-- Give each connected monitor its own persistent block of workspaces 1-10.
-- This module uses only Hyprland's native Lua API and the Lua standard library.

local SLOTS = 10
local homeDir = os.getenv("HOME") or "."
local stateHome = os.getenv("XDG_STATE_HOME") or (homeDir .. "/.local/state")
local stateDir = stateHome .. "/hypr"
local stateFile = stateDir .. "/monitor-workspaces"

local M = { slots = SLOTS }
local blocks = {}
local current = {}
local written = nil

local function shell_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function identity_base(identity)
    return identity:gsub(" #%d+$", "")
end

local function description(monitor)
    local value = monitor.description
    if not value or value == "" then
        value = monitor.name
    end
    return tostring(value):gsub("[\t\r\n]", " ")
end

local function internal(monitor)
    return monitor.name:match("^eDP") ~= nil
        or monitor.name:match("^LVDS") ~= nil
        or monitor.name:match("^DSI") ~= nil
end

local function connected()
    local monitors = {}
    for _, monitor in ipairs(hl.get_monitors()) do
        if not monitor.is_mirror then
            monitors[#monitors + 1] = monitor
        end
    end

    table.sort(monitors, function(left, right)
        if internal(left) ~= internal(right) then
            return internal(left)
        end
        return left.id < right.id
    end)
    return monitors
end

local function load_state()
    blocks = {}
    current = {}
    local file = io.open(stateFile, "r")
    if not file then
        return
    end

    for line in file:lines() do
        local block, connector, identity = line:match("^(%d+)\t([^\t]*)\t(.+)$")
        if block then
            blocks[identity] = tonumber(block)
            if connector ~= "" then
                current[connector] = identity
            end
        end
    end
    file:close()
end

local function save_state(monitors, identities)
    local connector_by_identity = {}
    for connector, identity in pairs(identities) do
        connector_by_identity[identity] = connector
    end

    local rows = {}
    for identity, block in pairs(blocks) do
        rows[#rows + 1] = {
            block = block,
            line = block .. "\t" .. (connector_by_identity[identity] or "") .. "\t" .. identity,
        }
    end
    table.sort(rows, function(left, right)
        return left.block < right.block
    end)

    local lines = {}
    for _, row in ipairs(rows) do
        lines[#lines + 1] = row.line .. "\n"
    end
    local content = table.concat(lines)
    if content == written then
        return
    end

    os.execute("mkdir -p " .. shell_quote(stateDir) .. " 2>/dev/null")
    local file = io.open(stateFile, "w")
    if file then
        file:write(content)
        file:close()
        written = content
    end
end

local function free_block()
    local taken = {}
    for _, block in pairs(blocks) do
        taken[block] = true
    end
    local block = 0
    while taken[block] do
        block = block + 1
    end
    return block
end

local function assign(monitors)
    load_state()
    local identities = {}
    local taken = {}

    -- Keep identical displays tied to their connector while connected.
    local by_name = {}
    for _, monitor in ipairs(monitors) do
        by_name[#by_name + 1] = monitor
    end
    table.sort(by_name, function(left, right)
        return left.name < right.name
    end)

    for _, monitor in ipairs(by_name) do
        local identity = current[monitor.name]
        if identity and identity_base(identity) == description(monitor) and not taken[identity] then
            identities[monitor.name] = identity
            taken[identity] = true
        end
    end

    for _, monitor in ipairs(by_name) do
        if not identities[monitor.name] then
            local base = description(monitor)
            local identity = base
            local count = 1
            while taken[identity] do
                count = count + 1
                identity = base .. " #" .. count
            end
            identities[monitor.name] = identity
            taken[identity] = true
        end
    end

    local by_connector = {}
    for _, monitor in ipairs(monitors) do
        local identity = identities[monitor.name]
        if blocks[identity] == nil then
            blocks[identity] = free_block()
        end
        by_connector[monitor.name] = blocks[identity]
    end

    save_state(monitors, identities)
    return by_connector, identities
end

local function regular(workspace)
    return workspace and not workspace.special and workspace.id > 0
end

local function block_of_id(id)
    return math.floor((id - 1) / SLOTS)
end

local function owner(id, monitors, by_connector)
    if id < 1 then
        return nil
    end
    local block = block_of_id(id)
    for _, monitor in ipairs(monitors) do
        if by_connector[monitor.name] == block then
            return monitor
        end
    end
    return nil
end

local function show(monitor, id)
    local workspace = hl.get_workspace(id)
    if workspace and workspace.monitor and workspace.monitor.name ~= monitor.name then
        hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))
    end
    hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
    hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
end

local function home(monitor, block)
    local best = nil
    for _, workspace in ipairs(hl.get_workspaces()) do
        if regular(workspace)
            and block_of_id(workspace.id) == block
            and workspace.monitor
            and workspace.monitor.name == monitor.name
            and (not best or workspace.id < best) then
            best = workspace.id
        end
    end
    return best or block * SLOTS + 1
end

local function slot_id(monitor, slot)
    assert(slot >= 1 and slot <= SLOTS, "workspace slot must be between 1 and 10")
    local by_connector = assign(connected())
    return (by_connector[monitor.name] or 0) * SLOTS + slot
end

function M.focus(slot)
    local monitor = hl.get_active_monitor()
    if not monitor then
        return
    end
    local id = slot_id(monitor, slot)
    show(monitor, id)
end

function M.move_window(slot, follow)
    local window = hl.get_active_window()
    local monitor = hl.get_active_monitor()
    if not window or not monitor then
        return
    end

    local id = slot_id(monitor, slot)
    local workspace = hl.get_workspace(id)
    if workspace and workspace.monitor and workspace.monitor.name ~= monitor.name then
        hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = monitor.name }))
    end
    hl.dispatch(hl.dsp.window.move({
        workspace = tostring(id),
        follow = follow ~= false,
        window = "address:" .. window.address,
    }))
end

function M.step(offset)
    local monitor = hl.get_active_monitor()
    local workspace = hl.get_active_workspace()
    if not monitor then
        return
    end
    local by_connector = assign(connected())
    local block = by_connector[monitor.name] or 0
    local slot = 1
    if regular(workspace) and block_of_id(workspace.id) == block then
        slot = (workspace.id - 1) % SLOTS + 1
    end
    M.focus((slot - 1 + offset) % SLOTS + 1)
end

function M.reconcile()
    local monitors = connected()
    if #monitors == 0 then
        return
    end

    local by_connector = assign(monitors)
    local focused_window = hl.get_active_window()
    local focused_monitor = hl.get_active_monitor()
    local focused_name = focused_monitor and focused_monitor.name
    local changed = false

    -- When an output returns, move its numbered workspaces home.
    for _, workspace in ipairs(hl.get_workspaces()) do
        if regular(workspace) and workspace.monitor then
            local home_monitor = owner(workspace.id, monitors, by_connector)
            if home_monitor and home_monitor.name ~= workspace.monitor.name then
                hl.dispatch(hl.dsp.workspace.move({
                    workspace = tostring(workspace.id),
                    monitor = home_monitor.name,
                }))
                changed = true
            end
        end
    end

    -- Each output shows one of its own workspaces. Keep populated workspaces
    -- from disconnected outputs visible as guests until their output returns.
    for _, monitor in ipairs(connected()) do
        local block = by_connector[monitor.name]
        local active = monitor.active_workspace
        local own = regular(active) and block_of_id(active.id) == block
        local guest = regular(active)
            and not owner(active.id, monitors, by_connector)
            and (active.windows or 0) > 0
        if not own and not guest then
            show(monitor, home(monitor, block))
            changed = true
        end
    end

    if changed then
        if focused_window and hl.get_window("address:" .. focused_window.address) then
            hl.dispatch(hl.dsp.focus({ window = "address:" .. focused_window.address }))
        elseif focused_name and hl.get_monitor(focused_name) then
            hl.dispatch(hl.dsp.focus({ monitor = focused_name }))
        end
    end
end

hl.on("hyprland.start", M.reconcile)
hl.on("config.reloaded", M.reconcile)
hl.on("monitor.added", M.reconcile)
hl.on("monitor.removed", function()
    hl.timer(M.reconcile, { type = "oneshot", timeout = 100 })
end)

return M
