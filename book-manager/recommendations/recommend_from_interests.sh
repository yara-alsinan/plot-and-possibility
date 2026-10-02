#!/usr/bin/env bash
# Match the favorite genres listed in the personal profile.
source "$(dirname "$0")/../common.sh"
awk -F '\t' 'BEGIN { OFS="\t" }
    FILENAME == ARGV[1] { if ($0 != "") favorite[$0]=75-FNR; next }
    FNR > 1 && favorite[$3] {
        print $1,$2,$3,$4,$5,"Interests",favorite[$3],"Matches your interest in " $3
    }
' "$PROFILE/interests.txt" "$CATALOG"
