return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      on_highlights = function(hl)
        hl.Normal = { bg = "NONE" }
        hl.NormalNC = { bg = "NONE" }
        hl.SignColumn = { bg = "NONE" }
        hl.EndOfBuffer = { bg = "NONE" }
        hl.FloatBorder = { bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }
        hl.NeoTreeNormal = { bg = "NONE" }
        hl.NeoTreeNormalNC = { bg = "NONE" }
        hl.TelescopeNormal = { bg = "NONE" }
        hl.LazyNormal = { bg = "NONE" }
      end,
    },
  },
}
