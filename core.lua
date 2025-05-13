local addonName, addon = ...
local L = addon.L
local openedTabsTable = {} --stores all the opened tabs removes them when they are hidden.
local panel = CreateFrame("Frame", addonName .. "panelFrame")
panel.name = addonName
local FadeCanceled = nil;
local disabled = false;
local settingOpen = nil;
local FadeStarts = nil;
local FadeDuration = nil;
local delay = nil;
------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

SLASH_DISABLE_FADER1, SLASH_DISABLE_FADER2 = "/disfader", "/disf"
SLASH_ENABLE_FADER1, SLASH_ENABLE_FADER2 = "/enfader", "/enf"

function SlashCmdList.DISABLE_FADER(msg, editBox)
	if disabled == false then
		if InCombatLockdown() ~= true then
			addon.func.cancelFade()
			disabled = true
			FadeCanceled = true
		else
			print("|cfff26e0a".."["..addonName.."] ".. "You cannot disabled the fader in combat".."|r")
		end
	end
end

function SlashCmdList.ENABLE_FADER(msg, editBox)
	if disabled == true then
		disabled = false
	end
end
	
--Event Handler
local EventListenerFrame = CreateFrame("Frame") --Create event listener Frame
local eventHandlers = {}

local function eventHandlerFunction(self,event, ...) --event handler function 
	return eventHandlers[event](...)
end

EventListenerFrame:SetScript("OnEvent",eventHandlerFunction)
EventListenerFrame:RegisterEvent("ADDON_LOADED")
EventListenerFrame:RegisterEvent("PLAYER_LOGIN")
EventListenerFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
EventListenerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
EventListenerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
EventListenerFrame:RegisterEvent("GROUP_JOINED")
----------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
--EVENTS
function eventHandlers.PLAYER_LOGIN()
	print("|cfff26e0a".."Hello "..UnitName("PLAYER").." thank you for downloading ".. addonName.."|r") --Display logging message when use logs in, so they don't forget.
	print("|cfff26e0a".."Type /disfader or /disf to disabled the fading. Type /enfader or /enf to enable the fading".."|r")
end
function eventHandlers.LOADING_SCREEN_DISABLED() --start fading when player enter world.
	delay = 1 + GetTime()
	FadeCanceled = true;
	targetTaken = false;
	if InCombatLockdown() ~= true then
		addon.func.cancelFade()
	end
end
function eventHandlers.PLAYER_REGEN_DISABLED() --enter combat
	FadeCanceled = true;
	if InCombatLockdown() ~= true then
		addon.func.cancelFade()
	end
end
function eventHandlers.UNIT_SPELLCAST_SENT()
	FadeCanceled = true;
	if InCombatLockdown() ~= true then 
		addon.func.cancelFade() 
	end
end
function eventHandlers.GROUP_ROSTER_UPDATE()
	addon.func.setPartyFrameAlpha(addon.db.partyFrame.alpha)
	if UnitInRaid("Player") == nil then
		if addon.db.partyFrame.alpha <= 0 then
				HidePartyFrame()
		end
	end
end
function eventHandlers.GROUP_JOINED()
	addon.func.setPartyFrameAlpha(addon.db.partyFrame.alpha)
	if UnitInRaid("Player") == nil then
		if addon.db.partyFrame.alpha <= 0 then
				HidePartyFrame()
		end
	end
end

function eventHandlers.PLAYER_TARGET_CHANGED()
	targetTaken = false --if nothing was caught set targetTaken to false
	if UnitExists("target") and UnitIsDead("target") ~= true then
		while 1 == 1 do
			if addon.db.friendlyNpc.value then
				if UnitIsFriend("Player","Target") and UnitIsPlayer("Target") ~= true then
					targetTaken = true;
					FadeCanceled = true;
					if InCombatLockdown() ~= true then 
						addon.func.cancelFade() --prevent calling cancel when you are in combat.
					end
					break; -- target has been found break loop
				end
			end
			if addon.db.friendlyPlayer.value then
				if UnitIsFriend("Player", "Target") and UnitIsPlayer("Target") then
					targetTaken = true;
					FadeCanceled = true;
					if InCombatLockdown() ~= true then 
						addon.func.cancelFade() --prevent calling cancel when you are in combat.
					end
					break;
				end
			end
			if addon.db.enemyPlayer.value then
				if UnitIsFriend("Player", "Target") == false and UnitIsPlayer("Target") then
					targetTaken = true;
					FadeCanceled = true;
					if InCombatLockdown() ~= true then 
						addon.func.cancelFade() --prevent calling cancel when you are in combat.
					end
					break;
				end
			end
			if addon.db.attackableNpc.value then
				if UnitIsPlayer("Target") == false and UnitCanAttack("Player", "Target") then
					targetTaken = true;
					FadeCanceled = true;
					if InCombatLockdown() ~= true then 
						addon.func.cancelFade() --prevent calling cancel when you are in combat.
					end
					break;
				end
			end				
			break; -- if nothing was caught break;
		end
	end
end

function eventHandlers.ADDON_LOADED(name) -- loads the saved variables when addon has loaded
	if name == addonName then
		if type(MyAddonDB) ~= "table" then MyAddonDB = {} end --Create a new table or use old one
		local sv = MyAddonDB
		----------------------------------------------------------------------------------------------
		----------------------------------------------------------------------------------------------
		--CHECKBOXES
		if type(sv.inventory) ~= "table" then sv.inventory = {} end
		sv.inventory.globalName = addonName .. L["Open inventory"]
		if type(sv.inventory.value) ~= "boolean" then sv.inventory.value = true end
		
		if type(sv.map) ~= "table" then sv.map = {} end
		sv.map.globalName = addonName .. L["Open map"] 
		if type(sv.map.value) ~= "boolean" then sv.map.value = false end
		
		if type(sv.spell) ~= "table" then sv.spell = {} end
		sv.spell.globalName = addonName .. L["Cast spell"]
		if type(sv.spell.value) ~= "boolean" then sv.spell.value = false end
		
		if type(sv.openTabs) ~= "table" then sv.openTabs = {} end
		sv.openTabs.globalName = addonName .. L["Open tabs"]
		if type(sv.openTabs.value) ~= "boolean" then sv.openTabs.value = false end
		
		if type(sv.friendlyPlayer) ~= "table" then sv.friendlyPlayer = {} end
		sv.friendlyPlayer.globalName = addonName .. L["Friendly player"]
		if type(sv.friendlyPlayer.value) ~= "boolean" then sv.friendlyPlayer.value = true end
		
		if type(sv.friendlyNpc) ~= "table" then sv.friendlyNpc = {} end
		sv.friendlyNpc.globalName = addonName .. L["Friendly npc"]
		if type(sv.friendlyNpc.value) ~= "boolean" then sv.friendlyNpc.value = false end
		
		if type(sv.enemyPlayer) ~= "table" then sv.enemyPlayer = {} end
		sv.enemyPlayer.globalName = addonName .. L["Enemy player"]
		if type(sv.enemyPlayer.value) ~= "boolean" then sv.enemyPlayer.value = true end
		
		if type(sv.attackableNpc) ~= "table" then sv.attackableNpc = {} end
		sv.attackableNpc.globalName = addonName .. L["Attackable npc"]
		if type(sv.attackableNpc.value) ~= "boolean" then sv.attackableNpc.value = true end
		--------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------
		--SLIDERS
	
		if type(sv.fadeDur) ~= "table" then sv.fadeDur = {} end
		sv.fadeDur.globalName = addonName .. L["FadeDuration"]
		if type(sv.fadeDur.value) ~= "number" then sv.fadeDur.value = 3 end
		
		if type(sv.fadeStarts) ~= "table" then sv.fadeStarts = {} end
		sv.fadeStarts.globalName = addonName .. L["FadeStartsAfter"]
		if type(sv.fadeStarts.value)  ~= "number" then sv.fadeStarts.value = 5 end
		---------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------
		
		if type(sv.minimap) ~= "table" then sv.minimap = {} end --creat a minimap table
		sv.minimap.name = MinimapCluster
		sv.minimap.eventHandler = MinimapCluster_OnEvent
		sv.minimap.globalName = addonName .. L["MinimapSlider"] --slider global name
		if type(sv.minimap.value) ~= "number" then sv.minimap.value = 50 end
			
		if type(sv.buffFrame) ~= "table" then sv.buffFrame = {} end
		sv.buffFrame.name = BuffFrame
		sv.buffFrame.eventHandler = BuffFrame_OnEvent
		sv.buffFrame.globalName = addonName .. L["BuffFrameSlider"]
		if type(sv.buffFrame.value) ~= "number" then sv.buffFrame.value = 50 end
			
		if type(sv.playerFrame) ~= "table" then sv.playerFrame = {} end
		sv.playerFrame.name = PlayerFrame
		sv.playerFrame.eventHandler = PlayerFrame_OnEvent
		sv.playerFrame.globalName = addonName .. L["PlayerFrameSlider"]
		if type(sv.playerFrame.value) ~= "number" then sv.playerFrame.value = 50 end
			
		if type(sv.partyFrame) ~= "table" then sv.partyFrame = {} end --*
		sv.partyFrame.name = "PartyFrame"
		sv.partyFrame.alpha = 1
		sv.playerFrame.eventHandler = PartyFrame_OnEvent
		sv.partyFrame.globalName = addonName .. L["PartyFrameSlider"]
		if type(sv.partyFrame.value) ~= "number" then sv.partyFrame.value = 50 end
			
		if type(sv.questLog) ~= "table" then sv.questLog = {} end
		sv.questLog.name = QuestWatchFrame
		sv.questLog.eventHandler = QuestWatchFrame_OnEvent
		sv.questLog.globalName = addonName .. L["QuestLogSlider"]
		if type(sv.questLog.value) ~= "number" then sv.questLog.value = 50 end
		
		if type(sv.actionBar) ~= "table" then sv.actionBar = {} end
		sv.actionBar.name = "ActionBar"
		sv.actionBar.globalName = addonName .. L["ActionBarSlider"]
		if type(sv.actionBar.value) ~= "number" then sv.actionBar.value = 50 end
		---------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------
		
		sv.tbl = {[1] = sv.minimap, [2] = sv.buffFrame, [3] = sv.playerFrame, [4] = sv.questLog,
		[5] = sv.partyFrame, [6] = sv.actionBar, [7] = sv.fadeDur, [8] = sv.fadeStarts,
		[9] = sv.inventory, [10] = sv.map, [11] = sv.spell, [12] = sv.openTabs,
		[13] = sv.friendlyPlayer, [14] = sv.friendlyNpc, [15] = sv.enemyPlayer, [16] = sv.attackableNpc}
		
		local oldValidateActionBarTransition = ValidateActionBarTransition
		ValidateActionBarTransition = function()
		end
		
		addon.db = sv --saved variables are now in form: addon.db.variable
		ExamplePanel_OnLoad(panel) -- configuration	
		
	hooksecurefunc(_G["InterfaceOptionsFrame"],"Show", function()
		if InCombatLockdown() then
			settingOpen = true
		else
			FadeCanceled = true
			settingOpen = true
			addon.func.cancelFade()
			EventListenerFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
			EventListenerFrame:UnregisterEvent("UNIT_SPELLCAST_SENT")
		end
	end)
	hooksecurefunc(_G["InterfaceOptionsFrame"],"Hide", function()
		addon.func.setEvents(EventListenerFrame)
		settingOpen = false
	end)
		addon.func.setEvents(EventListenerFrame)
		EventListenerFrame:UnregisterEvent("ADDON_LOADED") --UnRegister the addon loaded event when addon has successfully been loaded.
	end
end

--TIMER
local frame = CreateFrame("Frame")
local e = 0
frame:SetScript("OnUpdate", function(self, elapsed) -- function that determines how many times OnUpdate is executed
	e = e + elapsed
	if e >= 0.10 then --call on update every 0.10 sec and when enabled == true.
		e = 0
		if delay <= GetTime() then
			if InCombatLockdown() ~= true and disabled == false and targetTaken ~= true and settingOpen ~= true and next(openedTabsTable) == nil then --set the execution conditionals for the OnUpdate
				FadeCanceled,FadeStarts, FadeDuration = addon.func.onUpdate(FadeCanceled,FadeStarts,FadeDuration)
			end 
		end
	end
end)

--HOOKS
for i = 1, 5 do
	hooksecurefunc(_G["ContainerFrame" .. i],"Show", function() -- Open bag
		if addon.db.inventory.value then	-- if invetory is checked 
			if InCombatLockdown() ~= true then
				FadeCanceled = true
				addon.func.cancelFade()
			end
			table.insert(openedTabsTable, 1, 1)
		end
	end)
	hooksecurefunc(_G["ContainerFrame" .. i],"Hide", function()
		if addon.db.inventory.value then
			table.remove(openedTabsTable)
		end
	end)
end
hooksecurefunc(WorldMapFrame, "Show", function()
	if addon.db.map.value then
		if InCombatLockdown() ~= true then
			FadeCanceled = true
			addon.func.cancelFade()
		end
		table.insert(openedTabsTable, 1, 1)
	end
end)
hooksecurefunc(WorldMapFrame, "Hide", function()
	if addon.db.map.value then
		table.remove(openedTabsTable)
	end
end)
local tbl = {CharacterFrame, SpellBookFrame, } --list uncomplete now
for i = 1, #tbl do
	local frame = tbl[i]
	hooksecurefunc(frame, "Show", function()
		if addon.db.openTabs.value then
				if InCombatLockdown() ~= true then
					FadeCanceled = true
					addon.func.cancelFade()
				end
			table.insert(openedTabsTable, 1, 1)
		end
	end)
	hooksecurefunc(frame, "Hide", function()
		if addon.db.openTabs.value then
			table.remove(openedTabsTable)
		end 
	end)
end
