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

# TheNewEconomy 0.1.4.0 — fournit un provider Economy (legacy Vault + VaultUnlocked)
# pour que Skript puisse hooker Vault. Même auteur que VaultUnlocked.
# (Marqué 1.17-1.21.8 sur Hangar mais charge sans souci sur Paper 26.x.)
RUN curl -fsSL \
    "https://hangarcdn.papermc.io/plugins/TNE/TheNewEconomy/versions/0.1.4.0/PAPER/TNE-Paper-0.1.4.0.jar" \
    -o plugins/TNE-Paper-0.1.4.0.jar

# ── Skript addons supplémentaires ────────────────────────────────────────────
# skript-placeholders 1.7.1 (lecture de placeholders PAPI depuis Skript)
RUN curl -fsSL \
    "https://github.com/APickledWalrus/skript-placeholders/releases/download/1.7.1/skript-placeholders-1.7.1.jar" \
    -o plugins/skript-placeholders-1.7.1.jar

# Skript-Translate 1.3 (traduction de texte côté serveur)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/MRwiW8AG/versions/zAGLk81q/Skript-Translate-1.3.jar" \
    -o plugins/Skript-Translate-1.3.jar

# skript-db 1.5.0 (fork 4w3, marqué 1.20–1.21.4 mais charge sur Paper 26.x)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/wQPcgT79/versions/8qXzcJlI/skript-db-1.5.0.jar" \
    -o plugins/skript-db-1.5.0.jar

# ── Dépendances natives utilisées par les scripts Xeinoria ───────────────────
# ProtocolLib 5.4.0 (dépendance de plusieurs addons + scripts)
RUN curl -fsSL \
    "https://github.com/dmulloy2/ProtocolLib/releases/download/5.4.0/ProtocolLib.jar" \
    -o plugins/ProtocolLib.jar

# PacketEvents 2.12.1 (utilisé par Lusk et certains scripts)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/HYKaKraK/versions/ap8qHs7D/packetevents-spigot-2.12.1.jar" \
    -o plugins/packetevents-spigot-2.12.1.jar

# WorldEdit 7.4.3 (Paper 26.1.2 supporté) — requis par skript-worldguard
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/1u6JkXh5/versions/yDUBafTJ/worldedit-bukkit-7.4.3.jar" \
    -o plugins/worldedit-bukkit-7.4.3.jar

# WorldGuard 7.0.16 (Paper 26.1.2 supporté) — requis par skript-worldguard
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/DKY9btbd/versions/EZl3moba/worldguard-bukkit-7.0.16.jar" \
    -o plugins/worldguard-bukkit-7.0.16.jar

# LuckPerms 5.5.53 (permissions ; nombreux scripts y font référence)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/Vebnzrzj/versions/MBSY8toc/LuckPerms-Bukkit-5.5.53.jar" \
    -o plugins/LuckPerms-Bukkit-5.5.53.jar

# CommandAPI 11.2.0 (Paper build) — dépendance de certains plugins
RUN curl -fsSL \
    "https://github.com/CommandAPI/CommandAPI/releases/download/11.2.0/CommandAPI-11.2.0-Paper.jar" \
    -o plugins/CommandAPI-11.2.0-Paper.jar

# DecentHolograms 2.9.10 (hologrammes utilisés par les scripts)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/w02MKsTg/versions/t9gURTWO/DecentHolograms-2.9.10.jar" \
    -o plugins/DecentHolograms-2.9.10.jar

# Simple Voice Chat 2.6.17 (Bukkit build, supporte 26.1.2)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/9eGKb6K1/versions/Qnk9puxN/voicechat-bukkit-2.6.17.jar" \
    -o plugins/voicechat-bukkit-2.6.17.jar

# SkinsRestorer 15.12.0 (Bukkit/Paper build, supporte 26.1.x)
RUN curl -fsSL \
    "https://cdn.modrinth.com/data/TsLS8Py5/versions/2PjHGlwd/SkinsRestorer.jar" \
    -o plugins/SkinsRestorer-15.12.0.jar

# ── Entrypoint ────────────────────────────────────────────────────────────────
COPY entrypoint.sh /entrypoint.sh
# Strip potential CRLF (Windows checkouts) and make executable.
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# ── Volume pour les scripts du contributeur ───────────────────────────────────
VOLUME /server/plugins/Skript/scripts
# (global/ sera cloné par entrypoint.sh au premier démarrage)

EXPOSE 25565

ENTRYPOINT ["/entrypoint.sh"]
