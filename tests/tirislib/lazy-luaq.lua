local Assert = Tirislib.Testing.Assert
local LazyLuaq = Tirislib.LazyLuaq

---------------------------------------------------------------------------------------------------
-- << generators >>

Tirislib.Testing.add_test_case(
    "from iterates over a table",
    "lib.lazy-luaq",
    function()
        local tbl = {a = 1, b = 2, c = 3}
        local result = LazyLuaq.from(tbl):to_table()
        Assert.equals(result, tbl)
    end
)

Tirislib.Testing.add_test_case(
    "from iterates over an array",
    "lib.lazy-luaq",
    function()
        local arr = {10, 20, 30}
        local result = LazyLuaq.from(arr):to_array()
        Assert.equals(result, arr)
    end
)

Tirislib.Testing.add_test_case(
    "from handles an empty table",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({}):to_array()
        Assert.equals(result, {})
    end
)

Tirislib.Testing.add_test_case(
    "range generates a number sequence",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.range(1, 5):to_array()
        Assert.equals(result, {1, 2, 3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "range with step",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.range(0, 10, 3):to_array()
        Assert.equals(result, {0, 3, 6, 9})
    end
)

Tirislib.Testing.add_parameterized_test_case(
    "range(%s, %s, %s) gives %s",
    "lib.lazy-luaq",
    {
        {5, 1, -1, {5, 4, 3, 2, 1}, name = "negative step counts down"},
        {10, 1, -3, {10, 7, 4, 1}, name = "negative step landing on the end value"},
        {10, 2, -3, {10, 7, 4}, name = "negative step not landing on the end value"},
        {3, 3, -1, {3}, name = "negative step, start equals end"},
        {1, 5, -1, {}, name = "negative step pointing away from the end"},
        {5, 1, nil, {}, name = "default step pointing away from the end"},
        {1, 2, 0.5, {1, 1.5, 2}, name = "fractional step"},
    },
    function(start_value, end_value, step, expected)
        Assert.equals(LazyLuaq.range(start_value, end_value, step):to_array(), expected)
    end
)

Tirislib.Testing.add_test_case(
    "repeat_element repeats a value",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.repeat_element("x", 3):to_array()
        Assert.equals(result, {"x", "x", "x"})
    end
)

Tirislib.Testing.add_test_case(
    "repeat_function calls the generator each time",
    "lib.lazy-luaq",
    function()
        local counter = 0
        local result = LazyLuaq.repeat_function(
            function()
                counter = counter + 1
                return counter
            end,
            3
        ):to_array()
        Assert.equals(result, {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "from_iterator works with pairs",
    "lib.lazy-luaq",
    function()
        local tbl = {a = 1, b = 2, c = 3}
        local result = LazyLuaq.from_iterator(pairs(tbl)):to_table()
        Assert.equals(result, tbl)
    end
)

Tirislib.Testing.add_test_case(
    "from_iterator works with ipairs",
    "lib.lazy-luaq",
    function()
        local arr = {10, 20, 30}
        local result = LazyLuaq.from_iterator(ipairs(arr)):to_array()
        Assert.equals(result, arr)
    end
)

Tirislib.Testing.add_test_case(
    "from_iterator supports multiple passes via caching",
    "lib.lazy-luaq",
    function()
        local calls = 0
        local data = {10, 20, 30}
        local function counting_iter(t, i)
            calls = calls + 1
            local next_i = i + 1
            return data[next_i] and next_i or nil, data[next_i]
        end

        local query = LazyLuaq.from_iterator(counting_iter, nil, 0)
        local first  = query:to_array()
        local second = query:to_array()

        Assert.equals(first, {10, 20, 30})
        Assert.equals(second, {10, 20, 30})
        -- iterator was called exactly 4 times (3 values + 1 nil to signal end), never again
        Assert.equals(calls, 4)
    end
)

Tirislib.Testing.add_test_case(
    "from_iterator caching works correctly after partial iteration",
    "lib.lazy-luaq",
    function()
        local calls = 0
        local data = {10, 20, 30, 40, 50}
        local function counting_iter(t, i)
            calls = calls + 1
            local next_i = i + 1
            return data[next_i] and next_i or nil, data[next_i]
        end

        local query = LazyLuaq.from_iterator(counting_iter, nil, 0)
        local partial = query:take(2):to_array()  -- consumes 10, 20 from the real iterator
        local full    = query:to_array()           -- should return all 5 from cache + real iterator

        Assert.equals(partial, {10, 20})
        Assert.equals(full, {10, 20, 30, 40, 50})
        -- 2 from partial + 3 remaining + 1 nil = 6 real calls total
        Assert.equals(calls, 6)
    end
)

Tirislib.Testing.add_test_case(
    "from_keyset yields the keys of a lookup table as values",
    "lib.lazy-luaq",
    function()
        local set = {apple = true, banana = true, cherry = true}
        local result = LazyLuaq.from_keyset(set):to_lookup()
        Assert.equals(result, set)
    end
)

Tirislib.Testing.add_test_case(
    "from_keyset handles an empty table",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from_keyset({}):to_array()
        Assert.equals(result, {})
    end
)

Tirislib.Testing.add_test_case(
    "from_keyset works with where",
    "lib.lazy-luaq",
    function()
        local before = {a = true, b = true}
        local after  = {a = true, b = true, c = true, d = true}
        local result = LazyLuaq.from_keyset(after)
            :where(function(name) return not before[name] end)
            :to_lookup()
        Assert.equals(result, {c = true, d = true})
    end
)

Tirislib.Testing.add_test_case(
    "from_keyset works with select",
    "lib.lazy-luaq",
    function()
        local set = {foo = true, bar = true}
        local result = LazyLuaq.from_keyset(set)
            :select(function(name) return name .. "!" end)
            :to_lookup()
        Assert.equals(result, {["foo!"] = true, ["bar!"] = true})
    end
)

---------------------------------------------------------------------------------------------------
-- << terminal operations >>

Tirislib.Testing.add_test_case(
    "count returns the number of elements",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({5, 10, 15}):count(), 3)
        Assert.equals(LazyLuaq.from({}):count(), 0)
    end
)

Tirislib.Testing.add_test_case(
    "any returns true when elements exist",
    "lib.lazy-luaq",
    function()
        Assert.is_true(LazyLuaq.from({1, 2, 3}):any())
        Assert.is_false(LazyLuaq.from({}):any())
    end
)

Tirislib.Testing.add_test_case(
    "any with condition",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({1, 2, 3, 4})
        Assert.is_true(query:any(function(v) return v > 3 end))
        Assert.is_false(query:any(function(v) return v > 10 end))
    end
)

Tirislib.Testing.add_test_case(
    "all checks every element",
    "lib.lazy-luaq",
    function()
        Assert.is_true(LazyLuaq.from({2, 4, 6}):all(function(v) return v % 2 == 0 end))
        Assert.is_false(LazyLuaq.from({2, 3, 6}):all(function(v) return v % 2 == 0 end))
    end
)

Tirislib.Testing.add_test_case(
    "contains finds elements",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({10, 20, 30})
        Assert.is_true(query:contains(20))
        Assert.is_false(query:contains(25))
    end
)

Tirislib.Testing.add_test_case(
    "first returns the first element",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({5, 10, 15}):first(), 5)
    end
)

Tirislib.Testing.add_test_case(
    "first with condition",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4}):first(function(v) return v > 2 end)
        Assert.equals(result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "last returns the last element",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({5, 10, 15}):last(), 15)
    end
)

Tirislib.Testing.add_test_case(
    "sum computes the sum",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({1, 2, 3, 4}):sum(), 10)
    end
)

Tirislib.Testing.add_test_case(
    "product computes the product",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({2, 3, 4}):product(), 24)
    end
)

Tirislib.Testing.add_test_case(
    "average computes the average",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({2, 4, 6}):average(), 4)
    end
)

Tirislib.Testing.add_test_case(
    "min returns minimum value",
    "lib.lazy-luaq",
    function()
        local value, index = LazyLuaq.from({5, 1, 3}):min()
        Assert.equals(value, 1)
        Assert.equals(index, 2)
    end
)

Tirislib.Testing.add_test_case(
    "max returns maximum value",
    "lib.lazy-luaq",
    function()
        local value, index = LazyLuaq.from({5, 1, 3}):max()
        Assert.equals(value, 5)
        Assert.equals(index, 1)
    end
)

Tirislib.Testing.add_test_case(
    "to_lookup creates a set-like table",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({"a", "b", "c"}):to_lookup()
        Assert.is_true(result["a"])
        Assert.is_true(result["b"])
        Assert.is_true(result["c"])
        Assert.is_nil(result["d"])
    end
)

Tirislib.Testing.add_test_case(
    "to_lookup with custom element value",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({"a", "b"}):to_lookup(42)
        Assert.equals(result["a"], 42)
        Assert.equals(result["b"], 42)
    end
)

Tirislib.Testing.add_test_case(
    "to_dictionary without selectors is equivalent to to_table",
    "lib.lazy-luaq",
    function()
        local tbl = {a = 1, b = 2, c = 3}
        Assert.equals(LazyLuaq.from(tbl):to_dictionary(), tbl)
    end
)

Tirislib.Testing.add_test_case(
    "to_dictionary creates a table with selectors",
    "lib.lazy-luaq",
    function()
        local data = {{id = "x", val = 10}, {id = "y", val = 20}}
        local result = LazyLuaq.from(data):to_dictionary(
            function(v) return v.val end,
            function(v) return v.id end
        )
        Assert.equals(result["x"], 10)
        Assert.equals(result["y"], 20)
    end
)

Tirislib.Testing.add_test_case(
    "to_dictionary value_selector receives the original index, not the computed key",
    "lib.lazy-luaq",
    function()
        -- value_selector uses the original numeric index; index_selector produces a string key.
        -- A bug that passes the computed key to value_selector would put the string key as value instead.
        local result = LazyLuaq.from({10, 20, 30}):to_dictionary(
            function(v, i) return i end,
            function(v, i) return "k" .. i end
        )
        Assert.equals(result["k1"], 1)
        Assert.equals(result["k2"], 2)
        Assert.equals(result["k3"], 3)
    end
)

Tirislib.Testing.add_test_case(
    "order_descending is deferred and supports then_by chaining",
    "lib.lazy-luaq",
    function()
        -- Previously order_descending returned a plain from()-query, so then_by would throw.
        -- Now it returns an ordered query.
        local result = LazyLuaq.from({3, 1, 3, 2})
            :order_descending()
            :then_by(function(v) return v end)
            :to_array()
        Assert.equals(result, {3, 3, 2, 1})
    end
)

Tirislib.Testing.add_test_case(
    "max_by returns the element with the maximum selected value",
    "lib.lazy-luaq",
    function()
        local data = {{name = "a", score = 5}, {name = "b", score = 9}, {name = "c", score = 3}}
        local element, index, value = LazyLuaq.from(data):max_by(function(v) return v.score end)
        Assert.equals(element.name, "b")
        Assert.equals(value, 9)
    end
)

Tirislib.Testing.add_test_case(
    "min_by returns the element with the minimum selected value",
    "lib.lazy-luaq",
    function()
        local data = {{name = "a", score = 5}, {name = "b", score = 9}, {name = "c", score = 3}}
        local element, index, value = LazyLuaq.from(data):min_by(function(v) return v.score end)
        Assert.equals(element.name, "c")
        Assert.equals(value, 3)
    end
)

Tirislib.Testing.add_test_case(
    "maxima returns all maximum elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({3, 5, 2, 5, 1}):maxima():to_array()
        Assert.equals(result, {5, 5})
    end
)

Tirislib.Testing.add_test_case(
    "maxima with selector",
    "lib.lazy-luaq",
    function()
        local data = {{name = "a", score = 5}, {name = "b", score = 3}, {name = "c", score = 5}}
        local result = LazyLuaq.from(data):maxima(function(v) return v.score end):select(function(v) return v.name end):to_array()
        Assert.equals(result, {"a", "c"})
    end
)

Tirislib.Testing.add_test_case(
    "maxima preserves original indices",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({a = 5, b = 3, c = 5}):maxima():to_table()
        Assert.equals(result["a"], 5)
        Assert.equals(result["c"], 5)
        Assert.is_nil(result["b"])
    end
)

Tirislib.Testing.add_test_case(
    "minima returns all minimum elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({3, 1, 2, 1, 5}):minima():to_array()
        Assert.equals(result, {1, 1})
    end
)

Tirislib.Testing.add_test_case(
    "minima preserves original indices",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({a = 3, b = 1, c = 1}):minima():to_table()
        Assert.equals(result["b"], 1)
        Assert.equals(result["c"], 1)
        Assert.is_nil(result["a"])
    end
)

Tirislib.Testing.add_test_case(
    "average with selector",
    "lib.lazy-luaq",
    function()
        local data = {{val = 2}, {val = 4}, {val = 6}}
        Assert.equals(LazyLuaq.from(data):average(function(v) return v.val end), 4)
    end
)

Tirislib.Testing.add_test_case(
    "last with condition",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 5}):last(function(v) return v < 4 end)
        Assert.equals(result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "for_each calls function for every element",
    "lib.lazy-luaq",
    function()
        local sum = 0
        LazyLuaq.from({1, 2, 3}):for_each(function(v) sum = sum + v end)
        Assert.equals(sum, 6)
    end
)

---------------------------------------------------------------------------------------------------
-- << aggregate >>

Tirislib.Testing.add_test_case(
    "aggregate with seed",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):aggregate(
            function(acc, v) return acc + v end,
            0
        )
        Assert.equals(result, 6)
    end
)

Tirislib.Testing.add_test_case(
    "aggregate without seed uses first element and does not double-count",
    "lib.lazy-luaq",
    function()
        -- sum without seed: should be 1+2+3 = 6, not 1+1+2+3 = 7
        local result = LazyLuaq.from({1, 2, 3}):aggregate(
            function(acc, v) return acc + v end
        )
        Assert.equals(result, 6)
    end
)

Tirislib.Testing.add_test_case(
    "aggregate with result_selector",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):aggregate(
            function(acc, v) return acc + v end,
            0,
            function(total) return total * 10 end
        )
        Assert.equals(result, 60)
    end
)

---------------------------------------------------------------------------------------------------
-- << filtering >>

Tirislib.Testing.add_test_case(
    "where filters elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 5, 6}):where(function(v) return v % 2 == 0 end):to_array()
        Assert.equals(result, {2, 4, 6})
    end
)

Tirislib.Testing.add_test_case(
    "where handles filtering out all elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):where(function(v) return v > 10 end):to_array()
        Assert.equals(result, {})
    end
)

Tirislib.Testing.add_test_case(
    "where_key filters by truthy key",
    "lib.lazy-luaq",
    function()
        local data = {
            {name = "a", active = true},
            {name = "b", active = false},
            {name = "c", active = true}
        }
        local result = LazyLuaq.from(data):where_key("active"):select(function(v) return v.name end):to_array()
        Assert.equals(result, {"a", "c"})
    end
)

---------------------------------------------------------------------------------------------------
-- << projection >>

Tirislib.Testing.add_test_case(
    "select projects elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):select(function(v) return v * 2 end):to_array()
        Assert.equals(result, {2, 4, 6})
    end
)

Tirislib.Testing.add_test_case(
    "select_key extracts a key from table elements",
    "lib.lazy-luaq",
    function()
        local data = {{x = 10}, {x = 20}, {x = 30}}
        local result = LazyLuaq.from(data):select_key("x"):to_array()
        Assert.equals(result, {10, 20, 30})
    end
)

Tirislib.Testing.add_test_case(
    "choose filters and projects in one step",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4}):choose(
            function(v)
                if v % 2 == 0 then
                    return true, v * 10
                end
                return false
            end
        ):to_array()
        Assert.equals(result, {20, 40})
    end
)

Tirislib.Testing.add_test_case(
    "select_many flattens projected collections",
    "lib.lazy-luaq",
    function()
        local data = {{items = {1, 2}}, {items = {3, 4}}}
        local result = LazyLuaq.from(data):select_many(function(v) return v.items end):to_array()
        Assert.equals(result, {1, 2, 3, 4})
    end
)

Tirislib.Testing.add_test_case(
    "select_many handles mixed plain-table and LazyLuaqQuery results",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({{1, 2}, {3, 4}, {5, 6}}):select_many(
            function(v, i)
                return i % 2 == 0 and LazyLuaq.from(v) or v
            end
        ):to_array()
        Assert.equals(result, {1, 2, 3, 4, 5, 6})
    end
)

Tirislib.Testing.add_test_case(
    "choose_key filters and projects by key",
    "lib.lazy-luaq",
    function()
        local data = {
            {name = "a", tag = "x"},
            {name = "b"},
            {name = "c", tag = "z"}
        }
        local result = LazyLuaq.from(data):choose_key("tag"):to_array()
        Assert.equals(result, {"x", "z"})
    end
)

---------------------------------------------------------------------------------------------------
-- << take / skip >>

Tirislib.Testing.add_test_case(
    "take returns the first n elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 5}):take(3):to_array()
        Assert.equals(result, {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "skip skips the first n elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 5}):skip(2):to_array()
        Assert.equals(result, {3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "take_while takes until condition fails",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 1}):take_while(function(v) return v < 4 end):to_array()
        Assert.equals(result, {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "take_while stops at the first failing element even if later ones would pass",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 5, 1, 2}):take_while(function(v) return v < 3 end):to_array()
        Assert.equals(result, {1, 2})
    end
)

Tirislib.Testing.add_test_case(
    "skip_while skips until condition fails",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 1}):skip_while(function(v) return v < 3 end):to_array()
        Assert.equals(result, {3, 4, 1})
    end
)

---------------------------------------------------------------------------------------------------
-- << combining >>

Tirislib.Testing.add_test_case(
    "concat combines two sequences",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2}):concat({3, 4}):to_array()
        Assert.equals(result, {1, 2, 3, 4})
    end
)

Tirislib.Testing.add_test_case(
    "zip combines element-wise",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):zip(
            {10, 20, 30},
            function(a, b) return a + b end
        ):to_array()
        Assert.equals(result, {11, 22, 33})
    end
)

Tirislib.Testing.add_test_case(
    "zip stops at shorter sequence",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2}):zip({10, 20, 30}):to_array()
        Assert.equals(#result, 2)
    end
)

Tirislib.Testing.add_test_case(
    "prepend adds elements before the sequence",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({3, 4}):prepend({1, 2}):to_array()
        Assert.equals(result, {1, 2, 3, 4})
    end
)

Tirislib.Testing.add_test_case(
    "chunk splits into groups of given size",
    "lib.lazy-luaq",
    function()
        local chunks = LazyLuaq.from({1, 2, 3, 4, 5}):chunk(2)
        local result = {}
        for _, chunk in chunks:iterate() do
            result[#result + 1] = chunk:to_array()
        end
        Assert.equals(result[1], {1, 2})
        Assert.equals(result[2], {3, 4})
        Assert.equals(result[3], {5})
    end
)

Tirislib.Testing.add_test_case(
    "interleave alternates elements from multiple sequences",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 4}):interleave({2, 5}, {3, 6}):to_array()
        Assert.equals(result, {1, 2, 3, 4, 5, 6})
    end
)

Tirislib.Testing.add_test_case(
    "interleave handles sequences of different lengths",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 4, 7}):interleave({2, 5}, {3}):to_array()
        Assert.equals(result, {1, 2, 3, 4, 5, 7})
    end
)

-- Regression: the end check used '#' on the sparse table of finished sequences, which can count
-- {[2] = true} as 2 and stopped as soon as the second of two sequences had ended.
Tirislib.Testing.add_parameterized_test_case(
    "interleave continues with the remaining sequences when one ends: %s",
    "lib.lazy-luaq",
    {
        {{1, 2, 3}, {{"a"}}, {1, "a", 2, 3}, name = "second of two ends first"},
        {{1}, {{"a", "b", "c"}}, {1, "a", "b", "c"}, name = "first of two ends first"},
        {{}, {{"a", "b"}}, {"a", "b"}, name = "first is empty"},
        {{1, 2, 3}, {{"a", "b"}, {"x"}}, {1, "a", "x", 2, "b", 3}, name = "three sequences"},
        {{1, 2, 3}, {{"a"}, {"x", "y"}}, {1, "a", "x", 2, "y", 3}, name = "middle one ends first"},
    },
    function(first, others, expected)
        local result = LazyLuaq.from(first):interleave(table.unpack(others)):to_array()
        Assert.equals(result, expected)
    end
)

Tirislib.Testing.add_test_case(
    "interleave gives the same result when iterated again",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({1, 2, 3}):interleave({"a"})
        Assert.equals(query:to_array(), {1, "a", 2, 3})
        Assert.equals(query:to_array(), {1, "a", 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "pairwise applies function to consecutive pairs",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 3, 6, 10}):pairwise(
            function(prev, curr) return curr - prev end
        ):to_array()
        Assert.equals(result, {2, 3, 4})
    end
)

Tirislib.Testing.add_test_case(
    "pairwise without selector returns pair tables",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):pairwise():to_array()
        Assert.equals(result[1], {1, 2})
        Assert.equals(result[2], {2, 3})
    end
)

---------------------------------------------------------------------------------------------------
-- << set operations >>

Tirislib.Testing.add_test_case(
    "distinct removes duplicates",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 2, 3, 1, 3}):distinct():to_array()
        Assert.equals(result, {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "duplicates returns only repeated elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 2, 3, 1, 3}):duplicates():to_array()
        Assert.equals(result, {2, 1, 3})
    end
)

Tirislib.Testing.add_test_case(
    "except produces set difference",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4}):except({2, 4}):to_array()
        Assert.equals(result, {1, 3})
    end
)

Tirislib.Testing.add_test_case(
    "intersect produces set intersection",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4}):intersect({2, 4, 6}):to_array()
        Assert.equals(result, {2, 4})
    end
)

Tirislib.Testing.add_test_case(
    "union produces set union",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):union({3, 4, 5}):to_array()
        Assert.equals(result, {1, 2, 3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "distinct_by removes duplicates by selector",
    "lib.lazy-luaq",
    function()
        local data = {{id = 1, v = "a"}, {id = 2, v = "b"}, {id = 1, v = "c"}}
        local result = LazyLuaq.from(data):distinct_by(function(v) return v.id end):select(function(v) return v.v end):to_array()
        Assert.equals(result, {"a", "b"})
    end
)

Tirislib.Testing.add_test_case(
    "duplicates_by returns duplicates by selector",
    "lib.lazy-luaq",
    function()
        local data = {{id = 1, v = "a"}, {id = 2, v = "b"}, {id = 1, v = "c"}}
        local result = LazyLuaq.from(data):duplicates_by(function(v) return v.id end):select(function(v) return v.v end):to_array()
        Assert.equals(result, {"c"})
    end
)

Tirislib.Testing.add_test_case(
    "except_by produces set difference by selector",
    "lib.lazy-luaq",
    function()
        local left = {{id = 1}, {id = 2}, {id = 3}}
        local right = {{id = 2}, {id = 4}}
        local result = LazyLuaq.from(left):except_by(right, function(v) return v.id end):select(function(v) return v.id end):to_array()
        Assert.equals(result, {1, 3})
    end
)

Tirislib.Testing.add_test_case(
    "intersect_by produces set intersection by selector",
    "lib.lazy-luaq",
    function()
        local left = {{id = 1}, {id = 2}, {id = 3}}
        local right = {{id = 2}, {id = 3}, {id = 5}}
        local result = LazyLuaq.from(left):intersect_by(right, function(v) return v.id end):select(function(v) return v.id end):to_array()
        Assert.equals(result, {2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "union_by produces set union by selector",
    "lib.lazy-luaq",
    function()
        local left = {{id = 1}, {id = 2}}
        local right = {{id = 2}, {id = 3}}
        local result = LazyLuaq.from(left):union_by(right, function(v) return v.id end):select(function(v) return v.id end):to_array()
        Assert.equals(result, {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "symmetric_difference produces elements in either but not both",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):symmetric_difference({2, 3, 4}):to_array()
        Assert.equals(result, {1, 4})
    end
)

Tirislib.Testing.add_test_case(
    "symmetric_difference_by works with selector",
    "lib.lazy-luaq",
    function()
        local left = {{id = 1}, {id = 2}, {id = 3}}
        local right = {{id = 2}, {id = 3}, {id = 4}}
        local result = LazyLuaq.from(left):symmetric_difference_by(right, function(v) return v.id end):select(function(v) return v.id end):to_array()
        Assert.equals(result, {1, 4})
    end
)

---------------------------------------------------------------------------------------------------
-- << ordering >>

Tirislib.Testing.add_test_case(
    "order sorts ascending",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({3, 1, 4, 1, 5}):order():to_array()
        Assert.equals(result, {1, 1, 3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "order_descending sorts descending",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({3, 1, 4, 1, 5}):order_descending():to_array()
        Assert.equals(result, {5, 4, 3, 1, 1})
    end
)

Tirislib.Testing.add_test_case(
    "order_by sorts by selector and handles duplicate values",
    "lib.lazy-luaq",
    function()
        local data = {{name = "c", priority = 2}, {name = "a", priority = 1}, {name = "b", priority = 2}}
        local result = LazyLuaq.from(data):order_by(function(v) return v.priority end):select(function(v) return v.name end):to_array()
        -- priority 1 first, then the two priority-2 elements
        Assert.equals(result[1], "a")
        Assert.equals(#result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "order_by_descending sorts by selector descending",
    "lib.lazy-luaq",
    function()
        local data = {{name = "a", priority = 1}, {name = "b", priority = 3}, {name = "c", priority = 2}}
        local result = LazyLuaq.from(data):order_by_descending(function(v) return v.priority end):select(function(v) return v.name end):to_array()
        Assert.equals(result[1], "b")
        Assert.equals(result[2], "c")
        Assert.equals(result[3], "a")
    end
)

Tirislib.Testing.add_test_case(
    "order with custom comparator",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({3, 1, 4, 1, 5}):order(function(a, b) return a > b end):to_array()
        Assert.equals(result, {5, 4, 3, 1, 1})
    end
)

Tirislib.Testing.add_test_case(
    "order_by with custom comparator",
    "lib.lazy-luaq",
    function()
        local data = {{name = "a", priority = 1}, {name = "b", priority = 3}, {name = "c", priority = 2}}
        local result = LazyLuaq.from(data):order_by(
            function(v) return v.priority end,
            function(a, b) return a > b end
        ):select(function(v) return v.name end):to_array()
        Assert.equals(result, {"b", "c", "a"})
    end
)

Tirislib.Testing.add_test_case(
    "then_by adds secondary sort level",
    "lib.lazy-luaq",
    function()
        local data = {
            {name = "banana", category = "fruit"},
            {name = "apple", category = "fruit"},
            {name = "carrot", category = "vegetable"},
            {name = "broccoli", category = "vegetable"}
        }
        local result = LazyLuaq.from(data)
            :order_by(function(v) return v.category end)
            :then_by(function(v) return v.name end)
            :select(function(v) return v.name end)
            :to_array()
        Assert.equals(result, {"apple", "banana", "broccoli", "carrot"})
    end
)

Tirislib.Testing.add_test_case(
    "then_by_descending adds secondary descending sort level",
    "lib.lazy-luaq",
    function()
        local data = {
            {name = "banana", category = "fruit"},
            {name = "apple", category = "fruit"},
            {name = "carrot", category = "vegetable"},
            {name = "broccoli", category = "vegetable"}
        }
        local result = LazyLuaq.from(data)
            :order_by(function(v) return v.category end)
            :then_by_descending(function(v) return v.name end)
            :select(function(v) return v.name end)
            :to_array()
        Assert.equals(result, {"banana", "apple", "carrot", "broccoli"})
    end
)

Tirislib.Testing.add_test_case(
    "then_by chains multiple levels",
    "lib.lazy-luaq",
    function()
        local data = {
            {a = 2, b = 1, c = "z"},
            {a = 1, b = 2, c = "y"},
            {a = 1, b = 1, c = "x"},
            {a = 2, b = 1, c = "w"},
            {a = 1, b = 1, c = "v"}
        }
        local result = LazyLuaq.from(data)
            :order_by(function(v) return v.a end)
            :then_by(function(v) return v.b end)
            :then_by(function(v) return v.c end)
            :select(function(v) return v.c end)
            :to_array()
        Assert.equals(result, {"v", "x", "y", "w", "z"})
    end
)

Tirislib.Testing.add_test_case(
    "then_by levels apply in the order they were added",
    "lib.lazy-luaq",
    function()
        -- b and c disagree on every pair with equal a, so the result shows which level decides
        local data = {
            {a = 1, b = 2, c = "a"},
            {a = 1, b = 1, c = "z"},
            {a = 1, b = 1, c = "m"},
            {a = 0, b = 9, c = "q"}
        }
        local function names(query)
            return query:select(function(v) return v.c end):to_array()
        end
        local by_a = LazyLuaq.from(data):order_by(function(v) return v.a end)

        Assert.equals(names(by_a:then_by(function(v) return v.b end):then_by(function(v) return v.c end)),
            {"q", "m", "z", "a"})
        Assert.equals(names(by_a:then_by(function(v) return v.b end):then_by_descending(function(v) return v.c end)),
            {"q", "z", "m", "a"})
        Assert.equals(names(by_a:then_by_descending(function(v) return v.b end):then_by(function(v) return v.c end)),
            {"q", "a", "m", "z"})
    end
)

Tirislib.Testing.add_test_case(
    "order_by_descending with then_by mixes directions",
    "lib.lazy-luaq",
    function()
        local data = {
            {name = "a", priority = 1},
            {name = "c", priority = 2},
            {name = "b", priority = 2},
            {name = "d", priority = 1}
        }
        local result = LazyLuaq.from(data)
            :order_by_descending(function(v) return v.priority end)
            :then_by(function(v) return v.name end)
            :select(function(v) return v.name end)
            :to_array()
        Assert.equals(result, {"b", "c", "a", "d"})
    end
)

Tirislib.Testing.add_test_case(
    "then_by errors when called without order_by",
    "lib.lazy-luaq",
    function()
        local ok = pcall(function()
            LazyLuaq.from({1, 2, 3}):then_by(function(v) return v end)
        end)
        Assert.equals(ok, false)
    end
)

-- partial_sort should be equivalent to order():take(n) - the n smallest elements in ascending order.
-- partial_sort_descending should be equivalent to order_descending():take(n) - the n largest in descending order.
-- NOTE: the implementations are currently swapped - partial_sort returns top-n descending and
-- partial_sort_descending returns bottom-n ascending. These four tests will fail until that is fixed.

Tirislib.Testing.add_test_case(
    "partial_sort returns the n smallest elements in ascending order",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({5, 3, 8, 1, 9, 2}):partial_sort(3):to_array()
        Assert.equals(result, {1, 2, 3}) -- currently returns {9, 8, 5}
    end
)

Tirislib.Testing.add_test_case(
    "partial_sort_descending returns the n largest elements in descending order",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({5, 3, 8, 1, 9, 2}):partial_sort_descending(3):to_array()
        Assert.equals(result, {9, 8, 5}) -- currently returns {1, 2, 3}
    end
)

Tirislib.Testing.add_test_case(
    "partial_sort_by returns the n smallest elements by selector in ascending order",
    "lib.lazy-luaq",
    function()
        local data = {{name = "a", score = 5}, {name = "b", score = 3}, {name = "c", score = 8}, {name = "d", score = 1}}
        local result = LazyLuaq.from(data):partial_sort_by(2, function(v) return v.score end):select(function(v) return v.name end):to_array()
        Assert.equals(result, {"d", "b"}) -- currently returns {"c", "a"}
    end
)

Tirislib.Testing.add_test_case(
    "partial_sort_by_descending returns the n largest elements by selector in descending order",
    "lib.lazy-luaq",
    function()
        local data = {{name = "a", score = 5}, {name = "b", score = 3}, {name = "c", score = 8}, {name = "d", score = 1}}
        local result = LazyLuaq.from(data):partial_sort_by_descending(2, function(v) return v.score end):select(function(v) return v.name end):to_array()
        Assert.equals(result, {"c", "a"}) -- currently returns {"d", "b"}
    end
)

Tirislib.Testing.add_test_case(
    "partial_sort variants return the whole sequence sorted when count exceeds its length",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({3, 1, 2})
        local negate = function(v) return -v end
        Assert.equals(query:partial_sort(5):to_array(), {1, 2, 3})
        Assert.equals(query:partial_sort_descending(5):to_array(), {3, 2, 1})
        Assert.equals(query:partial_sort_by(5, negate):to_array(), {3, 2, 1})
        Assert.equals(query:partial_sort_by_descending(5, negate):to_array(), {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "group_by groups elements by selector",
    "lib.lazy-luaq",
    function()
        local data = {{type = "a", val = 1}, {type = "b", val = 2}, {type = "a", val = 3}}
        local groups = LazyLuaq.from(data):group_by(function(v) return v.type end):to_table()
        local group_a = groups["a"]:select(function(v) return v.val end):to_array()
        local group_b = groups["b"]:select(function(v) return v.val end):to_array()
        Assert.equals(group_a, {1, 3})
        Assert.equals(group_b, {2})
    end
)

Tirislib.Testing.add_test_case(
    "shuffle returns all elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 5}):shuffle()
        Assert.equals(result:count(), 5)
        Assert.equals(result:order():to_array(), {1, 2, 3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "shuffle can move every element to every position",
    "lib.lazy-luaq",
    function()
        -- 400 shuffles of 4 elements: a missing (position, value) pair has a chance of about 10^-48
        local seen = {}
        for _ = 1, 400 do
            for position, value in pairs(LazyLuaq.from({1, 2, 3, 4}):shuffle():to_array()) do
                seen[position * 10 + value] = true
            end
        end
        for position = 1, 4 do
            for value = 1, 4 do
                Assert.is_true(seen[position * 10 + value] == true, "never saw value " .. value .. " at " .. position)
            end
        end
    end
)

Tirislib.Testing.add_test_case(
    "reverse reverses the sequence",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4}):reverse():to_array()
        Assert.equals(result, {4, 3, 2, 1})
    end
)

Tirislib.Testing.add_test_case(
    "normalize makes elements sum to 1",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({2, 3, 5}):normalize():to_array()
        Assert.equals(result, {0.2, 0.3, 0.5})
    end
)

Tirislib.Testing.add_test_case(
    "normalize scales up elements whose sum is below 1",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({0.1, 0.3}):normalize():to_array()
        Assert.is_number_close(result[1], 0.25, 1e-12)
        Assert.is_number_close(result[2], 0.75, 1e-12)
    end
)

Tirislib.Testing.add_test_case(
    "normalize returns elements unchanged when sum is zero",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({0, 0, 0}):normalize():to_array()
        Assert.equals(result, {0, 0, 0})
    end
)

Tirislib.Testing.add_test_case(
    "cache_execution preserves index-value pairs and allows re-iteration",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({a = 1, b = 2}):cache_execution()
        local first = query:to_table()
        local second = query:to_table()
        Assert.equals(first, {a = 1, b = 2})
        Assert.equals(second, {a = 1, b = 2})
    end
)

Tirislib.Testing.add_test_case(
    "__tostring returns a string representation",
    "lib.lazy-luaq",
    function()
        local str = tostring(LazyLuaq.from({1, 2, 3}))
        Assert.not_nil(str)
        Assert.is_true(Tirislib.String.begins_with(str, "LazyLuaqQuery"))
    end
)

---------------------------------------------------------------------------------------------------
-- << copy >>

Tirislib.Testing.add_test_case(
    "copy creates an independent query",
    "lib.lazy-luaq",
    function()
        local original = LazyLuaq.from({1, 2, 3}):where(function(v) return v > 1 end)
        local copied = original:copy()

        -- consuming the copy should not affect the original
        local copy_result = copied:to_array()
        local original_result = original:to_array()

        Assert.equals(copy_result, {2, 3})
        Assert.equals(original_result, {2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "copy works with take",
    "lib.lazy-luaq",
    function()
        local original = LazyLuaq.from({1, 2, 3, 4, 5}):take(3)
        local copied = original:copy()

        Assert.equals(copied:to_array(), {1, 2, 3})
        Assert.equals(original:to_array(), {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "copy works with concat",
    "lib.lazy-luaq",
    function()
        local original = LazyLuaq.from({1, 2}):concat({3, 4})
        local copied = original:copy()

        Assert.equals(copied:to_array(), {1, 2, 3, 4})
        Assert.equals(original:to_array(), {1, 2, 3, 4})
    end
)

Tirislib.Testing.add_test_case(
    "copy works with zip",
    "lib.lazy-luaq",
    function()
        local original = LazyLuaq.from({1, 2, 3}):zip({10, 20, 30}, function(a, b) return a + b end)
        local copied = original:copy()

        Assert.equals(copied:to_array(), {11, 22, 33})
        Assert.equals(original:to_array(), {11, 22, 33})
    end
)

Tirislib.Testing.add_test_case(
    "copy works with pairwise",
    "lib.lazy-luaq",
    function()
        local original = LazyLuaq.from({1, 3, 6}):pairwise(function(a, b) return b - a end)
        local copied = original:copy()

        Assert.equals(copied:to_array(), {2, 3})
        Assert.equals(original:to_array(), {2, 3})
    end
)

---------------------------------------------------------------------------------------------------
-- << chaining >>

Tirislib.Testing.add_test_case(
    "chaining where, select, and take",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.range(1, 100)
            :where(function(v) return v % 3 == 0 end)
            :select(function(v) return v * v end)
            :take(4)
            :to_array()
        Assert.equals(result, {9, 36, 81, 144})
    end
)

Tirislib.Testing.add_test_case(
    "resetting allows re-iteration",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({1, 2, 3})
        Assert.equals(query:sum(), 6)
        Assert.equals(query:sum(), 6)
    end
)

---------------------------------------------------------------------------------------------------
-- << tap >>

Tirislib.Testing.add_test_case(
    "tap calls side-effect without modifying the sequence",
    "lib.lazy-luaq",
    function()
        local seen = {}
        local result = LazyLuaq.from({1, 2, 3}):tap(function(v) seen[#seen + 1] = v end):to_array()
        Assert.equals(result, {1, 2, 3})
        Assert.equals(seen, {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "tap receives index",
    "lib.lazy-luaq",
    function()
        local collected = {}
        LazyLuaq.from({a = 10, b = 20}):tap(function(v, i) collected[i] = v end):to_table()
        Assert.equals(collected, {a = 10, b = 20})
    end
)

---------------------------------------------------------------------------------------------------
-- << count_by >>

Tirislib.Testing.add_test_case(
    "count_by counts occurrences by selector",
    "lib.lazy-luaq",
    function()
        local data = {"apple", "banana", "apple", "cherry", "banana", "apple"}
        local result = LazyLuaq.from(data):count_by(function(v) return v end)
        Assert.equals(result["apple"], 3)
        Assert.equals(result["banana"], 2)
        Assert.equals(result["cherry"], 1)
    end
)

Tirislib.Testing.add_test_case(
    "count_by with selector on table elements",
    "lib.lazy-luaq",
    function()
        local data = {{type = "a"}, {type = "b"}, {type = "a"}}
        local result = LazyLuaq.from(data):count_by(function(v) return v.type end)
        Assert.equals(result["a"], 2)
        Assert.equals(result["b"], 1)
    end
)

---------------------------------------------------------------------------------------------------
-- << element_at >>

Tirislib.Testing.add_test_case(
    "element_at returns the nth element",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({10, 20, 30, 40})
        Assert.equals(query:element_at(1), 10)
        Assert.equals(query:element_at(3), 30)
        Assert.equals(query:element_at(4), 40)
    end
)

Tirislib.Testing.add_test_case(
    "element_at returns nil when position is beyond the sequence",
    "lib.lazy-luaq",
    function()
        Assert.is_nil(LazyLuaq.from({1, 2}):element_at(5))
    end
)

---------------------------------------------------------------------------------------------------
-- << single >>

Tirislib.Testing.add_test_case(
    "single returns the only element",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({42}):single(), 42)
    end
)

Tirislib.Testing.add_test_case(
    "single errors on empty sequence",
    "lib.lazy-luaq",
    function()
        Assert.throws(function() LazyLuaq.from({}):single() end)
    end
)

Tirislib.Testing.add_test_case(
    "single errors when more than one element",
    "lib.lazy-luaq",
    function()
        Assert.throws(function() LazyLuaq.from({1, 2}):single() end)
    end
)

Tirislib.Testing.add_test_case(
    "single with condition returns the matching element",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({1, 2, 3}):single(function(v) return v == 2 end), 2)
    end
)

Tirislib.Testing.add_test_case(
    "single with condition errors when multiple elements match",
    "lib.lazy-luaq",
    function()
        Assert.throws(function()
            LazyLuaq.from({2, 2, 3}):single(function(v) return v == 2 end)
        end)
    end
)

Tirislib.Testing.add_test_case(
    "single with condition errors when no elements match",
    "lib.lazy-luaq",
    function()
        Assert.throws(function()
            LazyLuaq.from({1, 3, 5}):single(function(v) return v == 2 end)
        end)
    end
)

---------------------------------------------------------------------------------------------------
-- << select_many with LazyLuaqQuery >>

Tirislib.Testing.add_test_case(
    "select_many flattens LazyLuaqQuery results from selector",
    "lib.lazy-luaq",
    function()
        local data = {{1, 2}, {3, 4}}
        local result = LazyLuaq.from(data)
            :select_many(function(v) return LazyLuaq.from(v) end)
            :to_array()
        Assert.equals(result, {1, 2, 3, 4})
    end
)

---------------------------------------------------------------------------------------------------
-- << window >>

Tirislib.Testing.add_test_case(
    "window returns sliding windows of given size",
    "lib.lazy-luaq",
    function()
        local result = {}
        for _, w in LazyLuaq.from({1, 2, 3, 4, 5}):window(3):iterate() do
            result[#result + 1] = w:to_array()
        end
        Assert.equals(#result, 3)
        Assert.equals(result[1], {1, 2, 3})
        Assert.equals(result[2], {2, 3, 4})
        Assert.equals(result[3], {3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "window with size equal to sequence length returns one window",
    "lib.lazy-luaq",
    function()
        local result = {}
        for _, w in LazyLuaq.from({1, 2, 3}):window(3):iterate() do
            result[#result + 1] = w:to_array()
        end
        Assert.equals(#result, 1)
        Assert.equals(result[1], {1, 2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "window with size larger than sequence returns empty",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({1, 2}):window(5):count(), 0)
    end
)

Tirislib.Testing.add_test_case(
    "window with size 1 yields each element as a single-element window",
    "lib.lazy-luaq",
    function()
        local result = {}
        for _, w in LazyLuaq.from({10, 20, 30}):window(1):iterate() do
            result[#result + 1] = w:first()
        end
        Assert.equals(result, {10, 20, 30})
    end
)

Tirislib.Testing.add_test_case(
    "window resets correctly for re-iteration",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({1, 2, 3}):window(2)
        local first_pass = {}
        for _, w in query:iterate() do first_pass[#first_pass + 1] = w:to_array() end
        local second_pass = {}
        for _, w in query:iterate() do second_pass[#second_pass + 1] = w:to_array() end
        Assert.equals(first_pass, second_pass)
    end
)

---------------------------------------------------------------------------------------------------
-- << scan >>

Tirislib.Testing.add_test_case(
    "scan produces running sum without seed",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.range(1, 5):scan(function(acc, v) return acc + v end):to_array()
        Assert.equals(result, {1, 3, 6, 10, 15})
    end
)

Tirislib.Testing.add_test_case(
    "scan with seed applies aggregator from the first element",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.range(1, 4):scan(function(acc, v) return acc + v end, 0):to_array()
        Assert.equals(result, {1, 3, 6, 10})
    end
)

Tirislib.Testing.add_test_case(
    "scan preserves original indices",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):scan(function(acc, v) return acc + v end, 0):to_table()
        Assert.equals(result[1], 1)
        Assert.equals(result[2], 3)
        Assert.equals(result[3], 6)
    end
)

Tirislib.Testing.add_test_case(
    "scan on empty sequence produces empty sequence",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({}):scan(function(acc, v) return acc + v end):to_array(), {})
    end
)

Tirislib.Testing.add_test_case(
    "scan on single-element sequence without seed emits the element as-is",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({42}):scan(function(acc, v) return acc + v end):to_array(), {42})
    end
)

Tirislib.Testing.add_test_case(
    "scan on single-element sequence with seed applies aggregator once",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({10}):scan(function(acc, v) return acc + v end, 5):to_array(), {15})
    end
)

Tirislib.Testing.add_test_case(
    "scan resets correctly for re-iteration",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.range(1, 3):scan(function(acc, v) return acc + v end)
        Assert.equals(query:to_array(), {1, 3, 6})
        Assert.equals(query:to_array(), {1, 3, 6})
    end
)

---------------------------------------------------------------------------------------------------
-- << normalize index preservation >>

Tirislib.Testing.add_test_case(
    "normalize preserves original indices",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({a = 2, b = 8}):normalize():to_table()
        Assert.equals(result["a"], 0.2)
        Assert.equals(result["b"], 0.8)
    end
)

---------------------------------------------------------------------------------------------------
-- << for_each index >>

Tirislib.Testing.add_test_case(
    "for_each passes index to callback",
    "lib.lazy-luaq",
    function()
        local collected = {}
        LazyLuaq.from({a = 1, b = 2}):for_each(function(v, i) collected[i] = v end)
        Assert.equals(collected, {a = 1, b = 2})
    end
)

---------------------------------------------------------------------------------------------------
-- << index passing >>

Tirislib.Testing.add_test_case(
    "any condition receives index",
    "lib.lazy-luaq",
    function()
        local tbl = {a = 1, b = 2, c = 3}
        Assert.is_true(LazyLuaq.from(tbl):any(function(v, i) return i == "b" end))
        Assert.is_false(LazyLuaq.from(tbl):any(function(v, i) return i == "z" end))
    end
)

Tirislib.Testing.add_test_case(
    "distinct_by selector receives index",
    "lib.lazy-luaq",
    function()
        -- All values are identical; only the index distinguishes elements.
        -- If the selector only received the value, all keys would collapse to the same thing
        -- and only one element would survive.
        local result = LazyLuaq.from({a = 5, b = 5, c = 5}):distinct_by(
            function(v, i) return i end
        ):count()
        Assert.equals(result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "duplicates_by selector receives index",
    "lib.lazy-luaq",
    function()
        -- All values are identical but all indices are unique, so there are no duplicates.
        local result = LazyLuaq.from({a = 5, b = 5, c = 5}):duplicates_by(
            function(v, i) return i end
        ):count()
        Assert.equals(result, 0)
    end
)

Tirislib.Testing.add_test_case(
    "except_by selector receives index on content side",
    "lib.lazy-luaq",
    function()
        local left = {x = 0, y = 0, z = 0}
        local right = LazyLuaq.from({x = 0, y = 0})
        local result = LazyLuaq.from(left):except_by(right, function(v, i) return i end):to_table()
        Assert.is_nil(result["x"])
        Assert.is_nil(result["y"])
        Assert.equals(result["z"], 0)
    end
)

Tirislib.Testing.add_test_case(
    "except_by selector receives index for plain-table right side",
    "lib.lazy-luaq",
    function()
        -- right is a plain table; selector keys by position, so indices 1-3 are excluded from left
        local left = {"a", "b", "c", "d", "e"}
        local right = {true, true, true}
        local result = LazyLuaq.from(left):except_by(right, function(v, i) return i end):to_array()
        Assert.equals(result, {"d", "e"})
    end
)

Tirislib.Testing.add_test_case(
    "intersect_by selector receives index on content side",
    "lib.lazy-luaq",
    function()
        local left = {x = 10, y = 20, z = 30}
        local right = LazyLuaq.from({x = 10, y = 20})
        local result = LazyLuaq.from(left):intersect_by(right, function(v, i) return i end):to_table()
        Assert.equals(result["x"], 10)
        Assert.equals(result["y"], 20)
        Assert.is_nil(result["z"])
    end
)

Tirislib.Testing.add_test_case(
    "intersect_by selector receives index for plain-table right side",
    "lib.lazy-luaq",
    function()
        -- right is a plain table with 3 entries; selector keys by position, so only indices 1-3 are kept
        local left = {"a", "b", "c", "d", "e"}
        local right = {true, true, true}
        local result = LazyLuaq.from(left):intersect_by(right, function(v, i) return i end):to_array()
        Assert.equals(result, {"a", "b", "c"})
    end
)

Tirislib.Testing.add_test_case(
    "order_by selector receives original index",
    "lib.lazy-luaq",
    function()
        -- Sorting by string key (index): a < b < c alphabetically.
        -- a=3, b=2, c=1 → values in key-sorted order: {3, 2, 1}.
        -- Sorting by value alone would give {1, 2, 3} instead.
        local data = {c = 1, a = 3, b = 2}
        local result = LazyLuaq.from(data):order_by(function(v, i) return i end):to_array()
        Assert.equals(result, {3, 2, 1})
    end
)

---------------------------------------------------------------------------------------------------
-- << reverse (rewrite) >>

Tirislib.Testing.add_test_case(
    "reverse preserves original indices",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({a = 1, b = 2, c = 3}):reverse():to_table()
        Assert.equals(result["a"], 1)
        Assert.equals(result["b"], 2)
        Assert.equals(result["c"], 3)
    end
)

Tirislib.Testing.add_test_case(
    "reverse copy produces an independent query",
    "lib.lazy-luaq",
    function()
        local original = LazyLuaq.from({1, 2, 3, 4}):reverse()
        local copied = original:copy()
        Assert.equals(copied:to_array(), {4, 3, 2, 1})
        Assert.equals(original:to_array(), {4, 3, 2, 1})
    end
)

Tirislib.Testing.add_test_case(
    "reverse re-iterates correctly",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({1, 2, 3}):reverse()
        Assert.equals(query:to_array(), {3, 2, 1})
        Assert.equals(query:to_array(), {3, 2, 1})
    end
)

---------------------------------------------------------------------------------------------------
-- << find >>

Tirislib.Testing.add_test_case(
    "find returns index and value of first matching element",
    "lib.lazy-luaq",
    function()
        local index, value = LazyLuaq.from({a = 1, b = 2, c = 3}):find(function(v) return v == 2 end)
        Assert.equals(index, "b")
        Assert.equals(value, 2)
    end
)

Tirislib.Testing.add_test_case(
    "find returns nil when no element matches",
    "lib.lazy-luaq",
    function()
        local index, value = LazyLuaq.from({1, 2, 3}):find(function(v) return v > 10 end)
        Assert.is_nil(index)
        Assert.is_nil(value)
    end
)

Tirislib.Testing.add_test_case(
    "find condition receives index",
    "lib.lazy-luaq",
    function()
        local index, value = LazyLuaq.from({a = 10, b = 20}):find(function(v, i) return i == "a" end)
        Assert.equals(index, "a")
        Assert.equals(value, 10)
    end
)

---------------------------------------------------------------------------------------------------
-- << first_or_default / last_or_default / single_or_default >>

Tirislib.Testing.add_test_case(
    "first_or_default returns first element when present",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({5, 10, 15}):first_or_default(99), 5)
    end
)

Tirislib.Testing.add_test_case(
    "first_or_default returns default on empty sequence",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({}):first_or_default(99), 99)
    end
)

Tirislib.Testing.add_test_case(
    "first_or_default with condition returns first matching element",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4}):first_or_default(0, function(v) return v > 2 end)
        Assert.equals(result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "first_or_default with condition returns default when no match",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):first_or_default(0, function(v) return v > 10 end)
        Assert.equals(result, 0)
    end
)

Tirislib.Testing.add_test_case(
    "first_or_default handles false as default value",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({}):first_or_default(false), false)
    end
)

Tirislib.Testing.add_test_case(
    "last_or_default returns last element when present",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({5, 10, 15}):last_or_default(99), 15)
    end
)

Tirislib.Testing.add_test_case(
    "last_or_default returns default on empty sequence",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({}):last_or_default(99), 99)
    end
)

Tirislib.Testing.add_test_case(
    "last_or_default with condition returns last matching element",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3, 4, 5}):last_or_default(0, function(v) return v < 4 end)
        Assert.equals(result, 3)
    end
)

Tirislib.Testing.add_test_case(
    "last_or_default with condition returns default when no match",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({1, 2, 3}):last_or_default(0, function(v) return v > 10 end)
        Assert.equals(result, 0)
    end
)

Tirislib.Testing.add_test_case(
    "single_or_default returns value for single element",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({42}):single_or_default(99), 42)
    end
)

Tirislib.Testing.add_test_case(
    "single_or_default returns default on empty sequence",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({}):single_or_default(99), 99)
    end
)

Tirislib.Testing.add_test_case(
    "single_or_default errors when sequence has more than one element",
    "lib.lazy-luaq",
    function()
        Assert.throws(function() LazyLuaq.from({1, 2}):single_or_default(99) end)
    end
)

Tirislib.Testing.add_test_case(
    "single_or_default with condition returns matching element",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({1, 2, 3}):single_or_default(0, function(v) return v == 2 end), 2)
    end
)

Tirislib.Testing.add_test_case(
    "single_or_default with condition returns default when no match",
    "lib.lazy-luaq",
    function()
        Assert.equals(LazyLuaq.from({1, 2, 3}):single_or_default(0, function(v) return v == 5 end), 0)
    end
)

Tirislib.Testing.add_test_case(
    "single_or_default with condition errors on multiple matches",
    "lib.lazy-luaq",
    function()
        Assert.throws(function()
            LazyLuaq.from({2, 2, 3}):single_or_default(0, function(v) return v == 2 end)
        end)
    end
)

---------------------------------------------------------------------------------------------------
-- << flatten >>

Tirislib.Testing.add_test_case(
    "flatten flattens a sequence of tables",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({{1, 2}, {3, 4}, {5}}):flatten():to_array()
        Assert.equals(result, {1, 2, 3, 4, 5})
    end
)

Tirislib.Testing.add_test_case(
    "flatten is equivalent to select_many with identity",
    "lib.lazy-luaq",
    function()
        local data = {{10, 20}, {30, 40}}
        local via_flatten = LazyLuaq.from(data):flatten():to_array()
        local via_select_many = LazyLuaq.from(data):select_many(function(v) return v end):to_array()
        Assert.equals(via_flatten, via_select_many)
    end
)

Tirislib.Testing.add_test_case(
    "flatten works with LazyLuaqQuery elements",
    "lib.lazy-luaq",
    function()
        local result = LazyLuaq.from({LazyLuaq.range(1, 2), LazyLuaq.range(3, 4)}):flatten():to_array()
        Assert.equals(result, {1, 2, 3, 4})
    end
)

---------------------------------------------------------------------------------------------------
-- << index semantics >>
-- One test per rule of the index semantics in the header of tirislib/lazy-luaq.lua.
-- Most other tests use to_array(), which discards the indices.

--- Collects the (index, value) pairs of a query in iteration order, so repeated indices show.
local function pairs_of(query)
    local ret = {}
    for index, value in query:iterate() do
        ret[#ret + 1] = {index, value}
    end
    return ret
end

Tirislib.Testing.add_test_case(
    "generators yield sequential indices starting at 1",
    "lib.lazy-luaq",
    function()
        Assert.equals(pairs_of(LazyLuaq.range(3, 5)), {{1, 3}, {2, 4}, {3, 5}})
        Assert.equals(pairs_of(LazyLuaq.repeat_element("x", 2)), {{1, "x"}, {2, "x"}})
        Assert.equals(pairs_of(LazyLuaq.repeat_function(function() return "y" end, 2)), {{1, "y"}, {2, "y"}})
        Assert.equals(pairs_of(LazyLuaq.from_keyset({a = true, b = true})), {{1, "a"}, {2, "b"}})
    end
)

Tirislib.Testing.add_test_case(
    "from_iterator adds sequential indices for iterators that return only one value",
    "lib.lazy-luaq",
    function()
        local values = {"x", "y", "z"}
        local i = 0
        local function next_value()
            i = i + 1
            return values[i]
        end
        Assert.equals(pairs_of(LazyLuaq.from_iterator(next_value)), {{1, "x"}, {2, "y"}, {3, "z"}})
    end
)

Tirislib.Testing.add_test_case(
    "zip and pairwise yield sequential indices",
    "lib.lazy-luaq",
    function()
        local zipped = LazyLuaq.from({a = 1, b = 2}):zip({x = 10, y = 20}, function(l, r) return l + r end)
        Assert.equals(pairs_of(zipped), {{1, 11}, {2, 22}})

        local differences = LazyLuaq.from({a = 1, b = 3, c = 6}):pairwise(function(prev, curr) return curr - prev end)
        Assert.equals(pairs_of(differences), {{1, 2}, {2, 3}})
    end
)

Tirislib.Testing.add_test_case(
    "select replaces the index only when the selector returns a second value",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({a = 1, b = 2})
        Assert.equals(query:select(function(v) return v * 10 end):to_table(), {a = 10, b = 20})
        Assert.equals(query:select(function(v, i) return v, i .. i end):to_table(), {aa = 1, bb = 2})
        Assert.equals(query:select(function(v) return v, nil end):to_table(), {a = 1, b = 2})
    end
)

Tirislib.Testing.add_test_case(
    "select_many and flatten yield the indices of the inner sequences",
    "lib.lazy-luaq",
    function()
        local flattened = LazyLuaq.from({p = {1, 2}, q = {3}}):flatten()
        Assert.equals(pairs_of(flattened), {{1, 1}, {2, 2}, {1, 3}})

        local projected = LazyLuaq.from({a = 1, b = 2}):select_many(function(v) return {x = v, y = v * 10} end)
        Assert.equals(pairs_of(projected), {{"x", 1}, {"y", 10}, {"x", 2}, {"y", 20}})
    end
)

Tirislib.Testing.add_test_case(
    "chunk yields sequential indices and the chunks keep the original indices",
    "lib.lazy-luaq",
    function()
        local chunks = pairs_of(LazyLuaq.from({a = 1, b = 2, c = 3}):chunk(2))
        Assert.equals(#chunks, 2)
        Assert.equals(chunks[1][1], 1)
        Assert.equals(chunks[2][1], 2)
        Assert.equals(chunks[1][2]:to_table(), {a = 1, b = 2})
        Assert.equals(chunks[2][2]:to_table(), {c = 3})
    end
)

Tirislib.Testing.add_test_case(
    "window yields sequential indices and the windows are arrays",
    "lib.lazy-luaq",
    function()
        local windows = pairs_of(LazyLuaq.from({a = 1, b = 2, c = 3}):window(2))
        Assert.equals(#windows, 2)
        Assert.equals(windows[1][1], 1)
        Assert.equals(windows[2][1], 2)
        Assert.equals(windows[1][2]:to_table(), {1, 2})
        Assert.equals(windows[2][2]:to_table(), {2, 3})
    end
)

Tirislib.Testing.add_test_case(
    "group_by uses the group key as index and the groups keep the original indices",
    "lib.lazy-luaq",
    function()
        local groups = LazyLuaq.from({a = 1, b = 2, c = 3}):group_by(function(v) return v % 2 end):to_table()
        Assert.equals(groups[1]:to_table(), {a = 1, c = 3})
        Assert.equals(groups[0]:to_table(), {b = 2})
    end
)

Tirislib.Testing.add_test_case(
    "order, shuffle and partial_sort yield sequential indices",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({a = 3, b = 1, c = 2})
        Assert.equals(query:order():to_table(), {1, 2, 3})
        Assert.equals(query:order_by_descending(function(v) return v end):to_table(), {3, 2, 1})
        Assert.equals(query:partial_sort(2):to_table(), {1, 2})
        Assert.equals(query:shuffle():order():to_table(), {1, 2, 3})
        Assert.equals(LazyLuaq.from(query:shuffle():to_table()):count(), 3)
    end
)

Tirislib.Testing.add_test_case(
    "reverse keeps the original indices",
    "lib.lazy-luaq",
    function()
        local reversed = LazyLuaq.from({"a", "b", "c"}):reverse()
        Assert.equals(reversed:to_array(), {"c", "b", "a"})
        Assert.equals(reversed:to_table(), {"a", "b", "c"})
        Assert.equals(pairs_of(LazyLuaq.from({x = 1, y = 2}):reverse()), {{"y", 2}, {"x", 1}})
    end
)

Tirislib.Testing.add_test_case(
    "concat and prepend keep the original indices",
    "lib.lazy-luaq",
    function()
        local combined = LazyLuaq.from({"x", "y"}):concat({"z"})
        Assert.equals(pairs_of(combined), {{1, "x"}, {2, "y"}, {1, "z"}})
        Assert.equals(combined:to_table(), {"z", "y"})
        Assert.equals(pairs_of(LazyLuaq.from({a = 1}):prepend({b = 2})), {{"b", 2}, {"a", 1}})
    end
)

Tirislib.Testing.add_test_case(
    "filtering, take, skip, distinct and scan keep the original indices",
    "lib.lazy-luaq",
    function()
        local query = LazyLuaq.from({a = 1, b = 2, c = 3, d = 2})
        Assert.equals(query:where(function(v) return v > 1 end):to_table(), {b = 2, c = 3, d = 2})
        Assert.equals(query:take(2):to_table(), {a = 1, b = 2})
        Assert.equals(query:skip(2):to_table(), {c = 3, d = 2})
        Assert.equals(query:distinct():to_table(), {a = 1, b = 2, c = 3})
        Assert.equals(query:scan(function(acc, v) return acc + v end, 0):to_table(), {a = 1, b = 3, c = 6, d = 8})
    end
)
