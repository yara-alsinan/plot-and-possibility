#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"
heading 'A little familiar. A little unexpected.'
printf 'Finding books from your library, your interests, and your learning goals.\n'
# The workflow streams running/done messages to the terminal on stderr.
if ! rows=$("$ROOT/workflows/get_recommendations.sh"); then
    printf 'Recommendations could not finish. See the error above.\n' >&2
    pause_screen
    exit 1
fi
if [ -z "$rows" ]; then
    printf 'No new matches in this small catalog. Add more titles to catalog/books.tsv.\n'
    pause_screen
    exit 0
fi
printf '\n'
while IFS=$'\t' read -r title author genre year link strategy score reason; do
    heading "$title — $author"
    printf '  %s | %s\n  %s\n\n' "$strategy" "$genre" "$reason"
done <<< "$rows"
row=$(choose_book "$rows") || exit 0
IFS=$'\t' read -r title author genre year link strategy score reason <<< "$row"
printf '\n%s (%s)\n%s\nMore: %s\n' "$title" "$year" "$reason" "$link"
if gum confirm 'Save this book to your want-to-read list?'; then
    if "$ROOT/workflows/manage_library.sh" add "$title" "$author" "$genre" "$year" 'want-to-read' '-' "$link"; then
        heading 'Saved. It will be excluded from future recommendations.'
    fi
fi
pause_screen
