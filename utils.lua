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
	if type(n) == "number" then 
		if n > 0 then
			for i = 2, n, 1 do
				str = str .." ".. s
			end
		end
	end
	print(_info .. "jauhud:|r " .. str)
end

ownName, JAUHUD = ...
JAUHUD.print = pInfo
JAUHUD.warn = pWarn
JAUHUD.error = pError
JAUHUD.devp = devPrint

JauhudDB = JauhudDB or {}
--

-- Purpose of this is to avoid the checks and _G shit
local function JAUHUD_HIDE(f, t, giga)
	if f then
		if t == true then
			f:Show()
		else
			if giga then f:SetVertexColor(0,0,0,0) end
			f:Hide()
		end
	else
		JAUHUD.error("tried to modify a frame that could not be found: " .. tostring(f))
	end
end
JAUHUD.hide = JAUHUD_HIDE

local function JAUHUD_LASTWORD(s)
	return s:match("([^%.]+)$")
end
JAUHUD.lastword = JAUHUD_LASTWORD

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

function JAUHUD_ClassColorRGB(_class, ffxiv)
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

local function JAUHUD_GETHP(u)
	if u then
		return UnitHealth(u)
	end
	return UnitHealth("player")
end
JAUHUD.hp = JAUHUD_GETHP
local function JAUHUD_GETMAXHP(u)
	if u then
		return UnitHealthMax(u)
	end
	return UnitHealthMax("player")
end
JAUHUD.maxhp = JAUHUD_GETMAXHP
local function JAUHUD_GETHPP(u)
	if u then
		return (UnitHealth(u) / UnitHealthMax(u)) * 100
	end
	return (UnitHealth("player") / UnitHealthMax("player")) * 100
end
JAUHUD.hpp = JAUHUD_GETHPP

local function JAUHUD_gradient(hp, c)
	if hp < 0 then return end
	local c1 = { 1.0, 0, 0 }
	local c2 = C_ClassColor.GetClassColor(UnitClassBase("player"))

	local t = hp / 100
	local red = c1[1] * (1 - t) + c2.r * t
	local gre = c1[2] * (1 - t) + c2.g * t
	local blu = c1[3] * (1 - t) + c2.b * t
	return { r = red, g = gre, b = blu }
end
JAUHUD.grad = JAUHUD_gradient

local function JAUHUD_classicgradient(hp) -- hp is %
	hp = math.floor((hp / 100) * 255)
	local red = 255 - hp
	local gre = hp
	return { r = red, g = gre, b = 0 }
end
JAUHUD.gradc = JAUHUD_classicgradient
--[[

local function OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local addOnName = ...
		print(event, addOnName)
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isLogin, isReload = ...
		print(event, isLogin, isReload)
	elseif event == "CHAT_MSG_CHANNEL" then
		local text, playerName, _, channelName = ...
		print(event, text, playerName, channelName)
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("CHAT_MSG_CHANNEL")
f:SetScript("OnEvent", OnEvent)
]]
