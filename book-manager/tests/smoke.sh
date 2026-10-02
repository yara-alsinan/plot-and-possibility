#!/usr/bin/env bash
# Integration checks use a temporary library, never your personal books.
source "$(dirname "$0")/../common.sh"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT
export BOOK_DB="$test_dir/library.csv"
db="$ROOT/data/book_database.sh"
manage="$ROOT/workflows/manage_library.sh"
fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
expect_failure() { if "$@" >"$test_dir/error" 2>&1; then fail 'Expected command to fail'; fi; }

while IFS= read -r script; do bash -n "$script"; done < <(find "$ROOT" -name '*.sh')
"$db" init
[ -z "$("$db" list)" ] || fail 'New library is not empty'
"$manage" add 'The Hunger Games' 'Suzanne Collins' Unknown - finished 5 -
row=$("$db" list)
[[ "$row" == *$'Dystopian\t2008\tfinished\t5\thttps://'* ]] || fail 'Metadata enrichment'
"$db" exists 'the hunger games' 'SUZANNE COLLINS' || fail 'Case-insensitive existence'
expect_failure "$manage" add ' THE HUNGER GAMES ' 'Suzanne Collins' Dystopian 2008 reading - -

"$manage" add 'A "Quoted", Book' 'Test Author' History 2020 owned - -
row=$("$ROOT/books/search_books.sh" 'quoted')
[[ "$row" == 'A "Quoted", Book'* ]] || fail 'CSV quoting round trip'
[ "$(printf 'quoted\n' | "$ROOT/books/search_books.sh")" = "$row" ] || fail 'Search from stdin'
"$manage" update-status 'A "Quoted", Book' 'Test Author' reading
"$manage" update-rating 'A "Quoted", Book' 'Test Author' 4
[[ "$("$db" search 'quoted')" == *$'reading\t4\t-' ]] || fail 'Update persistence'
expect_failure "$db" update-rating 'A "Quoted", Book' 'Test Author' 6
expect_failure "$db" update-status 'A "Quoted", Book' 'Test Author' invalid
expect_failure "$db" add $'bad\ttitle' Author History 2020 owned - -
expect_failure "$ROOT/books/fetch_book_metadata.sh" 'Not in the catalog'

"$ROOT/workflows/get_recommendations.sh" > "$test_dir/results" 2> "$test_dir/progress"
[ -s "$test_dir/results" ] || fail 'Missing recommendations'
if grep -q 'The Hunger Games' "$test_dir/results"; then fail 'Recommended a saved book'; fi
for strategy in History Interests Discovery; do
    grep -q "$strategy" "$test_dir/results" || fail "Missing $strategy results"
done
[ "$(grep -c 'running' "$test_dir/progress")" -eq 3 ] || fail 'Missing running progress'
[ "$(grep -c 'done' "$test_dir/progress")" -eq 3 ] || fail 'Missing completion progress'
awk -F '\t' 'NF!=8 {exit 1} {k=tolower($1 FS $2); if (seen[k]++) exit 1}' "$test_dir/results" || fail 'Duplicate or malformed shortlist'

# Repeat the same candidates: the refiner must still emit each book once.
cat "$test_dir/results" "$test_dir/results" | "$ROOT/recommendations/refine_recommendations.sh" > "$test_dir/refined"
cmp -s "$test_dir/results" "$test_dir/refined" || fail 'Refinement is not idempotent'
IFS=$'\t' read -r title author genre year link strategy score reason < "$test_dir/results"
"$manage" add "$title" "$author" "$genre" "$year" want-to-read - "$link"
cat "$test_dir/results" | "$ROOT/recommendations/refine_recommendations.sh" > "$test_dir/after-save"
if cut -f1 "$test_dir/after-save" | grep -Fxq "$title"; then fail 'Saved recommendation remains'; fi

# A failed component must fail the whole workflow, not present partial success.
expect_failure env BOOK_PROFILE="$test_dir/missing-profile" "$ROOT/workflows/get_recommendations.sh"
expect_failure env BOOK_CATALOG="$test_dir/missing-catalog" "$ROOT/workflows/get_recommendations.sh"
printf 'PASS: syntax, metadata, CSV quoting, search, updates, validation, recommendations, filtering, and failure propagation.\n'
