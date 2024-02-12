
works_programs, works_globals = {}, {}

function works_create_program(inst, obj)
	inst = works_func[inst]
	local loc_cont = {
		loc_var = {},
		obj_var = obj or {},
		program = inst, -- list of functions
		program_len = #inst, 
		line_exe = 1,
		stack = {}, -- {{program_current, program_line, loc_var}, ...} (to be placed back into program, program_line, loc_var)
		waiting = 0,
		returning = false,
	}

	function loc_cont.call()
		context = loc_cont -- important to let outside functions know the current context
		
		-- wait a certain number of times called before continuing execution
		if loc_cont.waiting > 0 then 
			loc_cont.waiting -= 1
			if(loc_cont.waiting > 0) return
		end
		
		::popped::

		 -- while inside the program
		while loc_cont.line_exe <= loc_cont.program_len do
			loc_cont.program[loc_cont.line_exe]()
			loc_cont.line_exe += 1
			if(loc_cont.waiting > 0) return -- exit if waiting
		end

		-- end of function (without returning) pop stack
		local s = deli(loc_cont.stack)
		if s then
			loc_cont.program, loc_cont.line_exe, loc_cont.loc_var = unpack(s)
			loc_cont.program_len = #loc_cont.program
			goto popped
		else
			-- no longer executing
			del(works_programs, loc_cont)
		end 
	end

	add(works_programs, loc_cont)
end

function works_execute()
	for p in all(works_programs) do
		p.call()
	end
end