# éƒ¨ç½²æŒ‡å—

[English](deployment.md) | [ä¸­æ–‡](deployment.zh.md) | [æ—¥æœ¬èªž](deployment.ja.md) | [FranÃ§ais](deployment.fr.md)

## éƒ¨ç½²å±‚çº§

Stratum æ”¯æŒä¸‰ä¸ªéƒ¨ç½²å±‚çº§ï¼š

| å±‚çº§ | ç»„ä»¶ | è´¹ç”¨ | åŠŸèƒ½ |
|------|------|------|------|
| æœ€å°åŒ– | CF Worker + D1 + R2 | $0/æœˆ | S3 APIã€Botã€Mini Appï¼Œæ–‡ä»¶æœ€å¤§ 20MB |
| æ ‡å‡† | æœ€å°åŒ– + VPS | çº¦ $4/æœˆ | + æ–‡ä»¶æœ€å¤§ 2GBï¼Œåª’ä½“å¤„ç† |
| å¢žå¼º | æ ‡å‡† + CF ä»˜è´¹è®¡åˆ’ | çº¦ $9/æœˆ | + æ›´é«˜é€ŸçŽ‡é™åˆ¶ï¼Œæ›´å¤š D1 æŸ¥è¯¢ |

## å‰ææ¡ä»¶

1. **Telegram Bot** -- é€šè¿‡ [@BotFather](https://t.me/BotFather) åˆ›å»ºï¼Œä¿å­˜ token
2. **Telegram ç¾¤ç»„** -- åˆ›å»ºç¾¤ç»„æˆ–è¶…çº§ç¾¤ç»„ï¼Œå°† bot æ·»åŠ ä¸ºç®¡ç†å‘˜ï¼ŒèŽ·å– chat ID
3. **Cloudflare è´¦æˆ·** -- åœ¨ [dash.cloudflare.com](https://dash.cloudflare.com) æ³¨å†Œ
4. **Node.js 22+** -- wrangler CLI æ‰€éœ€ï¼ˆä»…æ‰‹åŠ¨éƒ¨ç½²éœ€è¦ï¼‰

### èŽ·å– Chat ID

ä¸´æ—¶å°† [@userinfobot](https://t.me/userinfobot) æ·»åŠ åˆ°ç¾¤ç»„ä¸­ï¼Œå®ƒä¼šå›žå¤ chat IDï¼ˆä¸€ä¸ªè´Ÿæ•°ï¼Œå¦‚ `-1001234567890`ï¼‰ã€‚èŽ·å–åŽå°†å…¶ç§»é™¤ã€‚

### åˆ›å»º Cloudflare API Token

Docker éƒ¨ç½²éœ€è¦åœ¨ [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens) åˆ›å»ºä¸€ä¸ªåŒ…å«ä»¥ä¸‹æƒé™çš„ tokenï¼š
- Account / Workers Scripts: Edit
- Account / D1: Edit
- Account / R2: Edit
- Account / Account Settings: Read
- Account / Cloudflare Tunnel: Edit *ï¼ˆä»…ä½¿ç”¨ tunnel æ—¶éœ€è¦ï¼‰*
- Zone / DNS: Edit *ï¼ˆä»…ä½¿ç”¨ tunnel é…åˆè‡ªå®šä¹‰åŸŸåæ—¶éœ€è¦ï¼‰*

## æ–¹æ³•ä¸€ï¼šDocker éƒ¨ç½²ï¼ˆæŽ¨èï¼‰

é€‚åˆ VPS éƒ¨ç½²ï¼Œä¸€æ¡å‘½ä»¤æžå®šä¸€åˆ‡ã€‚

```bash
# å…‹éš†å¹¶é…ç½®
git clone https://github.com/DebadityaHait/stratum.git
cd stratum
cp .env.example .env
```

ç¼–è¾‘ `.env`ï¼Œä»…éœ€å¡«å†™ 2 é¡¹å¿…å¡«å€¼ï¼š

```bash
# å¿…å¡«
TG_BOT_TOKEN=123456:ABC-DEF...
DEFAULT_CHAT_ID=-1001234567890

# Docker éƒ¨ç½²
CLOUDFLARE_API_TOKEN=your-cf-api-token

# å¯é€‰ï¼šè‡ªå®šä¹‰åŸŸåï¼ˆåŒæ—¶å¯ç”¨ tunnel è‡ªåŠ¨åˆ›å»ºï¼‰
CF_CUSTOM_DOMAIN=s3.example.com
```

å…¶ä»–å‡­æ®ï¼ˆS3 å¯†é’¥ã€VPS_SECRETã€webhook å¯†é’¥ï¼‰å‡åœ¨éƒ¨ç½²æ—¶**è‡ªåŠ¨ç”Ÿæˆ**ã€‚

éƒ¨ç½²ï¼š

```bash
./deploy.sh
```

è„šæœ¬è‡ªåŠ¨æ£€æµ‹çŽ¯å¢ƒå¹¶æ‰§è¡Œç›¸åº”æ“ä½œï¼š
- **å®¿ä¸»æœºæœ‰ Dockerï¼š** æž„å»ºé•œåƒï¼Œéƒ¨ç½² CF Workerï¼Œé…ç½® tunnelï¼ˆå¦‚å·²å¯ç”¨ï¼‰ï¼Œå¯åŠ¨æ‰€æœ‰æœåŠ¡
- **å®¿ä¸»æœºæ—  Dockerï¼š** ä½¿ç”¨æœ¬åœ° wrangler ç›´æŽ¥éƒ¨ç½² Worker

éƒ¨ç½²å®ŒæˆåŽï¼Œåœ¨ Telegram Mini App çš„ Keys æ ‡ç­¾é¡µä¸­åˆ›å»º S3 å‡­æ®ä»¥è¿žæŽ¥ S3 å®¢æˆ·ç«¯ã€‚

### Cloudflare Tunnelï¼ˆæŽ¨èç”¨äºŽ VPSï¼‰

Cloudflare Tunnel åœ¨ processor å’Œ CF Worker ä¹‹é—´å»ºç«‹å®‰å…¨è¿žæŽ¥ï¼Œæ— éœ€æš´éœ²å…¬ç½‘ç«¯å£ã€‚

**è‡ªåŠ¨é…ç½®**ï¼ˆéœ€è¦åœ¨ `.env` ä¸­è®¾ç½® `CF_CUSTOM_DOMAIN`ï¼‰ï¼š

`deploy.sh` ä¼šè‡ªåŠ¨åˆ›å»º tunnel å¹¶é…ç½® DNSã€‚tunnel åŸŸåä¸º `vps.<ä½ çš„è‡ªå®šä¹‰åŸŸå>`ã€‚åªéœ€è¿è¡Œ `./deploy.sh`ï¼Œè®¾ç½®äº† `CF_CUSTOM_DOMAIN` åŽ tunnel ä¼šè‡ªåŠ¨é…ç½®ã€‚

**æ‰‹åŠ¨é…ç½®**ï¼ˆæ— è‡ªå®šä¹‰åŸŸåæ—¶ï¼‰ï¼š

1. è¿›å…¥ CF Dashboard > Zero Trust > Networks > Tunnels
2. åˆ›å»ºåä¸º `Stratum` çš„ tunnel
3. æ·»åŠ å…¬å…±ä¸»æœºåï¼ŒæŒ‡å‘ `http://processor:3000`
4. å°† tunnel token å¤åˆ¶åˆ° `.env`ï¼š

```bash
CF_TUNNEL_TOKEN=eyJhIjo...
```

5. å¯åŠ¨éƒ¨ç½²ï¼š

```bash
./deploy.sh
```

Tunnel æ›¿ä»£äº† `VPS_URL`ï¼ŒWorker é€šè¿‡ Cloudflare ç½‘ç»œè®¿é—® processorï¼Œè€Œéžç›´æŽ¥è¿žæŽ¥ã€‚

### æ›´æ–°

```bash
git pull && ./deploy.sh
```

## æ–¹æ³•äºŒï¼šæ‰‹åŠ¨éƒ¨ç½²ï¼ˆæ—  Dockerï¼‰

### ä»… Cloudflare Workerï¼ˆæœ€å°åŒ–å±‚çº§ï¼‰

```bash
npm install
cp .env.example .env
# ç¼–è¾‘ .envï¼ˆä»…éœ€ TG_BOT_TOKEN å’Œ DEFAULT_CHAT_IDï¼‰

./deploy.sh
```

è„šæœ¬è‡ªåŠ¨æ£€æµ‹åˆ° Docker ä¸å¯ç”¨æ—¶ï¼Œä¼šä½¿ç”¨æœ¬åœ° wranglerã€‚å®ƒå°†æ‰§è¡Œä»¥ä¸‹æ“ä½œï¼š
1. éªŒè¯é…ç½®
2. åˆ›å»º D1 æ•°æ®åº“å¹¶åˆå§‹åŒ– schema
3. åˆ›å»º R2 å­˜å‚¨æ¡¶å¹¶è®¾ç½®ç”Ÿå‘½å‘¨æœŸç­–ç•¥
4. è‡ªåŠ¨ç”Ÿæˆ VPS_SECRET
5. åœ¨ D1 ä¸­åˆ›å»ºåˆå§‹ admin S3 å‡­æ®
6. åœ¨ Cloudflare ä¸­è®¾ç½®æ‰€æœ‰ secrets
7. éƒ¨ç½² Worker
8. æ³¨å†Œ Telegram Bot webhook

### ä¼ ç»Ÿ VPS SSH éƒ¨ç½²

é€šè¿‡ SSH å°† processor éƒ¨ç½²åˆ°è¿œç¨‹ VPS æ—¶ï¼Œåœ¨ `.env` ä¸­æ·»åŠ  VPS é…ç½®ï¼š

```bash
VPS_SSH=user@your-vps-ip
VPS_DEPLOY_DIR=/opt/stratum
VPS_PORT=3000
VPS_URL=https://vps.example.com:3000
# VPS_SECRET æœªè®¾ç½®æ—¶è‡ªåŠ¨ç”Ÿæˆ
```

ç„¶åŽéƒ¨ç½²ï¼š

```bash
./deploy.sh --vps
```

VPS éƒ¨ç½²å°†æ‰§è¡Œä»¥ä¸‹æ“ä½œï¼š
1. æ£€æŸ¥ SSH è¿žé€šæ€§
2. å¦‚éœ€è¦åˆ™å®‰è£… Docker
3. é€šè¿‡ rsync ä¸Šä¼  processor æ–‡ä»¶
4. æž„å»ºå¹¶å¯åŠ¨ processor å®¹å™¨

## éƒ¨ç½²åŽéªŒè¯

### S3 å‡­æ®

S3 å‡­æ®åœ¨éƒ¨ç½²æ—¶æ˜¾ç¤ºä¸€æ¬¡ã€‚ä¹‹åŽå¯åœ¨ Mini App çš„ **Keys** æ ‡ç­¾é¡µä¸­ç®¡ç†å‡­æ®ï¼ˆåˆ›å»ºã€æ’¤é”€ã€è®¾ç½®å•æ¡¶æƒé™ï¼‰ã€‚

### éªŒè¯ S3 è®¿é—®

```bash
# AWS CLIï¼ˆä½¿ç”¨éƒ¨ç½²è¾“å‡ºä¸­çš„å‡­æ®ï¼‰
aws --endpoint-url https://your-worker.workers.dev s3 ls
aws --endpoint-url https://your-worker.workers.dev s3 mb s3://test
aws --endpoint-url https://your-worker.workers.dev s3 cp file.txt s3://test/

# rclone
rclone config create stratum s3 \
  provider=Other \
  access_key_id=YOUR_KEY \
  secret_access_key=YOUR_SECRET \
  endpoint=https://your-worker.workers.dev \
  acl=private
rclone ls stratum:default
```

### éªŒè¯ Bot

åœ¨ Telegram ä¸­å‘ä½ çš„ bot å‘é€ `/start`ï¼Œå®ƒåº”è¯¥å›žå¤æ¬¢è¿Žæ¶ˆæ¯ã€‚

### éªŒè¯ Mini App

å‘ bot å‘é€ `/miniapp`ï¼Œæˆ–ç›´æŽ¥è®¿é—® `https://your-worker.workers.dev/miniapp`ã€‚

## è‡ªå®šä¹‰åŸŸå

1. åœ¨ Cloudflare DNS ä¸­æ·»åŠ ä¸€æ¡æŒ‡å‘ä½ çš„ worker çš„ CNAME è®°å½•
2. åœ¨ Cloudflare æŽ§åˆ¶å°ä¸­ï¼Œè¿›å…¥ Workers & Pages > ä½ çš„ worker > Settings > Triggers
3. æ·»åŠ è‡ªå®šä¹‰åŸŸå
4. åœ¨ `.env` ä¸­è®¾ç½® `CF_CUSTOM_DOMAIN`ï¼Œç„¶åŽé‡æ–°éƒ¨ç½²

## æ•…éšœæŽ’æŸ¥

### Worker æ— å“åº”
- ä½¿ç”¨ `npx wrangler tail` æŸ¥çœ‹å®žæ—¶æ—¥å¿—
- éªŒè¯ secrets æ˜¯å¦å·²è®¾ç½®ï¼š`npx wrangler secret list`

### Bot æœªæ”¶åˆ°æ¶ˆæ¯
- éªŒè¯ webhookï¼š`curl https://api.telegram.org/bot<TOKEN>/getWebhookInfo`
- é‡æ–°æ³¨å†Œï¼šä½¿ç”¨ `deploy.sh` é‡æ–°éƒ¨ç½²ï¼ˆwebhook å¯†é’¥ç”± TG_BOT_TOKEN è‡ªåŠ¨æ´¾ç”Ÿï¼‰

### D1 é”™è¯¯
- æ£€æŸ¥æ•°æ®åº“æ˜¯å¦å­˜åœ¨ï¼š`npx wrangler d1 list`
- é‡æ–°åˆå§‹åŒ– schemaï¼š`npm run db:init:remote`

### VPS processor ä¸å¯è¾¾
- æ£€æŸ¥å®¹å™¨ï¼š`docker compose logs processor`
- éªŒè¯ç«¯å£æ˜¯å¦å¼€æ”¾ï¼š`curl http://localhost:3000/health`
- è€ƒè™‘ä½¿ç”¨ Cloudflare Tunnel ä»£æ›¿ç›´æŽ¥ç«¯å£æš´éœ²
