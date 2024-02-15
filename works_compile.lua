-- used to set or copy variables
-- set 1 2 3 = _a _b _c
function set(...) -- this is kinda silly
	return ...
end

function wait(x)
	context.waiting = x
end

function go_to(x)
	context.line_exe = x
end

function branch_gt(b, x, y)
	if(x > y) context.line_exe = b
end

function branch(b, t)
	if(t) context.line_exe = b
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
		if works_returning then
			works_returning = false
			return unpack(works_returned)
		else
			local _ENV, func = context, works_func[name]
			add(stack, {program, program_len, line_exe, loc_var})
			program, program_len, line_exe, loc_var = func, #func, 1, {...}
			func[1]() -- execute the first instruction automatically. (always will)
		end
		-- due to the order of things, we don't need to worry about program line
	end
end

function returning(...)
	works_returning, works_returned = true, {...}
	
	local _ENV = context
	local s = deli(stack)
	program, program_len, line_exe, loc_var = s[1], s[2], s[3], s[4] -- unpack is a little slower
	program[line_exe]() -- execute the original instruction automatically. (always will)
end

-- returns a function that gets a value for a parameter.
-- need to test using indexing instead of functions to potentially boost performance
function get_val(val, ty)
	return ty == 1 and function() return val end
		or ty == 2 and function() return works_globals[val] end
		or ty == 3 and function() return context.loc_var[val] end
		or ty == 4 and function() return context.obj_var[val] end
end

-- returns a function that sets a value to a returned value.
function set_val(key, ty)
	return ty == 2 and function(val) works_globals[key] = val end
		or ty == 3 and function(val) context.loc_var[key] = val end
		or ty == 4 and function(val) context.obj_var[key] = val end
end
-- [[ 
-- slightly better performance
function prep_call(inst)
	local inst, par, ret = unpack(inst)
	local inst, ret_none, ret_one, par_count, param = works_functions_nameid[inst], #ret == 0, #ret == 1 and ret[1], #par, {}

	if par_count == 0 then -- no parameter
		if ret_none then -- no return
			return inst -- no need for wrapping

		elseif ret_one then -- single return
			return function() ret_one(inst()) end
		end 

		return function() -- multiple return
			for i, r in inext, {inst()} do
				ret[i](r)
			end
		end

	elseif par_count == 1 then -- single parameter
		par = par[1]
		if ret_none then -- no return
			return function() inst(par()) end

		elseif ret_one then -- single return
			return function() ret_one(inst(par())) end
		end 

		return function() -- multiple return
			for i, r in inext, {inst(par())} do
				ret[i](r)
			end
		end
	end 

	-- multiple parameter
	if ret_none then -- no return
		return function()
			for i, p in inext, par do
				param[i] = p()
			end
			inst(unpack(param))
		end
		
	elseif ret_one then -- single return
		return function()
			for i, p in inext, par do
				param[i] = p()
			end
			ret_one(inst(unpack(param)))
		end
	end
	
	return function() -- multiple return
		for i, p in inext, par do
			param[i] = p()
		end
		for i, r in inext, {inst(unpack(param))} do
			ret[i](r)
		end
	end
end
--]]
--[[
-- alternative using fewer tokens
-- returns a function that calls a function with given parameters and set variables with given returned values.
function prep_call(inst)
	local param, inst, par, ret = {}, unpack(inst)
	inst = works_functions_nameid[inst]

	return function()
		for i, p in next, par do
			param[i] = p()
		end
		local r = {inst(unpack(param))}
		for i = 1,min(#ret,#r) do
			ret[i](r[i])
		end
	end
end
--]]

-- compiles all prepared functions
function works_compile()
	-- creates table of functions based on what is used in the compile functions
	local new_list = {}
	for k,v in ipairs(works_functions_nameid) do
		new_list[k] = works_func[v] and custom_function(v) or _ENV[v]
	end
	works_functions_nameid = new_list

	-- turn the function data into callable functions
	for n, tab in next, works_func do
		for i, inst in next, tab do
			-- !!! turn the parameter info into function calls

			local _, par, ret = unpack(inst)
			for j, var in next, par do
				par[j] = get_val(unpack(var))
			end

			for j, var in next, ret do
				ret[j] = set_val(unpack(var))
			end

			-- !!! turn test_instructions into callable functions
			tab[i] = prep_call(inst)
		end
	end
end
