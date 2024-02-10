-- used to set or copy variables
-- set 1 2 3 = _a _b _c
function set(...) -- this is kinda silly
	return ...
end

function wait(x)
	context.waiting = x
end

function go_to(x)
	context.line = x
end

function branch_gt(x, y, b)
	if(x > y) context.line = b
end

function branch(t, b)
	if(t) context.line = b
end

-- need to test, probably faster than just having individual functions
-- could do a stack math version that allows for better order (1 2 + 3 4 + *)
function math(...)
	local iter = all{...}
	local val = iter()
	for m in iter do
		local n = iter()
		if m == "+" then val += n
		elseif m == "-" then val -= n
		elseif m == "*" then val *= n
		elseif m == "/" then val /= n
		elseif m == "\\" then val \= n
		elseif m == "%" then val %= n
		end
		-- may want to add more
	end
	return val
end

function custom_function(name)
	return function(...)
		if context.returning then
			context.returning = false
			return unpack(works_returned)
		else
			add(context.stack, {context.program, context.line, context.var[3]})
			local func = works_func[name]
			context.program, context.program_len, context.line, context.var[3] = func, #func, 0, {...}
		end
		-- due to the order of things, we don't need to worry about program line
	end
end

function returning(...)
	works_returned = {...}
	context.program, context.line, context.var[3] = unpack(deli(context.stack))
	context.line -= 1
	context.returning, context.program_len = true, #context.program
end

-- [[
-- alternative using fewer tokens
-- returns a function that calls a function with given parameters and set variables with given returned values.
function prep_call(inst)
	local param, inst, par, ret = {}, unpack(inst)
	inst = works_functions_list[inst]

	local par_ty, par_count = {}, #par
	for i = 1, par_count do
		if par[i][2] == 1 then
			add(works_constants, par[i][1])
			par[i][1] = #works_constants
		end
		add(par_ty, par[i][2])
		par[i] = par[i][1]
	end

	local ret_ty, ret_count = {}, #ret
	for i = 1, ret_count do
		add(ret_ty, ret[i][2])
		ret[i] = ret[i][1]
	end
	
--[=[ optional boost by not using unneeded parts
	if ret_count == 0 then
		return function()
			local v = context.var
			for i = 1, par_count do
				param[i] = v[par_ty[i]][par[i]]
			end
			inst(unpack(param))
		end

	elseif par_count == 0 then
		return function()
			local r = {inst()}
			for i = 1, min(ret_count, #r) do
				v[ret_ty[i]][ret[i]] = r[i]
			end
		end
	
	elseif par_count == 0 and ret_count == 0 then
		return inst
	end
--]=]
	
	return function()
		local v = context.var
		for i = 1, par_count do
			param[i] = v[par_ty[i]][par[i]]
		end

		local r = {inst(unpack(param))}
		for i = 1, min(ret_count, #r) do
			v[ret_ty[i]][ret[i]] = r[i]
		end
	end
end
--]]

-- compiles all prepared functions
function works_compile()
	works_compile_prep()

	for n, tab in next, works_func do
		for i, inst in next, tab do
			tab[i] = prep_call(inst)
		end
	end
end

function works_compile_prep()
	local new_list = {}
	for k,v in pairs(works_functions_list) do
		new_list[v] = works_func[k] and custom_function(k) or _ENV[k]
	end
	works_functions_list = new_list
end

