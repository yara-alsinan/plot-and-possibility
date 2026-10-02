#!/usr/bin/env bash
# Shared paths and shell settings; no application logic lives here.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATALOG="${BOOK_CATALOG:-$ROOT/catalog/books.tsv}"
PROFILE="${BOOK_PROFILE:-$ROOT/config}"
export BOOK_DB="${BOOK_DB:-$ROOT/data/books.csv}"
export LC_ALL=C

require_gum() {
    if ! command -v gum >/dev/null 2>&1; then
        printf 'Gum is required. Install it with: brew install gum\n' >&2
        exit 1
    fi
}
