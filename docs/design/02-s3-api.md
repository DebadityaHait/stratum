# S3 API è§„èŒƒ

## è¯·æ±‚è·¯ç”±

Worker é€šè¿‡ HTTP Method + Path + Query Params åˆ¤æ–­ S3 æ“ä½œç±»åž‹ï¼š

```typescript
// è·¯ç”±ä¼ªä»£ç 
function routeS3Request(method: string, path: string, query: URLSearchParams): S3Operation {
  const { bucket, key } = parsePath(path);

  if (!bucket) {
    if (method === 'GET') return 'ListBuckets';
  }

  if (!key) {
    if (method === 'GET' && query.has('location'))     return 'GetBucketLocation';
    if (method === 'GET' && query.has('versioning'))   return 'GetBucketVersioning';
    if (method === 'GET' && query.has('uploads'))      return 'ListMultipartUploads';
    if (method === 'GET' && query.get('list-type')==='2') return 'ListObjectsV2';
    if (method === 'GET')                              return 'ListObjects'; // v1
    if (method === 'HEAD')                             return 'HeadBucket';
    if (method === 'PUT')                              return 'CreateBucket';
    if (method === 'DELETE')                            return 'DeleteBucket';
    if (method === 'POST' && query.has('delete'))       return 'DeleteObjects';
  }

  if (key) {
    if (method === 'GET' && query.has('uploadId'))     return 'ListParts';
    if (method === 'GET')                              return 'GetObject';
    if (method === 'HEAD')                             return 'HeadObject'; // å«å­èµ„æºæ£€æŸ¥
    if (method === 'PUT' && query.has('partNumber') && hasHeader('x-amz-copy-source'))
                                                        return 'UploadPartCopy';
    if (method === 'PUT' && query.has('partNumber'))    return 'UploadPart';
    if (method === 'PUT' && hasHeader('x-amz-copy-source'))
                                                        return 'CopyObject';
    if (method === 'PUT')                              return 'PutObject';
    if (method === 'DELETE' && query.has('uploadId'))    return 'AbortMultipartUpload';
    if (method === 'DELETE')                            return 'DeleteObject';
    if (method === 'POST' && query.has('uploads'))      return 'CreateMultipartUpload';
    if (method === 'POST' && query.has('uploadId'))     return 'CompleteMultipartUpload';
  }
}
```

### ä¸æ”¯æŒçš„å­èµ„æºæ“ä½œå®‰å…¨ç½‘

è·¯ç”±åœ¨åŒ¹é…æ•°æ®æ“ä½œï¼ˆGetObject/HeadObject/PutObject/DeleteObjectï¼‰ä¹‹å‰ï¼Œä¼šæ£€æŸ¥è¯·æ±‚æ˜¯å¦æºå¸¦ä¸æ”¯æŒçš„ S3 å­èµ„æºæŸ¥è¯¢å‚æ•°ï¼ˆå¦‚ `?acl`, `?policy` ç­‰ï¼‰ã€‚å¦‚æžœåŒ¹é…åˆ°ä¸æ”¯æŒçš„å­èµ„æºï¼Œè¿”å›ž `501 NotImplemented` è€Œéžè½åˆ°æ•°æ®æ“ä½œã€‚è¿™é˜²æ­¢äº†å®¢æˆ·ç«¯å‘é€ `PUT /{bucket}/{key}?acl` æ—¶å°† ACL XML body å½“ä½œæ–‡ä»¶å†…å®¹è¦†ç›–å†™å…¥çš„æ•°æ®æŸåé£Žé™©ã€‚

å·²å®žçŽ°çš„å­èµ„æº: `tagging`ï¼ˆå¯¹è±¡æ ‡ç­¾ï¼‰ã€`lifecycle`ï¼ˆç”Ÿå‘½å‘¨æœŸè§„åˆ™ï¼‰ã€`uploads`/`uploadId`ï¼ˆåˆ†æ®µä¸Šä¼ ï¼‰ã€‚

æ‹¦æˆªçš„å­èµ„æºåˆ—è¡¨: `acl`, `policy`, `cors`, `encryption`, `notification`, `replication`, `website`, `logging`, `analytics`, `metrics`, `inventory`, `accelerate`, `requestPayment`, `object-lock`, `legal-hold`, `retention`, `torrent`, `restore`, `select`, `intelligent-tiering`, `ownershipControls`, `publicAccessBlock`, `versions`ã€‚

## è·¯å¾„æ ¼å¼

æ”¯æŒ Path-styleï¼ˆä¸æ”¯æŒ Virtual-hosted-styleï¼Œå› ä¸ºéœ€è¦é€šé…ç¬¦ DNSï¼‰ï¼š

```
https://stratum.example.com/{bucket}/{key}
https://stratum.example.com/             â†’ ListBuckets
https://stratum.example.com/photos/      â†’ ListObjectsV2 (bucket=photos)
https://stratum.example.com/photos/a.jpg â†’ GetObject (bucket=photos, key=a.jpg)
```

## å„æ“ä½œè¯¦ç»†è§„èŒƒ

### PutObject

```
PUT /{bucket}/{key}
Headers:
  Content-Type: application/octet-stream (æˆ–å®žé™…ç±»åž‹)
  Content-Length: 12345
  Content-MD5: base64 (å¯é€‰, å®Œæ•´æ€§æ ¡éªŒ)
  x-amz-meta-*: è‡ªå®šä¹‰å…ƒæ•°æ®
  x-amz-tagging: key1=val1&key2=val2 (å¯é€‰, æœ€å¤š 10 ä¸ªæ ‡ç­¾, key<=128 chars, value<=256 chars)
  x-amz-server-side-encryption-customer-algorithm: AES256 (SSE-C)
  x-amz-server-side-encryption: AES256 (SSE-S3, éœ€é…ç½® SSE_MASTER_KEY)
Body: æ–‡ä»¶å†…å®¹
```

å¤§å°è·¯ç”±ï¼š
- åˆ†å—ä¼ è¾“ç¼–ç  (chunked): Worker å†…å­˜ç¼“å†², ä¸Šé™ 100MB (WORKER_BODY_LIMIT)
- <=20MB: Worker å†…å­˜ç¼“å†², é€šè¿‡ Bot API ä¸Šä¼ 
- 20MB-2GB: æµå¼è½¬å‘åˆ° VPS, VPS è®¡ç®— ETag å¹¶ä¸Šä¼ åˆ° TG Local Bot API

å¤„ç†æµç¨‹ï¼š
1. éªŒè¯è®¤è¯
2. æ£€æŸ¥é€ŸçŽ‡é™åˆ¶
3. è¯»å– Content-Type, Content-Length, x-amz-meta-*, x-amz-tagging headers
4. éªŒè¯æ ‡ç­¾: æœ€å¤š 10 ä¸ª, key<=128, value<=256
5. æ”¯æŒæ¡ä»¶å†™å…¥: `If-None-Match: *` é˜»æ­¢è¦†ç›–å·²æœ‰å¯¹è±¡ï¼Œè¿”å›ž 412 PreconditionFailed
6. è®¡ç®—è¯·æ±‚ä½“ MD5 ä½œä¸º ETag (å¤§æ–‡ä»¶ç”± VPS è®¡ç®—)
7. åˆ¤æ–­å¤§å°è·¯ç”±åˆ° TG Bot API æˆ– VPS
7. è°ƒç”¨ TG sendDocument:
   ```
   POST https://api.telegram.org/bot{token}/sendDocument
   Content-Type: multipart/form-data
   chat_id: {bucket_channel_id}
   document: (æ–‡ä»¶å†…å®¹)
   filename: {key} (æ–‡ä»¶åæ˜¾ç¤ºåœ¨ TG æ¶ˆæ¯ä¸­)
   ```
8. ä»Ž TG å“åº”æå– file_id, file_unique_id, message_id
9. INSERT INTO objects ... ON CONFLICT(bucket, key) DO UPDATEï¼ˆè¦†ç›–å†™ï¼‰
10. å¦‚æžœæ˜¯è¦†ç›–å†™ï¼Œåˆ é™¤æ—§çš„ TG æ¶ˆæ¯ï¼ˆå¼‚æ­¥ï¼Œå¯é€‰ï¼‰

å“åº”ï¼š
```xml
HTTP/1.1 200 OK
ETag: "d41d8cd98f00b204e9800998ecf8427e"
```

### GetObject

```
GET /{bucket}/{key}
Headers:
  Range: bytes=0-999 (å¯é€‰)
  If-Match: "etag" (å¯é€‰, ä¸åŒ¹é…è¿”å›ž 412)
  If-None-Match: "etag" (å¯é€‰, åŒ¹é…è¿”å›ž 304)
  If-Modified-Since: <date> (å¯é€‰, æœªä¿®æ”¹è¿”å›ž 304)
  If-Unmodified-Since: <date> (å¯é€‰, å·²ä¿®æ”¹è¿”å›ž 412)

Query Parameters:
  partNumber=<n>           (å¯é€‰, è¿”å›žå¤šæ®µä¸Šä¼ å¯¹è±¡çš„ç¬¬ n æ®µ, 206 å“åº”)
  response-content-type    (å¯é€‰, è¦†ç›–å“åº” Content-Type)
  response-content-disposition (å¯é€‰, è¦†ç›– Content-Disposition, å¦‚å¼ºåˆ¶ä¸‹è½½)
  response-content-encoding    (å¯é€‰, è¦†ç›– Content-Encoding)
  response-content-language    (å¯é€‰, è¦†ç›– Content-Language)
  response-cache-control       (å¯é€‰, è¦†ç›– Cache-Control)
  response-expires             (å¯é€‰, è¦†ç›– Expires)
  w=<width>    (å›¾ç‰‡ä¸“ç”¨, ç¼©æ”¾å®½åº¦ 1-4096px, é«˜åº¦æŒ‰æ¯”ä¾‹)
  fmt=<format> (å›¾ç‰‡ä¸“ç”¨, æ ¼å¼è½¬æ¢: auto/webp/jpeg/jpg/png/avif)
  q=<quality>  (å›¾ç‰‡ä¸“ç”¨, è´¨é‡ 1-100)
  original=1   (å›¾ç‰‡ä¸“ç”¨, è·³è¿‡è‡ªåŠ¨è½¬æ¢è¿”å›žåŽŸå§‹æ–‡ä»¶)
```

å¤„ç†æµç¨‹ï¼š
1. éªŒè¯è®¤è¯ï¼ˆSigV4 / Bearer / é¢„ç­¾å URLï¼‰
2. æŸ¥ D1 èŽ·å–å…ƒæ•°æ®
3. æ¡ä»¶è¯·æ±‚å¤„ç†ï¼ˆæŒ‰ S3 ä¼˜å…ˆçº§ï¼‰ï¼š
   - If-Match â†’ ä¸åŒ¹é…è¿”å›ž 412
   - If-Unmodified-Since â†’ å·²ä¿®æ”¹è¿”å›ž 412ï¼ˆIf-Match å­˜åœ¨æ—¶è·³è¿‡ï¼‰
   - If-None-Match â†’ åŒ¹é…è¿”å›ž 304
   - If-Modified-Since â†’ æœªä¿®æ”¹è¿”å›ž 304ï¼ˆIf-None-Match å­˜åœ¨æ—¶è·³è¿‡ï¼‰
4. ä¸‰å±‚ç¼“å­˜æŸ¥æ‰¾ï¼ˆéž Range è¯·æ±‚ï¼Œ<=20MBï¼‰ï¼š
   a. ç¬¬ 1 å±‚: CDN Cache â†’ ETag ä¸€è‡´åˆ™ç›´æŽ¥è¿”å›ž
   b. ç¬¬ 2 å±‚: R2 ç¼“å­˜ (64KB-20MB) â†’ ETag ä¸€è‡´åˆ™è¿”å›žå¹¶å›žå¡« CDN
   c. ç¬¬ 3 å±‚: TG æºç«™ï¼ˆä¸‹è½½åŽå›žå¡« CDN + R2ï¼‰
5. æŒ‰æ–‡ä»¶å¤§å°è·¯ç”±ä¸‹è½½ï¼š
   a. <=20MB: Worker è°ƒ TG Bot API getFile â†’ æµå¼è¿”å›žï¼›Range è¯·æ±‚åœ¨ Worker å†…åˆ‡ç‰‡
   b. >20MB: Worker è¯·æ±‚ VPS â†’ VPS é€šè¿‡ Local Bot API ä¸‹è½½ â†’ æµå¼è¿”å›žï¼ˆå« Range æ”¯æŒï¼‰
6. å›¾ç‰‡å˜ä½“å¤„ç†ï¼ˆw/fmt/q å‚æ•°ï¼‰ï¼š
   - HEIC/HEIF è‡ªåŠ¨è½¬æ¢ä¸ºæµè§ˆå™¨å…¼å®¹æ ¼å¼ï¼ˆé™¤éžä¼  original=1ï¼‰
   - fmt=auto æ ¹æ® Accept å¤´é€‰æ‹©æœ€ä¼˜æ ¼å¼ï¼ˆAVIF > WebP > JPEGï¼‰
   - å˜ä½“ç¼“å­˜åˆ° D1 + TGï¼ŒåŽç»­è¯·æ±‚ç›´æŽ¥è¿”å›ž
   - åŠ å¯†å¯¹è±¡ä¸æ”¯æŒå›¾ç‰‡å˜ä½“

å“åº”ï¼š
```
HTTP/1.1 200 OK
Content-Type: image/jpeg
Content-Length: 12345
ETag: "d41d8cd98f00b204e9800998ecf8427e"
Last-Modified: Mon, 15 Mar 2026 08:00:00 GMT
Cache-Control: public, max-age=86400

(æ–‡ä»¶å†…å®¹æµ)
```

### HeadObject

åŒ GetObject ä½†ä¸è¿”å›ž bodyï¼Œåªè¿”å›ž headersã€‚ç›´æŽ¥æŸ¥ D1ï¼Œä¸è°ƒ TG APIã€‚

### DeleteObject

```
DELETE /{bucket}/{key}
```

å¤„ç†æµç¨‹ï¼š
1. éªŒè¯è®¤è¯
2. æŸ¥ D1 èŽ·å–å…ƒæ•°æ®
3. DELETE FROM objects WHERE bucket=? AND key=?
4. å¼‚æ­¥æ¸…ç†ï¼ˆå…¨éƒ¨ best-effortï¼Œä¸é˜»å¡ž 204 å“åº”ï¼‰ï¼š
   a. åˆ é™¤ TG æ¶ˆæ¯
   b. åˆ é™¤æ´¾ç”Ÿæ–‡ä»¶ (derivatives)
   c. åˆ é™¤åˆ†å—æ¶ˆæ¯ (chunks)
   d. åˆ é™¤å…³è”çš„åˆ†äº«ä»¤ç‰Œ (share tokens)
   e. æ¸…é™¤ CDN ç¼“å­˜
   f. æ¸…é™¤ R2 ç¼“å­˜

å“åº”ï¼š
```
HTTP/1.1 204 No Content
```

### ListObjectsV2

```
GET /{bucket}?list-type=2&prefix=photos/&delimiter=/&max-keys=1000&continuation-token=xxx
```

å¤„ç†æµç¨‹ï¼š
1. éªŒè¯è®¤è¯
2. SQL æŸ¥è¯¢ D1ï¼š
   ```sql
   SELECT key, size, etag, last_modified, content_type
   FROM objects
   WHERE bucket = ?
     AND key >= ?           -- prefix
     AND key < ?            -- prefix çš„ä¸‹ä¸€ä¸ªå­—å…¸åº
   ORDER BY key ASC
   LIMIT ? + 1              -- max-keys + 1ï¼ˆåˆ¤æ–­æ˜¯å¦ truncatedï¼‰
   ```
3. å¦‚æžœæœ‰ delimiterï¼ˆé€šå¸¸æ˜¯ `/`ï¼‰ï¼Œéœ€è¦åœ¨ç»“æžœä¸­æå– CommonPrefixesï¼š
   ```typescript
   // å¯¹äºŽ prefix="photos/", delimiter="/"
   // key="photos/2024/a.jpg" â†’ CommonPrefix="photos/2024/"
   // key="photos/b.jpg" â†’ æ­£å¸¸ Contents æ¡ç›®
   ```
4. ç”Ÿæˆ XML å“åº”

å“åº”ï¼š
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
  <Name>photos</Name>
  <Prefix>photos/</Prefix>
  <Delimiter>/</Delimiter>
  <MaxKeys>1000</MaxKeys>
  <IsTruncated>false</IsTruncated>
  <Contents>
    <Key>photos/b.jpg</Key>
    <LastModified>2026-03-15T08:00:00.000Z</LastModified>
    <ETag>&quot;d41d8cd9...&quot;</ETag>
    <Size>12345</Size>
    <StorageClass>STANDARD</StorageClass>
  </Contents>
  <CommonPrefixes>
    <Prefix>photos/2024/</Prefix>
  </CommonPrefixes>
</ListBucketResult>
```

### CopyObject

```
PUT /{dest-bucket}/{dest-key}
Headers:
  x-amz-copy-source: /{src-bucket}/{src-key}
  x-amz-metadata-directive: COPY | REPLACE (é»˜è®¤ COPY)
  x-amz-tagging-directive: COPY | REPLACE (é»˜è®¤ COPY)
  x-amz-tagging: key1=val1&key2=val2 (ä»… tagging-directive=REPLACE æ—¶ä½¿ç”¨)
```

å¤„ç†æµç¨‹ï¼š
1. è§£æž `x-amz-copy-source` headerï¼ˆURL è§£ç ï¼ŒåŽ»é™¤ `?versionId=`ï¼‰
2. è‡ªèº«å¤åˆ¶ä¿æŠ¤: åŒ bucket åŒ key + COPY directive â†’ è¿”å›ž 400 InvalidRequestï¼ˆAWS S3 æ ‡å‡†è¡Œä¸ºï¼Œä¸å…è®¸ä¸ä¿®æ”¹å…ƒæ•°æ®çš„è‡ªèº«å¤åˆ¶ï¼‰
3. æŸ¥ D1 èŽ·å–æºå¯¹è±¡å…ƒæ•°æ®ï¼Œæ”¯æŒæ¡ä»¶ copy headersï¼ˆif-match/if-none-match/if-modified-since/if-unmodified-sinceï¼‰
4. æ£€æŸ¥ `x-amz-metadata-directive`: COPYï¼ˆé»˜è®¤ï¼Œä¿ç•™æºå…ƒæ•°æ®ï¼‰æˆ– REPLACEï¼ˆä½¿ç”¨è¯·æ±‚ä¸­çš„æ–°å…ƒæ•°æ®ï¼‰
5. æ£€æŸ¥ `x-amz-tagging-directive`: COPYï¼ˆé»˜è®¤ï¼Œå¤åˆ¶æºå¯¹è±¡æ ‡ç­¾ï¼‰æˆ– REPLACEï¼ˆä½¿ç”¨ `x-amz-tagging` header ä¸­çš„æ–°æ ‡ç­¾ï¼‰
5. åŒ bucket: å¤ç”¨åŒä¸€ä¸ª file_idï¼Œä»… INSERT D1 è®°å½•
   - ç‰¹æ®Šæƒ…å†µ: 0 å­—èŠ‚å¯¹è±¡ (`__zero__` sentinel) çš„ tg_chat_id æŒ‡å‘ç›®æ ‡ bucket çš„ chat_id
6. è·¨ bucket: è°ƒç”¨ TG `forwardMessage`ï¼ˆå« `message_thread_id`ï¼‰è½¬å‘æ¶ˆæ¯åˆ°ç›®æ ‡é¢‘é“/è¯é¢˜ï¼ˆå—é€ŸçŽ‡é™åˆ¶ï¼‰ï¼ŒèŽ·å–æ–°çš„ file_id + message_id
   - ç‰¹æ®Šæƒ…å†µ: Bot ä¸Šä¼ çš„æ–‡ä»¶ (tg_message_id=0) æ— é¢‘é“æ¶ˆæ¯å¯è½¬å‘ï¼Œæ”¹ç”¨ `sendDocumentByFileId` é‡æ–°å‘é€
7. å¦‚æžœç›®æ ‡ key å·²æœ‰å¯¹è±¡ï¼ˆè¦†ç›–å†™ï¼‰ï¼Œå¼‚æ­¥åˆ é™¤æ—§ TG æ¶ˆæ¯
8. å¼‚æ­¥æ¸…é™¤ç›®æ ‡ key çš„ CDN + R2 ç¼“å­˜

### DeleteObjects (æ‰¹é‡åˆ é™¤)

```
POST /{bucket}?delete
Body:
<Delete>
  <Object><Key>file1.txt</Key></Object>
  <Object><Key>file2.txt</Key></Object>
</Delete>
```

å¤„ç†æµç¨‹ï¼š
1. è§£æž XML bodyï¼Œæ ¡éªŒ Content-MD5ï¼ˆå¿…éœ€ï¼Œç¼ºå¤±è¿”å›ž 400 MissingContentMD5ï¼‰
2. é€æ¡å¤„ç†æ¯ä¸ª keyï¼ˆéžæ‰¹é‡ SQLï¼Œå› ä¸ºæ¯æ¡éœ€è¦ç‹¬ç«‹çš„å‰¯ä½œç”¨å¤„ç†ï¼‰ï¼š
   - åˆ é™¤ D1 å¯¹è±¡è®°å½• + æ›´æ–° bucket ç»Ÿè®¡
   - åˆ é™¤å…³è”çš„è¡ç”Ÿæ–‡ä»¶ï¼ˆ_derivativesï¼‰
   - åˆ é™¤å…³è”çš„ share_tokens
   - å¼‚æ­¥åˆ é™¤ TG æ¶ˆæ¯ + CDN/R2 ç¼“å­˜
3. æ”¯æŒ `<Quiet>true</Quiet>` æ¨¡å¼ï¼ˆåªè¿”å›žé”™è¯¯æ¡ç›®ï¼‰
4. è¿”å›žç»“æžœ XML

### CreateMultipartUpload

```
POST /{bucket}/{key}?uploads
```

å¤„ç†ï¼š
1. ç”Ÿæˆ uploadId (UUID v4, `crypto.randomUUID()`)
2. INSERT INTO multipart_uploads (upload_id, bucket, key, created_at)
3. è¿”å›ž uploadId

### UploadPart

```
PUT /{bucket}/{key}?partNumber=1&uploadId=xxx
Body: part å†…å®¹
```

å¤„ç†ï¼š
1. ä¸Šä¼  part åˆ° TG ä½œä¸ºç‹¬ç«‹æ–‡ä»¶
2. INSERT INTO multipart_parts (upload_id, part_number, size, etag, file_id)
3. è¿”å›ž ETag

### CompleteMultipartUpload

```
POST /{bucket}/{key}?uploadId=xxx
Body:
<CompleteMultipartUpload>
  <Part><PartNumber>1</PartNumber><ETag>"aaa"</ETag></Part>
  <Part><PartNumber>2</PartNumber><ETag>"bbb"</ETag></Part>
</CompleteMultipartUpload>
```

å¤„ç†ç­–ç•¥ï¼ˆæ··åˆæ–¹æ¡ˆï¼‰ï¼š
- **æ€»å¤§å° <=20MB**ï¼šWorker å†…å­˜ä¸­ä¸‹è½½æ‰€æœ‰ partsï¼Œæ‹¼æŽ¥ï¼Œé€šè¿‡ Bot API é‡æ–°ä¸Šä¼ ä¸ºå•ä¸ªæ–‡ä»¶ï¼Œå¼‚æ­¥åˆ é™¤ part æ¶ˆæ¯
- **æ€»å¤§å° >20MB ä¸”æœ‰ VPS**ï¼šå§”æ‰˜ VPS é€šè¿‡ `POST /api/proxy/consolidate` åˆå¹¶æ‰€æœ‰ parts ä¸ºå•ä¸ªæ–‡ä»¶
- **æ€»å¤§å° >2GB (VPS) æˆ– >20MB (æ—  VPS)**ï¼šè¿”å›ž `EntityTooLarge` é”™è¯¯

### ListBuckets

```
GET /
```

æŸ¥ D1 buckets è¡¨ï¼Œè¿”å›žï¼š
```xml
<ListAllMyBucketsResult>
  <Buckets>
    <Bucket>
      <Name>photos</Name>
      <CreationDate>2026-03-15T08:00:00.000Z</CreationDate>
    </Bucket>
  </Buckets>
</ListAllMyBucketsResult>
```

### CreateBucket

```
PUT /{bucket}
```

å¤„ç†ï¼š
1. åœ¨é¢„é…ç½®çš„ Supergroup (Forum) ä¸­åˆ›å»ºæ–°çš„ Topicï¼ˆé€šè¿‡ TG Bot API `createForumTopic`ï¼‰
2. INSERT INTO buckets (name, tg_chat_id, tg_topic_id, created_at)

å®žé™…å®žçŽ°ï¼šæ‰€æœ‰ Bucket å…±ç”¨åŒä¸€ä¸ª Supergroupï¼ˆçŽ¯å¢ƒå˜é‡ `DEFAULT_CHAT_ID`ï¼‰ï¼Œæ¯ä¸ª Bucket å¯¹åº”ä¸€ä¸ª Forum Topicï¼Œé€šè¿‡ `tg_topic_id` éš”ç¦»å­˜å‚¨ã€‚Bot éœ€è¦æœ‰è¯¥ Supergroup çš„ç®¡ç†å‘˜æƒé™ã€‚

## è®¤è¯

### AWS SigV4ï¼ˆS3 å®¢æˆ·ç«¯ï¼‰

æ ‡å‡† S3 ç­¾åéªŒè¯æµç¨‹ï¼Œæ”¯æŒå¤šå‡­è¯ï¼ˆD1 `credentials` è¡¨ç®¡ç†ï¼‰ï¼š
1. ä»Ž Authorization header æå– Credential, SignedHeaders, Signature
2. é€šè¿‡ Access Key ID æŸ¥è¯¢å¯¹åº”çš„ Secret Access Keyï¼ˆå¸¦ 60s å†…å­˜ç¼“å­˜ï¼‰
3. é‡å»º Canonical Request â†’ String to Sign
4. ç”¨ Secret Key æ´¾ç”Ÿ Signing Keyï¼ˆHMAC-SHA256ï¼‰
5. è®¡ç®—ç­¾åå¹¶æ¯”å¯¹

CPU å¼€é”€ï¼š1-3msï¼Œåœ¨å…è´¹è®¡åˆ’ 10ms CPU é™åˆ¶å†…å®Œå…¨å¯è¡Œã€‚

### TG WebApp initDataï¼ˆMini Appï¼‰

Telegram Mini App é€šè¿‡ WebApp initData è®¤è¯ï¼š
1. ä»Ž Authorization header æå– `tg <initData>`
2. æŒ‰ Telegram è§„èŒƒéªŒè¯ HMAC ç­¾å
3. éªŒè¯é€šè¿‡åŽæŽˆäºˆ **admin æƒé™**ï¼ˆç­‰åŒå…¨æƒå‡­è¯ï¼Œå«å‡­è¯ç®¡ç†å’Œ Bucket åˆ é™¤ï¼‰

> è®¾è®¡é€‰æ‹©: Mini App ç”¨æˆ·ç»Ÿä¸€èŽ·å¾— admin æƒé™ï¼Œå› ä¸º Stratum æ˜¯å•ç”¨æˆ·ç³»ç»Ÿï¼Œèƒ½æ‰“å¼€ Mini App çš„ç”¨æˆ·å³ä¸ºç³»ç»Ÿæ‰€æœ‰è€…ã€‚å¦‚æžœå°†æ¥éœ€è¦å¤šç”¨æˆ·æ”¯æŒï¼Œåº”å¼•å…¥ TG user_id ç™½åå•æœºåˆ¶ã€‚

### è®¤è¯æ¨¡å¼æ€»ç»“

- S3 å®¢æˆ·ç«¯ (rclone/aws cli): SigV4ï¼ˆå¤šå‡­è¯ï¼‰
- TG Mini App: TG WebApp initData
- é¢„ç­¾å URL: SigV4 Query String è®¤è¯
- å…¬å¼€åˆ†äº«é“¾æŽ¥: åˆ†äº« Token è®¤è¯

## æ˜Žç¡®ä¸å®žçŽ°çš„ S3 èƒ½åŠ›

### Versioningï¼ˆå¯¹è±¡ç‰ˆæœ¬æŽ§åˆ¶ï¼‰

**å†³å®š**: ä¸å®žçŽ°ã€‚æ°¸ä¹…æç½®ã€‚

**åŽŸå› **:

1. **å­˜å‚¨æˆæœ¬ä¸åŒ¹é…**: æ¯ä¸ªå¯¹è±¡ç‰ˆæœ¬éœ€è¦ä¸€æ¡ç‹¬ç«‹çš„ Telegram æ¶ˆæ¯ã€‚Telegram å­˜å‚¨å—æ¶ˆæ¯æ•°é‡é™åˆ¶ï¼Œç‰ˆæœ¬æŽ§åˆ¶ä¼šå¯¼è‡´å­˜å‚¨å¿«é€Ÿè†¨èƒ€ï¼Œä¸Ž S3 å¼¹æ€§å­˜å‚¨çš„å‰æå®Œå…¨ä¸åŒã€‚

2. **å®žçŽ°èŒƒå›´è¿‡å¤§**: ç‰ˆæœ¬æŽ§åˆ¶æ”¹å˜å‡ ä¹Žæ‰€æœ‰ S3 æ“ä½œçš„è¯­ä¹‰ã€‚DELETE ä¸å†çœŸæ­£åˆ é™¤è€Œæ˜¯åˆ›å»º"åˆ é™¤æ ‡è®°"ï¼ŒGET éœ€è¦è§£æžç‰ˆæœ¬é“¾ï¼Œè¿˜éœ€è¦æ–°å¢ž ListObjectVersions æ“ä½œã€‚å®žçŽ°æˆæœ¬ä¸Žä»·å€¼ä¸æˆæ¯”ä¾‹ã€‚

3. **ä½¿ç”¨åœºæ™¯ä¸åŒ¹é…**: Stratum çš„æ ¸å¿ƒåœºæ™¯æ˜¯ä¸ªäººç½‘ç›˜ã€‚éœ€è¦ç‰ˆæœ¬ä¿æŠ¤çš„ç”¨æˆ·ï¼Œé€šè¿‡å›žæ”¶ç«™/è½¯åˆ é™¤åŠŸèƒ½å³å¯æ»¡è¶³ï¼ˆè§„åˆ’ä¸­ï¼‰ï¼Œåªéœ€æžå°‘çš„å¤æ‚åº¦å°±èƒ½è¦†ç›–"è¯¯åˆ æ¢å¤"è¿™ä¸€æ ¸å¿ƒéœ€æ±‚ã€‚

4. **ç”Ÿæ€å…ˆä¾‹**: å¤šä¸ª S3 å…¼å®¹æœåŠ¡ï¼ˆCloudflare R2ã€Backblaze B2 ç­‰ï¼‰åŒæ ·æœªå®žçŽ°ç‰ˆæœ¬æŽ§åˆ¶ã€‚æ²¡æœ‰ä¸»æµ S3 å®¢æˆ·ç«¯è¦æ±‚æ­¤åŠŸèƒ½æ‰èƒ½æ­£å¸¸è¿è¡Œã€‚

**æ›¿ä»£æ–¹æ¡ˆ**: å›žæ”¶ç«™åŠŸèƒ½ï¼ˆè½¯åˆ é™¤ + å¯é…ç½®ä¿ç•™æœŸï¼‰ï¼Œè¦†ç›–ç”¨æˆ·æœ€æ ¸å¿ƒçš„"é˜²è¯¯åˆ "éœ€æ±‚ã€‚

### å…¶ä»–å¹³å°é™åˆ¶

ä»¥ä¸‹é™åˆ¶æºäºŽ Telegram å­˜å‚¨åŽç«¯ï¼š

- å•æ–‡ä»¶å¤§å°ä¸Šé™: 2GBï¼ˆLocal Bot APIï¼‰æˆ– 20MBï¼ˆæ ‡å‡† Bot APIï¼Œä¸Šä¼ ä¸Žä¸‹è½½å¯¹é½ï¼‰
- æ”¯æŒ SSE-Cï¼ˆå®¢æˆ·æä¾›å¯†é’¥ï¼‰å’Œ SSE-S3ï¼ˆæœåŠ¡ç«¯ç®¡ç†å¯†é’¥ï¼Œéœ€é…ç½® `SSE_MASTER_KEY`ï¼‰
- æ”¯æŒç”Ÿå‘½å‘¨æœŸè§„åˆ™ï¼ˆåŸºäºŽå‰ç¼€å’Œæ ‡ç­¾çš„å¯¹è±¡è¿‡æœŸï¼Œcron å®šæœŸæ‰§è¡Œï¼‰
- æ— å­˜å‚¨ç±»åˆ«: æ‰€æœ‰å¯¹è±¡ç­‰åŒäºŽ STANDARD
- æ— å¯¹è±¡é”å®š/ä¿ç•™: ä¸é€‚ç”¨äºŽ Telegram å­˜å‚¨
- æ—  Bucket Policy / ACL: å•ç”¨æˆ·ç³»ç»Ÿï¼Œä½¿ç”¨ Bearer Token æˆ– SigV4 è®¤è¯

## å“åº”æ ¼å¼

### é€šç”¨å“åº”å¤´ï¼ˆS3 å…¼å®¹æ€§ï¼‰

æ‰€æœ‰å“åº”è‡ªåŠ¨é™„åŠ ä»¥ä¸‹æ ‡å‡† S3 å¤´ï¼Œç¡®ä¿ AWS SDK å’Œ S3 å®¢æˆ·ç«¯å·¥å…·æ­£å¸¸å·¥ä½œï¼š

| Header | å€¼ | è¯´æ˜Ž |
|--------|---|------|
| `Date` | UTC æ—¶é—´ | AWS SDK ç”¨äºŽæ—¶é’Ÿåå·®æ£€æµ‹ |
| `x-amz-request-id` | 16 å­—ç¬¦éšæœº hex | è¯·æ±‚è¿½è¸ªæ ‡è¯† |
| `x-amz-id-2` | 32 å­—ç¬¦éšæœº hex | æ‰©å±•è¯·æ±‚æ ‡è¯† |
| `Server` | `AmazonS3` | éƒ¨åˆ† SDK/å·¥å…·æ£€æŸ¥æ­¤å¤´ |
| `Access-Control-Allow-Origin` | `*` | CORS æ”¯æŒ |
| `Access-Control-Expose-Headers` | ETag, Content-Range ç­‰ | æµè§ˆå™¨å¯è¯»å–çš„å“åº”å¤´åˆ—è¡¨ |

### 304 Not Modified å“åº”å¤´è§„èŒƒ

éµå¾ª RFC 7232 Â§4.1ï¼Œ304 å“åº”ä»…ä¿ç•™ç¼“å­˜ç›¸å…³å¤´éƒ¨ï¼Œå‰¥ç¦»è¡¨å¾å¤´éƒ¨ï¼š

- **ä¿ç•™**: ETag, Last-Modified, Cache-Control, Expires, Vary, x-amz-meta-*
- **å‰¥ç¦»**: Content-Type, Content-Length, Content-Encoding, Content-Language, Content-Disposition, Content-Range, Accept-Ranges

æ­¤è¡Œä¸ºä¸Ž AWS S3 ä¸€è‡´ã€‚

### é”™è¯¯å“åº”

æ‰€æœ‰é”™è¯¯è¿”å›ž S3 æ ‡å‡† XMLï¼š

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Error>
  <Code>NoSuchKey</Code>
  <Message>The specified key does not exist.</Message>
  <Key>nonexistent.txt</Key>
  <RequestId>A1B2C3D4E5F67890</RequestId>
</Error>
```

å¸¸ç”¨é”™è¯¯ç ï¼š

| HTTP | S3 Code | è§¦å‘æ¡ä»¶ |
|------|---------|---------|
| 400 | BadDigest | Content-MD5 æ ¡éªŒå¤±è´¥ |
| 400 | EntityTooLarge | æ–‡ä»¶è¶…å‡ºå¤§å°é™åˆ¶ |
| 400 | InvalidArgument | å‚æ•°æ— æ•ˆ (å¦‚ copy source æ ¼å¼é”™è¯¯) |
| 400 | InvalidPartNumber | partNumber è¶…å‡ºèŒƒå›´ |
| 400 | KeyTooLongError | Key è¶…è¿‡ 1024 å­—èŠ‚ (UTF-8) |
| 400 | MalformedXML | XML è¯·æ±‚ä½“è§£æžå¤±è´¥ |
| 400 | MissingContent | UploadPart body ä¸ºç©º |
| 400 | XAmzContentSHA256Mismatch | x-amz-content-sha256 æ ¡éªŒå¤±è´¥ |
| 403 | AccessDenied | è®¤è¯å¤±è´¥ |
| 404 | NoSuchBucket | Bucket ä¸å­˜åœ¨ |
| 404 | NoSuchKey | Key ä¸å­˜åœ¨ |
| 404 | NoSuchUpload | Multipart upload ID ä¸å­˜åœ¨ |
| 405 | MethodNotAllowed | ä¸æ”¯æŒçš„ HTTP æ–¹æ³• |
| 400 | InvalidBucketName | Bucket åç§°ä¸åˆæ³• |
| 400 | InvalidPartOrder | CompleteMultipartUpload ä¸­ Part åºå·æœªé€’å¢ž |
| 400 | InvalidPart | CompleteMultipartUpload ä¸­ Part ETag ä¸åŒ¹é… |
| 400 | EntityTooSmall | Part å¤§å°ä¸è¶³ (é™¤æœ€åŽä¸€ä¸ª Part) |
| 409 | BucketNotEmpty | åˆ é™¤éžç©º Bucket |
| 412 | PreconditionFailed | æ¡ä»¶è¯·æ±‚å¤±è´¥ (If-Match / If-None-Match: *) |
| 501 | NotImplemented | ä¸æ”¯æŒçš„ S3 å­èµ„æºæ“ä½œ (acl, tagging ç­‰) |
| 503 | SlowDown | è§¦å‘é€ŸçŽ‡é™åˆ¶ |
| 500 | InternalError | TG API å¤±è´¥ã€VPS åŽç«¯ä¸å¯ç”¨ç­‰ |
