
works_programs, works_globals, works_constants = {}, {}, {}

function works_create_program(inst, obj)
    inst = works_func[inst]
	local loc_cont = {
		var = {works_constants, works_globals, {}, obj or {}},
		program = inst, -- list of functions
		program_len = #inst, 
		exe_line = 1,
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
		while loc_cont.exe_line <= loc_cont.program_len do
			loc_cont.program[loc_cont.exe_line]()
			loc_cont.exe_line += 1
			if(loc_cont.waiting > 0) return -- exit if waiting
		end

		-- end of function (without returning) pop stack
        local s = deli(loc_cont.stack)
        if s then
            loc_cont.program, loc_cont.exe_line, loc_cont[3] = unpack(s)
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