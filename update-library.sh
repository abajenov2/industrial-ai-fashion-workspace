#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
LIBRARY_ONLY=0
TARGET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --library-only)
      LIBRARY_ONLY=1
      shift
      ;;
    -h|--help)
      echo "Usage: bash update-library.sh [--dry-run] [--library-only] /absolute/path/to/resident-workspace"
      exit 0
      ;;
    *)
      if [[ -n "$TARGET" ]]; then
        echo "Unexpected argument: $1"
        exit 2
      fi
      TARGET="$1"
      shift
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: bash update-library.sh [--dry-run] [--library-only] /absolute/path/to/resident-workspace"
  exit 2
fi

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$REPO_ROOT/knowledge-base"
SYSTEM_SOURCE="$REPO_ROOT/alliance-system"
DESTINATION="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Свод_знаний_репозиторий"
SYSTEM_DESTINATION="$TARGET/03_Библиотека_роли/01_Открытый_стандарт/Система_Альянса"

if [[ ! -f "$SOURCE/VERSION.json" ]]; then
  echo "Source Knowledge Base version is missing: $SOURCE/VERSION.json"
  exit 1
fi

if [[ "$LIBRARY_ONLY" -eq 0 && ! -f "$SYSTEM_SOURCE/navigation/START_HERE.md" ]]; then
  echo "Source Alliance system navigation is missing: $SYSTEM_SOURCE"
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "Resident workspace not found: $TARGET"
  exit 1
fi

SOURCES=("$SOURCE")
DESTINATIONS=("$DESTINATION")
VALIDATIONS=("VERSION.json")
PREFIXES=("kb")
NAMES=("Knowledge Base")

if [[ "$LIBRARY_ONLY" -eq 0 ]]; then
  SOURCES+=("$SYSTEM_SOURCE")
  DESTINATIONS+=("$SYSTEM_DESTINATION")
  VALIDATIONS+=("navigation/START_HERE.md")
  PREFIXES+=("system")
  NAMES+=("Alliance system navigation")
fi

PACKAGE_VERSION="$(awk -F'"' '/"package_version"/ { print $4; exit }' "$SOURCE/VERSION.json")"
MODE="SharedLayer"
if [[ "$LIBRARY_ONLY" -eq 1 ]]; then
  MODE="LibraryOnly"
fi

echo "Update mode: $MODE"
echo "Dry run: $DRY_RUN"
echo "Target workspace: $TARGET"
echo "Package version: $PACKAGE_VERSION"
echo "Existing destinations are preserved until all staged copies pass validation."
echo "The script will update only:"

for ((INDEX = 0; INDEX < ${#SOURCES[@]}; INDEX++)); do
  SOURCE_PATH="${SOURCES[$INDEX]}"
  DESTINATION_PATH="${DESTINATIONS[$INDEX]}"
  PARENT_PATH="$(dirname "$DESTINATION_PATH")"
  FILE_COUNT="$(find "$SOURCE_PATH" -type f | wc -l | tr -d ' ')"
  DIRECTORY_COUNT="$(find "$SOURCE_PATH" -type d | wc -l | tr -d ' ')"
  CREATE_PARENT="yes"
  REPLACE_EXISTING="no"
  [[ -d "$PARENT_PATH" ]] && CREATE_PARENT="no"
  [[ -e "$DESTINATION_PATH" ]] && REPLACE_EXISTING="yes"
  echo "  - ${NAMES[$INDEX]}"
  echo "    Source: $SOURCE_PATH"
  echo "    Destination: $DESTINATION_PATH"
  echo "    Will create parent folder: $CREATE_PARENT"
  echo "    Will replace existing destination: $REPLACE_EXISTING"
  echo "    Files: $FILE_COUNT; directories: $DIRECTORY_COUNT"
done

echo "The script will not modify:"
for PROTECTED_PATH in \
  "00_Паспорт_рабочего_места" \
  "01_Роль_и_траектория" \
  "02_Рабочий_ритм_и_план_работ" \
  "04_Проекты_и_рабочие_задачи" \
  "05_Встречи_и_цифровой_след" \
  "06_Публикации_и_обновления_платформы" \
  "07_Права_доступы_авторство" \
  "08_Кооперационные_цепочки_и_рынок_роли" \
  "99_Архив_исходников"
do
  echo "  - $PROTECTED_PATH"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry run complete. No files or directories were changed."
  exit 0
fi

STAGES=()
BACKUPS=()
HAD_EXISTING=()
SWAPPED=()

rollback() {
  local status=$?
  trap - ERR
  for ((INDEX = ${#DESTINATIONS[@]} - 1; INDEX >= 0; INDEX--)); do
    local destination_path="${DESTINATIONS[$INDEX]}"
    local stage_path="${STAGES[$INDEX]:-}"
    local backup_path="${BACKUPS[$INDEX]:-}"
    if [[ "${SWAPPED[$INDEX]:-0}" -eq 1 && -e "$destination_path" ]]; then
      rm -rf "$destination_path"
    fi
    if [[ "${HAD_EXISTING[$INDEX]:-0}" -eq 1 && -n "$backup_path" && -e "$backup_path" ]]; then
      mv "$backup_path" "$destination_path"
    fi
    if [[ -n "$stage_path" && -e "$stage_path" ]]; then
      rm -rf "$stage_path"
    fi
  done
  echo "Shared library update failed. Existing destinations were restored when possible."
  exit "$status"
}
trap rollback ERR

for ((INDEX = 0; INDEX < ${#SOURCES[@]}; INDEX++)); do
  SOURCE_PATH="${SOURCES[$INDEX]}"
  DESTINATION_PATH="${DESTINATIONS[$INDEX]}"
  PARENT_PATH="$(dirname "$DESTINATION_PATH")"
  mkdir -p "$PARENT_PATH"
  STAGE_PATH="$(mktemp -d "$PARENT_PATH/.alliance-${PREFIXES[$INDEX]}-stage-XXXXXX")"
  STAGES[$INDEX]="$STAGE_PATH"
  BACKUPS[$INDEX]=""
  HAD_EXISTING[$INDEX]=0
  SWAPPED[$INDEX]=0
  rsync -a "$SOURCE_PATH/" "$STAGE_PATH/"
  test -f "$STAGE_PATH/${VALIDATIONS[$INDEX]}"
done

for ((INDEX = 0; INDEX < ${#SOURCES[@]}; INDEX++)); do
  DESTINATION_PATH="${DESTINATIONS[$INDEX]}"
  PARENT_PATH="$(dirname "$DESTINATION_PATH")"
  if [[ -e "$DESTINATION_PATH" ]]; then
    HAD_EXISTING[$INDEX]=1
    BACKUP_PATH="$PARENT_PATH/.alliance-${PREFIXES[$INDEX]}-backup-$(date +%Y%m%d-%H%M%S)-$$"
    BACKUPS[$INDEX]="$BACKUP_PATH"
    mv "$DESTINATION_PATH" "$BACKUP_PATH"
  fi
  mv "${STAGES[$INDEX]}" "$DESTINATION_PATH"
  SWAPPED[$INDEX]=1
done

trap - ERR
for BACKUP_PATH in "${BACKUPS[@]}"; do
  if [[ -n "$BACKUP_PATH" && -e "$BACKUP_PATH" ]]; then
    rm -rf "$BACKUP_PATH"
  fi
done

echo "Update completed without changing owner passport, roles, work rhythm or private folders."
echo "Version: $DESTINATION/VERSION.json"
if [[ "$LIBRARY_ONLY" -eq 0 ]]; then
  echo "Start here: $SYSTEM_DESTINATION/navigation/START_HERE.md"
fi
