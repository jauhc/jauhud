-- |cAARRGGBBtext|r
-- dumb fuck way to make coloured text easier to write
local _info = "|c88b2ff00"
local _warn = "|cffffff00"
local _error = "|cffff8800"
local _clear = "|r" -- redundant but consistency, i guess
local function pInfo(s) return _info .. s .. _clear end
local function pWarn(s) return _warn .. s .. _clear end
local function pError(s) return _error .. s .. _clear end
local function devPrint(s, n)
	local str = s
	if str == nil then str = "attempted to print nil!" end
	if type(n) == "number" then
		if n > 0 then
			for i = 2, n, 1 do
				str = str .." ".. s
			end
		end
	end
	print(_info .. "jauhud:|r " .. str)
end

ownName, JH = ...
--JH = JH or {}
JH.loaded = {}
JH.print = pInfo
JH.warn = pWarn
JH.error = pError
JH.devp = devPrint

function JH_Specstuff()
	if true then return end -- because i removed cooldownmanager stuff
	local myClass, myClassId = UnitClassBase("player") -- i.e. EVOKER, 13
	local mySpecId = GetSpecialization() -- returns simple index 1-3 or so
	local realSpecId = GetSpecializationInfoForClassID(myClassId, mySpecId)
	local heroTalents = C_ClassTalents.GetActiveHeroTalentSpec() or 0
	return realSpecId, heroTalents
end

-- Purpose of this is to avoid the checks and _G shit
local function JH_HIDE(f, t, giga)
	if f then
		if t == true then
			f:Show()
		else
			if giga then f:SetVertexColor(0,0,0,0) end
			f:Hide()
		end
	else
		JH.error("tried to modify a frame that could not be found: " .. tostring(f))
	end
end
JH.hide = JH_HIDE

local function JH_LASTWORD(s)
	return s:match("([^%.]+)$")
end
JH.lastword = JH_LASTWORD

function PrintTable(t, indent)
	assert(type(t) == "table", "PrintTable() called for non-table!")

	local indentString = ""
	for i = 1, indent do
		indentString = indentString .. "  "
	end

	for k, v in pairs(t) do
		if type(v) ~= "table" then
			if type(v) == "string" then
				print(indentString, k, "=", v)
			end
		else
			print(indentString, k, "=")
			print(indentString, "  {")
			PrintTable(v, indent + 2)
			print(indentString, "  }")
		end
	end
end

local function doBrightness(c, b)
	-- adds b amount of brightness
	if b < 0 then return c end -- no ops needed, return
	local red = c[1] * b
	local green = c[2] * b
	local blue = c[3] * b

	if type(red) ~= "number" then red = 255 end
	if type(green) ~= "number" then green = 0 end
	if type(blue) ~= "number" then blue = 255 end

	local f = { red, green, blue }
	return f --{ red, green, blue }
end

function JH_ClassColorRGB(_class, ffxiv)
	local _role_colors = { ffxiv = { dps = { 106, 45, 43 }, healer = { 64, 101, 45 }, tank = { 49, 58, 124 } }, solid = { dps = { 255, 0, 0 }, healer = { 0, 255, 0 }, tank = { 0, 0, 255 } } }
	local c = {}
	if ffxiv then c = _role_colors.ffxiv else c = _role_colors.solid end
	local class = string.lower(_class)
	if class == "dps" or class == "damager" then
		return c.dps
	elseif class == "healer" then
		return c.healer
	elseif class == "tank" then
		return c.tank
	else
		--
		c = C_ClassColor.GetClassColor(class)
		if c then
			return { c.r * 255, c.g * 255, c.b * 255 }
		else
			return { 255, 0, 255 }
		end
	end
end

local function JH_GETHP(u)
	if u then
		return UnitHealth(u)
	end
	return UnitHealth("player")
end
JH.hp = JH_GETHP
local function JH_GETMAXHP(u)
	if u then
		return UnitHealthMax(u)
	end
	return UnitHealthMax("player")
end
JH.maxhp = JH_GETMAXHP
local function JH_GETHPP(u)
	if u then
		return (UnitHealth(u) / UnitHealthMax(u)) * 100
	end
	return (UnitHealth("player") / UnitHealthMax("player")) * 100
end
JH.hpp = JH_GETHPP

local function JH_gradient(hp, c)
	if hp < 0 then return end
	local c1 = { 1.0, 0, 0 }
	local c2 = C_ClassColor.GetClassColor(UnitClassBase("player"))

	local t = hp / 100
	local red = c1[1] * (1 - t) + c2.r * t
	local gre = c1[2] * (1 - t) + c2.g * t
	local blu = c1[3] * (1 - t) + c2.b * t
	return { r = red, g = gre, b = blu }
end
JH.grad = JH_gradient

local function JH_classicgradient(hp) -- hp is %
	hp = math.floor((hp / 100) * 255)
	local red = 255 - hp
	local gre = hp
	return { r = red, g = gre, b = 0 }
end
JH.gradc = JH_classicgradient


local function JH_tableswap(table, pos1, pos2)
	table[pos1], table[pos2] = table[pos2], table[pos1]
	return table
end
JH.swptbl = JH_tableswap

local function JH_clearTable(t)
	for k in pairs(t) do
		t[k] = nil
	end
end
JH.cleartbl = JH_clearTable
