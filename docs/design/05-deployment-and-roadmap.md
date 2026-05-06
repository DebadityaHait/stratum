# Deployment and Roadmap

## Deployment Shape

The default deployment is a single Cloudflare Worker with D1 and R2 bindings.

```text
wrangler deploy
```

Required secrets include the Telegram bot token, default chat ID, and any optional processor credentials. D1 migrations must be applied before production traffic.

## Free Deployment

The free deployment supports the S3 API, public dashboard, Telegram bot, Telegram mini app, D1 metadata, R2 warm cache, and Telegram cold storage for files within the normal Bot API limits.

## Optional Processor

An external processor can be added later for:

- Local Telegram Bot API support
- files larger than the normal public Bot API limit
- media conversion
- large-object range reads
- background repair or reindex jobs

## Maintenance Jobs

Scheduled Worker jobs can clean expired shares, expired multipart uploads, orphaned parts, stale R2 cache entries, and lifecycle-expired objects.

## Roadmap

| Area | Planned work |
|---|---|
| Benchmarking | Capture real latency numbers for CDN, R2, and Telegram tiers |
| Dashboard | Add richer object previews and clearer upload error states |
| Mini app | Improve bucket and key management flows |
| Processor | Document the optional VPS path for large files |
| Repair | Add stronger orphan detection and metadata repair tooling |
