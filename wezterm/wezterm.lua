local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.max_fps = 120
config.font = wezterm.font("Hack Nerd Font", { weight = "DemiBold" })
config.window_decorations = "RESIZE"
config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.font_size = 16.0

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

-- Rose Pine Moon palette
local rp = {
  base    = "#232136",
  surface = "#2a2738",
  overlay = "#393552",
  muted   = "#6e6a86",
  subtle  = "#908caa",
  text    = "#e0def4",
  iris    = "#c4a7e7",
  foam    = "#9ccfd8",
  pine    = "#3e8fb0",
  gold    = "#f6c177",
  love    = "#eb6f92",
  rose    = "#ea9a97",
}

config.colors = {
  selection_fg = "none",
  selection_bg = "rgba(50% 50% 50% 50%)",
  tab_bar = {
    background = rp.base,
    active_tab = {
      bg_color  = rp.surface,
      fg_color  = rp.text,
      intensity = "Normal",
    },
    inactive_tab = {
      bg_color = rp.base,
      fg_color = rp.muted,
    },
    inactive_tab_hover = {
      bg_color = rp.overlay,
      fg_color = rp.subtle,
    },
  },
}

config.window_frame = {
  font      = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
  font_size = 13.0,
}

-- Icons for common processes
local process_icons = {
  nvim    = "󰕮 ",
  vim     = "󰕮 ",
  bash    = " ",
  zsh     = " ",
  fish    = " ",
  ssh     = "󰣀 ",
  python  = "󰌠 ",
  python3 = "󰌠 ",
  node    = "󰎙 ",
  git     = "󰊢 ",
  docker  = "󰡨 ",
  cargo   = " ",
  make    = "󱁤 ",
  htop    = "󰊢 ",
  btop    = " ",
  claude  = " ",
}

local function tab_title(tab)
  local pane  = tab.active_pane
  local proc  = pane.foreground_process_name
  local title = pane.title

  -- Extract just the binary name
  local name = proc:match("([^/\\]+)$") or ""
  name = name:lower()

  local icon = process_icons[name] or "  "

  local shells = { zsh = true, bash = true, fish = true, sh = true }
  local label, kind

  if shells[name] then
    kind = "dir"
    local cwd = pane.current_working_dir
    if cwd then
      local path = cwd.file_path or tostring(cwd)
      local home = os.getenv("HOME") or ""
      path = path:gsub("^" .. home, "~")
      local parts = {}
      for p in path:gmatch("[^/]+") do parts[#parts + 1] = p end
      if #parts >= 2 then
        label = parts[#parts - 1] .. "/" .. parts[#parts]
      elseif #parts == 1 then
        label = (path:sub(1, 1) == "~") and "~/" .. parts[1] or parts[1]
      else
        label = "~"
      end
    else
      label = name
    end
  else
    kind = "proc"
    label = title ~= "" and title or name
  end

  if #label > 20 then label = label:sub(1, 19) .. "…" end

  return icon .. label
end

wezterm.on("format-tab-title", function(tab, _, _, _, hover, max_width)
  local title = tab_title(tab)
  local idx   = tostring(tab.tab_index + 1)

  if tab.is_active then
    return {
      { Background = { Color = rp.surface } },
      { Foreground = { Color = rp.iris } },
      { Text = " " .. idx .. " " },
      { Foreground = { Color = rp.text } },
      { Text = title .. " " },
    }
  elseif hover then
    return {
      { Background = { Color = rp.overlay } },
      { Foreground = { Color = rp.subtle } },
      { Text = " " .. idx .. " " .. title .. " " },
    }
  else
    return {
      { Background = { Color = rp.base } },
      { Foreground = { Color = rp.muted } },
      { Text = " " .. idx .. " " .. title .. " " },
    }
  end
end)

config.initial_cols = 130
config.initial_rows = 32

local maximize_window = wezterm.action_callback(function(window, _pane)
  window:maximize()
end)

config.keys = {
  { key = "LeftArrow",  mods = "OPT", action = wezterm.action.SendString("\x1bb") },
  { key = "RightArrow", mods = "OPT", action = wezterm.action.SendString("\x1bf") },
}

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
