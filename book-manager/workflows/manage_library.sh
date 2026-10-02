#!/usr/bin/env bash
# Coordinate library operations. The UI supplies input; the data layer stores it.
source "$(dirname "$0")/../common.sh"
action="${1:-}"
if [ "$#" -gt 0 ]; then shift; fi
case "$action" in
    list) exec "$ROOT/data/book_database.sh" list ;;
    search) exec "$ROOT/books/search_books.sh" "$@" ;;
    metadata) exec "$ROOT/books/fetch_book_metadata.sh" "$@" ;;
    add)
        # UI arguments: title author genre year status rating link.
        [ "$#" -eq 7 ] || { printf 'Add needs seven fields.\n' >&2; exit 1; }
        title="$1"; author="$2"; genre="$3"; year="$4"; status="$5"; rating="$6"; link="$7"
        # Fill missing metadata only; preserve any deliberate user edits.
        if metadata=$("$ROOT/books/fetch_book_metadata.sh" "$title" "$author"); then
            IFS=$'\t' read -r unused_title unused_author found_genre found_year found_link <<< "$metadata"
            [ "$genre" != 'Unknown' ] || genre="$found_genre"
            [ "$year" != '-' ] || year="$found_year"
            [ "$link" != '-' ] || link="$found_link"
        fi
        exec "$ROOT/data/book_database.sh" add "$title" "$author" "$genre" "$year" "$status" "$rating" "$link"
        ;;
    update-status|update-rating) exec "$ROOT/data/book_database.sh" "$action" "$@" ;;
    *) printf 'Usage: manage_library.sh list|search|metadata|add|update-status|update-rating ...\n' >&2; exit 1 ;;
esac
