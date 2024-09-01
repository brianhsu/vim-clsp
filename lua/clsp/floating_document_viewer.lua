local M = {}
local vim = vim
local util = require('clsp/util')

M.config = {
    win_blend = 15,
    win_config = {
        title = "Documentation",
        border = "rounded",
    },
    keymap = {
        scroll_line_up = '<C-y>',
        scroll_line_down = '<C-e>',
        scroll_page_up = '<C-b>',
        scroll_page_down = '<C-f>',
        focus = '<CR>',
        close = 'q'
    }
}

local function setup_key_map(float_win_id, parent_win_id)
    vim.keymap.set(
        'n',
        M.config.keymap.scroll_line_down,
        util.run_normal_mode_command(float_win_id, parent_win_id, '<C-e>'),
        {desc = 'Scroll document window 1 line down.', buffer = true}
    )

    vim.keymap.set(
        'n',
        M.config.keymap.scroll_line_up,
        util.run_normal_mode_command(float_win_id, parent_win_id, '<C-y>'),
        {desc = 'Scroll document window 1 line up.', buffer = true}
    )

    vim.keymap.set(
        'n',
        M.config.keymap.scroll_page_down,
        util.run_normal_mode_command(float_win_id, parent_win_id, '<C-f>'),
        {desc = 'Scroll document window 1 page down.', buffer = true}
    )

    vim.keymap.set(
        'n',
        M.config.keymap.scroll_page_up,
        util.run_normal_mode_command(float_win_id, parent_win_id, '<C-b>'),
        {desc = 'Scroll document window 1 page up.', buffer = true}
    )

    vim.keymap.set(
        'n',
        M.config.keymap.close,
        util.run_normal_mode_command(float_win_id, parent_win_id, 'q'),
        {desc = 'Close document window.', buffer = true}
    )

    vim.keymap.set(
        'n',
        M.config.keymap.focus,
        util.focus_floating_window(float_win_id),
        {desc = 'Focus document window.', buffer = true}
    )

end

function M.floating_document_viewer(_, result, ctx, config)
    local parent_buf_id = vim.api.nvim_get_current_buf()
    local parent_win_id = vim.api.nvim_get_current_win()

    local float_buf_id, float_win_id = vim.lsp.handlers.hover(_, result, ctx, config)

    setup_key_map(float_win_id, parent_win_id)
    util.create_unmap_key_autocmds(float_buf_id, float_win_id, parent_buf_id, M.config.keymap)

    vim.api.nvim_set_option_value('winblend', M.config.win_blend, {scope = 'local', win = float_win_id})
end


function M.setup()
    M.config.win_config.width = math.floor(vim.api.nvim_win_get_width(vim.api.nvim_get_current_win()) * 0.75)

    M.handler = vim.lsp.with(M.floating_document_viewer, M.config.win_config)

    vim.lsp.handlers["textDocument/hover"] = M.handler
end

return M
