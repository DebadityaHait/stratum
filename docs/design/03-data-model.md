# Data Model

Stratum stores object metadata in D1 and object bytes in the configured storage tiers.

## Core Tables

| Table | Purpose |
|---|---|
| `buckets` | Bucket records, public flags, counters, and configuration |
| `objects` | Object metadata, content headers, hashes, size, and Telegram references |
| `credentials` | S3 access keys, secret hashes, scope, and permission level |
| `multipart_uploads` | Active multipart upload sessions |
| `multipart_parts` | Uploaded part metadata for multipart completion |
| `share_tokens` | Public or password-protected share links |
| `object_tags` | S3 object tags |
| `lifecycle_rules` | Prefix and tag based expiration policy |
| `user_preferences` | Telegram bot and mini app user defaults |

## Object Identity

Objects are scoped by `(bucket, key)`. This mirrors S3 behavior and keeps listing queries simple. Each object row stores size, content type, ETag, creation time, modification time, user metadata, system metadata, and Telegram file identifiers.

## Consistency

PutObject writes the backing object first and then commits metadata. If metadata fails after a successful Telegram upload, the object can be treated as orphaned and later cleaned. DeleteObject removes D1 metadata synchronously and cleans Telegram/R2 state asynchronously.

## Credentials

Credential rows contain access key IDs, secret hashes, bucket scope, permission level, and active state. Lookup results can be cached briefly in Worker memory to reduce repeated D1 reads.

## Rate Limits

Telegram write paths need conservative throttling. The design uses an in-memory token bucket in the Worker isolate for write-heavy routes and retry handling for Telegram `429` responses.

## Cache Metadata

R2 cache entries use object keys derived from bucket and key, plus metadata that allows ETag validation. Cache cleanup checks whether the D1 source row still exists and whether the ETag still matches.
