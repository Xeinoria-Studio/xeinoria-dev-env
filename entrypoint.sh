#!/bin/bash
set -e

# Empêche git d'attendre interactivement des credentials (repo privé)
# et évite tout helper credentials hérité de l'hôte (Windows / WSL).
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/true
export GCM_INTERACTIVE=never

SCRIPTS_DIR=/server/plugins/Skript/scripts
GLOBAL_DIR=$SCRIPTS_DIR/global
GLOBAL_REPO="${GLOBAL_REPO:-https://github.com/Xeinoria-Studio/xeinoria-scripts-global.git}"

# ── Clone ou mise à jour des scripts globaux (non bloquant) ───────────────────
mkdir -p "$GLOBAL_DIR"
if [ ! -d "$GLOBAL_DIR/.git" ]; then
    if [ -n "$(ls -A "$GLOBAL_DIR" 2>/dev/null)" ]; then
        echo "[xeinoria-dev] global/ déjà rempli (mount local), pas de clone."
    else
        echo "[xeinoria-dev] Clonage des scripts globaux depuis $GLOBAL_REPO..."
        # Timeout 30s : si le repo est privé/hors-ligne, on n'attend pas.
        if ! timeout 30 git -c credential.helper= clone --depth=1 "$GLOBAL_REPO" "$GLOBAL_DIR" 2>&1; then
            echo "[xeinoria-dev] AVERTISSEMENT : clone échoué (repo privé, credentials manquants ou hors-ligne)."
            echo "[xeinoria-dev] Démarrage sans scripts globaux — montez vos propres scripts dans /server/plugins/Skript/scripts si besoin."
            rm -rf "$GLOBAL_DIR"/* "$GLOBAL_DIR"/.git 2>/dev/null || true
        fi
    fi
else
    echo "[xeinoria-dev] Mise à jour des scripts globaux..."
    timeout 30 git -C "$GLOBAL_DIR" -c credential.helper= pull --ff-only 2>/dev/null \
        || echo "[xeinoria-dev] pull échoué, on garde l'état actuel."
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
