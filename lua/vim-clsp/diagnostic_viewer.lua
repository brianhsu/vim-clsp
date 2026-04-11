local M = {}
local vim = vim
local util = require('vim-clsp/util')

M._opened_win_id = nil
M.config = {
    win_blend = 15,
    win_config = {
        border = "rounded",
        scope = "cursor",
        source = true,
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
        { desc = 'Scroll diagnostic window 1 line down.', buffer = true }
    )

    vim.keymap.set(
        'n',
        M.config.keymap.scroll_line_up,
        util.run_normal_mode_command(float_win_id, parent_win_id, '<C-y>'),
        { desc = 'Scroll diagnostic window 1 line up.', buffer = true }
    )

    vim.keymap.set(
        'n',
        M.config.keymap.scroll_page_down,
        util.run_normal_mode_command(float_win_id, parent_win_id, '<C-f>'),
        { desc = 'Scroll diagnostic window 1 page down.', buffer = true }
    )

    vim.keymap.set(
        'n',
        M.config.keymap.scroll_page_up,
        util.run_normal_mode_command(float_win_id, parent_win_id, '<C-b>'),
        { desc = 'Scroll diagnostic window 1 page up.', buffer = true }
    )

    vim.keymap.set(
        'n',
        M.config.keymap.close,
        util.run_normal_mode_command(float_win_id, parent_win_id, 'q'),
        { desc = 'Close diagnostic window.', buffer = true }
    )

    vim.keymap.set(
        'n',
        M.config.keymap.focus,
        util.focus_floating_window(float_win_id),
        { desc = 'Focus diagnostic window.', buffer = true }
    )
end

function M.toggle_diagnostic()
    if M._opened_win_id ~= nil and not vim.api.nvim_win_is_valid(M._opened_win_id) then
        M._opened_win_id = nil
    end

    if M._opened_win_id ~= nil then
        vim.api.nvim_win_close(M._opened_win_id, false)
        M._opened_win_id = nil
        return
    end

    local parent_buf_id = vim.api.nvim_get_current_buf()
    local parent_win_id = vim.api.nvim_get_current_win()

    local float_buf_id, float_win_id = vim.diagnostic.open_float(M.config.win_config)

    if float_win_id == nil then
        vim.notify('No diagnostics at cursor')
        return
    end

    M._opened_win_id = float_win_id

    setup_key_map(float_win_id, parent_win_id)

    util.call_when_window_closed(float_win_id, function()
        util.unmap_keys(float_buf_id, parent_buf_id, M.config.keymap)
        M._opened_win_id = nil
    end)

    vim.api.nvim_set_option_value('winblend', M.config.win_blend, { scope = 'local', win = float_win_id })
end

function M.setup(config)
    M.config = util.merge(M.config, config)
end

return M
