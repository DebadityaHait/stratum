# Commandes du Bot Telegram

[English](bot-commands.md) | [ä¸­æ–‡](bot-commands.zh.md) | [æ—¥æœ¬èªž](bot-commands.ja.md) | [FranÃ§ais](bot-commands.fr.md)

## AperÃ§u

Le bot Stratum fournit une interface Telegram pour gÃ©rer votre stockage S3. Toutes les commandes fonctionnent dans le groupe de stockage dÃ©signÃ© ou en messages directs avec le bot.

## Commandes

### /start

Affiche un message de bienvenue avec une brÃ¨ve introduction et un guide de dÃ©marrage rapide.

### /help

Affiche la rÃ©fÃ©rence complÃ¨te des commandes avec la syntaxe et des exemples.

### /buckets

Liste tous les buckets avec leur nombre d'objets et leur taille totale.

```
/buckets
```

Exemple de sortie :
```
Buckets (3):
  default - 42 objects, 156.3 MB
  photos  - 128 objects, 1.2 GB
  backup  - 7 objects, 89.5 MB
```

### /ls

Liste les objets d'un bucket avec filtrage optionnel par prÃ©fixe.

```
/ls <bucket> [prefix]
```

- Avec un bucket : liste les objets de ce bucket
- Avec un prÃ©fixe : filtre par prÃ©fixe de clÃ© (fonctionne comme un listing de rÃ©pertoire)

Exemples :
```
/ls photos
/ls photos 2024/january/
```

### /info

Affiche les informations dÃ©taillÃ©es d'un objet spÃ©cifique.

```
/info <bucket> <key>
```

Les informations comprennent : taille, type de contenu, ETag, date d'envoi et nom du bucket.

### /search

Recherche des objets dans un bucket par motif de clÃ©.

```
/search <bucket> <query>
```

La requÃªte est comparÃ©e aux clÃ©s des objets par recherche de sous-chaÃ®ne dans le bucket spÃ©cifiÃ©.

### /share

CrÃ©e un lien de partage pour un fichier avec des restrictions optionnelles.

```
/share <bucket> <key>
```

Des paramÃ¨tres optionnels peuvent Ãªtre ajoutÃ©s aprÃ¨s la clÃ© :

```
/share <bucket> <key> [expiration_secondes] [mot_de_passe] [max_telechargements]
```

- **Expiration** : durÃ©e d'expiration en secondes (par dÃ©faut : sans expiration)
- **Mot de passe** : protection par mot de passe (par dÃ©faut : aucun)
- **Max tÃ©lÃ©chargements** : limite de tÃ©lÃ©chargement (par dÃ©faut : illimitÃ©)

Format du lien gÃ©nÃ©rÃ© : `https://your-worker.workers.dev/share/<token>`

Les liens de partage supportent :
- `/share/<token>` -- Page d'aperÃ§u avec mÃ©tadonnÃ©es
- `/share/<token>/download` -- TÃ©lÃ©chargement direct
- `/share/<token>/inline` -- Affichage en ligne (images, vidÃ©os)

### /shares

Liste tous les tokens de partage actifs (non expirÃ©s, non Ã©puisÃ©s).

```
/shares [bucket]
```

- Sans bucket : liste les partages de tous les buckets
- Avec bucket : liste uniquement les partages du bucket spÃ©cifiÃ©

Affiche le token, le fichier associÃ©, la date de crÃ©ation, l'expiration, le nombre de tÃ©lÃ©chargements et le statut du mot de passe.

### /revoke

RÃ©voque un token de partage actif, rendant le lien immÃ©diatement invalide.

```
/revoke <token>
```

### /delete

Supprime un objet du stockage. NÃ©cessite une confirmation via un bouton inline.

```
/delete <bucket> <key>
```

La suppression est en cascade complÃ¨te : supprime le message Telegram, tous les objets dÃ©rivÃ©s (miniatures, versions transcodÃ©es), les tokens de partage associÃ©s et les entrÃ©es de cache.

### /stats

Affiche les statistiques de stockage pour l'ensemble des buckets.

```
/stats
```

Les informations comprennent : nombre total d'objets, taille totale et nombre de buckets.

### /setbucket

DÃ©finit le bucket par dÃ©faut pour l'envoi de fichiers directement au bot.

```
/setbucket <name>
```

### /miniapp

Ouvre l'interface Mini App Telegram en ligne pour une gestion complÃ¨te des fichiers avec une interface graphique.

```
/miniapp
```

## Envoi de fichiers

Envoyez n'importe quel fichier (document, photo, vidÃ©o, audio) directement au bot pour l'envoyer vers le stockage. Le fichier sera stockÃ© dans le bucket par dÃ©faut avec le nom de fichier original comme clÃ©.

Pour les photos envoyÃ©es en tant qu'images compressÃ©es (pas en tant que documents), le bot conserve la version en plus haute rÃ©solution disponible.

## Actions de callback

Certaines commandes dÃ©clenchent des boutons inline pour des flux interactifs :

- **Confirmation de suppression** -- Boutons "Oui, supprimer" / "Annuler" aprÃ¨s `/delete`
- **Confirmation de rÃ©vocation** -- Boutons "Confirmer" / "Annuler" aprÃ¨s `/revoke`
- **Pagination** -- "Page suivante" / "Page prÃ©cÃ©dente" pour les listings longs

Les donnÃ©es de callback ont un TTL de 5 Ã  10 minutes. Si les boutons ne rÃ©pondent plus, relancez la commande.
