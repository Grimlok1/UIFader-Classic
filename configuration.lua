local addonName, addon = ...
local L = addon.L

function ExamplePanel_OnLoad(panel)
	print("create interface panel")	
	panel.name = addonName
	panel:Hide()
	if InterfaceOptions_AddCategory then
		InterfaceOptions_AddCategory(panel)
	else
		local category, layout = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
		Settings.RegisterAddOnCategory(category)
		addon.settingsCategory = category
	end
	
	local function CreateCheckBox(label, description, onClick)
		local check = CreateFrame("CheckButton", addonName .. label, panel, "InterfaceOptionsCheckButtonTemplate")
		check:SetScript("OnClick", function(self)
			local mark = self:GetChecked()
			onClick(self, mark and true or false) -- do something depending whether value is true or false
			if mark then
				PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
			else
				PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
			end
		end)
		check.label = _G[check:GetName() .. "Text"] --set the text of the CheckButton
		check.label:SetText(label)
		check.tooltipText = label --set the tooltip text
		check.tooltipRequirement = description --set tooltip description
		check:SetScript("OnDisable",function(self)
			check.label:SetTextColor(.5,.5,.5)
		end) 
		check:SetScript("OnEnable",function(self) check.label:SetTextColor(1,1,1)end)  -- On Enable
		return check --returs check!
	end
	-------------------------------------------------------------------------------------------------------------------------
	local function CreateSlider(name, label, high, low, description, onValueChanged)
		local slider = CreateFrame("Slider", addonName.. name, panel, "OptionsSliderTemplate") --***
			slider:SetScript("OnValueChanged", function(self)
				if onValueChanged then
					onValueChanged()
				end
				local value = self:GetValue()
				local name = self:GetName()
				if name == (addonName .. L["FadeStartsAfter"]) or name == (addonName .. L["FadeDuration"]) then
					_G[self:GetName() .. "Text"]:SetFormattedText(label,math.ceil(value))
				else
					_G[self:GetName() .. "Text"]:SetFormattedText(label, value)
				end
			end)
		slider.high = _G[slider:GetName() .. "High"]
		slider.high:SetText(high)
		slider.low = _G[slider:GetName() .. "Low"]
		slider.low:SetText(low)
		slider.text = _G[slider:GetName() .. "Text"]
		if description then
			slider.tooltipText = name --set the tooltip text
			slider.tooltipRequirement = description --set tooltip description
		end
		slider:SetScript("OnDisable",function(self)  --On Disable
			slider.high:SetTextColor(.5,.5,.5)
			slider.low:SetTextColor(.5,.5,.5)
			slider.text:SetTextColor(.5,.5,.5)
		end)
		slider:SetScript("OnEnable",function(self)  --On Disable
			slider.high:SetTextColor(1,1,1)
			slider.low:SetTextColor(1,1,1)
			slider.text:SetTextColor(1,1,1)
		end)	
		return slider
	end
	-----------------------------------------------------------------------------------------------------------------------------
	
	local mainTittle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge") --MainTittle
	mainTittle:SetPoint("TOPLEFT", 10, -2)
	mainTittle:SetText(addonName)
	
	local subTittle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subTittle:SetPoint("TOPLEFT", mainTittle, "BOTTOMLEFT", 0, -16)
	subTittle:SetText("Select Frames and set opacity:")
	
	local subTittle2 = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal") 
	subTittle2:SetPoint("TOPLEFT", subTittle, "TOPRIGHT", 180, 0)
	subTittle2:SetText("Timer options:")
	
	local subTittle3 = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	subTittle3:SetPoint("BOTTOMLEFT", subTittle2, 16, -160)
	subTittle3:SetText("Return UI When:")
	
	--SLIDERS
	local minimapSlider = CreateSlider(
		L["MinimapSlider"],
		L["Minimap opacity"],
		L["100%"],
		L["Hide"]
		)
	minimapSlider:SetMinMaxValues(0,100)
	minimapSlider:SetValue(addon.db.minimap.value)
	minimapSlider:SetValueStep(10)
	minimapSlider:SetObeyStepOnDrag(true)
	minimapSlider:SetPoint("TOPLEFT",subTittle,"BOTTOMLEFT", 23, -55)
	
	local buffFrameSlider = CreateSlider(
		L["BuffFrameSlider"],
		L["BuffFrame opacity"],
		L["100%"],
		L["Hide"]
		
		)
	buffFrameSlider:SetMinMaxValues(0,100)
	buffFrameSlider:SetValue(addon.db.buffFrame.value)
	buffFrameSlider:SetValueStep(10)
	buffFrameSlider:SetObeyStepOnDrag(true)
	buffFrameSlider:SetPoint("TOPLEFT",minimapSlider,"BOTTOMLEFT", 0, -55)
	
	local playerFrameSlider = CreateSlider(
		L["PlayerFrameSlider"],
		L["PlayerFrame opacity"],
		L["100%"],
		L["Hide"]
		)
	playerFrameSlider:SetMinMaxValues(0,100)
	playerFrameSlider:SetValue(addon.db.playerFrame.value)
	playerFrameSlider:SetValueStep(10)
	playerFrameSlider:SetObeyStepOnDrag(true)
	playerFrameSlider:SetPoint("TOPLEFT",buffFrameSlider,"BOTTOMLEFT", 0, -55)
	
	local partyFrameSlider = CreateSlider(
		L["PartyFrameSlider"],
		L["PartyFrame opacity"],
		L["100%"],
		L["Hide"]
		)
	partyFrameSlider:SetMinMaxValues(0,100)
	partyFrameSlider:SetValue(addon.db.partyFrame.value)
	partyFrameSlider:SetValueStep(10)
	partyFrameSlider:SetObeyStepOnDrag(true)
	partyFrameSlider:SetPoint("TOPLEFT",playerFrameSlider,"BOTTOMLEFT", 0, -55)
	
	local questLogSlider = CreateSlider(
		L["QuestLogSlider"],
		L["QuestLog opacity"],
		L["100%"],
		L["Hide"]
		)
	questLogSlider:SetMinMaxValues(0,100)
	questLogSlider:SetValue(addon.db.questLog.value)
	questLogSlider:SetValueStep(10)
	questLogSlider:SetObeyStepOnDrag(true)
	questLogSlider:SetPoint("TOPLEFT",partyFrameSlider,"BOTTOMLEFT", 0, -55)
	
	local actionBarSlider = CreateSlider(
		L["ActionBarSlider"],
		L["ActionBar opacity"],
		L["100%"],
		L["Hide"]
		)
	actionBarSlider:SetMinMaxValues(0,100)
	actionBarSlider:SetValue(addon.db.actionBar.value)
	actionBarSlider:SetValueStep(10)
	actionBarSlider:SetObeyStepOnDrag(true)
	actionBarSlider:SetPoint("TOPLEFT",questLogSlider,"BOTTOMLEFT", 0, -55)
	
	local fadeDuration = CreateSlider(
		L["FadeDuration"], --name
		L["Fade duration"], --label 
		L["10 sec"],	--high
		L["1 sec"],		--low
		L["Fade duration desc"] --description
		)
	fadeDuration:SetMinMaxValues(1, 10);
	fadeDuration:SetValue(addon.db.fadeDur.value)
	fadeDuration:SetValueStep(1)
	fadeDuration:SetObeyStepOnDrag(true)
	fadeDuration:SetPoint("BOTTOMLEFT",subTittle2,16,-80)
	
	local fadeStartsAfter = CreateSlider(
		L["FadeStartsAfter"],
		L["Fade starts after"], --label 
		L["30 sec"],	--high
		L["1 sec"],		--low
		L["Fade starts after desc"] --description
		)
	fadeStartsAfter:SetMinMaxValues(1, 30)
	fadeStartsAfter:SetValue(addon.db.fadeStarts.value) --Default Value to start at
	fadeStartsAfter:SetValueStep(1)
	fadeStartsAfter:SetObeyStepOnDrag(true)
	fadeStartsAfter:SetPoint("BOTTOMLEFT",fadeDuration,0,-45)
	
	--------------------------------------------------------------------------------------------------------------------------------------
	local openInventory = CreateCheckBox(
		L["Open inventory"], 
		L["Open inventory desc"],
		function(self)end)
	openInventory:SetChecked(addon.db.inventory.value)
	openInventory:SetPoint("TOPLEFT", subTittle3, "BOTTOMLEFT", 0, -8)
	
	local castSpell = CreateCheckBox(
		L["Cast spell"],
		L["Cast spell desc"],
		function(self)end)
	castSpell:SetChecked(addon.db.spell.value)
	castSpell:SetPoint("TOPLEFT", openInventory, "BOTTOMLEFT", 0, -8)
	
	local openMap = CreateCheckBox(
		L["Open map"],
		L["Open map desc"],
		function(self)end)
	openMap:SetChecked(addon.db.map.value)
	openMap:SetPoint("TOPLEFT", castSpell, "BOTTOMLEFT", 0, -8)
	
	local openTabs = CreateCheckBox(
		L["Open tabs"],
		L["Open tabs desc"],
		function(self)end)
	openTabs:SetChecked(addon.db.openTabs.value)
	openTabs:SetPoint("TOPLEFT", openMap, "BOTTOMLEFT", 0, -8)
	
	local friendlyPlayer = CreateCheckBox(
		L["Friendly player"],
		L["Friendly player desc"],
		function(self)end)
	friendlyPlayer:SetPoint("TOPLEFT", openTabs, "BOTTOMLEFT", 0, -8)
	friendlyPlayer:SetChecked(addon.db.friendlyPlayer.value)
		
	local friendlyNpc = CreateCheckBox(
		L["Friendly npc"],
		L["Friendly npc desc"],
		function(self)end)
	friendlyNpc:SetPoint("TOPLEFT", friendlyPlayer, "BOTTOMLEFT", 0, -8)
	friendlyNpc:SetChecked(addon.db.friendlyNpc.value)
		
	local enemyPlayer = CreateCheckBox(
		L["Enemy player"],
		L["Enemy player desc"],
		function(self)end)
	enemyPlayer:SetPoint("TOPLEFT", friendlyNpc, "BOTTOMLEFT", 0, -8)
	enemyPlayer:SetChecked(addon.db.enemyPlayer.value)
		
	local attackableNpc = CreateCheckBox(
		L["Attackable npc"],
		L["Attackable npc desc"],
		function(self)end)
	attackableNpc:SetPoint("TOPLEFT", enemyPlayer, "BOTTOMLEFT", 0, -8)
	attackableNpc:SetChecked(addon.db.attackableNpc.value)
	
	--------------------------------------------------------------------------------------------------------------------------------------------------------
	panel.okay = function()
		addon.func.okayPressed()
	end
	panel.cancel = function()
		addon.func.cancelPressed()
	end
end