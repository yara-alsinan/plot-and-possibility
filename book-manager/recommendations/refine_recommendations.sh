#!/usr/bin/env bash
# Read candidates on stdin. Remove saved books and duplicates, then keep a
# diverse shortlist: at most two per strategy and one per strategy/genre.
source "$(dirname "$0")/../common.sh"
LIBRARY_SNAPSHOT="$("$ROOT/data/book_database.sh" list)"
export LIBRARY_SNAPSHOT
sort -t $'\t' -k7,7nr -k1,1 | awk -F '\t' '
    function key(title, author, result) {
        gsub(/^ +| +$/, "", title); gsub(/^ +| +$/, "", author)
        result=tolower(title "\t" author)
        gsub(/ +/, " ", result)
        return result
    }
    BEGIN {
        n=split(ENVIRON["LIBRARY_SNAPSHOT"], rows, "\n")
        for (i=1; i<=n; i++) {
            split(rows[i], fields, "\t"); saved[key(fields[1],fields[2])]=1
        }
    }
    NF == 8 {
        id=key($1,$2)
        if (saved[id] || used[id] || count[$6]>=2 || genre[$6 SUBSEP $3]) next
        print
        used[id]=1; count[$6]++; genre[$6 SUBSEP $3]=1
    }
'
