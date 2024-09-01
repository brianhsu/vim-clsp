local M = {}
local vim = vim

function M.setup(config)

    if config == nil then
        config = {}
    end

    local floating_document_viewer = require('vim-clsp/floating_document_viewer')
    local side_document_viewer = require('vim-clsp/side_document_viewer')
    local signature_viewer = require('vim-clsp/signature_viewer')

    floating_document_viewer.setup(config.floating_document_viewer)
    side_document_viewer.setup(config.side_document_viewer)
    signature_viewer.setup(config.signature_viwer)

    vim.api.nvim_create_user_command('CLSPDocumentationFloating', floating_document_viewer.toggle_document_floating, {})
    vim.api.nvim_create_user_command('CLSPDocumentationSide', side_document_viewer.open_document_side, {})
    vim.api.nvim_create_user_command('CLSPSignatureHelp', signature_viewer.open_signature_viwer, {})
    vim.api.nvim_create_user_command('CLSPSignatureHelpToggleAlwaysOn', signature_viewer.toggle_is_always_on, {})

    vim.api.nvim_create_user_command('CLSPDeclaration', function() vim.lsp.buf.declaration() end, {})
    vim.api.nvim_create_user_command('CLSPDefinition', function() vim.lsp.buf.definition() end, {})
    vim.api.nvim_create_user_command('CLSPDocumentSymbol', function() vim.lsp.buf.document_symbol() end, {})
    vim.api.nvim_create_user_command('CLSPFormat', function() vim.lsp.buf.format() end, {})
    vim.api.nvim_create_user_command('CLSPImplementation', function() vim.lsp.buf.implementation() end, {})
    vim.api.nvim_create_user_command('CLSPIncommingCalls', function() vim.lsp.buf.incoming_calls() end, {})
    vim.api.nvim_create_user_command('CLSPOutgoingCalls', function() vim.lsp.buf.outgoing_calls() end, {})
    vim.api.nvim_create_user_command('CLSPReference', function() vim.lsp.buf.references() end, {})
    vim.api.nvim_create_user_command('CLSPRename', function() vim.lsp.buf.rename() end, {})
    vim.api.nvim_create_user_command('CLSPTypeDefinition', function() vim.lsp.buf.type_definition() end, {})
    vim.api.nvim_create_user_command('CLSPTypeHierarchy', function() vim.lsp.buf.typehierarchy() end, {})
    vim.api.nvim_create_user_command('CLSPWorkspaceSymbol', function() vim.lsp.buf.workspace_symbol() end, {})
end

return M
