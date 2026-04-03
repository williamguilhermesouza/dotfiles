local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

-- Start with PowerShell Core
config.default_prog = { "pwsh.exe" }

-- No borders, no tab bar
config.window_decorations = "RESIZE"
config.enable_tab_bar = false

config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 10

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

return config
