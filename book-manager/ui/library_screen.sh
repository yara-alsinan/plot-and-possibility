#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"
workflow="$ROOT/workflows/manage_library.sh"
case "${1:-browse}" in
    add)
        heading 'Add a book'
        title=$(gum input --placeholder 'Title, for example The Hunger Games') || exit 0
        [ -n "$title" ] || exit 0
        if metadata=$("$workflow" metadata "$title"); then
            IFS=$'\t' read -r title author genre year link <<< "$metadata"
            printf 'Found in the offline catalog: %s by %s (%s, %s)\n' "$title" "$author" "$genre" "$year"
            if ! gum confirm 'Use this match?'; then exit 0; fi
        else
            printf 'Not in the small offline catalog. Enter the details below.\n'
            author=$(gum input --placeholder 'Author') || exit 0
            genre=$(choose_genre) || exit 0
            year=$(gum input --placeholder 'Publication year, or - if unknown' --value '-') || exit 0
            link='-'
        fi
        status=$(choose_status) || exit 0
        rating=$(choose_rating) || exit 0
        if "$workflow" add "$title" "$author" "$genre" "$year" "$status" "$rating" "$link"; then
            heading 'Saved to your library.'
        fi
        pause_screen
        ;;
    browse|search)
        if [ "${1:-browse}" = search ]; then
            term=$(gum input --placeholder 'Search title, author, shelf, or status') || exit 0
            [ -n "$term" ] || exit 0
            rows=$("$workflow" search "$term")
        else
            rows=$("$workflow" list)
        fi
        if [ -z "$rows" ]; then
            printf 'No books to show. Use Add Book to start your library.\n'
            pause_screen
            exit 0
        fi
        heading 'Your library'
        row=$(choose_book "$rows") || exit 0
        show_book "$row"
        IFS=$'\t' read -r title author genre year status rating link <<< "$row"
        action=$(gum choose 'Update status' 'Update rating' 'Back') || exit 0
        case "$action" in
            'Update status')
                status=$(choose_status "$status") || exit 0
                "$workflow" update-status "$title" "$author" "$status"
                heading 'Status updated.'
                pause_screen
                ;;
            'Update rating')
                rating=$(choose_rating "$rating") || exit 0
                "$workflow" update-rating "$title" "$author" "$rating"
                heading 'Rating updated.'
                pause_screen
                ;;
        esac
        ;;
    *) printf 'Usage: library_screen.sh add|browse|search\n' >&2; exit 1 ;;
esac
