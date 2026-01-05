local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
local in_vscode = (vim.g.vscode == 1) or (vim.g.vscode == true)
vim.g.mapleader = " "
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.textwidth = 80
vim.opt.formatoptions:remove({ "t", "c" })

vim.opt.shell = [["C:/Program Files/Git/bin/bash.exe"]]
vim.opt.shellcmdflag = "-c"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

require("lazy").setup({
  spec = {
    {
      "neovim/nvim-lspconfig",
      { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
      { "lewis6991/gitsigns.nvim", opts = {} },
      { "nvim-lualine/lualine.nvim", dependencies = { 'nvim-tree/nvim-web-devicons' }, opts = {} },
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").setup({
      defaults = { hidden = true },
      pickers = {
        find_files = {
          find_command = {
          "fd", "--type", "f", "--no-ignore-vcs", 
          "--strip-cwd-prefix", "--hidden",
          "--exclude", ".git", "--exclude", "venv",
          "--exclude", ".venv", "--exclude", "node_modules",
          "--exclude", "__pycache__", "--exclude", "build"
        }
        }
      }
    })
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>td', builtin.diagnostics, { desc = 'Telescope diagnostics' })
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = 'LSP references' })
vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = 'LSP defs' })
  end
},
      { "nvim-tree/nvim-tree.lua", 
        opts = {
          filters = {
          git_ignored = false,
          dotfiles = false,
            },
          } 
      },
      { "nvim-treesitter/nvim-treesitter", lazy = false, build = ":TSUpdate" },
      { "williamboman/mason.nvim", opts = {} },
      { "williamboman/mason-lspconfig.nvim", opts = {
       ensure_installed = { "pyright", "gopls", "omnisharp" } 
      } },

      -- Completion plugins
      {
        "hrsh7th/nvim-cmp",
        dependencies = {
          "hrsh7th/cmp-nvim-lsp",
          "hrsh7th/cmp-buffer",
          "hrsh7th/cmp-path",
          "hrsh7th/cmp-cmdline",
          "L3MON4D3/LuaSnip",
          "saadparwaiz1/cmp_luasnip",
        },
        config = function()
          local cmp = require("cmp")
          local luasnip = require("luasnip")

          cmp.setup({
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ["<Tab>"] = cmp.mapping.select_next_item(),
              ["<S-Tab>"] = cmp.mapping.select_prev_item(),
              ["<CR>"] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
              { name = "nvim_lsp" },
              { name = "luasnip" },
              { name = "buffer" },
              { name = "path" },
            }),
          })
        end,
      },
    },
  },
  { colorscheme = { "catppuccin" } },
  checker = { enabled = true },
})

require('nvim-treesitter.configs').setup({
  ensure_installed = { "python", "lua", "bash", "json", "c_sharp", "go" },
  auto_install = true,
  highlight = { enable = true },
})

require("catppuccin").setup({
  flavour = "mocha",
  integrations = {
    treesitter = true,
    native_lsp = { enabled = true },
  },
  highlight_overrides = {
    all = function(colors)
      return {
        ["@function.builtin"] = { fg = colors.blue },
      }
    end
  }
})

require('lspconfig').omnisharp.setup({
  cmd = { "omnisharp" },
  enable_roslyn_analyzers = true,
  organize_imports_on_format = true,
  enable_import_completion = true,
})

require('lspconfig').gopls.setup({
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"),
})
require("lspconfig").pyright.setup({
  root_dir = require("lspconfig.util").root_pattern("pyproject.toml"),
})
vim.cmd("colorscheme catppuccin")
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Window right' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<cr>')
vim.keymap.set('n', '<leader>tf', ':NvimTreeFocus<cr>')
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostics' })

if in_vscode then
  local vsc = function(cmd, args) return vim.fn.VSCodeNotify(cmd, args or {}) end
  vim.keymap.set("n", "<leader>ff", function() vsc("workbench.action.quickOpen") end, { silent = true, desc = "Files (VS Code Quick Open)" })
  vim.keymap.set("n", "<leader>fg", function() vsc("workbench.action.findInFiles") end, { silent = true, desc = "Grep (Find in Files)" })
  vim.keymap.set("n", "<leader>fb", function() vsc("workbench.action.showAllEditors") end, { silent = true, desc = "Buffers (Open Editors)" })
  vim.keymap.set("n", "<leader>td", function() vsc("workbench.actions.view.problems") end, { silent = true, desc = "Diagnostics (Problems)" })
  vim.keymap.set("n", "<leader>fr", function() vsc("editor.action.referenceSearch.trigger") end, { silent = true, desc = "LSP References" })
  vim.keymap.set("n", "<leader>fd", function() vsc("editor.action.revealDefinition") end, { silent = true, desc = "LSP Definition" })
  -- Replace NvimTree mappings with Explorer
  vim.keymap.set("n", "<leader>tt", function() vsc("workbench.view.explorer") end, { silent = true, desc = "Explorer" })
  vim.keymap.set("n", "<leader>tf", function() vsc("workbench.files.action.focusFilesExplorer") end, { silent = true, desc = "Focus Explorer" })
  -- Focus editor groups (VS Code)
  vim.keymap.set("n", "<C-h>", function() vsc("workbench.action.focusLeftGroup")  end, { silent = true, desc = "Focus left group" })
  vim.keymap.set("n", "<C-l>", function() vsc("workbench.action.focusRightGroup") end, { silent = true, desc = "Focus right group" })
  vim.keymap.set("n", "<C-j>", function() vsc("workbench.action.focusBelowGroup") end, { silent = true, desc = "Focus below group" })
  vim.keymap.set("n", "<C-k>", function() vsc("workbench.action.focusAboveGroup") end, { silent = true, desc = "Focus above group" })
end
