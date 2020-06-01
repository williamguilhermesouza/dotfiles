# !/bin/bas
TEMP_FILE="/tmp/screenlockbg.png"

FONT=$1
FONTSIZE=$2
BACKGROUND=$3
BORDER=$4
THEME=$5
ERROR=$6
WARNING=$7
CIRCLEWIDTH=$8
RINGWIDTH=$9

grim -s 0.1 $TEMP_FILE
swaylock -f -i $TEMP_FILE -s fill \
\
--font-size $FONTSIZE \
--font "$FONT" \
\
--indicator-radius $CIRCLEWIDTH \
--indicator-thickness $RINGWIDTH \
\
--key-hl-color "$THEME" \
--bs-hl-color "$ERROR" \
--caps-lock-key-hl-color "$WARNING" \
--caps-lock-bs-hl-color "$ERROR" \
\
--inside-color "$BACKGROUND" \
--inside-clear-color "$BACKGROUND" \
--inside-caps-lock-color "$BACKGROUND" \
--inside-ver-color "$BACKGROUND" \
--inside-wrong-color "$BACKGROUND" \
\
--line-color "$BORDER" \
--line-clear-color "$BORDER" \
--line-caps-lock-color "$BORDER" \
--line-ver-color "$BORDER" \
--line-wrong-color "$BORDER" \
\
--ring-color "$BACKGROUND" \
--ring-clear-color "$WARNING" \
--ring-caps-lock-color "$WARNING" \
--ring-ver-color "$THEME" \
--ring-wrong-color "$ERROR" \
\
--separator-color "$BORDER" \
\
--text-color "$BORDER" \
--text-clear-color "$BORDER" \
--text-caps-lock-color "$BORDER" \
--text-ver-color "$BORDER" \
--text-wrong-color "$BORDER"

