-- Plain black background, no splash quote, while the shell starts up
hl.config({
	misc = {
		disable_splash_rendering = true,
		background_color = "rgb(000000)",
	},
})

-- Pin workspaces to monitors by connector name (Hyprland matches workspace-rule
-- monitors by name, not by numeric index). Built-in panel is always present, so
-- it owns 1 & 2; external owns 3 & 4.
hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "eDP-1", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-1", default = true, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-1", persistent = true })
