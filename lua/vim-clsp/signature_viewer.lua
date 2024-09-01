local M = {}
local util = require('vim-clsp/util')
local vim = vim
local auto_cmd_group_name = 'SignatureHelpViewer'

M.config = {
    win_blend = 15,
    win_config = {
        border = "rounded"
    }
}

M._opened_win_id = nil
M._is_always_on = false

function M.signature_help_viewer(_, result, ctx, config)
    local float_buf_id, float_win_id = vim.lsp.handlers.signature_help(_, result, ctx, config)

    vim.api.nvim_set_option_value('winblend', M.config.win_blend, {scope = 'local', win = float_win_id})

    M._opened_win_id = float_win_id
end

function M.toggle_is_always_on()
    if M._is_always_on then
        vim.api.nvim_clear_autocmds({group = auto_cmd_group_name})
    else
        vim.api.nvim_create_autocmd("CursorHold", {
            pattern = '*',
            group = vim.api.nvim_create_augroup(auto_cmd_group_name, { clear = true }),
            callback = vim.lsp.buf.signature_help
        })
    end

    M._is_always_on = not M._is_always_on
end

function M.open_signature_viwer()
    if M._opened_win_id ~= nil and not vim.api.nvim_win_is_valid(M._opened_win_id) then
        M._opened_win_id = nil
    end

    if M._opened_win_id == nil then
        vim.lsp.buf.signature_help()
    else
        vim.api.nvim_win_close(M._opened_win_id, false)
    end

end

function M.setup(config)
    M.config = util.merge(M.config, config)
    M.handler = vim.lsp.with(M.floating_document_viewer, M.config.win_config)

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(M.signature_help_viewer, M.config.win_config)
end

return M
