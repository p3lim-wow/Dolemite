local addon = ...

local button = CreateFrame('Button', addon, UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
local macro = '/cast %s\n/use %s %s'
local spell = GetSpellInfo(13262)

local ARMOR_TYPE = GetLocale() == 'ruRU' and 'Доспехи' or ARMOR

local function Clickable()
	return not InCombatLockdown() and IsAltKeyDown()
end

local function Disperse(self)
	if(InCombatLockdown()) then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:Hide()
		self:ClearAllPoints()
		AutoCastShine_AutoCastStop(self)
	end
end

function button:MODIFIER_STATE_CHANGED(event, key)
	if(self:IsShown() and (key == 'LALT' or key == 'RALT')) then
		Disperse(self)
	end
end

function button:PLAYER_REGEN_ENABLED(event)
	self:UnregisterEvent(event)
	Disperse(self)
end

function button:PLAYER_LOGIN()
	if(not IsSpellKnown(13262)) then return end

	GameTooltip:HookScript('OnTooltipSetItem', function(self)
		local item = self:GetItem()
		if(item and Clickable()) then

			local _, _, quality, _, _, type = GetItemInfo(item)
			if(not (type == ARMOR_TYPE or type == ENCHSLOT_WEAPON) or not (quality and (quality > 1 and quality < 5))) then return end

			local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()
			if(GetContainerItemInfo(bag:GetID(), slot:GetID()) and bag ~= PaperDollFrameItemFlyoutButtons) then
				button:SetAttribute('macrotext', macro:format(spell, bag:GetID(), slot:GetID()))
				button:SetAllPoints(slot)
				button:Show()
				AutoCastShine_AutoCastStart(button, 0.5, 0.5, 1)
			end
		end
	end)
end

do
	button:SetScript('OnLeave', Disperse)
	button:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
	button:SetFrameStrata('DIALOG')
	button:RegisterEvent('MODIFIER_STATE_CHANGED')
	button:RegisterEvent('PLAYER_LOGIN')
	button:RegisterForClicks('LeftButtonUp')
	button:SetAttribute('*type*', 'macro')
	button:Hide()

	for _, sparks in pairs(button.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end
