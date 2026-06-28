-- ~/.config/nvim/init.lua
-- Minimal Neovim config for a returning Vim user.
-- Pretty, usable, not overbuilt.

-- We are intentionally NOT setting vim.g.mapleader.
-- Default leader stays backslash: \
-- Example: <leader>ff means \ff
--
-- Ctrl-[ already works as Escape by default.

vim.g.maplocalleader = "\\"

-- ---------------------------------------------------------------------------
-- Basic editor settings
-- ---------------------------------------------------------------------------

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.ignorecase = true
opt.smartcase = true
opt.splitbelow = true
opt.splitright = true
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.list = true
opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}

-- ---------------------------------------------------------------------------
-- Keymaps
-- ---------------------------------------------------------------------------

local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>x", "<cmd>x<cr>", { desc = "Save and quit" })
map("n", "<leader>e", "<cmd>Ex<cr>", { desc = "Open netrw file explorer" })
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower split" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper split" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })

-- ---------------------------------------------------------------------------
-- Bootstrap lazy.nvim plugin manager
-- ---------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv or vim.loop

if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

-- ---------------------------------------------------------------------------
-- Plugins
-- ---------------------------------------------------------------------------

require("lazy").setup({
  -- Theme: matches WezTerm rose-pine-moon
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        styles = {
          transparency = false,
        },
      })

      vim.cmd.colorscheme("rose-pine-moon")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "rose-pine",
          globalstatus = true,
        },
      })
    end,
  },

  -- Git signs in the gutter
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- Treesitter.
  -- Pinned to master because this config uses the classic
  -- require("nvim-treesitter.configs").setup(...) API.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "bash",
          "go",
          "javascript",
          "json",
          "lua",
          "markdown",
          "python",
          "query",
          "tsx",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        },
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")

      map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      map("n", "<leader>fg", builtin.live_grep, { desc = "Search text" })
      map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      map("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
    end,
  },

  -- Mason installs language servers
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  -- Mason bridge for LSP server installation
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    config = function()
      local servers = {
        "lua_ls",
        "gopls",
        "pyright",
        "ts_ls",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = false,
      })

      -- New Neovim 0.11+ LSP API.
      -- Do not use require("lspconfig").foo.setup({}) anymore.
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end
    end,
  },
})

-- ---------------------------------------------------------------------------
-- LSP keymaps
-- ---------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local bufmap = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, {
        buffer = event.buf,
        desc = desc,
      })
    end

    bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bufmap("n", "gr", vim.lsp.buf.references, "Go to references")
    bufmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
    bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
    bufmap("n", "<leader>lf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format file")
  end,
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})