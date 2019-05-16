IMBAEvents = class({})

function IMBAEvents:DeathMatchRandomOMG(npc)
	npc:SetAbilityPoints(0)
	local abilityName = {}
	for i=0, 23 do
		local ability = npc:GetAbilityByIndex(i)
		if ability then
			abilityName[#abilityName + 1] = ability:GetName()
		end
	end
	for i=1, #abilityName do
		npc:RemoveAllModifiers()
		npc:RemoveAbility(abilityName[i])
	end
	npc:RemoveAllModifiers()
	npc:SetAbilityPoints(npc:GetLevel())
	for i=1, 4 do
		local ability_table = GetRandomAbilityNormal()
		while npc:HasAbility(ability_table[2]) do
			ability_table = GetRandomAbilityNormal()
		end
		PrecacheUnitWithQueue(ability_table[1])
		npc:AddAbility(ability_table[2])
	end
	for i=1, 2 do
		local ability_table = GetRandomAbilityUltimate()
		while npc:HasAbility(ability_table[2]) do
			ability_table = GetRandomAbilityUltimate()
		end
		PrecacheUnitWithQueue(ability_table[1])
		npc:AddAbility(ability_table[2])
	end
	npc:RemoveAllModifiers()
	local max_level = 0
	for i=0, 23 do
		local ability = npc:GetAbilityByIndex(i)
		if ability then
			max_level = max_level + ability:GetMaxLevel()
		end
	end
	if npc:GetLevel() >= max_level then
		for i=0, 23 do
			local ability = npc:GetAbilityByIndex(i)
			if ability then
				ability:SetLevel(ability:GetMaxLevel())
			end
		end
		npc:SetAbilityPoints(0)
	end
end

function IMBAEvents:GiveAKAbility(npc)
	if npc:HasAbility("generic_hidden") and not npc:HasAbility("imba_ogre_magi_multicast") and not npc:HasAbility("imba_storm_spirit_ball_lightning") then
		GameRules:SetSafeToLeave(true)
		local ak = nil
		local ak_name = GetRandomAKAbility()
		while npc:HasAbility(ak_name[2]) do
			ak_name = GetRandomAKAbility()
		end
		npc:AddNewModifier(npc, nil, "modifier_imba_ak_ability_loading", {})
		PrecacheUnitByNameAsync(ak_name[1], function() npc:AddNewModifier(npc, nil, "modifier_imba_ak_ability_adder", {duration = RandomFloat(0.2, 6.0), ability_owner = ak_name[1], ability_name = ak_name[2]}) end, npc:GetPlayerOwnerID())
	else
		local buff = npc:AddNewModifier(npc, nil, "modifier_imba_unlimited_powerup_ak", {})
	end
end

function IMBAEvents:OnHeroKilled(victim, attacker)
	if victim:IsRealHero() and not victim:IsReincarnating() and IsInTable(victim, CDOTA_PlayerResource.IMBA_PLAYER_HERO) then

		if GameRules:GetDOTATime(false, false) >= 1200 then
			GameRules:SetSafeToLeave(true)
		end

		local buff = victim:FindModifierByName("modifier_alchemist_goblins_greed")
		if buff then
			buff:Destroy()
		end

		--Lose Gold
		local maxLoseGold = PlayerResource:GetUnreliableGold(victim:GetPlayerID())
		local netWorth = PlayerResource:GetGoldSpentOnItems(victim:GetPlayerID())
		PlayerResource:ModifyGold(victim:GetPlayerID(), 0 - math.min(maxLoseGold, 50 + netWorth / 40), false, DOTA_ModifyGold_Death)

		--print(victim:GetName(), "respawn time:", respawn_timer, "bb cd:", buyback_cooldown, "bb cost:", buy_back_cost, "lose gold:", math.min(maxLoseGold, 50 + netWorth / 40))

		--Death Streak
		if attacker and IsInTable(attacker, CDOTA_PlayerResource.IMBA_PLAYER_HERO) then
			local line_duration = 7

			local death_player = victim:GetPlayerID()
			local kill_player = attacker:GetPlayerID()
			if death_player and kill_player then
				CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK[death_player + 1] = math.min(CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK[death_player + 1] + 1, 10)
				CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK[kill_player + 1] = 0
				CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[death_player + 1] = 0
				CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[kill_player + 1] = CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[kill_player + 1] + 1

				if CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK[death_player + 1] >= 3 then
					Notifications:BottomToAll({hero = victim:GetName(), duration = line_duration})
					Notifications:BottomToAll({text = PlayerResource:GetPlayerName(death_player).." ", duration = line_duration, continue = true})
					Notifications:BottomToAll({text = "#imba_deathstreak_"..CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK[death_player + 1], duration = line_duration, continue = true})
				end
			end
		end

		if END_GAME_ON_KILLS then
			if GetTeamHeroKills(DOTA_TEAM_GOODGUYS) >= IMBA_KILL_GOAL then
				GAME_WINNER_TEAM = DOTA_TEAM_GOODGUYS
				GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
				GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
				UpDatePlayerInfo()
				IMBA:EndGameAPI(DOTA_TEAM_GOODGUYS)
			elseif GetTeamHeroKills(DOTA_TEAM_BADGUYS) >= IMBA_KILL_GOAL then
				GAME_WINNER_TEAM = DOTA_TEAM_BADGUYS
				GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
				GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
				UpDatePlayerInfo()
				IMBA:EndGameAPI(DOTA_TEAM_BADGUYS)
			end
		end
	end
end

function IMBAEvents:OnRoshanKilled(killed_unit)
	if killed_unit:IsBoss() then
		for i=3, roshan_kill do
			local drop_cheese = CreateItem("item_imba_cheese", nil, nil)
			if drop_cheese then
				CreateItemOnPositionSync(killed_unit:GetAbsOrigin(), drop_cheese)
				drop_cheese:LaunchLoot(false, 100, 0.5, killed_unit:GetAbsOrigin() + RandomVector(100))
			end
		end
		if roshan_kill >= 15 then
			local drop_cheese = CreateItem("item_aegis", nil, nil)
			if drop_cheese then
				CreateItemOnPositionSync(killed_unit:GetAbsOrigin(), drop_cheese)
				drop_cheese:LaunchLoot(false, 100, 0.5, killed_unit:GetAbsOrigin() + RandomVector(100))
			end
		end
		local dummy = CreateModifierThinker(nil, nil, "modifier_dummy_thinker", {duration = CUSTOM_ROSHAN_RESPAWN}, Vector(30000,30000,5000), DOTA_TEAM_NEUTRALS, false)
		local buff = dummy:FindModifierByName("modifier_dummy_thinker")
		buff.OnRemoved = function()
			if IsServer() then
				IMBA:SpawnRoshan()
			end
		end
		--[[Timers:CreateTimer(CUSTOM_ROSHAN_RESPAWN, function()
			IMBA:SpawnRoshan()
			return nil
		end
		)]]
	end
end

LinkLuaModifier("modifier_imba_version_check", "events/imba_events.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_version_check = class({})

function modifier_imba_version_check:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(30.0)
	end
end

function modifier_imba_version_check:OnIntervalThink()
	local buff = self
	local current_version = IMBA_GAME_VERSION
	local new_version = -1
	local function OnGetGameVersion(hRes)
		new_version = tonumber(hRes.Body)
		if new_version > current_version then
			print("game updated")
			EmitGlobalSound("Loot_Drop_Stinger_Immortal")
			Notifications:TopToAll({text="#DOTA_IMBA_GAME_UPDATE_NOTICE", duration = 15, style={["font-size"] = "30px"}})
			Notifications:TopToAll({text="#DOTA_IMBA_GAME_UPDATE_NOTICE", duration = 15, style={["font-size"] = "30px"}})
			Notifications:TopToAll({text="#DOTA_IMBA_GAME_UPDATE_NOTICE", duration = 15, style={["font-size"] = "30px"}})
			Notifications:BottomToAll({text="#DOTA_IMBA_GAME_UPDATE_NOTICE", duration = 15, style={["font-size"] = "30px"}})
			Notifications:BottomToAll({text="#DOTA_IMBA_GAME_UPDATE_NOTICE", duration = 15, style={["font-size"] = "30px"}})
			Notifications:BottomToAll({text="#DOTA_IMBA_GAME_UPDATE_NOTICE", duration = 15, style={["font-size"] = "30px"}})
			buff:StartIntervalThink(-1)
			buff:Destroy()
		end
	end
	IMBA:SendHTTPRequest("imba_request_version.php", {["game"] = "imba"}, nil, OnGetGameVersion)
end

function IMBAEvents:StartIMBAVersionCheck()
	if IsServer() then
		CreateModifierThinker(nil, nil, "modifier_imba_version_check", {}, Vector(30000,30000,5000), DOTA_TEAM_NEUTRALS, false)
	end
end

LinkLuaModifier("modifier_imba_abandon_check", "events/imba_events.lua", LUA_MODIFIER_MOTION_NONE)
--
modifier_imba_abandon_check = class({})

function modifier_imba_abandon_check:OnCreated()
	if IsServer() and not GameRules:IsCheatMode() then
		self:StartIntervalThink(30.0)
	end
end

function modifier_imba_abandon_check:OnIntervalThink()
	if GameRules:State_Get() <= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local total = {}
		total[DOTA_TEAM_GOODGUYS] = 0
		total[DOTA_TEAM_BADGUYS] = 0
		local abandon = {}
		abandon[DOTA_TEAM_GOODGUYS] = 0
		abandon[DOTA_TEAM_BADGUYS] = 0
		for i=1, 24 do
			if CDOTA_PlayerResource.IMBA_PLAYER_HERO[i] then
				local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i]
				total[hero:GetTeamNumber()] = total[hero:GetTeamNumber()] + 1
				if PlayerResource:GetConnectionState(hero:GetPlayerOwnerID()) == DOTA_CONNECTION_STATE_ABANDONED or (hero:IsIdle() and (GameRules:GetGameTime() - hero:GetLastIdleChangeTime() >= 180)) then
					abandon[hero:GetTeamNumber()] = abandon[hero:GetTeamNumber()] + 1
				end
			end
		end
		if abandon[DOTA_TEAM_GOODGUYS] > 0 and abandon[DOTA_TEAM_GOODGUYS] == total[DOTA_TEAM_GOODGUYS] and CDOTAGamerules.IMBA_FORT[DOTA_TEAM_GOODGUYS] then
			CDOTAGamerules.IMBA_FORT[DOTA_TEAM_GOODGUYS]:ForceKill(false)
		end
		if abandon[DOTA_TEAM_BADGUYS] > 0 and abandon[DOTA_TEAM_BADGUYS] == total[DOTA_TEAM_BADGUYS] and CDOTAGamerules.IMBA_FORT[DOTA_TEAM_BADGUYS] then
			CDOTAGamerules.IMBA_FORT[DOTA_TEAM_BADGUYS]:ForceKill(false)
		end
	end
end

function IMBAEvents:StartAbandonCheck()
	if IsServer() then
		CreateModifierThinker(nil, nil, "modifier_imba_abandon_check", {}, Vector(30000,30000,5000), DOTA_TEAM_NEUTRALS, false)
	end
end