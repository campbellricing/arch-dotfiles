return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettierd" },
      typescript = { "prettierd" },
      javascriptreact = { "prettierd" },
      typescriptreact = { "prettierd" },
      json = { "prettierd" },
    },
    format_on_save = {
      lsp_fallback = false,
    },
  },
}
