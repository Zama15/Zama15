-- Set the tab width to 2 spaces
vim.opt.tabstop = 2       -- The width of a <Tab> character
vim.opt.shiftwidth = 2    -- The width for auto-indents
vim.opt.expandtab = true  -- Convert tabs to spaces

-- Enable syntax highlighting
vim.cmd('syntax on')

-- Enable filetype plugins and indentation
vim.cmd('filetype plugin indent on')

-- Enable mouse support in all modes
vim.opt.mouse = 'a'

-- Enable search highlighting
vim.opt.hlsearch = true

-- Keybind to un-/indent selected text
-- Map Ctrl+] to indent selected text
vim.api.nvim_set_keymap('v', '<C-]>', '>gv', { noremap = true, silent = true })

-- Map Ctrl+[ to un-indent selected text
vim.api.nvim_set_keymap('v', '<C-[>', '<gv', { noremap = true, silent = true })

-- Function to add an empty line at the end of the file if needed
local function add_empty_line_at_end()
  local last_line = vim.fn.line('$')
  local last_line_content = vim.fn.getline(last_line)

  if last_line_content ~= '' then
    vim.fn.append(last_line, '')
  end
end
-- Autocommand to call the function on write
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = add_empty_line_at_end
})

-- Key mappings for clipboard operations
local function has_clipboard()
  return vim.fn.has('clipboard') == 1
end
if has_clipboard() then
  vim.opt.clipboard:append('unnamedplus')
else
  vim.notify("Clipboard support not available. Some features may not work.", vim.log.levels.WARN)
end
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
if has_clipboard() then
  -- Map Ctrl+C to copy the current line to the clipboard in normal mode
  map('n', '<C-c>', '"+yy')

  -- Map Ctrl+C to copy only the selected text to the clipboard in visual mode
  map('v', '<C-c>', '"+y')

  -- Map Ctrl+V to paste from clipboard in normal and insert mode
  map('n', '<C-v>', '"+p')
  map('i', '<C-v>', '<C-r>+')
else
  vim.notify("Clipboard mappings not set due to lack of clipboard support.", vim.log.levels.WARN)
end


-- Initialize Packer
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  
  -- Add your plugins here
  -- For example:
  -- use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP

  --
  -- A blazing fast and easy to configure Neovim statusline written in Lua.
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  --
  -- Treesitter configurations and abstraction layer for Neovim. 
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }

  --
  -- Toggle comments in Neovim, using built in commentstring filetype option
  use "terrortylor/nvim-comment"

  --
  -- A File Explorer For Neovim Written In Lua
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    }
  }

  --
  -- Soothing pastel theme for (Neo)vim
  use { "catppuccin/nvim", as = "catppuccin" }
end)

--
-- Set up lualine with a custom theme based on ayu_light
local lualine_tokyo_night_theme = require('lualine_tokyo_night')
require('lualine').setup {
  options = {
    theme = lualine_tokyo_night_theme,
  },

  sections = {
    lualine_a = { "mode" },
    lualine_b = { "filename" },
    lualine_c = { "g:coc_status" },
    lualine_x = { "branch", "diff", "diagnostics" },
    lualine_y = { "filetype" },
    lualine_z = { "location" }
  }
}

--
-- Set up TreeSitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "bash", "css", "diff", "git_config", "git_rebase", "gitattributes", "gitcommit", "gitignore", "html", "java", "javascript", "json", "kotlin", "lua", "markdown", "markdown_inline", "php", "python", "regex", "ruby", "scss", "sql", "vim", "vue", "yaml", "xml"},
  highlight = {
    enable = true,
  },
  indent = {
    enable = true
  },
}

--
-- Init Nvim-Comment
require('nvim_comment').setup({
    line_mapping = "<C-_>", -- Ctrl + /
    operator_mapping = "<C-_>", -- Optional: set for operator mode as well
    comment_empty = true,
    comment_empty_trim_whitespace = true,
    create_mappings = true,
})

--
-- Init Nvim-Comment
require('nvim_comment').setup({
    line_mapping = "<C-/>", -- Ctrl + /
    operator_mapping = "<C-/>", -- Optional: set for operator mode as well
    comment_empty = true,
    comment_empty_trim_whitespace = true,
    create_mappings = true,
})

--
-- Set up Nvim-Tree
require("nvim-tree").setup({
  -- Set this to true to sync the tree with the current working directory
  sync_root_with_cwd = true,
  view = {
    adaptive_size = true,
    side = "left",
  },
  filters = {
    dotfiles = false,
  },
  sync_root_with_cwd = true,
})
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

--
-- Set up catppuccin
require("catppuccin").setup({
    flavour = "auto", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "mocha",
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15, -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { "italic" }, -- Change the style of comments
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {
      latte = {
        base = "#FFFFFF",
      }
    },
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        -- cmp = true,
        -- gitsigns = true,
        nvimtree = true,
        treesitter = true,
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    },
})

-- setup must be called before loading
vim.cmd.colorscheme "catppuccin"

