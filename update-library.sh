#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: bash update-library.sh /absolute/path/to/resident-workspace"
  exit 2
fi

TARGET="$1"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$REPO_ROOT/knowledge-base"
SYSTEM_SOURCE="$REPO_ROOT/alliance-system"
DESTINATION="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Свод_знаний_репозиторий"
SYSTEM_DESTINATION="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Система_Альянса"

if [[ ! -f "$SOURCE/VERSION.json" ]]; then
  echo "Source Knowledge Base version is missing: $SOURCE/VERSION.json"
  exit 1
fi

if [[ ! -f "$SYSTEM_SOURCE/navigation/START_HERE.md" ]]; then
  echo "Source Alliance system navigation is missing: $SYSTEM_SOURCE"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Resident workspace not found: $TARGET"
  exit 1
fi

mkdir -p "$DESTINATION"
rsync -a --delete "$SOURCE/" "$DESTINATION/"
mkdir -p "$SYSTEM_DESTINATION"
rsync -a --delete "$SYSTEM_SOURCE/" "$SYSTEM_DESTINATION/"

echo "Knowledge Base and Alliance system navigation updated without changing private resident folders."
echo "Version: $DESTINATION/VERSION.json"
echo "Start here: $SYSTEM_DESTINATION/navigation/START_HERE.md"
