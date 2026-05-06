# Design Overview

Stratum is an S3-compatible object storage service built for Cloudflare Workers. It exposes familiar S3-style HTTP endpoints while storing metadata in D1, recent objects in R2, and cold object payloads in Telegram.

## Goals

- Preserve practical S3 client compatibility for common object operations.
- Keep the default deployment inside Cloudflare's free tier.
- Make the public dashboard useful without creating a second hosting surface.
- Keep Telegram-specific storage details behind the S3 API boundary.

## Non-goals

- Replacing a production object store with a formal SLA.
- Running heavy media transcoding inside Workers.
- Making the public demo bucket private or credential-gated.

## Main Surfaces

| Surface | Purpose |
|---|---|
| S3-compatible API | Programmatic storage access for clients and tools |
| Public dashboard | Demo upload, listing, stats, and architecture presentation |
| Telegram bot | Operational access from Telegram |
| Telegram mini app | Bucket, file, share, and key management inside Telegram |

## Storage Tiers

```text
Client -> Worker -> D1 metadata
                -> Cloudflare Cache for hot reads
                -> R2 for warm objects
                -> Telegram Bot API for cold storage
```
