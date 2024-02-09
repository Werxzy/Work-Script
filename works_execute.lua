
works_programs, globals = {}, {}

function works_create_program(inst, obj)
    inst = works_func[inst]
	local loc_cont = {
		loc_var = {},
		obj_var = obj or {},
		program = inst, -- list of functions
		program_len = #inst, 
		line = 1,
		stack = {}, -- {{program_current, program_line, loc_var}, ...} (to be placed back into program, program_line, loc_var)
		waiting = 0,
        returning = false,
	}

    function loc_cont.call()
		context = loc_cont -- important to let outside functions know the current context

		if loc_cont.waiting > 0 then -- wait a certain number of times called
			loc_cont.waiting -= 1
			if(loc_cont.waiting > 0) return
		end
		
        ::popped::

		while loc_cont.line <= loc_cont.program_len do -- while inside the program
			loc_cont.program[loc_cont.line]()
			loc_cont.line += 1
			if(loc_cont.waiting > 0) return -- exit if waiting
		end

		-- end of program (only way to reach here is to go passed the last line)
        local s = deli(context.stack)
        if s then
            context.program, context.line, context.loc_var = unpack(s)
            context.program_len = #context.program
            goto popped
        else
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