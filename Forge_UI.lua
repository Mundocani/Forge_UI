ForgeUI = {}

ForgeUI.FilteredErrors =
{
	[ERR_ABILITY_COOLDOWN] = true,
	[ERR_NO_ATTACK_TARGET] = true,
	[ERR_BADATTACKPOS] = true,
	[ERR_ITEM_COOLDOWN] = true,
	[ERR_OUT_OF_RAGE] = true,
	[ERR_OUT_OF_RANGE] = true,
	[SPELL_FAILED_TARGETS_DEAD] = true,
	[ERR_SPELL_COOLDOWN] = true,
	[SPELL_FAILED_SPELL_IN_PROGRESS] = true,
	[SPELL_FAILED_NO_COMBO_POINTS] = true,
}

ForgeUI.SnareSpellIDs =
{
	[GetSpellInfo(31589)] = true, -- Slow
	[GetSpellInfo(55095)] = true, -- Frost Fever
	[GetSpellInfo(45524)] = true, -- Chains of Ice
	[GetSpellInfo(50259)] = true, -- Feral Charge - Cat (Dazed)
	[GetSpellInfo(13809)] = true, -- Frost Trap
	[GetSpellInfo(5116)]  = true, -- Concussive Shot
	[GetSpellInfo(25809)] = true, -- Crippling Poison
	[GetSpellInfo(3600)]  = true, -- Earth Bind
--	[GetSpellInfo(18223)] = true, -- Curse of Exhaustion
	[GetSpellInfo(1715)]  = true, -- Hamstring
	[GetSpellInfo(12323)] = true, -- Piercing Howl
}

function ForgeUI:PatchUnitFrames()
	-- TargetFrame
	
	if not TargetFrame.ForgeUI_SetPoint then
		TargetFrame.ForgeUI_ClearAllPoints = TargetFrame.ClearAllPoints
		TargetFrame.ClearAllPoints = function () end
		TargetFrame.ForgeUI_SetPoint = TargetFrame.SetPoint
		TargetFrame.SetPoint = function () end
	end
	
	TargetFrame:ForgeUI_ClearAllPoints()
	TargetFrame:ForgeUI_SetPoint("TOPLEFT", PlayerFrame, "TOPRIGHT", 0, 0)
	
	TargetFrame.SnareMessage = TargetFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	TargetFrame.SnareMessage:SetPoint("LEFT", TargetFrame, "TOPLEFT", 15, -12)
	TargetFrame.SnareMessage:SetText("Snared")
	TargetFrame.SnareMessage:Hide()
	
	Forge.EventLib:RegisterEvent("PLAYER_TARGET_CHANGED", self.CheckSnares, self)
	Forge.EventLib:RegisterEvent("UNIT_AURA", self.CheckSnares, self)
	
	-- World objectives
	
	--WorldStateAlwaysUpFrame:ClearAllPoints()
	--WorldStateAlwaysUpFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, -5)
	
	-- Player frame updates
	
	PlayerFrame:UnregisterEvent("UNIT_ENTERING_VEHICLE")
	
	-- Buff tooltip
	
	local vSetUnitAura = GameTooltip.SetUnitAura
	
	GameTooltip.SetUnitAura = function (pTooltip, pUnit, pID, pFilter)
		vSetUnitAura(pTooltip, pUnit, pID, pFilter)
		local vName, vRank, vTexture, vCount, vType,
		      vDuration, vExpirationTime, vCasterUnitID, vStealable, vConsolidate, vSpellID = UnitAura(pUnit, pID, pFilter)
		if vCasterUnitID then
			local vCaster = UnitName(vCasterUnitID)
			
			pTooltip:AddLine("Cast by "..vCaster, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			pTooltip:AddLine("Spell ID "..tostring(vSpellID), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
			pTooltip:Show()
		end
	end
	
	--hooksecurefunc("PlayerFrame_AnimFinished", function (...) ForgeUI:ReanchorPlayerUnitFrame() end)
	--MCSchedulerLib:ScheduleRepeatingTask(1, self.ReanchorPlayerUnitFrame, self)
end

function ForgeUI:CheckSnares(pEvent, pUnitID)
	if pEvent == "PLAYER_TARGET_CHANGED"
	or (pUnitID == TargetFrame.unit and pEvent == "UNIT_AURA") then
		local vHasSnare
		
		if UnitExists(TargetFrame.unit) then
			local vBuffIndex = 1
			
			while true do
				local vName, vRank, vTexture, vCount, vType,
					  vDuration, vExpirationTime, vCasterUnitID, vStealable, vConsolidate, vSpellID = UnitAura(TargetFrame.unit, vBuffIndex, "HARMFUL")
				
				if not vName then
					break
				end
				
				if ForgeUI.SnareSpellIDs[vName] then
					vHasSnare = true
					break
				end
				
				vBuffIndex = vBuffIndex + 1
			end
		end
		
		if vHasSnare then
			TargetFrame.SnareMessage:Show()
		else
			TargetFrame.SnareMessage:Hide()
		end
	end
end
	
function ForgeUI:HideGargoyles()
	MainMenuBarArtFrame.LeftEndCap:Hide()
	MainMenuBarArtFrame.RightEndCap:Hide()
end

function ForgeUI:PatchActionBars()
	hooksecurefunc("VehicleMenuBar_MoveMicroButtons", function (...) ForgeUI:VehicleMenuBar_MoveMicroButtons(...) end)
	
	--MainMenuBar:SetHeight(96)
	MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 43)
	MainMenuBar:SetWidth(512)
	
	MainMenuBarTexture2:ClearAllPoints()
	MainMenuBarTexture2:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "BOTTOM", 0, -43)
	
	MainMenuBarTexture3:ClearAllPoints()
	MainMenuBarTexture3:SetPoint("LEFT", MainMenuBarTexture2, "RIGHT", 0, 0)
	
	MainMenuBarTexture0:ClearAllPoints()
	MainMenuBarTexture0:SetPoint("BOTTOMLEFT", MainMenuBarTexture2, "TOPLEFT", 0, 0)
	
	MainMenuBarTexture1:ClearAllPoints()
	MainMenuBarTexture1:SetPoint("LEFT", MainMenuBarTexture0, "RIGHT", 0, 0)
	
	-- XPBar
	
	MainMenuXPBarTexture0:ClearAllPoints()
	MainMenuXPBarTexture0:SetPoint("BOTTOMRIGHT", MainMenuExpBar, "BOTTOM", 0, 3)
	
	MainMenuXPBarTexture3:ClearAllPoints()
	MainMenuXPBarTexture3:SetPoint("LEFT", MainMenuXPBarTexture0, "RIGHT", 0, 0)
	
	MainMenuXPBarTexture1:Hide()
	MainMenuXPBarTexture2:Hide()
	
	MainMenuExpBar:SetWidth(512)
	
	-- ReputationWatchBar
	
	ReputationWatchBar:SetWidth(512)
	ReputationWatchBar:SetHeight(8)
	
	ReputationWatchStatusBar:SetWidth(512)
	
	ReputationWatchBarTexture0:ClearAllPoints()
	ReputationWatchBarTexture0:SetPoint("BOTTOMRIGHT", ReputationWatchStatusBar, "BOTTOM", 0, 3)
	
	ReputationWatchBarTexture3:ClearAllPoints()
	ReputationWatchBarTexture3:SetPoint("LEFT", ReputationWatchBarTexture0, "RIGHT", 0, 0)
	
	ReputationWatchBarTexture1:ClearAllPoints()
	ReputationWatchBarTexture1:SetParent(UIParent)
	ReputationWatchBarTexture1:Hide()
	ReputationWatchBarTexture2:ClearAllPoints()
	ReputationWatchBarTexture2:SetParent(UIParent)
	ReputationWatchBarTexture2:Hide()
	
	ReputationXPBarTexture2:ClearAllPoints()
	ReputationXPBarTexture2:SetParent(UIParent)
	ReputationXPBarTexture2:Hide()
	ReputationXPBarTexture3:ClearAllPoints()
	ReputationXPBarTexture3:SetParent(UIParent)
	ReputationXPBarTexture3:Hide()
	
	-- ActionBar
	
	ActionButton1:ClearAllPoints()
	ActionButton1:SetPoint("TOPLEFT", MainMenuBarArtFrame, "TOPLEFT", 8, -13)
	
	ActionBarUpButton:ClearAllPoints()
	ActionBarUpButton:SetPoint("TOPLEFT", MainMenuBarArtFrame, "TOPLEFT", -6, -50)
	
	ActionBarDownButton:ClearAllPoints()
	ActionBarDownButton:SetPoint("TOP", ActionBarUpButton, "TOP", 0, -20)
	
	MainMenuBarPageNumber:ClearAllPoints()
	MainMenuBarPageNumber:SetPoint("CENTER", MainMenuBarArtFrame, "LEFT", 30, -5 - 43)
	
	-- BonusActionBar
	
	BonusActionBarFrame:ClearAllPoints()
	BonusActionBarFrame:SetPoint("BOTTOMLEFT", ActionButton1, "BOTTOMLEFT", 0, -4)
	BonusActionBarTexture0:Hide()
	BonusActionBarTexture1:Hide()
	
	-- MicroButtons
	
	Forge:TestMessage("Moving CharacterMicroButton")
	
	CharacterMicroButton:ClearAllPoints()
	CharacterMicroButton:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMLEFT", 40, 3 - 43)
	
	-- Bags
	
	MainMenuBarBackpackButton:ClearAllPoints()
	MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "BOTTOMRIGHT", -6, 3 - 43)

	-- PetActionBar
	
	-- UIPARENT_MANAGED_FRAME_POSITIONS.PETACTIONBAR_YPOS.baseY = 98 + 40
end

function ForgeUI:HookScript(pFrame, pScriptID, pFunction)
	if not pFrame:GetScript(pScriptID) then
		pFrame:SetScript(pScriptID, pFunction)
	else
		pFrame:HookScript(pScriptID, pFunction)
	end
end

function ForgeUI:DispatchEvent(pEventID, pArg1, pArg2, pArg3, pArg4)
	if self[pEventID] then
		self[pEventID](self, pEventID, pArg1, pArg2, pArg3, pArg4)
	end
end

function ForgeUI:PlayerEnteringWorld(pEventID, pArg1, pArg2, pArg3, pArg4)
	Forge:NoteMessage("Loaded UI modifications")
	
	Forge.EventLib:UnregisterEvent("PLAYER_ENTERING_WORLD", self.PlayerEnteringWorld, self)
	
	self:PatchUnitFrames()
	
	self:HideGargoyles()
	-- self:PatchActionBars()
	self:ReanchorPlayerUnitFrame()
	self:ReanchorTrackers()
	
	-- Move the default tooltip position so that it isn't always covering the bags
	
	--[[
	self.GameTooltip_SetDefaultAnchor = GameTooltip_SetDefaultAnchor
	
	GameTooltip_SetDefaultAnchor = function(pTooltip, pParent, ...)
		if self.ShowingNewbieTooltip then
			pTooltip.default = nil
			return self.GameTooltip_SetDefaultAnchor(pTooltip, pParent, ...)
		else
			pTooltip:SetOwner(pParent, "ANCHOR_NONE")
			pTooltip.default = 1
		end
	end
	
	self:HookScript(GameTooltip, "OnUpdate", function (pTooltip)
		if not pTooltip.default then
			return
		end
		
		local vCursorX, vCursorY = GetCursorPosition()
		local vScale = 1 / UIParent:GetEffectiveScale()
		
		vCursorX = vCursorX * vScale
		vCursorY = vCursorY * vScale
		
		pTooltip:ClearAllPoints()
		
		local vNearTop, vNearLeft
		local vHorizDistance, vVertDistance
		
		if vCursorY < 0.5 * UIParent:GetTop() then
			vVertDistance = vCursorY
		else
			vVertDistance = UIParent:GetTop() - vCursorY
			vNearTop = true
		end
		
		if vCursorX < 0.5 * UIParent:GetRight() then
			vHorizDistance = vCursorX
			vNearLeft = true
		else
			vHorizDistance = UIParent:GetRight() - vCursorX
		end
		
		if vHorizDistance < vVertDistance then
			if vNearLeft then
				pTooltip:SetPoint("LEFT", UIParent, "BOTTOMLEFT", 0, vCursorY)
			else
				pTooltip:SetPoint("RIGHT", UIParent, "BOTTOMRIGHT", 0, vCursorY)
			end
		else
			if vNearTop then
				pTooltip:SetPoint("TOP", UIParent, "TOPLEFT", vCursorX, 0)
			else
				pTooltip:SetPoint("BOTTOM", UIParent, "BOTTOMLEFT", vCursorX, 0)
			end
		end
	end)
	
	self:HookScript(GameTooltip, "OnHide", function (pTooltip)
		pTooltip.default = nil
	end)
	
	ForgeUI.GameTooltip_AddNewbieTip = GameTooltip_AddNewbieTip
	
	GameTooltip_AddNewbieTip = function(...)
		ForgeUI.ShowingNewbieTooltip = true
		
		ForgeUI.GameTooltip_AddNewbieTip(...)
		
		ForgeUI.ShowingNewbieTooltip = nil
	end
	]]
	-- Remove undesirable UI errors
	
	UIErrorsFrame.Orig_AddMessage = UIErrorsFrame.AddMessage
	UIErrorsFrame.AddMessage = function (self, pMessage, ...)
		if ForgeUI.FilteredErrors[pMessage] then
			return
		end
		
		self:Orig_AddMessage(pMessage, ...)
	end
--[[
	-- I think these features are now part of the standard UI, unless I'm forgetting about something.
	-- Just disabling for now, but should remove if they really aren't needed
	if IsAddOnLoaded("Auc-Advanced") then
		if IsAddOnLoaded("Blizzard_TradeSkillUI") then
			ForgeUI:InstallAuctioneerTradeskillPrices()
			ForgeUI:InstallTradeskillReagentSearch()
		else
			Forge.EventLib:RegisterEvent("ADDON_LOADED", function (pEventID, pAddOnName)
				if pAddOnName == "Blizzard_TradeSkillUI" then
					Forge:NoteMessage("Installing tradeskill reagent searching")
					ForgeUI:InstallAuctioneerTradeskillPrices()
					ForgeUI:InstallTradeskillReagentSearch()
				end
			end)
		end
	end
]]
	-- Auction items
	
	if not IsAddOnLoaded("Auc-Advanced") then
		if IsAddOnLoaded("Blizzard_AuctionUI") then
			self:InstallPerUnitAuctionPrices()
		else
			self.EventLib:RegisterEvent("ADDON_LOADED", function (pEventID, pAddOnName)
				if pAddOnName == "Blizzard_AuctionUI" then
					self:InstallPerUnitAuctionPrices()
				end
			end)
		end
	end
	
	-- Allow chat frames to be sized much larger
	
	for vIndex = 1, 20 do
		local vChatFrame = _G["ChatFrame"..vIndex]
		
		if not vChatFrame then
			break
		end
		
		vChatFrame:SetMaxResize(1200, 1000)
	end
	
	-- Disable hiding of Blizzard chat tabs to avoid the Blizzard security bugs
	
	for vIndex = 1, 20 do
		local vChatFrameTab = _G["ChatFrame"..vIndex.."Tab"]
		
		if vChatFrameTab then
			vChatFrameTab.Hide = function (pFrame) pFrame:SetAlpha(0) end
		end
	end
end

function ForgeUI:InstallPerUnitAuctionPrices()
	for vIndex = 1, NUM_BROWSE_TO_DISPLAY do
		local vButtonName = "BrowseButton"..vIndex
		local vButton = _G[vButtonName]
		
		if not vButton then
			Forge:ErrorMessage("Couldn't find auction button %s", vButtonName or "nil")
			break
		end
		
		local vName = _G[vButtonName.."Name"]
		local vLevel = _G[vButtonName.."Level"]
		local vHighBidder = _G[vButtonName.."HighBidder"]
		local vClosingTimeText = _G[vButtonName.."ClosingTimeText"]
		
		if not vName
		or not vLevel
		or not vHighBidder
		or not vClosingTimeText then
			-- Auction frame ain't what it used to be
			Forge:ErrorMessage("Auction per-unit prices not installed because an incompatibility was detected.")
			return
		end
		
		vName:SetHeight(14)
		vLevel:SetHeight(14)
		vHighBidder:SetHeight(14)
		vClosingTimeText:SetHeight(14)
		
		local vUnitMoneyFrame = CreateFrame("Frame", vButtonName.."UnitMoneyFrame", vButton, "SmallMoneyFrameTemplate")
		SmallMoneyFrame_OnLoad(vUnitMoneyFrame)
		MoneyFrame_SetType(vUnitMoneyFrame, "AUCTION");
		SetMoneyFrameColor(vUnitMoneyFrame:GetName(), "yellow")
		MoneyFrame_SetMaxDisplayWidth(vUnitMoneyFrame, 146);
		vUnitMoneyFrame:SetFrameLevel(vButton:GetFrameLevel() + 1)
		vUnitMoneyFrame:SetPoint("TOPRIGHT", vName, "BOTTOMRIGHT")
		
		SmallMoneyFrame_OnLoad(vUnitMoneyFrame, "AUCTION")
		
		SetMoneyFrameColor(vUnitMoneyFrame:GetName(), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		vUnitMoneyFrame:Show()
	end
	
	hooksecurefunc("AuctionFrameBrowse_Update", ForgeUI.UpdatePerUnitMoneyFrames)
end

function ForgeUI.UpdatePerUnitMoneyFrames()
	Forge:DebugMessage("-----------------------------")
	Forge:DebugMessage("ForgeUI.UpdatePerUnitMoneyFrames")
	local vFirstItemOffset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
	
	for vIndex = 1, NUM_BROWSE_TO_DISPLAY do
		local vButtonName = "BrowseButton"..vIndex
		local vButton = _G[vButtonName]
		
		if vButton:IsVisible() then
			local vName, vTexture, vCount, vQuality, vCanUse, vLevel, vLevelColHeader,
				  vMinBid, vMinIncrement, vBuyoutPrice, vBidAmount,
				  vHighBidder, vOwner, vSaleStatus, vItemID, vHasAllInfo =  GetAuctionItemInfo("list", vFirstItemOffset + vIndex)
			Forge:DebugMessage("ForgeUI.UpdatePerUnitMoneyFrames: Buyout = %s (%sg) Count = %s", tostring(vBuyoutPrice), tostring(vBuyoutPrice / 10000), tostring(vCount))
			local vUnitMoneyFrame = _G[vButtonName.."UnitMoneyFrame"]
			local vUnitPrice = math.floor(vBuyoutPrice / vCount + 0.5)
			
			MoneyFrame_Update(vUnitMoneyFrame, vUnitPrice)
			vUnitMoneyFrame:Show()
		end
	end
end

function ForgeUI:ReanchorPlayerUnitFrame()
	if not PlayerFrame:CanChangeProtectedState() then
		return
	end
	
	if not PlayerFrame.ForgeUI_SetPoint then
		PlayerFrame.ForgeUI_ClearAllPoints = PlayerFrame.ClearAllPoints
		PlayerFrame.ClearAllPoints = function () end
		PlayerFrame.ForgeUI_SetPoint = PlayerFrame.SetPoint
		PlayerFrame.SetPoint = function () end
	end
	
	PlayerFrame:ForgeUI_ClearAllPoints()
	PlayerFrame:ForgeUI_SetPoint("TOPRIGHT", UIParent, "TOP", 0, 0)
	
	if ConsolidatedBuffs then
		ConsolidatedBuffs:ClearAllPoints()
		ConsolidatedBuffs:SetPoint("TOPLEFT", PlayerFrame, "TOPLEFT", 5, -20)
		
		function ConsolidatedBuffs:ClearAllPoints() end
		function ConsolidatedBuffs:SetPoint() end
	end
	if BuffFrame then
		BuffFrame:ClearAllPoints()
		BuffFrame:SetPoint("TOPRIGHT", PlayerFrame, "TOPLEFT", 0, -20)
		
		function BuffFrame:ClearAllPoints() end
		function BuffFrame:SetPoint() end
	end
end

function ForgeUI:ReanchorTrackers()
	if AchievementWatchFrame then
		AchievementWatchFrame:ClearAllPoints()
		AchievementWatchFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 200)
		
		function AchievementWatchFrame:ClearAllPoints() end
		function AchievementWatchFrame:SetPoint() end
	end
	
	if QuestWatchFrame then
		QuestWatchFrame:ClearAllPoints()
		QuestWatchFrame:SetPoint("BOTTOMRIGHT", AchievementWatchFrame, "TOPRIGHT", 0, 0)
		
		function QuestWatchFrame:ClearAllPoints() end
		function QuestWatchFrame:SetPoint() end
	end
end

function ForgeUI:VehicleMenuBar_MoveMicroButtons(pSkinName)
	CharacterMicroButton:ClearAllPoints()
	CharacterMicroButton:SetPoint("BOTTOMLEFT", MainMenuBarArtFrame, "BOTTOMLEFT", 40, 3 - 43)
end

function ForgeUI:SwapBagSlots(pBagID1, pSlotID1, pBagID2, pSlotID2)
	PickupContainerItem(pBagID1, pSlotID1)
	PickupContainerItem(pBagID2, pSlotID2)
end

function ForgeUI:InstallTradeskillReagentSearch()
	for vIndex = 1, MAX_TRADE_SKILL_REAGENTS do
		local vReagentButtonName = "TradeSkillReagent"..vIndex
		local vReagentButton = _G[vReagentButtonName]
		
		vReagentButton.Name = _G[vReagentButtonName.."Name"]
		
		vReagentButton:SetScript("OnClick", function (...) ForgeUI:ReagentButton_OnClick(...) end)
		
		local vIconTexture = _G[vReagentButtonName.."IconTexture"]
		
		vReagentButton.Highlight = vReagentButton:CreateTexture(nil, "HIGHLIGHT")
		vReagentButton.Highlight:SetPoint("TOPLEFT", vIconTexture, "TOPLEFT")
		vReagentButton.Highlight:SetPoint("BOTTOMRIGHT", vIconTexture, "BOTTOMRIGHT")
		vReagentButton.Highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		vReagentButton.Highlight:SetBlendMode("ADD")
	end
end

function ForgeUI:InstallAuctioneerTradeskillPrices()
	if MoneyTypeInfo.TRADE_AUC_VALUE then
		return
	end
	
	for vIndex = 1, TRADE_SKILLS_DISPLAYED do
		local vSkillButtonName = "TradeSkillSkill"..vIndex 
		local vSkillButton = _G[vSkillButtonName]
		
		vSkillButton.MoneyFrame = Forge:New(ForgeUI._MoneyFrame, vSkillButton)
		vSkillButton.MoneyFrame:SetScale(0.8)
		vSkillButton.MoneyFrame:SetPoint("RIGHT", vSkillButton, "RIGHT", 0, 0)
		
		vSkillButton.Text = _G[vSkillButtonName.."Text"]
		vSkillButton.Count = _G[vSkillButtonName.."Count"]
	end
	
	self.Orig_TradeSkillFrame_Update = TradeSkillFrame_Update
	TradeSkillFrame_Update = function (...) return ForgeUI:TradeSkillFrame_Update(...) end
end

function ForgeUI:ReagentButton_OnClick(pReagentButton, ...)
	if IsModifiedClick() then
		HandleModifiedItemClick(GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, pReagentButton:GetID()))
		return
	end

	local vName = pReagentButton.Name:GetText()
	
	TradeSkillFrameEditBox:SetText(vName)
	MCSchedulerLib:ScheduleUniqueTask(0.1, self.ReagentButton_ClearClassFilter, self)
end

function ForgeUI:ReagentButton_ClearClassFilter()
	SetTradeSkillSubClassFilter(0, 1, 1)
	MCSchedulerLib:ScheduleUniqueTask(0.1, self.ReagentButton_ClearSlotFilter, self)
end

function ForgeUI:ReagentButton_ClearSlotFilter()
	SetTradeSkillInvSlotFilter(0, 1, 1)
	MCSchedulerLib:ScheduleUniqueTask(0.1, self.ReagentButton_FindMatchingItem, self)
end

function ForgeUI:ReagentButton_FindMatchingItem()
	local vName = TradeSkillFrameEditBox:GetText()
	local vNumTradeSkills = GetNumTradeSkills()
	
	for vSkillIndex = 1, vNumTradeSkills do
		local vSkillName, vSkillType, vNumAvailable, vIsExpanded = GetTradeSkillInfo(vSkillIndex)
		
		if vSkillName == vName then
			TradeSkillFrame_SetSelection(vSkillIndex)
			TradeSkillFrame_Update()
			break
		end
	end
end

function ForgeUI:TradeSkillFrame_Update(...)
	self.Orig_TradeSkillFrame_Update(...)
	
	local vNumTradeSkills = GetNumTradeSkills()
	local vSkillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
	
	for vIndex = 1, TRADE_SKILLS_DISPLAYED do
		local vSkillIndex = vIndex + vSkillOffset
		
		if vSkillIndex < vNumTradeSkills then
			local vSkillButtonName = "TradeSkillSkill"..vIndex 
			local vSkillButton = _G[vSkillButtonName]
			
			local vSkillName, vSkillType, vNumAvailable, vIsExpanded = GetTradeSkillInfo(vSkillIndex)
			local vLink = GetTradeSkillItemLink(vSkillIndex)
			
			if vSkillType ~= "header"
			and vLink
			and vLink:find("|Hitem:") then
				local vMarketPrice, vSeen = AucAdvanced.API.GetMarketValue(vLink)
				
				if vSeen and vMarketPrice then
					vSkillButton.MoneyFrame:SetMoney(vMarketPrice)
					vSkillButton.MoneyFrame:Show()
					
					local vMoneyWidth = vSkillButton.MoneyFrame:GetWidth()
					
					if vNumAvailable <= 0 then
						vSkillButton.Text:SetWidth(TRADE_SKILL_TEXT_WIDTH - 2 - vMoneyWidth)
					else
						TradeSkillFrameDummyString:SetText(vSkillName)
						
						local vNameWidth = TradeSkillFrameDummyString:GetWidth()
						local vCountWidth = vSkillButton.Count:GetWidth()
						
						if vNameWidth + 2 + vCountWidth + vMoneyWidth > TRADE_SKILL_TEXT_WIDTH then
							vSkillButton.Text:SetWidth(TRADE_SKILL_TEXT_WIDTH - 2 - vCountWidth - vMoneyWidth)
						else
							vSkillButton.Text:SetWidth(TRADE_SKILL_TEXT_WIDTH - 2 - vMoneyWidth)
						end
					end
				else
					vSkillButton.MoneyFrame:Hide()
				end
			else
				vSkillButton.MoneyFrame:Hide()
			end
		end -- if
	end -- for
end

----------------------------------------
ForgeUI._MoneyFrame = {}
----------------------------------------

function ForgeUI._MoneyFrame:New(pParent)
	return CreateFrame("Frame", nil, pParent)
end

function ForgeUI._MoneyFrame:Construct(pParent)
	self:SetWidth(125)
	self:SetHeight(13)
	
	self.CopperIcon = self:CreateTexture(nil, "ARTWORK")
	self.CopperIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	self.CopperIcon:SetTexCoord(0.5, 0.75, 0, 1)
	self.CopperIcon:SetWidth(13)
	self.CopperIcon:SetHeight(13)
	self.CopperIcon:SetPoint("RIGHT", self, "RIGHT")
	
	self.CopperText = self:CreateFontString(nil, "ARTWORK", "NumberFontNormalRight")
	self.CopperText:SetWidth(20)
	self.CopperText:SetPoint("RIGHT", self.CopperIcon, "LEFT")
	
	self.SilverIcon = self:CreateTexture(nil, "ARTWORK")
	self.SilverIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	self.SilverIcon:SetTexCoord(0.25, 0.5, 0, 1)
	self.SilverIcon:SetWidth(13)
	self.SilverIcon:SetHeight(13)
	self.SilverIcon:SetPoint("RIGHT", self.CopperText, "LEFT", -4, 0)
	
	self.SilverText = self:CreateFontString(nil, "ARTWORK", "NumberFontNormalRight")
	self.SilverText:SetWidth(20)
	self.SilverText:SetPoint("RIGHT", self.SilverIcon, "LEFT")
	
	self.GoldIcon = self:CreateTexture(nil, "ARTWORK")
	self.GoldIcon:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
	self.GoldIcon:SetTexCoord(0, 0.25, 0, 1)
	self.GoldIcon:SetWidth(13)
	self.GoldIcon:SetHeight(13)
	self.GoldIcon:SetPoint("RIGHT", self.SilverText, "LEFT", -4, 0)
	
	self.GoldText = self:CreateFontString(nil, "ARTWORK", "NumberFontNormalRight")
	self.GoldText:SetWidth(30)
	self.GoldText:SetPoint("RIGHT", self.GoldIcon, "LEFT")
end

function ForgeUI._MoneyFrame:SetMoney(pMoney)
	local vGold = math.floor(pMoney / 10000)
	local vMoney = pMoney - vGold * 10000
	local vSilver = math.floor(vMoney / 100)
	local vCopper = vMoney - vSilver * 100
	
	self.GoldText:SetText(vGold)
	self.SilverText:SetText(vSilver)
	self.CopperText:SetText(vCopper)
	
	if vGold == 0 then
		self.GoldText:Hide()
		self.GoldIcon:Hide()
		
		if vSilver == 0 then
			self.SilverText:Hide()
			self.SilverIcon:Hide()
		else
			self.SilverText:Show()
			self.SilverIcon:Show()
		end
	else
		self.GoldText:Show()
		self.GoldIcon:Show()
		
		self.SilverText:Show()
		self.SilverIcon:Show()
	end
end

----------------------------------------
----------------------------------------

--ForgeUI.EventFrame:SetScript("OnEvent", function (self, event, ...) ForgeUI:DispatchEvent(event, ...) end)

Forge.EventLib:RegisterEvent("PLAYER_ENTERING_WORLD", ForgeUI.PlayerEnteringWorld, ForgeUI)
--ForgeUI.EventFrame:RegisterEvent("VARIABLES_LOADED")
