# Stratum

**åŸºäºŽ Telegram çš„ S3 å…¼å®¹å­˜å‚¨ï¼Œè¿è¡Œåœ¨ Cloudflare Workers ä¸Š**

[English](README.md) | [ä¸­æ–‡](README.zh.md) | [æ—¥æœ¬èªž](README.ja.md) | [FranÃ§ais](README.fr.md)

---

Stratum å°† Telegram å˜æˆ S3 å…¼å®¹çš„å¯¹è±¡å­˜å‚¨åŽç«¯ã€‚æ–‡ä»¶ä½œä¸º Telegram æ¶ˆæ¯å­˜å‚¨ï¼Œå…ƒæ•°æ®ä¿å­˜åœ¨ Cloudflare D1 ä¸­ï¼Œæ•´ä¸ªç³»ç»Ÿè¿è¡Œåœ¨ Cloudflare Workers ä¸Šï¼Œé›¶è¿è¡Œæ—¶ä¾èµ–ã€‚

## åŠŸèƒ½ç‰¹æ€§

- **S3 å…¼å®¹ API** -- æ”¯æŒ 27 ç§æ“ä½œï¼ŒåŒ…æ‹¬åˆ†ç‰‡ä¸Šä¼ ã€é¢„ç­¾å URL å’Œæ¡ä»¶è¯·æ±‚
- **æ— é™å…è´¹å­˜å‚¨** -- Telegram æä¾›å…è´¹çš„å­˜å‚¨å±‚
- **ä¸‰çº§ç¼“å­˜** -- CF CDN (L1) -> R2 (L2) -> Telegram (L3)ï¼ŒåŠ é€Ÿè¯»å–
- **Telegram Bot** -- ç›´æŽ¥åœ¨ Telegram ä¸­ç®¡ç†æ–‡ä»¶ã€å­˜å‚¨æ¡¶å’Œåˆ†äº«
- **Mini App** -- Telegram å†…ç½®çš„å®Œæ•´ Web UIï¼Œæ”¯æŒæ–‡ä»¶æµè§ˆã€ä¸Šä¼ å’Œåˆ†äº«ç®¡ç†
- **æ–‡ä»¶åˆ†äº«** -- æ”¯æŒå¯†ç ä¿æŠ¤ã€è¿‡æœŸæ—¶é—´ã€ä¸‹è½½é™åˆ¶å’Œåœ¨çº¿é¢„è§ˆçš„åˆ†äº«é“¾æŽ¥
- **æœåŠ¡ç«¯åŠ å¯†** -- æ”¯æŒ SSE-Cï¼ˆå®¢æˆ·æä¾›å¯†é’¥ï¼‰å’Œ SSE-S3ï¼ˆæœåŠ¡ç«¯æ‰˜ç®¡å¯†é’¥ï¼‰ï¼Œé‡‡ç”¨ AES-256-GCM åŠ å¯†
- **å¤§æ–‡ä»¶æ”¯æŒ** -- é€šè¿‡å¯é€‰çš„ VPS ä»£ç†å’Œ Local Bot API æ”¯æŒæœ€å¤§ 2GB æ–‡ä»¶
- **åª’ä½“å¤„ç†** -- é€šè¿‡ VPS å®žçŽ°å›¾ç‰‡è½¬æ¢ (HEIC/WebP)ã€è§†é¢‘è½¬ç ã€Live Photo å¤„ç†
- **å¤šå‡­æ®è®¤è¯** -- åŸºäºŽ D1 çš„å‡­æ®ç®¡ç†ï¼Œæ”¯æŒæŒ‰å­˜å‚¨æ¡¶å’Œæ“ä½œè®¾ç½®æƒé™
- **Cloudflare Tunnel** -- å®‰å…¨è¿žæŽ¥ VPSï¼Œæ— éœ€æš´éœ²å…¬ç½‘ç«¯å£
- **å¤šè¯­è¨€** -- Mini App æ”¯æŒè‹±è¯­ã€ä¸­æ–‡ã€æ—¥è¯­å’Œæ³•è¯­
- **é›¶æˆæœ¬èµ·æ­¥** -- æ ¸å¿ƒåŠŸèƒ½å®Œå…¨è¿è¡Œåœ¨ Cloudflare å…è´¹å¥—é¤ä¸Š

## æž¶æž„

```
S3 å®¢æˆ·ç«¯ â”€â”€â”€â”€â”€â”€â”
                â”‚
Telegram Bot â”€â”€â”€â”¤
                â”œâ”€â”€â–¶ Cloudflare Worker â”€â”€â–¶ D1 (å…ƒæ•°æ®)
Mini App â”€â”€â”€â”€â”€â”€â”€â”¤         â”‚                R2 (ç¼“å­˜)
                â”‚         â”‚
åˆ†äº«é“¾æŽ¥ â”€â”€â”€â”€â”€â”€â”€â”˜         â–¼
                     Telegram API â—€â”€â”€â–¶ VPS ä»£ç† (å¯é€‰ï¼Œ>20MB)
```

**ç»„ä»¶ï¼š**

| ç»„ä»¶ | ä½œç”¨ | è´¹ç”¨ |
|------|------|------|
| CF Worker | S3 API ç½‘å…³ã€Bot Webhookã€Mini App æ‰˜ç®¡ | å…è´¹å¥—é¤ |
| CF D1 | å…ƒæ•°æ®å­˜å‚¨ï¼ˆå¯¹è±¡ã€å­˜å‚¨æ¡¶ã€åˆ†äº«ï¼‰ | å…è´¹å¥—é¤ |
| CF R2 | æŒä¹…ç¼“å­˜ï¼Œ<=20MB æ–‡ä»¶ | å…è´¹å¥—é¤ (10GB) |
| Telegram | æŒä¹…æ–‡ä»¶å­˜å‚¨ï¼ˆæ— é™å®¹é‡ï¼‰ | å…è´¹ |
| VPS + Processor | å¤§æ–‡ä»¶ (>20MB)ã€åª’ä½“å¤„ç† | çº¦ $4/æœˆï¼ˆå¯é€‰ï¼‰ |

## å¿«é€Ÿå¼€å§‹

### å‰ç½®æ¡ä»¶

- Node.js 22+
- ä¸€ä¸ª [Telegram Bot](https://t.me/BotFather) åŠå…¶ Token
- ä¸€ä¸ª Telegram ç¾¤ç»„/è¶…çº§ç¾¤ç»„ï¼ˆé€šè¿‡ [@userinfobot](https://t.me/userinfobot) èŽ·å– Chat IDï¼‰
- ä¸€ä¸ª [Cloudflare è´¦æˆ·](https://dash.cloudflare.com)

### ä¸€é”®éƒ¨ç½²

```bash
git clone https://github.com/DebadityaHait/stratum.git
cd stratum
cp .env.example .env
# ç¼–è¾‘ .env: å¡«å†™ TG_BOT_TOKENã€DEFAULT_CHAT_IDã€CLOUDFLARE_API_TOKEN
# å»ºè®®è®¾ç½® TG_ADMIN_IDS é™åˆ¶ Bot è®¿é—®æƒé™ï¼ˆé€—å·åˆ†éš”çš„ç”¨æˆ· IDï¼‰
./deploy.sh
```

`deploy.sh` è‡ªåŠ¨æ£€æµ‹è¿è¡ŒçŽ¯å¢ƒï¼šæœ‰ Docker æ—¶è‡ªåŠ¨æž„å»ºé•œåƒã€éƒ¨ç½² CF Workerã€é…ç½® Cloudflare Tunnel å¹¶å¯åŠ¨æ‰€æœ‰æœåŠ¡ï¼›æ—  Docker æ—¶ä½¿ç”¨æœ¬åœ° wrangler éƒ¨ç½²ã€‚S3 å‡­æ®å¯åœ¨ Telegram Mini App çš„ Keys æ ‡ç­¾é¡µä¸­åˆ›å»ºã€‚

### éªŒè¯

å°†ä»»æ„ S3 å®¢æˆ·ç«¯æŒ‡å‘ä½ çš„ Worker URLï¼š

```bash
# ä½¿ç”¨ AWS CLI
aws configure set aws_access_key_id YOUR_KEY
aws configure set aws_secret_access_key YOUR_SECRET
aws --endpoint-url https://your-worker.workers.dev s3 ls

# ä½¿ç”¨ rclone
rclone config create stratum s3 \
  provider=Other \
  access_key_id=YOUR_KEY \
  secret_access_key=YOUR_SECRET \
  endpoint=https://your-worker.workers.dev \
  acl=private
rclone ls stratum:default
```

## S3 å…¼å®¹æ€§

æ”¯æŒ 27 ç§æ“ä½œï¼Œæ¶µç›–å¯¹è±¡ CRUDã€åˆ†ç‰‡ä¸Šä¼ ã€å­˜å‚¨æ¡¶ç®¡ç†å’Œè®¤è¯ã€‚

| åˆ†ç±» | æ“ä½œ |
|------|------|
| å¯¹è±¡ | GetObject, PutObject, HeadObject, DeleteObject, DeleteObjects, CopyObject |
| æ ‡ç­¾ | GetObjectTagging, PutObjectTagging, DeleteObjectTagging |
| åˆ—ä¸¾ | ListObjectsV2, ListObjects (v1) |
| åˆ†ç‰‡ä¸Šä¼  | CreateMultipartUpload, UploadPart, UploadPartCopy, CompleteMultipartUpload, AbortMultipartUpload, ListParts, ListMultipartUploads |
| å­˜å‚¨æ¡¶ | ListBuckets, CreateBucket, DeleteBucket, HeadBucket, GetBucketLocation, GetBucketVersioning |
| ç”Ÿå‘½å‘¨æœŸ | GetBucketLifecycleConfiguration, PutBucketLifecycleConfiguration, DeleteBucketLifecycleConfiguration |
| è®¤è¯ | AWS SigV4ï¼ˆå¤šå‡­æ®ï¼‰ã€é¢„ç­¾å URLã€Bearer Tokenã€Telegram initData |

**ä¸æ”¯æŒï¼ˆè®¾è®¡å†³ç­–ï¼‰ï¼š** ç‰ˆæœ¬æŽ§åˆ¶ã€ACLã€è·¨åŒºåŸŸå¤åˆ¶ã€‚è¯¦è§ [docs/S3-COMPAT.md](docs/S3-COMPAT.md)ã€‚

## Telegram Bot å‘½ä»¤

| å‘½ä»¤ | è¯´æ˜Ž |
|------|------|
| `/start` | æ¬¢è¿Žæ¶ˆæ¯ |
| `/help` | å‘½ä»¤å¸®åŠ© |
| `/buckets` | åˆ—å‡ºæ‰€æœ‰å­˜å‚¨æ¡¶ |
| `/ls <bucket> [prefix]` | åˆ—å‡ºå¯¹è±¡ |
| `/info <bucket> <key>` | å¯¹è±¡è¯¦æƒ… |
| `/search <bucket> <query>` | æœç´¢å¯¹è±¡ |
| `/share <bucket> <key>` | åˆ›å»ºåˆ†äº«é“¾æŽ¥ |
| `/shares` | åˆ—å‡ºæ´»è·ƒçš„åˆ†äº« |
| `/revoke <token>` | æ’¤é”€åˆ†äº« |
| `/delete <bucket> <key>` | åˆ é™¤å¯¹è±¡ï¼ˆéœ€ç¡®è®¤ï¼‰ |
| `/stats` | å­˜å‚¨ç»Ÿè®¡ |
| `/setbucket <name>` | è®¾ç½®é»˜è®¤å­˜å‚¨æ¡¶ |
| `/miniapp` | æ‰“å¼€ Mini App |

ç›´æŽ¥å‘é€æ–‡ä»¶ç»™ Bot å³å¯ä¸Šä¼ åˆ°é»˜è®¤å­˜å‚¨æ¡¶ã€‚

## æ–‡æ¡£

- [éƒ¨ç½²æŒ‡å—](docs/deployment.zh.md)
- [é…ç½®å‚è€ƒ](docs/configuration.zh.md)
- [Bot å‘½ä»¤](docs/bot-commands.zh.md)
- [S3 å…¼å®¹æ€§](docs/S3-COMPAT.md)
- [æž¶æž„è®¾è®¡](docs/design/00-overview.md)

## æŠ€æœ¯æ ˆ

- **è¿è¡Œæ—¶ï¼š** Cloudflare Workersï¼ˆé›¶è¿è¡Œæ—¶ä¾èµ–ï¼‰
- **æ•°æ®åº“ï¼š** Cloudflare D1 (SQLite)
- **ç¼“å­˜ï¼š** Cloudflare R2 + CF Cache API
- **è®¤è¯ï¼š** AWS SigV4ã€é¢„ç­¾å URLã€Bearer Token
- **è¯­è¨€ï¼š** TypeScriptï¼ˆä¸¥æ ¼æ¨¡å¼ï¼‰
- **åª’ä½“å¤„ç†ï¼š** Sharp + FFmpegï¼ˆä»… VPSï¼‰
- **æž„å»ºï¼š** wrangler v3

## è®¸å¯è¯

MIT
