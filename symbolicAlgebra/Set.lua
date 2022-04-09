local List = require(script.Parent.Parent.Parent.Llama).List

local function removeDuplicatesFromSortedList(array)
    local result = {array[1]}

    for i = 2, #array do
        if array[i - 1] ~= array[i] then
            result[#result+1] = array[i]
        end
    end

    return result
end

local function setFromArray(array) 
    local set = removeDuplicatesFromSortedList(List.sort(array, function(a, b) 
        return a < b 
    end))

    return setmetatable(set, {
        
    })
end

local Set = {}

Set.__add = function (left, right)
    local result = setFromArray({})

    local i = 0
    local j = 0

    while i < #left or j < #right do
        if i == #left then
            result[i + j + 1] = right[j + 1]
            j = j + 1
        elseif j == #right then
            result[i + j + 1] = left[i + 1]
            i = i + 1        
        elseif left[i] < right[j] then
            result[i + j + 1] = left[i + 1]
            i = i + 1
        elseif left[i] == right[j] then
            result[i + j + 1] = left[i + 1]
            i = i + 1
            j = j + 1
        else
            result[i + j + 1] = right[j + 1]
            j = j + 1
        end
    end

    return result
end

Set.__mul = function (left, right)
    local result = setFromArray({})

    if left == nil or right == nil or #left == 0 or #right == 0 then
        return result
    end

    local i = 1
    local j = 1

    while i <= #left and j <= #right do
        while i <= #left and j <= #right and left[i] < right[j] do
            i = i + 1
        end
        while i <= #left and j <= #right and left[i] > right[j] do
            j = j + 1
        end
        if left[i] == right[j] then
            result[#result+1] = left[i]
            i = i + 1
            j = j + 1
        end
    end

    return result
end

Set.__eq = function (left, right)
    if #left ~= #right then
        return false
    end

    for i = 1, #left do
        if left[i] ~= right[i] then
            return false
        end
    end

    return true
end

Set.__lt = function (left, right)
    if #left >= #right then
        return false
    end

    return left * right == left
end

Set.__le = function (left, right)
    return left * right == left
end



return {
    Set = Set,
    new = setFromArray,
    removeDuplicatesFromSortedList = removeDuplicatesFromSortedList
}