local M = {} -- M stands for module, a naming convention

function M.setup(opts)
  opts = opts or {}

end


local ns = vim.api.nvim_create_namespace("strunked")

local synonyms = {}

function M.load_synonyms(file_path)
  -- local json = require('cjson')
  local f = io.open(file_path, 'r')
  if f then
    local content = f:read('*all')
    f:close()
    synonyms = vim.json.decode(content)
  else
    print("Error: Unable to open synonyms file")
  end

--    if synonyms['abdomen'] == nil then
--         print('ERROR - adbdomen not found')
--     else
--         print('OK - abdomen found')
--         print('OK - abdomen found consider using a synonym: ' .. synonyms['abdomen'] )
--     end

    -- if synonyms['abdominal'] ~= nil then
    --     print('ERROR - abdominal found')
    -- else
    --     print('OK - abdominal not found')
    -- end

end

function M.check_synonyms()
    local bufnr = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local diagnostics = {}

    for lnum, line in ipairs(lines) do

        for word in line:gmatch("%w+") do
            if synonyms[word] ~= nil then
                -- print('word: ' .. word .. ' is a latin based word. consider revising')
                local start, ending = line:find(word)
                while start do
                    table.insert(diagnostics, {
                        bufnr = bufnr,
                        lnum = lnum -1,
                        col = start -1,
                        end_col = ending,
                        message = "Consider using a synonym: " .. synonyms[word],
                        severity = vim.diagnostic.severity.WARN,
                    })
                    start, ending = line:find(word, ending + 1)
                end
            end
        end
    end

--    for word, syn_list in pairs(synonyms) do
--      local start, ending = line:find(word)
--      while start do
--        table.insert(diagnostics, {
--          bufnr = bufnr,
--          lnum = lnum - 1,
--          col = start - 1,
--          end_col = ending,
--          message = "Consider using a synonym: " .. table.concat(syn_list, ", "),
--          severity = vim.diagnostic.severity.WARN,
--        })
--        start, ending = line:find(word, ending + 1)
--      end
--    end
 -- end

    vim.diagnostic.set(ns, bufnr, diagnostics, { virtual_text = true })

--  vim.diagnostic.set(vim.diagnostic.get_namespace("synonym_checker"), bufnr, diagnostics)
end

-- Function to open the floating window with a table of words
-- Function to open the floating window with a table of words and replace the word under the cursor with the selected word

-- Global variables to store the selected word and window handle
_G.selected_word = nil
_G.win = nil
_G.buf = nil

-- Function to open the floating window with a table of words and replace the word under the cursor with the selected word
function M.suggest_word()
    -- Get the word under the cursor
    local word = vim.fn.expand("<cword>")

    -- Define a table of words
    local words = {
        "apple",
        "banana",
        "cherry",
        "date",
        "elderberry",
        "fig",
        "grape",
        "honeydew",
    }

    -- Create a string from the words table (each word on a new line)
    local word_list = table.concat(words, "\n")

    -- Get the cursor position
    -- local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    -- Set up the floating window configuration
    local opts = {
        relative = 'cursor',
        width = 20,
        height = #words,
        col = 0,
        row = 1,
        anchor = 'NW',
        border = 'rounded',
    }

    -- Create a new buffer for the popup window
    _G.buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer (no lines, listed)
    vim.api.nvim_buf_set_lines(_G.buf, 0, -1, false, vim.split(word_list, "\n")) -- Set the lines in the buffer
    _G.win = vim.api.nvim_open_win(_G.buf, true, opts) -- Open the floating window

    -- Store selected word globally
    _G.selected_word = nil

    -- Function to close the window and replace the word under the cursor with the selected word
    _G.close_and_replace = function()

        local selected_word = vim.fn.expand("<cword>")
        vim.api.nvim_win_close(_G.win, true)  -- close the window, we are no longer in a menu
        local word_to_replace = vim.fn.expand("<cword>")

        local key = vim.api.nvim_replace_termcodes("ciw" .. selected_word .. "<Esc>", true, false, true)
        vim.api.nvim_feedkeys(key, 'n', false)

    end

    _G.close_without_replace = function()
        vim.api.nvim_win_close(_G.win, true)
    end


    -- Key mappings for selection
    -- We will move through the list with 'j' (down) and 'k' (up), and use 'Enter' to select
    -- tehse keymaps will only be valid for the _G.buf buffer {the menu window}
    vim.api.nvim_buf_set_keymap(_G.buf, 'n', 'j', ':lua vim.fn.cursor(vim.fn.line(".") + 1, 1)<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(_G.buf, 'n', 'k', ':lua vim.fn.cursor(vim.fn.line(".") - 1, 1)<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(_G.buf, 'n', '<CR>', ':lua _G.close_and_replace()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(_G.buf, 'n', '<Esc>', ':lua _G.close_without_replace()<CR>', { noremap = true, silent = true })

    -- Highlight the selected line (initially the first word)
    vim.api.nvim_buf_add_highlight(_G.buf, -1, 'Visual', 0, 0, -1)

end



return M

