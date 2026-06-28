local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "DemiBold" })
config.window_decorations = "RESIZE"
config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
}
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.font_size = 16.0
config.window_frame.font_size = 14.0
config.enable_tab_bar = false

config.initial_cols = 130
config.initial_rows = 32

local maximize_window = wezterm.action_callback(function(window, _pane)
  window:maximize()
end)

config.mouse_bindings = {
  -- Complete selection and copy to system clipboard when releasing left click
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = wezterm.action.CompleteSelection 'Clipboard',
  },
}
config.colors = {
  selection_fg = 'none', -- Use 'none' to keep the original text color, or a color like '#ffffff'
  selection_bg = 'rgba(50% 50% 50% 50%)', -- Adjust transparency for the highlight background
}

return config
