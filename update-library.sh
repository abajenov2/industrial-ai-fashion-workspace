#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: bash update-library.sh /absolute/path/to/resident-workspace"
  exit 2
fi

TARGET="$1"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$REPO_ROOT/knowledge-base"
DESTINATION="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Свод_знаний_репозиторий"

if [[ ! -f "$SOURCE/VERSION.json" ]]; then
  echo "Source Knowledge Base version is missing: $SOURCE/VERSION.json"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Resident workspace not found: $TARGET"
  exit 1
fi

mkdir -p "$DESTINATION"
rsync -a --delete "$SOURCE/" "$DESTINATION/"

echo "Knowledge Base updated without changing private resident folders."
echo "Version: $DESTINATION/VERSION.json"
