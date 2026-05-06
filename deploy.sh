#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Stratum ä¸€é”®éƒ¨ç½²è„šæœ¬
#
# ç”¨æ³•: ./deploy.sh
#   è‡ªåŠ¨æ£€æµ‹è¿è¡ŒçŽ¯å¢ƒ:
#   - å®¿ä¸»æœº + Docker å¯ç”¨: æž„å»ºé•œåƒ + éƒ¨ç½² Worker + å¯åŠ¨æ‰€æœ‰æœåŠ¡
#   - å®¿ä¸»æœº + æ—  Docker:   ä½¿ç”¨æœ¬åœ° wrangler éƒ¨ç½² Worker
#   - Docker å®¹å™¨å†…:         ä»…éƒ¨ç½² Worker (ç”±å®¿ä¸»æœºç¼–æŽ’è°ƒç”¨)
#
# å¯é€‰å‚æ•°:
#   --vps    ä¼ ç»Ÿ SSH éƒ¨ç½²æ¨¡å¼ (éž Docker)
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---- é¢œè‰² ----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[!!]${NC} $1"; }
err()  { echo -e "${RED}[ERR]${NC} $1" >&2; }
step() { echo -e "\n${CYAN}==>${NC} $1"; }

gen_random() {
  local len="${1:-32}"
  LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$len" 2>/dev/null || \
    openssl rand -base64 "$((len * 2))" | tr -dc 'A-Za-z0-9' | head -c "$len"
}

# ---- çŽ¯å¢ƒæ£€æµ‹ ----
IN_CONTAINER=0
if [ -f /.dockerenv ] || grep -qsE 'docker|containerd' /proc/1/cgroup 2>/dev/null; then
  IN_CONTAINER=1
fi

# ---- åŠ è½½ .env ----
if [ ! -f .env ]; then
  err "æœªæ‰¾åˆ° .env æ–‡ä»¶ã€‚è¯·å¤åˆ¶ .env.example ä¸º .env å¹¶å¡«å†™é…ç½®:"
  err "  cp .env.example .env && vim .env"
  exit 1
fi

set -a
source .env
set +a

# å…¼å®¹æ—§ç‰ˆ CF_ACCOUNT_ID (wrangler 4.x è¦æ±‚ CLOUDFLARE_ACCOUNT_ID)
if [ -n "${CF_ACCOUNT_ID:-}" ] && [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
  CLOUDFLARE_ACCOUNT_ID="$CF_ACCOUNT_ID"
  export CLOUDFLARE_ACCOUNT_ID
fi

# ---- å·¥å…·å‡½æ•° ----
# è·¨å¹³å° sed -i (macOS éœ€è¦ -i ''ï¼ŒLinux éœ€è¦ -i)
sed_inplace() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

derive_webhook_secret() {
  node -e "const c=require('crypto');console.log(c.createHmac('sha256',process.env.TG_BOT_TOKEN).update('stratum-webhook').digest('hex'))"
}

# HTTP è¯·æ±‚ (Node.js fetch æ›¿ä»£ curl, Docker å®¹å™¨å†… curl å­˜åœ¨ SSL/CA å…¼å®¹æ€§é—®é¢˜)
_fetch() {
  local method="GET" url="" body=""
  local -a headers=()
  while [ $# -gt 0 ]; do
    case "$1" in
      -s) shift ;;
      -X) method="$2"; shift 2 ;;
      -H) headers+=("$2"); shift 2 ;;
      -d) body="$2"; shift 2 ;;
      *)  url="$1"; shift ;;
    esac
  done
  node -e "
    (async () => {
      const [url, method, body, ...hdrs] = process.argv.slice(1);
      const headers = {};
      for (const h of hdrs) { const i = h.indexOf(': '); if (i > 0) headers[h.slice(0,i)] = h.slice(i+2); }
      const opts = { method, headers };
      if (body) opts.body = body;
      const r = await fetch(url, opts);
      process.stdout.write(await r.text());
    })().catch(e => { process.stderr.write(e.message + '\n'); process.exit(1); });
  " "$url" "$method" "$body" ${headers[@]+"${headers[@]}"}
}

# æŒä¹…åŒ–å†™å…¥ .env (å·²æœ‰åˆ™æ›´æ–°ï¼Œæ²¡æœ‰åˆ™è¿½åŠ )
# ä½¿ç”¨é€è¡Œé‡å†™é¿å… sed ç‰¹æ®Šå­—ç¬¦è½¬ä¹‰é—®é¢˜
persist_env() {
  local key="$1" val="$2"
  if grep -q "^${key}=" .env 2>/dev/null; then
    # é€è¡Œé‡å†™: é¿å… sed å¯¹ val ä¸­ | & \ ç­‰ç‰¹æ®Šå­—ç¬¦çš„è½¬ä¹‰é—®é¢˜
    local tmpfile
    tmpfile=$(mktemp "${TMPDIR:-/tmp}/env.XXXXXX")
    while IFS= read -r line || [ -n "$line" ]; do
      if [[ "$line" == "${key}="* ]]; then
        echo "${key}=${val}"
      else
        echo "$line"
      fi
    done < .env > "$tmpfile"
    if cat "$tmpfile" > .env; then
      rm -f "$tmpfile"
    else
      rm -f "$tmpfile"
      return 1
    fi
  else
    echo "${key}=${val}" >> .env
  fi
}

# ---- äº¤äº’å¼é…ç½® ----
INTERACTIVE=0
if [ "$IN_CONTAINER" -eq 0 ] && [ -t 0 ] && [ -t 1 ]; then
  INTERACTIVE=1
fi

open_url() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$1" 2>/dev/null &
  elif command -v xdg-open &>/dev/null; then
    xdg-open "$1" 2>/dev/null &
  fi
}

ask_value() {
  local var_name="$1" prompt="$2" value
  read -rp "  $prompt: " value
  if [ -n "$value" ]; then
    eval "$var_name=\"\$value\""
    export "$var_name"
    persist_env "$var_name" "$value"
  fi
}

ask_yn() {
  local prompt="$1" default="${2:-Y}" choice
  read -rp "$(echo -e "${CYAN}?${NC}") $prompt [${default}]: " choice
  [[ "${choice:-$default}" =~ ^[Yy]$ ]]
}

interactive_setup() {
  step "çŽ¯å¢ƒé…ç½®æ£€æŸ¥"

  # -- å¿…å¡«é¡¹ --

  if [ -n "${TG_BOT_TOKEN:-}" ]; then
    log "TG_BOT_TOKEN âœ“"
  else
    warn "TG_BOT_TOKEN æœªè®¾ç½® (å¿…å¡«)"
    echo "  1. Telegram ä¸­æ‰¾ @BotFather, å‘é€ /newbot"
    echo "  2. æŒ‰æç¤ºåˆ›å»º Bot, å¤åˆ¶ç”Ÿæˆçš„ Token"
    if [ "$INTERACTIVE" -eq 1 ]; then
      open_url "https://t.me/BotFather"
      ask_value TG_BOT_TOKEN "è¯·è¾“å…¥ Bot Token"
    fi
  fi

  if [ -n "${DEFAULT_CHAT_ID:-}" ]; then
    log "DEFAULT_CHAT_ID âœ“"
  else
    warn "DEFAULT_CHAT_ID æœªè®¾ç½® (å¿…å¡«)"
    echo "  1. åˆ›å»º Telegram ç¾¤ç»„, å°† Bot æ·»åŠ ä¸ºç®¡ç†å‘˜"
    echo "  2. åœ¨ç¾¤ç»„ä¸­å‘é€ä¸€æ¡æ¶ˆæ¯"
    if [ -n "${TG_BOT_TOKEN:-}" ]; then
      echo "  3. æ‰“å¼€ä»¥ä¸‹é“¾æŽ¥, åœ¨ JSON ä¸­æ‰¾ chat.id:"
      echo "     https://api.telegram.org/bot${TG_BOT_TOKEN}/getUpdates"
      if [ "$INTERACTIVE" -eq 1 ]; then
        open_url "https://api.telegram.org/bot${TG_BOT_TOKEN}/getUpdates"
      fi
    else
      echo "  3. å…ˆè®¾ç½® TG_BOT_TOKEN, å†ç”¨ getUpdates API èŽ·å–"
    fi
    if [ "$INTERACTIVE" -eq 1 ]; then
      ask_value DEFAULT_CHAT_ID "è¯·è¾“å…¥ Chat ID (å¦‚ -1001234567890)"
    fi
  fi

  # -- å¯é€‰åŠŸèƒ½ --

  if [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
    log "CLOUDFLARE_API_TOKEN âœ“"
  elif [ "$INTERACTIVE" -eq 1 ]; then
    echo ""
    if ask_yn "é…ç½® Cloudflare API Token? (Docker éƒ¨ç½²å¿…å¡«)" "Y"; then
      echo "  1. åˆ›å»ºè‡ªå®šä¹‰ API Token"
      echo "  2. æƒé™: Workers Scripts:Edit, D1:Edit, R2:Edit, Account Settings:Read"
      echo "     å¦‚éœ€ tunnel: è¿½åŠ  Cloudflare Tunnel:Edit, DNS:Edit"
      open_url "https://dash.cloudflare.com/profile/api-tokens"
      ask_value CLOUDFLARE_API_TOKEN "è¯·è¾“å…¥ API Token"
    fi
  fi

  if [ -n "${CF_CUSTOM_DOMAIN:-}" ]; then
    log "CF_CUSTOM_DOMAIN = ${CF_CUSTOM_DOMAIN} âœ“"
  elif [ "$INTERACTIVE" -eq 1 ]; then
    echo ""
    if ask_yn "ä½¿ç”¨è‡ªå®šä¹‰åŸŸå? (åŒæ—¶å¯ç”¨ Cloudflare Tunnel)" "Y"; then
      ask_value CF_CUSTOM_DOMAIN "è¯·è¾“å…¥åŸŸå (å¦‚ s3.example.com)"
    fi
  fi

  if [ -n "${TELEGRAM_API_ID:-}" ] && [ -n "${TELEGRAM_API_HASH:-}" ]; then
    log "Telegram Local Bot API âœ“ (2GB æ–‡ä»¶æ”¯æŒ)"
  elif [ "$INTERACTIVE" -eq 1 ]; then
    echo ""
    echo "  Local Bot API å¯å°†æ–‡ä»¶å¤§å°é™åˆ¶ä»Ž 20MB æå‡åˆ° 2GB"
    if ask_yn "å¯ç”¨ Telegram Local Bot API?" "Y"; then
      echo "  1. ç”¨æ‰‹æœºå·ç™»å½• my.telegram.org"
      echo "  2. é€‰æ‹© 'API development tools'"
      echo "  3. åˆ›å»ºåº”ç”¨, èŽ·å– api_id å’Œ api_hash"
      open_url "https://my.telegram.org"
      ask_value TELEGRAM_API_ID "è¯·è¾“å…¥ API ID (çº¯æ•°å­—)"
      ask_value TELEGRAM_API_HASH "è¯·è¾“å…¥ API Hash"
    fi
  fi

  echo ""
}

# å®¿ä¸»æœºä¸Šè¿è¡Œäº¤äº’å¼å¼•å¯¼ (å®¹å™¨å†…è·³è¿‡)
if [ "$IN_CONTAINER" -eq 0 ]; then
  interactive_setup
fi

# ---- è‡ªåŠ¨ç”Ÿæˆ secrets ----
if [ -z "${VPS_SECRET:-}" ]; then
  VPS_SECRET="$(gen_random 48)"
  persist_env VPS_SECRET "$VPS_SECRET"
  log "è‡ªåŠ¨ç”Ÿæˆ VPS_SECRET"
fi
if [ -z "${SSE_MASTER_KEY:-}" ]; then
  SSE_MASTER_KEY="$(openssl rand -base64 32)"
  persist_env SSE_MASTER_KEY "$SSE_MASTER_KEY"
  log "è‡ªåŠ¨ç”Ÿæˆ SSE_MASTER_KEY"
fi

# ---- Telegram Local Bot API æ£€æµ‹ ----
HAS_LOCAL_API=0
if [ -n "${TELEGRAM_API_ID:-}" ] && [ -n "${TELEGRAM_API_HASH:-}" ]; then
  HAS_LOCAL_API=1
  TG_LOCAL_API="http://telegram-bot-api:8081"
  persist_env TG_LOCAL_API "$TG_LOCAL_API"
  log "å¯ç”¨ Local Bot API (2GB æ–‡ä»¶æ”¯æŒ)"
elif [ -n "${TELEGRAM_API_ID:-}" ] || [ -n "${TELEGRAM_API_HASH:-}" ]; then
  # åªå¡«äº†ä¸€ä¸ª, æé†’ç”¨æˆ·è¡¥å…¨
  warn "TELEGRAM_API_ID å’Œ TELEGRAM_API_HASH å¿…é¡»åŒæ—¶è®¾ç½®, å½“å‰åªè®¾äº†å…¶ä¸­ä¸€ä¸ª"
  warn "Local Bot API æœªå¯ç”¨, æ–‡ä»¶å¤§å°é™åˆ¶ 20MB"
  TG_LOCAL_API="https://api.telegram.org"
else
  if [ -z "${TG_LOCAL_API:-}" ]; then
    TG_LOCAL_API="https://api.telegram.org"
  fi
  # éžäº¤äº’æ¨¡å¼ä¸‹ç»™å‡ºæç¤º (äº¤äº’æ¨¡å¼å·²åœ¨ interactive_setup ä¸­å¤„ç†)
  if [ "$INTERACTIVE" -eq 0 ] && [ "$IN_CONTAINER" -eq 0 ]; then
    warn "æœªé…ç½® TELEGRAM_API_ID/HASH, æ–‡ä»¶å¤§å°é™åˆ¶ 20MB"
  fi
fi

# ---- æ ¡éªŒå¿…å¡«é¡¹ ----
validate_required() {
  local missing=0
  for var in TG_BOT_TOKEN DEFAULT_CHAT_ID; do
    if [ -z "${!var:-}" ]; then
      err "ç¼ºå°‘å¿…å¡«é¡¹: $var"
      missing=1
    fi
  done
  if [ $missing -eq 1 ]; then
    err "è¯·åœ¨ .env ä¸­å¡«å†™å¿…å¡«é¡¹, æˆ–é‡æ–°è¿è¡Œ ./deploy.sh è¿›è¡Œäº¤äº’å¼é…ç½®"
    exit 1
  fi
}

# ============================================================
# CF Worker éƒ¨ç½² (åœ¨å®¹å™¨å†…æˆ–æœ¬åœ°æ‰§è¡Œ)
# ============================================================
deploy_cf() {
  step "éƒ¨ç½² Cloudflare Worker"

  if ! command -v npx &>/dev/null; then
    err "éœ€è¦ Node.js å’Œ npm, è¯·å…ˆå®‰è£…"
    exit 1
  fi

  # å®‰è£…ä¾èµ–
  if [ ! -d node_modules ]; then
    step "å®‰è£… npm ä¾èµ–"
    npm install
    log "ä¾èµ–å®‰è£…å®Œæˆ"
  fi

  # æ£€æŸ¥ wrangler è®¤è¯
  step "æ£€æŸ¥ Cloudflare è®¤è¯çŠ¶æ€"
  if [ -n "${CLOUDFLARE_API_TOKEN:-}" ]; then
    log "ä½¿ç”¨ CLOUDFLARE_API_TOKEN è®¤è¯"
  elif ! npx wrangler whoami &>/dev/null 2>&1; then
    warn "wrangler æœªç™»å½•, æ­£åœ¨æ‰“å¼€æµè§ˆå™¨æŽˆæƒ..."
    npx wrangler login
  fi
  log "Cloudflare è®¤è¯æ­£å¸¸"

  # èŽ·å–æˆ–åˆ›å»º D1 æ•°æ®åº“ (å®Œå…¨è‡ªåŠ¨ï¼Œæ”¯æŒé‡å¤éƒ¨ç½²)
  # ä¼˜å…ˆçº§: .env ç¼“å­˜ > wrangler.toml > è¿œç¨‹æŸ¥è¯¢ > æ–°å»º
  CURRENT_DB_ID=$(grep 'database_id' wrangler.toml | head -1 | sed 's/.*= *"\(.*\)"/\1/')
  DB_ID=""

  if [ -n "$CURRENT_DB_ID" ]; then
    DB_ID="$CURRENT_DB_ID"
    log "D1 æ•°æ®åº“å·²å­˜åœ¨: $DB_ID"
  elif [ -n "${D1_DATABASE_ID:-}" ]; then
    DB_ID="$D1_DATABASE_ID"
    log "D1 æ•°æ®åº“ ID å·²ä»Ž .env æ¢å¤: $DB_ID"
  else
    # å…ˆæŸ¥è¿œç¨‹æ˜¯å¦å·²æœ‰åŒåæ•°æ®åº“
    step "æŸ¥æ‰¾ D1 æ•°æ®åº“ stratum-db"
    DB_ID=$(npx wrangler d1 list --json 2>/dev/null | \
      node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); const db=d.find(x=>x.name==='stratum-db'); console.log(db?.uuid||'')" 2>/dev/null) || DB_ID=""

    if [ -z "$DB_ID" ]; then
      # è¿œç¨‹æ²¡æœ‰, åˆ›å»ºæ–°æ•°æ®åº“
      step "åˆ›å»º D1 æ•°æ®åº“ stratum-db"
      DB_OUTPUT=$(npx wrangler d1 create stratum-db 2>&1) || true
      DB_ID=$(echo "$DB_OUTPUT" | grep -o 'database_id = "[^"]*"' | head -1 | sed 's/database_id = "\(.*\)"/\1/')
    fi

    if [ -z "$DB_ID" ]; then
      err "æ— æ³•èŽ·å– D1 æ•°æ®åº“ ID"
      exit 1
    fi
    log "D1 æ•°æ®åº“: $DB_ID"
  fi

  # ç¡®ä¿ wrangler.toml ä¸­æœ‰æ­£ç¡®çš„ database_id
  if [ -z "$CURRENT_DB_ID" ]; then
    sed_inplace "s/database_id = \"\"/database_id = \"$DB_ID\"/" wrangler.toml
  fi

  # æŒä¹…åŒ–åˆ° .env (Docker å®¹å™¨å†… wrangler.toml ä¸æŒä¹…ï¼Œ.env é€šè¿‡ volume æŒä¹…åŒ–)
  persist_env D1_DATABASE_ID "$DB_ID"

  # åˆ›å»º R2 ç¼“å­˜ bucket
  step "åˆ›å»º R2 ç¼“å­˜ bucket stratum-cache"
  if npx wrangler r2 bucket list 2>&1 | grep -q 'stratum-cache'; then
    log "R2 ç¼“å­˜ bucket å·²å­˜åœ¨"
  else
    npx wrangler r2 bucket create stratum-cache 2>&1 || true
    log "R2 ç¼“å­˜ bucket åˆ›å»ºå®Œæˆ"
  fi

  # R2 lifecycle: 90 å¤©å…œåº• GC
  step "é…ç½® R2 å…œåº•æ¸…ç†ç­–ç•¥ (90 å¤©)"
  LIFECYCLE_OUT=$(npx wrangler r2 bucket lifecycle add stratum-cache "cache-gc" \
    --expire-days 90 2>&1) || true
  if echo "$LIFECYCLE_OUT" | grep -q "Rule IDs must be unique"; then
    log "R2 lifecycle è§„åˆ™å·²å­˜åœ¨"
  else
    log "R2 lifecycle è§„åˆ™å·²è®¾ç½®"
  fi

  # åº”ç”¨æ•°æ®åº“è¿ç§»
  step "åº”ç”¨ D1 æ•°æ®åº“è¿ç§»"
  if npx wrangler d1 migrations apply stratum-db --remote 2>&1; then
    log "æ•°æ®åº“è¿ç§»å·²åº”ç”¨"
  else
    warn "æ•°æ®åº“è¿ç§»å¯èƒ½å¤±è´¥ (å¦‚æžœå·²æ˜¯æœ€æ–°åˆ™å¯å¿½ç•¥)"
  fi

  # è®¾ç½® secrets
  step "é…ç½® Worker secrets"
  echo "$TG_BOT_TOKEN" | npx wrangler secret put TG_BOT_TOKEN 2>&1 || true
  echo "$DEFAULT_CHAT_ID" | npx wrangler secret put DEFAULT_CHAT_ID 2>&1 || true
  if [ -n "${VPS_URL:-}" ]; then
    echo "$VPS_URL" | npx wrangler secret put VPS_URL 2>&1 || true
  fi
  echo "$VPS_SECRET" | npx wrangler secret put VPS_SECRET 2>&1 || true
  if [ -n "${SSE_MASTER_KEY:-}" ]; then
    echo "$SSE_MASTER_KEY" | npx wrangler secret put SSE_MASTER_KEY 2>&1 || true
  fi
  if [ -n "${TG_ADMIN_IDS:-}" ]; then
    echo "$TG_ADMIN_IDS" | npx wrangler secret put TG_ADMIN_IDS 2>&1 || true
  fi
  log "Secrets é…ç½®å®Œæˆ"

  # éƒ¨ç½² Worker
  step "éƒ¨ç½² Worker"
  if ! DEPLOY_OUTPUT=$(npx wrangler deploy 2>&1); then
    err "Worker éƒ¨ç½²å¤±è´¥:"
    echo "$DEPLOY_OUTPUT" >&2
    exit 1
  fi
  echo "$DEPLOY_OUTPUT"

  WORKER_URL=$(echo "$DEPLOY_OUTPUT" | grep -oE 'https://[^ ]+\.workers\.dev' | head -1) || WORKER_URL=""
  if [ -n "$WORKER_URL" ]; then
    log "Worker éƒ¨ç½²æˆåŠŸ: $WORKER_URL"
  else
    log "Worker éƒ¨ç½²å®Œæˆ"
  fi

  # è®¾ç½® WORKER_URL secret
  EFFECTIVE_URL="${CF_CUSTOM_DOMAIN:+https://$CF_CUSTOM_DOMAIN}"
  EFFECTIVE_URL="${EFFECTIVE_URL:-$WORKER_URL}"
  if [ -n "$EFFECTIVE_URL" ]; then
    step "è®¾ç½® WORKER_URL secret"
    echo "$EFFECTIVE_URL" | npx wrangler secret put WORKER_URL 2>&1 || true
    log "WORKER_URL = $EFFECTIVE_URL"
  fi

  # æ³¨å†Œ Telegram Webhook
  if [ -n "$EFFECTIVE_URL" ]; then
    step "æ³¨å†Œ Telegram Bot Webhook"
    WEBHOOK_URL="$EFFECTIVE_URL/bot/webhook"
    WEBHOOK_SECRET=$(TG_BOT_TOKEN="$TG_BOT_TOKEN" derive_webhook_secret)
    WEBHOOK_RES=$(_fetch -X POST \
      "https://api.telegram.org/bot${TG_BOT_TOKEN}/setWebhook" \
      -H "Content-Type: application/json" \
      -d "{\"url\":\"${WEBHOOK_URL}\",\"secret_token\":\"${WEBHOOK_SECRET}\"}" 2>&1) || true
    if echo "$WEBHOOK_RES" | grep -q '"ok":true'; then
      log "Webhook æ³¨å†ŒæˆåŠŸ: $WEBHOOK_URL"
    else
      warn "Webhook æ³¨å†Œå¤±è´¥"
      if [ -n "$WEBHOOK_RES" ]; then
        warn "  å“åº”: $WEBHOOK_RES"
      else
        warn "  æ— æ³•è¿žæŽ¥ api.telegram.org (ç½‘ç»œé—®é¢˜?)"
      fi
    fi
  fi

  # è‡ªå®šä¹‰åŸŸåå·²é€šè¿‡ wrangler.toml routes è‡ªåŠ¨é…ç½®ï¼Œæ— éœ€æ‰‹åŠ¨æ“ä½œ
}

# ============================================================
# Cloudflare Tunnel è‡ªåŠ¨åˆ›å»º
# åˆ›å»ºåŽè‡ªåŠ¨å†™å…¥ CF_TUNNEL_TOKEN åˆ° .env (æŒ‚è½½ volume æ—¶å¯æŒä¹…åŒ–)
# ============================================================
setup_tunnel() {
  step "é…ç½® Cloudflare Tunnel"

  if [ -n "${CF_TUNNEL_TOKEN:-}" ]; then
    log "CF_TUNNEL_TOKEN å·²è®¾ç½®, è·³è¿‡ tunnel åˆ›å»º"
    return 0
  fi

  if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
    warn "è·³è¿‡ tunnel è‡ªåŠ¨åˆ›å»º (éœ€è¦ CLOUDFLARE_API_TOKEN)"
    warn "æ‰‹åŠ¨åˆ›å»º: CF Dashboard > Zero Trust > Tunnels, ç„¶åŽè®¾ç½® CF_TUNNEL_TOKEN"
    return 1
  fi

  if [ -z "${CF_CUSTOM_DOMAIN:-}" ]; then
    warn "éœ€è¦ CF_CUSTOM_DOMAIN æ¥ä¸º tunnel åˆ†é…åŸŸå"
    warn "æˆ–åœ¨ CF Dashboard > Zero Trust > Tunnels æ‰‹åŠ¨åˆ›å»ºåŽè®¾ç½® CF_TUNNEL_TOKEN"
    return 1
  fi

  local CF_API="https://api.cloudflare.com/client/v4"
  local AUTH_HEADER="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}"

  # èŽ·å– Account ID
  local ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-${CF_ACCOUNT_ID:-}}"
  if [ -z "$ACCOUNT_ID" ]; then
    step "èŽ·å– Cloudflare Account ID"
    ACCOUNT_ID=$(_fetch "$CF_API/accounts" -H "$AUTH_HEADER" | \
      node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.result?.[0]?.id||'')" 2>/dev/null) || ACCOUNT_ID=""
    if [ -z "$ACCOUNT_ID" ]; then
      warn "æ— æ³•èŽ·å– Account ID, è¯·åœ¨ .env ä¸­è®¾ç½® CF_ACCOUNT_ID"
      return 1
    fi
    log "Account ID: ${ACCOUNT_ID:0:8}..."
  fi

  # æ£€æŸ¥æ˜¯å¦å·²æœ‰åŒå tunnel
  step "æ£€æŸ¥çŽ°æœ‰ tunnel"
  local LIST_RESP=""
  LIST_RESP=$(_fetch "$CF_API/accounts/$ACCOUNT_ID/cfd_tunnel?name=Stratum&is_deleted=false" \
    -H "$AUTH_HEADER" 2>&1) || true
  local EXISTING=""
  EXISTING=$(echo "$LIST_RESP" | \
    node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); const t=d.result?.find(t=>t.name==='Stratum'); console.log(t?.id||'')" 2>/dev/null) || EXISTING=""

  local TUNNEL_ID=""
  local TUNNEL_TOKEN_FROM_CREATE=""
  if [ -n "$EXISTING" ]; then
    TUNNEL_ID="$EXISTING"
    log "å·²æœ‰ tunnel stratum: ${TUNNEL_ID:0:8}..."
  else
    # æ£€æŸ¥ API æƒé™ (list å¤±è´¥è¯´æ˜Ž token æ— æƒé™)
    if echo "$LIST_RESP" | grep -q '"success":false'; then
      warn "API Token ç¼ºå°‘ Cloudflare Tunnel æƒé™"
      warn "è¯·åœ¨ CF Dashboard > æˆ‘çš„ä¸ªäººèµ„æ–™ > API ä»¤ç‰Œ ä¸­æ·»åŠ :"
      warn "  Account | Cloudflare Tunnel | Edit"
      warn "å“åº”: $LIST_RESP"
      return 1
    fi

    step "åˆ›å»º Cloudflare Tunnel: Stratum"
    local CREATE_RESP=""
    CREATE_RESP=$(_fetch -X POST "$CF_API/accounts/$ACCOUNT_ID/cfd_tunnel" \
      -H "$AUTH_HEADER" \
      -H "Content-Type: application/json" \
      -d '{"name":"Stratum","config_src":"cloudflare"}' 2>&1) || true
    TUNNEL_ID=$(echo "$CREATE_RESP" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.result?.id||'')" 2>/dev/null) || TUNNEL_ID=""
    # åˆ›å»ºå“åº”ç›´æŽ¥åŒ…å« tokenï¼Œæ— éœ€å•ç‹¬èŽ·å–
    TUNNEL_TOKEN_FROM_CREATE=$(echo "$CREATE_RESP" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.result?.token||'')" 2>/dev/null) || TUNNEL_TOKEN_FROM_CREATE=""
    if [ -z "$TUNNEL_ID" ]; then
      warn "tunnel åˆ›å»ºå¤±è´¥"
      if echo "$CREATE_RESP" | grep -q '"code":10000'; then
        warn "API Token æƒé™ä¸è¶³ï¼Œéœ€è¦ Cloudflare Tunnel: Edit"
      fi
      [ -n "$CREATE_RESP" ] && warn "å“åº”: $CREATE_RESP"
      return 1
    fi
    log "Tunnel åˆ›å»ºæˆåŠŸ: ${TUNNEL_ID:0:8}..."
  fi

  # é…ç½® tunnel ingress
  local TUNNEL_HOSTNAME="vps.${CF_CUSTOM_DOMAIN}"
  step "é…ç½® tunnel ingress: $TUNNEL_HOSTNAME -> processor:3000"
  _fetch -X PUT "$CF_API/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -d "{\"config\":{\"ingress\":[{\"hostname\":\"$TUNNEL_HOSTNAME\",\"service\":\"http://processor:3000\",\"originRequest\":{\"noTLSVerify\":true}},{\"service\":\"http_status:404\"}]}}" >/dev/null 2>&1 || true
  log "Tunnel ingress å·²é…ç½®"

  # åˆ›å»º DNS CNAME
  step "é…ç½® DNS: $TUNNEL_HOSTNAME -> tunnel"
  local ZONE_ID=""
  local DOMAIN="$CF_CUSTOM_DOMAIN"
  while [ -n "$DOMAIN" ] && [ -z "$ZONE_ID" ]; do
    ZONE_ID=$(_fetch "$CF_API/zones?name=$DOMAIN" -H "$AUTH_HEADER" | \
      node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.result?.[0]?.id||'')" 2>/dev/null) || ZONE_ID=""
    if [ -z "$ZONE_ID" ]; then
      DOMAIN="${DOMAIN#*.}"
      if [[ "$DOMAIN" != *.* ]]; then break; fi
    fi
  done

  if [ -n "$ZONE_ID" ]; then
    local EXISTING_DNS
    EXISTING_DNS=$(_fetch "$CF_API/zones/$ZONE_ID/dns_records?name=$TUNNEL_HOSTNAME&type=CNAME" \
      -H "$AUTH_HEADER" | \
      node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.result?.[0]?.id||'')" 2>/dev/null) || EXISTING_DNS=""

    if [ -n "$EXISTING_DNS" ]; then
      _fetch -X PUT "$CF_API/zones/$ZONE_ID/dns_records/$EXISTING_DNS" \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        -d "{\"type\":\"CNAME\",\"name\":\"$TUNNEL_HOSTNAME\",\"content\":\"$TUNNEL_ID.cfargotunnel.com\",\"proxied\":true}" >/dev/null 2>&1 || true
      log "DNS è®°å½•å·²æ›´æ–°: $TUNNEL_HOSTNAME"
    else
      _fetch -X POST "$CF_API/zones/$ZONE_ID/dns_records" \
        -H "$AUTH_HEADER" \
        -H "Content-Type: application/json" \
        -d "{\"type\":\"CNAME\",\"name\":\"$TUNNEL_HOSTNAME\",\"content\":\"$TUNNEL_ID.cfargotunnel.com\",\"proxied\":true}" >/dev/null 2>&1 || true
      log "DNS è®°å½•å·²åˆ›å»º: $TUNNEL_HOSTNAME"
    fi
  else
    warn "æ— æ³•æ‰¾åˆ°åŸŸå $CF_CUSTOM_DOMAIN å¯¹åº”çš„ CF Zone"
    warn "è¯·æ‰‹åŠ¨æ·»åŠ  DNS CNAME: $TUNNEL_HOSTNAME -> $TUNNEL_ID.cfargotunnel.com"
  fi

  # èŽ·å– tunnel token (ä¼˜å…ˆä½¿ç”¨åˆ›å»ºå“åº”ä¸­çš„ token)
  if [ -n "$TUNNEL_TOKEN_FROM_CREATE" ]; then
    CF_TUNNEL_TOKEN="$TUNNEL_TOKEN_FROM_CREATE"
    log "Tunnel token å·²ä»Žåˆ›å»ºå“åº”èŽ·å–"
  else
    step "èŽ·å– tunnel connector token"
    local TOKEN_RESP=""
    TOKEN_RESP=$(_fetch "$CF_API/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/token" \
      -H "$AUTH_HEADER" 2>&1) || true
    CF_TUNNEL_TOKEN=$(echo "$TOKEN_RESP" | node -e "const d=JSON.parse(require('fs').readFileSync('/dev/stdin','utf8')); console.log(d.result||'')" 2>/dev/null) || CF_TUNNEL_TOKEN=""
    if [ -z "$CF_TUNNEL_TOKEN" ]; then
      warn "æ— æ³•èŽ·å– tunnel token"
      [ -n "$TOKEN_RESP" ] && warn "å“åº”: $TOKEN_RESP"
      warn "è¯·åœ¨ CF Dashboard > Zero Trust > Tunnels > Stratum ä¸­èŽ·å– token"
      return 1
    fi
    log "Tunnel token å·²èŽ·å–"
  fi

  # å†™å…¥ .env (volume æŒ‚è½½æ—¶è‡ªåŠ¨æŒä¹…åŒ–åˆ°å®¿ä¸»æœº)
  persist_env CF_TUNNEL_TOKEN "$CF_TUNNEL_TOKEN"
  log "CF_TUNNEL_TOKEN å·²å†™å…¥ .env"

  # è®¾ç½® VPS_URL ä¸º tunnel åŸŸå
  VPS_URL="https://$TUNNEL_HOSTNAME"
  persist_env VPS_URL "$VPS_URL"
  log "VPS_URL å·²è®¾ä¸º: $VPS_URL"

  # åŒæ­¥åˆ° Worker secrets
  echo "$VPS_URL" | npx wrangler secret put VPS_URL 2>&1 || true
  log "VPS_URL secret å·²æ›´æ–°"
}

# ============================================================
# Docker å…¨è‡ªåŠ¨ç¼–æŽ’ (å®¿ä¸»æœºæ‰§è¡Œ)
# ============================================================
deploy_docker() {
  # æ£€æŸ¥ CLOUDFLARE_API_TOKEN (Docker æ¨¡å¼å¿…éœ€)
  if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
    err "Docker éƒ¨ç½²éœ€è¦ CLOUDFLARE_API_TOKEN"
    err "è¯·åœ¨ .env ä¸­è®¾ç½®ï¼Œæˆ–ä½¿ç”¨æœ¬åœ° wrangler éƒ¨ç½²:"
    err "  npm install && npx wrangler login && npx wrangler deploy"
    exit 1
  fi

  # é€ä¸ªæž„å»ºé•œåƒ (é¿å… BuildKit å¹¶è¡Œæž„å»º bug)
  step "æž„å»º Docker é•œåƒ (deploy)"
  if ! docker compose build deploy; then
    err "deploy é•œåƒæž„å»ºå¤±è´¥"
    exit 1
  fi

  step "æž„å»º Docker é•œåƒ (processor)"
  if ! docker compose build processor; then
    err "processor é•œåƒæž„å»ºå¤±è´¥"
    exit 1
  fi

  # é€šè¿‡ deploy å®¹å™¨éƒ¨ç½² CF Worker + é…ç½® Tunnel
  # .env æ–‡ä»¶ä»¥ volume æŒ‚è½½åˆ°å®¹å™¨ï¼Œå®¹å™¨å†…ä¿®æ”¹ (CF_TUNNEL_TOKEN ç­‰) è‡ªåŠ¨æŒä¹…åŒ–
  step "éƒ¨ç½² CF Worker"
  if ! docker compose --profile deploy run --rm -T deploy; then
    err "CF Worker éƒ¨ç½²å¤±è´¥, è¯·æ£€æŸ¥æ—¥å¿—"
    exit 1
  fi

  # é‡æ–°åŠ è½½ .env (å®¹å™¨å¯èƒ½å†™å…¥äº† CF_TUNNEL_TOKEN, VPS_URL, VPS_SECRET)
  set -a
  source .env
  set +a

  # å¯åŠ¨å¸¸é©»æœåŠ¡
  step "å¯åŠ¨æœåŠ¡"
  COMPOSE_PROFILES=""
  if [ -n "${CF_TUNNEL_TOKEN:-}" ]; then
    COMPOSE_PROFILES="$COMPOSE_PROFILES --profile tunnel"
  fi
  if [ "$HAS_LOCAL_API" -eq 1 ]; then
    COMPOSE_PROFILES="$COMPOSE_PROFILES --profile localapi"
  fi

  if [ -n "$COMPOSE_PROFILES" ]; then
    docker compose $COMPOSE_PROFILES up -d
  else
    docker compose up -d processor
  fi

  # çŠ¶æ€æç¤º
  if [ -n "${CF_TUNNEL_TOKEN:-}" ] && [ "$HAS_LOCAL_API" -eq 1 ]; then
    log "processor + tunnel + telegram-bot-api å·²å¯åŠ¨ (2GB æ–‡ä»¶æ”¯æŒ)"
  elif [ -n "${CF_TUNNEL_TOKEN:-}" ]; then
    log "processor + tunnel å·²å¯åŠ¨"
    warn "æœªå¯ç”¨ Local Bot API, æ–‡ä»¶å¤§å°é™åˆ¶ 20MB"
  elif [ "$HAS_LOCAL_API" -eq 1 ]; then
    warn "æœªé…ç½® Cloudflare Tunnel (ç¼ºå°‘ CF_CUSTOM_DOMAIN æˆ– API Token æƒé™ä¸è¶³)"
    warn "processor + telegram-bot-api å·²å¯åŠ¨ä½†å¤–éƒ¨æ— æ³•è®¿é—®"
  else
    warn "æœªé…ç½® Cloudflare Tunnel (ç¼ºå°‘ CF_CUSTOM_DOMAIN æˆ– API Token æƒé™ä¸è¶³)"
    warn "processor å·²å¯åŠ¨ä½†å¤–éƒ¨æ— æ³•è®¿é—®"
    warn "å¦‚éœ€ tunnelï¼Œè¯·è®¾ç½® CF_CUSTOM_DOMAIN åŽé‡æ–°è¿è¡Œ ./deploy.sh"
  fi

  # ç­‰å¾… processor å°±ç»ª
  step "æ£€æŸ¥ processor å¥åº·çŠ¶æ€"
  sleep 2
  PROC_STATE=$(docker compose ps processor --format '{{.State}}' 2>/dev/null) || PROC_STATE=""
  if [ "$PROC_STATE" = "running" ]; then
    log "processor è¿è¡Œæ­£å¸¸"
  elif docker compose ps processor 2>/dev/null | grep -qiE 'running|up'; then
    log "processor è¿è¡Œæ­£å¸¸"
  else
    warn "processor çŠ¶æ€: ${PROC_STATE:-æœªçŸ¥}"
    warn "æŸ¥çœ‹æ—¥å¿—: docker compose logs processor"
  fi
}

# ============================================================
# VPS SSH éƒ¨ç½² (éž Docker æ¨¡å¼)
# ============================================================
deploy_vps() {
  step "éƒ¨ç½² VPS å¤„ç†æœåŠ¡"

  if [ -z "${VPS_SSH:-}" ]; then
    err "VPS éƒ¨ç½²éœ€è¦è®¾ç½® VPS_SSH (å¦‚ root@1.2.3.4)"
    exit 1
  fi

  VPS_DIR="${VPS_DEPLOY_DIR:-/opt/stratum}"

  # æµ‹è¯• SSH è¿žæŽ¥
  step "æµ‹è¯• SSH è¿žæŽ¥: $VPS_SSH"
  if ! ssh -o ConnectTimeout=10 -o BatchMode=yes "$VPS_SSH" "echo ok" &>/dev/null; then
    err "SSH è¿žæŽ¥å¤±è´¥: $VPS_SSH"
    err "è¯·ç¡®ä¿:"
    err "  1. SSH å¯†é’¥å·²é…ç½®"
    err "  2. ç›®æ ‡ä¸»æœºå¯è¾¾"
    err "  3. VPS_SSH æ ¼å¼æ­£ç¡® (å¦‚ root@1.2.3.4)"
    exit 1
  fi
  log "SSH è¿žæŽ¥æ­£å¸¸"

  # æ£€æŸ¥ Docker
  step "æ£€æŸ¥ VPS Docker çŽ¯å¢ƒ"
  if ! ssh "$VPS_SSH" "command -v docker &>/dev/null && docker compose version &>/dev/null"; then
    warn "VPS ä¸Šæœªæ£€æµ‹åˆ° Docker, æ­£åœ¨å®‰è£…..."
    ssh "$VPS_SSH" bash <<'INSTALL_DOCKER'
      curl -fsSL https://get.docker.com | sh
      systemctl enable docker
      systemctl start docker
INSTALL_DOCKER
    log "Docker å®‰è£…å®Œæˆ"
  else
    log "Docker çŽ¯å¢ƒæ­£å¸¸"
  fi

  # åˆ›å»ºéƒ¨ç½²ç›®å½•
  ssh "$VPS_SSH" "mkdir -p \"$VPS_DIR\""

  # ä¸Šä¼ æ–‡ä»¶
  step "ä¸Šä¼ å¤„ç†æœåŠ¡æ–‡ä»¶"
  rsync -avz --delete \
    processor/package.json \
    processor/server.js \
    processor/Dockerfile \
    docker-compose.yml \
    "$VPS_SSH:$VPS_DIR/"

  # ä¸Šä¼  .env
  step "é…ç½® VPS çŽ¯å¢ƒå˜é‡"
  ssh "$VPS_SSH" "cat > \"$VPS_DIR/.env\"" <<ENV_EOF
TG_BOT_TOKEN=$TG_BOT_TOKEN
VPS_SECRET=${VPS_SECRET:-}
DEFAULT_CHAT_ID=$DEFAULT_CHAT_ID
TG_LOCAL_API=${TG_LOCAL_API:-https://api.telegram.org}
TELEGRAM_API_ID=${TELEGRAM_API_ID:-}
TELEGRAM_API_HASH=${TELEGRAM_API_HASH:-}
PORT=${VPS_PORT:-3000}
ENV_EOF
  log "VPS çŽ¯å¢ƒå˜é‡å·²é…ç½®"

  # æž„å»ºå¹¶å¯åŠ¨
  step "æž„å»ºå¹¶å¯åŠ¨æœåŠ¡"
  local VPS_PROFILES=""
  if [ "$HAS_LOCAL_API" -eq 1 ]; then
    VPS_PROFILES="--profile localapi"
  fi

  ssh "$VPS_SSH" bash <<DEPLOY_CMD
    cd "$VPS_DIR"
    docker compose down 2>/dev/null || true
    docker compose build --no-cache
    docker compose $VPS_PROFILES up -d
    echo "--- æœåŠ¡çŠ¶æ€ ---"
    docker compose $VPS_PROFILES ps
DEPLOY_CMD
  log "VPS å¤„ç†æœåŠ¡å·²å¯åŠ¨"

  # å¥åº·æ£€æŸ¥
  step "VPS å¥åº·æ£€æŸ¥"
  sleep 3
  if ssh "$VPS_SSH" "curl -sf -o /dev/null http://127.0.0.1:${VPS_PORT:-3000}/api/jobs/nonexistent 2>/dev/null"; then
    log "VPS å¤„ç†æœåŠ¡è¿è¡Œæ­£å¸¸"
  else
    if ssh "$VPS_SSH" "curl -sf -w '%{http_code}' -o /dev/null http://127.0.0.1:${VPS_PORT:-3000}/api/jobs/test 2>/dev/null" | grep -qE '40[0-9]'; then
      log "VPS å¤„ç†æœåŠ¡è¿è¡Œæ­£å¸¸ (API å“åº”ä¸­)"
    else
      warn "VPS æœåŠ¡å¯èƒ½æœªå°±ç»ª, è¯·æ£€æŸ¥æ—¥å¿—:"
      warn "  ssh $VPS_SSH 'cd $VPS_DIR && docker compose logs'"
    fi
  fi
}

# ============================================================
# éƒ¨ç½²å®Œæˆæ‘˜è¦
# ============================================================
print_summary() {
  echo ""
  echo -e "${GREEN}============================================================${NC}"
  echo -e "${GREEN}  Stratum éƒ¨ç½²å®Œæˆ${NC}"
  echo -e "${GREEN}============================================================${NC}"
  echo ""

  if [ -n "${EFFECTIVE_URL:-}" ]; then
    echo -e "  è®¿é—®åœ°å€:    ${CYAN}${EFFECTIVE_URL}${NC}"
    echo -e "  Mini App:    ${CYAN}${EFFECTIVE_URL}/miniapp${NC}"
  elif [ -n "${WORKER_URL:-}" ]; then
    echo -e "  Worker URL:  ${CYAN}${WORKER_URL}${NC}"
    echo -e "  Mini App:    ${CYAN}${WORKER_URL}/miniapp${NC}"
  fi

  if [ -n "${VPS_URL:-}" ]; then
    echo -e "  Processor:   ${CYAN}${VPS_URL}${NC} (via Cloudflare Tunnel)"
  fi

  echo ""
  echo -e "  S3 å‡­æ®è¯·åœ¨ Telegram Mini App çš„ ${CYAN}Keys${NC} æ ‡ç­¾é¡µä¸­åˆ›å»º"
  echo ""
  echo "  å¿«é€ŸéªŒè¯:"
  echo "    rclone mkdir stratum:photos"
  echo "    rclone copy ./test.jpg stratum:photos/"
  echo "    rclone ls stratum:photos/"
  echo ""
  echo "  å¸¸ç”¨æ“ä½œ:"
  echo "    æ›´æ–°ä»£ç åŽé‡æ–°éƒ¨ç½²:  git pull && ./deploy.sh"
  echo "    ä»…é‡å¯æœåŠ¡:          docker compose --profile tunnel restart"
  echo "    æŸ¥çœ‹æ—¥å¿—:            docker compose --profile tunnel logs -f"
  echo "    åœæ­¢æ‰€æœ‰æœåŠ¡:        docker compose --profile tunnel down"
  echo ""
}

# ============================================================
# ä¸»æµç¨‹
# ============================================================
echo -e "${CYAN}"
echo "  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”"
echo "  â”‚         Stratum ä¸€é”®éƒ¨ç½²               â”‚"
echo "  â”‚   Telegram-backed S3 Storage         â”‚"
echo "  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜"
echo -e "${NC}"

validate_required

if [ "$IN_CONTAINER" -eq 1 ]; then
  # ============================================
  # å®¹å™¨å†…: ä»…éƒ¨ç½² CF Worker + é…ç½® tunnel
  # ============================================
  deploy_cf
  setup_tunnel || true
  print_summary
  exit 0
fi

# ============================================
# å®¿ä¸»æœº
# ============================================
case "${1:-}" in
  --vps)
    # ä¼ ç»Ÿ SSH æ¨¡å¼: æœ¬åœ° wrangler éƒ¨ç½² Worker + SSH éƒ¨ç½² VPS
    deploy_cf
    deploy_vps
    ;;
  *)
    # è‡ªåŠ¨æ£€æµ‹
    if command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
      # Docker å…¨è‡ªåŠ¨ç¼–æŽ’
      deploy_docker
    else
      # æ—  Docker: æœ¬åœ° wrangler éƒ¨ç½² Worker
      deploy_cf
    fi
    ;;
esac

print_summary
