IMBAHeroSelection = class({})

require("internal/hero_selection_detail")

CustomGameEventManager:RegisterListener("IMBAHeroSelection_PlayerDirtySelectHero", function(...) return IMBAHeroSelection:PlayerDirtySelectHero(...) end)
CustomGameEventManager:RegisterListener("IMBAHeroSelection_PlayerLockHeroIn", function(...) return IMBAHeroSelection:PlayerLockHeroIn(...) end)
CustomGameEventManager:RegisterListener("IMBAHeroSelection_PlayerRandomSelect", function(...) return IMBAHeroSelection:PlayerRandomSelect(...) end)
CustomGameEventManager:RegisterListener("IMBAHeroSelection_PlayerBanHero", function(...) return IMBAHeroSelection:PlayerBanHero(...) end)
CustomGameEventManager:RegisterListener("IMBAHeroSelection_APSuggestHero", function(...) return IMBAHeroSelection:APSuggestHero(...) end)

--HeroList[n][1] hero name
--HeroList[n][2] hero enable

--HeroKV
--HeroKVBase

local IMBA_HEROSELECTION_SELECTED_HERO = {}
local IMBA_HEROSELECTION_BANNED_HERO = {}
local IMBA_HEROSELECTION_TEAM_BANNED = {}

IMBA_HEROLIST = {}
IMBA_HEROLIST_SUM = {}
IMBA_HEROLIST[0] = {} --STR
IMBA_HEROLIST[1] = {} --AGI
IMBA_HEROLIST[2] = {} --INT

function IMBAHeroSelection:Init()
	for i=1, #HeroList do
		if HeroList[i][2] >= 1 then
			local main = IMBAHeroSelection:GetHeroPrimaryAttribute(HeroList[i][1])
			if main == "DOTA_ATTRIBUTE_STRENGTH" then
				IMBA_HEROLIST[0][#IMBA_HEROLIST[0] + 1] = HeroList[i][1]
			elseif main == "DOTA_ATTRIBUTE_AGILITY" then
				IMBA_HEROLIST[1][#IMBA_HEROLIST[1] + 1] = HeroList[i][1]
			elseif main == "DOTA_ATTRIBUTE_INTELLECT" then
				IMBA_HEROLIST[2][#IMBA_HEROLIST[2] + 1] = HeroList[i][1]
			end
		end
	end
	CustomNetTables:SetTableValue("imba_hero_selection_list", "all_pick_str", IMBA_HEROLIST[0])
	CustomNetTables:SetTableValue("imba_hero_selection_list", "all_pick_agi", IMBA_HEROLIST[1])
	CustomNetTables:SetTableValue("imba_hero_selection_list", "all_pick_int", IMBA_HEROLIST[2])
	for i=0, 2 do
		for j=1, #IMBA_HEROLIST[i] do
			local hero_name = IMBA_HEROLIST[i][j]
			IMBA_HEROLIST_SUM[#IMBA_HEROLIST_SUM + 1] = hero_name
			CustomNetTables:SetTableValue("imba_hero_selection_ability", hero_name, IMBAHeroSelection:GetHeroAbility(hero_name))
			CustomNetTables:SetTableValue("imba_hero_selection_talent", hero_name, IMBAHeroSelection:GetHeroTalent(hero_name))
		end
	end
	CustomNetTables:SetTableValue("imba_hero_selection_list", "all_pick_sum", IMBA_HEROLIST_SUM)
	--CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_timer", {duration = -1}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
end

function IMBAHeroSelection:ChangeSelectionPhase(sPhasename)
	CustomNetTables:SetTableValue("imba_hero_selection_list", "pick_phase", {sPhasename})
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_ChangePhase", {})
end

function IMBAHeroSelection:GetSelectionPhase()
	local info = CustomNetTables:GetTableValue("imba_hero_selection_list", "pick_phase")
	if info and info["1"] then
		return info["1"]
	else
		return "no_phase"
	end
end

function IMBAHeroSelection:GetGameMode()
	local info = CustomNetTables:GetTableValue("imba_hero_selection_list", "pick_mode")
	if info and info["1"] then
		return info["1"]
	else
		return "no_mode"
	end
end

function IMBAHeroSelection:GetHeroPrimaryAttribute(sHeroname)
	--DOTA_ATTRIBUTE_AGILITY DOTA_ATTRIBUTE_INTELLECT DOTA_ATTRIBUTE_STRENGTH
	--0 = strength, 1 = agility, 2 = intelligence.
	if HeroKV[sHeroname] and HeroKV[sHeroname]['AttributePrimary'] then
		return HeroKV[sHeroname]['AttributePrimary']
	elseif HeroKVBase[sHeroname] and HeroKVBase[sHeroname]['AttributePrimary'] then
		return HeroKVBase[sHeroname]['AttributePrimary']
	else
		return nil
	end
end

function IMBAHeroSelection:GetHeroAbility(sHeroname)
	local ability_list = {}
	for i=1, 6 do
		if HeroKV[sHeroname] and HeroKV[sHeroname]['Ability'..i] then
			ability_list[i] = HeroKV[sHeroname]['Ability'..i]
		elseif HeroKVBase[sHeroname] and HeroKVBase[sHeroname]['Ability'..i] then
			ability_list[i] = HeroKVBase[sHeroname]['Ability'..i]
		else
			ability_list[i] = "generic_hidden"
		end
	end
	for i=1, 6 do
		if ability_list[i] == "generic_hidden" or ability_list[i] == "imba_riki_tott_true" then
			ability_list[i] = nil
		end
	end
	return ability_list
end

function IMBAHeroSelection:GetHeroTalent(sHeroname)
	local talent_list = {}
	for i=7, 24 do
		local name = nil
		if HeroKV[sHeroname] and HeroKV[sHeroname]['Ability'..i] then
			name = HeroKV[sHeroname]['Ability'..i]
		elseif HeroKVBase[sHeroname] and HeroKVBase[sHeroname]['Ability'..i] then
			name = HeroKVBase[sHeroname]['Ability'..i]
		else
			name = "generic_hidden"
		end
		if string.find(name, "special_bonus_") then
			talent_list[#talent_list + 1] = name
		end
	end
	return talent_list
end

function IMBAHeroSelection:CanHeroBeSelected(sHeroname)
	--[[for i=0, 19 do
		local info = CustomNetTables:GetTableValue("imba_hero_selection_player", "player_hero_selected_"..i)
		if info and info.hero == sHeroname then
			return false
		end
	end]]
	return (not IMBA_HEROSELECTION_SELECTED_HERO[sHeroname] and not IMBA_HEROSELECTION_BANNED_HERO[sHeroname])
end

function IMBAHeroSelection:GetRandomHero()
	local hero_list_net = CustomNetTables:GetTableValue("imba_hero_selection_list", "all_pick_sum")
	local hero_list = {}
	for k,v in pairs(hero_list_net) do
		hero_list[#hero_list + 1] = v
	end
	return RandomFromTable(hero_list)
end

function IMBAHeroSelection:PlayerDirtySelectHero(unused, kv)
	local pID = kv.PlayerID
	local hero = kv.hero
	CustomNetTables:SetTableValue("imba_hero_selection_player", "player_hero_dirty_"..pID, {hero = hero}) --
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_PlayerSelectedHero", {type = "dirty", hero = hero, pID = pID})
end

-------------------------------------------
-------------------------------------------
-------------------------------------------

LinkLuaModifier("modifier_imba_hero_selection_select", "internal/hero_selection.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_hero_selection_select = class({})

function modifier_imba_hero_selection_select:OnCreated(kv)
	if IsServer() then
		local pID = kv.PlayerID
		local info = CustomNetTables:GetTableValue("imba_hero_selection_player", "player_hero_dirty_"..pID)
		if not info or not string.find(IMBAHeroSelection:GetSelectionPhase(), "pick") then
			return
		end
		local hero = info.hero
		if not IMBAHeroSelection:CanHeroBeSelected(hero) then
			return
		end
		IMBA_HEROSELECTION_SELECTED_HERO[hero] = IMBA_HEROSELECTION_SELECTED_HERO[hero] and IMBA_HEROSELECTION_SELECTED_HERO[hero] + 1 or 1
		CustomNetTables:SetTableValue("imba_hero_selection_player", "player_hero_selected_"..pID, {hero = hero})
		CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_PlayerSelectedHero", {type = "select", hero = hero, pID = pID})
		CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_replace_hero", {hero = hero, pID = pID}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
	end
end

function IMBAHeroSelection:PlayerLockHeroIn(unused, kv)
	CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_select", {duration = 1.0, PlayerID = kv.PlayerID}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
end

-------------------------------------------
-------------------------------------------
-------------------------------------------

LinkLuaModifier("modifier_imba_hero_selection_random", "internal/hero_selection.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_hero_selection_random = class({})

function modifier_imba_hero_selection_random:OnCreated(kv)
	if IsServer() then
		local pID = kv.PlayerID
		if CustomNetTables:GetTableValue("imba_hero_selection_player", "player_hero_selected_"..pID) or not string.find(IMBAHeroSelection:GetSelectionPhase(), "pick") then
			return
		end
		local hero = kv.hero
		if not IMBAHeroSelection:CanHeroBeSelected(hero) then
			return
		end
		CustomNetTables:SetTableValue("imba_hero_selection_player", "player_hero_selected_"..pID, {hero = hero})
		if not kv.force then
			CustomNetTables:SetTableValue("imba_hero_selection_player", "player_hero_randomed_"..pID, {hero = hero})
		end
		IMBA_HEROSELECTION_SELECTED_HERO[hero] = IMBA_HEROSELECTION_SELECTED_HERO[hero] and IMBA_HEROSELECTION_SELECTED_HERO[hero] + 1 or 1
		CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_PlayerSelectedHero", {type = "select", hero = hero, pID = pID})
		CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_replace_hero", {hero = hero, pID = pID}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
	end
end

function IMBAHeroSelection:PlayerRandomSelect(unused, kv)
	--[[local hero_list_net = CustomNetTables:GetTableValue("imba_hero_selection_list", "all_pick_sum")
	local hero_list = {}
	for k,v in pairs(hero_list_net) do
		hero_list[#hero_list + 1] = v
	end]]
	local hero = IMBAHeroSelection:GetRandomHero()
	while not IMBAHeroSelection:CanHeroBeSelected(hero) do
		hero = IMBAHeroSelection:GetRandomHero()
	end
	CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_random", {duration = 1.0, PlayerID = kv.PlayerID, force = kv.force, hero = hero}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
end

-------------------------------------------
-------------------------------------------
-------------------------------------------

local ban_time = {}

LinkLuaModifier("modifier_imba_hero_selection_ban", "internal/hero_selection.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_hero_selection_ban = class({})

function modifier_imba_hero_selection_ban:OnCreated(kv)
	if IsServer() then
		if ban_time[GameRules:GetGameTime()] or not string.find(IMBAHeroSelection:GetSelectionPhase(), "ban") then
			return
		end
		ban_time[GameRules:GetGameTime()] = true
		local pID = kv.PlayerID
		local team = PlayerResource:GetTeam(pID)
		IMBA_HEROSELECTION_TEAM_BANNED[team] = IMBA_HEROSELECTION_TEAM_BANNED[team] or 0
		local info = CustomNetTables:GetTableValue("imba_hero_selection_player", "player_hero_dirty_"..pID)
		if not info then
			return
		end
		local hero = info.hero
		if not IMBAHeroSelection:CanHeroBeSelected(hero) then
			return
		end
		if (team ~= DOTA_TEAM_GOODGUYS and IMBAHeroSelection:GetSelectionPhase() == "ban_radiant") or (team ~= DOTA_TEAM_BADGUYS and IMBAHeroSelection:GetSelectionPhase() == "ban_dire") then
			return
		end
		if IMBAHeroSelection:GetGameMode() == "all_pick" and IMBA_HEROSELECTION_TEAM_BANNED[team] >= 2 then
			return
		end
		IMBA_HEROSELECTION_TEAM_BANNED[team] = IMBA_HEROSELECTION_TEAM_BANNED[team] + 1
		IMBA_HEROSELECTION_BANNED_HERO[hero] = true
		local ban_info = CustomNetTables:GetTableValue("imba_hero_selection_list", "banned_hero")
		local new_info = ban_info or {}
		new_info[hero] = true
		CustomNetTables:SetTableValue("imba_hero_selection_list", "banned_hero", new_info)
		CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_PlayerSelectedHero", {type = "ban", hero = hero, pID = pID})
	end
end

function IMBAHeroSelection:PlayerBanHero(unused, kv)
	CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_ban", {duration = 1.0, PlayerID = kv.PlayerID}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
end

-------------------------------------------
-------------------------------------------
-------------------------------------------

local suggest_time = {}
for i=0, 19 do
	suggest_time[i] = {}
end

LinkLuaModifier("modifier_imba_hero_selection_suggest", "internal/hero_selection.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_hero_selection_suggest = class({})

function modifier_imba_hero_selection_suggest:OnCreated(kv)
	if IsServer() then
		local pID = kv.PlayerID
		if suggest_time[pID][GameRules:GetGameTime()] then
			return
		end
		suggest_time[pID][GameRules:GetGameTime()] = true
		local hero = kv.hero
		if not IMBAHeroSelection:CanHeroBeSelected(hero) then
			return
		end
		local hero_name = kv.hero_name
		local info_string = kv.info_string
		local team = PlayerResource:GetTeam(pID)
		local info = CustomNetTables:GetTableValue("imba_hero_selection_list", "ap_suggest_list"..team)
		if not info or (info and not info[hero]) then
			info = info or {}
			info[hero] = true
			local text = string.format(info_string, PlayerResource:GetPlayerName(pID), hero_name)
			GameRules:SendCustomMessage(text, team, 0)
		elseif info and info[hero] then
			info[hero] = nil
		end
		CustomNetTables:SetTableValue("imba_hero_selection_list", "ap_suggest_list"..team, info)
		CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_PlayerSuggestHero", {team = team, hero = hero})
	end
end

function IMBAHeroSelection:APSuggestHero(unused, kv)
	-----------------------
	CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_suggest", {duration = 0, PlayerID = kv.PlayerID, hero = kv.hero, hero_name = kv.hero_name, info_string = kv.info_string}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
	-- Fix for this event is called twice with no idea
	-----------------------
end

-------------------------------------------
-------------------------------------------
-------------------------------------------

function IMBAHeroSelection:EndIMBAHeroSelection()
	for i=0, 19 do
		if PlayerResource:IsValidPlayer(i) then
			local info = CustomNetTables:GetTableValue("imba_hero_selection_player", "player_hero_selected_"..i)
			if not info then
				IMBAHeroSelection:PlayerRandomSelect(nil, {PlayerID = i, force = 1})
			end
		end
	end
	CustomNetTables:SetTableValue("imba_hero_selection_list", "selection_phase_done", {done = true})
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_SelectionDone", {})
end

-------------------------------------------
-------------------------------------------
-------------------------------------------

LinkLuaModifier("modifier_imba_hero_selection_replace_hero", "internal/hero_selection.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_hero_selection_replace_hero = class({})

function modifier_imba_hero_selection_replace_hero:OnCreated(keys)
	if IsServer() then
		self.hero = keys.hero
		self.pID = keys.pID
		self.dummy = PlayerResource:GetSelectedHeroEntity(self.pID)
		if self.dummy and self.dummy:GetUnitName() ~= "npc_dota_hero_dummy_dummy" then
			self:Destroy()
			return
		end
		self:StartIntervalThink(1.0)
		self:OnIntervalThink()
	end
end

function modifier_imba_hero_selection_replace_hero:OnIntervalThink()
	if self:GetStackCount() == 0 then
		if not self.dummy then
			self.dummy = PlayerResource:GetSelectedHeroEntity(self.pID)
		end
		if self.dummy and PlayerResource:GetConnectionState(self.pID) == DOTA_CONNECTION_STATE_CONNECTED or PlayerResource:GetConnectionState(self.pID) == DOTA_CONNECTION_STATE_ABANDONED then
			self.dummy:AddNoDraw()
			self.dummy:AddNewModifier(nil, nil, "modifier_imba_storm_bolt_caster", {})
			PlayerResource:ReplaceHeroWith(self.pID, self.hero, 0, 0)
			self.dummy:RemoveSelf()
			self:SetStackCount(1)
			self:Destroy()
		end
	end
end

function modifier_imba_hero_selection_replace_hero:OnDestroy()
	if IsServer() then
		self.hero = nil
		self.pID = nil
	end
end

LinkLuaModifier("modifier_imba_hero_selection_wait_for_game", "internal/hero_selection.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_hero_selection_wait_for_game = class({})

function modifier_imba_hero_selection_wait_for_game:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_hero_selection_wait_for_game:OnIntervalThink()
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_UpdateTimer", {time = math.ceil(self:GetRemainingTime())})
	GameRules:SetTimeOfDay(0.25)
end

function modifier_imba_hero_selection_wait_for_game:OnDestroy()
	if IsServer() then
		IMBAHeroSelection:EndIMBAHeroSelection()
	end
end

LinkLuaModifier("modifier_imba_hero_selection_timer", "internal/hero_selection.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_hero_selection_timer = class({})

function modifier_imba_hero_selection_timer:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_hero_selection_timer:OnIntervalThink()
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_UpdateTimer", {time = math.ceil(self:GetRemainingTime())})
	GameRules:SetTimeOfDay(0.25)
end

function modifier_imba_hero_selection_timer:OnDestroy()
	if IsServer() then
		IMBAHeroSelection:ChangeSelectionPhase("end_pick")
		CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_wait_for_game", {duration = 10.0}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
		Timers:CreateTimer(5, function()
			Notifications:BottomToAll({text="#imba_introduction_line_01", duration = 2.9})
			return nil
		end
		)
		Timers:CreateTimer(8, function()
			Notifications:BottomToAll({text="#imba_introduction_line_02", duration = 2.9})
			return nil
		end
		)
		Timers:CreateTimer(11, function()
			Notifications:BottomToAll({text="#imba_introduction_line_03", duration = 2.9})
			return nil
		end
		)
		Timers:CreateTimer(14, function()
			Notifications:BottomToAll({text="#imba_introduction_line_04", duration = 10, style={["font-size"] = "30px"}})
			return nil
		end
		)
	end
end
