#!/usr/bin/env bash
# Favor genres from saved books; finished/high-rated books count more.
source "$(dirname "$0")/../common.sh"
[ -r "$CATALOG" ] || { printf 'Cannot read the book catalog.\n' >&2; exit 1; }
"$ROOT/data/book_database.sh" list | awk -F '\t' -v catalog="$CATALOG" '
    BEGIN { OFS="\t" }
    {
        if ($6 != "-" && $6+0 <= 2) next
        weight[$3] += ($5 == "finished" ? 3 : 1) + ($6 == "-" ? 0 : $6)
    }
    END {
        getline < catalog
        while ((getline < catalog) > 0) {
            if (weight[$3] > 0)
                print $1,$2,$3,$4,$5,"History",80+weight[$3],"Your saved or highly rated " $3 " books"
        }
        close(catalog)
    }
'
