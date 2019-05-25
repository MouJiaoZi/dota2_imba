require('events/imba_events')

-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.
if CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK == nil then
	CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK = {}
end
if CDOTA_PlayerResource.IMBA_PLAYER_HERO == nil then
	CDOTA_PlayerResource.IMBA_PLAYER_HERO = {}
end
if CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK == nil then
	CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK = {}
end
if CDOTAGamerules.IMBA_TOWER == nil then
	CDOTAGamerules.IMBA_TOWER = {}
	CDOTAGamerules.IMBA_TOWER[DOTA_TEAM_GOODGUYS] = {}
	CDOTAGamerules.IMBA_TOWER[DOTA_TEAM_BADGUYS] = {}
	for i=1, 4 do
		CDOTAGamerules.IMBA_TOWER[DOTA_TEAM_GOODGUYS][i] = {}
		CDOTAGamerules.IMBA_TOWER[DOTA_TEAM_BADGUYS][i] = {}
	end
end
if CDOTAGamerules.IMBA_FORT == nil then
	CDOTAGamerules.IMBA_FORT = {}
end
if CDOTAGamerules.IMBA_COURIER == nil then
	CDOTAGamerules.IMBA_COURIER = {}
	CDOTAGamerules.IMBA_COURIER[DOTA_TEAM_GOODGUYS] = {}
	CDOTAGamerules.IMBA_COURIER[DOTA_TEAM_BADGUYS] = {}
end

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
	-- GetConnectionState values:
	-- 0 - no connection
	-- 1 - bot connected
	-- 2 - player connected
	-- 3 - bot/player disconnected.

	-- Typical keys:
	-- PlayerID: 2
	-- name: Zimberzimber
	-- networkid: [U:1:95496383]
	-- reason: 2
	-- splitscreenplayer: -1
	-- userid: 7
	-- xuid: 76561198055762111

	local playerName = keys.name
	local playerHero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[keys.PlayerID + 1]
	local playerID = keys.PlayerID
	local time = 0
	local max_time = 300
	local line_duration = 7

	if not playerHero then
		return
	end

	Timers:CreateTimer(1.0, function()
		time = time + 1
		if GameRules:State_Get() <= DOTA_GAMERULES_STATE_PRE_GAME or DOTA_GAMERULES_STATE_PRE_GAME >= DOTA_GAMERULES_STATE_POST_GAME then
			return nil
		end
		if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_ABANDONED then
			Notifications:BottomToAll({hero = playerHero:GetName(), duration = line_duration})
			Notifications:BottomToAll({text = playerName.." ", duration = line_duration, continue = true})
			Notifications:BottomToAll({text = "#imba_player_abandon_message", duration = line_duration, style = {color = "DodgerBlue"}, continue = true})
			IMBA:StartGoldShare(playerID)
			GameRules:SetSafeToLeave(true)
			--GameRules:SendCustomMessage("#dota_safe_to_abandon_match_not_scored", 0, 0)
			return nil
		end
		if time >= max_time then
			Notifications:BottomToAll({hero = playerHero:GetName(), duration = line_duration})
			Notifications:BottomToAll({text = playerName.." ", duration = line_duration, continue = true})
			Notifications:BottomToAll({text = "#imba_player_abandon_message", duration = line_duration, style = {color = "DodgerBlue"}, continue = true})
			GameRules:SetSafeToLeave(true)
			return nil
		end
		if PlayerResource:GetConnectionState(playerID) == DOTA_CONNECTION_STATE_CONNECTED then
			Notifications:BottomToAll({hero = playerHero:GetName(), duration = line_duration})
			Notifications:BottomToAll({text = playerName.." ", duration = line_duration, continue = true})
			Notifications:BottomToAll({text = "#imba_player_reconnect_message", duration = line_duration, style = {color = "DodgerBlue"}, continue = true})
			return nil
		end
		return 1.0
	end
	)
end



local selectedHero = {}

local tick = 0
local waitTick = 10
if GameRules:IsCheatMode() then
	waitTick = 3
end

-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
	DebugPrint("[BAREBONES] GameRules State Changed")
	DebugPrintTable(keys)

	local newState = GameRules:State_Get()

	print("Game State:",newState)

	if newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		Timers:CreateTimer(1.0, function()
			PauseGame(false)
			if GameRules:State_Get() > DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
				return nil
			end
			return 1.0
		end
		)
	end

	if newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		IMBA:SendHTTPRequest("imba_new_match.php", {["match_id"] = GameRules:IsCheatMode() and tostring(RandomInt(0, 1000000))..tostring(RandomInt(200, 9000)).."0000000" or GameRules:GetMatchID(), ["map_name"] = GetMapName(), ["player_number"] = (PlayerResource:GetPlayerCountForTeam(2) + PlayerResource:GetPlayerCountForTeam(3)), ["game_version"] = IMBA_GAME_VERSION,})
		if GameRules:IsCheatMode() then
			GameRules:SetSafeToLeave(true)
		end
		Timers:CreateTimer(5, function()
			local function httpprint(res)
				GameRules:SendCustomMessage(res.Body, 0, 0)
			end
			IMBA:SendHTTPRequest(nil, nil, nil, httpprint)
			Notifications:BottomToAll({text="#DOTA_IMBA_WAIT_WARN", duration = 5})
			Notifications:BottomToAll({text="#DOTA_IMBA_WAIT_WARN", duration = 5})
			Notifications:BottomToAll({text="#DOTA_IMBA_WAIT_WARN", duration = 5})
			return nil
		end
		)
	end

	if newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		if IsInToolsMode() and IMBA_DEBUG_AK then
			SendToConsole("say -bot")
		end
		for i=0, 19 do -- force that noob random
			if PlayerResource:IsValidPlayer(i) and not PlayerResource:HasSelectedHero(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
				PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
				PlayerResource:SetCanRepick(i, false)
			end
			CDOTA_PlayerResource.IMBA_PLAYER_DEATH_STREAK[i + 1] = 0
			CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[i + 1] = 0
			if PlayerResource:IsValidPlayer(i) then
				local function setUpIMBADisable(res)
					if res.Body == "1" then
						IMBA_DISABLE_PLAYER[i] = true
						Timers:CreateTimer(1.0, function()
							if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
								Notifications:BottomToAll({text = PlayerResource:GetPlayerName(i).."(ID:"..tostring(PlayerResource:GetSteamID(i))..") ", duration = 20.0})
								Notifications:BottomToAll({text = "#imba_player_banned_message", duration = 20.0, continue = true})
								return nil
							else
								return 1.0
							end
						end
						)
					end
				end
				IMBA:SendHTTPRequest("imba_check_disable.php", {["steamid_64"] = tostring(PlayerResource:GetSteamID(i))}, nil, setUpIMBADisable)
			end
		end
	end

	if newState == DOTA_GAMERULES_STATE_PRE_GAME then--and not GameRules:IsCheatMode() then
		if GetMapName() == "dbii_death_match" then
			GameRules:SetSafeToLeave(true)
			--GameRules:SendCustomMessage("#dota_safe_to_abandon_match_not_scored", 0, 0)
		end
		if USE_CUSTOM_TEAM_COLORS_FOR_PLAYERS then
			for i=0, 23 do
				PlayerResource:SetCustomPlayerColor(i, PLAYER_COLORS[i][1], PLAYER_COLORS[i][2], PLAYER_COLORS[i][3])
			end
		end
		local announce = false
		Timers:CreateTimer({useGameTime = false, endTime = IMBA_LOADING_DELAY, 
			callback = function()
				if tick == 0 then
					if GameRules:IsCheatMode() then
						CreateUnitByName("npc_dota_hero_target_dummy", Vector(-5345,-6549,384), false, nil, nil, DOTA_TEAM_NEUTRALS)
					end
					IMBAEvents:StartIMBAVersionCheck()
					IMBAEvents:StartAbandonCheck()
					local towers = FindUnitsInRadius(0, Vector(0,0,0), nil, 50000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
					for _, tower in pairs(towers) do
						if string.find(tower:GetUnitName(), "_tower1_") then --T1 Tower set
							tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 5.0)
							local ability = tower:AddAbility(RandomFromTable(IMBA_TOWER_ABILITY_1))
							ability:SetLevel(1)
							if (string.find(tower:GetName(), "_top") or string.find(tower:GetName(), "_bot")) and GetMapName() == "dbii_death_match" then
								tower:AddNewModifier(tower, nil, "modifier_dummy_thinker", {})
							end
							table.insert(CDOTAGamerules.IMBA_TOWER[tower:GetTeamNumber()][1], tower)
						end
						if string.find(tower:GetUnitName(), "_tower2_") then --T2 Tower set
							SetCreatureHealth(tower, tower:GetHealth() + 800, true)
							tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 5.0)
							for i=1, 2 do
								local abilityName = RandomFromTable(IMBA_TOWER_ABILITY_2)
								while true do
									if not tower:HasAbility(abilityName) then
										local ability = tower:AddAbility(abilityName)
										ability:SetLevel(2)
										break
									else
										abilityName = RandomFromTable(IMBA_TOWER_ABILITY_2)
									end
								end
							end
							------
							if not string.find(tower:GetUnitName(), "mid") then
								tower:AddNewModifier(tower, nil, "modifier_imba_t2_tower_vision", {})
							end
							table.insert(CDOTAGamerules.IMBA_TOWER[tower:GetTeamNumber()][2], tower)
						end
						if string.find(tower:GetUnitName(), "_tower3_") then --T3 Tower set
							SetCreatureHealth(tower, tower:GetHealth() + 1300, true)
							tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 5.0)
							for i=1, 3 do
								local abilityName = RandomFromTable(IMBA_TOWER_ABILITY_3)
								while true do
									if not tower:HasAbility(abilityName) then
										local ability = tower:AddAbility(abilityName)
										ability:SetLevel(2)
										break
									else
										abilityName = RandomFromTable(IMBA_TOWER_ABILITY_3)
									end
								end
							end
							local abi = tower:AddAbility("imba_tower_healer_protect")
							abi:SetLevel(1)
							table.insert(CDOTAGamerules.IMBA_TOWER[tower:GetTeamNumber()][3], tower)
						end
						if string.find(tower:GetUnitName(), "_tower4") then --T4 Tower set
							SetCreatureHealth(tower, tower:GetHealth() + 2200, true)
							tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 5.0)
							for i=1, 3 do
								local abilityName = RandomFromTable(IMBA_TOWER_ABILITY_4)
								while true do
									if not tower:HasAbility(abilityName) then
										local ability = tower:AddAbility(abilityName)
										ability:SetLevel(3)
										break
									else
										abilityName = RandomFromTable(IMBA_TOWER_ABILITY_4)
									end
								end
							end
							local abi = tower:AddAbility("imba_tower_the_last_line")
							abi:SetLevel(1)
							table.insert(CDOTAGamerules.IMBA_TOWER[tower:GetTeamNumber()][4], tower)
						end
						if string.find(tower:GetUnitName(), "_melee_rax_") then
							tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 5.0)
							SetCreatureHealth(tower, 4000, true)
						end
						if string.find(tower:GetUnitName(), "_range_rax_") then
							tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 5.0)
							SetCreatureHealth(tower, 3200, true)
						end
						if string.find(tower:GetName(), "_fort") then
							if GetMapName() == "dbii_death_match" then
								tower:AddNewModifier(tower, nil, "modifier_imba_base_protect", {})
							end
							CDOTAGamerules.IMBA_FORT[tower:GetTeamNumber()] = tower
							tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 5.0)
						end
						---------------
						--[[if string.find(tower:GetUnitName(), "tower") then
							if tower:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
								tower:SetRangedProjectileName("particles/econ/world/towers/rock_golem/radiant_rock_golem_attack.vpcf")
							else
								tower:SetRangedProjectileName("particles/econ/world/towers/rock_golem/dire_rock_golem_attack.vpcf")
							end
						end]]
					end
				end
				if tick >= 2 and not announce then
					announce = true
					Notifications:BottomToAll({text="#DOTA_IMBA_WAIT_20_SCES", duration = 100})
					Notifications:BottomToAll({text="#DOTA_IMBA_WAIT_WARN", duration = 100})
					Timers:CreateTimer({
						useGameTime = false,
						endTime = waitTick-2, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
						callback = function()
							Notifications:ClearBottomFromAll()
						end
					})
				end
				PauseGame(true)
				tick = tick + 0.1
				if tick < waitTick then
					return 0.1
				else
					PauseGame(false)
					if IMBA_DEBUG_AK then
						Timers:CreateTimer(10, function()
								print(" ")
								print(" ")
								print(" ")
								print(" ")
								SendToServerConsole("dota_launch_custom_game dota_imba_redux dbii_10v10")
								return nil
							end
						)
					end
					--GameMode:ResetCameraForAll()
					return nil
				end
			end
		})

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

function GameMode:ResetCameraForAll()
	for i=0, 19 do -- force that noob random
		if PlayerResource:IsValidPlayer(i) and PlayerResource:HasSelectedHero(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
			Timers:CreateTimer({useGameTime = false, endTime = 10.0,
			callback = function()
					local hero = PlayerResource:GetPlayer(i):GetAssignedHero()
					local cameraDis = 1134
					PlayerResource:SetCameraTarget(i, hero)
					--GameRules:GetGameModeEntity():SetCameraDistanceOverride(cameraDis)
					PlayerResource:SetCameraTarget(i, nil)
					return nil
				end
			})
		end
	end
end

roshan_spawn = false
roshan_pos = Vector(-2464.244629, 2016.373291, 232.000000)
roshan_kill = 0

local monkeyKingFound = false
local courier_num_radiant = 1
local courier_num_dire = 1

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
	DebugPrint("[BAREBONES] NPC Spawned")
	DebugPrintTable(keys)

	local npc = EntIndexToHScript(keys.entindex)

	--Game Start Hero Set
	if npc:IsRealHero() and not npc:IsTempestDouble() and not npc:IsClone() and npc:GetPlayerID() and npc:GetPlayerID() and npc:GetPlayerID() + 1 > 0 and CDOTA_PlayerResource.IMBA_PLAYER_HERO[npc:GetPlayerID() + 1] == nil then
		
		Timers:CreateTimer({useGameTime = false, endTime = FrameTime(),
			callback = function()
				if CDOTA_PlayerResource.IMBA_PLAYER_HERO[npc:GetPlayerID() + 1] == nil then
					CDOTA_PlayerResource.IMBA_PLAYER_HERO[npc:GetPlayerID() + 1] = npc
					CDOTA_PlayerResource.IMBA_PLAYER_HERO[npc:GetPlayerID() + 1].order = 0
				end
				-- Set Talent Ability
				for i = 0, 23 do
					local ability = npc:GetAbilityByIndex(i)
					if ability and ability.IsTalentAbility and ability:IsTalentAbility() then
						ability:SetLevel(1)
					end
				end
				npc:AddExperience(1, 0, false, false)
				npc:AddExperience(-1, 0, false, false)
				HeroItems:SetHeroItemTable(npc)
				for i=0, 10 do
					AddFOWViewer(i, npc:GetAbsOrigin(), 200, FrameTime(), false)
				end
				if GetMapName() ~= "dbii_death_match" and (IMBA_AK_ENABLE or GameRules:IsCheatMode()) then
					IMBAEvents:GiveAKAbility(npc)
				elseif GetMapName() == "dbii_death_match" and (IMBA_OMG_ENABLE or IsInToolsMode()) then
					IMBAEvents:DeathMatchRandomOMG(npc)
				end
				return nil
			end
		})

		npc:AddNewModifier(npc, nil, "modifier_imba_talent_modifier_adder", {})
		npc:AddNewModifier(npc, nil, "modifier_imba_movespeed_controller", {})
		npc:AddNewModifier(npc, nil, "modifier_imba_reapers_scythe_permanent", {})
		npc:AddNewModifier(npc, nil, "modifier_imba_ability_layout_contoroller", {})

		local chicken = npc:AddItemByName("item_courier")
		npc:CastAbilityNoTarget(chicken, npc:GetPlayerID())

		PlayerResource:SetGold(npc:GetPlayerID(), IMBA_STARTING_GOLD, true)

		if PlayerResource:HasRandomed(npc:GetPlayerID()) then
			PlayerResource:SetGold(npc:GetPlayerID(), IMBA_STARTING_GOLD_RANDOM, true)
		end
		
		Timers:CreateTimer(0, function()
			-- a fresh Tp
			local tp = npc:GetTP()
			if tp then
				tp:EndCooldown()
				return nil
			end
			return 0.2
		end
		)

		-- Set up Player infomation
		local pID = npc:GetPlayerOwnerID()
		local player_table = {["player_id"] = pID, ["player_name"] = PlayerResource:GetPlayerName(pID), ["player_team"] = npc:GetTeamNumber(), ["steamid_64"] = PlayerResource:GetSteamID(pID), ["hero_index"] = npc:entindex(), ["hero_name"] = npc:GetUnitName()}
		CustomNetTables:SetTableValue("imba_player_detail", tostring(pID), player_table)

		if IMBA_TEAM_DUMMY_GOOD == nil and npc:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			IMBA_TEAM_DUMMY_GOOD = CreateUnitByName("npc_dummy_unit", npc:GetAbsOrigin(), false, npc, npc, DOTA_TEAM_GOODGUYS)
		end
		if IMBA_TEAM_DUMMY_BAD == nil and npc:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			IMBA_TEAM_DUMMY_BAD = CreateUnitByName("npc_dummy_unit", npc:GetAbsOrigin(), false, npc, npc, DOTA_TEAM_BADGUYS)
		end
	end

	if npc:IsRealHero() and npc.firstSpawn and GetMapName() == "dbii_death_match" and (IMBA_OMG_ENABLE or IsInToolsMode()) then
		IMBAEvents:DeathMatchRandomOMG(npc)
	end

	--Roshan Setup
	if npc:GetName() == "npc_dota_roshan" and not roshan_spawn then
		roshan_spawn = true
		npc:AddNewModifier(npc, nil, "modifier_imba_storm_bolt_caster", {})
		npc:SetAbsOrigin(Vector(40000,40000,-40000))
		Timers:CreateTimer(2.0, function()
			IMBA:SpawnRoshan()
			return nil
		end
		)
	end

	--Courier Setup
	if npc:IsCourier() and npc:HasAbility("imba_courier_speed") then
		npc:FindAbilityByName("imba_courier_speed"):SetLevel(1)
		if npc:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			npc.courier_num = courier_num_radiant
			courier_num_radiant = courier_num_radiant + 1
		elseif npc:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			npc.courier_num = courier_num_dire
			courier_num_dire = courier_num_dire + 1
		end
		table.insert(CDOTAGamerules.IMBA_COURIER[npc:GetTeamNumber()], npc)
	end

	--modifier_imba_unlimited_level_powerup
	if npc:IsHero() and not npc.firstSpawn then
		npc:AddNewModifier(npc, nil, "modifier_imba_unlimited_level_powerup", {})
	end

	if not npc.firstSpawn then
		npc.firstSpawn = true
		npc.splitattack = true
		--[[if npc:IsCourier() then
			npc:SetControllableByPlayer(-1, true)
		end]]
	end

	if npc:GetUnitName() == "npc_dota_hero_silencer" and not npc:HasModifier("modifier_imba_silencer_int_steal") then
		local duration = 1500
		if GetMapName() == "dbii_5v5" then
			duration = 2500
		end
		npc:AddNewModifier(npc, nil, "modifier_imba_silencer_int_steal", {duration = duration})
	end

	if npc:IsNeutralUnitType() then
		npc:SetDeathXP(npc:GetDeathXP() * 2)
		npc:SetMinimumGoldBounty(npc:GetMinimumGoldBounty() * 1.3)
		npc:SetMaximumGoldBounty(npc:GetMaximumGoldBounty() * 1.3)
	end

	if npc:IsOther() and (npc:GetUnitName() == "npc_dota_observer_wards" or npc:GetUnitName() == "npc_dota_sentry_wards") then
		if not IMBA_WARD_TABLE[npc:GetCreationTime()] then
			IMBA_WARD_TABLE[npc:GetCreationTime()] = {}
		end
		IMBA_WARD_TABLE[npc:GetCreationTime()]["ward"] = npc
		HeroItems:ApplyWardsParticle(npc:GetCreationTime())
	end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
	--DebugPrint("[BAREBONES] Entity Hurt")
	--DebugPrintTable(keys)

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless
	if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
		local attacker = EntIndexToHScript(keys.entindex_attacker)
		local target = EntIndexToHScript(keys.entindex_killed)

		-- The ability/item used to damage, or nil if not damaged by an item/ability
		local ability = nil

		if keys.entindex_inflictor ~= nil then
			ability = EntIndexToHScript( keys.entindex_inflictor )
		end
	end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
	DebugPrint( '[BAREBONES] OnItemPickedUp' )
	DebugPrintTable(keys)

	local unitEntity = nil
	if keys.UnitEntitIndex then
		unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
	elseif keys.HeroEntityIndex then
		unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
	end

	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
	DebugPrint( '[BAREBONES] OnPlayerReconnect' )
	DebugPrintTable(keys) 

	local player_id = keys.PlayerID
	local playerHero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[keys.PlayerID + 1]

	
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
	DebugPrint( '[BAREBONES] OnItemPurchased' )
	DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname 
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
	DebugPrint('[BAREBONES] AbilityUsed')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityname = keys.abilityname

	if abilityname == "item_ward_observer" or abilityname == "item_ward_dispenser" or abilityname == "item_ward_sentry" then
		if not IMBA_WARD_TABLE[GameRules:GetGameTime()] then
			IMBA_WARD_TABLE[GameRules:GetGameTime()] = {}
		end
		IMBA_WARD_TABLE[GameRules:GetGameTime()]["player_id"] = keys.PlayerID
	end
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
	DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
	DebugPrintTable(keys)

	local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
	DebugPrint('[BAREBONES] OnPlayerChangedName')
	DebugPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
	DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
	DebugPrintTable(keys)
	--[[
	PlayerID: 0
	abilityname: imba_axe_berserkers_call
	player: 1
	splitscreenplayer: -1
	]]

	local pID = keys.PlayerID
	local abilityname = keys.abilityname
	local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[pID + 1]
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
	DebugPrint('[BAREBONES] OnAbilityChannelFinished')
	DebugPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
	DebugPrint('[BAREBONES] OnPlayerLevelUp')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	if not player then
		return
	end

	local level = keys.level
	local hero = player:GetAssignedHero()
	local hero_level = hero:GetLevel()

	hero:SetCustomDeathXP(HERO_XP_BOUNTY_PER_LEVEL[hero_level])
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
	DebugPrint('[BAREBONES] OnLastHit')
	DebugPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
	DebugPrint('[BAREBONES] OnTreeCut')
	DebugPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
	DebugPrint('[BAREBONES] OnRuneActivated')
	DebugPrintTable(keys)
	--PrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune

	if rune == DOTA_RUNE_ILLUSION then
		IMBA:PlayerPickUpIllusionRune(player)
	end


	--[[ Rune Can be one of the following types
	DOTA_RUNE_DOUBLEDAMAGE
	DOTA_RUNE_HASTE
	DOTA_RUNE_HAUNTED
	DOTA_RUNE_ILLUSION
	DOTA_RUNE_INVISIBILITY
	DOTA_RUNE_BOUNTY
	DOTA_RUNE_MYSTERY
	DOTA_RUNE_RAPIER
	DOTA_RUNE_REGENERATION
	DOTA_RUNE_SPOOKY
	DOTA_RUNE_TURBO
	]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
	DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
	DebugPrint('[BAREBONES] OnPlayerPickHero')
	DebugPrintTable(keys)

	local heroClass = keys.hero
	local heroEntity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
	DebugPrint('[BAREBONES] OnTeamKillCredit')
	DebugPrintTable(keys)
	--PrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber
end

-- An entity died
function GameMode:OnEntityKilled( keys )
	DebugPrint( '[BAREBONES] OnEntityKilled Called' )
	DebugPrintTable( keys )
	--[[
	damagebits: 0
	entindex_attacker: 866
	entindex_inflictor: 866
	entindex_killed: 866
	splitscreenplayer: -1
	]]

	-- The Unit that was Killed
	local killed_unit = EntIndexToHScript( keys.entindex_killed )

	local victim = killed_unit

	if noDamageFilterUnits[victim:GetName()] then
		return
	end

	-- The Killing entity
	local killer = nil

	if keys.entindex_attacker ~= nil then
		killer = EntIndexToHScript( keys.entindex_attacker )
	end

	local attacker = killer

	-- The ability/item used to kill, or nil if not killed by an item/ability
	local ability = nil

	if keys.entindex_inflictor ~= nil then
		ability = EntIndexToHScript( keys.entindex_inflictor )
	end

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	-------------------------------------------------------------------------------------------------
	-- IMBA: Hero Kill
	-------------------------------------------------------------------------------------------------

	if victim:IsRealHero() then
		--IMBAEvents:OnHeroKilled(victim, attacker)
		xpcall((IMBAEvents:OnHeroKilled(victim, attacker)), function (msg) return msg..'\n'..debug.traceback()..'\n' end)
	end

	-------------------------------------------------------------------------------------------------
	-- IMBA: Roshan
	-------------------------------------------------------------------------------------------------

	if killed_unit:IsBoss() then
		--IMBAEvents:OnRoshanKilled(killed_unit)
		xpcall((IMBAEvents:OnRoshanKilled(killed_unit)), function (msg) return msg..'\n'..debug.traceback()..'\n' end)
	end

	-------------------------------------------------------------------------------------------------
	-- IMBA: Lion ult refresh
	-------------------------------------------------------------------------------------------------

	local function FingerOfDeathKillCredit(ability, killed_unit)
		if ability and ability:GetName() == "imba_lion_finger_of_death" and ability.KillCredit then
			ability:KillCredit(killed_unit)
			if ability:GetCaster() and HeroItems:UnitHasItem(ability:GetCaster(), "lion_ti8") then
				local pfx_target = ParticleManager:CreateParticle("particles/econ/items/lion/lion_ti8/lion_spell_finger_death_arcana.vpcf", PATTACH_ABSORIGIN, killed_unit)
				ParticleManager:SetParticleControlEnt(pfx_target, 0, killed_unit, PATTACH_ABSORIGIN, nil, killed_unit:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx_target, 1, killed_unit, PATTACH_ABSORIGIN, nil, killed_unit:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(pfx_target)
			end
		end
	end

	if ability and ability:GetName() == "imba_lion_finger_of_death" and ability.KillCredit then
		--FingerOfDeathKillCredit(ability, killed_unit)
		xpcall((FingerOfDeathKillCredit(ability, killed_unit)), function (msg) return msg..'\n'..debug.traceback()..'\n' end)
	end

	-------------------------------------------------------------------------------------------------
	-- IMBA: Necrolyte Reapers Scythe Permanent Debuff
	-------------------------------------------------------------------------------------------------

	local function ReapersScytheKillCredit(ability, killed_unit)
		if ability and ability:GetName() == "imba_necrolyte_reapers_scythe" and killed_unit:IsRealHero() then
			local buff = killed_unit:FindModifierByName("modifier_imba_reapers_scythe_permanent")
			if buff then
				buff:SetStackCount(buff:GetStackCount() + 1)
			end
			if ability:GetCaster():HasScepter() then
				local allies = FindUnitsInRadius(ability:GetCaster():GetTeamNumber(), killed_unit:GetAbsOrigin(), nil, ability:GetSpecialValueFor("sadist_aoe_scepter"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				local sadist = ability:GetCaster():FindAbilityByName("necrolyte_heartstopper_aura")
				if sadist and sadist:GetLevel() > 0 then
					for i=1, #allies do
						if allies[i] ~= ability:GetCaster() then
							for j=1, ability:GetSpecialValueFor("stacks_scepter") do
								allies[i]:AddNewModifier(ability:GetCaster(), sadist, "modifier_imba_reapers_scythe_scepter_ally_remover", {duration = sadist:GetSpecialValueFor("regen_duration")})
								local buff = allies[i]:AddNewModifier(ability:GetCaster(), sadist, "modifier_necrolyte_heartstopper_aura_counter", {duration = sadist:GetSpecialValueFor("regen_duration")})
								buff:SetStackCount(buff:GetStackCount() + 1)
							end
						end
					end
				end
			end
		end
	end

	if ability and ability:GetName() == "imba_necrolyte_reapers_scythe" and killed_unit:IsRealHero() then
		--ReapersScytheKillCredit(ability, killed_unit)
		xpcall((ReapersScytheKillCredit(ability, killed_unit)), function (msg) return msg..'\n'..debug.traceback()..'\n' end)
	end

	-------------------------------------------------------------------------------------------------
	-- IMBA: Antimage Mana Void Scepter Effect
	-------------------------------------------------------------------------------------------------

	local function ManaVoidKillCredit(ability, killed_unit)
		if ability and ability:GetAbilityName() == "imba_antimage_mana_void" and killed_unit:IsRealHero() then
			CreateModifierThinker(killed_unit, ability, "modifier_imba_mana_void_scepter", {},  Vector(30000,30000,5000), ability:GetCaster():GetTeamNumber(), false)
		end
	end

	if ability and ability:GetName() == "imba_antimage_mana_void" and killed_unit:IsRealHero() and ability:GetCaster():HasScepter() then
		xpcall((ManaVoidKillCredit(ability, killed_unit)), function (msg) return msg..'\n'..debug.traceback()..'\n' end)
	end

	-------------------------------------------------------------------------------------------------
	-- IMBA: Ancient destruction detection
	-------------------------------------------------------------------------------------------------

	if killed_unit.GetUnitName and killed_unit:GetUnitName() == "npc_dota_badguys_fort" then
		GAME_WINNER_TEAM = DOTA_TEAM_GOODGUYS
		GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
		GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		UpDatePlayerInfo()
		IMBA:EndGameAPI(DOTA_TEAM_GOODGUYS)
	elseif killed_unit.GetUnitName and killed_unit:GetUnitName() == "npc_dota_goodguys_fort" then
		GAME_WINNER_TEAM = DOTA_TEAM_BADGUYS
		GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		UpDatePlayerInfo()
		IMBA:EndGameAPI(DOTA_TEAM_BADGUYS)
	end

end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
	DebugPrint('[BAREBONES] PlayerConnect')
	DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
	DebugPrint('[BAREBONES] OnConnectFull')
	DebugPrintTable(keys)
	
	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)
	
	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
	DebugPrint('[BAREBONES] OnIllusionsCreated')
	DebugPrintTable(keys)
	PrintTable(keys)

	local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
	DebugPrint('[BAREBONES] OnItemCombined')
	DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end
	local player = PlayerResource:GetPlayer(plyID)

	-- The name of the item purchased
	local itemName = keys.itemname 
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
	DebugPrint('[BAREBONES] OnAbilityCastBegins')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
	DebugPrint('[BAREBONES] OnTowerKill')
	DebugPrintTable(keys)

	local gold = keys.gold
	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local tower_team = keys.teamnumber

	-- Display upgrade message and play ominous sound
	if tower_team == DOTA_TEAM_GOODGUYS then
		Notifications:BottomToAll({text = "#tower_abilities_radiant_upgrade", duration = 7, style = {color = "DodgerBlue"}})
		EmitGlobalSound("powerup_01")
	else
		Notifications:BottomToAll({text = "#tower_abilities_dire_upgrade", duration = 7, style = {color = "DodgerBlue"}})
		EmitGlobalSound("powerup_02")
	end
	UpgradeTower(tower_team)

	-- Refresh TP
	for i=1, 24 do
		if CDOTA_PlayerResource.IMBA_PLAYER_HERO[i] then
			local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i]
			if hero:GetTeamNumber() == tower_team then
				local tp = hero:GetTP()
				if tp then
					tp:EndCooldown()
				end
			end
		end
	end
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
	DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.player_id)
	local success = (keys.success == 1)
	local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
	DebugPrint('[BAREBONES] OnNPCGoalReached')
	DebugPrintTable(keys)

	local goalEntity = EntIndexToHScript(keys.goal_entindex)
	local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
	local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
	--[[
	playerid: 0
	splitscreenplayer: -1
	teamonly: 1
	text: 12
	userid: 1
	]]
	local teamonly = keys.teamonly
	local pID = keys.playerid
	local playerHero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[pID + 1]
	local text = keys.text

	if not (string.byte(text) == 45) then
		return nil
	end

	for str in string.gmatch(text, "%S+") do
		if str == "-blink" then
			local color = {}
			for color_num in string.gmatch(text, "%S+") do
				local colorRGB = tonumber(color_num)
				if colorRGB and playerHero and colorRGB == -1 then
					playerHero.blinkcolor = nil
				end
				if colorRGB and playerHero and colorRGB >= 0 and colorRGB <= 255 then
					color[#color + 1] = colorRGB
					if #color >= 3 then
						playerHero.blinkcolor = Vector(color[1], color[2], color[3])
						break
					end
				end
			end
		end
		if GameRules:IsCheatMode() then
			if str == "-dummy" then
				if playerHero then
					local dummy = CreateUnitByName("npc_dota_hero_target_dummy", playerHero:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
					FindClearSpaceForUnit(dummy, dummy:GetAbsOrigin(), true)
				end
			end
			if str == "-bot" then
				GameRules:BotPopulate()
			end
		end
		if IsInToolsMode() then
			if str == "-illunique" then
				IllusionManager:PrintIllusionUnique()
			end
			if str == "-illcommon" then
				IllusionManager:PrintIllusionCommon()
			end
			if str == "-checkak" then
				CheckRandomAbilityKV()
			end
			if str == "-api" then
				local function httpprint(res)
					for k, v in pairs(res) do
						print(k, v)
					end
				end
				IMBA:SendHTTPRequest(nil, nil, nil, httpprint)
			end
		end
	end

end