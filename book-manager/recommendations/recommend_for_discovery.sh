#!/usr/bin/env bash
# Explore learning goals, with preference for genres absent from the library.
source "$(dirname "$0")/../common.sh"
LIBRARY_SNAPSHOT="$("$ROOT/data/book_database.sh" list)"
export LIBRARY_SNAPSHOT
awk -F '\t' '
    BEGIN {
        OFS="\t"
        n=split(ENVIRON["LIBRARY_SNAPSHOT"], rows, "\n")
        for (i=1; i<=n; i++) { split(rows[i], fields, "\t"); seen[fields[3]]++ }
    }
    FILENAME == ARGV[1] { if ($0 != "") goal[$0]=65-FNR; next }
    FNR > 1 && goal[$3] {
        print $1,$2,$3,$4,$5,"Discovery",goal[$3]-(seen[$3] ? 10 : 0),"Try " $3 ": " $6
    }
' "$PROFILE/discovery.txt" "$CATALOG"
