#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: bash install.sh /absolute/path/to/workspace"
  exit 2
fi

TARGET="$1"
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

for required in \
  "$REPO_ROOT/templates/workspace" \
  "$REPO_ROOT/knowledge-base" \
  "$REPO_ROOT/alliance-system" \
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
cp -R "$REPO_ROOT/templates/workspace/." "$TARGET/"

for directory in \
  "04_Проекты_и_рабочие_задачи" \
  "05_Встречи_и_цифровой_след" \
  "06_Публикации_и_обновления_платформы" \
  "08_Кооперационные_цепочки_и_рынок_роли" \
  "99_Архив_исходников"
do
  mkdir -p "$TARGET/$directory"
done

LIBRARY_TARGET="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Свод_знаний_репозиторий"
SYSTEM_TARGET="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Система_Альянса"
SKILL_TARGET="$TARGET/09_Скиллы_для_Codex/alliance-resident-workspace"
mkdir -p \
  "$(dirname "$LIBRARY_TARGET")" \
  "$(dirname "$SYSTEM_TARGET")" \
  "$(dirname "$SKILL_TARGET")"
cp -R "$REPO_ROOT/knowledge-base" "$LIBRARY_TARGET"
cp -R "$REPO_ROOT/alliance-system" "$SYSTEM_TARGET"
cp -R "$REPO_ROOT/skills/alliance-resident-workspace" "$SKILL_TARGET"

echo "Workspace installed: $TARGET"
echo "Model: unified resident workspace"
echo "Knowledge Base version: $LIBRARY_TARGET/VERSION.json"
echo "Next: open the workspace in Codex, fill in its owner context, roles and nearest task."
