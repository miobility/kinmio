#!/bin/bash
# Sync le prototype kinmio depuis le dossier de travail vers GitHub.
# Usage : ./sync.sh   (depuis le dossier kinmio-repo)
set -e

SRC="/Users/benja/Desktop/APP KINMIO"
REPO="$SRC/kinmio-repo"
FILES="index.html kinmio_logo_app.png kinmio_logo_app_light.png kinmio_n.png kinmio_n_light.png kinmio_logo.jpeg Marc.jpg Sophie.jpg female1.jpg male1.jpg benjamin.webp shadow.jpg shadow.mp4 onboarding.mp4 onboarding2.mp4 ob_vision.mp4 ob_demo_step1.mp4 ob_demo_step2.mp4 ob_demo_step3.mp4 programme-cardio.jpg programme-entretien.jpg programme-mobilite.jpg programme-renforcement.jpg exercise-01.jpg exercise-02.jpg exercise-03.jpg exercise-04.jpg exercise-05.jpg exercise-06.jpg exercise-07.jpg exercise-08.jpg exercise-09.jpg exercise-10.jpg exercise-11.jpg exercise-12.jpg exercise-13.jpg exercise-14.jpg exercise-15.jpg exercise-16.jpg exercise-17.jpg exercise-18.jpg exercise-19.jpg exercise-20.jpg"

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
