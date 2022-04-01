local polynomialAlgebra = {}

local shallowCopyTable = function (table)
    local result = {}

    for key, value in ipairs(table) do
        result[key] = value
    end

    return result
end

local _polynomial = {}

local _polynomialFromArray = function (table)
    local polynomial = setmetatable(shallowCopyTable(table), _polynomial)

    rawset(polynomial, "symbol", "x")

    return polynomial
end

local _polynomialSetSymbol = function (polynomial, symbol)
    polynomial["symbol"] = symbol
end

local _polynomialShiftAndScale = function (s, c, polynomial)
    local result = {}

    for i = 1, s do
        result[i] = 0
    end

    for i = 1, #polynomial do
        result[s + i] = c * polynomial[i]
    end

    return _polynomialFromArray(result)
end

local _polynomialEvaluate = function (polynomial, c)
    if #polynomial == 1 then
        return polynomial[1]
    end

    local eval = polynomial[#polynomial - 1] + c * polynomial[#polynomial]

    for i = #polynomial - 1, 2, -1 do
        eval = polynomial[i - 1] + c * eval
    end

    return eval
end

local _polynomialFormalDerivative = function (polynomial)
    local result = {}

    for i = 1, #polynomial - 1 do
        result[i] = i * polynomial[i + 1]
    end

    return _polynomialFromArray(result)
end

local _polynomialFormalAntiderivative = function (polynomial, c)
    local result = {c}

    for i = 2, #polynomial + 1 do
        result[i] = polynomial[i - 1] / (i - 1)
    end

    return _polynomialFromArray(result)
end

_polynomial.__add = function(left, right)
    local result = {}

    local minLength = math.min(#left, #right)
    local maxLength = math.max(#left, #right)

    for i = 1, minLength do
        result[i] = left[i] + right[i]
    end

    if minLength == maxLength then
        return _polynomialFromArray(result)
    elseif #left > #right then
        for i = minLength + 1, maxLength do
            result[i] = left[i]
        end
    else
        for i = minLength + 1, maxLength do
            result[i] = right[i]
        end
    end

    return _polynomialFromArray(result)
end

_polynomial.__sub = function(left, right)
    local result = {}

    local minLength = math.min(#left, #right)
    local maxLength = math.max(#left, #right)

    for i = 1, minLength do
        result[i] = left[i] - right[i]
    end

    if minLength == maxLength then
        return _polynomialFromArray(result)
    elseif #left > #right then
        for i = minLength + 1, maxLength do
            result[i] = left[i]
        end
    else
        for i = minLength + 1, maxLength do
            result[i] = -right[i]
        end
    end

    return _polynomialFromArray(result)
end

_polynomial.__unm = function (polynomial)
    local result = {}

    for i = 1, #polynomial do
        result[i] = -polynomial[i]
    end

    return _polynomialFromArray(result)
end

_polynomial.__mul = function(left, right)
    local result = _polynomialFromArray({})

    for i = 1, #left do
        result = result + _polynomialShiftAndScale(i - 1, left[i], right)
    end

    return result
end

_polynomial.__tostring = function (polynomial)
    local result = ""

    for i = 1, #polynomial do
        if i == 1 then
            result = result .. tostring(polynomial[i])
        elseif polynomial[i] ~= 0 and i > 1 then
            result = result .. " + " .. tostring(polynomial[i]) .. polynomial["symbol"] .. "^" .. tostring(i - 1)
        end
    end

    return result
end

polynomialAlgebra.polynomial = {}

polynomialAlgebra.polynomial.new = function (array)
    return _polynomialFromArray(array)
end

polynomialAlgebra.polynomial.eval = function (polynomial, c)
    return _polynomialEvaluate(polynomial, c)
end

polynomialAlgebra.polynomial.derivative = function (polynomial)
    return _polynomialFormalDerivative(polynomial)
end

polynomialAlgebra.polynomial.integral = function (polynomial, c)
    return _polynomialFormalAntiderivative(polynomial, c)
end

polynomialAlgebra.polynomial.setSymbol = function (polynomial, symbol)
    _polynomialSetSymbol(polynomial, symbol)
end

polynomialAlgebra.polynomial.constant = function (r)
    return _polynomialFromArray({r})
end

local _formalSeries = {}

local _formalSeriesFromRule = function (rule)
    local formalSeries = setmetatable({}, _formalSeries)

    rawset(formalSeries, "rule", rule)

    return formalSeries
end

local _polynomialFromFormalSeries = function (formalSeries, n)
    local result = {}
    local rule = formalSeries["rule"]

    for i = 1, n do
        result[i] = rule(i)
    end

    return _polynomialFromArray(result)
end

local _formalSeriesInverse = function (formalSeries)
    local seriesRule = formalSeries["rule"]
    
    if seriesRule(1) == 0 then
        error("Non-inevrtible formal power series!", 2)
    end

    local rule

    rule = function (n)
        if n == 1 then
            return 1/seriesRule(1)
        else
            local sum = 0
            for i = 2, n do
                sum = sum - seriesRule(i) * rule(n - i + 1)
            end
            return sum/seriesRule(1)
        end
    end

    return _formalSeriesFromRule(rule)
end

local _formalSeriesDerivative = function (formalSeries)
    local seriesRule = formalSeries["rule"]

    local rule = function (n)
        return n * seriesRule(n + 1)
    end

    return _formalSeriesFromRule(rule)
end

local _formalSeriesAntiderivative = function (formalSeries, c)
    local seriesRule = formalSeries["rule"]

    local rule = function (n)
        if n == 1 then
            return c
        else
            return seriesRule(n - 1) / (n - 1)
        end
    end

    return _formalSeriesFromRule(rule)
end

_formalSeries.__add = function (left, right)
    local rule = function (n)
        return left["rule"](n) + right["rule"](n)
    end

    return _formalSeriesFromRule(rule)
end

_formalSeries.__sub = function (left, right)
    local rule = function (n)
        return left["rule"](n) - right["rule"](n)
    end

    return _formalSeriesFromRule(rule)
end

_formalSeries.__mul = function (left, right)
    local rule = function (n)
        local sum = 0

        local leftRule = left["rule"]
        local rightRule = right["rule"]

        for i = 1, n do
            sum = sum + leftRule(i) * rightRule(n - i + 1)
        end

        return sum
    end

    return _formalSeriesFromRule(rule)
end

_formalSeries.__index = function (formalSeries, n)
    return formalSeries["rule"](n)
end

polynomialAlgebra.formalSeries = {}

polynomialAlgebra.formalSeries.new = function (rule)
    return _formalSeriesFromRule(rule)
end

polynomialAlgebra.formalSeries.partialSum = function (formalSeries, n)
    return _polynomialFromFormalSeries(formalSeries, n)
end

polynomialAlgebra.formalSeries.inverse = function (formalSeries)
    return _formalSeriesInverse(formalSeries)
end

polynomialAlgebra.formalSeries.derivative = function (formalSeries)
    return _formalSeriesDerivative(formalSeries)
end

polynomialAlgebra.formalSeries.integral = function (formalSeries, c)
    return _formalSeriesAntiderivative(formalSeries, c)
end

return polynomialAlgebra