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
	local level_info = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..npc:GetPlayerOwnerID())
	--if not level_info or (level_info and level_info['penalize'] == "0") then
		if npc:HasAbility("generic_hidden") and not npc:HasAbility("imba_ogre_magi_multicast") and not npc:HasAbility("imba_storm_spirit_ball_lightning") then
			GameRules:SetSafeToLeave(true)
			local ak_name = GetRandomAKAbility()
			while npc:HasAbility(ak_name[2]) or (not npc:IsRangedAttacker() and (ak_name[2] == "dragon_knight_elder_dragon_form" or ak_name[2] == "terrorblade_metamorphosis")) do
				ak_name = GetRandomAKAbility()
			end
			npc:AddNewModifier(npc, nil, "modifier_imba_ak_ability_loading", {})
			PrecacheUnitByNameAsync(ak_name[1], function() npc:AddNewModifier(npc, nil, "modifier_imba_ak_ability_adder", {duration = RandomFloat(0.2, 6.0), ability_owner = ak_name[1], ability_name = ak_name[2]}) end, npc:GetPlayerOwnerID())
		else
			local buff = npc:AddNewModifier(npc, nil, "modifier_imba_unlimited_powerup_ak", {})
		end
	--end
end

function IMBAEvents:OnHeroKilled(victim, attacker)
	if victim:IsTrueHero() and not victim:IsReincarnating() and IsInTable(victim, CDOTA_PlayerResource.IMBA_PLAYER_HERO) then

		if GameRules:GetDOTATime(false, false) >= 1200 then
			GameRules:SetSafeToLeave(true)
		end

		local buff = victim:FindModifierByName("modifier_alchemist_goblins_greed")
		if buff then
			buff:Destroy()
		end

		--Lose Gold
		local maxLoseGold = PlayerResource:GetUnreliableGold(victim:GetPlayerOwnerID())
		local netWorth = PlayerResource:GetGoldSpentOnItems(victim:GetPlayerOwnerID())
		PlayerResource:ModifyGold(victim:GetPlayerOwnerID(), 0 - math.min(maxLoseGold, 50 + netWorth / 40), false, DOTA_ModifyGold_Death)

		--Death Streak
		if attacker and CDOTA_PlayerResource.IMBA_PLAYER_HERO[attacker:GetPlayerOwnerID() + 1] then
			local line_duration = 7

			local death_player = victim:GetPlayerOwnerID()
			local kill_player = attacker:GetPlayerOwnerID()
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

LinkLuaModifier("modifier_imba_roshan_spawn_timer", "events/imba_events.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_roshan_spawn_timer = class({})

function modifier_imba_roshan_spawn_timer:OnDestroy()
	if IsServer() then
		IMBA:SpawnRoshan()
	end
end

function IMBAEvents:OnRoshanKilled(killed_unit)
	if killed_unit:IsBoss() then
		if roshan_kill >= 15 then
			local drop_cheese = CreateItem("item_aegis", nil, nil)
			if drop_cheese then
				CreateItemOnPositionSync(killed_unit:GetAbsOrigin(), drop_cheese)
				drop_cheese:LaunchLoot(false, 100, 0.5, killed_unit:GetAbsOrigin() + RandomVector(100))
			end
		end
		CreateModifierThinker(nil, nil, "modifier_imba_roshan_spawn_timer", {duration = CUSTOM_ROSHAN_RESPAWN}, Vector(30000,30000,5000), DOTA_TEAM_NEUTRALS, false)
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
		if not new_version then
			return
		end
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

function IMBAEvents:PlayerSpawnsWard(hWard)
	local campname = hWard:GetTeamNumber() == DOTA_TEAM_GOODGUYS and "neutralcamp_good" or "neutralcamp_evil"
	local trigger = Entities:FindAllByClassnameWithin("trigger_multiple", hWard:GetAbsOrigin(), 50)
	for i=1, #trigger do
		if string.find(trigger[i]:GetName(), campname) then
			hWard:SetHealth(1)
			break
		end
	end
end

function IMBAEvents:NormalIllusionCreated(fGameTime, hBaseUnit)
	local all = Entities:FindAllByName(hBaseUnit:GetName())
	for i=1, #all do
		local unit = all[i]
		if unit:IsIllusion() then
			local buff = unit:FindModifierByName("modifier_illusion")
			if buff and buff:GetCreationTime() == fGameTime then
				if hBaseUnit:GetModifierStackCount("modifier_imba_moon_shard_consume", nil) > 0 then
					unit:AddNewModifier(hBaseUnit, nil, "modifier_imba_moon_shard_consume", {}):SetStackCount(hBaseUnit:GetModifierStackCount("modifier_imba_moon_shard_consume", nil))
				end
			end
			if hBaseUnit:HasModifier("modifier_imba_consumable_scepter_consumed") then
				unit:AddNewModifier(hBaseUnit, nil, "modifier_imba_consumable_scepter_consumed", {})
			end
		end
	end
end

function IMBAEvents:SetTowerAbility(hTowerTable)
	local safeAbilities = {}
	local midAbilities = {}
	local dangerousAbilities = {}
	local fortAbilities1 = {}
	local fortAbilities2 = {}
	for i=1, 3 do
		safeAbilities[i] = {}
		midAbilities[i] = {}
		dangerousAbilities[i] = {}
	end
	for i=1, 3 do
		local newAbility = RandomFromTable(IMBA_TOWER_ABILITY_1)
		while IsInTable(newAbility, safeAbilities[1]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_1)
		end
		safeAbilities[1][#safeAbilities[1] + 1] = newAbility
		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_1)
		while IsInTable(newAbility, midAbilities[1]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_1)
		end
		midAbilities[1][#midAbilities[1] + 1] = newAbility
		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_1)
		while IsInTable(newAbility, dangerousAbilities[1]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_1)
		end
		dangerousAbilities[1][#dangerousAbilities[1] + 1] = newAbility

		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_2)
		while IsInTable(newAbility, safeAbilities[2]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_2)
		end
		safeAbilities[2][#safeAbilities[2] + 1] = newAbility
		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_2)
		while IsInTable(newAbility, midAbilities[2]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_2)
		end
		midAbilities[2][#midAbilities[2] + 1] = newAbility
		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_2)
		while IsInTable(newAbility, dangerousAbilities[2]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_2)
		end
		dangerousAbilities[2][#dangerousAbilities[2] + 1] = newAbility

		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_3)
		while IsInTable(newAbility, safeAbilities[3]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_3)
		end
		safeAbilities[3][#safeAbilities[3] + 1] = newAbility
		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_3)
		while IsInTable(newAbility, midAbilities[3]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_3)
		end
		midAbilities[3][#midAbilities[3] + 1] = newAbility
		newAbility = RandomFromTable(IMBA_TOWER_ABILITY_3)
		while IsInTable(newAbility, dangerousAbilities[3]) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_3)
		end
		dangerousAbilities[3][#dangerousAbilities[3] + 1] = newAbility
	end
	for i=1, 6 do
		local newAbility = RandomFromTable(IMBA_TOWER_ABILITY_4)
		while IsInTable(newAbility, fortAbilities1) or IsInTable(newAbility, fortAbilities2) do
			newAbility = RandomFromTable(IMBA_TOWER_ABILITY_4)
		end
		if #fortAbilities1 < 3 then
			fortAbilities1[#fortAbilities1 + 1] = newAbility
		else
			fortAbilities2[#fortAbilities2 + 1] = newAbility
		end
	end
	
	local goodFortTower = {}
	local badFortTower = {}
	for i=1, #hTowerTable do
		local tower = hTowerTable[i]
		local safe = true
		if (tower:GetTeamNumber() == DOTA_TEAM_GOODGUYS and string.find(tower:GetUnitName(), "_top")) or (tower:GetTeamNumber() == DOTA_TEAM_BADGUYS and string.find(tower:GetUnitName(), "_bot")) then
			safe = false
		end
		if string.find(tower:GetUnitName(), "_tower1_") then
			if string.find(tower:GetUnitName(), "mid") then
				tower:AddAbility(midAbilities[1][1]):SetLevel(1)
				tower:AddAbility(midAbilities[1][2])
				tower:AddAbility(midAbilities[1][3])
			else
				if safe then
					tower:AddAbility(safeAbilities[1][1]):SetLevel(1)
					tower:AddAbility(safeAbilities[1][2])
					tower:AddAbility(safeAbilities[1][3])
				else
					tower:AddAbility(safeAbilities[1][1]):SetLevel(1)
					tower:AddAbility(safeAbilities[1][2])
					tower:AddAbility(safeAbilities[1][3])
				end
			end
		elseif string.find(tower:GetUnitName(), "_tower2_") then
			if string.find(tower:GetUnitName(), "mid") then
				tower:AddAbility(midAbilities[2][1]):SetLevel(2)
				tower:AddAbility(midAbilities[2][2]):SetLevel(2)
				tower:AddAbility(midAbilities[2][3])
			else
				if safe then
					tower:AddAbility(safeAbilities[2][1]):SetLevel(2)
					tower:AddAbility(safeAbilities[2][2]):SetLevel(2)
					tower:AddAbility(safeAbilities[2][3])
				else
					tower:AddAbility(safeAbilities[2][1]):SetLevel(2)
					tower:AddAbility(safeAbilities[2][2]):SetLevel(2)
					tower:AddAbility(safeAbilities[2][3])
				end
			end
		elseif string.find(tower:GetUnitName(), "_tower3_") then
			if string.find(tower:GetUnitName(), "mid") then
				tower:AddAbility(midAbilities[3][1]):SetLevel(3)
				tower:AddAbility(midAbilities[3][2]):SetLevel(3)
				tower:AddAbility(midAbilities[3][3]):SetLevel(3)
			else
				if safe then
					tower:AddAbility(safeAbilities[3][1]):SetLevel(3)
					tower:AddAbility(safeAbilities[3][2]):SetLevel(3)
					tower:AddAbility(safeAbilities[3][3]):SetLevel(3)
				else
					tower:AddAbility(safeAbilities[3][1]):SetLevel(3)
					tower:AddAbility(safeAbilities[3][2]):SetLevel(3)
					tower:AddAbility(safeAbilities[3][3]):SetLevel(3)
				end
			end
		elseif string.find(tower:GetUnitName(), "_tower4") then
			if tower:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
				goodFortTower[#goodFortTower + 1] = tower
			else
				badFortTower[#badFortTower + 1] = tower
			end
		end
	end
	for i=1, 2 do
		if i == 1 then
			goodFortTower[i]:AddAbility(fortAbilities1[1]):SetLevel(3)
			goodFortTower[i]:AddAbility(fortAbilities1[2]):SetLevel(3)
			goodFortTower[i]:AddAbility(fortAbilities1[3]):SetLevel(3)
			badFortTower[i]:AddAbility(fortAbilities1[1]):SetLevel(3)
			badFortTower[i]:AddAbility(fortAbilities1[2]):SetLevel(3)
			badFortTower[i]:AddAbility(fortAbilities1[3]):SetLevel(3)
		else
			goodFortTower[i]:AddAbility(fortAbilities2[1]):SetLevel(3)
			goodFortTower[i]:AddAbility(fortAbilities2[2]):SetLevel(3)
			goodFortTower[i]:AddAbility(fortAbilities2[3]):SetLevel(3)
			badFortTower[i]:AddAbility(fortAbilities2[1]):SetLevel(3)
			badFortTower[i]:AddAbility(fortAbilities2[2]):SetLevel(3)
			badFortTower[i]:AddAbility(fortAbilities2[3]):SetLevel(3)
		end
	end
end