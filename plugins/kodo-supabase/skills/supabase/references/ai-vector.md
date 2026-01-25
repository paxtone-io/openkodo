# AI and Vector Reference

## pgvector Extension

PostgreSQL extension for vector similarity search. Store embeddings alongside relational data.

### Enable Extension

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

### Create Vector Column

```sql
CREATE TABLE documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  embedding vector(1536),  -- OpenAI ada-002
  created_at timestamptz DEFAULT now()
);

-- Or for smaller dimensions
CREATE TABLE documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  content text NOT NULL,
  embedding vector(384)  -- gte-small (Supabase built-in)
);
```

### Dimension Limits

| Index Type | Max Dimensions |
|------------|----------------|
| HNSW | 4,000 (halfvec) |
| IVFFlat | 2,000 |
| No index | 16,000 |

## Index Types

### HNSW (Recommended)

Hierarchical Navigable Small World graph. Best for most use cases.

```sql
CREATE INDEX ON documents
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

**Parameters:**
- `m`: Max connections per node (default 16, higher = better recall, more memory)
- `ef_construction`: Build-time search depth (default 64, higher = better index, slower build)

**Performance:**
- Query: ~1.5ms
- Build: 30-81s (depends on data size)
- Memory: Higher than IVFFlat

### IVFFlat

Inverted file index. Better for memory-constrained environments.

```sql
-- Create index AFTER data is loaded
CREATE INDEX ON documents
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

**Parameters:**
- `lists`: Number of clusters (rule of thumb: sqrt(rows) for <1M rows, rows/1000 for >1M)

**Performance:**
- Query: ~2.4ms
- Build: ~15s
- Memory: 2.8x less than HNSW

**Important:** IVFFlat should be created after data is loaded. Empty table = poor quality index.

## Distance Operators

| Operator | Function | Use Case |
|----------|----------|----------|
| `<->` | L2 distance | General similarity |
| `<=>` | Cosine distance | Normalized embeddings (OpenAI) |
| `<#>` | Inner product | When vectors aren't normalized |

```sql
-- Cosine similarity (most common)
SELECT * FROM documents
ORDER BY embedding <=> '[0.1, 0.2, ...]'::vector
LIMIT 10;

-- L2 distance
SELECT * FROM documents
ORDER BY embedding <-> '[0.1, 0.2, ...]'::vector
LIMIT 10;
```

## Similarity Search

### Basic Search

```sql
SELECT id, title, 1 - (embedding <=> $1) as similarity
FROM documents
WHERE embedding <=> $1 < 0.5  -- Distance threshold
ORDER BY embedding <=> $1
LIMIT 10;
```

### With Filters

```sql
SELECT id, title, 1 - (embedding <=> $1) as similarity
FROM documents
WHERE category = 'technology'
  AND created_at > now() - interval '30 days'
ORDER BY embedding <=> $1
LIMIT 10;
```

### Search Function

```sql
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.78,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  title text,
  content text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    id,
    title,
    content,
    1 - (embedding <=> query_embedding) as similarity
  FROM documents
  WHERE 1 - (embedding <=> query_embedding) > match_threshold
  ORDER BY embedding <=> query_embedding
  LIMIT match_count;
$$;
```

### Call from Client

```typescript
const { data } = await supabase.rpc('match_documents', {
  query_embedding: embedding,
  match_threshold: 0.78,
  match_count: 10
})
```

## Generate Embeddings

### Supabase Built-in (gte-small, 384 dimensions)

```typescript
// Edge Function
const session = new Supabase.ai.Session('gte-small')

const embedding = await session.run(text, {
  mean_pool: true,
  normalize: true
})
// Returns Float32Array[384]
```

**Advantages:**
- No external API calls
- ~100-200ms CPU time
- No extra cost

### OpenAI (ada-002, 1536 dimensions)

```typescript
import OpenAI from 'npm:openai@4.0.0'

const openai = new OpenAI({
  apiKey: Deno.env.get('OPENAI_API_KEY')
})

const response = await openai.embeddings.create({
  model: 'text-embedding-ada-002',
  input: text
})

const embedding = response.data[0].embedding
// Returns number[1536]
```

### Batch Embedding Generation

```typescript
// Edge Function for batch processing
serve(async (req) => {
  const { texts } = await req.json()
  const session = new Supabase.ai.Session('gte-small')

  const embeddings = await Promise.all(
    texts.map(text => session.run(text, { mean_pool: true, normalize: true }))
  )

  return new Response(JSON.stringify({ embeddings }))
})
```

## Automatic Embeddings

Supabase can auto-generate embeddings on insert/update.

### Using Database Webhook + Edge Function

```sql
-- Create webhook trigger
CREATE TRIGGER generate_embedding_trigger
  AFTER INSERT OR UPDATE ON documents
  FOR EACH ROW
  EXECUTE FUNCTION supabase_functions.http_request(
    'https://PROJECT.supabase.co/functions/v1/generate-embedding',
    'POST',
    '{"Authorization": "Bearer SERVICE_ROLE_KEY"}',
    '{}',
    '5000'
  );
```

```typescript
// Edge Function
serve(async (req) => {
  const { record, type } = await req.json()

  if (type === 'INSERT' || type === 'UPDATE') {
    const session = new Supabase.ai.Session('gte-small')
    const embedding = await session.run(record.content)

    const supabase = createClient(url, serviceKey)
    await supabase
      .from('documents')
      .update({ embedding: Array.from(embedding) })
      .eq('id', record.id)
  }

  return new Response('ok')
})
```

## RAG Pattern (Retrieval Augmented Generation)

```typescript
async function ragQuery(question: string) {
  const supabase = createClient(url, key)

  // 1. Generate embedding for question
  const questionEmbedding = await generateEmbedding(question)

  // 2. Find relevant documents
  const { data: documents } = await supabase.rpc('match_documents', {
    query_embedding: questionEmbedding,
    match_threshold: 0.7,
    match_count: 5
  })

  // 3. Build context
  const context = documents
    .map(doc => doc.content)
    .join('\n\n')

  // 4. Generate response with LLM
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [
      {
        role: 'system',
        content: `Answer based on the following context:\n\n${context}`
      },
      { role: 'user', content: question }
    ]
  })

  return response.choices[0].message.content
}
```

## Hybrid Search (Vector + Full-Text)

```sql
CREATE OR REPLACE FUNCTION hybrid_search(
  query_text text,
  query_embedding vector(1536),
  match_count int DEFAULT 10,
  full_text_weight float DEFAULT 1,
  semantic_weight float DEFAULT 1,
  rrf_k int DEFAULT 60
)
RETURNS TABLE (
  id uuid,
  title text,
  content text,
  score float
)
LANGUAGE sql STABLE
AS $$
WITH full_text AS (
  SELECT id,
    row_number() OVER (ORDER BY ts_rank(to_tsvector('english', content), plainto_tsquery(query_text)) DESC) as rank
  FROM documents
  WHERE to_tsvector('english', content) @@ plainto_tsquery(query_text)
  LIMIT 20
),
semantic AS (
  SELECT id,
    row_number() OVER (ORDER BY embedding <=> query_embedding) as rank
  FROM documents
  ORDER BY embedding <=> query_embedding
  LIMIT 20
)
SELECT
  d.id,
  d.title,
  d.content,
  COALESCE(1.0 / (rrf_k + ft.rank), 0) * full_text_weight +
  COALESCE(1.0 / (rrf_k + s.rank), 0) * semantic_weight as score
FROM documents d
LEFT JOIN full_text ft ON d.id = ft.id
LEFT JOIN semantic s ON d.id = s.id
WHERE ft.id IS NOT NULL OR s.id IS NOT NULL
ORDER BY score DESC
LIMIT match_count;
$$;
```

## Performance Tips

1. **Choose right index**: HNSW for frequent queries, IVFFlat for memory constraints
2. **Filter before search**: Add WHERE clauses to reduce search space
3. **Use appropriate dimensions**: Smaller embeddings = faster search
4. **Batch operations**: Insert embeddings in batches, not one at a time
5. **Partial indexes**: Create indexes for commonly filtered subsets

```sql
-- Partial index for active documents only
CREATE INDEX ON documents
USING hnsw (embedding vector_cosine_ops)
WHERE status = 'active';
```

## Scaling Limits

| Vector Count | Recommendation |
|--------------|----------------|
| <1M | Single table, standard indexes |
| 1M-10M | Optimize indexes, partition tables |
| 10M-100M | Consider read replicas |
| >100M | Dedicated vector DB (Pinecone, Weaviate) |

**pgvector advantage**: SQL joins with vector similarity in single query--not possible with dedicated vector DBs.
