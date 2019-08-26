IMBAHeroSelection = IMBAHeroSelection or class({})

function IMBAHeroSelection:SetGameMode(sGamemode)
	if sGamemode == "all_pick" then
		local Pre_Time = IMBA_SELECTION_SHOW_UP_DELAY + 60.0 + HERO_SELECTION_TIME + IMBA_LOADING_DELAY + AP_BAN_TIME_TEAM * 2
		GameRules:SetPreGameTime(Pre_Time)
		CustomNetTables:SetTableValue("imba_hero_selection_list", "pick_mode", {"all_pick"})
		CustomNetTables:SetTableValue("imba_hero_selection_list", "pick_time", {Pre_Time - 60.0 - IMBA_LOADING_DELAY})
		--CustomNetTables:SetTableValue("imba_hero_selection_list", "pick_phase", {"pick_both"})
		CreateModifierThinker(nil, nil, "modifier_imba_selection_ap_show_up", {duration = IMBA_SELECTION_SHOW_UP_DELAY}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
	end
end

LinkLuaModifier("modifier_imba_selection_ap_show_up", "internal/hero_selection_detail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_selection_ap_ban_dire", "internal/hero_selection_detail.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_selection_ap_ban_radiant", "internal/hero_selection_detail.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_selection_ap_show_up = class({})

function modifier_imba_selection_ap_show_up:OnCreated()
	if IsServer() then
		IMBAHeroSelection:ChangeSelectionPhase("set_up")
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_selection_ap_show_up:OnIntervalThink()
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_UpdateTimer", {time = math.ceil(self:GetRemainingTime())})
	GameRules:SetTimeOfDay(0.25)
end

function modifier_imba_selection_ap_show_up:OnDestroy()
	if IsServer() then
		CreateModifierThinker(nil, nil, "modifier_imba_selection_ap_ban_dire", {duration = AP_BAN_TIME_TEAM}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
	end
end

modifier_imba_selection_ap_ban_dire = class({})

function modifier_imba_selection_ap_ban_dire:OnCreated()
	if IsServer() then
		IMBAHeroSelection:ChangeSelectionPhase("ban_dire")
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_selection_ap_ban_dire:OnIntervalThink()
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_UpdateTimer", {time = math.ceil(self:GetRemainingTime())})
	GameRules:SetTimeOfDay(0.25)
end

function modifier_imba_selection_ap_ban_dire:OnDestroy()
	if IsServer() then
		CreateModifierThinker(nil, nil, "modifier_imba_selection_ap_ban_radiant", {duration = AP_BAN_TIME_TEAM}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
	end
end

modifier_imba_selection_ap_ban_radiant = class({})

function modifier_imba_selection_ap_ban_radiant:OnCreated()
	if IsServer() then
		IMBAHeroSelection:ChangeSelectionPhase("ban_radiant")
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_selection_ap_ban_radiant:OnIntervalThink()
	CustomGameEventManager:Send_ServerToAllClients("IMBAHeroSelection_UpdateTimer", {time = math.ceil(self:GetRemainingTime())})
	GameRules:SetTimeOfDay(0.25)
end

function modifier_imba_selection_ap_ban_radiant:OnDestroy()
	if IsServer() then
		IMBAHeroSelection:ChangeSelectionPhase("all_pick")
		CreateModifierThinker(nil, nil, "modifier_imba_hero_selection_timer", {duration = HERO_SELECTION_TIME}, Vector(0,0,0), DOTA_TEAM_NEUTRALS, false)
	end
end
