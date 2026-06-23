-- Notifications (swaync)

hl.bind("SUPER + COMMA",
    hl.dsp.exec_cmd("swaync-client --close-latest"))

hl.bind("SUPER + SHIFT + COMMA",
    hl.dsp.exec_cmd("swaync-client --close-all"))

hl.bind("SUPER + CTRL + COMMA",
    hl.dsp.exec_cmd("swaync-client --toggle-panel"))

hl.bind("SUPER + ALT + COMMA",
    hl.dsp.exec_cmd([[swaync-client --toggle-dnd &&
        swaync-client --get-dnd | grep -q 'true' &&
        notify-send "Silenced notifications" ||
        notify-send "Enabled notifications"]]))


-- Screenshots

local hyprshot = os.getenv("HOME") .. "/.local/bin/hyprshot"

hl.bind("PRINT",
    hl.dsp.exec_cmd(hyprshot .. " -m region"))

hl.bind("ALT + PRINT",
    hl.dsp.exec_cmd(hyprshot .. " -m window"))

hl.bind("SHIFT + PRINT",
    hl.dsp.exec_cmd(hyprshot .. " -m output"))
