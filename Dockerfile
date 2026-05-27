FROM eclipse-temurin:25-jre-noble

# ── Outils système ────────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /server

# ── Paper 26.1.2 (CalVer, match prod) ────────────────────────────────────────
# Build 66 du 26 mai 2026 (stable). API Fill v3 (PaperMC).
ARG PAPER_VERSION=26.1.2
ARG PAPER_BUILD=66
RUN curl -fsSL \
    "https://fill-data.papermc.io/v1/objects/2c2af90d6ef0e823c272e7059873e3b7a24e07674e56e3b8d6c63ebff03cf827/paper-${PAPER_VERSION}-${PAPER_BUILD}.jar" \
    -o paper.jar

# ── EULA & configuration minimale ────────────────────────────────────────────
RUN echo "eula=true" > eula.txt
COPY server.properties server.properties

# ── Dossiers ─────────────────────────────────────────────────────────────────
RUN mkdir -p plugins plugins/Skript/scripts/global plugins-extra

# ── Add-ons Skript (disponibles publiquement) ────────────────────────────────
# Skript 2.15.2
RUN curl -fsSL \
    "https://github.com/SkriptLang/Skript/releases/download/2.15.2/Skript-2.15.2.jar" \
    -o plugins/Skript-2.15.2.jar

# skript-reflect 2.6.3
RUN curl -fsSL \
    "https://github.com/SkriptLang/skript-reflect/releases/download/v2.6.3/skript-reflect-2.6.3.jar" \
    -o plugins/skript-reflect-2.6.3.jar

# SkBee 3.22.0 (version utilisée en prod Xeinoria)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/a0tlbHZO/versions/gzP50Xns/SkBee-3.22.0.jar" \
    -o plugins/SkBee-3.22.0.jar

# skript-worldguard 1.0.1
RUN curl -fsSL \
    "https://github.com/SkriptLang/skript-worldguard/releases/download/v1.0.1/skript-worldguard-1.0.1.jar" \
    -o plugins/skript-worldguard-1.0.1.jar

# Lusk 1.3.13
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/mn8WEUWe/versions/QhSzCjgz/Lusk-1.3.13.jar" \
    -o plugins/Lusk-1.3.13.jar

# SkRedis 2.3.1
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/3R33dfbs/versions/uZyv6bO1/SkRedis-2.3.1.jar" \
    -o plugins/SkRedis-2.3.1.jar

# SkProxy 2.4
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/HaSv4ey2/versions/awO490UD/SkProxy-2.4.jar" \
    -o plugins/SkProxy-2.4.jar

# PlaceholderAPI 2.12.2 (requis par skript-placeholders)
RUN curl -fsSL \
    "https://github.com/PlaceholderAPI/PlaceholderAPI/releases/download/2.12.2/PlaceholderAPI-2.12.2.jar" \
    -o plugins/PlaceholderAPI-2.12.2.jar

# VaultUnlocked 2.17.0 (dernière version publique sur Hangar ;
# la prod utilise 2.19.1 build privé, non requis pour le dev env)
RUN curl -fsSL \
    "https://hangarcdn.papermc.io/plugins/TNE/VaultUnlocked/versions/2.17.0/PAPER/VaultUnlocked-2.17.0.jar" \
    -o plugins/VaultUnlocked-2.17.0.jar

# ── Entrypoint ────────────────────────────────────────────────────────────────
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ── Volume pour les scripts du contributeur ───────────────────────────────────
VOLUME /server/plugins/Skript/scripts
# (global/ sera cloné par entrypoint.sh au premier démarrage)

EXPOSE 25565

ENTRYPOINT ["/entrypoint.sh"]
