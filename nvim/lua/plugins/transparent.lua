return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    require("transparent").setup({
      extra_groups = {
        "NormalFloat",
        "FloatBorder",
        "TelescopeNormal",
        "TelescopeBorder",
        "NvimTreeNormal",
      },
    })
    require("transparent").clear_prefix("BufferLine")
  end,
}
