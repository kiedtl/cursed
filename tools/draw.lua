#!/usr/bin/env lua5.3

function _collect_helper(vals, fun, i_f, i_s, i_v)
    local values = { i_f(i_s, i_v) }
    i_v = values[1]
    if not i_v then return vals end

    vals[#vals + 1] = fun(table.unpack(values))
    return _collect_helper(vals, fun, i_f, i_s, i_v)
end

function id(...) return ... end

function collect(fun, iter)
    return _collect_helper({}, fun, table.unpack(iter))
end

BORDER = 36

font = {}
font.current = 0
font.data    = {}

local function _copyinfo(number)
	return function(line)
		local cmd = (line[1]):lower()
		font[cmd] = line[2]:gsub("\"", "")
		if number then
			font[cmd] = tonumber(font[cmd])
		end
	end
end

local handlers = {
	["FONTBOUNDINGBOX"] = function(line)
		font.width  = tonumber(line[2])
		font.height = tonumber(line[3])
	end,
	["FOUNDRY"] = _copyinfo(),
	["FAMILY_NAME"] = _copyinfo(),
	["WEIGHT_NAME"] = _copyinfo(),
	["SLANT"] = _copyinfo(),
	["CHARS"] = _copyinfo(true),

	["ENCODING"] = function(line)
		font.current = tonumber(line[2])
		font.data[font.current] = {}
	end,

	[0] = function(line)
		local nm = tonumber(line[1], 16)

		-- if unable to parse, it's a directive we're ignoring
		if not nm then return end

		local len = #font.data[font.current]
		font.data[font.current][len + 1] = nm
	end,

}

local f = assert(io.open("font.bdf", 'rb'))
local data = assert(f:read('*all'))

for line in data:gmatch("([^\n]+)\n?") do
	local directives = collect(id, {line:gmatch("([^%s]+)%s?")})

	local handler = handlers[directives[1]]
	if handler then
		(handler)(directives)
	else
		(handlers[0])(directives)
	end
end

f:close()

-- ---

function debug(fmt, ...)
	io.stderr:write(string.format(fmt, ...))
end

local canvas = {}
local y = 1
local x = 1

local linelen   = 0
local linecount = 0
local charcount = 0

local text = assert(io.stdin:read("*all"))
for char in text:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
	if char == "\n" then
		linecount = linecount + 1
		if charcount > linelen then
			linelen = charcount
		end
		charcount = 0

		x = 1
		y = y + font.height
		goto continue
	end

	--debug("char=%s\n", utf8.codepoint(char))
	local glyph = font.data[utf8.codepoint(char)] or font.data[0]
	assert(#glyph == font.height)

	for _, n in ipairs(glyph) do
		--debug("%04X\n", n)
		if not canvas[y] then canvas[y] = {} end
		if not canvas[x] then canvas[x] = {} end

		local mag = {
			0x8000, 0x4000, 0x2000, 0x1000,
			0x800,  0x400,  0x200,  0x100,
			0x80,   0x40,   0x20,   0x10,
		}

		local oldx = x
		local target = x + font.width
		x = x

		for i = 1, #mag do
			if (n & mag[i]) ~= 0 then
				canvas[y][x] = "1"
				--debug("x")
			else
				canvas[y][x] = "0"
				--debug(".")
			end

			x = x + 1
			if x == target then break end
		end

		y = y + 1
		x = oldx
		--debug("\n")
	end

	y = y - font.height
	x = x + font.width

	charcount = charcount + 1

::continue::
end

-- solarized dark:  002b36 839496
-- solarized light: fdf6e3 657b83

local imgheight = linecount * font.height + (BORDER * 2)
local imgwidth  = linelen   * font.width  + (BORDER * 2)
local mkffcmd = ("./tools/mkff %d %d 002b36 839496"):format(imgheight, imgwidth)
local mkff = assert(io.popen(mkffcmd, 'w'))

mkff:write(("0"):rep(BORDER * imgwidth))
for y = 1, linecount * font.height do
	mkff:write(("0"):rep(BORDER))
	for x = 1, linelen * font.width do
		if canvas[y] and canvas[y][x] then
			mkff:write(canvas[y][x])
		else
			mkff:write("0")
		end
	end
	mkff:write(("0"):rep(BORDER))
end
mkff:write(("0"):rep(BORDER * imgwidth))

mkff:close()
