local lib = require("lib")

-- Pull in the wezterm API
local wezterm = require("wezterm")

local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- set TERM environment variable
-- download wezterm's terminfo file from https://github.com/wez/wezterm/termwiz/data/wezterm
-- and copy to terminfo directory (usually /usr/share/terminfo/w/)
config.term = "wezterm"

config.color_scheme = "GruvboxDarkHard"

config.window_background_opacity = 0.9

config.hide_tab_bar_if_only_one_tab = true

config.window_frame = {
  font = wezterm.font("CaskaydiaCove Nerd Font"),
  font_size = 11,
}

config.colors = {
  tab_bar = {
    background = "rgba(100% 0% 0% 50%)",
  }
}

config.font = wezterm.font("CaskaydiaCove Nerd Font Mono")
config.font_size = 11

config.window_close_confirmation = "NeverPrompt"

config.underline_thickness = 2

config.window_padding = {
  top = 0,
  left = 0,
  bottom = 0,
  right = 0,
}

-- config.enable_kitty_keyboard = true

config.adjust_window_size_when_changing_font_size = false

config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.5,
}

-- [[ keymaps
local act = wezterm.action
config.key_tables = {
  resize_pane = {
    {
      key = "h",
      action = act.AdjustPaneSize({ "Left", 5 }),
    },
    {
      key = "j",
      action = act.AdjustPaneSize({ "Down", 5 }),
    },
    {
      key = "k",
      action = act.AdjustPaneSize({ "Up", 5 }),
    },
    {
      key = "l",
      action = act.AdjustPaneSize({ "Right", 5 }),
    },
    {
      key = "q",
      action = "PopKeyTable",
    },
  }
}

config.keys = {
  -- [[ splits
  {
    key = "l",
    mods = "ALT|SHIFT",
    action = act.SplitHorizontal,
  },
  {
    key = "j",
    mods = "ALT|SHIFT",
    action = act.SplitVertical,
  },
  {
    key = "q",
    mods = "ALT",
    action = act.CloseCurrentPane({ confirm = false }),
  },
  {
    key = "q",
    mods = "ALT|CTRL",
    action = act.InputSelector({
      title = "Quit",
      choices = {
        { label = "Close pane", },
        { label = "Close tab", },
      },
      action = wezterm.action_callback(function(window, pane, id, label)
        if label == "Close pane" then
          pane:move_to_new_tab()
          act.CloseCurrentPane({ confirm = false })
        end
      end),
    }),
  },
  {
    key = "l",
    mods = "ALT",
    action = act.ActivatePaneDirection("Right"),
  },
  {
    key = "j",
    mods = "ALT",
    action = act.ActivatePaneDirection("Down"),
  },
  {
    key = "h",
    mods = "ALT",
    action = act.ActivatePaneDirection("Left"),
  },
  {
    key = "k",
    mods = "ALT",
    action = act.ActivatePaneDirection("Up"),
  },
  {
    key = "x",
    mods = "ALT",
    action = act.ActivateCopyMode,
  },
  {
    key = "r",
    mods = "ALT",
    action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, }),
  },
  {
    key = "c",
    mods = "ALT",
    action = act.CharSelect,
  },
  {
    key = "Enter",
    mods = "ALT",
    action = act.SpawnTab("CurrentPaneDomain"),
  },
  --  ]]
}
-- ]]


if (lib.isUnix()) then
  -- [[ unix only config
  config.window_decorations = "None"
  -- ]]
else
  -- [[ windows only config
  -- use git's included bash.exe as a default shell
  config.default_prog = { "C:\\Program Files\\Git\\bin\\bash.exe" }
  -- ]]
end

-- and finally, return the configuration to wezterm
return config
