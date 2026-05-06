# Architecture

## System Diagram

```text
S3 client / dashboard / bot
          |
          v
Cloudflare Worker
  - routing
  - auth and presigned URL validation
  - S3 XML and JSON responses
  - cache orchestration
          |
          +--> D1 metadata
          +--> Cloudflare Cache
          +--> R2 warm cache
          +--> Telegram Bot API cold storage
          +--> optional VPS processor for large files
```

## Worker

The Worker is the only public runtime. It parses S3-style requests, validates authentication where required, serves the public dashboard at `/`, and routes API traffic to the correct handler.

The dashboard intentionally reuses the S3 endpoints for uploads and listing. It does not have a separate upload path, which keeps demo behavior close to real API behavior.

## D1

D1 stores durable metadata for buckets, objects, credentials, multipart uploads, share tokens, lifecycle rules, object tags, and Telegram references. Object rows are scoped by bucket and key.

All dynamic D1 access should use parameterized statements.

## R2 and Cache

R2 stores warm copies of eligible objects. Cloudflare Cache handles hot repeated reads. Cache entries are validated against object metadata so overwritten or deleted files do not keep serving stale content.

## Telegram

Telegram is the cold storage backend. Each stored object maps to Telegram message and file identifiers saved in D1. The normal public Bot API is suitable for objects up to the size that Workers can later retrieve.

## Optional VPS

A VPS is not required for the mini app or the public dashboard. It is only needed for larger objects, Local Bot API support, range reads over large files, or CPU-heavy media processing.
