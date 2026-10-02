#!/usr/bin/env bash
# Small shared display functions. Never read or write the library file here.
source "$(dirname "${BASH_SOURCE[0]}")/../common.sh"
require_gum

heading() {
    gum style --foreground 212 --bold "$1"
}

pause_screen() {
    gum input --placeholder 'Press Enter to return to the menu' >/dev/null || true
}

choose_book() {
    local rows="$1" selection number
    selection=$(printf '%s\n' "$rows" | awk -F '\t' '{printf "%d. %s — %s\n",NR,$1,$2}' |
        gum choose --height 10 --header 'Choose a book (Esc to go back)') || return 1
    number="${selection%%.*}"
    printf '%s\n' "$rows" | sed -n "${number}p"
}

choose_status() {
    gum choose --header 'Reading status' --selected="${1:-want-to-read}" \
        'want-to-read' 'owned' 'reading' 'finished'
}

choose_rating() {
    gum choose --header 'Your rating (1 lowest, 5 highest; - means unrated)' \
        --selected="${1:--}" '-' '1' '2' '3' '4' '5'
}

choose_genre() {
    gum choose --header 'Choose a shelf' 'Dystopian' 'Romance' 'Historical Fiction' \
        'History' 'Personal Finance' 'Startups' 'Self-help' 'Other'
}

show_book() {
    local title author genre year status rating link
    IFS=$'\t' read -r title author genre year status rating link <<< "$1"
    heading "$title"
    printf 'By %s\nShelf: %s  |  Year: %s\nStatus: %s  |  Rating: %s\nMore: %s\n\n' \
        "$author" "$genre" "$year" "$status" "$rating" "$link"
}
