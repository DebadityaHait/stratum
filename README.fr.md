# Stratum

**Stockage compatible S3, propulsÃ© par Telegram, sur Cloudflare Workers**

[English](README.md) | [ä¸­æ–‡](README.zh.md) | [æ—¥æœ¬èªž](README.ja.md) | [FranÃ§ais](README.fr.md)

---

Stratum transforme Telegram en backend de stockage objet compatible S3. Les fichiers sont stockÃ©s sous forme de messages Telegram, les mÃ©tadonnÃ©es sont dans Cloudflare D1, et le tout fonctionne sur Cloudflare Workers sans dÃ©pendance runtime.

## FonctionnalitÃ©s

- **API compatible S3** -- 27 opÃ©rations dont l'upload multipart, les URL prÃ©signÃ©es et les requÃªtes conditionnelles
- **Stockage gratuit illimitÃ©** -- Telegram fournit la couche de stockage gratuitement
- **Cache Ã  trois niveaux** -- CF CDN (L1) -> R2 (L2) -> Telegram (L3) pour des lectures rapides
- **Bot Telegram** -- GÃ©rez fichiers, buckets et partages directement depuis Telegram
- **Mini App** -- Interface web complÃ¨te dans Telegram avec navigateur de fichiers, uploads et gestion des partages
- **Partage de fichiers** -- Liens de partage avec protection par mot de passe, expiration, limite de tÃ©lÃ©chargements et aperÃ§u en ligne
- **Chiffrement cÃ´tÃ© serveur** -- SSE-C (clÃ©s fournies par le client) et SSE-S3 (clÃ©s gÃ©rÃ©es par le serveur) avec AES-256-GCM
- **Support gros fichiers** -- Fichiers jusqu'Ã  2 Go via proxy VPS optionnel avec Local Bot API
- **Traitement mÃ©dia** -- Conversion d'images (HEIC/WebP), transcodage vidÃ©o, gestion Live Photo via VPS
- **Authentification multi-identifiants** -- Gestion des identifiants D1 avec permissions par bucket et par opÃ©ration
- **Cloudflare Tunnel** -- ConnectivitÃ© VPS sÃ©curisÃ©e sans exposer de ports publics
- **Multilingue** -- Mini App en anglais, chinois, japonais et franÃ§ais
- **ZÃ©ro coÃ»t initial** -- Les fonctionnalitÃ©s principales fonctionnent entiÃ¨rement sur le plan gratuit Cloudflare

## Architecture

```
Client S3 â”€â”€â”€â”€â”€â”€â”
                â”‚
Bot Telegram â”€â”€â”€â”¤
                â”œâ”€â”€â–¶ Cloudflare Worker â”€â”€â–¶ D1 (mÃ©tadonnÃ©es)
Mini App â”€â”€â”€â”€â”€â”€â”€â”¤         â”‚                R2 (cache)
                â”‚         â”‚
Liens partage â”€â”€â”˜         â–¼
                     API Telegram â—€â”€â”€â–¶ Proxy VPS (optionnel, >20 Mo)
```

**Composants :**

| Composant | RÃ´le | CoÃ»t |
|-----------|------|------|
| CF Worker | Passerelle API S3, webhook Bot, hÃ´te Mini App | Plan gratuit |
| CF D1 | Stockage mÃ©tadonnÃ©es (objets, buckets, partages) | Plan gratuit |
| CF R2 | Cache persistant, fichiers <=20 Mo | Plan gratuit (10 Go) |
| Telegram | Stockage persistant de fichiers (illimitÃ©) | Gratuit |
| VPS + Processor | Gros fichiers (>20 Mo), traitement mÃ©dia | ~4 $/mois (optionnel) |

## DÃ©marrage rapide

### PrÃ©requis

- Node.js 22+
- Un [Bot Telegram](https://t.me/BotFather) avec son token
- Un groupe/supergroupe Telegram (obtenir le Chat ID via [@userinfobot](https://t.me/userinfobot))
- Un [compte Cloudflare](https://dash.cloudflare.com)

### Option 1 : Docker (recommandÃ©)

```bash
git clone https://github.com/DebadityaHait/stratum.git
cd stratum
cp .env.example .env
# Ã‰ditez .env : seuls TG_BOT_TOKEN, DEFAULT_CHAT_ID et CLOUDFLARE_API_TOKEN sont nÃ©cessaires
# RecommandÃ© : dÃ©finir TG_ADMIN_IDS pour restreindre l'accÃ¨s au bot (IDs sÃ©parÃ©s par virgule)
./deploy.sh
```

Le script dÃ©tecte automatiquement l'environnement et gÃ¨re tout : construction des images, dÃ©ploiement du Worker, configuration du tunnel (si `CF_CUSTOM_DOMAIN` est dÃ©fini) et dÃ©marrage des services. Les identifiants S3 peuvent Ãªtre crÃ©Ã©s dans le Mini App Telegram (onglet Keys) selon les besoins.

### Option 2 : DÃ©ploiement manuel (sans Docker)

```bash
git clone https://github.com/DebadityaHait/stratum.git
cd stratum
npm install
cp .env.example .env
# Ã‰ditez .env : seuls TG_BOT_TOKEN et DEFAULT_CHAT_ID sont nÃ©cessaires

# DÃ©ployer (dÃ©tection automatique de l'environnement, gÃ©nÃ©ration de tous les secrets)
./deploy.sh

# (Optionnel) DÃ©ploiement VPS SSH legacy
./deploy.sh --vps
```

### VÃ©rification

Configurez n'importe quel client S3 vers l'URL de votre Worker :

```bash
# Avec AWS CLI
aws configure set aws_access_key_id YOUR_KEY
aws configure set aws_secret_access_key YOUR_SECRET
aws --endpoint-url https://your-worker.workers.dev s3 ls

# Avec rclone
rclone config create stratum s3 \
  provider=Other \
  access_key_id=YOUR_KEY \
  secret_access_key=YOUR_SECRET \
  endpoint=https://your-worker.workers.dev \
  acl=private
rclone ls stratum:default
```

## CompatibilitÃ© S3

27 opÃ©rations supportÃ©es couvrant le CRUD objets, l'upload multipart, la gestion des buckets et l'authentification.

| CatÃ©gorie | OpÃ©rations |
|-----------|-----------|
| Objets | GetObject, PutObject, HeadObject, DeleteObject, DeleteObjects, CopyObject |
| Tags | GetObjectTagging, PutObjectTagging, DeleteObjectTagging |
| Listing | ListObjectsV2, ListObjects (v1) |
| Multipart | CreateMultipartUpload, UploadPart, UploadPartCopy, CompleteMultipartUpload, AbortMultipartUpload, ListParts, ListMultipartUploads |
| Buckets | ListBuckets, CreateBucket, DeleteBucket, HeadBucket, GetBucketLocation, GetBucketVersioning |
| Lifecycle | GetBucketLifecycleConfiguration, PutBucketLifecycleConfiguration, DeleteBucketLifecycleConfiguration |
| Auth | AWS SigV4 (multi-identifiants), URL prÃ©signÃ©es, Bearer token, Telegram initData |

**Non supportÃ© (par conception) :** versioning, ACL, rÃ©plication inter-rÃ©gions. Voir [docs/S3-COMPAT.md](docs/S3-COMPAT.md) pour les dÃ©tails.

## Commandes du Bot Telegram

| Commande | Description |
|----------|-------------|
| `/start` | Message de bienvenue |
| `/help` | RÃ©fÃ©rence des commandes |
| `/buckets` | Lister tous les buckets |
| `/ls <bucket> [prefix]` | Lister les objets |
| `/info <bucket> <key>` | DÃ©tails d'un objet |
| `/search <bucket> <query>` | Rechercher des objets |
| `/share <bucket> <key>` | CrÃ©er un lien de partage |
| `/shares` | Lister les partages actifs |
| `/revoke <token>` | RÃ©voquer un partage |
| `/delete <bucket> <key>` | Supprimer un objet (avec confirmation) |
| `/stats` | Statistiques de stockage |
| `/setbucket <name>` | DÃ©finir le bucket par dÃ©faut |
| `/miniapp` | Ouvrir la Mini App |

Envoyez un fichier au Bot pour l'uploader dans le bucket par dÃ©faut.

## Documentation

- [Guide de dÃ©ploiement](docs/deployment.fr.md)
- [RÃ©fÃ©rence de configuration](docs/configuration.fr.md)
- [Commandes du Bot](docs/bot-commands.fr.md)
- [CompatibilitÃ© S3](docs/S3-COMPAT.md)
- [Conception de l'architecture](docs/design/00-overview.md)

## Stack technique

- **Runtime :** Cloudflare Workers (zÃ©ro dÃ©pendance runtime)
- **Base de donnÃ©es :** Cloudflare D1 (SQLite)
- **Cache :** Cloudflare R2 + CF Cache API
- **Auth :** AWS SigV4, URL prÃ©signÃ©es, Bearer tokens
- **Langage :** TypeScript (mode strict)
- **Traitement mÃ©dia :** Sharp + FFmpeg (VPS uniquement)
- **Build :** wrangler v3

## Licence

MIT
