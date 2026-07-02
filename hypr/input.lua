---------------
---- INPUT ----
---------------

hl.config({
  input = {
    kb_layout    = "us",
    kb_variant   = "",
    kb_model     = "",
    kb_options   = "ctrl:nocaps,altwin:swap_alt_win",
    kb_rules     = "",

    follow_mouse = 1,

    repeat_rate  = 40,
    repeat_delay = 400,

    sensitivity  = -0.5, -- -1.0 - 1.0, 0 means no modification.

    touchpad     = {
      scroll_factor = 0.2,
      clickfinger_behavior = true,
      disable_while_typing = true,
      natural_scroll = true,
    },
  },

  cursor = {
    inactive_timeout = 0.4
  }
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
  name        = "epic-mouse-v1",
  sensitivity = -0.5,
})
