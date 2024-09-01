local M = {}
local vim = vim
local util = require('vim-clsp/util')
M.config = {
    win_config = {
        split = "right", -- left, right, above, below
        size_calculator = function ()
            if M.config.win_config.split == 'left' or M.config.win_config.split == 'right' then
                return math.floor(vim.api.nvim_win_get_width(vim.api.nvim_get_current_win()) * 0.4)
            else
                return math.floor(vim.api.nvim_win_get_height(vim.api.nvim_get_current_win()) * 0.4)
            end
        end
    }
}

M._opened_win_id = nil
M._loaded_contents = nil

local function parese_document_content(result)
    local contents ---@type string[]
    if type(result.contents) == 'table' and result.contents.kind == 'plaintext' then
        contents = vim.split(result.contents.value or '', '\n', { trimempty = true })
    else
        contents = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    end
    return contents
end

local function is_same_contents(c1, c2)
    for i, _ in pairs(c1) do
        if c1[i] ~= c2[i] then
            return false
        end
    end
    return true
end

local function create_document_buffer(contents)
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, 0, true, contents)
    vim.api.nvim_buf_set_option(buf, "modified", false)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)

    return buf
end

function M.side_document_viewer(_, result, ctx, config)

    local contents = parese_document_content(result)

    if vim.tbl_isempty(contents) then
      vim.notify('No information available')
      return
    end

    -- If there is only one window, we need open the document window regardless
    -- if the current window is from previous documentation window.
    if #vim.api.nvim_list_wins() == 1 then
        M._opened_win_id = nil
        M._loaded_contents = nil
    end

    if M._opened_win_id ~= nil and vim.api.nvim_win_is_valid(M._opened_win_id) and is_same_contents(M._loaded_contents, contents) then
        vim.api.nvim_win_close(M._opened_win_id, true)
        M._opened_win_id = nil
        M._loaded_contents = nil
        return
    else
        local buf = create_document_buffer(contents)

        if M._opened_win_id ~= nil and vim.api.nvim_win_is_valid(M._opened_win_id) then
            vim.api.nvim_win_set_buf(M._opened_win_id, buf)
        else
            local window_size = M.config.win_config.size_calculator()
            M._opened_win_id = vim.api.nvim_open_win(buf, false, {split = M.config.win_config.split, win = 0})
            vim.api.nvim_win_set_width(M._opened_win_id, window_size)
            vim.api.nvim_win_set_height(M._opened_win_id, window_size)
        end
    end

    M._loaded_contents = contents
end

function M.open_document_side()
    vim.lsp.handlers["textDocument/hover"] = M.handler
    vim.lsp.buf.hover()
end

function M.setup(config)
    M.config = util.merge(M.config, config)
    M.handler = vim.lsp.with(M.side_document_viewer, {})
end

return M
