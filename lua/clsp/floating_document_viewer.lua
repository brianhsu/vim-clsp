local M = {}
local vim = vim
local util = require('clsp/util')

M.opened_win_id = nil
M.config = {
    win_blend = 15,
    win_config = {
        title = "Documentation",
        border = "rounded",
        width_calculator = function ()
            return math.floor(vim.api.nvim_win_get_width(vim.api.nvim_get_current_win()) * 0.6)
        end
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

    M.opened_win_id = float_win_id

    setup_key_map(float_win_id, parent_win_id)

    util.call_when_window_closed(float_win_id, function ()
        util.unmap_keys(float_buf_id, parent_buf_id, M.config.keymap)
        M.opened_win_id = nil
    end)

    vim.api.nvim_set_option_value('winblend', M.config.win_blend, {scope = 'local', win = float_win_id})
end

function M.open_document_floating()
    if M.config.win_config.width_calculator ~= nil then
        M.config.win_config.width = M.config.win_config.width_calculator()
    end

    vim.lsp.handlers["textDocument/hover"] = M.handler
    vim.lsp.buf.hover()
end

function M.close_document_floating()
    vim.api.nvim_win_close(M.opened_win_id, false)
end

function M.toggle_document_floating()
    if M.opened_win_id ~= nil then
        M.close_document_floating()
    else
        M.open_document_floating()
    end
end

function M.setup(config)
    M.config = util.merge(M.config, config)
    M.handler = vim.lsp.with(M.floating_document_viewer, M.config.win_config)

    vim.api.nvim_create_user_command('CLSPDocumentFloating', M.toggle_document_floating, {})
end

return M
