local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()
local startup_dir = os.getenv("DEV_ENV") or os.getenv("HOME") or wezterm.home_dir

local is_linux = string.find(wezterm.target_triple, "linux")
local is_windows = string.find(wezterm.target_triple, "windows")

-- Start with PowerShell Core
if is_windows then
    config.default_prog = { "pwsh.exe" }
end

config.default_cwd = startup_dir

-- No borders, no tab bar
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = false

config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 12


-- Color scheme — high contrast, easy on projectors
config.color_scheme = "Tokyo Night Storm"

-- Window padding — breathing room around content
config.window_padding = {
  left = 16,
  right = 16,
  top = 16,
  bottom = 16,
}

-- Hide scrollbar, steady block cursor
config.enable_scroll_bar = false
config.default_cursor_style = "SteadyBlock"
config.keys = {
  { key = "1", mods = "CTRL", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "CTRL", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "CTRL", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "CTRL", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "CTRL", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "CTRL", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "CTRL", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "CTRL", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "CTRL", action = wezterm.action.ActivateTab(8) },
  { key = "0", mods = "CTRL", action = wezterm.action.ActivateTab(-1) },
}

return config
