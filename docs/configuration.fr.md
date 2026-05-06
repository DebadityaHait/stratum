# RÃ©fÃ©rence de configuration

[English](configuration.md) | [ä¸­æ–‡](configuration.zh.md) | [æ—¥æœ¬èªž](configuration.ja.md) | [FranÃ§ais](configuration.fr.md)

## Variables d'environnement

Toute la configuration se fait via des variables d'environnement. Pour le dÃ©ploiement Docker, dÃ©finissez-les dans `.env`. Pour le dÃ©ploiement manuel, elles sont lues depuis `.env` par `deploy.sh` et envoyÃ©es en tant que secrets Cloudflare.

### Requises

| Variable | Description | Exemple |
|----------|-------------|---------|
| `TG_BOT_TOKEN` | Token API du bot Telegram, obtenu via @BotFather | `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11` |
| `DEFAULT_CHAT_ID` | Chat ID du groupe/supergroupe Telegram | `-1001234567890` |

### RecommandÃ©es

| Variable | Description | Exemple |
|----------|-------------|---------|
| `TG_ADMIN_IDS` | IDs utilisateur Telegram autorisÃ©s (sÃ©parÃ©s par virgule). Si non dÃ©fini, tout le monde peut utiliser le bot. | `123456789,987654321` |

Pour trouver votre ID Telegram, envoyez un message Ã  [@userinfobot](https://t.me/userinfobot).

### GÃ©nÃ©rÃ©es automatiquement (pas besoin de les dÃ©finir)

| Variable | Description | GÃ©nÃ©rÃ©e par |
|----------|-------------|-------------|
| `VPS_SECRET` | Secret d'authentification entre le Worker et le processeur | `deploy.sh` (chaÃ®ne alÃ©atoire de 48 caractÃ¨res) |
| `SSE_MASTER_KEY` | ClÃ© Base64 pour le chiffrement SSE-S3 cÃ´tÃ© serveur. GÃ©nÃ©rÃ© par deploy.sh. | `deploy.sh` |
| Identifiants S3 | ClÃ© d'accÃ¨s + clÃ© secrÃ¨te pour l'authentification API S3 | `deploy.sh` (crÃ©Ã©s dans la table D1 `credentials`) |
| Secret webhook | Secret de vÃ©rification du webhook Telegram | DÃ©rivÃ© de `TG_BOT_TOKEN` via HMAC-SHA256 |

Les identifiants S3 sont affichÃ©s une seule fois lors du dÃ©ploiement. GÃ©rez-les ensuite dans l'onglet **Keys** de la Mini App (crÃ©er, rÃ©voquer, dÃ©finir des permissions par bucket).

### Cloudflare (dÃ©ploiement Docker)

| Variable | Description | Exemple |
|----------|-------------|---------|
| `CLOUDFLARE_API_TOKEN` | Token API CF (requis pour Docker, optionnel pour le manuel) | `cf-api-token...` |
| `CF_ACCOUNT_ID` | Identifiant du compte CF (dÃ©tectÃ© automatiquement si non dÃ©fini) | `abc123def456` |
| `CF_CUSTOM_DOMAIN` | Domaine personnalisÃ© pour le Worker (active aussi la crÃ©ation automatique du tunnel) | `s3.example.com` |
| `CF_TUNNEL_TOKEN` | Token du connecteur Cloudflare Tunnel (crÃ©Ã© automatiquement avec CF_CUSTOM_DOMAIN, ou Ã  dÃ©finir manuellement) | `eyJhIjo...` |

Permissions du token API : Workers Scripts:Edit, D1:Edit, R2:Edit, Account Settings:Read. Ajoutez Cloudflare Tunnel:Edit et DNS:Edit pour la crÃ©ation automatique du tunnel.

### VPS / Processeur (optionnel)

| Variable | Description | Valeur par dÃ©faut |
|----------|-------------|-------------------|
| `VPS_SSH` | ChaÃ®ne de connexion SSH pour le dÃ©ploiement VPS | -- |
| `VPS_DEPLOY_DIR` | RÃ©pertoire de dÃ©ploiement sur le VPS | `/opt/stratum` |
| `VPS_PORT` | Port du service processeur | `3000` |
| `VPS_URL` | URL publique du processeur VPS (dÃ©finie automatiquement avec le tunnel) | -- |
| `VPS_SECRET` | Secret d'authentification entre le Worker et le processeur (gÃ©nÃ©rÃ© automatiquement) | -- |
| `TELEGRAM_API_ID` | ID API Telegram pour l'API Bot locale (voir ci-dessous). Active le support de fichiers 2 Go. | -- |
| `TELEGRAM_API_HASH` | Hash API Telegram pour l'API Bot locale (voir ci-dessous) | -- |

**Obtenir TELEGRAM_API_ID et TELEGRAM_API_HASH :**

1. Allez sur https://my.telegram.org et connectez-vous avec votre numÃ©ro de tÃ©lÃ©phone
2. Cliquez sur "API development tools"
3. Remplissez le formulaire pour crÃ©er une application (ces champs sont des mÃ©tadonnÃ©es et n'affectent pas le fonctionnement) :
   - **App title** : n'importe quoi, par ex. `Stratum`
   - **Short name** : 5-32 caractÃ¨res alphanumÃ©riques, par ex. `stratum`
   - **URL** : laisser vide
   - **Platform** : sÃ©lectionner `Other`
   - **Description** : laisser vide
4. AprÃ¨s la crÃ©ation, copiez `api_id` (nombre) et `api_hash` (chaÃ®ne) dans votre `.env`

### Runtime du Worker

Ces valeurs sont dÃ©finies dans `wrangler.toml` en tant que vars ou bindings :

| Variable | Description | Valeur par dÃ©faut |
|----------|-------------|-------------------|
| `S3_REGION` | RÃ©gion AWS dÃ©clarÃ©e | `us-east-1` |
| `WORKER_URL` | URL publique du Worker (dÃ©finie automatiquement par deploy.sh) | -- |

### Bindings D1 et R2

ConfigurÃ©s dans `wrangler.toml` :

```toml
[[d1_databases]]
binding = "DB"
database_name = "stratum-db"
database_id = "your-database-id"

[[r2_buckets]]
binding = "CACHE"
bucket_name = "stratum-cache"
```

## wrangler.toml

Sections principales de configuration :

```toml
name = "stratum"
main = "src/index.ts"
compatibility_date = "2026-03-15"

[vars]
S3_REGION = "us-east-1"

[triggers]
crons = ["0 */6 * * *"]  # Maintenance toutes les 6 heures
```

### TÃ¢ches de maintenance cron

Le gestionnaire planifiÃ© s'exÃ©cute toutes les 6 heures et effectue :

1. Nettoyage des tokens de partage expirÃ©s
2. Nettoyage des tokens de partage orphelins (objet supprimÃ© mais partage encore prÃ©sent)
3. Nettoyage des uploads multipart obsolÃ¨tes (plus de 24 heures)
4. Nettoyage des chunks orphelins
5. Nettoyage des enregistrements de tentatives de mot de passe expirÃ©s
6. VÃ©rification de cohÃ©rence (Ã©chantillonnage dynamique ~2% des objets, limitÃ© Ã  [5, 50], vÃ©rification de l'accÃ¨s aux fichiers Telegram)
7. Nettoyage du cache R2 (Ã©viction des objets supprimÃ©s de D1)
8. RÃ¨gles de cycle de vie (suppression des objets expirÃ©s selon la configuration de cycle de vie du bucket)

## Notes de sÃ©curitÃ©

- Les **identifiants S3** sont stockÃ©s dans D1 et utilisÃ©s pour la vÃ©rification de signature AWS SigV4. Des valeurs alÃ©atoires robustes sont gÃ©nÃ©rÃ©es automatiquement. GÃ©rez-les dans l'onglet Keys de la Mini App.
- Le **secret webhook** est dÃ©rivÃ© de maniÃ¨re dÃ©terministe de `TG_BOT_TOKEN` via HMAC-SHA256. Aucune variable d'environnement sÃ©parÃ©e n'est nÃ©cessaire.
- Le **VPS_SECRET** authentifie la communication entre le Worker et le processeur. GÃ©nÃ©rÃ© automatiquement s'il n'est pas dÃ©fini.
- Le **CLOUDFLARE_API_TOKEN** dispose d'un accÃ¨s en Ã©criture Ã  votre compte CF. Ne le commitez jamais dans git.
- Le fichier `.env` est inclus dans `.gitignore` et `.dockerignore` par dÃ©faut.

## Limites de requÃªtes

### Offre gratuite Cloudflare

| Ressource | Limite |
|-----------|--------|
| RequÃªtes Worker | 100 000/jour |
| Lectures D1 | 5 000 000/jour |
| Ã‰critures D1 | 100 000/jour |
| RequÃªtes D1 par invocation | 50 |
| OpÃ©rations R2 Classe A (Ã©criture) | 1 000 000/mois |
| OpÃ©rations R2 Classe B (lecture) | 10 000 000/mois |
| Stockage R2 | 10 Go |

### API Bot Telegram

| Ressource | Limite |
|-----------|--------|
| Messages par canal | ~20/minute |
| DÃ©bit global de messages | ~30/seconde |
| TÃ©lÃ©chargement de fichier | 20 Mo (API Bot) / 2 Go (API Bot locale) |
| Envoi de fichier | 20 Mo (API Bot, alignÃ© sur la limite de tÃ©lÃ©chargement) / 2 Go (API Bot locale) |
