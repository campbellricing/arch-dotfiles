-- Plain black background, no splash quote, while the shell starts up
hl.config({
	misc = {
		disable_splash_rendering = true,
		background_color = "rgb(000000)",
	},
})

-- Pin workspaces to monitors: 1 & 2 -> external, 3 & 4 -> built-in panel.
hl.workspace_rule({ workspace = "1", monitor = 1, default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = 1, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = 0, default = true, persistent = true })
hl.workspace_rule({ workspace = "4", monitor = 0, persistent = true })
