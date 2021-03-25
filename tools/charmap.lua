#!/usr/bin/env lua5.3

local max = 45
local col = 0

local f = assert(io.open("font.bdf", 'rb'))
local data = assert(f:read('*all'))

for line in data:gmatch("([^\n]+)\n?") do
	local cmd, arg = line:match("([^%s]+)%s+(.+)")

	if cmd == "CHARS" then
		local total = tonumber(arg)
		max = math.floor(math.sqrt(total))
	elseif cmd == "ENCODING" then
		local ch = tonumber(arg)
		if ch ~= 10 then
			io.stdout:write(utf8.char(ch))
			io.stdout:write(" ")
			col = col + 1
		end
	end

	if col >= max then
		print()
		col = 0
	end
end

print()
f:close()
