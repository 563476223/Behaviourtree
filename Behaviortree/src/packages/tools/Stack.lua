--
-- Date: 2014-11-19 15:29:02
--
local Stack = class("Stack")

function Stack:ctor()
    self.stack_table = {}
end

function Stack:push(element)
    local size = self:size()
    self.stack_table[size + 1] = element
end

function Stack:pop()
    local size = self:size()
    if self:isEmpty() then
        printError("Error: Stack is empty!")
        return
    end
    return table.remove(self.stack_table,size)
end

function Stack:top()
    local size = self:size()
    if self:isEmpty() then
        printError("Error: Stack is empty!")
        return
    end
    return self.stack_table[size]
end

function Stack:isEmpty()
    local size = self:size()
    if size == 0 then
        return true
    end
    return false
end

function Stack:size()
    return table.nums(self.stack_table) or 0
end

function Stack:clear()
    -- body
    self.stack_table = nil
    self.stack_table = {}
end

function Stack:printElement()
    local size = self:size()

    if self:isEmpty() then
        printError("Error: Stack is empty!")
        return
    end

    local str = "{"..self.stack_table[size]
    size = size - 1
    while size > 0 do
        str = str..", "..self.stack_table[size]
        size = size - 1
    end
    str = str.."}"
    print(str)
end


return Stack