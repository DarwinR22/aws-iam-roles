#!/usr/bin/env bash
set -euo pipefail

BRANCH=${1:-$(git rev-parse --abbrev-ref HEAD)}
REMOTE=${2:-origin}

printf "🔍 Verificando sincronización con %s/%s ...\n" "$REMOTE" "$BRANCH"

# Obtener refs remotas actualizadas
git fetch --quiet "$REMOTE" "$BRANCH"

LOCAL=$(git rev-parse "$BRANCH")
REMOTE_HASH=$(git rev-parse "$REMOTE/$BRANCH")
BASE=$(git merge-base "$BRANCH" "$REMOTE/$BRANCH")

if [ "$LOCAL" = "$REMOTE_HASH" ]; then
  echo "✅ La rama local está sincronizada con $REMOTE/$BRANCH"
  exit 0
elif [ "$LOCAL" = "$BASE" ]; then
  echo "⬇️ Falta hacer pull (la rama remota tiene commits nuevos)"
  echo "   Ejecuta: git pull --ff-only $REMOTE $BRANCH"
  exit 2
elif [ "$REMOTE_HASH" = "$BASE" ]; then
  echo "⬆️ La rama local tiene commits que no están en remoto (push pendiente)"
  echo "   Ejecuta: git push $REMOTE $BRANCH"
  exit 3
else
  echo "⚠️ Historial divergente: se requiere reconciliar (rebase recomendado)"
  echo "   Sugerido: git fetch $REMOTE && git rebase $REMOTE/$BRANCH"
  exit 4
fi
