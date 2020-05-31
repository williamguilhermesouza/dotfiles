# !/bin/bash

FONT=$1
FONT_MONO=$2
FONTSIZE=$3

LINE_PADDING=$4
INNER_PADDING=$5

TERMINAL_CONFIG=$6
LAUNCHER_CONFIG=$7

FOREGROUND=$8
BACKGROUND=$9

BLACK=${10}
RED=${11}
GREEN=${12}
YELLOW=${13}
BLUE=${14}
MAGENTA=${15}
CYAN=${16}
WHITE=${17}

ACC_BLACK=${18}
ACC_RED=${19}
ACC_GREEN=${20}
ACC_YELLOW=${21}
ACC_BLUE=${22}
ACC_MAGENTA=${23}
ACC_CYAN=${24}
ACC_WHITE=${25}

mkdir -p $(dirname $TERMINAL_CONFIG)
mkdir -p $(dirname $LAUNCHER_CONFIG)

printf -v COLORS_CONTENT "\
colors:\n\
  primary:\n\
    background: '$BACKGROUND'\n\
    foreground: '$FOREGROUND'\n\
  normal:\n\
    black:   '$BLACK'\n\
    red:     '$RED'\n\
    green:   '$GREEN'\n\
    yellow:  '$YELLOW'\n\
    blue:    '$BLUE'\n\
    magenta: '$MAGENTA'\n\
    cyan:    '$CYAN'\n\
    white:   '$WHITE'\n\
  bright:\n\
    black:   '$ACC_BLACK'\n\
    red:     '$ACC_RED'\n\
    green:   '$ACC_GREEN'\n\
    yellow:  '$ACC_YELLOW'\n\
    blue:    '$ACC_BLUE'\n\
    magenta: '$ACC_MAGENTA'\n\
    cyan:    '$ACC_CYAN'\n\
    white:   '$ACC_WHITE'\n\

"

printf -v FONT_MONO_CONTENT "\
font:\n\
  normal:\n\
    family: $FONT_MONO\n\
    style: Medium\n\
  bold:\n\
    family: $FONT_MONO\n\
    style: Bold\n\
  italic:\n\
    family: $FONT_MONO\n\
    style: Regular\n\
"

printf -v FONT_CONTENT "\
font:\n\
  normal:\n\
    family: $FONT\n\
    style: Medium\n\
  bold:\n\
    family: $FONT\n\
    style: Bold\n\
  italic:\n\
    family: $FONT\n\
    style: Regular\n\
"

printf -v LAYOUT "\
  size: $FONTSIZE\n\
  offset:\n\
    y: $LINE_PADDING\n\
window:\n\
  padding:\n\
    x: $INNER_PADDING\n\
    y: $INNER_PADDING\n\
"

echo "$COLORS_CONTENT$FONT_MONO_CONTENT$LAYOUT" > $TERMINAL_CONFIG
echo "$COLORS_CONTENT$FONT_CONTENT$LAYOUT" > $LAUNCHER_CONFIG


