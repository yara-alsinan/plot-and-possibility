#!/usr/bin/env bash
# Exact, case-insensitive title lookup in the bundled offline catalog.
# Output: title<TAB>author<TAB>genre<TAB>year<TAB>link. Exit 2 = not found.
source "$(dirname "$0")/../common.sh"
if [ "$#" -lt 1 ]; then printf 'Usage: fetch_book_metadata.sh TITLE [AUTHOR]\n' >&2; exit 1; fi
export LOOKUP_TITLE="$1" LOOKUP_AUTHOR="${2:-}"
awk -F '\t' 'BEGIN { OFS="\t" }
    NR > 1 && tolower($1) == tolower(ENVIRON["LOOKUP_TITLE"]) &&
    (ENVIRON["LOOKUP_AUTHOR"] == "" || tolower($2) == tolower(ENVIRON["LOOKUP_AUTHOR"])) {
        print $1, $2, $3, $4, $5; found=1; exit
    }
    END { if (!found) exit 2 }
' "$CATALOG"
