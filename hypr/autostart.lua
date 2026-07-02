-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("hypridle")
  hl.exec_cmd("waybar")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("clipse -listen")
  hl.exec_cmd("swaync")
  hl.exec_cmd("swayosd-server")
  hl.exec_cmd("fcitx5")
  hl.exec_cmd(
    "mpvpaper -o 'hwdec=auto-safe gpu-context=wayland no-audio loop-file=inf vf=fps=24 vd-lavc-threads=1 --input-ipc-server=/tmp/mpvsocket' ALL ~/.config/images/wallpapers/wallpaper.mp4")
  hl.exec_cmd("mpvpaper-stop")
  hl.exec_cmd("~/.config/autostart/scripts/xdg-desktop-portal.sh")
end)
