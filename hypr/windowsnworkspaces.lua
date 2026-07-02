--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

hl.window_rule({
  -- Ignore maximize requests from all apps. You'll probably like this.
  name           = "suppress-maximize-events",
  match          = { class = ".*" },

  suppress_event = "maximize",
})

hl.window_rule({
  -- Fix some dragging issues with XWayland
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
  name  = "move-hyprland-run",
  match = { class = "hyprland-run" },

  move  = "20 monitor_h-120",
  float = true,
})

hl.window_rule({
  name = "float_center",
  match = { class = "float_center" },

  float = true,
  size = { 800, 600 }
})

hl.window_rule({
  name = "gazelle",
  match = { class = "gazelle" },

  float = true,
  maximize = true,
})

hl.window_rule({
  name = "nautilus-file-picker",
  match = { title = "^Open File(s)?$" },

  float = true,
  size = { 960, 600 }
})

hl.window_rule({
  name = "nautilus",
  match = { class = "org.gnome.Nautilus" },

  float = true,
  size = { 1200, 600 }
})

hl.window_rule({
  name = "nautilus-preview",
  match = { class = "org.gnome.NautilusPreviewer" },

  float = true,
  maximize = true
})

hl.window_rule({
  name = "packet-tracer",
  match = { class = "PacketTracer" },

  float = true,
})
