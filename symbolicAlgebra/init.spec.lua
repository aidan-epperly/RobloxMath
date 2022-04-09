local poly = require(script.Parent.symbolicAlgebra).polynomial

return function()
    describe("symbolic algebra", function() 
        it("linear", function() 
            local x = 1
            local linear = poly.new({1 , x})
            expect(linear).to.equal(2) -- 1 + x =
        end)
        it("quadratic", function() 
            
        end)
    end)
end