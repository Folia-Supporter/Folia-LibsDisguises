#!/usr/bin/env bash
set -e

UPSTREAM_REF=$(grep "^upstreamRef=" gradle.properties | cut -d'=' -f2 | tr -d '[:space:]')

if [ -z "$UPSTREAM_REF" ]; then
    echo "ERROR: upstreamRef not found in gradle.properties"
    exit 1
fi

if [ ! -d "src/.git" ]; then
    echo "ERROR: src/ not found. Run ./setup.sh first."
    exit 1
fi

COMMIT_COUNT=$(git -C src rev-list --count "$UPSTREAM_REF"..HEAD)

if [ "$COMMIT_COUNT" -eq 0 ]; then
    echo "No commits ahead of upstreamRef ($UPSTREAM_REF) in src/"
    echo "Nothing to do."
    exit 0
fi

echo "Rebuilding patches from $COMMIT_COUNT commit(s) in src/ since $UPSTREAM_REF..."

rm -rf patches/
mkdir -p patches/

git -C src format-patch "$UPSTREAM_REF"..HEAD --output-directory "../patches/"

echo ""
echo "Generated patches:"
ls patches/*.patch | while read f; do echo "  $f"; done
echo ""
echo "Done! Run 'git add patches/' to stage updated patches."
