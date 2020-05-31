# !/bin/bash

BG=$3
FG=$4
HL=$5

TOEXEC="$(\
	grep '\[' $1 | \
	sed -e 's/\[//' -e 's/\]//' | \
	fzf \
	--color=bg:$BG,fg:$FG,border:$BG,marker:$HL,pointer:$HL,prompt:$HL,gutter:$BG,bg+:$BG,fg+:$FG,spinner:$HL,hl:$HL,hl+:$HL \
	--layout=reverse \
	--margin=1,2,0,2 \
	--prompt='Search: ' \
	-i  \
	--history="$HOME/.launcher_history" | \
	xargs -r -I selectedApp grep -A 1 '\[selectedApp\]' $1 | \
	tail -1\
)"

if [[ -z "$TOEXEC" ]]; then
	exit 1
fi

case $TOEXEC in
	*"\$TERMAPP"*)
		COMMAND="${TOEXEC/\$TERMAPP/}"
		swaymsg exec "alacritty --title='$COMMAND' --config-file=$2 -e $COMMAND";;
	*"\$NVIMAPP"*)
		TARGETPATH=${TOEXEC/\$NVIMAPP /}
		TARGETPATH=${TARGETPATH/\~/$HOME}
		if [[ -d $TARGETPATH ]]; then
			WORKINGDIR=$(dirname "${TARGETPATH%%/}/.")
			FILEPATH=""
			TITLE=$(basename $WORKINGDIR)
		elif [[ -f $TARGETPATH ]]; then
			WORKINGDIR=$(dirname $TARGETPATH)
			FILEPATH=$(basename $TARGETPATH)
			TITLE="$FILEPATH"
		else
			swaynag -t warning -m "Invalid command passed to \$NVIMAPP. Should be directory or file" &
			exit 1
		fi
		swaymsg exec "alacritty --config-file=$2 --title='$TITLE' -e bash -c 'cd $WORKINGDIR && sleep 0.1 && nvim $FILEPATH'";;
	*""*)
		swaymsg exec "$TOEXEC";;
esac
