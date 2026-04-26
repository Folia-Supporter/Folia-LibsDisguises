#!/usr/bin/env bash
set -e

OLD_REF=$(grep "^upstreamRef=" gradle.properties | cut -d'=' -f2 | tr -d '[:space:]')

if [ -z "$OLD_REF" ]; then
    echo "ERROR: upstreamRef not found in gradle.properties"
    exit 1
fi

if [ ! -d "src/.git" ]; then
    echo "ERROR: src/ not found. Run ./setup.sh first."
    exit 1
fi

echo "Fetching upstream..."
git -C src fetch origin

NEW_REF=$(git -C src rev-parse origin/master)

if [ "$OLD_REF" = "$NEW_REF" ]; then
    echo "Already up to date (upstream is still ${OLD_REF:0:12})"
    exit 0
fi

echo "Rebasing our commits onto new upstream..."
echo "  old: ${OLD_REF:0:12}"
echo "  new: ${NEW_REF:0:12}"
echo ""

git -C src rebase --onto "$NEW_REF" "$OLD_REF" || {
    echo ""
    echo "CONFLICT during rebase. Go into src/, resolve conflicts, then run:"
    echo "  git -C src add -A && git -C src rebase --continue"
    echo "  ./update-upstream.sh --finish $NEW_REF  (to finalize)"
    exit 1
}

# Update upstreamRef
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/^upstreamRef=.*/upstreamRef=$NEW_REF/" gradle.properties
else
    sed -i "s/^upstreamRef=.*/upstreamRef=$NEW_REF/" gradle.properties
fi

./make-patches.sh

git add gradle.properties patches/
git commit -m "Update upstream to ${NEW_REF:0:12}"

echo ""
echo "Done! Updated upstream from ${OLD_REF:0:12} to ${NEW_REF:0:12}"
