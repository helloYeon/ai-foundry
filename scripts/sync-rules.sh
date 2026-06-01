#!/bin/bash
#
# rules/*.mdc を指定したプロジェクトの各AIツール形式に同期するスクリプト
#
# 対応ツール:
#   - Kiro:   <target>/.kiro/steering/*.md
#   - Cursor: <target>/.cursor/rules/*.mdc
#
# 使い方:
#   ./scripts/sync-rules.sh --target ~/works/my-project [--dry-run]
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$ROOT_DIR/rules"

DRY_RUN=false
TARGET_DIR=""

# 引数解析
while [[ $# -gt 0 ]]; do
    case "$1" in
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 --target <directory> [--dry-run]"
            exit 1
            ;;
    esac
done

if [[ -z "$TARGET_DIR" ]]; then
    echo "Error: --target が必要です"
    echo "Usage: $0 --target <directory> [--dry-run]"
    exit 1
fi

# チルダ展開
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

if [[ "$DRY_RUN" == "true" ]]; then
    echo "[dry-run] 実際のファイル操作は行いません"
fi

# front-matterの変換関数（Kiro用）
convert_frontmatter_for_kiro() {
    local file="$1"
    local description alwaysApply inclusion
    local in_frontmatter=false
    local frontmatter_count=0
    local body=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "---" ]]; then
            ((frontmatter_count++))
            if [[ $frontmatter_count -eq 1 ]]; then
                in_frontmatter=true
                continue
            elif [[ $frontmatter_count -eq 2 ]]; then
                in_frontmatter=false
                continue
            fi
        fi

        if [[ "$in_frontmatter" == "true" ]]; then
            if [[ "$line" =~ ^description:\ *(.*) ]]; then
                description="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^alwaysApply:\ *(.*) ]]; then
                alwaysApply="${BASH_REMATCH[1]}"
            fi
        else
            body+="$line"$'\n'
        fi
    done < "$file"

    if [[ "$alwaysApply" == "true" ]]; then
        inclusion="always"
    else
        inclusion="manual"
    fi

    echo "---"
    echo "description: $description"
    echo "inclusion: $inclusion"
    echo "---"
    printf '%s' "$body"
}

# Cursor/Windsurf用（そのままコピー）
convert_passthrough() {
    cat "$1"
}

# ディレクトリ作成
ensure_dir() {
    local dir="$1"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[dry-run] mkdir -p $dir"
    else
        mkdir -p "$dir"
    fi
}

# ファイル書き込み
write_file() {
    local content="$1"
    local dest="$2"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[dry-run] write: $dest"
    else
        echo "$content" > "$dest"
        echo "  wrote: $dest"
    fi
}

# メイン処理
main() {
    echo "=== AI Rules Sync ==="
    echo "Source: $SOURCE_DIR"
    echo "Target: $TARGET_DIR"
    echo ""

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Error: $SOURCE_DIR が見つかりません"
        exit 1
    fi

    if [[ ! -d "$TARGET_DIR" ]]; then
        echo "Error: $TARGET_DIR が見つかりません"
        exit 1
    fi

    local mdc_files=("$SOURCE_DIR"/*.mdc)
    if [[ ! -e "${mdc_files[0]}" ]]; then
        echo "Error: $SOURCE_DIR に .mdc ファイルがありません"
        exit 1
    fi

    # Kiro
    echo "[kiro] -> .kiro/steering/"
    ensure_dir "$TARGET_DIR/.kiro/steering"
    for mdc_file in "$SOURCE_DIR"/*.mdc; do
        local basename=$(basename "$mdc_file" .mdc)
        local content=$(convert_frontmatter_for_kiro "$mdc_file")
        write_file "$content" "$TARGET_DIR/.kiro/steering/$basename.md"
    done
    echo ""

    # Cursor
    echo "[cursor] -> .cursor/rules/"
    ensure_dir "$TARGET_DIR/.cursor/rules"
    for mdc_file in "$SOURCE_DIR"/*.mdc; do
        local basename=$(basename "$mdc_file" .mdc)
        local content=$(convert_passthrough "$mdc_file")
        write_file "$content" "$TARGET_DIR/.cursor/rules/$basename.mdc"
    done
    echo ""

    echo "=== 完了 ==="
}

main
