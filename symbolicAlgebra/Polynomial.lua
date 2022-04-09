local List = require(script.Parent.Parent.Parent.Llama).List
local Monomial = require(script.Parent.Monomial)

local Polynomial = {}

local function polynomialFromArrayOfMonomials(array)
    local preresult = List.sort(array, function(a, b) 
        return b > a
    end)

    local result = {preresult[1]}

    for i = 2, #array do
        if preresult[i - 1] == preresult[i] then
            result[#result] = result[#result] + preresult[i]
        else
            result[#result+1] = preresult[i]
        end
    end

    setmetatable(result, Polynomial)
    return result
end

local function polynomialCopy(polynomial)
    local result = {}

    for i = 1, #polynomial do
        result[#result+1] = Monomial.copy(polynomial[i])
    end
end

local function polynomialReplace(polynomial, symbolToReplace, symbol)
    local result = {}

    for i = 1, #polynomial do
        result[i] = Monomial.replace(polynomial[i], symbolToReplace, symbol)
    end

    return polynomialFromArrayOfMonomials(result)
end

local function polynomialScale(c, polynomial)
    local result = {}

    for i = 1, #polynomial do
        result[i] = Monomial.scale(c, polynomial[i])
    end

    return polynomialFromArrayOfMonomials(result)
end

local function polynomialSimplify(polynomial)
    local result = {}

    for i = 1, #polynomial do
        local simple = Monomial.simplify(polynomial[i])
        if simple["coeff"] ~= 0 then
            result[#result+1] = simple
        end
    end

    return polynomialFromArrayOfMonomials(result)
end

local function polynomialFromArray(array)
    local result = {}

    for i = 1, #array do
        result[i] = Monomial.new({"x"}, {i - 1}, array[i])
    end

    return polynomialFromArrayOfMonomials(result)
end

local function polynomialEvaluate(polynomial, rules)
    local result = {}

    for i = 1, #polynomial do
        local simple = Monomial.simplify(Monomial.evaluate(polynomial[i], rules))
        if simple["coeff"] ~= 0 then
            result[#result+1] = simple
        end
    end

    return polynomialFromArrayOfMonomials(result)
end

Polynomial.__add = function (left, right)
    local preresult = List.concat(left, right)

    return polynomialFromArrayOfMonomials(preresult)
end

Polynomial.__unm = function (polynomial)
    local result = {}

    for i = 1, #polynomial do
        result[i] = -polynomial[i]
    end

    return polynomialFromArrayOfMonomials(result)
end

Polynomial.__sub = function (left, right)
    return left + -right
end

Polynomial.__mul = function (left, right)
    local result = {}

    for i = 1, #left do
        for j = 1, #right do
            result[#result+1] = left[i] * right[j]
        end
    end

    return polynomialFromArrayOfMonomials(result)
end

Polynomial.__tostring = function (polynomial)
    local result = tostring(polynomial[1])

    for i = 2, #polynomial do
        result = result .. " + " .. tostring(polynomial[i])
    end

    return result
end

return {
    new = function(array) 
        if getmetatable(array[1]) == Monomial then
            return polynomialSimplify(polynomialFromArrayOfMonomials(array))
        else
            return polynomialSimplify(polynomialFromArray(array))
        end
    end,
    copy = polynomialCopy,
    replace = polynomialReplace,
    scale = polynomialScale,
    simplify = polynomialSimplify,
    evaluate = polynomialEvaluate
}