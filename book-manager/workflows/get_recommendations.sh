#!/usr/bin/env bash
# Each agent owns an output file. Progress goes to stderr, data to stdout.
source "$(dirname "$0")/../common.sh"
work="$(mktemp -d)"
pid_list=''
cleanup() {
    for pid in $pid_list; do kill "$pid" 2>/dev/null || true; done
    rm -rf "$work"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
agents=(history interests discovery)
scripts=(recommend_from_history recommend_from_interests recommend_for_discovery)
for i in 0 1 2; do
    printf '[%s] running\n' "${agents[$i]}" >&2
    "$ROOT/recommendations/${scripts[$i]}.sh" > "$work/${agents[$i]}.tsv" &
    pids[$i]=$! # Save the background process ID so we can wait for this agent.
    pid_list="$pid_list ${pids[$i]}"
done
failed=0
for i in 0 1 2; do
    if wait "${pids[$i]}"; then
        printf '[%s] done\n' "${agents[$i]}" >&2
    else
        printf '[%s] failed\n' "${agents[$i]}" >&2
        failed=1
    fi
done
pid_list=''
[ "$failed" -eq 0 ] || exit 1
printf 'Combining candidates and refining your shortlist...\n' >&2
# This is the required meaningful pipe: combined candidates become stdin.
cat "$work/history.tsv" "$work/interests.tsv" "$work/discovery.tsv" |
    "$ROOT/recommendations/refine_recommendations.sh"
