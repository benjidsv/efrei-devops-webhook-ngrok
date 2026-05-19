#!/usr/bin/env bash
set -euo pipefail 
 
: "${REPO_URL:?Missing REPO_URL}" 
: "${DEPLOY_DIR:?Missing DEPLOY_DIR}" 
: "${TARGET_BRANCH:=main}" 
 
echo "== Deploy started =="
echo "Repo: $REPO_URL"
echo "Dir:  $DEPLOY_DIR"
echo "Branch: $TARGET_BRANCH" 
 
if [ ! -d "$DEPLOY_DIR/.git" ]; then 
  echo "Cloning..." 
  git clone --branch "$TARGET_BRANCH" "$REPO_URL" "$DEPLOY_DIR"
else 
  echo "Pulling latest..." 
  git -C "$DEPLOY_DIR" fetch --all 
  git -C "$DEPLOY_DIR" checkout "$TARGET_BRANCH" 
  git -C "$DEPLOY_DIR" pull --ff-only 
fi 
 
echo "Installing dependencies..."
cd "$DEPLOY_DIR\deployed-react-app" 
npm install 
 
echo "Stopping previous app (best-effort)..."
# If you use a process manager (recommended), stop it here instead.
# This is intentionally minimal. 
 
echo "Starting app..."
if npm run | grep -qE ' start'; then 
  # if we built our React app app with create-react-app 
  nohup npm run start > app.log 2>&1 & 
  echo "Started with: npm run start"
elif npm run | grep -qE ' dev'; then 
  # if we built our app with vite 
  nohup npm run dev -- --host 0.0.0.0 > app.log 2>&1 &echo "Started with: npm run dev"
else 
  echo "No start/dev script found in package.json" 
  exit 1 
fi 
 
echo "== Deploy done =="