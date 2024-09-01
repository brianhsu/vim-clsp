local module = {}
local vim = vim

function module.run_normal_mode_command(float_win_id, parent_win_id, key)
    return function ()
        if vim.api.nvim_get_current_win() == parent_win_id then
            vim.api.nvim_set_current_win(float_win_id)
            vim.cmd.normal(vim.api.nvim_replace_termcodes(key, true, true, true))
            vim.api.nvim_set_current_win(parent_win_id)
        end
    end
end

function module.focus_floating_window(win_id)
    return function ()
       vim.api.nvim_set_current_win(win_id)
    end
end

function module.unmap_keys(float_buf_id, parent_buf_id, keys)
    local new_buf_id = vim.api.nvim_get_current_buf()

    vim.api.nvim_set_current_buf(parent_buf_id)

    for _, key in pairs(keys) do
        vim.keymap.del('n', key, {buffer = true})
    end

    if new_buf_id ~= float_buf_id then
       vim.api.nvim_set_current_buf(new_buf_id)
    end
end

function module.call_when_window_closed(float_win_id, callback)
    local floting_win_group = vim.api.nvim_create_augroup('floating_win_group', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinClosed' }, {
      pattern = tostring(float_win_id),
      group = floting_win_group,
      callback = callback
  })
end

return module
