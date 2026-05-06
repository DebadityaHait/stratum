# Media and Sharing

## Media Handling

The serverless deployment stores media files as ordinary objects. Workers can set and preserve content headers, but heavy image or video processing should run outside the Worker runtime.

| Task | Serverless Worker | Optional VPS |
|---|---|---|
| Store JPEG, PNG, WebP, GIF, MP4 | Yes | Yes |
| Serve thumbnails already uploaded as objects | Yes | Yes |
| HEIC conversion | No | Yes |
| Video transcoding | No | Yes |
| Large-file range processing | Limited | Yes |

## Shares

Share links are backed by D1 tokens. A share token can point to a bucket/key pair and may include expiry, password hash, download limits, creator metadata, and a note.

## Share Validation

When a request uses a share token, the Worker checks:

- token existence
- expiry
- password state, if configured
- max download count
- referenced object existence

Successful downloads increment counters in D1.

## Public Demo Links

The dashboard copy-link action points to the public object URL for files in the `demo` bucket. This is intentionally simple so a visitor can upload, copy, and retrieve a demo object without credentials.
