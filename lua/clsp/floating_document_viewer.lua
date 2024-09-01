local M = {}
local vim = vim
local util = require('clsp/util')

function M.floating_document_viewer(_, result, ctx, config)
    local orig_buf = vim.api.nvim_get_current_buf()
    local orig_win = vim.api.nvim_get_current_win()

    local bufid, winid = vim.lsp.handlers.hover(_, result, ctx, config)

    vim.keymap.set('n', 'a', util.run_normal_mode_command(winid, orig_win, '<C-e>'), {desc = 'Scroll 1 line down.', buffer = true})
    vim.keymap.set('n', 'b', util.run_normal_mode_command(winid, orig_win, '<C-y>'), {desc = 'Scroll 1 line up.', buffer = true})
    vim.keymap.set('n', 'c', util.run_normal_mode_command(winid, orig_win, '<C-f>'), {desc = 'Scroll 1 page down.', buffer = true})
    vim.keymap.set('n', 'd', util.run_normal_mode_command(winid, orig_win, '<C-b>'), {desc = 'Scroll 1 page up.', buffer = true})
    vim.keymap.set('n', 'e', util.run_normal_mode_command(winid, orig_win, 'q'), {desc = 'Scroll 1 page up.', buffer = true})
    vim.keymap.set('n', 'i', util.focus_floating_window(winid), {desc = 'Focus document window.', buffer = true})

    util.create_unmap_key_autocmds(bufid, winid, orig_buf, {'a', 'b', 'c', 'd', 'e', 'i'})

    vim.api.nvim_set_option_value('winblend', 30, {
        scope = 'local',
        win = winid
    })
end


function M.setup()

    local handler = vim.lsp.with(
        M.floating_document_viewer,
        {
            border = "rounded",
            title = "Documentation"
        }
    )

    vim.lsp.handlers["textDocument/hover"] = handler

end

return M
