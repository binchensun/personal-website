#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://binchensun.github.io}"
PUBLIC_DIR="${PUBLIC_DIR:-public}"
DEPLOY_MESSAGE="${1:-Deploy site}"
SOURCE_MESSAGE="${2:-Update website source}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${repo_root}"

if ! command -v hugo >/dev/null 2>&1; then
  echo "Error: hugo is not installed or is not on PATH." >&2
  exit 1
fi

if [[ ! -d "${PUBLIC_DIR}/.git" ]]; then
  echo "Error: ${PUBLIC_DIR} is not initialized as the publishing repository." >&2
  echo "Try: git submodule update --init --recursive" >&2
  exit 1
fi

source_branch="$(git branch --show-current)"
public_branch="$(git -C "${PUBLIC_DIR}" branch --show-current)"

if [[ -z "${source_branch}" ]]; then
  echo "Error: source repository is in detached HEAD state." >&2
  exit 1
fi

if [[ -z "${public_branch}" ]]; then
  echo "Error: ${PUBLIC_DIR} repository is in detached HEAD state." >&2
  exit 1
fi

echo "Building site with base URL: ${BASE_URL}"
hugo --gc --minify -b "${BASE_URL}"

echo "Committing generated site in ${PUBLIC_DIR}/..."
git -C "${PUBLIC_DIR}" add -A -- . ':(exclude).DS_Store' ':(exclude)**/.DS_Store'
if git -C "${PUBLIC_DIR}" diff --cached --quiet --exit-code; then
  echo "No generated-site changes to commit."
else
  git -C "${PUBLIC_DIR}" commit -m "${DEPLOY_MESSAGE}"
fi

echo "Pushing generated site to origin/${public_branch}..."
git -C "${PUBLIC_DIR}" push origin "${public_branch}"

echo "Committing source repository changes..."
git add -A -- . ':(exclude).DS_Store' ':(exclude)**/.DS_Store'
if git diff --cached --quiet --exit-code; then
  echo "No source changes to commit."
else
  git commit -m "${SOURCE_MESSAGE}"
fi

echo "Pushing source repository to origin/${source_branch}..."
git push origin "${source_branch}"

echo "Deployment complete."
