-- A Quake-style drop-down terminal on its own special workspace.
-- The terminal is launched lazily the first time the workspace is opened.

local SHARE = 0.5
local SINGLE_WINDOW_ASPECT = 2
local CONSOLE = "special:qconsole"
local APP_CLASS = "dotfiles-quake-terminal"
local launch_pending = false

local function alone()
    local tiled = 0
    for _, window in ipairs(hl.get_workspace_windows(CONSOLE)) do
        if not window.floating then
            tiled = tiled + 1
        end
    end
    return tiled <= 1
end

local beside, below = nil, nil

local function cover(side, bottom)
    if beside == side and below == bottom then
        return false
    end
    beside, below = side, bottom

    hl.workspace_rule({
        workspace = CONSOLE,
        gaps_in = 0,
        gaps_out = { top = 0, right = side, bottom = bottom, left = side },
        no_border = true,
    })
    return true
end

local function fit(monitor)
    if not monitor or not monitor.scale or monitor.scale <= 0 then
        return false
    end

    local width, height = monitor.width, monitor.height
    if (monitor.transform or 0) % 2 == 1 then
        width, height = height, width
    end

    local reserved = monitor.reserved or {}
    height = height / monitor.scale - (reserved.top or 0) - (reserved.bottom or 0)
    width = width / monitor.scale - (reserved.left or 0) - (reserved.right or 0)

    local tall = math.floor(height * SHARE)
    local wide = width
    if alone() then
        wide = math.min(width, tall * SINGLE_WINDOW_ASPECT)
    end

    return cover(math.floor((width - wide) / 2), math.floor(height - tall))
end

local function console_monitor()
    local workspace = hl.get_workspace(CONSOLE)
    local monitor = workspace and workspace.visible and workspace.monitor
    if monitor and monitor.scale and monitor.scale > 0 then
        return monitor
    end
    return hl.get_active_monitor()
end

local function refit(monitor)
    if fit(monitor or console_monitor()) then
        hl.exec_scheduled_prop_refresh_immediately()
    end
end

local function launch_if_empty(workspace, terminal)
    if not workspace or workspace.name ~= CONSOLE or not workspace.is_empty or launch_pending then
        return
    end

    launch_pending = true
    hl.exec_cmd(terminal .. " start --class " .. APP_CLASS, {
        workspace = CONSOLE .. " silent",
    })

    -- Let a later open retry if the terminal command fails to create a window.
    hl.timer(function()
        launch_pending = false
    end, { type = "oneshot", timeout = 3000 })
end

local function recount()
    local workspace = hl.get_workspace(CONSOLE)
    if workspace and workspace.visible then
        refit()
    end
end

local function setup(terminal)
    hl.config({ decoration = { dim_special = 0.6 } })

    cover(0, 0)
    fit(console_monitor())

    hl.bind("SUPER + grave", hl.dsp.workspace.toggle_special("qconsole"))
    hl.bind("SUPER + SHIFT + grave", hl.dsp.window.move({
        workspace = CONSOLE,
        follow = false,
    }))

    hl.on("workspace.special_active", function(workspace, monitor)
        if workspace and workspace.name == CONSOLE then
            refit(monitor)
            launch_if_empty(workspace, terminal)
        end
    end)

    hl.on("monitor.layout_changed", function()
        refit()
    end)
    hl.on("monitor.focused", function()
        refit()
    end)
    hl.on("workspace.move_to_monitor", function(workspace, monitor)
        if workspace and workspace.name == CONSOLE then
            refit(monitor)
        end
    end)

    hl.on("window.open", function(window)
        if window and window.class == APP_CLASS then
            launch_pending = false
        end
        recount()
    end)
    hl.on("window.destroy", recount)
    hl.on("window.move_to_workspace", recount)
    hl.on("window.update_rules", recount)

    hl.animation({
        leaf = "specialWorkspaceIn",
        enabled = true,
        speed = 3,
        bezier = "easeOutQuint",
        style = "slide top",
    })
    hl.animation({
        leaf = "specialWorkspaceOut",
        enabled = true,
        speed = 2,
        bezier = "easeInOutCubic",
        style = "slide bottom",
    })
end

return setup
