pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

#include works_preprocess.lua
#include works_compile.lua
#include works_execute.lua

func = [[
	set 1 = _a
loop:
	cls
	rectfill 10 10 100 _a 8
	adding _a
	unpack @0 = _a
	rnd 20 = _b
	wait 1
	go_to #loop

]]

func2 = [[
	math 1 + _1 % 20 = _1
	returning _1
]]

works_preprocess("test", func)
works_preprocess("adding", func2)
works_compile()
works_create_program("test")

function _draw()
	works_execute()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
