#!/usr/bin/env bash
# Skript validation runner for CI.
#
# Lance le container xeinoria-dev-env avec les scripts du repo appelant montés,
# attend la fin du démarrage de Paper, puis vérifie que Skript n'a pas signalé
# d'erreurs de parsing.
#
# Variables d'environnement :
#   IMAGE         (def. ghcr.io/xeinoria-studio/xeinoria-dev-env:latest)
#   SCRIPTS_DIR   chemin absolu sur l'hôte vers les .sk à valider (requis)
#   MOUNT_NAME    sous-dossier sous /server/plugins/Skript/scripts/ (def. repo)
#   GLOBAL_DIR    chemin absolu vers un checkout de xeinoria-scripts-global
#                 (optionnel — monté comme global/ si fourni)
#   TIMEOUT       timeout du démarrage de Paper en secondes (def. 240)
#
# Sortie : 0 si pas d'erreur Skript détectée, !=0 sinon.

set -euo pipefail

IMAGE="${IMAGE:-ghcr.io/xeinoria-studio/xeinoria-dev-env:latest}"
SCRIPTS_DIR="${SCRIPTS_DIR:-$PWD}"
MOUNT_NAME="${MOUNT_NAME:-repo}"
GLOBAL_DIR="${GLOBAL_DIR:-}"
TIMEOUT="${TIMEOUT:-240}"
CONTAINER_NAME="xeinoria-ci-$$"
LOG_FILE="$(mktemp)"
ERR_FILE="$(mktemp)"

cleanup() {
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    rm -f "$LOG_FILE" "$ERR_FILE"
}
trap cleanup EXIT

if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "[skript-ci] SCRIPTS_DIR introuvable : $SCRIPTS_DIR" >&2
    exit 2
fi

echo "[skript-ci] image=$IMAGE"
echo "[skript-ci] scripts=$SCRIPTS_DIR -> /server/plugins/Skript/scripts/$MOUNT_NAME"
[ -n "$GLOBAL_DIR" ] && echo "[skript-ci] global=$GLOBAL_DIR -> /server/plugins/Skript/scripts/global"

docker pull "$IMAGE" >/dev/null

MOUNT_ARGS=( -v "$SCRIPTS_DIR:/server/plugins/Skript/scripts/$MOUNT_NAME:ro" )
if [ -n "$GLOBAL_DIR" ]; then
    if [ ! -d "$GLOBAL_DIR" ]; then
        echo "[skript-ci] GLOBAL_DIR introuvable : $GLOBAL_DIR" >&2
        exit 2
    fi
    MOUNT_ARGS+=( -v "$GLOBAL_DIR:/server/plugins/Skript/scripts/global:ro" )
fi

# REDIS_HOST vide = désactive SkRedis (pas de Redis disponible dans le runner).
docker run -d --name "$CONTAINER_NAME" \
    -e JVM_XMX=1G -e JVM_XMS=512M \
    -e REDIS_HOST= \
    "${MOUNT_ARGS[@]}" \
    "$IMAGE" >/dev/null

echo "[skript-ci] container démarré, capture des logs (timeout=${TIMEOUT}s)…"
( docker logs -f "$CONTAINER_NAME" > "$LOG_FILE" 2>&1 ) &
LOG_PID=$!

deadline=$(( $(date +%s) + TIMEOUT ))
ready=0
while [ "$(date +%s)" -lt "$deadline" ]; do
    if grep -qE 'Done \([0-9.]+s\)!' "$LOG_FILE" 2>/dev/null; then
        ready=1
        break
    fi
    if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
        echo "[skript-ci] container arrêté prématurément"
        break
    fi
    sleep 2
done

# Laisser Skript finir d'imprimer ses erreurs après le "Done".
sleep 8
kill "$LOG_PID" 2>/dev/null || true
wait "$LOG_PID" 2>/dev/null || true

if [ "$ready" -ne 1 ]; then
    echo "[skript-ci] ECHEC : Paper n'a pas fini son démarrage en ${TIMEOUT}s"
    echo "[skript-ci] === 100 dernières lignes ==="
    tail -n 100 "$LOG_FILE"
    exit 1
fi

# ── Détection des erreurs Skript ──────────────────────────────────────────────
# Signal canonique de Skript : "Encountered N errors while [re]loading 'foo.sk'!"
# On ignore les scripts hors de notre mount (ex. scripts internes du conteneur).
ERRORS=0
if grep -E "Encountered [0-9]+ error.* while (re)?loading" "$LOG_FILE" > "$ERR_FILE" 2>/dev/null; then
    if [ -s "$ERR_FILE" ]; then
        ERRORS=$(wc -l < "$ERR_FILE")
    fi
fi

# Détails (lignes précédentes contenant les vraies erreurs Skript)
DETAILS_FILE="$(mktemp)"
grep -nE "^\[.*\] \[Skript\] (Line [0-9]+:|Can't understand|.*is not a |Invalid |There's no )" "$LOG_FILE" > "$DETAILS_FILE" 2>/dev/null || true

echo "[skript-ci] === résumé ==="
echo "[skript-ci] scripts en erreur : $ERRORS"
if [ -s "$DETAILS_FILE" ]; then
    DET_COUNT=$(wc -l < "$DETAILS_FILE")
    echo "[skript-ci] lignes d'erreur Skript : $DET_COUNT"
fi

if [ "$ERRORS" -gt 0 ]; then
    echo "[skript-ci] ECHEC : Skript a signalé $ERRORS script(s) en erreur"
    echo "[skript-ci] --- summary lines ---"
    cat "$ERR_FILE"
    if [ -s "$DETAILS_FILE" ]; then
        echo "[skript-ci] --- error context (max 100 lignes) ---"
        head -n 100 "$DETAILS_FILE"
    fi
    rm -f "$DETAILS_FILE"
    exit 1
fi

# Compte les scripts chargés avec succès comme sanity check.
LOADED=$(grep -cE "Loaded [0-9]+ scripts? in" "$LOG_FILE" || true)
echo "[skript-ci] indicateur 'Loaded ... scripts in ...' : $LOADED occurrence(s)"

rm -f "$DETAILS_FILE"
echo "[skript-ci] OK — aucune erreur Skript détectée"
