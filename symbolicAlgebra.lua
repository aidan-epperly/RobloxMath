local symbolicAlgebra = {}

local shallowCopyTable = function (table)
    local result = {}

    for key, value in ipairs(table) do
        result[key] = value
    end

    return result
end

local _symbolicPolynomial = {}

local shallowCopyPolynomial = function (polynomial)
    local result = setmetatable(shallowCopyTable(polynomial), _symbolicPolynomial)
    rawset(result, "symbol", polynomial["symbol"])
    return result
end

local _symbolicPolynomialFromArray = function (table)
    local polynomial = setmetatable(shallowCopyTable(table), _symbolicPolynomial)

    rawset(polynomial, "symbol", "x")

    return polynomial
end

local _symbolicPolynomialIsSingleVariable = function (polynomial)
    local check = true

    for i = 1, #polynomial do
        check = check and getmetatable(polynomial[i]) == _symbolicPolynomial
    end

    return not check
end

local _symbolicPolynomialSetSymbol = function (polynomial, symbol)
    local result = shallowCopyPolynomial(polynomial)
    result["symbol"] = symbol
    return result
end

local _symbolicPolynomialConstant = function (c)
    return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray({c}), "")
end

local _symbolicPolynomialShiftAndScale
_symbolicPolynomialShiftAndScale = function (s, c, polynomial)
    local result = {}

    for i = 1, s do
        result[i] = 0
    end

    for i = 1, #polynomial do
        if getmetatable(polynomial[i]) == _symbolicPolynomial then
            result[s + i] = _symbolicPolynomialShiftAndScale(0, c, polynomial[i])
        else
            result[s + i] = c * polynomial[i]
        end
    end

    return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), polynomial["symbol"])
end

local _symbolicPolynomialEvaluateSingleVariable = function (polynomial, c)
    if #polynomial == 1 then
        return polynomial[1]
    end

    local eval = polynomial[#polynomial - 1] + c * polynomial[#polynomial]

    for i = #polynomial - 1, 2, -1 do
        eval = polynomial[i - 1] + c * eval
    end

    return eval
end

local _symbolicPolynomialGeneralizedAddition = function (left, right)
    if getmetatable(left) == _symbolicPolynomial and getmetatable(right) == _symbolicPolynomial then
        return left + right
    elseif getmetatable(left) == _symbolicPolynomial then
        return _symbolicPolynomialConstant(right) + left
    elseif getmetatable(right) == _symbolicPolynomial then
        return _symbolicPolynomialConstant(left) + right
    else
        return left + right
    end
end

local _symbolicPolynomialGeneralizedMultiply = function (left, right)
    if getmetatable(left) == _symbolicPolynomial and getmetatable(right) == _symbolicPolynomial then
        return left * right
    elseif getmetatable(left) == _symbolicPolynomial then
        return _symbolicPolynomialConstant(right) * left
    elseif getmetatable(right) == _symbolicPolynomial then
        return _symbolicPolynomialConstant(left) * right
    else
        return left * right
    end
end

local _symbolicPolynomialEvaluate
_symbolicPolynomialEvaluate = function (polynomial, rules)
    if getmetatable(polynomial) ~= _symbolicPolynomial then
        return polynomial
    end

    local rule = rules[polynomial["symbol"]]
    local check = type(rule) ~= "nil"

    if _symbolicPolynomialIsSingleVariable(polynomial) and check then
        return _symbolicPolynomialEvaluateSingleVariable(polynomial, rules[polynomial["symbol"]])
    elseif _symbolicPolynomialIsSingleVariable(polynomial) then
        return polynomial
    end

    if #polynomial == 1 and getmetatable(polynomial[1]) ~= _symbolicPolynomial then
        return polynomial[1]
    end

    local eval

    if getmetatable(polynomial[#polynomial]) == _symbolicPolynomial and check then
        eval = _symbolicPolynomialGeneralizedAddition(polynomial[#polynomial - 1], _symbolicPolynomialShiftAndScale(0,rule,polynomial[#polynomial]))
    elseif check then
        eval = _symbolicPolynomialGeneralizedAddition(polynomial[#polynomial - 1], rule * polynomial[#polynomial])
    elseif not check then
        local polynomialCopy = shallowCopyPolynomial(polynomial)
        for i = 1, #polynomial do
            polynomialCopy[i] = _symbolicPolynomialEvaluate(polynomial[i], rules)
        end
        return polynomialCopy
    end

    for i = #polynomial - 1, 2, -1 do
        if getmetatable(eval) == _symbolicPolynomial and check then
            eval = _symbolicPolynomialGeneralizedAddition(polynomial[i - 1], _symbolicPolynomialShiftAndScale(0,rule,eval))
        else
            eval = _symbolicPolynomialGeneralizedAddition(polynomial[#polynomial - 1], rule * eval)
        end
    end

    return _symbolicPolynomialEvaluate(eval, rules)
end

local _symbolicPolynomialFormalDerivative = function (polynomial)
    local result = {}

    for i = 1, #polynomial - 1 do
        result[i] = _symbolicPolynomialGeneralizedMultiply(i, polynomial[i + 1])
    end

    return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), polynomial["symbol"])
end

local _symbolicPolynomialFormalAntiderivative = function (polynomial, c)
    local result = {c}

    for i = 2, #polynomial + 1 do
        result[i] = _symbolicPolynomialGeneralizedMultiply(1/(i-1), polynomial[i - 1])
    end

    return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), polynomial["symbol"])
end

local _symbolicPolynomialAddition = function (left, right)
    local result = {}

    local minLength = math.min(#left, #right)
    local maxLength = math.max(#left, #right)

    for i = 1, minLength do
        result[i] = left[i] + right[i]
    end

    if minLength == maxLength then
        return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), right["symbol"])
    elseif #left > #right then
        for i = minLength + 1, maxLength do
            result[i] = left[i]
        end
    else
        for i = minLength + 1, maxLength do
            result[i] = right[i]
        end
    end

    return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), right["symbol"])
end

local _symbolicPolynomialAddConstant
_symbolicPolynomialAddConstant = function (c, right)
    local result = shallowCopyPolynomial(right)

    if getmetatable(right[1]) == _symbolicPolynomial then
        result[1] = _symbolicPolynomialAddConstant(result[1])
        return result
    else
        result[1] = result[1] + c
        return result
    end
end

_symbolicPolynomial.__add = function(left, right)
    local check = left["symbol"] == right["symbol"]
    local leftCheck = _symbolicPolynomialIsSingleVariable(left)
    local rightCheck = _symbolicPolynomialIsSingleVariable(right)

    local result = {}

    local minLength = math.min(#left, #right)
    local maxLength = math.max(#left, #right)

    if leftCheck and rightCheck and check then
        return _symbolicPolynomialAddition(left, right)
    elseif check then
        for i = 1, minLength do
            if getmetatable(left[i]) == _symbolicPolynomial and getmetatable(right) == _symbolicPolynomial then
                result[i] = left[i] + right[i]
            elseif getmetatable(left[i]) == _symbolicPolynomial then
                result[i] = _symbolicPolynomialAddConstant(right[i], left[i])
            elseif getmetatable(right[i]) == _symbolicPolynomial then
                result[i] = _symbolicPolynomialAddConstant(left[i], right[i])
            else
                result[i] = left[i] + right[i]
            end
        end

        if minLength == maxLength then
            return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), right["symbol"])
        elseif #left > #right then
            for i = minLength + 1, maxLength do
                result[i] = left[i]
            end
        else
            for i = minLength + 1, maxLength do
                result[i] = right[i]
            end
        end
    else
        result = shallowCopyPolynomial(right)
        if getmetatable(result[1]) == _symbolicPolynomial then
            result[1] = left + result[1]
        else
            result[1] = _symbolicPolynomialAddConstant(result[1], left)
        end
    end

    return result
end

_symbolicPolynomial.__sub = function(left, right)
    local check = left["symbol"] == right["symbol"]
    local leftCheck = _symbolicPolynomialIsSingleVariable(left)
    local rightCheck = _symbolicPolynomialIsSingleVariable(right)

    local result = {}

    local minLength = math.min(#left, #right)
    local maxLength = math.max(#left, #right)

    if leftCheck and rightCheck and check then
        return _symbolicPolynomialAddition(-left, right)
    elseif check then
        for i = 1, minLength do
            if getmetatable(left[i]) == _symbolicPolynomial and getmetatable(right) == _symbolicPolynomial then
                result[i] = left[i] - right[i]
            elseif getmetatable(left[i]) == _symbolicPolynomial then
                result[i] = _symbolicPolynomialAddConstant(-right[i], left[i])
            elseif getmetatable(right[i]) == _symbolicPolynomial then
                result[i] = _symbolicPolynomialAddConstant(left[i], -right[i])
            else
                result[i] = left[i] - right[i]
            end
        end

        if minLength == maxLength then
            return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), right["symbol"])
        elseif #left > #right then
            for i = minLength + 1, maxLength do
                result[i] = left[i]
            end
        else
            for i = minLength + 1, maxLength do
                result[i] = -right[i]
            end
        end
    else
        result = shallowCopyPolynomial(-right)
        if getmetatable(result[1]) == _symbolicPolynomial then
            result[1] = left + result[1]
        else
            result[1] = _symbolicPolynomialAddConstant(result[1], left)
        end
    end

    return result
end

_symbolicPolynomial.__unm = function (polynomial)
    local result = {}

    for i = 1, #polynomial do
        result[i] = -polynomial[i]
    end

    return _symbolicPolynomialSetSymbol(_symbolicPolynomialFromArray(result), polynomial["symbol"])
end

_symbolicPolynomial.__mul = function(left, right)
    local result = _symbolicPolynomialFromArray({})
    result = _symbolicPolynomialSetSymbol(result, right["symbol"])

    local check = left["symbol"] == right["symbol"]
    local leftCheck = _symbolicPolynomialIsSingleVariable(left)
    local rightCheck = _symbolicPolynomialIsSingleVariable(right)

    if leftCheck and rightCheck and check then
        for i = 1, #left do
            result = result + _symbolicPolynomialShiftAndScale(i - 1, left[i], right)
        end
        return result
    elseif leftCheck and check then
        for i = 1, #left do
            result = result + _symbolicPolynomialShiftAndScale(i - 1, left[i], right)
        end
        return result
    elseif rightCheck and check then
        for i = 1, #left do
            result = result + left[i] * _symbolicPolynomialShiftAndScale(i - 1, 1, right)
        end
        return result
    else
        for i = 1, #right do
            if getmetatable(right[i]) == _symbolicPolynomial then
                result[i] = left * right[i]
            else
                result[i] = _symbolicPolynomialShiftAndScale(0, right[i], left)
            end
        end
    end

    return result
end

_symbolicPolynomial.__tostring = function (polynomial)
    local result = ""

    local check = true
    local zeroCheck = true

    for i = 1, #polynomial do
        zeroCheck = zeroCheck and polynomial[i] == 0
    end

    if #polynomial == 0 or zeroCheck then
        return "0"
    elseif #polynomial == 1 then
        return tostring(polynomial[1])
    end

    for i = 1, #polynomial do
        if tostring(polynomial[i]) ~= "0" and check then
            if polynomial[i] ~= 1 or i == 1 then
                result = result .. tostring(polynomial[i])
            end
            if i == 2 then
                result = result .. polynomial["symbol"]
            elseif i > 1 then
                result = result .. polynomial["symbol"] .. "^" .. tostring(i - 1)
            end
            check = false
        elseif tostring(polynomial[i]) ~= "0" and i > 1 then
            if polynomial[i] ~= 1 or i == 1 then
                result = result .. " + " .. tostring(polynomial[i])
            else
                result = result .. " + "
            end
            if i == 2 then
                result = result .. polynomial["symbol"]
            elseif i > 1 then
                result = result .. polynomial["symbol"] .. "^" .. tostring(i - 1)
            end
        end
    end

    return result
end

symbolicAlgebra.polynomial = {}

symbolicAlgebra.polynomial.new = function (array)
    return _symbolicPolynomialFromArray(array)
end

symbolicAlgebra.polynomial.eval = function (polynomial, rules)
    if _symbolicPolynomialIsSingleVariable(polynomial) then
        local c
        if type(rules) == "table" then
            c = rules[polynomial["symbol"]]
        else
            c = rules
        end
        return _symbolicPolynomialEvaluateSingleVariable(polynomial, c)
    else
        return _symbolicPolynomialEvaluate(polynomial, rules)
    end
end

symbolicAlgebra.polynomial.derivative = function (polynomial)
    return _symbolicPolynomialFormalDerivative(polynomial)
end

symbolicAlgebra.polynomial.integral = function (polynomial, c)
    return _symbolicPolynomialFormalAntiderivative(polynomial, c)
end

symbolicAlgebra.polynomial.setSymbol = function (polynomial, symbol)
    return _symbolicPolynomialSetSymbol(polynomial, symbol)
end

symbolicAlgebra.polynomial.constant = function (r)
    return _symbolicPolynomialFromArray({r})
end

return symbolicAlgebra