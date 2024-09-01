local M = {}

function M.setup()
    local floating_document_viewer = require('clsp/floating_document_viewer')
    floating_document_viewer.setup()
    print('Hello')
end

return M
