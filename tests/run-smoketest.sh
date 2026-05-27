#!/usr/bin/env bash
# Smoke test du conteneur xeinoria-dev-env.
# Lance le container, attend les marqueurs `[XEINORIA_SMOKETEST]`,
# valide que Skript et les addons clés sont chargés, puis arrête le container.
#
# Usage:
#   IMAGE=xeinoria-dev-env:smoke ./tests/run-smoketest.sh
set -euo pipefail

IMAGE="${IMAGE:-xeinoria-dev-env:smoke}"
TIMEOUT="${TIMEOUT:-180}"
CONTAINER_NAME="xeinoria-smoke-$$"
SCRIPT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="$(mktemp)"

cleanup() {
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    rm -f "$LOG_FILE"
}
trap cleanup EXIT

echo "[smoketest] Lancement du conteneur $CONTAINER_NAME (image=$IMAGE)"

# On monte le dossier tests + les scripts utilisateur du repo pour valider qu'ils parsent.
# Le dossier global/ sera cloné automatiquement par l'entrypoint.
docker run -d --name "$CONTAINER_NAME" \
    -e JVM_XMX=1G -e JVM_XMS=512M \
    -v "$SCRIPT_ROOT/tests:/server/plugins/Skript/scripts/tests:ro" \
    -v "$SCRIPT_ROOT/scripts:/server/plugins/Skript/scripts/user:ro" \
    "$IMAGE" >/dev/null

echo "[smoketest] Capture des logs (timeout=${TIMEOUT}s)…"
( docker logs -f "$CONTAINER_NAME" > "$LOG_FILE" 2>&1 ) &
LOGS_PID=$!

deadline=$(( $(date +%s) + TIMEOUT ))
done=0
while [ "$(date +%s)" -lt "$deadline" ]; do
    if grep -q '\[XEINORIA_SMOKETEST\] done' "$LOG_FILE" 2>/dev/null; then
        done=1
        break
    fi
    if ! docker inspect -f '{{.State.Running}}' "$CONTAINER_NAME" 2>/dev/null | grep -q true; then
        echo "[smoketest] container arrete prematurement"
        break
    fi
    sleep 2
done

kill "$LOGS_PID" 2>/dev/null || true
wait "$LOGS_PID" 2>/dev/null || true

echo "[smoketest] --- extrait logs (filtré smoketest) ---"
grep -E 'XEINORIA_SMOKETEST|Loaded Skript|Skript.*reloaded|ERROR|severe' "$LOG_FILE" | tail -n 60 || true
echo "[smoketest] --- fin extrait ---"

if [ "$done" -ne 1 ]; then
    echo "[smoketest] ECHEC : marqueur 'done' non recu dans le delai"
    echo "[smoketest] === derniers logs bruts ==="
    tail -n 80 "$LOG_FILE" || true
    exit 1
fi

# Détection d'erreurs : un addon manquant ou Skript fail = échec
if grep -E '\[XEINORIA_SMOKETEST\] (plugin|addon)=[^=]+=(fail|missing)' "$LOG_FILE" >/tmp/smoke-failures 2>/dev/null; then
    if [ -s /tmp/smoke-failures ]; then
        echo "[smoketest] ECHEC : éléments manquants/cassés :"
        cat /tmp/smoke-failures
        exit 1
    fi
fi

# Détection erreurs Skript bloquantes au chargement
if grep -E 'Skript.*encountered.*error|Can.t understand|Line:.*\.sk' "$LOG_FILE" | grep -v "smoketest.sk" >/tmp/skript-errors 2>/dev/null; then
    if [ -s /tmp/skript-errors ]; then
        echo "[smoketest] AVERTISSEMENT : erreurs Skript détectées dans global/ :"
        cat /tmp/skript-errors
        # Pas bloquant pour le moment : les scripts global/ peuvent avoir des dépendances staff absentes.
    fi
fi

echo "[smoketest] OK"
