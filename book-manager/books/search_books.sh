#!/usr/bin/env bash
# Accept a search argument or one line on stdin; storage stays behind the API.
source "$(dirname "$0")/../common.sh"
term="${1:-}"
if [ "$#" -eq 0 ]; then IFS= read -r term || true; fi
if [ -z "$term" ]; then printf 'Enter a search term.\n' >&2; exit 1; fi
exec "$ROOT/data/book_database.sh" search "$term"
