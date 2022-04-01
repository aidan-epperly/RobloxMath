local poly = require "polynomialAlgebra"
local symb = require "symbolicAlgebra"

local one = poly.polynomial.new({1})
local quad = poly.polynomial.new({1,0,1})
poly.polynomial.setSymbol(quad, "t")

local rule = function (n)
    return n
end

local linear = poly.formalSeries.new(rule)
local linearInverse = poly.formalSeries.inverse(linear)
local unit = linear * linearInverse

local quadRule = function (n)
    return n^2
end

local quadratic = poly.formalSeries.new(quadRule)
local quadraticInverse = poly.formalSeries.inverse(quadratic)
local quadUnit = quadratic * quadraticInverse

local fact
fact = function (n)
    if (n == 1 or n == 0) then
        return 1
    else
        return n * fact(n - 1)
    end
end

local expRule = function (n)
    return 1/fact(n - 1)
end

local exp = poly.formalSeries.new(expRule)
local expInverse = poly.formalSeries.inverse(exp)
local expPrime = poly.formalSeries.derivative(exp)

print(tostring(one))
print(tostring(quad))
print(tostring(one * quad))
print(tostring(quad * quad))
print(tostring(quad - one))
print(tostring(quad*quad - quad))
print(tostring(poly.polynomial.eval(quad * quad, 2)))
print(tostring(poly.formalSeries.partialSum(linear,5)))
print(tostring(poly.formalSeries.partialSum(linearInverse,5)))
print(tostring(poly.formalSeries.partialSum(unit, 5)))
print(tostring(poly.formalSeries.partialSum(quadratic,5)))
print(tostring(poly.formalSeries.partialSum(quadraticInverse,5)))
print(tostring(poly.formalSeries.partialSum(quadUnit, 5)))
print(tostring(poly.formalSeries.partialSum(exp,5)))
print(tostring(poly.formalSeries.partialSum(expInverse,5)))
print(tostring(poly.formalSeries.partialSum(exp - expPrime, 5)))

local x = symb.polynomial.new({0,1})
local y = symb.polynomial.new({0,1})
y = symb.polynomial.setSymbol(y, "y")

print("Beginning of symbolic section---")

print(x)
print(y)
local z = y * x
print(z)
local two = symb.polynomial.eval(x,2)
print(two)
local twoY = symb.polynomial.eval(z,{x = 2})
print(twoY)