# éƒ¨ç½²æž¶æž„ä¸Žå®žçŽ°è·¯çº¿

## ä¸€ã€éƒ¨ç½²æ‹“æ‰‘

### æœ€å°éƒ¨ç½²ï¼ˆ$0/æœˆï¼ŒTier 1 åŠŸèƒ½ï¼‰

```
æ‰€éœ€èµ„æº:
  - Cloudflare å…è´¹è´¦æˆ·
  - ä¸€ä¸ªåŸŸåï¼ˆæ‰˜ç®¡åœ¨ CFï¼‰
  - Telegram Bot Token
  - ä¸€ä¸ª TG ç§æœ‰é¢‘é“/ç¾¤ç»„ï¼ˆBot ä¸ºç®¡ç†å‘˜ï¼‰

éƒ¨ç½²æ–¹å¼: ./deploy.sh (ä¸€é”®è‡ªåŠ¨åŒ–, è‡ªåŠ¨æ£€æµ‹çŽ¯å¢ƒ)
  è‡ªåŠ¨å®Œæˆ: D1 åˆ›å»º + R2 Bucket åˆ›å»º + Schema åˆå§‹åŒ– + Secrets é…ç½® + Worker éƒ¨ç½²

éƒ¨ç½²å†…å®¹:
  - 1x CF Worker: S3 API Gateway + Cron å®šæ—¶ä»»åŠ¡
  - 1x CF D1 Database: stratum-db å…ƒæ•°æ®
  - 1x CF R2 Bucket: stratum-cache æŒä¹…ç¼“å­˜
  - Telegram Mini App (å†…ç½®äºŽ Worker)

èƒ½åŠ›:
  - S3 åŸºç¡€ CRUD + List + Multipart
  - æ–‡ä»¶ <=20MB (ä¸Šä¼ ä¸Žä¸‹è½½å¯¹é½ï¼Œç¡®ä¿ä¸Šä¼ çš„æ–‡ä»¶å¯é€šè¿‡ Bot API ä¸‹è½½)
  - ä¸‰å±‚ç¼“å­˜: CDN + R2 + TG
  - å›¾åºŠç›´é“¾ + å›¾ç‰‡å˜ä½“ (?w=, ?fmt= éœ€ VPS)
  - æ–‡ä»¶åˆ†äº« (æ—¶æ•ˆ/å£ä»¤/ä¸‹è½½é™åˆ¶)
  - SigV4 + Presigned URL + Telegram initData è®¤è¯
  - Telegram Bot ç®¡ç† (13 å‘½ä»¤å« /start + æ–‡ä»¶ä¸Šä¼  + åˆ é™¤ç¡®è®¤)
  - Mini App æ–‡ä»¶ç®¡ç†å™¨
```

### æ ‡å‡†éƒ¨ç½²ï¼ˆ$4/æœˆï¼Œå…¨åŠŸèƒ½ï¼‰

```
æ‰€éœ€èµ„æº:
  - ä¸Šè¿°æ‰€æœ‰ +
  - 1x VPS (Hetzner CAX11 ARM, 2C4G, ~$4/æœˆ)

éƒ¨ç½²æ–¹å¼: ./deploy.sh (ä¸€é”®è‡ªåŠ¨åŒ– CF + VPS, è‡ªåŠ¨æ£€æµ‹ Docker)
  Docker æ¨¡å¼: æž„å»ºé•œåƒ + éƒ¨ç½² Worker + é…ç½® Tunnel + å¯åŠ¨æœåŠ¡

VPS ä¸Šè¿è¡Œ:
  - Local Telegram Bot API Server (Docker)
  - åª’ä½“å¤„ç†æœåŠ¡ (Node.js: sharp + ffmpeg)
  - HTTP API (ä¾› Worker è°ƒç”¨)

é¢å¤–èƒ½åŠ›:
  - æ–‡ä»¶ <=2GB
  - æ–‡ä»¶åˆ†å— (>2GB) [Phase 2]
  - HTTP Range è¯·æ±‚ (å¤§æ–‡ä»¶ seek)
  - HEIC/HEIF è½¬æ¢
  - å®žå†µç…§ç‰‡æ”¯æŒ
  - è§†é¢‘è½¬ç 
  - å›¾ç‰‡å˜ä½“ (?w=, ?fmt=)
  - ç¼©ç•¥å›¾è‡ªåŠ¨ç”Ÿæˆ
```

### å¢žå¼ºéƒ¨ç½²ï¼ˆ$5-9/æœˆï¼Œæœ€ä½³æ€§èƒ½ï¼‰

```
æ‰€éœ€èµ„æº:
  - ä¸Šè¿°æ‰€æœ‰ +
  - CF Workers ä»˜è´¹è®¡åˆ’ ($5/æœˆ)

é¢å¤–èƒ½åŠ›:
  - 30s CPU æ—¶é—´ (å¤æ‚è¯·æ±‚æ›´å®½è£•)
  - å¯é€‰: Workers WASM å›¾ç‰‡å¤„ç† (wasm-vips, è½»é‡ä»»åŠ¡ä¸èµ° VPS)
  - æ— é™è¯·æ±‚æ•°
```

## äºŒã€VPS éƒ¨ç½²è¯¦æƒ…

### ä¸€é”®éƒ¨ç½²

æ‰€æœ‰éƒ¨ç½²æ“ä½œé€šè¿‡ `./deploy.sh` ä¸€æ¡å‘½ä»¤å®Œæˆï¼Œè„šæœ¬è‡ªåŠ¨æ£€æµ‹è¿è¡ŒçŽ¯å¢ƒ:

| çŽ¯å¢ƒ | è¡Œä¸º |
|------|------|
| å®¿ä¸»æœº + Docker | æž„å»ºé•œåƒ + éƒ¨ç½² CF Worker + é…ç½® Tunnel + å¯åŠ¨æœåŠ¡ |
| å®¿ä¸»æœº + æ—  Docker | ä½¿ç”¨æœ¬åœ° wrangler éƒ¨ç½² CF Worker |
| Docker å®¹å™¨å†… | ä»…éƒ¨ç½² CF Worker (ç”±å®¿ä¸»æœºç¼–æŽ’è°ƒç”¨) |

```bash
# é¦–æ¬¡éƒ¨ç½² (ä¸€æ¡å‘½ä»¤)
cp .env.example .env
vim .env     # å¡«å†™ TG_BOT_TOKEN, DEFAULT_CHAT_ID, CLOUDFLARE_API_TOKEN
./deploy.sh

# æ›´æ–°ä»£ç åŽé‡æ–°éƒ¨ç½² (ä¸€æ¡å‘½ä»¤)
git pull && ./deploy.sh

# ä»…é‡å¯æœåŠ¡ (ä¸é‡æ–°éƒ¨ç½² Worker)
docker compose --profile tunnel restart

# åœæ­¢æ‰€æœ‰æœåŠ¡
docker compose --profile tunnel down

# æŸ¥çœ‹æ—¥å¿—
docker compose --profile tunnel logs -f
```

### Docker Compose æž¶æž„

```yaml
services:
  # CF Worker éƒ¨ç½²æœåŠ¡ (ä¸€æ¬¡æ€§, ç”± ./deploy.sh ç¼–æŽ’è°ƒç”¨)
  # profiles: [deploy] -- ä¸ä¼šéš docker compose up è‡ªåŠ¨å¯åŠ¨
  deploy:
    build:
      context: .
      dockerfile: Dockerfile.deploy
    env_file: .env
    volumes:
      - ./.env:/app/.env    # æŒ‚è½½ .env, å®¹å™¨å†…ä¿®æ”¹å¯æŒä¹…åŒ–
    environment:
      - CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN:-}
      - CF_ACCOUNT_ID=${CF_ACCOUNT_ID:-}
    restart: "no"
    profiles: [deploy]

  # Telegram Local Bot API: è§£é™¤æ–‡ä»¶å¤§å°é™åˆ¶ (20MB -> 2GB)
  telegram-bot-api:
    image: aiogram/telegram-bot-api:latest
    restart: unless-stopped
    environment:
      - TELEGRAM_API_ID=${TELEGRAM_API_ID}
      - TELEGRAM_API_HASH=${TELEGRAM_API_HASH}
      - TELEGRAM_LOCAL=1
    volumes:
      - tg-bot-api-data:/var/lib/telegram-bot-api
    profiles: [localapi]

  # åª’ä½“å¤„ç† + å¤§æ–‡ä»¶ä»£ç†æœåŠ¡ (å¸¸é©»)
  # Tunnel é€šè¿‡ Docker å†…éƒ¨ç½‘ç»œè®¿é—®, æ— éœ€æš´éœ²å®¿ä¸»æœºç«¯å£
  processor:
    build: ./processor
    restart: unless-stopped
    environment:
      - PORT=3000
      - TG_BOT_TOKEN=${TG_BOT_TOKEN}
      - AUTH_SECRET=${VPS_SECRET}
      - TG_LOCAL_API=${TG_LOCAL_API:-https://api.telegram.org}
      - DEFAULT_CHAT_ID=${DEFAULT_CHAT_ID}
      - TEMP_DIR=/tmp/stratum
    volumes:
      - processor-data:/tmp/stratum

  # Cloudflare Tunnel (profiles: [tunnel])
  tunnel:
    image: cloudflare/cloudflared:latest
    restart: unless-stopped
    command: tunnel run
    environment:
      - TUNNEL_TOKEN=${CF_TUNNEL_TOKEN}
    depends_on: [processor]
    profiles: [tunnel]

volumes:
  processor-data:
  tg-bot-api-data:
```

### deploy.sh ç¼–æŽ’æµç¨‹ (Docker æ¨¡å¼)

```
./deploy.sh
  1. åŠ è½½ .env, æ ¡éªŒå¿…å¡«é¡¹, è‡ªåŠ¨ç”Ÿæˆ VPS_SECRET
  2. æ£€æµ‹åˆ° Docker -> è¿›å…¥ Docker ç¼–æŽ’æ¨¡å¼
  3. é€ä¸ªæž„å»ºé•œåƒ (é¿å… BuildKit å¹¶è¡Œæž„å»º bug)
     docker compose build deploy
     docker compose build processor
  4. è¿è¡Œ deploy å®¹å™¨ (éƒ¨ç½² CF Worker + é…ç½® Tunnel)
     docker compose --profile deploy run --rm -T deploy
     å®¹å™¨å†…: deploy_cf() + setup_tunnel()
     .env ä»¥ volume æŒ‚è½½, CF_TUNNEL_TOKEN ç­‰è‡ªåŠ¨æŒä¹…åŒ–
  5. é‡æ–°åŠ è½½ .env, å¯åŠ¨å¸¸é©»æœåŠ¡
     docker compose --profile tunnel up -d
  6. å¥åº·æ£€æŸ¥ + æ‰“å°æ‘˜è¦
```

### Caddyfile

```
vps.stratum.example.com {
    reverse_proxy stratum-processor:3000

    header {
        Strict-Transport-Security "max-age=31536000"
    }

    # ä»…å…è®¸æ¥è‡ª CF Worker çš„è¯·æ±‚
    @not-cf {
        not remote_ip 173.245.48.0/20 103.21.244.0/22 103.22.200.0/22
        # ... å®Œæ•´ CF IP åˆ—è¡¨
    }
    respond @not-cf 403
}
```

### å¤„ç†æœåŠ¡ Dockerfile

```dockerfile
FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./

ENV PORT=3000
EXPOSE 3000
CMD ["node", "server.js"]
```

### VPS å®‰å…¨

| æŽªæ–½ | è¯´æ˜Ž |
|------|------|
| IP ç™½åå• | åªæŽ¥å— CF Worker IP æ®µçš„è¯·æ±‚ |
| å…±äº«å¯†é’¥ | Worker è¯·æ±‚æºå¸¦ `Authorization: Bearer ${VPS_SECRET}`ï¼ŒVPS éªŒè¯ |
| HTTPS | Caddy è‡ªåŠ¨ Let's Encrypt |
| é˜²ç«å¢™ | åªå¼€æ”¾ 443ï¼Œå…³é—­ SSH å¯†ç ç™»å½• |
| Docker ç½‘ç»œéš”ç¦» | æœåŠ¡é—´é€šè¿‡ Docker å†…éƒ¨ç½‘ç»œé€šä¿¡ |

## ä¸‰ã€CF Worker éƒ¨ç½²

### wrangler.toml

```toml
name = "Stratum"
main = "src/index.ts"
compatibility_date = "2026-03-15"

[vars]
S3_REGION = "us-east-1"

# Secrets (é€šè¿‡ wrangler secret put è®¾ç½®ï¼Œä¸å†™å…¥ toml):
# TG_BOT_TOKEN, DEFAULT_CHAT_ID, VPS_URL (å¯é€‰), VPS_SECRET (å¯é€‰)
# S3 å‡­æ®å­˜å‚¨åœ¨ D1 credentials è¡¨ä¸­ï¼ŒWebhook å¯†é’¥ç”± TG_BOT_TOKEN æ´¾ç”Ÿ

[[d1_databases]]
binding = "DB"
database_name = "stratum-db"
database_id = ""

[[r2_buckets]]
binding = "CACHE"
bucket_name = "stratum-cache"

[triggers]
crons = ["0 */6 * * *"]  # æ¯ 6 å°æ—¶: 8 é¡¹æ¸…ç† (è¿‡æœŸ/å­¤å„¿åˆ†äº«, è¿‡æœŸ multipart, D1-TG ä¸€è‡´æ€§, R2 ç¼“å­˜, å¯†ç é”å®š, å­¤å„¿åˆ†å—, ç”Ÿå‘½å‘¨æœŸè¿‡æœŸ)
```

### Worker é¡¹ç›®ç»“æž„

```
src/
â”œâ”€â”€ index.ts                 # å…¥å£: è¯·æ±‚è·¯ç”± + Cron handler + Mini App API
â”œâ”€â”€ types.ts                 # ç±»åž‹å®šä¹‰: Env, ObjectRow, S3Request, TG types ç­‰
â”œâ”€â”€ constants.ts             # å¸¸é‡: TG API é™åˆ¶, S3 é™åˆ¶, è¶…æ—¶å‚æ•°
â”œâ”€â”€ auth/
â”‚   â”œâ”€â”€ sigv4.ts            # AWS SigV4 éªŒè¯
â”‚   â”œâ”€â”€ bearer.ts           # Bearer Token éªŒè¯
â”‚   â””â”€â”€ presigned.ts        # é¢„ç­¾å URL ç”Ÿæˆ/éªŒè¯
â”œâ”€â”€ handlers/
â”‚   â”œâ”€â”€ get-object.ts       # GetObject + ä¸‰å±‚ç¼“å­˜ + R2 ç®¡ç† + å›¾ç‰‡å˜ä½“
â”‚   â”œâ”€â”€ put-object.ts       # PutObject + è¦†ç›–å†™ + ç¼“å­˜æ¸…é™¤
â”‚   â”œâ”€â”€ delete-object.ts    # DeleteObject + DeleteObjects æ‰¹é‡åˆ é™¤ + ç¼“å­˜æ¸…é™¤
â”‚   â”œâ”€â”€ head-object.ts
â”‚   â”œâ”€â”€ list-objects.ts     # ListObjectsV2 + ListObjects (v1)
â”‚   â”œâ”€â”€ copy-object.ts      # CopyObject + ç¼“å­˜æ¸…é™¤
â”‚   â”œâ”€â”€ multipart.ts        # Multipart Upload å…¨éƒ¨æ“ä½œ (å« UploadPartCopy)
â”‚   â”œâ”€â”€ bucket.ts           # Bucket CRUD + GetBucketLocation + GetBucketVersioning
â”‚   â””â”€â”€ share.ts            # åˆ†äº« CRUD API + å…¬å¼€åˆ†äº«è®¿é—®
â”œâ”€â”€ telegram/
â”‚   â”œâ”€â”€ client.ts           # TG Bot API å°è£…
â”‚   â”œâ”€â”€ upload.ts           # ä¸Šä¼ é€»è¾‘ (ç›´ä¼  + VPS ä»£ç†)
â”‚   â””â”€â”€ download.ts         # ä¸‹è½½é€»è¾‘ (ç›´å–å°è£…, VPS ä»£ç†åœ¨ handlers å±‚)
â”œâ”€â”€ storage/
â”‚   â”œâ”€â”€ metadata.ts         # D1 æ“ä½œå°è£…
â”‚   â””â”€â”€ schema.sql          # å»ºè¡¨ SQL (å« migration æ³¨é‡Š)
â”œâ”€â”€ rate-limit/
â”‚   â””â”€â”€ limiter.ts          # ä»¤ç‰Œæ¡¶é™é€Ÿå™¨ (å†…å­˜å®žçŽ°)
â”œâ”€â”€ bot/
â”‚   â”œâ”€â”€ webhook.ts          # TG Bot webhook + Callback Query + æ–‡ä»¶ä¸Šä¼  + setMyCommands
â”‚   â”œâ”€â”€ commands.ts         # Bot å‘½ä»¤å®žçŽ° (13 ä¸ªå‘½ä»¤å« /start)
â”‚   â””â”€â”€ miniapp.ts          # Telegram Mini App (å†…è” HTML/CSS/JS)
â”œâ”€â”€ sharing/
â”‚   â”œâ”€â”€ tokens.ts           # Token ç”Ÿæˆ/éªŒè¯ (PBKDF2)
â”‚   â””â”€â”€ pages.ts            # HTML åˆ†äº«é¡µé¢æ¸²æŸ“ (æš—è‰²æ¨¡å¼, å€’è®¡æ—¶, å¤šæ ¼å¼é¢„è§ˆ)
â”œâ”€â”€ media/
â”‚   â””â”€â”€ vps-client.ts       # VPS åª’ä½“å¤„ç†å®¢æˆ·ç«¯
â”œâ”€â”€ xml/
â”‚   â”œâ”€â”€ builder.ts          # S3 XML å“åº”æž„å»ºå™¨
â”‚   â””â”€â”€ parser.ts           # S3 XML è¯·æ±‚è§£æžå™¨
â””â”€â”€ utils/
    â”œâ”€â”€ crypto.ts           # SHA256, HMAC, PBKDF2
    â”œâ”€â”€ sse.ts              # SSE-C / SSE-S3 åŠ å¯†å·¥å…· (AES-256-GCM via Web Crypto)
    â”œâ”€â”€ path.ts             # S3 è·¯å¾„è§£æž
    â”œâ”€â”€ headers.ts          # S3 headers/Range/ETag å¤„ç†
    â””â”€â”€ format.ts           # å…±äº«æ ¼å¼åŒ–å·¥å…· (formatSize, escHtml)
```

## å››ã€Telegram Bot ç®¡ç†ç•Œé¢

### Bot å‘½ä»¤è®¾è®¡

```
/start               - æ¬¢è¿Žä»‹ç» + å¿«é€Ÿä¸Šæ‰‹å¼•å¯¼ (TG å†…å»ºï¼Œä¸è®¡å…¥ setMyCommands)
/help                - å®Œæ•´å‘½ä»¤åˆ—è¡¨
/buckets             - åˆ—å‡ºæ‰€æœ‰ Buckets
/ls <bucket> [prefix] [é¡µç ] - åˆ—å‡ºæ–‡ä»¶ (æ”¯æŒåˆ†é¡µï¼Œæ¯é¡µ 20 æ¡)
/info <bucket> <key> - æ–‡ä»¶è¯¦æƒ…
/delete <bucket> <key> - åˆ é™¤æ–‡ä»¶
/search <bucket> <keyword> - æœç´¢æ–‡ä»¶å
/share <bucket> <key> [ç§’æ•°] [å£ä»¤] [æœ€å¤§æ¬¡æ•°] - ç”Ÿæˆåˆ†äº«é“¾æŽ¥
/shares [bucket]     - åˆ—å‡ºåˆ†äº«
/revoke <token>      - æ’¤é”€åˆ†äº«
/stats               - å­˜å‚¨ç»Ÿè®¡
/setbucket [name]    - è®¾ç½®é»˜è®¤ä¸Šä¼  Bucket (æ— å‚æ•°æ—¶æ˜¾ç¤ºå½“å‰è®¾ç½®å’Œå¯ç”¨åˆ—è¡¨)
/miniapp             - æ‰“å¼€ç½‘ç›˜ç®¡ç† Mini App (å‘é€ web_app æŒ‰é’®ï¼Œç‚¹å‡»å³å¯å†…è”æ‰“å¼€)
ç›´æŽ¥å‘é€æ–‡ä»¶            - è‡ªåŠ¨ä¸Šä¼ åˆ°é»˜è®¤ Bucket (å¯é€šè¿‡ /setbucket è®¾ç½®)
```

> **å¤šè¯­è¨€æ”¯æŒ**: Bot æ‰€æœ‰æ¶ˆæ¯æ”¯æŒ EN/ZH/JA/FR å››ç§è¯­è¨€ï¼ŒåŸºäºŽç”¨æˆ· Telegram å®¢æˆ·ç«¯è¯­è¨€è‡ªåŠ¨æ£€æµ‹
> (`from.language_code`)ã€‚å‘½ä»¤æè¿°é€šè¿‡ `setMyCommands` æŒ‰è¯­è¨€æ³¨å†Œï¼Œä¸æ”¯æŒçš„è¯­è¨€å›žé€€åˆ°è‹±æ–‡ã€‚

### Bot äº¤äº’æµç¨‹

```
ç”¨æˆ·ç›´æŽ¥å‘é€æ–‡ä»¶ç»™ Bot:
  1. Bot æ”¶åˆ°æ–‡ä»¶ (é€šè¿‡ webhook)
  2. è‡ªåŠ¨è¯†åˆ«æ–‡ä»¶ç±»åž‹ (document/photo/video/audio)
  3. è®°å½• file_id åˆ°é»˜è®¤ Bucket çš„ D1 å…ƒæ•°æ®
  4. è¿”å›žä¸Šä¼ ç¡®è®¤ (bucketåã€æ–‡ä»¶åã€å¤§å°)
  æ³¨: æ–‡ä»¶åå†²çªæ—¶è‡ªåŠ¨åŠ æ—¶é—´æˆ³åŽç¼€

ç”¨æˆ·å‘é€ /share docs report.pdf 86400 mypass:
  1. è§£æžå‚æ•°: bucket=docs, key=report.pdf, expires=86400ç§’, password=mypass
  2. ç”Ÿæˆåˆ†äº« Token (PBKDF2 å“ˆå¸Œå£ä»¤)
  3. è¿”å›žåˆ†äº« Token å’Œé“¾æŽ¥
```

### Webhook å¤„ç†

Worker åŒæ—¶å¤„ç† S3 API å’Œ TG Bot Webhookï¼š

```typescript
// è·¯ç”±åŒºåˆ† (secret_token éªŒè¯ webhook åˆæ³•æ€§ï¼Œæ—¶åºå®‰å…¨æ¯”è¾ƒ)
if (path === '/bot/webhook' && request.method === 'POST') {
  const secret = request.headers.get('X-Telegram-Bot-Api-Secret-Token') || '';
  if (!timingSafeEqual(secret, await deriveWebhookSecret(env.TG_BOT_TOKEN))) return new Response('Unauthorized', { status: 401 });
  return handleWebhook(request, env);
}
// Mini App
if (path === '/miniapp') return renderMiniApp(url.origin);
// åˆ†äº«è®¿é—® (æ— éœ€è®¤è¯)
if (path.startsWith('/share/')) return handleShareAccess(request, url, env);
// å…¶ä½™èµ° S3 è·¯ç”± (éœ€è®¤è¯)
```

## äº”ã€Web UI æ–‡ä»¶ç®¡ç†å™¨ (Telegram Mini App)

> å®žé™…å®žçŽ°ä¸º Telegram Mini Appï¼Œå–ä»£äº†åŽŸè®¾è®¡çš„ CF Pages ç‹¬ç«‹åº”ç”¨ã€‚
> HTML/CSS/JS å†…è”åœ¨ Worker ä¸­ï¼Œé€šè¿‡ `/miniapp` è·¯ç”±æä¾›ã€‚

### æŠ€æœ¯æ ˆ

- çº¯ HTML/CSS/JS (æ— æ¡†æž¶ä¾èµ–ï¼Œ~1600 è¡Œå†…è”ä»£ç )
- Telegram WebApp JS SDK (ä¸»é¢˜è‰²é€‚é…)
- éƒ¨ç½²: Worker å†…è”æä¾› (æ— éœ€ CF Pages)
- API: è°ƒç”¨ `/api/miniapp/*` ç®¡ç† API (ä¸Šä¼ /ä¸‹è½½/é¢„è§ˆå‡é€šè¿‡å†…éƒ¨ç«¯ç‚¹ï¼Œæ— éœ€ S3 å‡­æ®)

### Mini App API ç«¯ç‚¹

| æ–¹æ³• | è·¯å¾„ | è¯´æ˜Ž |
|------|------|------|
| GET | `/api/miniapp/buckets` | åˆ—å‡ºæ‰€æœ‰ Bucket |
| POST | `/api/miniapp/bucket` | åˆ›å»º Bucket (body: `{name}`) |
| GET | `/api/miniapp/objects?bucket=&prefix=&delimiter=&maxKeys=&startAfter=` | åˆ—å‡ºæ–‡ä»¶ |
| GET | `/api/miniapp/object?bucket=&key=` | èŽ·å–æ–‡ä»¶å…ƒæ•°æ® |
| DELETE | `/api/miniapp/object?bucket=&key=` | åˆ é™¤æ–‡ä»¶ |
| GET | `/api/miniapp/search?bucket=&q=` | æœç´¢æ–‡ä»¶ (æœåŠ¡ç«¯ LIKE æŸ¥è¯¢) |
| POST | `/api/miniapp/share` | åˆ›å»ºåˆ†äº« (body: `{bucket, key, expiresIn?, password?, maxDownloads?}`) |
| GET | `/api/miniapp/shares?bucket=` | åˆ—å‡ºåˆ†äº« |
| DELETE | `/api/miniapp/share?token=` | æ’¤é”€åˆ†äº« |
| GET | `/api/miniapp/stats` | å…¨å±€ç»Ÿè®¡ |
| POST | `/api/miniapp/rename` | é‡å‘½å/ç§»åŠ¨æ–‡ä»¶ (body: `{bucket, oldKey, newKey}`) |
| PUT | `/api/miniapp/upload?bucket=&key=` | ç›´æŽ¥ä¸Šä¼ æ–‡ä»¶ (body ä¸ºæ–‡ä»¶å†…å®¹ï¼Œå†…éƒ¨è°ƒç”¨ PutObject) |
| GET | `/api/miniapp/download?bucket=&key=` | ç›´æŽ¥ä¸‹è½½æ–‡ä»¶ (å†…éƒ¨è°ƒç”¨ GetObjectï¼Œæ”¯æŒ `?auth=` æŸ¥è¯¢å‚æ•°è®¤è¯) |
| POST | `/api/miniapp/presign` | ç”Ÿæˆé¢„ç­¾å URLï¼Œä»…ç”¨äºŽ"å¤åˆ¶é¢„ç­¾åé“¾æŽ¥"åŠŸèƒ½ (body: `{bucket, key, method?, expiresIn?}`) |
| GET | `/api/miniapp/credentials` | åˆ—å‡ºå‡­è¯ (secret_access_key è„±æ•) |
| POST | `/api/miniapp/credential` | åˆ›å»ºå‡­è¯ (body: `{buckets?, permission?}`) |
| PATCH | `/api/miniapp/credential?accessKeyId=` | æ›´æ–°å‡­è¯ (body: `{name?, buckets?, permission?, is_active?}`) |
| DELETE | `/api/miniapp/credential?accessKeyId=` | åˆ é™¤å‡­è¯ |

æ‰€æœ‰ç«¯ç‚¹éœ€è®¤è¯ï¼ˆTelegram WebApp initDataï¼‰ã€‚è®¤è¯æ–¹å¼:
- `Authorization: Bearer <initData>` è¯·æ±‚å¤´ (JS fetch è°ƒç”¨)
- `?auth=<initData>` æŸ¥è¯¢å‚æ•° (æµè§ˆå™¨ç›´æŽ¥è®¿é—®çš„ URLï¼Œå¦‚ `img.src`ã€`window.open`)

### æ ¸å¿ƒåŠŸèƒ½

| åŠŸèƒ½ | è¯´æ˜Ž |
|------|------|
| Bucket åˆ—è¡¨ | æ˜¾ç¤ºæ‰€æœ‰ Bucket åŠç»Ÿè®¡ä¿¡æ¯ |
| æ–‡ä»¶æµè§ˆ | é¢åŒ…å±‘å¯¼èˆªï¼Œdelimiter åˆ†ç»„ï¼Œåˆ†é¡µåŠ è½½ |
| æ‹–æ‹½ä¸Šä¼  | å¤šæ–‡ä»¶æ‹–æ‹½ï¼Œé€šè¿‡ `/api/miniapp/upload` ç›´æŽ¥ä¸Šä¼  |
| å›¾ç‰‡é¢„è§ˆ | ç¼©ç•¥å›¾å†…è”æ˜¾ç¤º |
| æ‰¹é‡æ“ä½œ | å¤šé€‰åˆ é™¤ã€å¤šé€‰åˆ†äº«ï¼ˆåˆ†äº«æš‚é™é€ä¸ªï¼‰ |
| æœç´¢ | æ–‡ä»¶åæ¨¡ç³Šæœç´¢ (æœåŠ¡ç«¯ D1 LIKE æŸ¥è¯¢) |
| æŽ’åº | 6 ç§æŽ’åºæ¨¡å¼ï¼ˆåç§°ã€å¤§å°ã€æ—¶é—´ï¼Œå„å‡é™åºï¼‰ |
| åˆ†äº«ç®¡ç† | åˆ›å»º/æŸ¥çœ‹/æ’¤é”€åˆ†äº«é“¾æŽ¥ï¼Œæ”¯æŒå£ä»¤å’Œæœ‰æ•ˆæœŸ |
| æ–‡ä»¶æ“ä½œ | é‡å‘½å/ç§»åŠ¨ (CopyObject + Delete)ï¼Œæ–‡ä»¶è¯¦æƒ… |
| TG ä¸»é¢˜é€‚é… | è‡ªåŠ¨è·Ÿéš Telegram æš—è‰²/äº®è‰²æ¨¡å¼ |

## å…­ã€å®žçŽ°è·¯çº¿å›¾

### Phase 1: S3 åŸºç¡€ API (MVP) [å·²å®žçŽ°]

**ç›®æ ‡**: rclone èƒ½æ­£å¸¸è¿žæŽ¥ï¼Œå®ŒæˆåŸºæœ¬å¢žåˆ æŸ¥æ“ä½œ

```
äº¤ä»˜ç‰©:
  - CF Worker é¡¹ç›®éª¨æž¶
  - Telegram initData è®¤è¯
  - PutObject / GetObject / HeadObject / DeleteObject
  - ListObjectsV2 (prefix + delimiter)
  - HeadBucket / ListBuckets
  - D1 schema + åŸºç¡€ CRUD
  - TG Bot API é›†æˆ (sendDocument / getFile)
  - é€ŸçŽ‡é™åˆ¶ (å†…å­˜ä»¤ç‰Œæ¡¶)
  - CDN ç¼“å­˜ (GetObject å“åº”)

éªŒæ”¶æ ‡å‡†:
  - rclone lsd stratum: â†’ åˆ—å‡º buckets
  - rclone copy file.txt stratum:bucket/ â†’ ä¸Šä¼ æˆåŠŸ
  - rclone cat stratum:bucket/file.txt â†’ ä¸‹è½½æˆåŠŸ
  - rclone delete stratum:bucket/file.txt â†’ åˆ é™¤æˆåŠŸ
  - rclone ls stratum:bucket/ â†’ åˆ—å‡ºæ–‡ä»¶

ä¼°è®¡å·¥ä½œé‡: ~2000 è¡Œ TypeScript
```

### Phase 2: å®¢æˆ·ç«¯å…¼å®¹æ€§ [å·²å®žçŽ°]

**ç›®æ ‡**: aws cli å’Œ s3cmd ä¹Ÿèƒ½æ­£å¸¸å·¥ä½œ

```
äº¤ä»˜ç‰©:
  - AWS SigV4 è®¤è¯
  - CopyObject
  - DeleteObjects (æ‰¹é‡åˆ é™¤)
  - CreateMultipartUpload / UploadPart / CompleteMultipartUpload
  - AbortMultipartUpload / ListParts
  - Legacy ListObjects (v1)
  - CreateBucket / DeleteBucket

éªŒæ”¶æ ‡å‡†:
  - aws s3 cp / ls / rm / sync å…¨éƒ¨æ­£å¸¸
  - s3cmd get / put / ls / del å…¨éƒ¨æ­£å¸¸
  - rclone sync å®Œæ•´ç›®å½•åŒæ­¥

ä¼°è®¡å¢žé‡: ~1200 è¡Œ
```

### Phase 3: æ–‡ä»¶åˆ†äº« [å·²å®žçŽ°]

**ç›®æ ‡**: ç”Ÿæˆå¸¦æ—¶æ•ˆå’Œå£ä»¤çš„åˆ†äº«é“¾æŽ¥

```
äº¤ä»˜ç‰©:
  - åˆ†äº« Token ç”Ÿæˆ/éªŒè¯
  - é¢„ç­¾å URL ç”Ÿæˆ/éªŒè¯
  - HTML ä¸‹è½½é¡µé¢
  - å£ä»¤ä¿æŠ¤
  - ä¸‹è½½æ¬¡æ•°é™åˆ¶
  - åˆ†äº«ç®¡ç† API

éªŒæ”¶æ ‡å‡†:
  - ç”Ÿæˆåˆ†äº«é“¾æŽ¥ï¼Œæµè§ˆå™¨å¯è®¿é—®
  - è¿‡æœŸåŽæ— æ³•è®¿é—®
  - å£ä»¤é”™è¯¯æ— æ³•ä¸‹è½½
  - è¶…å‡ºä¸‹è½½æ¬¡æ•°é™åˆ¶åŽæ— æ³•ä¸‹è½½

ä¼°è®¡å¢žé‡: ~800 è¡Œ
```

### Phase 4: å›¾åºŠ [å·²å®žçŽ°]

**ç›®æ ‡**: å›¾ç‰‡ç›´é“¾è®¿é—®ï¼ŒCDN åŠ é€Ÿ

```
äº¤ä»˜ç‰©:
  - å›¾ç‰‡ Content-Type æ£€æµ‹
  - ç›´é“¾è®¿é—®ï¼ˆå†…è”æ˜¾ç¤ºï¼Œéžä¸‹è½½ï¼‰
  - CORS å¤´æ”¯æŒ
  - é•¿ç¼“å­˜ç­–ç•¥ (immutable)
  - å›¾ç‰‡å˜ä½“æŸ¥è¯¢å‚æ•° (?w=400&fmt=webp) -- éœ€ VPS

éªŒæ”¶æ ‡å‡†:
  - <img src="https://stratum.example.com/bucket/photo.jpg"> æ­£å¸¸æ˜¾ç¤º
  - Markdown å¼•ç”¨å›¾ç‰‡æ­£å¸¸
  - ç¼“å­˜å‘½ä¸­çŽ‡ >90% (çƒ­å›¾ç‰‡)

ä¼°è®¡å¢žé‡: ~400 è¡Œ
```

### Phase 5: VPS + å¤§æ–‡ä»¶ [éƒ¨åˆ†å®žçŽ°]

**ç›®æ ‡**: çªç ´ 20MB é™åˆ¶ï¼Œæ”¯æŒ Range è¯·æ±‚

```
äº¤ä»˜ç‰©:
  - VPS å¤„ç†æœåŠ¡ï¼ˆDocker Composeï¼‰
  - Local Bot API Server é›†æˆ
  - æ–‡ä»¶åˆ†å—ä¸Šä¼ /ä¸‹è½½
  - Range è¯·æ±‚æ”¯æŒ
  - Worker <-> VPS é€šä¿¡åè®®

éªŒæ”¶æ ‡å‡†:
  - ä¸Šä¼ /ä¸‹è½½ 500MB æ–‡ä»¶æˆåŠŸ
  - è§†é¢‘æ–‡ä»¶æµè§ˆå™¨å†…æ’­æ”¾ï¼Œå¯æ‹–è¿›åº¦æ¡
  - æ–­ç‚¹ç»­ä¼ æ­£å¸¸

ä¼°è®¡å¢žé‡: ~1500 è¡Œ (Worker + VPS)
```

### Phase 6: åª’ä½“å¤„ç†

**ç›®æ ‡**: HEIC è½¬æ¢ã€å®žå†µç…§ç‰‡ã€è§†é¢‘è½¬ç 

```
äº¤ä»˜ç‰©:
  - sharp å›¾ç‰‡å¤„ç†ç®¡çº¿
  - ffmpeg è§†é¢‘å¤„ç†ç®¡çº¿
  - HEIC -> JPEG/WebP è‡ªåŠ¨è½¬æ¢
  - å®žå†µç…§ç‰‡è¯†åˆ«å’Œå±•ç¤º
  - è§†é¢‘è½¬ç å’Œå°é¢ç”Ÿæˆ
  - ç¼©ç•¥å›¾è‡ªåŠ¨ç”Ÿæˆ
  - è¡ç”Ÿæ–‡ä»¶å­˜å‚¨

éªŒæ”¶æ ‡å‡†:
  - ä¸Šä¼  HEIC åŽè‡ªåŠ¨ç”Ÿæˆ JPEG ç‰ˆæœ¬
  - ä¸Šä¼ å®žå†µç…§ç‰‡åŽ Web UI å¯ä»¥æ’­æ”¾
  - ä¸Šä¼ è§†é¢‘åŽè‡ªåŠ¨è½¬ç  + å°é¢

ä¼°è®¡å¢žé‡: ~1200 è¡Œ (VPS æœåŠ¡)
```

### Phase 7: Web UI (Telegram Mini App) [å·²å®žçŽ°]

**ç›®æ ‡**: å¯ç”¨çš„æ–‡ä»¶ç®¡ç†å™¨ç•Œé¢

```
äº¤ä»˜ç‰©:
  - Telegram Mini App (çº¯ HTML/CSS/JS, å†…è”åœ¨ Worker ä¸­)
  - æ–‡ä»¶æµè§ˆå™¨ (é¢åŒ…å±‘å¯¼èˆªã€delimiter åˆ†ç»„ã€åˆ†é¡µ)
  - æ‹–æ‹½ä¸Šä¼  (/api/miniapp/upload ç›´æŽ¥ç«¯ç‚¹, å¤šæ–‡ä»¶å¹¶å‘)
  - å›¾ç‰‡ç¼©ç•¥å›¾é¢„è§ˆ
  - åˆ†äº«ç®¡ç† (åˆ›å»º/æŸ¥çœ‹/æ’¤é”€, æ”¯æŒå£ä»¤å’Œæœ‰æ•ˆæœŸ)
  - æ–‡ä»¶æ“ä½œ (é‡å‘½å/ç§»åŠ¨/åˆ é™¤/è¯¦æƒ…)
  - 6 ç§æŽ’åºæ¨¡å¼ã€æ–‡ä»¶åæœç´¢
  - TG ä¸»é¢˜è‰²é€‚é… (æš—è‰²/äº®è‰²æ¨¡å¼)
  - ç©ºçŠ¶æ€å¼•å¯¼ã€ä¸Šä¼ é¢„æ£€ (>20MB æç¤º)ã€åŠ è½½éª¨æž¶å±

éªŒæ”¶æ ‡å‡†:
  - åœ¨ Telegram å†…å®Œæ•´ç®¡ç†æ–‡ä»¶
  - ç§»åŠ¨ç«¯ä½“éªŒè‰¯å¥½
  - æ— éœ€ç‹¬ç«‹åŸŸåæˆ– CF Pages

ä¼°è®¡å·¥ä½œé‡: ~1600 è¡Œå†…è”ä»£ç 
```

### Phase 8: Telegram Bot [å·²å®žçŽ°]

**ç›®æ ‡**: é€šè¿‡ TG Bot ç®¡ç†æ–‡ä»¶

```
äº¤ä»˜ç‰©:
  - 13 ä¸ª Bot å‘½ä»¤ (12 ä¸ªæ³¨å†Œåˆ° setMyCommands + /start å†…å»º)
  - æ–‡ä»¶ä¸Šä¼  (ç›´æŽ¥å‘æ–‡ä»¶ç»™ Bot, æ”¯æŒ document/photo/video/audio)
  - æ–‡ä»¶åˆ—è¡¨/æœç´¢/åˆ é™¤ (å« Inline Keyboard ç¡®è®¤)
  - åˆ†äº«é“¾æŽ¥åˆ›å»º/åˆ—è¡¨/æ’¤é”€
  - Callback Query å¤„ç† (åˆ é™¤ç¡®è®¤ã€å¿«æ·åˆ†äº«ã€å¿«æ·è¯¦æƒ…)
  - setMyCommands è‡ªåŠ¨æ³¨å†Œ (æŒ‰è¯­è¨€æ³¨å†Œå‘½ä»¤æè¿°)
  - Bot å¤šè¯­è¨€æ”¯æŒ (EN/ZH/JA/FR, åŸºäºŽç”¨æˆ· Telegram è¯­è¨€è‡ªåŠ¨æ£€æµ‹)

ä¼°è®¡å¢žé‡: ~800 è¡Œ
```

## ä¸ƒã€æ€»å·¥ä½œé‡ä¼°ç®—

| Phase | å†…å®¹ | ä»£ç é‡ | ç´¯è®¡ |
|-------|------|--------|------|
| 1 | S3 åŸºç¡€ API | ~2000 è¡Œ | 2000 |
| 2 | å®¢æˆ·ç«¯å…¼å®¹ | ~1200 è¡Œ | 3200 |
| 3 | æ–‡ä»¶åˆ†äº« | ~800 è¡Œ | 4000 |
| 4 | å›¾åºŠ | ~400 è¡Œ | 4400 |
| 5 | VPS + å¤§æ–‡ä»¶ | ~500 è¡Œ | 4900 |
| 6 | åª’ä½“å¤„ç† | ~200 è¡Œ | 5100 |
| 7 | Web UI | ~1600 è¡Œ | 6700 |
| 8 | TG Bot | ~800 è¡Œ | 7500 |

**å®žé™…çº¦ 9,600 è¡Œä»£ç **ï¼ˆTypeScript + å†…è” HTML/CSS/JS + SQLï¼‰ã€‚

> æ³¨: Phase 5-6 ä¸­ VPS ç«¯æœåŠ¡ä»£ç ï¼ˆDocker/Node.jsï¼‰ä¸ºç‹¬ç«‹ä»“åº“ï¼Œæ­¤å¤„ä»…ç»Ÿè®¡ Worker ä¾§ä»£ç ã€‚

## å…«ã€çŽ¯å¢ƒå˜é‡ä¸Ž Secrets

**Worker ä¾§ (CF Worker Secrets / Vars)**

| å˜é‡ | ç”¨é€” | å­˜å‚¨æ–¹å¼ |
|------|------|---------|
| TG_BOT_TOKEN | Telegram Bot Token | Secret |
| S3_REGION | S3 åŒºåŸŸæ ‡è¯† (é»˜è®¤ "us-east-1") | Var (wrangler.toml) |
| VPS_URL | VPS æœåŠ¡åœ°å€ (å¯é€‰) | Secret |
| VPS_SECRET | Worker è°ƒç”¨ VPS çš„è®¤è¯å¯†é’¥ (å¯é€‰) | Secret |
| DEFAULT_CHAT_ID | é»˜è®¤ TG é¢‘é“/ç¾¤ç»„ ID | Secret |
| WORKER_URL | Worker å…¬å¼€ URL, Cron CDN ç¼“å­˜æ¸…ç†ç”¨ (å¯é€‰) | Var |

**VPS ä¾§ (.env)**

| å˜é‡ | ç”¨é€” |
|------|------|
| TG_BOT_TOKEN | Telegram Bot Token (ä¸Ž Worker ç›¸åŒ) |
| TG_API_ID | Telegram API ID (Local Bot API Server éœ€è¦) |
| TG_API_HASH | Telegram API Hash (Local Bot API Server éœ€è¦) |
| VPS_SECRET | Worker è°ƒç”¨è®¤è¯å¯†é’¥ (ä¸Ž Worker ç›¸åŒ) |

Binding èµ„æºï¼š

| Binding | ç±»åž‹ | åç§° | ç”¨é€” |
|---------|------|------|------|
| DB | D1 Database | stratum-db | å…ƒæ•°æ®å­˜å‚¨ |
| CACHE | R2 Bucket | stratum-cache | æŒä¹…æ–‡ä»¶ç¼“å­˜ (64KB-20MB) |

**R2 Bucket é…ç½®**

åœ¨ Cloudflare Dashboard çš„ R2 > stratum-cache > Settings ä¸­é…ç½® Object Lifecycle Rule:
- Rule name: `auto-expire-cache`
- Prefix: (ç•™ç©ºï¼Œé€‚ç”¨äºŽå…¨éƒ¨å¯¹è±¡)
- Action: Delete objects after **90 å¤©**
- ä½œç”¨: ä½œä¸º cron ç¼“å­˜æ¸…ç†çš„å…œåº•å®‰å…¨ç½‘ï¼Œé˜²æ­¢å­¤å„¿ç¼“å­˜æ°¸ä¹…å ç”¨ç©ºé—´
