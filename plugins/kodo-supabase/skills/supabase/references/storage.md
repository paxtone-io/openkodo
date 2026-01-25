# Storage Reference

## Overview

S3-compatible object storage with CDN, image transformations, and RLS-based access control.

## Limits

| Resource | Free | Pro | Team |
|----------|------|-----|------|
| Storage | 1 GB | 100 GB | 100 GB |
| Bandwidth | 5 GB | 250 GB | 250 GB |
| Max file size | 50 MB | 50 GB (configurable) | 50 GB |
| Image transform origins | - | 100/month | 100/month |

**Overage pricing** (Pro+):
- Storage: $0.021/GB
- Bandwidth: $0.09/GB
- Image transforms: $5/1,000 origins

## Bucket Types

### Public Bucket

Files accessible without authentication:

```typescript
// Create public bucket
const { data, error } = await supabase.storage.createBucket('avatars', {
  public: true,
  fileSizeLimit: 1024 * 1024 * 2 // 2MB
})

// Public URL (no auth needed)
const publicUrl = supabase.storage
  .from('avatars')
  .getPublicUrl('user-123/profile.jpg')
```

### Private Bucket

Files require authentication:

```typescript
// Create private bucket
const { data, error } = await supabase.storage.createBucket('documents', {
  public: false,
  fileSizeLimit: 1024 * 1024 * 50 // 50MB
})

// Access requires signed URL
const { data } = await supabase.storage
  .from('documents')
  .createSignedUrl('report.pdf', 3600) // 1 hour expiry
```

## Upload Patterns

### Standard Upload (<6MB)

```typescript
const { data, error } = await supabase.storage
  .from('bucket-name')
  .upload('path/to/file.jpg', file, {
    cacheControl: '3600',
    upsert: false
  })
```

### Resumable Upload (TUS protocol, >6MB)

```typescript
const { data, error } = await supabase.storage
  .from('bucket-name')
  .upload('path/to/large-file.zip', file, {
    cacheControl: '3600',
    upsert: true
  })
// SDK automatically uses TUS for large files
```

### Upload from Server/Edge Function

```typescript
// From Edge Function
const file = await req.blob()

const { data, error } = await supabase.storage
  .from('uploads')
  .upload(`${userId}/${filename}`, file, {
    contentType: file.type
  })
```

## Download Patterns

### Public URL

```typescript
const { data } = supabase.storage
  .from('public-bucket')
  .getPublicUrl('image.jpg')

// With transform
const { data } = supabase.storage
  .from('public-bucket')
  .getPublicUrl('image.jpg', {
    transform: {
      width: 200,
      height: 200,
      resize: 'cover'
    }
  })
```

### Signed URL (Private Files)

```typescript
const { data, error } = await supabase.storage
  .from('private-bucket')
  .createSignedUrl('document.pdf', 60 * 60) // 1 hour

// Signed URL with transform
const { data, error } = await supabase.storage
  .from('private-bucket')
  .createSignedUrl('photo.jpg', 3600, {
    transform: {
      width: 400,
      quality: 80
    }
  })
```

### Download File

```typescript
const { data, error } = await supabase.storage
  .from('bucket')
  .download('path/to/file.pdf')

// data is a Blob
const url = URL.createObjectURL(data)
```

## Image Transformations

### Parameters

| Parameter | Values | Description |
|-----------|--------|-------------|
| width | 1-2500 | Target width in pixels |
| height | 1-2500 | Target height in pixels |
| resize | cover, contain, fill | Resize mode |
| quality | 20-100 | JPEG/WebP quality |
| format | origin, webp | Output format |

### URL Format

```
https://project.supabase.co/storage/v1/render/image/public/bucket/image.jpg?width=200&height=200&resize=cover
```

### Via Client

```typescript
const { data } = supabase.storage
  .from('bucket')
  .getPublicUrl('image.jpg', {
    transform: {
      width: 400,
      height: 300,
      resize: 'cover',
      quality: 80,
      format: 'webp'
    }
  })
```

### Limitations

- Max source size: 25 MB
- Max resolution: 50 megapixels
- Supported formats: JPEG, PNG, WebP, GIF, AVIF
- No SVG transformation

## Storage Policies (RLS)

### Enable RLS

```sql
-- Policies use the storage.objects table
-- Already has RLS enabled by default
```

### Common Policies

**Allow authenticated uploads to own folder:**

```sql
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
```

**Allow public read:**

```sql
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

**Allow users to manage own files:**

```sql
CREATE POLICY "Users can manage own files"
ON storage.objects
FOR ALL
TO authenticated
USING (
  bucket_id = 'documents' AND
  owner_id = auth.uid()
)
WITH CHECK (
  bucket_id = 'documents' AND
  owner_id = auth.uid()
);
```

### Helper Functions

```sql
-- Get folder path from file name
storage.foldername(name) -- Returns text[]

-- Get file extension
storage.extension(name) -- Returns text

-- Get filename without path
storage.filename(name) -- Returns text
```

## CDN and Caching

### Cache Control

```typescript
await supabase.storage
  .from('bucket')
  .upload('file.jpg', file, {
    cacheControl: '31536000' // 1 year
  })
```

### Smart CDN (Pro+)

Automatically invalidates CDN cache within 60 seconds when files change. Works with signed URLs.

Enable in Dashboard: Settings > Storage > Smart CDN

### Cache Headers

Public files use CDN automatically. For private files, signed URLs bypass CDN unless Smart CDN is enabled.

## File Management

### List Files

```typescript
const { data, error } = await supabase.storage
  .from('bucket')
  .list('folder/', {
    limit: 100,
    offset: 0,
    sortBy: { column: 'created_at', order: 'desc' }
  })
```

### Move/Copy Files

```typescript
// Move
const { data, error } = await supabase.storage
  .from('bucket')
  .move('old/path/file.jpg', 'new/path/file.jpg')

// Copy
const { data, error } = await supabase.storage
  .from('bucket')
  .copy('source/file.jpg', 'dest/file.jpg')
```

### Delete Files

```typescript
// Single file
const { data, error } = await supabase.storage
  .from('bucket')
  .remove(['path/to/file.jpg'])

// Multiple files
const { data, error } = await supabase.storage
  .from('bucket')
  .remove(['file1.jpg', 'file2.jpg', 'folder/file3.jpg'])
```

## React Upload Component Example

```typescript
import { useState } from 'react'
import { supabase } from './supabaseClient'

function FileUpload({ userId }: { userId: string }) {
  const [uploading, setUploading] = useState(false)

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    setUploading(true)

    const fileExt = file.name.split('.').pop()
    const filePath = `${userId}/${Date.now()}.${fileExt}`

    const { error } = await supabase.storage
      .from('uploads')
      .upload(filePath, file, {
        cacheControl: '3600',
        upsert: false
      })

    if (error) {
      console.error('Upload error:', error)
    } else {
      console.log('Uploaded:', filePath)
    }

    setUploading(false)
  }

  return (
    <input
      type="file"
      onChange={handleUpload}
      disabled={uploading}
    />
  )
}
```

## When to Use External Storage

Consider Cloudflare R2 or AWS S3 instead when:

- **High egress**: R2 has zero egress fees
- **50+ GB storage**: Cost comparison favors alternatives
- **Custom CDN requirements**: Need CloudFlare or custom CDN rules
- **Complex processing**: Need serverless image processing beyond transforms
