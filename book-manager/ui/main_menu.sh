#!/usr/bin/env bash
source "$(dirname "$0")/helpers.sh"
while true; do
    gum style --border rounded --border-foreground 212 --padding '1 3' \
        'PLOT & POSSIBILITY' 'Stories to escape into. Ideas to grow with.'
    action=$(gum choose --header 'Your personal bookshelf' \
        'Browse Library' 'Add Book' 'Search Library' 'Get Recommendations' 'My Reading Profile' 'Quit') || exit 0
    case "$action" in
        'Browse Library') "$ROOT/ui/library_screen.sh" browse || true ;;
        'Add Book') "$ROOT/ui/library_screen.sh" add || true ;;
        'Search Library') "$ROOT/ui/library_screen.sh" search || true ;;
        'Get Recommendations') "$ROOT/ui/recommendations_screen.sh" || true ;;
        'My Reading Profile')
            heading 'Comfort reads'
            cat "$PROFILE/interests.txt"
            heading 'Explore something new'
            cat "$PROFILE/discovery.txt"
            printf '\nRecommendations use these shelves and the books you save or rate.\n'
            pause_screen
            ;;
        'Quit') printf 'Happy reading!\n'; exit 0 ;;
    esac
done
