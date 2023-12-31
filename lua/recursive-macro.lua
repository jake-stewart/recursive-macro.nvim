local function map(mapping, f, remap)
    remap = remap or false
    vim.keymap.set({"n", "v"}, mapping, f, { expr = true, remap = remap })
end

local function unmap(mapping)
    vim.keymap.set({"n", "v"}, mapping, function()
        return ""
    end, { expr = true })
end

local T = {
    registers = {"q", "w", "e", "r", "t", "y"},
    depth = 0,
    macros = {},
    startMacroKey = "q",
    replayMacroKey = "Q",
}

function T.startMacro()
    if T.depth >= #T.registers  then
        return ""
    end
    T.depth = T.depth + 1
    local keys = 'q' .. T.registers[T.depth]
    if T.depth == 1 then
        T.macros = {"", ""}
        map("q", T.endMacro)
        map("2q", T.startMacro)
        map(T.replayMacroKey, T.replayMacro)
    else
        if #T.macros < T.depth + 1 then
            table.insert(T.macros, "")
        else
            T.macros[T.depth + 1] = ""
        end
        vim.fn.feedkeys('q', 'nx')
        local macro = vim.fn.getreg(T.registers[T.depth - 1])

        if vim.endswith(macro, "2q") then
            macro = string.sub(macro, 1, #macro - 2)
        elseif vim.endswith(macro, "2") then
            macro = string.sub(macro, 1, #macro - 1)
        else
            macro = ""
        end
        T.macros[T.depth - 1] = T.macros[T.depth - 1] .. macro
    end
    return keys
end

function T.replayMacro()
    if #T.macros < T.depth + 2 then
        return ""
    end
    vim.fn.feedkeys('q', 'nx')
    local macro = vim.fn.getreg(T.registers[T.depth])
    T.macros[T.depth + 1] = T.macros[T.depth + 1]
        .. macro .. T.macros[T.depth + 2]
    vim.fn.feedkeys(T.macros[T.depth + 2], "m")
    return "q" .. T.registers[T.depth]
end

function T.endMacro()
    vim.fn.feedkeys('q', 'nx')
    local macro = vim.fn.getreg(T.registers[T.depth])
    T.macros[T.depth + 1] = T.macros[T.depth + 1] .. macro
    T.depth = T.depth - 1
    T.macros[T.depth + 1] = T.macros[T.depth + 1]
        .. T.macros[T.depth + 2]
    if T.depth == 0 then
        unmap("2q")
        map(T.startMacroKey, T.startMacro)
        vim.fn.setreg(T.registers[1], T.macros[1])
        map(T.replayMacroKey, function()
            return "@" .. T.registers[1]
        end, true)
        return ""
    else
        return 'q' .. T.registers[T.depth]
    end
end

function T.start()
    map(T.startMacroKey, T.startMacro)
    unmap("2q")
    unmap(T.replayMacroKey)
end


local function setup(opts)
    opts = opts or {}
    T.registers = opts.registers or T.registers
    T.startMacroKey = opts.startMacro or T.startMacroKey
    T.replayMacroKey = opts.replayMacro or T.replayMacroKey
    T.start()
end

return { setup = setup }
