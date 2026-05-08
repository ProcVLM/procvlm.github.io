#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.nvm/nvm.sh"
fi

GITHUB_OWNER="${GITHUB_OWNER:-ProcVLM}"
GITHUB_REPO="${GITHUB_REPO:-procvlm.github.io}"
GITHUB_REMOTE_URL="${GITHUB_REMOTE_URL:-git@github.com:${GITHUB_OWNER}/${GITHUB_REPO}.git}"

case "${1:-}" in
  build)
    npm run build
    ;;
  localhost | dev)
    npm run dev -- --host 127.0.0.1
    ;;
  deploy)
    if ! command -v git >/dev/null 2>&1; then
      echo "git is required for deployment."
      exit 1
    fi

    if ! git config user.name >/dev/null; then
      echo "Missing git user.name. Set it first, for example:"
      echo '  git config user.name "ProcVLM Authors"'
      exit 1
    fi

    if ! git config user.email >/dev/null; then
      echo "Missing git user.email. Set it first, preferably with a GitHub noreply email:"
      echo '  git config user.email "YOUR_ID+YOUR_USERNAME@users.noreply.github.com"'
      exit 1
    fi

    npm run build

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      git init
      git branch -M main
    fi

    if ! git remote get-url origin >/dev/null 2>&1; then
      git remote add origin "$GITHUB_REMOTE_URL"
    fi

    git add .

    if git diff --cached --quiet; then
      echo "No local changes to commit. Pushing current main branch."
    else
      git commit -m "${2:-Update ProcVLM website}"
    fi

    git branch -M main
    git push -u origin main
    ;;
  *)
    cat <<'USAGE'
Usage:
  ./commands.sh build                  # 重新输出静态网页到 dist/
  ./commands.sh localhost              # 启动本地预览: http://127.0.0.1:4321/
  ./commands.sh deploy [commit msg]    # 构建、提交并推送到 GitHub Pages 仓库

Deploy defaults:
  owner:  ProcVLM
  repo:   procvlm.github.io
  remote: git@github.com:ProcVLM/procvlm.github.io.git

Optional overrides:
  GITHUB_OWNER=ProcVLM GITHUB_REPO=procvlm.github.io ./commands.sh deploy
  GITHUB_REMOTE_URL=https://github.com/ProcVLM/procvlm.github.io.git ./commands.sh deploy

Before first use:
  npm install
USAGE
    ;;
esac
