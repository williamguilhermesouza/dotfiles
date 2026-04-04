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
config.unix_domains = {
  {
    name = 'unix',
  },
}

-- Auto-connect on startup
-- config.default_gui_startup_args = { 'connect', 'unix' }

-- No borders, no tab bar
config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true

config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 12
config.tab_max_width = 32
config.switch_to_last_active_tab_when_closing_tab = true


-- Color scheme — high contrast, easy on projectors
config.color_scheme = "Tokyo Night Storm"

-- Window padding — breathing room around content
config.window_padding = {
  left = 16,
  right = 16,
  top = 16,
  bottom = 16,
}

config.leader = {
  key = 'a',
  mods = 'CTRL',
  timeout_milliseconds = 2000,
}

-- Hide scrollbar, steady block cursor
config.enable_scroll_bar = false
config.default_cursor_style = "SteadyBlock"
config.keys = {
    {
        key = '[',
        mods = 'LEADER',
        action = wezterm.action.ActivateCopyMode,
    },
    {
        key = 'n',
        mods = 'LEADER',
        action = wezterm.action.ActivateTabRelative(1),
    },
    {
        key = 'p',
        mods = 'LEADER',
        action = wezterm.action.ActivateTabRelative(-1),
    },
    {
        key = 'w',
        mods = 'LEADER',
        action = wezterm.action.ShowTabNavigator,
    },
    {
        key = 'a',
        mods = 'LEADER',
        action = wezterm.action.AttachDomain 'unix',
    },

      -- Detach from muxer
    {
        key = 'd',
        mods = 'LEADER',
        action = wezterm.action.DetachDomain { DomainName = 'unix' },
    },
    -- Rename current session; analagous to command in tmux
    {
        key = '$',
        mods = 'LEADER|SHIFT',
        action = wezterm.action.PromptInputLine {
          description = 'Enter new name for session',
          action = wezterm.action_callback(
            function(window, pane, line)
              if line then
                mux.rename_workspace(
                  window:mux_window():get_workspace(),
                  line
                )
              end
            end
          ),
        },
    },
    -- Show list of workspaces
    {
        key = 's',
        mods = 'LEADER',
        action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' },
    },
    { key = 'h', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'CTRL', action = wezterm.action.ActivatePaneDirection 'Right' },
    { key = 'h', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Left', 5 }, },
    { key = 'l', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Right', 5 }, },
    { key = 'k', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Up', 5 }, },
    { key = 'j', mods = 'CTRL|SHIFT', action = wezterm.action.AdjustPaneSize { 'Down', 5 }, },
    { key = 'h', mods = 'LEADER', action = wezterm.action.SplitVertical{ domain = 'CurrentPaneDomain' } },
    { key = 'v', mods = 'LEADER', action = wezterm.action.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
    { key = '{', mods = 'LEADER|SHIFT', action = wezterm.action.PaneSelect { mode = 'SwapWithActiveKeepFocus' } },
    {
      key = 'c',
      mods = 'LEADER',
      action = wezterm.action.CloseCurrentPane { confirm = false },
    },
    {
        key = ';',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection('Prev'),
    },
    {
        key = '.',
        mods = 'LEADER',
        action = wezterm.action.ActivatePaneDirection('Next'),
    },
    {
        key = ',',
        mods = 'LEADER',
        action = wezterm.action.PromptInputLine {
          description = 'Enter new name for tab',
          action = wezterm.action_callback(
            function(window, pane, line)
              if line then
                window:active_tab():set_title(line)
              end
            end
          ),
        },
    },
    {
        key = 'q',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentTab{ confirm = true },
    },
    {
        key = 'o',
        mods = 'LEADER',
        action = wezterm.action.SpawnTab("CurrentPaneDomain"),
    },
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
