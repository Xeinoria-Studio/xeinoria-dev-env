# xeinoria-dev-env

Environnement de développement local pour les scripts Skript du réseau **Xeinoria**.

Basé sur Docker, il reproduit fidèlement la stack du serveur de production (Paper 1.21.4 + tous les add-ons Skript) sans que vous n'ayez besoin d'héberger quoi que ce soit.

---

## Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows / macOS / Linux)
- ~1,5 Go de RAM disponible pour le container

---

## Démarrage rapide

```bash
# 1. Cloner ce dépôt
git clone https://github.com/Xeinoria-Studio/xeinoria-dev-env.git
cd xeinoria-dev-env

# 2. Lancer le serveur
docker compose up

# 3. Rejoindre en jeu
#    Serveur : localhost:25565
#    Compte  : n'importe quel nom (mode hors-ligne)
```

Au premier démarrage, les scripts globaux (`global/`) sont automatiquement clonés depuis [`xeinoria-scripts-global`](https://github.com/Xeinoria-Studio/xeinoria-scripts-global).

---

## Créer et tester un script

```bash
# Créer votre script dans scripts/
echo 'command /hello:
    trigger:
        send "Bonjour monde !"' > scripts/hello.sk

# En jeu, recharger le script
/sk reload hello
```

Les fichiers dans `scripts/` sont montés en volume — toute modification est immédiatement visible.

---

## Add-ons disponibles (pré-installés dans l'image)

> Les versions marquées <kbd>*</kbd> ne sont pas explicitement marquées compatibles **Paper 26.1.2**
> par leurs auteurs, mais se chargent et fonctionnent sans erreur visible (testées via le smoke test
> de ce dépôt). Au moindre comportement étrange en jeu, repassez en version supportée.

### Skript & add-ons Skript

| Add-on | Version | Description | Source |
|--------|---------|-------------|--------|
| [Skript](https://github.com/SkriptLang/Skript) | 2.15.2 | Langage de script principal | GitHub |
| [skript-reflect](https://github.com/SkriptLang/skript-reflect) | 2.6.3 | Accès Java/API depuis Skript | GitHub |
| [SkBee](https://github.com/ShaneBeee/SkBee) | 3.22.0 | NBT, scoreboards, display entities, particles… | Modrinth |
| [Lusk](https://github.com/JakeGBLP/Lusk) <kbd>*</kbd> | 1.3.13 | Expressions et effets supplémentaires | Modrinth |
| [skript-worldguard](https://github.com/SkriptLang/skript-worldguard) | 1.0.1 | Intégration WorldGuard | GitHub |
| [SkRedis](https://modrinth.com/plugin/skredis) | 2.3.1 | Pub/sub Redis depuis Skript | Modrinth |
| [SkProxy](https://modrinth.com/plugin/skproxy) | 2.4 | Communication proxy Velocity | Modrinth |
| [skript-placeholders](https://github.com/APickledWalrus/skript-placeholders) <kbd>*</kbd> | 1.7.1 | Lecture de placeholders PAPI | GitHub |
| [Skript-Translate](https://modrinth.com/plugin/skript-translate) <kbd>*</kbd> | 1.3 | Traduction de texte côté serveur | Modrinth |
| [skript-db](https://modrinth.com/plugin/skript-db) <kbd>*</kbd> | 1.5.0 | Connexions SQL/SQLite depuis Skript | Modrinth |

### Dépendances natives et plugins associés

| Plugin | Version | Pourquoi |
|--------|---------|----------|
| [WorldEdit](https://enginehub.org/worldedit/) | 7.4.3 | Édition de monde, requis par skript-worldguard |
| [WorldGuard](https://enginehub.org/worldguard/) | 7.0.16 | Régions, requis par skript-worldguard |
| [ProtocolLib](https://github.com/dmulloy2/ProtocolLib) | 5.4.0 | Manipulation de paquets pour de nombreux addons |
| [PacketEvents](https://modrinth.com/plugin/packetevents) | 2.12.1 | API paquets utilisée par Lusk |
| [Simple Voice Chat](https://modrinth.com/plugin/simple-voice-chat) | 2.6.17 | API voicechat (port UDP `24454`) |
| [LuckPerms](https://luckperms.net/) | 5.5.53 | Permissions |
| [CommandAPI](https://commandapi.jorel.dev/) | 11.2.0 | Brigadier helper |
| [DecentHolograms](https://wiki.decentholograms.eu/) | 2.9.10 | Hologrammes |
| [PlaceholderAPI](https://placeholderapi.com/) | 2.12.2 | Placeholders dynamiques |
| [VaultUnlocked](https://hangar.papermc.io/TNE/VaultUnlocked) | 2.17.0 | API économie/permissions |
| [TheNewEconomy](https://hangar.papermc.io/TNE/TheNewEconomy) | 0.1.4.0 | Provider Economy pour Vault/Skript |

### Add-ons nécessitant un téléchargement manuel

Voir [`plugins-extra/README.md`](plugins-extra/README.md) pour les plugins non disponibles
publiquement (PermSk, skRayFall, jars privés…). Déposez vos jars dans `plugins-extra/` :
ils sont copiés dans `plugins/` au démarrage.

---

## Script de bienvenue intégré

Le script [`scripts/_xeinoria_welcome.sk`](scripts/_xeinoria_welcome.sk) est livré par défaut :

- **Auto-op du premier joueur** si aucun opérateur n'est défini. Cela ne se produit qu'**une seule
  fois** (persistant via une variable Skript) ; les autres joueurs gardent leurs permissions
  normales. L'événement est loggé en console (`[xeinoria-dev] Auto-op : <pseudo>`).
- Un **titre** s'affiche à la connexion, puis 5 s plus tard (le temps que les plugins finissent
  leur spam de boot) un récapitulatif est envoyé dans le tchat : objectif du serveur, liens
  cliquables vers les docs Skript / addons, tuto Docker, crédits et licence.

Pour le désactiver : supprimez ou commentez le fichier dans `scripts/`.

---

## Accéder à la console serveur via Docker

```bash
# Attache ton terminal à la console Minecraft du container
docker attach xeinoria-dev

# Tape n'importe quelle commande console : op <Pseudo>, stop, /sk reload <nom>, etc.

# Pour SE DÉTACHER SANS ARRÊTER LE SERVEUR :
#   Ctrl+P  puis  Ctrl+Q
# ⚠️  Ne pas faire Ctrl+C — ça tue le serveur.
```

Le nom du container est figé par `container_name: xeinoria-dev` dans `docker-compose.yml`.

---

## Utiliser Redis (SkRedis)

Le service `redis` est **activé par défaut** dans `docker-compose.yml` (mot de passe `password`,
dev seulement). Pour le désactiver : passez `REDIS_HOST: ""` dans l'environnement du service
`minecraft` — l'entrypoint retirera alors le jar SkRedis pour éviter le spam d'erreurs.

La config SkRedis est régénérée automatiquement au démarrage à partir des variables
`REDIS_HOST`, `REDIS_PORT`, `REDIS_USERNAME`, `REDIS_PASSWORD`.

---

## Image Docker

L'image est construite automatiquement via GitHub Actions et publiée sur :

```
ghcr.io/xeinoria-studio/xeinoria-dev-env:latest
```

Pour builder l'image localement :

```bash
docker compose up --build
```

---

## Licence

Ce dépôt est sous licence [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

---

---

# xeinoria-dev-env (English)

Local development environment for **Xeinoria** network Skript scripts.

Docker-based, it faithfully replicates the production server stack (Paper 1.21.4 + all Skript add-ons) without requiring you to host anything.

## Quick start

```bash
git clone https://github.com/Xeinoria-Studio/xeinoria-dev-env.git
cd xeinoria-dev-env
docker compose up
# Join at localhost:25565 (offline mode — any username works)
```

On first start, global scripts (`global/`) are automatically cloned from [`xeinoria-scripts-global`](https://github.com/Xeinoria-Studio/xeinoria-scripts-global).

Put your `.sk` files in `scripts/` and reload with `/sk reload <name>` in-game.

## License

[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
