
works_programs, works_globals = {}, {}

function works_create_program(inst, run_once, unfreezable, obj)
	inst = works_func[inst]
	local loc_cont = {
		loc_var = {},
		obj_var = obj or {},
		program = inst, -- list of functions
		program_len = #inst, 
		line_exe = 1,
		stack = {}, -- {{program_current, program_line, loc_var}, ...} (to be placed back into program, program_line, loc_var)
		waiting = 0,
		unfreezable = unfreezable,
	}

	function loc_cont.call()
		context = loc_cont -- important to let outside functions know the current context
		
		-- wait a certain number of times called before continuing execution
		if loc_cont.waiting > 0 then 
			loc_cont.waiting -= 1
			if(loc_cont.waiting > 0) return
		end
		
		::popped::
		-- local func = loc_cont.program[loc_cont.line_exe]
		--  -- while inside the program
		-- while func do
		-- 	func()
		-- 	loc_cont.line_exe += 1
		-- 	func = loc_cont.program[loc_cont.line_exe]
		-- 	if(loc_cont.waiting > 0) return -- exit if waiting
		-- end

		-- same performance, 1 less token, slightly less memory usage
		local func = loc_cont.program[loc_cont.line_exe] -- get next function
		while func do -- while/if function exists (inside bounds of program)
			func()
			loc_cont.line_exe, func = inext(loc_cont.program, loc_cont.line_exe) -- get next function and index
			if(loc_cont.waiting > 0) return -- exit if waiting
		end

		-- end of function (without returning) pop stack
		local s = deli(loc_cont.stack)
		if s then
			loc_cont.program, loc_cont.program_len, loc_cont.line_exe, loc_cont.loc_var = unpack(s)
			goto popped
		else
			-- no longer executing
			del(works_programs, loc_cont)
		end 
	end

	add(works_programs, loc_cont)

	if(run_once)loc_cont.call()
end

function works_execute(frozen)
	for p in all(works_programs) do
		if(not frozen or p.unfreezable) p.call()
	end
end