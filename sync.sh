#!/bin/bash
# Sync le prototype kinmio depuis le dossier de travail vers GitHub.
# Usage : ./sync.sh            (depuis le dossier kinmio-repo)
#         ./sync.sh --force    (passe outre le garde-fou, en connaissance de cause)
#
# GARDE-FOU (sept. 2026) — deux sessions Claude (design et dev) travaillent sur le MÊME fichier
# /Users/benja/Desktop/APP KINMIO/index.html. Si l'une garde en mémoire une version lue avant que
# l'autre n'écrive, elle réécrit par-dessus et fait disparaître le travail de l'autre sans bruit ;
# le sync le pousse ensuite comme s'il s'agissait d'une modification normale. Ce script vérifie
# donc, avant de commiter, que le fichier de travail contient toujours ce que les derniers commits
# ont apporté. Il refuse d'envoyer sinon.
set -e

SRC="/Users/benja/Desktop/APP KINMIO"
REPO="$SRC/kinmio-repo"
FILES="index.html kinmio_logo_app.png kinmio_logo_app_light.png kinmio_n.png kinmio_n_light.png kinmio_logo.jpeg Marc.jpg Sophie.jpg female1.jpg male1.jpg benjamin.webp shadow.jpg shadow.mp4 onboarding.mp4 onboarding2.mp4 ob_vision.mp4 ob_demo_step1.mp4 ob_demo_step2.mp4 ob_demo_step3.mp4 programme-cardio.jpg programme-entretien.jpg programme-mobilite.jpg programme-renforcement.jpg exercise-01.jpg exercise-02.jpg exercise-03.jpg exercise-04.jpg exercise-05.jpg exercise-06.jpg exercise-07.jpg exercise-08.jpg exercise-09.jpg exercise-10.jpg exercise-11.jpg exercise-12.jpg exercise-13.jpg exercise-14.jpg exercise-15.jpg exercise-16.jpg exercise-17.jpg exercise-18.jpg exercise-19.jpg exercise-20.jpg"

FORCE=0
[ "$1" = "--force" ] && FORCE=1

cd "$REPO"

# --- 1. Récupérer d'abord ce que l'autre session a poussé ----------------------------------------
# Absent jusqu'ici : le script copiait puis poussait, et un push rejeté laissait le dépôt à moitié
# écrasé. On se met à jour AVANT de toucher quoi que ce soit.
# --autostash : le dépôt contient presque toujours des copies non commitées (le sync précédent, ou
# ce script lui-même) — sans ça le pull refuse de démarrer et le sync ne part jamais.
echo "→ Récupération de ce qui est déjà sur GitHub…"
git pull --rebase --autostash origin main

# --- 2. Garde-fou : le fichier de travail défait-il du travail déjà poussé ? ----------------------
# On prend les lignes ajoutées par les 5 derniers commits et on vérifie qu'elles sont toujours dans
# le fichier de travail. Les lignes courtes (accolades, balises isolées) sont écartées : elles
# apparaissent des dizaines de fois et ne prouvent rien.
if [ -f "$SRC/index.html" ] && git rev-parse HEAD >/dev/null 2>&1; then
  BASE=$(git rev-list --max-count=6 HEAD | tail -1)
  PERDUES=$(git diff "$BASE" HEAD -- index.html \
    | grep '^+' | grep -v '^+++' | cut -c2- \
    | awk 'length($0) > 40' \
    | sort -u \
    | while IFS= read -r ligne; do
        grep -Fqx -- "$ligne" "$SRC/index.html" || printf '%s\n' "$ligne"
      done)
  NB=$(printf '%s' "$PERDUES" | grep -c . || true)

  if [ "$NB" -gt 0 ]; then
    echo
    echo "╭─────────────────────────────────────────────────────────────────────╮"
    echo "│  ARRÊT — le fichier de travail ne contient plus $NB ligne(s) que    "
    echo "│  les derniers commits avaient apportées.                            │"
    echo "╰─────────────────────────────────────────────────────────────────────╯"
    echo
    echo "C'est la signature d'une session qui a écrasé l'autre : elle avait lu"
    echo "le fichier avant, elle l'a réécrit après, et le travail d'entre-deux a"
    echo "disparu. Envoyer maintenant le pousserait sur GitHub."
    echo
    echo "Lignes manquantes (10 premières) :"
    printf '%s\n' "$PERDUES" | head -10 | sed 's/^/    /' | cut -c1-110
    echo
    echo "Que faire :"
    echo "  • demander à la session concernée de relire index.html et de refaire"
    echo "    sa modification par-dessus la version à jour ;"
    echo "  • ou, si ces lignes ont été supprimées EXPRÈS : ./sync.sh --force"
    echo
    if [ "$FORCE" -eq 0 ]; then
      exit 1
    fi
    echo "⚠  --force : on envoie quand même."
    echo
  else
    echo "✓ Garde-fou : rien de perdu depuis les derniers commits."
  fi
fi

# --- 3. Copier et envoyer -------------------------------------------------------------------------
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

git diff --cached --stat
git commit -m "Sync $(date '+%Y-%m-%d %H:%M')"
git push origin main
echo "OK — envoyé sur https://github.com/miobility/kinmio"
