local custom_colors = {
  -- MAIN COLORS
  red = '#f7768e',
  red_faint = '#f89aaa',
  red_intense = '#d1556e',

  green = '#73daca',
  green_faint = '#a2e5db',
  green_intense = '#52b0a2',

  yellow = '#e0af68',
  yellow_faint = '#ebc28c',
  yellow_intense = '#c48d4a',

  blue = '#7aa2f7',
  blue_faint = '#a3b9fa',
  blue_intense = '#597ed6',

  magenta = '#bb9af7',
  magenta_faint = '#d0b8fa',
  magenta_intense = '#9a74d5',

  cyan = '#7dcfff',
  cyan_faint = '#a0e2ff',
  cyan_intense = '#5bb3d8',

  -- SECONDARY
  white = '#f3f3f3',
  white_faint = '#d3d3d3',
  white_intense = '#9fa7d3',

  black = '#414868',
  black_faint = '#59607A',
  black_intense = '#30354E',
}

local custom_theme = {
  normal = {
    a = { fg = custom_colors.white, bg = custom_colors.blue, gui = 'bold' },
    b = { fg = custom_colors.black, bg = custom_colors.white_faint },
    c = { fg = custom_colors.black, bg = custom_colors.white },
  },
  insert = {
    a = { fg = custom_colors.white, bg = custom_colors.green, gui = 'bold' },
    b = { fg = custom_colors.black, bg = custom_colors.white_faint },
  },
  visual = {
    a = { fg = custom_colors.white, bg = custom_colors.magenta, gui = 'bold' },
    b = { fg = custom_colors.black, bg = custom_colors.white_faint },
  },
  replace = {
    a = { fg = custom_colors.white, bg = custom_colors.red, gui = 'bold' },
    b = { fg = custom_colors.black, bg = custom_colors.white_faint },
  },
  command = {
    a = { fg = custom_colors.white, bg = custom_colors.yellow, gui = 'bold' },
    b = { fg = custom_colors.black, bg = custom_colors.white_faint },
  },
  inactive = {
    a = { fg = custom_colors.black, bg = custom_colors.white_faint, gui = 'bold' },
    b = { fg = custom_colors.black, bg = custom_colors.white_faint },
    c = { fg = custom_colors.black, bg = custom_colors.white_faint },
  },
}

-- Return the custom theme
return custom_theme

