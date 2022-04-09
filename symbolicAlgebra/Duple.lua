local Duple = {}
Duple.__eq = function (left, right)
    return left[1] == right[1] and left[2] == right[2]
end

Duple.__lt = function (left, right)
    if left[1] == right[1] then
        return left[2] < right[2]
    else
        return left[1] < right[1]
    end
end

Duple.__le = function (left, right)
    return left < right or left == right
end

local function dupleFromTwoInputs(left, right) 
    local result = { left, right }

    return setmetatable(result, Duple)
end

local function directSum(left, right)
    if #left ~= #right then
        error("Cardinality mismatch between left and right arrays!", 2)
    end

    local result = {}

    for i = 1, #left do
        result[i] = dupleFromTwoInputs(left[i], right[i])
    end

    return result
end

return {
    Duple = Duple,
    new = dupleFromTwoInputs,
    directSum = directSum
}