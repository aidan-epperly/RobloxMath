local poly = require "symbolicAlgebraDev"

local linear = poly.polynomial.new({1,1})
print(linear)

local quadratic = linear * linear
print(quadratic)

local four = poly.polynomial.evaluate(quadratic, {x = 1})
print(four)

local multi = linear * poly.polynomial.replace(linear, "x", "y")
print(multi)

local doubleLinear = linear + linear
print(doubleLinear)