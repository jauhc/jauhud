
--[[
	a lot of stuff here remaining from dev version which
	shouldnt affect performance, just awful to look at
]]
--
-- C_Spell.GetSpellCooldown(61304)
-- local function isgcd(s) return s == 61304 or s == 42069 end
local __dev_verbose = false
local devp = function(s)
	if __dev_verbose then
		JAUHUD.devp(s)
	end
end

local NewTexture = "Interface/Addons/Plater/images/regular_white"

local function updatehpgrad(f)
	if JauhudDB.alt_playerframe then
		if JAUHUD.hpp("player") < 100 then
			local c = JAUHUD.gradc(JAUHUD.hpp("player"))
			f:SetColorFill(c.r / 255, c.g / 255, 0, 1)
			return
		else
			local c = C_ClassColor.GetClassColor(UnitClassBase("player"))
			f:SetColorFill(c.r, c.g, c.b, 1)
			return
		end
		local c = JAUHUD.grad(JAUHUD.hpp("player"), true)
		if c ~= nil then -- because
			local r = c.r
			local g = c.g
			local b = c.b
			if __dev_verbose then
				devp("R: " .. r .. " | G: " .. g .. " | B: " .. b) -- TODO FIX
			end
			f:SetColorFill(r, g, b, 1)
		end
	end
end

local function JAUHUD_CleanChat()
	if JauhudDB.cleaner_chat then
		local _want_hide_chat_side_button = true
		local _want_hide_quick_toast_button = true -- the button which shows online friends etc
		local _want_custom_tab_texture = false
		for i = 1, 16, 1 do
			if _G["ChatFrame" .. i .. "ButtonFrame"] and _want_hide_chat_side_button then
				_G["ChatFrame" .. i .. "ButtonFrame"]:Hide()
				--JAUHUD.devp("Hiding frame " .. i .. "buttonframe")
			end
			if _G["ChatFrame" .. i .. "Tab"] then -- remove tab backgrounds
				local kids = { _G["ChatFrame" .. i .. "Tab"]:GetRegions() }
				for j, child in ipairs(kids) do
					if child:GetObjectType() ~= "FontString" then
						--child:Hide()
						child:SetTexture() -- clears texture, a lot simpler
						--JAUHUD.devp(j .. _sep .. child:GetObjectType() .. _sep .. child:GetDebugName())
					end
				end
				--_G["ChatFrame" .. i .. "Tab"]:SetTexture(nil)
			end

			if _want_custom_tab_texture then
				-- add background to tab texts
				if _G["ChatFrame" .. i .. "TabFlash"] then
					local kids = { _G["ChatFrame" .. i .. "TabFlash"]:GetRegions() }
					for j, child in ipairs(kids) do
						devp(j .. _sep .. child:GetObjectType() .. _sep .. child:GetDebugName())
						child:SetTexture(NewTexture)
						child:SetVertexColor(0, 0, 0)
						_G["ChatFrame" .. i .. "TabFlash"]:Show()
					end
					--_G["ChatFrame" .. i .. "TabFlash"]:SetTexture(NewTexture)
					-- _G["ChatFrame" .. i .. "TabFlash"]:Show()
					-- _G["ChatFrame" .. i .. "TabFlash"]:GetRegions()[1]:SetTexture(NewTexture)
				end
			end
		end
		if _G["QuickJoinToastButton"] and _want_hide_quick_toast_button then
			_G["QuickJoinToastButton"]:Hide()
		end

		-- the dogshit tab frame is GeneralDockManager
		if _G["GeneralDockManager"] then
			--_G["GeneralDockManager"]:SetTexture(NewTexture)
		end
	end
end

local function CosmeticChanges()
	JAUHUD_CleanChat()
end

local function JAUHUD_init()
	-- this is just an improvement overall
	if _G["GameTooltipStatusBarTexture"] and JauhudDB.cleaner_tooltips then
		_G["GameTooltipStatusBarTexture"]:SetTexture(NewTexture)
	end

	CosmeticChanges()
	updatehpgrad(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar)
end

----

JAUHUD_optf:RegisterEvent("UNIT_HEALTH")
JAUHUD_optf:RegisterEvent("PLAYER_LOGIN")
JAUHUD_optf:RegisterEvent("ADDON_LOADED")
JAUHUD_optf:SetScript("OnEvent", function(self, event, p1, ...)
	-- ok... here i gave up trying to use my brain so i just let it do a few extra instructions
	if event == ("PLAYER_LOGIN") then
		C_Timer.After(0, function()
			JAUHUD_init()
		end)
	elseif event == ("ADDON_LOADED") then
		if p1 == ownName then -- THIS addon loaded
			JAUHUD.create_options()
		end
	elseif event == ("UNIT_HEALTH") then
		-- change hp bar color
		if p1 == "player" then
			-- if max hp, do class color, otherwise grad
			updatehpgrad(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar)
		end
	end
end)

hooksecurefunc(GameTooltip, "SetPadding", function(self, style)
	-- GOD, this is annoying but it works lol
	if JauhudDB.cleaner_tooltips then
		self.NineSlice:SetBorderColor(0, 0, 0, 0)
	end
end)

hooksecurefunc(
	PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.PlayerFrameHealthBarAnimatedLoss,
	"BeginAnimation", function(self)
		self:CancelAnimation()
	end)
--[[
--updatehpgrad
hooksecurefunc(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar,
	"TextStatusBarOnEvent", function(self)
		-- if unit ~= "player" then return end -- not player, dont care
		--devp("bar: " .. self:GetDebugName() .. " is typeof: " .. self:GetObjectType())
		--devp("BAR 2")
		--bar.lockColor = true -- commented after animationcancel
		--updatehpgrad(bar)
	end)
]]
-- gonna use all, so no table
hooksecurefunc("DefaultCompactUnitFrameSetup", function(frame)
	if JauhudDB.compact_bars then
		if frame.healthBar ~= nil then
			--JAUHUD.devp("compact_frame: " .. frame:GetDebugName())
			frame.healthBar:SetStatusBarTexture(NewTexture)
			frame.healthBar:GetStatusBarTexture():SetDrawLayer("BORDER") -- needed?
			-- do mana / power as well..?
			frame.background:SetTexture(NewTexture)
			frame.background:SetVertexColor(0, 0, 0, 0.5)
		end
	end
end)

SLASH_JAUHUDOPT1 = "/jhud"
function SlashCmdList.JAUHUDOPT()
	JAUHUD_optf:Toggle()
end
--SlashCmdList["SLASH_JAUHUDOPT"] = JAUHUD_optf:Toggle()