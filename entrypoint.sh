#!/bin/bash
set -e

SCRIPTS_DIR=/server/plugins/Skript/scripts
GLOBAL_DIR=$SCRIPTS_DIR/global

# ── Clone ou mise à jour des scripts globaux ──────────────────────────────────
if [ ! -d "$GLOBAL_DIR/.git" ]; then
    echo "[xeinoria-dev] Clonage des scripts globaux..."
    git clone --depth=1 https://github.com/Xeinoria-Studio/xeinoria-scripts-global.git "$GLOBAL_DIR"
else
    echo "[xeinoria-dev] Mise à jour des scripts globaux..."
    git -C "$GLOBAL_DIR" pull --ff-only 2>/dev/null || true
fi

# ── Plugins extras (plugins-extra/*.jar → plugins/) ───────────────────────────
EXTRA_DIR=/server/plugins-extra
if [ -d "$EXTRA_DIR" ]; then
    for jar in "$EXTRA_DIR"/*.jar; do
        [ -f "$jar" ] || continue
        dest="/server/plugins/$(basename "$jar")"
        if [ ! -f "$dest" ]; then
            echo "[xeinoria-dev] Plugin extra : $(basename "$jar")"
            cp "$jar" "$dest"
        fi
    done
fi

echo "[xeinoria-dev] Démarrage du serveur Paper..."
exec java \
    -Xmx${JVM_XMX:-1G} \
    -Xms${JVM_XMS:-512M} \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -jar /server/paper.jar \
    nogui
