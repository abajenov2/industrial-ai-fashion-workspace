#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: bash install.sh brand|expert|factory|architect /absolute/path/to/workspace"
  exit 2
fi

TYPE="$1"
TARGET="$2"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

case "$TYPE" in
  brand|marka)
    ROLE_TEMPLATE="brand"
    ;;
  expert)
    ROLE_TEMPLATE="expert"
    ;;
  factory)
    ROLE_TEMPLATE="factory"
    ;;
  architect)
    ROLE_TEMPLATE="architect"
    ;;
  *)
    echo "Unknown workspace type: $TYPE"
    exit 2
    ;;
esac

for required in \
  "$REPO_ROOT/templates/common" \
  "$REPO_ROOT/templates/$ROLE_TEMPLATE" \
  "$REPO_ROOT/knowledge-base" \
  "$REPO_ROOT/skills/alliance-resident-workspace"
do
  if [[ ! -d "$required" ]]; then
    echo "Installation package is incomplete: $required"
    exit 1
  fi
done

if [[ -d "$TARGET" ]] && find "$TARGET" -mindepth 1 -maxdepth 1 | read -r; then
  echo "Target directory is not empty: $TARGET"
  echo "Choose an empty directory. Existing resident data will not be overwritten."
  exit 1
fi

mkdir -p "$TARGET"
cp -R "$REPO_ROOT/templates/common/." "$TARGET/"
cp -R "$REPO_ROOT/templates/$ROLE_TEMPLATE/." "$TARGET/"

LIBRARY_TARGET="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Свод_знаний_репозиторий"
SKILL_TARGET="$TARGET/09_Скиллы_для_Codex/alliance-resident-workspace"
mkdir -p "$(dirname "$LIBRARY_TARGET")" "$(dirname "$SKILL_TARGET")"
cp -R "$REPO_ROOT/knowledge-base" "$LIBRARY_TARGET"
cp -R "$REPO_ROOT/skills/alliance-resident-workspace" "$SKILL_TARGET"

echo "Workspace installed: $TARGET"
echo "Type: $ROLE_TEMPLATE"
echo "Knowledge Base version: $LIBRARY_TARGET/VERSION.json"
echo "Next: open the workspace in Codex and fill in its passport."
