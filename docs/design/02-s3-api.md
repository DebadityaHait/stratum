# S3 API

Stratum implements the practical S3 operations needed by common clients and the public dashboard.

## Supported Operations

| Operation | Route pattern | Notes |
|---|---|---|
| PutObject | `PUT /{bucket}/{key}` | Uploads object data through the S3 API path |
| GetObject | `GET /{bucket}/{key}` | Streams object data from cache, R2, or Telegram |
| HeadObject | `HEAD /{bucket}/{key}` | Returns object metadata |
| DeleteObject | `DELETE /{bucket}/{key}` | Removes metadata and asynchronously cleans backing storage |
| ListObjectsV2 | `GET /{bucket}?list-type=2` | Supports prefix-style object listing |
| ListBuckets | `GET /` with authenticated S3 request | Returns owned buckets for API clients |
| Multipart upload | S3 multipart routes | Tracks upload state and part metadata |
| Presigned URLs | Query-authenticated S3 URLs | Validates expiry and signature |
| Object tags | Tagging routes | Stores per-object tags in D1 |
| Lifecycle config | Lifecycle routes | Stores rules evaluated by scheduled cleanup |

## Public Root

Browser requests to `/` serve the Stratum dashboard as HTML. Authenticated S3-style root requests still use the API behavior where applicable.

## Demo Bucket

The public dashboard writes only to the `demo` bucket through `PUT /demo/{key}` and lists it through `GET /demo?list-type=2`. This keeps public demo writes scoped to a single bucket.

## Response Formats

S3 API responses use XML where S3 clients expect XML. Dashboard-only endpoints such as `/api/stats` return JSON.

## Integrity

Uploads verify available integrity headers, including SHA-256 payload checks and Content-MD5 where clients provide them.
