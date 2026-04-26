#!/usr/bin/env bash
set -e

UPSTREAM_URL=$(grep "^upstreamUrl=" gradle.properties | cut -d'=' -f2 | tr -d '[:space:]')
UPSTREAM_REF=$(grep "^upstreamRef=" gradle.properties | cut -d'=' -f2 | tr -d '[:space:]')

if [ -z "$UPSTREAM_URL" ] || [ -z "$UPSTREAM_REF" ]; then
    echo "ERROR: upstreamUrl or upstreamRef not found in gradle.properties"
    exit 1
fi

# Clone upstream into src/ if not already present
if [ ! -d "src/.git" ]; then
    echo "Cloning upstream ($UPSTREAM_URL)..."
    git -c core.autocrlf=false clone "$UPSTREAM_URL" src
    git -C src config core.autocrlf false
else
    echo "src/ already exists, fetching latest..."
    git -C src fetch origin
fi

echo "Checking out upstream ref: $UPSTREAM_REF"
git -C src checkout -f "$UPSTREAM_REF"

# Clean any leftover state from previous patch attempts
git -C src am --abort 2>/dev/null || true

PATCHES=$(ls patches/*.patch 2>/dev/null | sort)

if [ -z "$PATCHES" ]; then
    echo "No patches found in patches/ — setup complete (clean upstream)."
    exit 0
fi

echo "Applying patches..."
for patch in $PATCHES; do
    echo "  -> $patch"
    git -C src am --ignore-whitespace "../$patch" || {
        echo ""
        echo "CONFLICT: Failed to apply $patch"
        echo "Go into src/, resolve conflicts, then run:"
        echo "  git -C src add -A && git -C src am --continue"
        exit 1
    }
done

echo ""
echo "Done! Source is ready in src/"
echo "To build: cd src && ./gradlew build"
