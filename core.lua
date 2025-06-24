--[[
	a lot of stuff here remaining from dev version which
	shouldnt affect performance, just awful to look at
]]
--
-- C_Spell.GetSpellCooldown(61304)
-- local function isgcd(s) return s == 61304 or s == 42069 end
local __dev_verbose = true
local devp = function(s)
	if __dev_verbose then
		JH.devp(s)
	end
end

-- aka "You are beautiful"
JHudDB = JHudDB or {}
JHudDB.texture = "Interface/Addons/Plater/images/regular_white"

--- SetColorFill of a Green -> Red gradient based off of health
local function updatehpgrad(f)
	if JH.hpp("player") < 100 or true then
		local c = JH.gradc(JH.hpp("player"))
		f:SetColorFill(c.r / 255, c.g / 255, 0, 1)
	end
end

local function CosmeticChanges()
	local function hidef(f)
		if f then f:Hide() end
	end
	if _G["GameTooltipStatusBarTexture"] then
		_G["GameTooltipStatusBarTexture"]:SetTexture(JHudDB.texture)
	end

	if _G["CompactPartyFrameTitle"] then
		_G["CompactPartyFrameTitle"]:SetText(JHudDB.custom_title or "gamers")
	end
	
	hidef(_G["QuickJoinToastButton"])
	hidef(_G["MinimapCompassTexture"])
	CompactPartyFrame:RefreshMembers() -- just for the sake of it
end

local function JH_init()
	-- this is just an improvement overall
	CosmeticChanges()
	updatehpgrad(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar)
end

do
	--- https://warcraft.wiki.gg/wiki/Handling_events#Lua-specific
	if JH.events_registered then return end
	local event_frame, ev = CreateFrame("Frame"), {};

	--- START EVENTS
	function ev:PLAYER_LOGIN(...)
		C_Timer.After(0, function()
			JH_init()
		end)
	end
	function ev:ADDON_LOADED(...)
		local s = select(1, ...)
		if s == ownName then
			devp(s .. " loaded..?")
			-- load options..?
		end
	end
	function ev:PLAYER_REGEN_DISABLED()
		JH.combat = true
	end
	function ev:PLAYER_REGEN_ENABLED()
		JH.combat = false
	end
	function ev:UNIT_HEALTH(...)
		local p = select(1, ...)
		if p ~= nil then
			if strlower(p) == "player" then -- is player
				-- if want playerframe hp bar to be gradient'd
				updatehpgrad(PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar)
			end
		end
	end
	--- END EVENTS

	event_frame:SetScript("OnEvent", function(self, event, ...)
		ev[event](self, ...)
	end)
	for k, v in pairs(ev) do
		event_frame:RegisterEvent(k)
	end
	JH.events_registered = true
end

-- TOOLTIP
hooksecurefunc(GameTooltip, "SetPadding", function(self, style)
	-- just works
	self.NineSlice:SetBorderColor(0, 0, 0, 0)
end)

-- DAMAGE TO HP ANIMATION
hooksecurefunc(
	PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.PlayerFrameHealthBarAnimatedLoss,
	"BeginAnimation", function(self)
		-- shows dmg taken instantly instead of some slow animation
		-- god awful frame selector tho
		self:CancelAnimation()
	end)

local function replaceBar(frame)
	if not frame or not frame.healthBar then return end
	frame.healthBar:SetStatusBarTexture(JHudDB.texture)
	local t = frame.healthBar:GetStatusBarTexture()
	if t then
		t:ClearAllPoints()
		t:SetAllPoints(frame.healthBar)
		frame.healthBar:GetStatusBarTexture():SetDrawLayer("BORDER", -8) --boo
	end

	local unit = frame.displayedUnit
	if not unit or not UnitIsConnected(unit) then return end

	local absorbs = UnitGetTotalAbsorbs(unit) or 0
	local maxhp = UnitHealthMax(unit)
	local hp = UnitHealth(unit)

	if absorbs > 0 and maxhp > 0 and frame.totalAbsorbBar ~= nil then
		frame.totalAbsorbBar:Show()
		frame.totalAbsorbBar:SetDrawLayer("OVERLAY", 5)
	end
end
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", replaceBar)
hooksecurefunc("CompactUnitFrame_UpdateHealth", replaceBar)
hooksecurefunc("CompactUnitFrame_UpdateHealPrediction", function(frame)
    local unit = frame.displayedUnit
    if not unit or not UnitIsConnected(unit) then return end
    if not frame.healthBar then return end
    if not frame.totalAbsorb then return end

    local absorb = UnitGetTotalAbsorbs(unit) or 0
    if absorb > 0 then
		if frame.overAbsorbGlow ~= nil then
			frame.overAbsorbGlow:Hide()
		end

		-- this bit could be causing issues with healAbsorb?
        CompactUnitFrameUtil_UpdateFillBar(
            frame,
            frame.healthBar,
            frame.totalAbsorb,
            absorb
        )

        frame.totalAbsorb:Show()
        --frame.totalAbsorb:SetDrawLayer("OVERLAY", 5)
		frame.totalAbsorb:ClearAllPoints()
		frame.totalAbsorb:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT")
		frame.totalAbsorb:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMLEFT")
    end
end)

--	ACTIONBARS
local function AdjustButtonSpacingAndZoom(prefix)
	local zoom = 8 -- percentages
	local top = 0 + (zoom / 100)
	local bot = 1 - top
    for i = 1, 12 do
        local btn = _G[prefix.."Button"..i]
        if btn then
            if btn.icon then
                btn.icon:SetTexCoord(top, bot, top, bot)
            end

			--btn.IconMask:Hide() -- allow squared
			btn.IconMask:SetTexture("Interface/CHARACTERFRAME/TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            btn:ClearNormalTexture() -- yeet the borders
			if prefix ~= "PetAction" then -- pet icons are already tight
				btn:SetScale(1)
				local cd = _G[prefix.."Button"..i.."Cooldown"]
				if cd ~= nil then
					cd:SetAllPoints(btn)
				end
			end
        end
    end
end

hooksecurefunc("ActionBarController_UpdateAll", function()
    AdjustButtonSpacingAndZoom("Action")
    AdjustButtonSpacingAndZoom("MultiBarBottomLeft")
    AdjustButtonSpacingAndZoom("MultiBarBottomRight")
    AdjustButtonSpacingAndZoom("MultiBarLeft")
    AdjustButtonSpacingAndZoom("MultiBarRight")
    AdjustButtonSpacingAndZoom("PetAction")
end)
