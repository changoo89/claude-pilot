#!/usr/bin/env bash
set -euo pipefail

DIST_DIR="${1:-dist-marketplace}"
RELEASE_BRANCH="${RELEASE_BRANCH:-release}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Publish marketplace content}"

if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN is required" >&2
  exit 1
fi

if [[ -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "GITHUB_REPOSITORY is required (e.g. owner/repo)" >&2
  exit 1
fi

if [[ ! -d "$DIST_DIR" ]]; then
  echo "Missing dist directory: $DIST_DIR" >&2
  exit 1
fi

REMOTE="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

rm -rf .release-branch-tmp
mkdir -p .release-branch-tmp
cp -R "$DIST_DIR/." .release-branch-tmp/

git -C .release-branch-tmp init
git -C .release-branch-tmp checkout -b "$RELEASE_BRANCH"
git -C .release-branch-tmp config user.name "github-actions[bot]"
git -C .release-branch-tmp config user.email "github-actions[bot]@users.noreply.github.com"
git -C .release-branch-tmp add -A
git -C .release-branch-tmp commit -m "$COMMIT_MESSAGE"
git -C .release-branch-tmp remote add origin "$REMOTE"
git -C .release-branch-tmp push --force origin "$RELEASE_BRANCH"

echo "Force-pushed $RELEASE_BRANCH from $DIST_DIR"

