# RobloxMath

A general purpose Roblox math library.

# Documentation

## MatrixAlgebra

TODO

## PolynomialAlgebra

TODO

## SymbolicAlgebra

symbolicAlgebra is a library that adds symbolic polynomials to Lua. What does it mean for something to be symbolic? I am glad you asked. In normal lua, if you create a variable `local x = a` you are creating a location in memory "called" `x`, and then storing the *current* value of `a` within it. Thus, unless `a` is a table, if you change the value of `a`, you will not change the value of `x`. This is not how variables work in mathematics. In mathematics, if I have a variable `x = a`, then `x` ***is*** `a`. If `a` changes, `x` changes and visa versa. Symbolic variables are somewhat different from both of these, but they are much closer to the math version. 

Suppose I write the foilow piece of code

```lua
local poly = require(symbolicAlgebra).polynomial

local lin = poly.new({1,1}) --lin is now the polynomial 1 + x
local quad = lin * lin --quad is now the polynomial 1 + 2x + x^2
```

As mentioned in the comments, `lin` is the polynomial `1 + x` and `quad` is the polynomial `1 + 2x + x^2`. Now, if I were to change `lin`, `quad` would remain unchanged, so the symbolic variable is not quite a mathematical variable, but, we can do interesting things with this. Suppose I were to define a new variable `local liny = poly.setSymbol(lin, "y")`. What would `lin * liny` be then? Well, in algebra, we would say that `(1 + x) * (1 + y) = 1 + x + (1 + x)y`, and using symbolic polynomials, we get this result! Namely

```lua
local poly = require(symbolicAlgebra).polynomial

local lin = poly.new({1,1}) --lin is now the polynomial 1 + x
local quad = lin * lin --quad is now the polynomial 1 + 2x + x^2
local quadish = lin * liny --quadish is the polynomial 1 + x + (1 + x)y
```

Thus, we can actually do real, mathematical algebra using these symbolic polynomials. Currently, only polynomial addition, subtraction, and multplication are implemented (division is tricky because you can't just divide one polynomial by another polynomial in general) so you can't do things like factor, but this will be implemented shortly (perhaps by April 10th, 2022).

The current functionality is as follows:

`+, -, *`

Polynomials can be multiplied, added and subtracted with each other.

`symbolicAlgebra.polynomial.new(array)`:

Creates a new polynomial with symbol `x` and coefficients given by the array. Coefficients can be numbers or polynomials.

`symbolicAlgebra.polynomial.eval(polynomial, rules)`

Evaluates the polynomial at some list of values. `rules` should be of the form `{x = a, y = b, ...}`.

`symbolicAlgebra.polynomial.setSymbol(polynomial, symbol)`

Returns a polynomial with the same coefficients as `polynomial`, but a different symbol determined by the string `symbol`.

`symbolicAlgebra.polynomial.derivative(polynomial)`

Computes the formal derivative of `polynomial`.

`symbolicAlgebra.polynomial.integral(polynomial, c)`

Compute the formal antiderivative of `polynomial` plus the constant `c`.
