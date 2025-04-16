
local custom_backdrop = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileEdge = true,
	tileSize = 32,
	edgeSize = 2,
	insets = { left = 2, right = 2, top = 2, bottom = 2 },
};

JAUHUD_optf = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
JAUHUD_optf:SetPoint("CENTER")
JAUHUD_optf:SetSize(200,200)
JAUHUD_optf:SetBackdrop(custom_backdrop) --Blizzard_SharedXML/Backdrop.lua
JAUHUD_optf:Hide()
--[[
JAUHUD_optf.tex = JAUHUD_optf:CreateTexture()
JAUHUD_optf.tex:SetAllPoints(JAUHUD_optf)
JAUHUD_optf.tex:SetTexture("interface/icons/inv_mushroom_11")
]]
function JAUHUD_optf:Toggle()
    if self:IsVisible() then
        self:Hide()
        return
    end
    self:Show()
end

--1 Bar textures
--2 Tooltip thinner
--3 Chat Cleanup
--4 Player Frame
local opt_list = {}
function JAUHUD.create_options()
    local togl_bars = CreateFrame("CheckButton", nil, JAUHUD_optf, "ChatConfigCheckButtonTemplate")
    togl_bars:SetPoint("TOPLEFT", 10, -5)
    togl_bars.Text:SetText("Solid health bars")
    if JauhudDB.compact_bars then
        togl_bars:SetChecked(true)
    end
    togl_bars:HookScript("OnClick", function(self)
        JauhudDB.compact_bars = self:GetChecked()
    end)
    table.insert(opt_list, togl_bars) -- add ref to table to count for size


    local togl_tooltip = CreateFrame("CheckButton", nil, togl_bars, "ChatConfigCheckButtonTemplate")
    togl_tooltip:SetPoint("TOPLEFT", 0, -20)
    togl_tooltip.Text:SetText("Cleaner tooltips")
    if JauhudDB.cleaner_tooltips then
        togl_tooltip:SetChecked(true)
    end
    togl_tooltip:HookScript("OnClick", function(self)
        JauhudDB.cleaner_tooltips = self:GetChecked()
    end)
    table.insert(opt_list, togl_tooltip) -- add ref to table to count for size


    local togl_chat = CreateFrame("CheckButton", nil, togl_tooltip, "ChatConfigCheckButtonTemplate")
    togl_chat:SetPoint("TOPLEFT", 0, -20)
    togl_chat.Text:SetText("Cleaner chat frame")
    if JauhudDB.cleaner_chat then
        togl_chat:SetChecked(true)
    end
    togl_chat:HookScript("OnClick", function(self)
        JauhudDB.cleaner_chat = self:GetChecked()
    end)
    table.insert(opt_list, togl_chat) -- add ref to table to count for size


    local togl_playerframe = CreateFrame("CheckButton", nil, togl_chat, "ChatConfigCheckButtonTemplate")
    togl_playerframe:SetPoint("TOPLEFT", 0, -20)
    togl_playerframe.Text:SetText("Alt. player frame")
    if JauhudDB.alt_playerframe then
        togl_playerframe:SetChecked(true)
    end
    togl_playerframe:HookScript("OnClick", function(self)
        JauhudDB.alt_playerframe = self:GetChecked()
    end)
    table.insert(opt_list, togl_playerframe) -- add ref to table to count for size

    --

    local btnClose = CreateFrame("Button", nil, JAUHUD_optf, "UIPanelButtonTemplate")
    btnClose:SetPoint("BOTTOMRIGHT")
    btnClose:SetSize(100, 20)
    btnClose:SetText("Close /jhud")
    btnClose:SetScript("OnMouseDown", function(self)
        JAUHUD_optf:Hide()
        JAUHUD.devp("Remember to /reload")
    end)


    -- borders are 4 (+ 5 for margins), text is roughly 25, + close button
    JAUHUD_optf:SetSize(200, (#opt_list * 30) + 50)
end