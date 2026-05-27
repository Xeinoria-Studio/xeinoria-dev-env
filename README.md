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

| Add-on | Version | Description | Source |
|--------|---------|-------------|--------|
| [Skript](https://github.com/SkriptLang/Skript) | 2.15.2 | Langage de script principal | GitHub |
| [skript-reflect](https://github.com/SkriptLang/skript-reflect) | 2.6.3 | Accès Java/API depuis Skript | GitHub |
| [SkBee](https://github.com/ShaneBeee/SkBee) | 3.22.0 | NBT, scoreboards, display entities, particles… | Modrinth |
| [Lusk](https://github.com/JakeGBLP/Lusk) | 1.3.13 | Expressions et effets supplémentaires | Modrinth |
| [skript-db](https://github.com/btk5h/skript-db) | 1.3.9 | Connexions SQL depuis Skript | GitHub |
| [skript-worldguard](https://github.com/SkriptLang/skript-worldguard) | 1.0.1 | Intégration WorldGuard | GitHub |
| [SkRedis](https://modrinth.com/plugin/skredis) | 2.3.1 | Pub/sub Redis depuis Skript | Modrinth |
| [SkProxy](https://modrinth.com/plugin/skproxy) | 2.4 | Communication proxy Velocity | Modrinth |
| [PlaceholderAPI](https://github.com/PlaceholderAPI/PlaceholderAPI) | 2.12.2 | Placeholders dynamiques | GitHub |
| [VaultUnlocked](https://github.com/MilkBowl/VaultAPI) | 2.17.0 | API économie/permissions | Hangar |

### Add-ons nécessitant un téléchargement manuel

Voir [`plugins-extra/README.md`](plugins-extra/README.md) pour les plugins non disponibles publiquement (SpigotMC).

---

## Utiliser Redis (SkRedis)

Décommentez le service `redis` dans `docker-compose.yml` :

```yaml
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
```

Et passez `REDIS_URL: "redis:6379"` dans les variables d'environnement du service `minecraft`.

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
