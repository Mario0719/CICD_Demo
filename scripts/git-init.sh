#!/usr/bin/env bash
# 首次把 CICD_Demo 纳入 Git（不自动 push，需你自己加 remote）
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Already a git repository."
  git status -sb
  exit 0
fi

git init
git add .
git commit -m "$(cat <<'EOF'
CICD Demo: login MVVM, unit tests, fastlane CI

- Step 1: LoginViewModel + tests
- Step 2: fastlane test
- Step 3: ci-local.sh + GitHub Actions
EOF
)"

git branch -M main

echo ""
echo "Done. Next:"
echo "  1. Create empty repo on GitHub (no README)"
echo "  2. git remote add origin git@github.com:YOUR_USER/CICD_Demo.git"
echo "  3. git push -u origin main"
echo "  4. Follow STEP3B.md for branch protection"
