# Database Functions Reference

## Overview

Database Functions (PL/pgSQL, SQL, PLV8) execute inside the PostgreSQL process with zero network latency. Ideal for data validation, triggers, complex aggregations, and transactional workflows.

## Basic Function Creation

### SQL Function (Simplest)

```sql
CREATE OR REPLACE FUNCTION get_user_email(user_id uuid)
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT email FROM auth.users WHERE id = user_id;
$$;
```

### PL/pgSQL Function (Most Common)

```sql
CREATE OR REPLACE FUNCTION increment_counter(row_id uuid)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  new_count integer;
BEGIN
  UPDATE counters
  SET count = count + 1
  WHERE id = row_id
  RETURNING count INTO new_count;

  RETURN new_count;
END;
$$;
```

## Security Modes

### SECURITY INVOKER (Default)

Runs with caller's privileges. Safest option:

```sql
CREATE FUNCTION my_function()
RETURNS void
LANGUAGE plpgsql
SECURITY INVOKER  -- Default, can omit
AS $$ ... $$;
```

### SECURITY DEFINER

Runs with function creator's privileges. **Dangerous if misused**:

```sql
CREATE FUNCTION admin_operation()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''  -- CRITICAL: Prevents injection
AS $$
BEGIN
  -- Has elevated privileges
  UPDATE public.users SET role = 'admin' WHERE ...;
END;
$$;

-- Restrict who can execute
REVOKE ALL ON FUNCTION admin_operation FROM PUBLIC;
GRANT EXECUTE ON FUNCTION admin_operation TO admin_role;
```

**Always set `search_path = ''`** with SECURITY DEFINER to prevent schema injection attacks.

## Triggers

### After Insert Trigger

```sql
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  -- Create profile for new user
  INSERT INTO public.profiles (id, email, created_at)
  VALUES (NEW.id, NEW.email, NOW());

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

### Before Update Trigger (Validation)

```sql
CREATE OR REPLACE FUNCTION validate_order_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Prevent invalid status transitions
  IF OLD.status = 'completed' AND NEW.status != 'completed' THEN
    RAISE EXCEPTION 'Cannot change status of completed order';
  END IF;

  -- Auto-update timestamp
  NEW.updated_at = NOW();

  RETURN NEW;
END;
$$;

CREATE TRIGGER before_order_update
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION validate_order_status();
```

### Audit Log Trigger

```sql
CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.audit_log (
    table_name,
    record_id,
    action,
    old_data,
    new_data,
    changed_by,
    changed_at
  ) VALUES (
    TG_TABLE_NAME,
    COALESCE(NEW.id, OLD.id),
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP != 'DELETE' THEN row_to_json(NEW) ELSE NULL END,
    auth.uid(),
    NOW()
  );

  RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER audit_orders
  AFTER INSERT OR UPDATE OR DELETE ON orders
  FOR EACH ROW EXECUTE FUNCTION audit_changes();
```

## Calling External APIs with pg_net

Database functions cannot make synchronous HTTP calls. Use `pg_net` for async requests:

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Async HTTP POST
CREATE OR REPLACE FUNCTION notify_webhook()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
BEGIN
  PERFORM net.http_post(
    url := 'https://project.supabase.co/functions/v1/webhook',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || current_setting('app.service_role_key', true),
      'Content-Type', 'application/json'
    ),
    body := jsonb_build_object(
      'event', 'new_order',
      'order_id', NEW.id,
      'amount', NEW.total
    )
  );

  RETURN NEW;
END;
$$;
```

**Note**: pg_net is fire-and-forget. No response handling in the function.

## Calling Functions from Client

### Via Supabase Client

```typescript
const { data, error } = await supabase.rpc('increment_counter', {
  row_id: '123e4567-e89b-12d3-a456-426614174000'
});
```

### With Parameters

```typescript
const { data } = await supabase.rpc('search_products', {
  search_term: 'laptop',
  min_price: 500,
  max_price: 2000
});
```

## Complex Queries as Functions

### Search with Full-Text

```sql
CREATE OR REPLACE FUNCTION search_documents(query text)
RETURNS SETOF documents
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM documents
  WHERE to_tsvector('english', title || ' ' || content)
        @@ plainto_tsquery('english', query)
  ORDER BY ts_rank(
    to_tsvector('english', title || ' ' || content),
    plainto_tsquery('english', query)
  ) DESC
  LIMIT 50;
END;
$$;
```

### Aggregation Function

```sql
CREATE OR REPLACE FUNCTION get_dashboard_stats(org_id uuid)
RETURNS TABLE (
  total_orders bigint,
  total_revenue numeric,
  avg_order_value numeric,
  orders_this_month bigint
)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*)::bigint,
    COALESCE(SUM(total), 0)::numeric,
    COALESCE(AVG(total), 0)::numeric,
    COUNT(*) FILTER (
      WHERE created_at >= date_trunc('month', CURRENT_DATE)
    )::bigint
  FROM orders
  WHERE orders.org_id = get_dashboard_stats.org_id;
END;
$$;
```

## Batch Operations

More efficient than multiple client calls:

```sql
CREATE OR REPLACE FUNCTION bulk_update_status(
  order_ids uuid[],
  new_status text
)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE orders
  SET status = new_status, updated_at = NOW()
  WHERE id = ANY(order_ids)
    AND status != 'completed';

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$;
```

## Returning JSON

```sql
CREATE OR REPLACE FUNCTION get_order_with_items(order_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  result jsonb;
BEGIN
  SELECT jsonb_build_object(
    'order', row_to_json(o),
    'items', (
      SELECT jsonb_agg(row_to_json(i))
      FROM order_items i
      WHERE i.order_id = o.id
    ),
    'customer', row_to_json(c)
  ) INTO result
  FROM orders o
  JOIN customers c ON o.customer_id = c.id
  WHERE o.id = get_order_with_items.order_id;

  RETURN result;
END;
$$;
```

## Error Handling

```sql
CREATE OR REPLACE FUNCTION safe_transfer(
  from_account uuid,
  to_account uuid,
  amount numeric
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
  from_balance numeric;
BEGIN
  -- Check balance
  SELECT balance INTO from_balance
  FROM accounts WHERE id = from_account
  FOR UPDATE;  -- Lock row

  IF from_balance IS NULL THEN
    RAISE EXCEPTION 'Source account not found'
      USING ERRCODE = 'P0001';
  END IF;

  IF from_balance < amount THEN
    RAISE EXCEPTION 'Insufficient funds: % < %', from_balance, amount
      USING ERRCODE = 'P0002';
  END IF;

  -- Perform transfer
  UPDATE accounts SET balance = balance - amount WHERE id = from_account;
  UPDATE accounts SET balance = balance + amount WHERE id = to_account;
END;
$$;
```

## Performance Tips

1. **Use STABLE/IMMUTABLE** for functions that don't modify data
2. **Add indexes** on columns used in WHERE clauses
3. **Use RETURN QUERY** instead of loops when possible
4. **Avoid SELECT *** in production functions
5. **Use FOR UPDATE** for row-level locking in transactions

## When to Use Database Functions vs Edge Functions

| Use Case | Database Function | Edge Function |
|----------|-------------------|---------------|
| Data validation | ✓ | |
| Triggers | ✓ | |
| Complex aggregations | ✓ | |
| Multi-table transactions | ✓ | |
| External API calls | | ✓ |
| File processing | | ✓ |
| Long computations | | ✓ |
| npm dependencies | | ✓ |
