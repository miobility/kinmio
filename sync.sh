#!/bin/bash
# Sync le prototype kinmio depuis le dossier de travail vers GitHub.
# Usage : ./sync.sh   (depuis le dossier kinmio-repo)
set -e

SRC="/Users/benja/Desktop/APP KINMIO"
REPO="$SRC/kinmio-repo"
FILES="index.html kinmio_logo_app.png kinmio_logo_app_light.png kinmio_n.png kinmio_n_light.png"

cd "$REPO"

for f in $FILES; do
  if [ -f "$SRC/$f" ]; then
    cp "$SRC/$f" "$REPO/$f"
  fi
done

git add -A

if git diff --cached --quiet; then
  echo "Rien de nouveau à envoyer."
  exit 0
fi

git commit -m "Sync $(date '+%Y-%m-%d %H:%M')"
git push origin main
echo "OK — envoyé sur https://github.com/miobility/kinmio"
