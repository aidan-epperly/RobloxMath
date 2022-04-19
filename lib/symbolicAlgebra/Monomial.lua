local List = require(script.Parent.Parent.Parent.Llama).List

local Set = require(script.Parent.Set)
local directSum = require(script.Parent.Duple).directSum

local Monomial = {}

local function lexicographicCompare(left, right)
    local i = 1

    while i < #left and i < #right do
        if left[i] == right[i] then
            i = i + 1
        else
            return left[i] < right[i]
        end
    end

    if #left >= #right then
        return left[i] < right[i]
    else
        return left[i] <= right[i]
    end
end

local function subarray(array, index)
    local result = {}

    for i = 1, math.min(index, #array) do
        result[i] = array[i]
    end

    return result
end

local function suparray(array, index)
    local result = {}

    for i = index, #array do
        result[#result+1] = array[i]
    end
end


local function binarySearch(element, array)
    if array == nil or #array == 0 then
        return false
    end

    local checkIndex = math.floor(#array / 2)

    if #array == 1 then
        if element == array[1] then
            return 1
        else
            return false
        end
    end

    if element < array[checkIndex] then
        return binarySearch(element, subarray(array, checkIndex - 1))
    elseif element > array[checkIndex] then
        return checkIndex + binarySearch(element, suparray(array, checkIndex + 1))
    else
        return checkIndex
    end
end

local function monomialFromArrayAndPreSet(preset, array, coeff)
    if #array ~= #preset then
        error("Cardinality mismatch between power array and symbol set!", 2)
    end

    if preset == nil or #preset == 0 then
        local result = { Set.new({}), {} }
        setmetatable(result, Monomial)
        rawset(result, "coeff", coeff)
        return result
    end

    local preresult = List.sort(directSum(preset, array), function(a, b) 
        return b > a
    end)

    local arrayResult = {preresult[1][2]}
    local presetResult = {preresult[1][1]}

    for i = 2, #preresult do
        if preresult[i - 1][1] ~= preresult[i][1] then
            arrayResult[#arrayResult+1] = preresult[i][2]
            presetResult[#presetResult+1] = preresult[i][1]
        else
            arrayResult[#arrayResult] = arrayResult[#arrayResult] + preresult[i][2]
        end
    end

    local result = {Set.new(presetResult), arrayResult}
    setmetatable(result, Monomial)
    rawset(result, "coeff", coeff)

    return result
end

local function monomialScale(c, monomial)
    return monomialFromArrayAndPreSet(List.copy(monomial[1]), List.copy(monomial[2]), c * monomial["coeff"])
end

local function monomialDegree(monomial)
    local result = 0

    for i = 1, #monomial[1] do
        result = result + monomial[2][i]
    end

    return result
end

local function monomialReRep(left, right)
    local symbolSet = left[1] * right[1]

    local zeroArray = {}

    for i = 1, #symbolSet do
        zeroArray[i] = 0
    end

    local leftPreSet = List.concat(left[1], symbolSet)
    local leftArray = List.concat(left[2], zeroArray)
    local rightPreSet = List.concat(right[1], symbolSet)
    local rightArray = List.concat(right[2], zeroArray)

    return monomialFromArrayAndPreSet(leftPreSet, leftArray, left["coeff"]), monomialFromArrayAndPreSet(rightPreSet, rightArray, right["coeff"])
end


local function integerPower(base, exponent)
    local result = base

    for _ = 2, exponent do
        result = result * base
    end

    return result
end

local function monomialSimplify(monomial)
    local exponentArray = {}
    local symbolPreSet = {}

    if monomial["coeff"] == 0 then
        return monomialFromArrayAndPreSet({},{},0)
    end

    for i = 1, #monomial[2] do
        if monomial[2][i] ~= 0 then
            exponentArray[#exponentArray+1] = monomial[2][i]
            symbolPreSet[#symbolPreSet+1] = monomial[1][i]
        end
    end

    return monomialFromArrayAndPreSet(symbolPreSet, exponentArray, monomial["coeff"])
end


local function monomialCopy(monomial)
    local result = monomialFromArrayAndPreSet(List.copy(monomial[1]), List.copy(monomial[2]), monomial["coeff"])

    return result
end

local function monomialReplace(monomial, symbolToReplace, symbol)
    local index = binarySearch(symbolToReplace, monomial[1])

    if index == false then
        return monomialCopy(monomial)
    else
        local result = List.copy(monomial[1])
        result[index] = symbol
        return monomialFromArrayAndPreSet(result, List.copy(monomial[2]), monomial["coeff"])
    end
end

local function monomialEvaluate(monomial, rules)
    local result = monomialCopy(monomial)
    local constant = 1

    if monomial[1] == nil or monomial[2] == nil then
        return monomial["coeff"]
    end

    for key, value in pairs(rules) do
        local index = binarySearch(key, monomial[1])
        if index ~= false then
            constant = constant * integerPower(value, monomial[2][index])
            result[2][index] = 0
        end
    end

    result["coeff"] = constant * result["coeff"]

    return result
end

Monomial.__add = function (left, right)
    local leftSimple = monomialSimplify(left)
    local rightSimple = monomialSimplify(right)

    if leftSimple[1] ~= rightSimple[1] then
        error("Monomial symbol set mismatch!", 2)
    elseif not List.equals(leftSimple[2], rightSimple[2]) then
        error("Monomial degree mismatch!", 2)
    end

    return monomialFromArrayAndPreSet(left[1], left[2], left["coeff"] + right["coeff"])
end

Monomial.__mul = function (left, right)
    return monomialFromArrayAndPreSet(List.concat(left[1], right[1]), List.concat(left[2], right[2]), left["coeff"] * right["coeff"])
end

Monomial.__unm = function (monomial)
    return monomialFromArrayAndPreSet(List.copy(monomial[1]), List.copy(monomial[2]), -monomial["coeff"])
end

Monomial.__sub = function (left, right)
    return left + -right
end

--[=[ unused
Monomial.__len = function (monomial)
    return #monomial[1]
end
]=]

Monomial.__tostring = function (monomial)
    local result = tostring(monomial["coeff"])

    for i = 1, #monomial[1] do
        result = result .. tostring(monomial[1][i]) .. "^" .. tostring(monomial[2][i])
    end

    return result
end

Monomial.__eq = function (left, right)
    local leftSimple = monomialSimplify(left)
    local rightSimple = monomialSimplify(right)

    return leftSimple[1] == rightSimple[1] and List.equals(leftSimple[2], rightSimple[2])
end

Monomial.__lt = function (left, right)
    if monomialDegree(left) ~= monomialDegree(right) then
        return monomialDegree(left) < monomialDegree(right)
    else
        if monomialDegree(left) == 0 then
            return true
        end
        local leftCopy, rightCopy = monomialReRep(left, right)
        return lexicographicCompare(List.reverse(leftCopy[2]), List.reverse(rightCopy[2]))
    end
end

Monomial.__le = function (left, right)
    return left == right or left < right
end

return {
    Monomial = Monomial,
    new = monomialFromArrayAndPreSet,
    copy = monomialCopy,
    replace = monomialReplace,
    evaluate = monomialEvaluate,
    scale = monomialScale,
    simplify = monomialSimplify
}


