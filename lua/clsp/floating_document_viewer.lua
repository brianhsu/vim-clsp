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
        scroll_line_up = 'a',
        scroll_line_down = 'b',
        scroll_page_up = 'c',
        scroll_page_down = 'd',
        focus = 'e',
        close = 'f'
    }
}


function M.floating_document_viewer(_, result, ctx, config)
    local parent_buf_id = vim.api.nvim_get_current_buf()
    local parent_win_id = vim.api.nvim_get_current_win()

    local float_buf_id, float_win_id = vim.lsp.handlers.hover(_, result, ctx, config)

    vim.keymap.set('n', 'a', util.run_normal_mode_command(float_win_id, parent_win_id, '<C-e>'), {desc = 'Scroll 1 line down.', buffer = true})
    vim.keymap.set('n', 'b', util.run_normal_mode_command(float_win_id, parent_win_id, '<C-y>'), {desc = 'Scroll 1 line up.', buffer = true})
    vim.keymap.set('n', 'c', util.run_normal_mode_command(float_win_id, parent_win_id, '<C-f>'), {desc = 'Scroll 1 page down.', buffer = true})
    vim.keymap.set('n', 'd', util.run_normal_mode_command(float_win_id, parent_win_id, '<C-b>'), {desc = 'Scroll 1 page up.', buffer = true})
    vim.keymap.set('n', 'e', util.run_normal_mode_command(float_win_id, parent_win_id, 'q'), {desc = 'Scroll 1 page up.', buffer = true})
    vim.keymap.set('n', 'i', util.focus_floating_window(float_win_id), {desc = 'Focus document window.', buffer = true})

    util.create_unmap_key_autocmds(float_buf_id, float_win_id, parent_buf_id, M.config.keymap)

    vim.api.nvim_set_option_value('winblend', M.config.win_blend, {scope = 'local', win = float_win_id})
end


function M.setup()
    M.config.win_config.width = math.floor(vim.api.nvim_win_get_width(vim.api.nvim_get_current_win()) * 0.75)

    M.handler = vim.lsp.with(M.floating_document_viewer, M.config.win_config)

    vim.lsp.handlers["textDocument/hover"] = M.handler
end

return M
