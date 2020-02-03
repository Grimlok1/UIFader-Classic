
do
	local addonName, addon = ...
	local L = addon.L
	local numOfElements = 6
	
	local buttonTable = {MultiBarRightButton12, MultiBarRightButton11, MultiBarRightButton10, MultiBarRightButton9, MultiBarRightButton8, MultiBarRightButton7, MultiBarRightButton6, MultiBarRightButton5, MultiBarRightButton4, MultiBarRightButton3, MultiBarRightButton2, MultiBarRightButton1, MultiBarLeftButton12, MultiBarLeftButton11, MultiBarLeftButton10, MultiBarLeftButton9, MultiBarLeftButton8, MultiBarLeftButton7, MultiBarLeftButton6, MultiBarLeftButton5, MultiBarLeftButton4, MultiBarLeftButton3, MultiBarLeftButton2, MultiBarLeftButton1, MultiBarBottomLeftButton12, MultiBarBottomLeftButton11, MultiBarBottomLeftButton10, MultiBarBottomLeftButton9, MultiBarBottomLeftButton8, MultiBarBottomLeftButton7, MultiBarBottomLeftButton6, MultiBarBottomLeftButton5, MultiBarBottomLeftButton4, MultiBarBottomLeftButton3, MultiBarBottomLeftButton2, MultiBarBottomLeftButton1, MultiBarBottomLeftButton12, MultiBarBottomRightButton11, MultiBarBottomRightButton10, MultiBarBottomRightButton9, MultiBarBottomRightButton8, MultiBarBottomRightButton7, MultiBarBottomRightButton6, MultiBarBottomRightButton5, MultiBarBottomRightButton4, MultiBarBottomRightButton3, MultiBarBottomRightButton2, MultiBarBottomRightButton1, ActionButton12, ActionButton11, ActionButton10, ActionButton9, ActionButton8, ActionButton7, ActionButton6, ActionButton5, ActionButton4, ActionButton3, ActionButton2, ActionButton1}
	
	local function setPartyFrameAlpha(alpha)
		if UnitInRaid("Player") == nil then
			PartyMemberFrame1:SetAlpha(alpha)
			PartyMemberFrame2:SetAlpha(alpha)
			PartyMemberFrame3:SetAlpha(alpha)
			PartyMemberFrame4:SetAlpha(alpha)
			addon.db.partyFrame.alpha = alpha --saves the alpha value and when, player joins the party, he is set to that alpha value
		end
	end
	
	local function setActionBarAlpha(alpha)
		MainMenuBar:SetAlpha(alpha)
		MultiBarRight:SetAlpha(alpha)
		MultiBarLeft:SetAlpha(alpha)
	end
	
	local function showActionBar()
		MainMenuBar:Show()
		MultiBarRight:Show()
		MultiBarLeft:Show()
	end
	
	local function hideActionBar()
		MainMenuBar:Hide()
		MultiBarRight:Hide()
		MultiBarLeft:Hide()
	end
	
	local function cancelFade() -- this funtion causes error when shifting to bear form
		showActionBar()
		MinimapCluster:Show()
		PlayerFrame:Show()
		BuffFrame:Show()
		if UnitInRaid("Player") == nil then
			ShowPartyFrame()
		end
		if next(QUEST_WATCH_LIST) ~= nil then
			QuestWatchFrame:Show()
		end
		if MainMenuBar:GetAlpha() <= 0 then
			for i = 1, #buttonTable do
				local button = buttonTable[i]
				ActionButton_Update(button)
			end
		end
		
		setActionBarAlpha(1)
		setPartyFrameAlpha(1)
		MinimapCluster:SetAlpha(1)
		PlayerFrame:SetAlpha(1)
		BuffFrame:SetAlpha(1)
		QuestWatchFrame:SetAlpha(1)
		MultiActionBar_Update()
	end
		
	local function setEvents(EventListenerFrame)
		if addon.db.friendlyPlayer.value or addon.db.friendlyNpc.value or addon.db.enemyPlayer.value or addon.db.attackableNpc.value then
			EventListenerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
		end
		if addon.db.spell.value then
			EventListenerFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
		end
	end
	
	local function calculateAlpha(currentAlpha, finishedAlpha, fadingTime,callCounter)
		local updatesPerSecond = 10;
		local defaultAlpha = 1;
		local finished = 0;
		local maxCalls = fadingTime * updatesPerSecond
	
		local amountDecreasedPerCall = (defaultAlpha/(maxCalls)) * (defaultAlpha - finishedAlpha)
		local result = defaultAlpha - (amountDecreasedPerCall * callCounter)

		if callCounter == maxCalls then --last call
			finished = 1
		end
		return result, finished
	end
	local function hideFrames(alpha,name)
		if alpha <= 0.00 then
			if  name == "PartyFrame" then
				HidePartyFrame()
			elseif name == "ActionBar" then
				hideActionBar()
			else
				name:Hide()
			end
		end
	end
	
	local function loopThroughElements(fadeDuration,callCounter)
		local tbl = addon.db.tbl
		local finished = 0
		
		for i = 1, numOfElements do
			local alpha = nil
			local name = tbl[i].name
			local finishedAlpha = (tbl[i].value/100)	--slider value divided by 100 because is in range 0 - 1
			if type(name) == "table" then
				local currentAlpha = name:GetAlpha() --get current alpha
			end
			alpha, finished = calculateAlpha(currentAlpha,finishedAlpha,addon.db.fadeDur.value,callCounter)
			if name == "PartyFrame" then
				setPartyFrameAlpha(alpha)
			elseif name == "ActionBar" then
				setActionBarAlpha(alpha)
			else
				name:SetAlpha(alpha)
			end
			if finished == 1 then
				hideFrames(alpha,name)
			end
		end
	end
	
	local function onUpdate(fadeCanceled,fadeStarts,fadeDuration) --if FadeCanceled then revaluate start timer.
		local finished = false
		local onUpdatePerSecond = 10
		if fadeCanceled == true then --if fade has been canceled and on update is called set new timer.
			fadeCanceled = false
			fadeDuration = addon.db.fadeDur.value * onUpdatePerSecond
			fadeStarts = addon.db.fadeStarts.value * onUpdatePerSecond
			callCounter = 1;
		end
		if  fadeStarts ~= 0 and fadeStarts ~= nil then
			fadeStarts = fadeStarts - 1
		end 
		if fadeStarts == 0 and fadeDuration ~= 0 and fadeDuration ~= nil then
			loopThroughElements(fadeDuration,callCounter) --loop through elements
			fadeDuration = fadeDuration - 1
			callCounter = callCounter + 1
		elseif fadeDuration == 0 then 		--when FadeDuration has run its time set both values to nil
			fadeDuration = nil
			fadeStarts = nil 
		end
		return fadeCanceled, fadeStarts, fadeDuration
	end
	
	local function okayPressed()  -- Save all variables when okay is pressed.
		if InCombatLockdown() then
			addon.func.cancelPressed()
			return
		else
			for i = 1, #addon.db.tbl do
				local key = addon.db.tbl[i]
				local name = _G[key.globalName]
				local value = key.value
				
				if type(value) == "boolean" then
					key.value = name:GetChecked()
				else
					key.value = name:GetValue()
				end
			end
		end
	end
	
	local function cancelPressed() -- reset all variables to previous state 
		for i = 1, #addon.db.tbl do
			local key = addon.db.tbl[i]
			local name = _G[key.globalName]
			local value = key.value
			
			if type(value) == "boolean" then
				name:SetChecked(key.value) -- set checkbox value back to original
			else
				name:SetValue(key.value)
			end
		end
	end
	
	local a = {}
	a.setStatus = setStatus
	a.startTimer = startTimer
	a.setSaved = setSaved
	a.cancelFade = cancelFade
	a.setEvents = setEvents
	a.setFrameValues = setFrameValues
	a.onUpdate = onUpdate
	a.okayPressed = okayPressed
	a.cancelPressed = cancelPressed
	a.setPartyFrameAlpha = setPartyFrameAlpha
	addon.func = a
end