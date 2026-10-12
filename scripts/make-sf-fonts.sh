#!/bin/zsh
# Generates static SF Pro weights from this Mac's system font into assets/fonts/sf/.
# SF Pro is licensed for Apple platforms only: the output is gitignored and must never be
# committed or distributed. Personal sideloaded builds only.
set -euo pipefail
cd "${0:A:h:h}"
OUT=assets/fonts/sf
VENV="${TMPDIR:-/tmp}/sf-fontvenv"
[[ -x $VENV/bin/python ]] || { python3 -m venv $VENV && $VENV/bin/pip -q install fonttools; }
mkdir -p $OUT
# Apple's named weights: Light 274, Regular 400, Medium 510, Semibold 590, Bold 700, Heavy 860
for spec in Light:274 Regular:400 Medium:510 Semibold:590 Bold:700 Heavy:860; do
  name=${spec%%:*}; w=${spec##*:}
  $VENV/bin/fonttools varLib.instancer -q /System/Library/Fonts/SFNS.ttf wght=$w opsz=17 wdth=100 GRAD=400 -o $OUT/SFProText-$name.ttf
  $VENV/bin/fonttools varLib.instancer -q /System/Library/Fonts/SFNS.ttf wght=$w opsz=28 wdth=100 GRAD=400 -o $OUT/SFProDisplay-$name.ttf
done
for spec in Regular:400 Semibold:590; do
  name=${spec%%:*}; w=${spec##*:}
  $VENV/bin/fonttools varLib.instancer -q /System/Library/Fonts/SFNSItalic.ttf wght=$w opsz=17 wdth=100 GRAD=400 -o $OUT/SFProText-${name}Italic.ttf 2>/dev/null \
    || $VENV/bin/fonttools varLib.instancer -q /System/Library/Fonts/SFNSItalic.ttf wght=$w opsz=17 -o $OUT/SFProText-${name}Italic.ttf
done
ls $OUT
