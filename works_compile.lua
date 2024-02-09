function set(...) -- this is kinda silly
	return ...
end

function wait(x)
	context.waiting = x
end

function go_to(x)
	context.line = x
end

-- combinds functionality to improve performance
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
		if m == "-" then val -= n
		elseif m == "+" then val += n
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
	-- don't do local context, because it could change later on
	-- may need to ~compile~ func
	return function(...)
		add(context.stack, {context.program, context.line, context.loc_var})
		local func = works_func[name]
		context.program, context.program_len, context.line, context.loc_var = func, #func, 0, {...}
		-- due to the order of things, we don't need to worry about program line
		
		-- may need to figure something out for returning variables from these functions, 
		-- maybe a specific scope of variable, or just a global variable
		-- below, I just automatically set any variables after returning to globals[0]
		-- can be used with unpack later with "unpack @0 = _a _b _c"
		
		-- could instead recognize the two functions as unique and give them special instructions
		-- other functions like set could also be given special treatment, as it's only passing the data
		-- this could add a lot of tokens though
	end
end

function returning(...)
	globals[0] = {...}
	context.program, context.line, context.loc_var = unpack(deli(context.stack))
	context.program_len = #context.program
end


function get_val(val, ty)
	if ty == 0 then
		return function() return val end
		
	elseif ty == 1 then
		local globals = globals -- could have these in a "do end"
		return function() return globals[val] end

	elseif ty == 2 then
		return function() return context.loc_var[val] end

	elseif ty == 3 then
		return function() return context.obj_var[val] end
	end
end

function set_val(key, ty)
	if ty == 1 then
		local globals = globals
		return function(val) globals[key] = val end

	elseif ty == 2 then
		return function(val) context.loc_var[key] = val end

	elseif ty == 3 then
		return function(val) context.obj_var[key] = val end
	end
end

function prep_call(inst)
	local inst, par, ret = unpack(inst)
	inst = works_functions_list[inst]
	local ret_none, ret_one = not ret or #ret == 0, #ret == 1 and ret[1]

	if not par or #par == 0 then -- no parameter
		if ret_none then -- no return
			return inst -- no need for wrapping

		elseif #ret_one == 1 then -- single return
			return function()
				ret_one(inst())
			end

		else -- multiple return
			return function()
				for i, r in inext, {inst()} do
					ret[i](r)
				end
			end
		end

	elseif #par == 1 then -- single parameter
		par = par[1]
		if ret_none then -- no return
			return function()
				inst(par())
			end

		elseif ret_one then -- single return
			return function()
				ret_one(inst(par()))
			end

		else -- multiple return
			return function()
				for i, r in inext, {inst(par())} do
					ret[i](r)
				end
			end
		end

	else -- multiple parameter
		local param = {}
		if ret_none then -- no return
			return function()
				for i, p in next, par do
					param[i] = p()
				end
				inst(unpack(param)) 
				-- todo? could use a custom recursive version of unpack, since p() need to be called, 
				-- about twice as expensive, but may save some performance due to using a loop for par
			end
			
		elseif ret_one then -- single return
			return function()
				for i, p in next, par do
					param[i] = p()
				end
				ret_one(inst(unpack(param)))
			end
			
		else -- multiple return
			return function()
				for i, p in next, par do
					param[i] = p()
				end
				for i, r in inext, {inst(unpack(param))} do
					ret[i](r)
				end
			end
		end
	end
end

function works_compile()
	works_compile_prep()

	for n, tab in pairs(works_func) do
		for i, inst in pairs(tab) do
			-- !!! turn the parameter info into function calls

			local _, par, ret = unpack(inst)
			for j, var in pairs(par) do
				par[j] = get_val(unpack(var))
			end

			for j, var in pairs(ret) do
				ret[j] = set_val(unpack(var))
			end

			-- !!! turn test_instructions into callable functions
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

