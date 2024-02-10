
-- a key-value table instead of indexed as it will be faster to find function names
works_func, works_functions_list, works_functions_count = {}, {}, 0

-- takes a string of Work Script into tables to be compiled
-- this is a separate step as it can be used to serialize code
function works_preprocess(name, str)

	-- split lines by \n and ;
	local lines, labels, instructions, final_inst = double_split(str, "\n", ";"), {}, {}, {}

	-- process each line
	for i, l in ipairs(lines) do

		l = split(split(l, "/", false)[1], ":", false)
		
		-- compile labels
		for j = 1,#l-1 do
			local labs = double_split(l[j], " ", "\t")
			for l2 in all(labs) do
				assert(not labels[l2], "duplicate label")
				labels[l2] = #instructions
			end
		end 

		-- prepare instructions for processing
		local inst = double_split(l[#l], " ", "\t")
		if #inst > 0 then
			add(instructions, inst)
		end
	end

	for inst in all(instructions) do

		local id, i, param, ret = works_functions_list[inst[1]], 1, {}, {}
		if id then
			inst[1] = id
		else
			works_functions_count += 1
			works_functions_list[inst[1]], inst[1] = works_functions_count, works_functions_count
		end

		while i < #inst do
			i += 1
			local s = inst[i]
			if(s == "=") break -- now providing returns
			add(param, calc_param(s, labels))
		end

		while i < #inst do
			i += 1
			add(ret, calc_param(inst[i], labels))
		end

		add(final_inst, {inst[1], param, ret})
	end

	works_func[name] = final_inst
end

function calc_param(p, lab)
	local ty = p[1]

	if ty == "#" then
		assert(lab[sub(p, 2)], "label doesn't exist")
		return {lab[sub(p, 2)], 1}
	end

	ty = ty == "@" and 2 or ty == "_" and 3 or ty == "." and 4 or 1
	if ty == 1 then
		p = sub(p, 2)
	end
	return {tonum(p) or p, ty}
end


function double_split(str, a, b)
	local tab = {}
	for s1 in all(split(str, a, false)) do
		for s2 in all(split(s1, b, false)) do
			add(tab, s2)
		end
	end
	remove_empty(tab)
	return tab
end

function remove_empty(tab)
	while del(tab, "") do end
end
