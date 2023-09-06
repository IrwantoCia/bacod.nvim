local M = {}
-- variable that need to be setup
M.api_key = nil

P = function(v)
    print(vim.inspect(v))
    return v
end

RELOAD = function(...)
    return require('plenary.reload').reload_module(...)
end

R = function(name)
    RELOAD(name)
    return require(name)
end

--[[ one thing need to be fixed
-- visual mode need to be escaped first before running the command
]] --
M._get_lines = function()
    local line1 = vim.api.nvim_buf_get_mark(0, "<")[1]
    local line2 = vim.api.nvim_buf_get_mark(0, ">")[1]
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2 + 1, false)
    local clean_lines = {}
    for _, line in ipairs(lines) do
        local cleaned_line = vim.trim(line)
        table.insert(clean_lines, cleaned_line)
    end
    return clean_lines
end

M.call_gpt = function()
    local lines = M._get_lines()
    if #lines == 0 then
        print("No lines selected")
        return
    end

    local text = vim.fn.join(lines, " ")

    -- currently using chatgpt4 api
    -- TODO: need to make it stream the result
    local messages = '"messages": [{"role": "user",' ..
        '"content": "' ..
        'each requirement seperated with .' ..
        'function starts with word input: .' ..
        'generate 1 test case using given language test framework. ' ..
        'Only return the code. ' ..
        'Do not add descriptption. ' ..
        'input: ' .. text .. '"}],'
    local command = "curl https://api.openai.com/v1/chat/completions -s " ..
        "-H \"Content-Type: application/json\" " ..
        "-H " .. '"Authorization: Bearer ' .. M.api_key .. '" ' ..
        "-d '{" ..
        '"model": "gpt-4",' ..
        messages ..
        '"temperature": 1.0' ..
        "}'"

    local jq_command = " | jq --raw-output .choices[0].message.content"
    local handle = io.popen(command .. jq_command)
    if handle == nil then
        print("Error")
        return
    end

    local response = handle:read("*a")
    local result = vim.trim(response)
    handle:close()

    local result_table = {}
    for s in result:gmatch("[^\r\n]+") do
        table.insert(result_table, s)
    end

    -- create and open new buffer in vertical split
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    vim.api.nvim_buf_set_lines(buf, 0, -1, true, result_table)
end

M.setup = function(api_key)
    M.api_key = api_key
end

return M
