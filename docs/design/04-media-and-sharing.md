# åª’ä½“å¤„ç†ä¸Žæ–‡ä»¶åˆ†äº«

## ä¸€ã€æ–‡ä»¶åˆ†å—å¼•æ“Ž [Phase 2 - åˆ†å—ä¸Šä¼ /ä¸‹è½½æœªå®žçŽ°]

> å½“å‰å®žçŽ°ä¸­ï¼Œå•æ–‡ä»¶é€šè¿‡ Bot API ä¸Šä¼  (<=20MB) æˆ– VPS Local Bot API (<=2GB)ã€‚
> åˆ†å—ä¸Šä¼ /ä¸‹è½½æµç¨‹ç”¨äºŽçªç ´ 2GB é™åˆ¶ï¼Œç•™å¾…åŽç»­ç‰ˆæœ¬å®žçŽ°ã€‚chunks è¡¨å·²åˆ›å»ºï¼ŒCRUD
> æ“ä½œå·²å®žçŽ°ï¼Œå½“å‰ç”¨äºŽ DeleteObject æ—¶æ¸…ç†å…³è”çš„ chunk è®°å½•å’Œ TG æ¶ˆæ¯ã€‚

### åˆ†å—ç­–ç•¥

| éƒ¨ç½²æ–¹å¼ | å—å¤§å° | åŽŸå›  |
|---------|--------|------|
| çº¯ Worker (Bot API) | 18 MB | ç•™ 2MB ä½™é‡ï¼ˆ20MB ä¸‹è½½é™åˆ¶ï¼‰ |
| VPS (Local Bot API) | 1.8 GB | ç•™ä½™é‡ï¼ˆ2GB é™åˆ¶ï¼‰ |

### ä¸Šä¼ åˆ†å—æµç¨‹

```
å¤§æ–‡ä»¶ (>= chunk_size)
    â”‚
    â”œâ”€ 1. Worker/VPS æŽ¥æ”¶å®Œæ•´æ–‡ä»¶æµ
    â”œâ”€ 2. æµå¼åˆ‡å—ï¼Œæ¯å—é€ TG sendDocument
    â”œâ”€ 3. æ¯å—èŽ·å¾— file_id, message_id
    â”œâ”€ 4. å†™å…¥ chunks è¡¨:
    â”‚     chunk_index=0, offset=0, size=18MB, file_id=aaa
    â”‚     chunk_index=1, offset=18MB, size=18MB, file_id=bbb
    â”‚     chunk_index=2, offset=36MB, size=5MB, file_id=ccc
    â”‚
    â””â”€ 5. å†™å…¥ objects è¡¨: size=41MB (chunks è¡¨è®°å½•åˆ†å—æ˜ å°„, Phase 2 éœ€æ‰©å±• objects è¡¨å¢žåŠ  is_chunked/chunk_count åˆ—)
```

### ä¸‹è½½é‡ç»„è£…æµç¨‹

```
GetObject è¯·æ±‚ â†’ æŸ¥ D1 â†’ is_chunked=true
    â”‚
    â”œâ”€ æ—  Range header: æŒ‰åºä¸‹è½½æ‰€æœ‰å—ï¼Œæµå¼æ‹¼æŽ¥è¿”å›ž
    â”‚   chunk_0 â†’ stream â†’ chunk_1 â†’ stream â†’ chunk_2 â†’ stream â†’ å®Œæˆ
    â”‚
    â””â”€ æœ‰ Range header: è®¡ç®—ç›®æ ‡å—ï¼Œåªä¸‹è½½éœ€è¦çš„å—
        Range: bytes=20000000-25000000
        â†’ ç›®æ ‡ chunk_index=1 (offset 18MB-36MB)
        â†’ åœ¨ chunk å†… offset = 20MB - 18MB = 2MB
        â†’ ä¸‹è½½ chunk_1ï¼Œseek åˆ° 2MBï¼Œè¯»å– 5MB
```

### Range è¯·æ±‚å®žçŽ°

```typescript
interface RangeResult {
  startChunk: number;
  endChunk: number;
  startOffset: number;  // åœ¨ç¬¬ä¸€ä¸ª chunk å†…çš„åç§»
  endOffset: number;    // åœ¨æœ€åŽä¸€ä¸ª chunk å†…çš„ç»“æŸä½ç½®
}

function resolveRange(
  chunks: ChunkInfo[],
  rangeStart: number,
  rangeEnd: number
): RangeResult {
  let startChunk = -1, endChunk = -1;
  for (const chunk of chunks) {
    if (startChunk < 0 && chunk.offset + chunk.size > rangeStart) {
      startChunk = chunk.chunk_index;
    }
    if (chunk.offset + chunk.size >= rangeEnd) {
      endChunk = chunk.chunk_index;
      break;
    }
  }
  return {
    startChunk,
    endChunk,
    startOffset: rangeStart - chunks[startChunk].offset,
    endOffset: rangeEnd - chunks[endChunk].offset,
  };
}
```

---

## äºŒã€åª’ä½“å¤„ç†ç®¡çº¿ [Phase 2 - éœ€ VPS]

> å½“å‰å®žçŽ°ä¸­ï¼ŒWorker æ”¯æŒå›¾ç‰‡å˜ä½“è¯·æ±‚ (?w=, ?fmt=) å¹¶é€šè¿‡ VPS API å¤„ç†ã€‚
> å®Œæ•´çš„è‡ªåŠ¨åª’ä½“å¤„ç†ç®¡çº¿ï¼ˆHEIC è½¬æ¢ã€è§†é¢‘è½¬ç ã€ç¼©ç•¥å›¾ç”Ÿæˆï¼‰éœ€ VPS é…åˆï¼Œç•™å¾…åŽç»­å®Œå–„ã€‚

### æž¶æž„

```
ä¸Šä¼ è¯·æ±‚ â†’ Worker
    â”‚
    â”œâ”€ æ™®é€šæ–‡ä»¶ â†’ ç›´æŽ¥å­˜ TG â†’ å®Œæˆ
    â”‚
    â””â”€ åª’ä½“æ–‡ä»¶ (å›¾ç‰‡/è§†é¢‘/å®žå†µç…§ç‰‡)
         â”‚
         â”œâ”€ åŽŸå§‹æ–‡ä»¶ â†’ å­˜ TG (ä¿ç•™åŽŸä»¶)
         â”‚
         â””â”€ æŽ¨é€å¤„ç†ä»»åŠ¡åˆ° VPS
              â”‚
              â”œâ”€ å›¾ç‰‡: sharp å¤„ç†
              â”‚   â”œâ”€ HEIC â†’ JPEG (å…¨å°ºå¯¸)
              â”‚   â”œâ”€ ç”Ÿæˆ WebP ç¼©ç•¥å›¾ (å¤šå°ºå¯¸)
              â”‚   â””â”€ æå– EXIF å…ƒæ•°æ®
              â”‚
              â”œâ”€ å®žå†µç…§ç‰‡: sharp + ffmpeg
              â”‚   â”œâ”€ HEIC â†’ JPEG
              â”‚   â”œâ”€ MOV â†’ MP4 (H.264, web å…¼å®¹)
              â”‚   â””â”€ æå– ContentIdentifier å…³è”
              â”‚
              â””â”€ è§†é¢‘: ffmpeg
                  â”œâ”€ è½¬ç  H.264 MP4
                  â”œâ”€ ç”Ÿæˆå°é¢å¸§ JPEG
                  â””â”€ å¯é€‰: å¤šç çŽ‡ HLS åˆ†æ®µ
              â”‚
              â””â”€ è¡ç”Ÿæ–‡ä»¶ â†’ å­˜ TG â†’ æ›´æ–° D1 å…ƒæ•°æ®
```

### å¤„ç†ä»»åŠ¡é˜Ÿåˆ—

Worker ä¸Ž VPS ä¹‹é—´é€šè¿‡ HTTP API é€šä¿¡ï¼š

```typescript
// Worker ä¾§: æäº¤å¤„ç†ä»»åŠ¡
async function submitMediaJob(file: ObjectMetadata, type: MediaJobType) {
  await fetch(`${VPS_URL}/api/jobs`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${VPS_SECRET}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      bucket: file.bucket,
      key: file.key,
      tg_file_id: file.tg_file_id,
      job_type: type,  // 'image_convert' | 'video_transcode' | 'live_photo'
    }),
  });
}
```

VPS ä¾§ APIï¼š

```
POST /api/jobs              æäº¤åª’ä½“å¤„ç†ä»»åŠ¡
GET  /api/jobs/:id          æŸ¥è¯¢ä»»åŠ¡çŠ¶æ€
POST /api/proxy/get         ä»Ž TG ä¸‹è½½æ–‡ä»¶ï¼ˆä¾› Worker å¤§æ–‡ä»¶ä½¿ç”¨ï¼‰
POST /api/proxy/put         ä¸Šä¼ æ–‡ä»¶åˆ° TGï¼ˆä¾› Worker å¤§æ–‡ä»¶ä½¿ç”¨ï¼‰
POST /api/proxy/range       Range è¯»å–ï¼ˆå¤§æ–‡ä»¶ï¼ŒPOST body å« file_id/start/endï¼‰
POST /api/proxy/consolidate Multipart åˆå¹¶ï¼ˆå°†å¤šä¸ª TG part æ‹¼æŽ¥ä¸ºå•æ–‡ä»¶ï¼‰
GET  /api/image/resize      å›¾ç‰‡å˜ä½“ï¼ˆquery: tg_file_id, width?, format?ï¼‰
```

### å›¾ç‰‡å¤„ç†ç»†èŠ‚

```typescript
// VPS ä¾§: sharp å¤„ç†
import sharp from 'sharp';

async function processImage(inputBuffer: Buffer, format: string) {
  const pipeline = sharp(inputBuffer);

  // è¯»å–å…ƒæ•°æ®
  const metadata = await pipeline.metadata();

  const results = {
    // å…¨å°ºå¯¸ JPEGï¼ˆä»Ž HEIC è½¬æ¢ï¼‰
    full: await sharp(inputBuffer)
      .jpeg({ quality: 90, mozjpeg: true })
      .toBuffer(),

    // ç¼©ç•¥å›¾ 400px å®½
    thumb_400: await sharp(inputBuffer)
      .resize(400, null, { withoutEnlargement: true })
      .webp({ quality: 80 })
      .toBuffer(),

    // ç¼©ç•¥å›¾ 200px å®½
    thumb_200: await sharp(inputBuffer)
      .resize(200, null, { withoutEnlargement: true })
      .webp({ quality: 75 })
      .toBuffer(),

    metadata: {
      width: metadata.width,
      height: metadata.height,
      format: metadata.format,
      exif: metadata.exif,
    },
  };

  return results;
}
```

### å®žå†µç…§ç‰‡å¤„ç†

```typescript
// VPS ä¾§
async function processLivePhoto(heicBuffer: Buffer, movBuffer: Buffer) {
  // 1. ä»Ž HEIC æå– ContentIdentifier
  const heicId = await extractContentIdentifier(heicBuffer);

  // 2. ä»Ž MOV æå– ContentIdentifier
  const movId = await extractMovContentIdentifier(movBuffer);

  // 3. éªŒè¯é…å¯¹
  if (heicId !== movId) throw new Error('Live Photo pair mismatch');

  // 4. è½¬æ¢é™æ€å›¾
  const jpeg = await sharp(heicBuffer).jpeg({ quality: 90 }).toBuffer();

  // 5. è½¬æ¢è§†é¢‘
  // ffmpeg -i input.mov -c:v libx264 -c:a aac -movflags +faststart output.mp4
  const mp4 = await ffmpegConvert(movBuffer, {
    videoCodec: 'libx264',
    audioCodec: 'aac',
    movflags: '+faststart',
  });

  // 6. ç”Ÿæˆç¼©ç•¥å›¾
  const thumb = await sharp(heicBuffer)
    .resize(400)
    .webp({ quality: 80 })
    .toBuffer();

  return { jpeg, mp4, thumb, contentIdentifier: heicId };
}
```

### å®žå†µç…§ç‰‡ Web å±•ç¤º

```html
<!-- ä½¿ç”¨ Apple LivePhotosKit JS -->
<script src="https://cdn.apple-livephotoskit.com/lpk/1/livephotoskit.js"></script>

<div
  data-live-photo
  data-photo-src="/share/{token}/inline"
  data-video-src="/share/{token}/live-video"
  style="width:100%;height:auto;aspect-ratio:4/3;border-radius:8px">
</div>
```

### è§†é¢‘è½¬ç 

```typescript
// VPS ä¾§
async function transcodeVideo(inputPath: string, outputPath: string) {
  // æ ‡å‡† H.264 MP4ï¼Œweb å‹å¥½
  await exec(`ffmpeg -i ${inputPath} \
    -c:v libx264 -preset medium -crf 23 \
    -c:a aac -b:a 128k \
    -movflags +faststart \
    -y ${outputPath}`);

  // ç”Ÿæˆå°é¢å¸§
  await exec(`ffmpeg -i ${inputPath} \
    -ss 00:00:01 -vframes 1 \
    -y ${outputPath}.poster.jpg`);
}
```

### è¡ç”Ÿæ–‡ä»¶å­˜å‚¨

å¤„ç†åŽçš„è¡ç”Ÿæ–‡ä»¶ä»¥çº¦å®šçš„ key å­˜å›ž TG + D1ï¼š

```
åŽŸå§‹æ–‡ä»¶: photos/IMG_0001.heic
è¡ç”Ÿæ–‡ä»¶:
  photos/IMG_0001.heic._derivatives/full.jpg
  photos/IMG_0001.heic._derivatives/thumb_400.webp
  photos/IMG_0001.heic._derivatives/thumb_200.webp
  photos/IMG_0001.heic._derivatives/video.mp4        (å®žå†µç…§ç‰‡)
  photos/IMG_0001.heic._derivatives/poster.jpg        (è§†é¢‘å°é¢)
  photos/IMG_0001.heic._derivatives/metadata.json     (EXIFç­‰)
```

D1 ä¸­ objects è¡¨å­˜å‚¨è¡ç”Ÿæ–‡ä»¶æ—¶ï¼Œå¯ä»¥åŠ ä¸€ä¸ªå­—æ®µå…³è”åŽŸå§‹æ–‡ä»¶ï¼š

```sql
ALTER TABLE objects ADD COLUMN derived_from TEXT;
-- derived_from = 'photos/IMG_0001.heic' è¡¨ç¤ºè¿™æ˜¯è¡ç”Ÿæ–‡ä»¶
```

---

## ä¸‰ã€æ–‡ä»¶åˆ†äº«ç³»ç»Ÿ

### åˆ†äº« Token ç”Ÿæˆ

```typescript
interface ShareOptions {
  bucket: string;
  key: string;
  expiresIn?: number;       // ç§’ï¼Œnull=æ°¸ä¸è¿‡æœŸ
  password?: string;        // æ˜Žæ–‡ï¼Œå­˜å‚¨æ—¶å“ˆå¸Œ
  maxDownloads?: number;    // null=æ— é™åˆ¶
  note?: string;
}

async function createShareToken(opts: ShareOptions, env: Env): Promise<ShareTokenRow> {
  const token = generateToken(32);           // 32å­—èŠ‚éšæœº, base64url
  const now = new Date().toISOString();
  const expiresAt = opts.expiresIn
    ? new Date(Date.now() + opts.expiresIn * 1000).toISOString()
    : null;
  const passwordHash = opts.password
    ? await hashPassword(opts.password)       // PBKDF2 (CF Workers ä¸æ”¯æŒ bcrypt)
    : null;

  const row: ShareTokenRow = {
    token, bucket: opts.bucket, key: opts.key,
    created_at: now, expires_at: expiresAt,
    password_hash: passwordHash,
    max_downloads: opts.maxDownloads ?? null,
    download_count: 0, creator: null, note: opts.note ?? null,
  };
  await store.createShareToken(row);
  return row;                                 // è¿”å›žå®Œæ•´ ShareTokenRowï¼Œéžä»… token å­—ç¬¦ä¸²
}
```

### åˆ†äº«é“¾æŽ¥æ ¼å¼

```
https://stratum.example.com/share/{token}                    (æµè§ˆå™¨: HTML é¢„è§ˆé¡µ; API: ç›´æŽ¥ä¸‹è½½)
https://stratum.example.com/share/{token}/download           (å¼ºåˆ¶ä¸‹è½½ï¼Œè®¡å…¥ä¸‹è½½æ¬¡æ•°)
https://stratum.example.com/share/{token}/inline             (å†…è”åª’ä½“ï¼Œç”¨äºŽé¢„è§ˆé¡µåµŒå…¥ï¼Œä¸è®¡ä¸‹è½½æ¬¡æ•°ï¼Œcookie éªŒè¯å£ä»¤)
https://stratum.example.com/share/{token}/live-video         (å®žå†µç…§ç‰‡è§†é¢‘ç»„ä»¶ï¼Œä¸è®¡ä¸‹è½½æ¬¡æ•°ï¼Œcookie éªŒè¯å£ä»¤)
```

> å®‰å…¨è¯´æ˜Ž: `/inline` å’Œ `/live-video` ä¸ç›´æŽ¥éªŒè¯å£ä»¤ï¼Œè€Œæ˜¯æ£€æŸ¥ session cookieã€‚å£ä»¤ä¿æŠ¤çš„åˆ†äº«åœ¨é¢„è§ˆé¡µé€šè¿‡ POST éªŒè¯å£ä»¤åŽï¼ŒæœåŠ¡ç«¯è®¾ç½® `HttpOnly; SameSite=Lax; Secure` çš„ session cookieï¼ˆ1 å°æ—¶æœ‰æ•ˆï¼‰ã€‚åŽç»­ `<img>`/`<video>`/`<audio>` çš„ src è¯·æ±‚è‡ªåŠ¨æºå¸¦æ­¤ cookieï¼Œæ— éœ€å†æ¬¡è¾“å…¥å£ä»¤ã€‚æ— å£ä»¤çš„åˆ†äº«åˆ™æ— éœ€ cookieï¼Œç›´æŽ¥è¿”å›žå†…å®¹ã€‚

å£ä»¤æäº¤æ–¹å¼ï¼š
- POST è¡¨å•ï¼ˆæŽ¨èï¼‰: `POST /share/{token}` body åŒ…å« `password` å­—æ®µ
- Query paramï¼ˆå…¼å®¹ä¿ç•™ï¼‰: `GET /share/{token}?password=xxx`

> å®‰å…¨è¯´æ˜Ž: GET query param æ–¹å¼ä¼šå°†å£ä»¤æ˜Žæ–‡æš´éœ²åœ¨ URL ä¸­ï¼ˆæµè§ˆå™¨åŽ†å²ã€æœåŠ¡ç«¯æ—¥å¿—ã€Referer å¤´ï¼‰ï¼ŒæŽ¨èä½¿ç”¨ POST è¡¨å•æ–¹å¼æäº¤å£ä»¤ã€‚

### åˆ†äº«è®¿é—®æµç¨‹

```
GET /share/{token}
    â”‚
    â”œâ”€ 1. æŸ¥ D1 share_tokens è¡¨
    â”‚
    â”œâ”€ 2. æ£€æŸ¥è¿‡æœŸ
    â”‚     expires_at IS NOT NULL AND expires_at < NOW â†’ 410 Gone (æ¸²æŸ“è¿‡æœŸé¡µé¢)
    â”‚
    â”œâ”€ 3. æ£€æŸ¥ä¸‹è½½æ¬¡æ•°
    â”‚     download_count >= max_downloads â†’ 410 Gone (æ¸²æŸ“æ¬¡æ•°ç”¨å°½é¡µé¢)
    â”‚
    â”œâ”€ 4. æ£€æŸ¥å£ä»¤ (PBKDF2 éªŒè¯ + æš´åŠ›ç ´è§£é˜²æŠ¤)
    â”‚     password_hash IS NOT NULL
    â”‚     â”œâ”€ æ£€æŸ¥ share_password_attempts è¡¨: åŒä¸€ token+IP å¤±è´¥ >=5 æ¬¡ â†’ é”å®š 15 åˆ†é’Ÿ (429)
    â”‚     â”œâ”€ POST form æˆ– query param æœ‰ password â†’ éªŒè¯å“ˆå¸Œ
    â”‚     â”‚   â”œâ”€ å¤±è´¥ â†’ è®°å½•å¤±è´¥æ¬¡æ•°åˆ° share_password_attempts
    â”‚     â”‚   â””â”€ æˆåŠŸ â†’ æ¸…é™¤è¯¥ token+IP çš„å¤±è´¥è®°å½•
    â”‚     â””â”€ æ—  password â†’ è¿”å›ž HTML å£ä»¤è¾“å…¥é¡µé¢
    â”‚
    â”œâ”€ 5. éªŒè¯é€šè¿‡, æ—  action (åªæŸ¥çœ‹é¢„è§ˆé¡µ, ä¸è®¡ä¸‹è½½æ¬¡æ•°):
    â”‚     æµè§ˆå™¨è®¿é—® (Accept: text/html) â†’ è¿”å›ž HTML é¢„è§ˆé¡µ
    â”‚     â”œâ”€ å›¾ç‰‡ â†’ <img> å†…è”å±•ç¤º
    â”‚     â”œâ”€ è§†é¢‘ â†’ <video> æ’­æ”¾å™¨
    â”‚     â”œâ”€ éŸ³é¢‘ â†’ <audio> æ’­æ”¾å™¨
    â”‚     â”œâ”€ PDF â†’ <embed> å†…åµŒé¢„è§ˆ
    â”‚     â”œâ”€ æ–‡æœ¬/JSON/XML (<=512KB) â†’ <pre> é¢„è§ˆ (JS fetch)
    â”‚     â”œâ”€ å®žå†µç…§ç‰‡ â†’ LivePhotosKit å±•ç¤º
    â”‚     â””â”€ å…¶ä»– â†’ ä»…æ˜¾ç¤ºæ–‡ä»¶ä¿¡æ¯å’Œä¸‹è½½æŒ‰é’®
    â”‚     é¡µé¢åŠŸèƒ½: å®žæ—¶å€’è®¡æ—¶ã€å¤åˆ¶é“¾æŽ¥æŒ‰é’®ã€æš—è‰²æ¨¡å¼é€‚é…
    â”‚
    â”œâ”€ 6. /download æˆ– API è®¿é—® â†’ å¢žåŠ ä¸‹è½½è®¡æ•° â†’ æµå¼è¿”å›žæ–‡ä»¶
    â”‚
    â”œâ”€ 7. /inline â†’ æ£€æŸ¥ session cookie (å£ä»¤ä¿æŠ¤æ—¶) â†’ è¿”å›žæ–‡ä»¶å†…å®¹ (ä¸è®¡ä¸‹è½½æ¬¡æ•°)
    â”‚
    â””â”€ 8. /live-video â†’ æ£€æŸ¥ session cookie (å£ä»¤ä¿æŠ¤æ—¶) â†’ è¿”å›žå®žå†µç…§ç‰‡è§†é¢‘ (ä¸è®¡ä¸‹è½½æ¬¡æ•°)
```

### åˆ†äº«é¡µé¢åŠŸèƒ½ï¼ˆHTMLï¼Œç”± `src/sharing/pages.ts` æ¸²æŸ“ï¼‰

å®žé™…å®žçŽ°çš„åˆ†äº«é¢„è§ˆé¡µåŒ…å«ä»¥ä¸‹åŠŸèƒ½ï¼š

- **å¤šåª’ä½“é¢„è§ˆ**: å›¾ç‰‡ `<img>`ã€è§†é¢‘ `<video>`ã€éŸ³é¢‘ `<audio>`ã€PDF `<embed>`ã€æ–‡æœ¬ `<pre>`ï¼ˆJS fetchï¼Œ<=512KBï¼‰
- **å®žå†µç…§ç‰‡**: Apple è®¾å¤‡å¼•å…¥ LivePhotosKit JS æ’­æ”¾å™¨ï¼›éž Apple è®¾å¤‡ï¼ˆAndroid ç­‰ï¼‰é™çº§ä¸ºå›¾ç‰‡ + è§†é¢‘ç‹¬ç«‹å±•ç¤ºï¼ˆJS UA æ£€æµ‹è‡ªåŠ¨åˆ‡æ¢ï¼‰
- **å®žæ—¶å€’è®¡æ—¶**: JS æ¯ç§’æ›´æ–°ï¼Œæ˜¾ç¤º "Xå¤©Xæ—¶Xåˆ†Xç§’"
- **ä¸‹è½½ + å¤åˆ¶é“¾æŽ¥**: åŒæŒ‰é’®å¸ƒå±€ï¼Œå¤åˆ¶é“¾æŽ¥ä½¿ç”¨ `navigator.clipboard.writeText`
- **æš—è‰²æ¨¡å¼**: `@media(prefers-color-scheme:dark)` è‡ªåŠ¨é€‚é…
- **å£ä»¤é¡µé¢**: æ”¯æŒ POST è¡¨å•æäº¤ï¼ˆ`method="POST"`ï¼‰å’Œ GET query paramï¼ˆ`?password=xxx`ï¼‰ä¸¤ç§æ–¹å¼
- **å£ä»¤æš´åŠ›ç ´è§£é˜²æŠ¤**: åŒä¸€ token+IP å¤±è´¥ 5 æ¬¡åŽé”å®š 15 åˆ†é’Ÿï¼Œè¿”å›ž 429 + Retry-Afterï¼›æˆåŠŸéªŒè¯åŽæ¸…é™¤è®°å½•ï¼›Cron æ¸…ç†è¿‡æœŸè®°å½•
- **è¿‡æœŸé¡µé¢**: åŒºåˆ† expired / max_downloads / download_failed / not_found å››ç§çŠ¶æ€ï¼Œæ˜¾ç¤ºä¸åŒæç¤ºæ–‡æ¡ˆ

### S3 é¢„ç­¾å URL

æ ‡å‡† S3 é¢„ç­¾å URL ä¹Ÿè¦æ”¯æŒï¼Œä¾› rclone ç­‰å·¥å…·ä½¿ç”¨ï¼š

```
https://stratum.example.com/bucket/key
  ?X-Amz-Algorithm=AWS4-HMAC-SHA256
  &X-Amz-Credential=AKID/20260315/auto/s3/aws4_request
  &X-Amz-Date=20260315T080000Z
  &X-Amz-Expires=3600
  &X-Amz-SignedHeaders=host
  &X-Amz-Signature=abcdef...
```

éªŒè¯æµç¨‹åŒ SigV4ï¼Œä»Ž query params æå–ç­¾åä¿¡æ¯ï¼Œé‡å»ºå¹¶æ ¡éªŒã€‚

`X-Amz-Expires` ä¸Šé™ä¸º 604800 ç§’ï¼ˆ7 å¤©ï¼‰ã€‚ç”Ÿæˆé¢„ç­¾å URL æ—¶è¶…å‡ºæ­¤å€¼å°†è¢«æˆªæ–­ï¼›éªŒè¯å¤–éƒ¨é¢„ç­¾å URL æ—¶è¶…å‡ºæ­¤å€¼å°†ç›´æŽ¥æ‹’ç»ï¼ˆä¸Ž AWS S3 è¡Œä¸ºä¸€è‡´ï¼‰ã€‚

### åˆ†äº«ç®¡ç† APIï¼ˆéž S3ï¼Œä¾› Web UI å’Œ Bot ä½¿ç”¨ï¼‰

```
POST   /api/shares              åˆ›å»ºåˆ†äº«
GET    /api/shares              åˆ—å‡ºæ‰€æœ‰åˆ†äº«
GET    /api/shares/:token       æŸ¥çœ‹åˆ†äº«è¯¦æƒ…
DELETE /api/shares/:token       æ’¤é”€åˆ†äº«
PATCH  /api/shares/:token       ä¿®æ”¹åˆ†äº«ï¼ˆå»¶é•¿æ—¶æ•ˆã€æ”¹å£ä»¤ç­‰ï¼‰
```

---

## å››ã€å›¾åºŠåŠŸèƒ½

### å›¾åºŠç›´é“¾

å›¾ç‰‡ä¸Šä¼ åŽï¼Œå¯ä»¥é€šè¿‡ä»¥ä¸‹ URL ç›´æŽ¥è®¿é—®ï¼š

```
S3 è·¯å¾„:  https://stratum.example.com/images/photo.jpg
ç›´é“¾:     https://stratum.example.com/images/photo.jpg          (åŽŸå›¾)
ç¼©ç•¥å›¾:   https://stratum.example.com/images/photo.jpg?w=400    (å®½åº¦ 400px)
æ ¼å¼è½¬æ¢: https://stratum.example.com/images/photo.jpg?fmt=webp  (è½¬ WebP)
```

### å›¾ç‰‡å˜ä½“è¯·æ±‚å¤„ç† [å·²å®žçŽ°]

é›†æˆåœ¨ `handleGetObject` ä¸­ä½œä¸º `handleImageVariant` å­æµç¨‹ï¼ˆ`src/handlers/get-object.ts`ï¼‰ã€‚

```
GET /{bucket}/{key}?w=400         â†’ å®½åº¦ 400px å˜ä½“
GET /{bucket}/{key}?fmt=webp      â†’ WebP æ ¼å¼
GET /{bucket}/{key}?w=200&fmt=webp â†’ ç»„åˆ

å¤„ç†æµç¨‹:
  1. æ£€æŸ¥ Content-Type æ˜¯å¦ä¸ºå›¾ç‰‡ï¼ˆisImageContentTypeï¼‰
  2. ç”Ÿæˆå˜ä½“ key: `{key}._derivatives/w${width || 'orig'}_${format || 'original'}`
  3. æŸ¥ D1 æ˜¯å¦å·²æœ‰ç¼“å­˜çš„å˜ä½“ â†’ æœ‰åˆ™ç›´æŽ¥è¿”å›ž
  4. æ—  VPS: å›žé€€è¿”å›žåŽŸå›¾ï¼ˆCache-Control: no-storeï¼Œé˜²æ­¢ç¼“å­˜æ±¡æŸ“ï¼‰
  5. æœ‰ VPS: è°ƒç”¨ GET /api/image/resize?tg_file_id=...&width=...&format=...
  6. VPS å¤„ç†å¤±è´¥: å›žé€€è¿”å›žåŽŸå›¾ï¼ˆCache-Control: no-storeï¼Œé˜²æ­¢ CDN å°†åŽŸå›¾ç¼“å­˜ä¸ºå˜ä½“ï¼‰
  7. æˆåŠŸ: å¼‚æ­¥å°†å˜ä½“å­˜å›ž TG + D1ï¼ˆderived_from å…³è”åŽŸå§‹æ–‡ä»¶ï¼‰ï¼Œç›´æŽ¥è¿”å›žå˜ä½“
```

### Markdown/HTML åµŒå…¥æ”¯æŒ

å›¾åºŠå…¸åž‹ç”¨æ³• -- è¿”å›žå¯åµŒå…¥çš„ URLï¼š

```markdown
![photo](https://stratum.example.com/images/photo.jpg)
![thumbnail](https://stratum.example.com/images/photo.jpg?w=400)
```

Worker å¯¹å›¾ç‰‡è¯·æ±‚è®¾ç½®åˆé€‚çš„ CORS å’Œ Cache å¤´ï¼š

```typescript
headers['Access-Control-Allow-Origin'] = '*';
headers['Cache-Control'] = 'public, max-age=31536000, immutable';
headers['Content-Disposition'] = 'inline';  // æµè§ˆå™¨å†…è”æ˜¾ç¤ºï¼Œä¸ä¸‹è½½
```

---

## äº”ã€Bot æ–‡ä»¶ä¸Šä¼ 

ç”¨æˆ·ç›´æŽ¥å‘é€æ–‡ä»¶ç»™ Bot å³å¯ä¸Šä¼ åˆ°é»˜è®¤ Bucketï¼š

```
ç”¨æˆ·å‘é€æ–‡ä»¶ç»™ Bot:
  1. Webhook æ”¶åˆ°æ–‡ä»¶æ¶ˆæ¯ (document/photo/video/audio)
  2. æå– file_id, file_unique_id, file_name, file_size, mime_type
  3. å¤§å°é¢„æ£€: æ–‡ä»¶ >20MB ä¸”æœªé…ç½® VPS æ—¶ï¼Œæç¤ºç”¨æˆ·è¯¥æ–‡ä»¶æ— æ³•é€šè¿‡ S3 API ä¸‹è½½ï¼Œæ‹’ç»è®°å½•
  4. å†…å®¹åŽ»é‡: æŒ‰ tg_file_unique_id æŸ¥è¯¢ï¼Œå¦‚å·²æœ‰ç›¸åŒå†…å®¹çš„å¯¹è±¡åˆ™è¿”å›žæç¤ºè€Œéžé‡å¤è®°å½•
  5. ä½¿ç”¨ç”¨æˆ·é€šè¿‡ /setbucket è®¾ç½®çš„é»˜è®¤ Bucketï¼Œæœªè®¾ç½®åˆ™é€‰æ‹©ç¬¬ä¸€ä¸ª (æ—  Bucket åˆ™æç¤ºå…ˆåˆ›å»º)
  6. æ–‡ä»¶åå†²çªæ—¶è‡ªåŠ¨åŠ æ—¶é—´æˆ³åŽç¼€
  7. ç›´æŽ¥è®°å½• TG file_id åˆ° D1 (æ–‡ä»¶å·²åœ¨ TGï¼Œæ— éœ€é‡æ–°ä¸Šä¼ )
  8. è¿”å›žä¸Šä¼ ç¡®è®¤ (bucket åã€æ–‡ä»¶åã€å¤§å°)
```

æ”¯æŒçš„æ–‡ä»¶ç±»åž‹ï¼šdocumentã€photoï¼ˆå–æœ€å¤§å°ºå¯¸ï¼‰ã€videoã€audioã€‚

### åˆ é™¤ç¡®è®¤æœºåˆ¶

Bot çš„ `/delete` å‘½ä»¤ä½¿ç”¨ Inline Keyboard äºŒæ¬¡ç¡®è®¤ï¼š

```
ç”¨æˆ·: /delete docs report.pdf
Bot: [æ˜¾ç¤ºæ–‡ä»¶ä¿¡æ¯ + ç¡®è®¤/å–æ¶ˆæŒ‰é’®]
ç”¨æˆ·: [ç‚¹å‡»ç¡®è®¤]
Bot: [åˆ é™¤æ–‡ä»¶ + D1 è®°å½• + å…³è”åˆ†äº«ï¼Œç¼–è¾‘åŽŸæ¶ˆæ¯æ˜¾ç¤ºç»“æžœ]
```

Callback data æ ¼å¼ï¼š`del_yes:{shortId}` / `del_no:{shortId}`ã€‚
ä½¿ç”¨å†…å­˜ Map å­˜å‚¨ shortId â†’ {bucket, key} æ˜ å°„ï¼Œé¿å… TG 64 å­—èŠ‚ callback_data é™åˆ¶å¯¼è‡´é•¿è·¯å¾„æˆªæ–­ã€‚
æ˜ å°„ 5 åˆ†é’Ÿè¿‡æœŸï¼Œè¿‡æœŸåŽæç¤ºç”¨æˆ·é‡æ–°æ‰§è¡Œå‘½ä»¤ã€‚
