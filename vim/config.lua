-- local rainbow = require 'ts-rainbow'

require "nvim-treesitter.configs".setup {
    ensure_installed = {},
    highlight = {
        enable = true,
        -- nix-vim provide better syntax highlighting
        disable = { "nix" }
    }, 
    -- rainbow = {
    --         query = {
    --            'rainbow-parens'
    --         },
    --         strategy = rainbow.strategy.global,
    --         hlgroups = {
    --            'TSRainbowRed',
    --            'TSRainbowYellow',
    --            'TSRainbowBlue',
    --            'TSRainbowOrange',
    --            'TSRainbowGreen',
    --            'TSRainbowViolet',
    --            'TSRainbowCyan'
    --         },
    --     -- enable = false,
    --     -- -- Which query to use for finding delimiters
    --     -- query = 'rainbow-parens',
    --     -- -- Highlight the entire buffer all at once
    --     -- strategy = require('ts-rainbow').strategy.global,
    -- }
}
