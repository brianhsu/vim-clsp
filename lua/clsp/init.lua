local M = {}

function M.setup(config)
    local floating_document_viewer = require('clsp/floating_document_viewer')

    floating_document_viewer.setup(config.floating_document_viewer)
end

return M
