# Stratum Feasibility Analysis

## Summary

Stratum is feasible as an S3-compatible object storage gateway on Cloudflare Workers. The practical zero-cost path is to keep the Worker as the API gateway, D1 as the metadata database, R2 as the warm cache, and Telegram Bot API as the cold storage backend.

The main tradeoff is file size. The public Bot API works well for files up to 20 MB that must later be downloaded by the Worker. A VPS running the local Telegram Bot API server is only needed for larger files, heavier media processing, or reliable range reads over large objects.

## Capability Matrix

| Capability | Free Cloudflare-only path | Requires VPS |
|---|---|---|
| S3 PUT, GET, HEAD, DELETE | Yes | No |
| Bucket and object listing | Yes | No |
| Presigned URLs | Yes | No |
| Multipart metadata flow | Yes | No |
| Files up to 20 MB | Yes | No |
| Files up to 2 GB | No | Yes |
| HEIC conversion and video transcoding | No | Yes |
| Public dashboard and Telegram mini app | Yes | No |

## Resource Fit

| Layer | Service | Free-tier fit |
|---|---|---|
| API gateway | Cloudflare Workers | Good for request routing, auth, S3 XML, and streaming |
| Metadata | Cloudflare D1 | Good for buckets, objects, credentials, shares, lifecycle rules |
| Warm cache | Cloudflare R2 | Good for recent files and cache refill |
| Hot cache | Cloudflare Cache | Good for repeated public reads |
| Cold storage | Telegram Bot API | Good for durable low-cost storage with strict rate limits |

## Key Risks

- Telegram API rate limits require conservative write throttling and retry behavior.
- Telegram is not an object-storage SLA, so D1 metadata and repair jobs are important.
- Worker memory and CPU budgets make heavy media processing unsuitable at the edge.
- The normal Bot API download limit keeps the pure serverless deployment focused on files up to 20 MB.

## Recommendation

Keep the default deployment serverless and free. Treat the VPS processor as an optional extension for users who need large objects, advanced media conversion, or range reads over files larger than the normal Bot API limit.
