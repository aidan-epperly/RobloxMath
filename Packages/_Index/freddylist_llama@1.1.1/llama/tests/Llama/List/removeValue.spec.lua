return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	local Packages = ReplicatedStorage.Packages
	local Llama = require(Packages.Llama)

	local List = Llama.List
	local removeValue = List.removeValue

	it("should validate types", function()
		local _, err = pcall(function()
			removeValue(0)
		end)

		expect(string.find(err, "expected, got")).to.be.ok()
	end)

	it("should return a new table", function()
		local a = {}

		local b = removeValue(a, "foo")

		expect(b).never.to.equal(a)
		expect(b).to.be.a("table")
	end)

	it("should not mutate passed in tables", function()
		local a = { "foo", "bar" }
		local mutations = 0

		setmetatable(a, {
			__newindex = function()
				mutations = mutations + 1
			end,
		})

		removeValue(a, "bar")

		expect(mutations).to.equal(0)
	end)

	it("should remove a single value", function()
		local a = {
			"foo",
			"bar",
			"baz",
			"baz",
		}

		local b = removeValue(a, "baz")

		expect(#b).to.equal(2)
		expect(b[1]).to.equal("foo")
		expect(b[2]).to.equal("bar")
	end)

	it("should work even if value does not exist", function()
		local a = {
			"foo",
			"bar",
		}

		expect(function()
			removeValue(a, "baz")
		end).never.to.throw()
	end)
end