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
    recurseMacroKey = "2q",
    replayMacroKey = "Q",
}

function T.startMacro()
    local keys
    if T.depth < #T.registers then
        keys = 'q' .. T.registers[T.depth + 1]
    else
        keys = 'q' .. T.registers[T.depth]
    end
    if T.depth == 0 then
        T.macros = {""}
        map("q", T.endMacro)
        map(T.recurseMacroKey, T.startMacro)
        map(T.replayMacroKey, T.replayMacro)
    else
        if T.depth < #T.registers then
            if #T.macros < T.depth + 1 then
                table.insert(T.macros, "")
            else
                T.macros[T.depth] = ""
            end
        end
        vim.fn.feedkeys('q', 'nx')
        local macro = vim.fn.getreg(T.registers[T.depth])

        if vim.endswith(macro, "2q") then
            macro = string.sub(macro, 1, #macro - 2)
        elseif vim.endswith(macro, "2") then
            macro = string.sub(macro, 1, #macro - 1)
        end
        T.macros[T.depth] = macro
    end
    if T.depth < #T.registers then
        T.depth = T.depth + 1
    end
    return keys
end

function T.replayMacro()
    vim.fn.feedkeys('q', 'nx')
    local macro = vim.fn.getreg(T.registers[T.depth])
    macro = string.sub(macro, 1, #macro - 1)
    T.macros[T.depth] = T.macros[T.depth]
        .. macro .. "@" .. T.registers[T.depth + 1]
    vim.fn.feedkeys("@" .. T.registers[T.depth + 1], "m")
    return "q" .. T.registers[T.depth]
end

function T.endMacro()
    if T.depth == 0 then
        return
    end

    vim.fn.feedkeys('q', 'nx')
    local keys = ""
    T.depth = T.depth - 1

    T.macros[T.depth + 1] = T.macros[T.depth + 1]
        .. vim.fn.getreg(T.registers[T.depth + 1])
    vim.fn.setreg(T.registers[T.depth + 1], T.macros[T.depth + 1])

    if T.depth == 0 then
        vim.cmd.unmap(T.recurseMacroKey)
        map(T.startMacroKey, T.startMacro)
        map(T.replayMacroKey, "@" .. T.registers[1])
    else
        T.macros[T.depth] = T.macros[T.depth]
            .. "@" .. T.registers[T.depth + 1]
        keys = keys .. 'q' .. T.registers[T.depth]
    end

    return keys
end

function T.start()
    map(T.startMacroKey, T.startMacro)
    unmap(T.recurseMacroKey)
    unmap(T.replayMacroKey)
end


local function setup(opts)
    opts = opts or {}
    T.registers = opts.registers or T.registers
    T.startMacroKey = opts.startMacro or T.startMacroKey
    T.recurseMacroKey = opts.recurseMacro or T.recurseMacroKey
    T.replayMacroKey = opts.replayMacro or T.replayMacroKey
    T.start()
end

return { setup = setup }
