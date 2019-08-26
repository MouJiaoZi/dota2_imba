IMBA = class({})

require('libraries/json')


--[[
0: Str to Damage
1: Str to Health
2: Str to Hp Regen Pct
4: Unknown
5: Str to Magical Resistance
6: Agi to Damage
7: Agi to Physical Armor
8: Agi to AS
9: Agi to MS
10 Int to Damage
11 Int to Mana
12 Int to Mana Regen Pct
13 Int to Spell AMP


]]

function IMBA:OnAllPlayersLoaded()

	CreateEmptyTalents("invoker")

	--GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(IMBA, "AbilityValueFilter"), self)
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(IMBA, "BountyRuneFilter"), self)
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(IMBA, "DamageFilter"), self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(IMBA, "OrderFilter"), self)
	GameRules:GetGameModeEntity():SetHealingFilter(Dynamic_Wrap(IMBA, "HealFilter"), self)
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(IMBA, "ItemPickFilter"), self)
	GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(IMBA, "ModifierAddFilter"), self)
	GameRules:GetGameModeEntity():SetModifyExperienceFilter(Dynamic_Wrap(IMBA, "ExpFilter"), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(IMBA, "GoldFilter"), self)
	GameRules:GetGameModeEntity():SetRuneSpawnFilter(Dynamic_Wrap(IMBA, "RuneSpawnFilter"), self)
	--GameRules:GetGameModeEntity():SetTrackingProjectileFilter(Dynamic_Wrap(IMBA, "TrackingProjectileFilter"), self)

	IMBALevelRewards:LoadAllPlayersLevel()

end

--[[function IMBA:DumpAllHero()
	for i=1, #HeroList do
		if HeroList[i][2] >= 1 then
			--PrecacheUnitWithQueue(HeroList[i][1])
			local main = GetHeroMainAttr(HeroList[i][1]) 
			if main == "DOTA_ATTRIBUTE_STRENGTH" then
				IMBA_HEROLIST_STR[#IMBA_HEROLIST_STR + 1] = HeroList[i][1]
			elseif main == "DOTA_ATTRIBUTE_AGILITY" then
				IMBA_HEROLIST_AGI[#IMBA_HEROLIST_AGI + 1] = HeroList[i][1]
			elseif main == "DOTA_ATTRIBUTE_INTELLECT" then
				IMBA_HEROLIST_INT[#IMBA_HEROLIST_INT + 1] = HeroList[i][1]
			end
		end
	end

	local player_num = CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] + CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]
	for i=1, player_num do
		local hero = RandomFromTable(IMBA_HEROLIST_STR)
		while IsInTable(hero, IMBA_PICKLIST_STR) do
			hero = RandomFromTable(IMBA_HEROLIST_STR)
		end
		IMBA_PICKLIST_STR[i] = hero
	end
	for i=1, player_num do
		local hero = RandomFromTable(IMBA_HEROLIST_AGI)
		while IsInTable(hero, IMBA_PICKLIST_AGI) do
			hero = RandomFromTable(IMBA_HEROLIST_AGI)
		end
		IMBA_PICKLIST_AGI[i] = hero
	end
	for i=1, player_num do
		local hero = RandomFromTable(IMBA_HEROLIST_INT)
		while IsInTable(hero, IMBA_PICKLIST_INT) do
			hero = RandomFromTable(IMBA_HEROLIST_INT)
		end
		IMBA_PICKLIST_INT[i] = hero
	end
	CustomNetTables:SetTableValue("imba_hero_selection_list", "str", IMBA_PICKLIST_STR)
	CustomNetTables:SetTableValue("imba_hero_selection_list", "agi", IMBA_PICKLIST_AGI)
	CustomNetTables:SetTableValue("imba_hero_selection_list", "int", IMBA_PICKLIST_INT)
end]]


function IMBA:BountyRuneFilter(keys)
	--[[
	gold_bounty: 40
	player_id_const: 0
	xp_bounty: 0
	]]
	local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[keys.player_id_const + 1]
	if hero then
		hero:AddNewModifier(hero, nil, "modifier_imba_rune_bounty", {duration = 60})
	end

	keys.gold_bounty = keys.gold_bounty * 4
	return true
end

function IMBA:DamageFilter(keys)
	--[[
	damage: 75.159187316895
	damagetype_const: 2
	entindex_attacker_const: 253
	entindex_inflictor_const: 254
	entindex_victim_const: 941
	]]

	local damage_type = keys.damagetype_const

	local target = EntIndexToHScript(keys.entindex_victim_const)

	local target_buffs = target:FindAllModifiers()

	local attacker = keys.entindex_attacker_const and EntIndexToHScript(keys.entindex_attacker_const) or nil

	local attacker_buffs = attacker and attacker:FindAllModifiers() or nil

	local ability = keys.entindex_inflictor_const and EntIndexToHScript(keys.entindex_inflictor_const) or nil

	local red_cirt = false

	if noDamageFilterUnits[target:GetName()] then
		return true
	end

	------------------------------------------------------------------------------------
	-- Legion Commander Duel Damage
	------------------------------------------------------------------------------------

	if target:HasModifier("modifier_legion_commander_duel") and target:FindModifierByName("modifier_legion_commander_duel"):GetCaster():HasScepter() then
		if not attacker then
			return false
		end
		if attacker and attacker:GetAttackTarget() ~= target then
			return false
		end
		if attacker and not attacker:HasModifier("modifier_legion_commander_duel") then
			return false
		end
	end

	------------------------------------------------------------------------------------
	-- IMBA Backdoor Protection
	------------------------------------------------------------------------------------

	if target:HasModifier("modifier_backdoor_protection_active") and (string.find(target:GetUnitName(), "_tower3_") or string.find(target:GetUnitName(), "_tower4")) then
		keys.damage = 1
	end

	------------------------------------------------------------------------------------
	-- IMBA Spell Rapier SPELL AMP Break Distance
	------------------------------------------------------------------------------------

	if attacker and ability and (target:GetAbsOrigin() - attacker:GetAbsOrigin()):Length2D() > 2500 then
		local rapier_spellAMP = 0
		local total_spellAMP = attacker:GetSpellAmplification(false)
		for _, buff in pairs(attacker_buffs) do
			if buff:GetName() == "modifier_imba_rapier_magic_unique" then
				rapier_spellAMP = rapier_spellAMP + SPELL_AMP_RAPIER_1
			end
			if buff:GetName() == "modifier_imba_rapier_magic_three_unique" then
				rapier_spellAMP = rapier_spellAMP + SPELL_AMP_RAPIER_3
			end
			if buff:GetName() == "modifier_imba_rapier_super_passive" then
				rapier_spellAMP = rapier_spellAMP + SPELL_AMP_RAPIER_SUPER
			end
		end
		keys.damage = keys.damage / (1 + total_spellAMP)
		keys.damage = keys.damage * (1 + (total_spellAMP - rapier_spellAMP))
	end


	------------------------------------------------------------------------------------
	-- IMBA Faceless Void Back Track
	------------------------------------------------------------------------------------

	if target:HasTalent("special_bonus_imba_faceless_void_2") and PseudoRandom:RollPseudoRandom(target:FindAbilityByName("special_bonus_imba_faceless_void_2"), target:GetTalentValue("special_bonus_imba_faceless_void_2")) then
		if attacker and attacker:GetName() == "dota_fountain" then
			--nothing
		else
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:ReleaseParticleIndex(pfx)
			return false
		end
	end

	------------------------------------------------------------------------------------
	-- Necrolyte Reapers Scythe Logic
	------------------------------------------------------------------------------------

	if target:HasModifier("modifier_imba_reapers_scythe_stundummy") and not target:HasModifier("modifier_winter_wyvern_winters_curse_aura") then
		local scythe = target:FindModifierByName("modifier_imba_reapers_scythe_stundummy")
		if scythe and scythe:GetCaster() and scythe:GetAbility() and (scythe:GetAbility() ~= ability or scythe:GetCaster() ~= attacker) then
			local scythe_caster = scythe:GetCaster()
			local scythe_ability = scythe:GetAbility()
			if target:GetHealth() <= keys.damage then
				local damageTable = {
									victim = target,
									attacker = scythe_caster,
									damage = target:GetHealth() + 10,
									damage_type = DAMAGE_TYPE_PURE,
									damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT, --Optional.
									ability = scythe_ability, --Optional.
									}
				ApplyDamage(damageTable)
				return false
			end
		end
	end

	------------------------------------------------------------------------------------
	-- Prevent IMBA Illusions Die
	------------------------------------------------------------------------------------

	if (target:HasModifier("modifier_imba_illusion") or target:HasModifier("modifier_imba_illusion_hidden")) and target:GetHealth() <= keys.damage then
		keys.damage = 0
		target:SetHealth(1)
	end

	------------------------------------------------------------------------------------
	-- Cheese Auto Cast Logic
	------------------------------------------------------------------------------------

	if target:GetHealth() <= keys.damage and target:GetName() ~= "npc_dota_roshan" and not target:IsIllusion() and not target:IsMuted() and not target:HasModifier("modifier_imba_cheese_auto_cooldown") then
		for i=0, 8 do
			local item = target:GetItemInSlot(i)
			if item and not item:IsNull() and item:GetName() == "item_imba_cheese" then
				target:AddNewModifier(target, item, "modifier_imba_cheese_auto_cooldown", {duration = item:GetSpecialValueFor("auto_cooldown")})
				item:OnSpellStart()
			end
		end
	end


	------------------------------------------------------------------------------------
	-- Red Cirt Damage Type
	------------------------------------------------------------------------------------

	for _, buff in pairs(target_buffs) do
		if buff.IMBARedCirtIncomingDamage and buff:IMBARedCirtIncomingDamage() then
			red_cirt = true
		end
	end

	------------------------------------------------------------------------------------
	-- True Hero Killed
	------------------------------------------------------------------------------------

	if target:IsTrueHero() and keys.damage >= target:GetHealth() and IsInTable(target, CDOTA_PlayerResource.IMBA_PLAYER_HERO) then
		local victim = target
		local game_time = GameRules:GetDOTATime(false, false)
		local base_gold = victim:GetLevel() * 10
		if game_time > 60 then
			base_gold = base_gold + PlayerResource:GetGoldPerMin(victim:GetPlayerID()) * 0.05
		end
		local bounty = base_gold * math.max((1 - PlayerResource.IMBA_PLAYER_DEATH_STREAK[victim:GetPlayerID() + 1] / 10), 0)
		bounty = bounty * (1 + CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[victim:GetPlayerID() + 1] * 0.2)
		victim:SetMinimumGoldBounty(bounty)
		victim:SetMaximumGoldBounty(bounty)
		local hero_level = victim:GetLevel()
		local xp = HERO_XP_BOUNTY_PER_LEVEL[hero_level]
		xp = xp * (1 + CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[victim:GetPlayerID() + 1] * 0.2)
		victim:SetCustomDeathXP(xp)
		if PlayerResource:GetConnectionState(victim:GetPlayerID()) == DOTA_CONNECTION_STATE_ABANDONED then
			victim:SetMinimumGoldBounty(0)
			victim:SetMaximumGoldBounty(0)
		end

		------------respawn-------------
		local game_time = GameRules:GetDOTATime(false, false)

		local respawn_timer = victim:GetIMBARespawnTime()

		if game_time > 1800 then
			respawn_timer = respawn_timer + ((game_time - 1800) / 60)
		end

		GameRules:GetGameModeEntity():SetFixedRespawnTime(respawn_timer)

		local buy_back_cost = 0

		buy_back_cost = BUYBACK_BASE_COST + PlayerResource:GetGoldSpentOnBuybacks(victim:GetPlayerID()) / 20 + math.min(victim:GetLevel(), 25) * BUYBACK_COST_PER_LEVEL + math.max(victim:GetLevel() - 25, 0) * BUYBACK_COST_PER_LEVEL_AFTER_25 + game_time * BUYBACK_COST_PER_SECOND

		if GameRules:IsCheatMode() then
			buy_back_cost = 0
		end

		PlayerResource:SetCustomBuybackCost(victim:GetPlayerID(), buy_back_cost)

		PlayerResource:SetCustomBuybackCost(victim:GetPlayerID(), buy_back_cost)

		-- Setup buyback cooldown
		local buyback_cooldown = 0
		if BUYBACK_COOLDOWN_ENABLED and game_time > BUYBACK_COOLDOWN_START_POINT then
			buyback_cooldown = math.min(BUYBACK_COOLDOWN_GROW_FACTOR * (game_time - BUYBACK_COOLDOWN_START_POINT), BUYBACK_COOLDOWN_MAXIMUM)
		end

		if GameRules:IsCheatMode() then
			buyback_cooldown = 0
		end

		PlayerResource:SetCustomBuybackCooldown(victim:GetPlayerID(), buyback_cooldown)

		print(victim:GetRespawnTime(), PlayerResource:GetRespawnSeconds(victim:GetPlayerID()))

	end

	if red_cirt then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, keys.damage, nil)
	end

	return true
end

--[[
76561198115784539
76561198101151944
76561198032910756
76561198124251542
76561198845399966
76561198054917153
76561198103991184
76561198096631135
76561198142179354
76561198146229057
76561198109522270
76561198240599250
76561198082036401
76561198312782420
76561198104023318
76561198113420595
76561198137694912
76561198053084768
76561198096612746
76561198049286339
76561198302684975
76561198103546522
76561198866505549
76561198006947736
76561198063283421
76561198123967311
76561198306196062
76561198100592590
]]

function IMBA:OrderFilter(keys)
	
	--entindex_ability	 ==> 	0
	--sequence_number_const	 ==> 	20
	--queue	 ==> 	0
	--units	 ==> 	table: 0x031d5fd0
	--entindex_target	 ==> 	0
	--position_z	 ==> 	384
	--position_x	 ==> 	-5694.3334960938
	--order_type	 ==> 	1
	--position_y	 ==> 	-6381.1127929688
	--issuer_player_id_const	 ==> 	0

	local units = keys["units"]
	local unit = units["0"] and EntIndexToHScript(units["0"]) or nil

	if not unit then
		return true
	end

	--PrintTable(keys)

	if IMBA_DISABLE_PLAYER[keys.issuer_player_id_const] == true then
		return false
	end

	------------------------------------------------------------------------------------
	-- Prevent to learn AK ability
	------------------------------------------------------------------------------------

	if keys.order_type == DOTA_UNIT_ORDER_TRAIN_ABILITY then
		if EntIndexToHScript(keys.entindex_ability).ak then
			return false
		end
	end

	------------------------------------------------------------------------------------
	-- Courier Set
	------------------------------------------------------------------------------------
	if 1 then--not GameRules:IsCheatMode() then
		for k, v in pairs(keys['units']) do
			if EntIndexToHScript(v):IsCourier() then
				keys['units'] = {['0'] = keys['units']['0']}
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.issuer_player_id_const), "IMBAUseCourier", {courier = CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1] and CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1]:entindex() or -1})
				break
			end
			--[[if tonumber(k) > 0 and EntIndexToHScript(v):IsCourier() then
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.issuer_player_id_const), "IMBAUseCourier", {})
				keys['units'][k] = nil
			end]]
		end
		if unit:IsCourier() and CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1] then
			if unit == CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1] then
				return true
			end
			if keys.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
				local ability = EntIndexToHScript(keys.entindex_ability)
				if not ability then
					return false
				end
				if ability:GetName() == "courier_shield" then
					return true
				end
				keys["units"]["0"] = CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1]:entindex()
				local ability_name = ability:GetName()
				if ability_name == "courier_transfer_items" then
					ability_name = "courier_take_stash_and_transfer_items"
				end
				keys.entindex_ability = CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1]:FindAbilityByName(ability_name):entindex()
				return true
			else
				keys["units"]["0"] = CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1]:entindex()
				return true
			end
			return true
		end

		if keys.order_type == DOTA_UNIT_ORDER_GIVE_ITEM and EntIndexToHScript(keys.entindex_target):IsCourier() then
			if not CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1] or CDOTA_PlayerResource.IMBA_PLAYER_COURIER[keys.issuer_player_id_const + 1] ~= EntIndexToHScript(keys.entindex_target) then
				return false
			end
		end
	end

	------------------------------------------------------------------------------------
	-- Suicide
	------------------------------------------------------------------------------------

	if keys.entindex_ability == 2228 and keys.order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		local hero = PlayerResource.IMBA_PLAYER_HERO[keys.issuer_player_id_const + 1]
		if hero and hero:IsAlive() then
			if hero:HasModifier("modifier_imba_suicide") then
				hero:RemoveModifierByName("modifier_imba_suicide")
			else
				hero:AddNewModifier(hero, nil, "modifier_imba_suicide", {duration = 30.0})
			end
		end
		return false
	end

	------------------------------------------------------------------------------------
	-- Tiny Toss / Furion Sprout Disable Help
	------------------------------------------------------------------------------------

	if (keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET or keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION) and (EntIndexToHScript(keys.entindex_ability):GetName() == "furion_sprout" or EntIndexToHScript(keys.entindex_ability):GetName() == "tiny_toss" or EntIndexToHScript(keys.entindex_ability):GetName() == "item_force_staff" or EntIndexToHScript(keys.entindex_ability):GetName() == "item_hurricane_pike") then
		local ability = EntIndexToHScript(keys.entindex_ability)
		if ability:GetName() == "furion_sprout" then
			if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
				local unit = FindUnitsInRadius(ability:GetCaster():GetTeamNumber(), Vector(keys.position_x, keys.position_y, keys.position_z), nil, 300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for i=1, #unit do
					if PlayerResource:IsDisableHelpSetForPlayerID(unit[i]:GetPlayerOwnerID(), ability:GetCaster():GetPlayerOwnerID()) then
						return false
					end
				end
			else
				return not PlayerResource:IsDisableHelpSetForPlayerID(EntIndexToHScript(keys.entindex_target):GetPlayerOwnerID(), ability:GetCaster():GetPlayerOwnerID())
			end
		elseif ability:GetName() == "tiny_toss" then
			local unit = FindUnitsInRadius(ability:GetCaster():GetTeamNumber(), ability:GetCaster():GetAbsOrigin(), nil, ability:GetSpecialValueFor("grab_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for i=1, #unit do
				if PlayerResource:IsDisableHelpSetForPlayerID(unit[i]:GetPlayerOwnerID(), ability:GetCaster():GetPlayerOwnerID()) then
					return false
				end
			end
		elseif ability:GetName() == "item_force_staff" or ability:GetName() == "item_hurricane_pike" then
			if PlayerResource:IsDisableHelpSetForPlayerID(EntIndexToHScript(keys.entindex_target):GetPlayerOwnerID(), ability:GetCaster():GetPlayerOwnerID()) then
				return false
			end
		end
	end

	------------------------------------------------------------------------------------
	-- Global Sniper Assassinate
	------------------------------------------------------------------------------------

	if keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET and EntIndexToHScript(keys.entindex_ability):GetName() == "imba_sniper_assassinate" then
		local ability = EntIndexToHScript(keys.entindex_ability)
		local target = EntIndexToHScript(keys.entindex_target)
		if target:HasModifier("modifier_sniper_shrapnel_slow") and not target:HasModifier("modifier_fountain_aura_buff") then
			ability.global = 50000
		else
			ability.global = 0
		end
	end

	------------------------------------------------------------------------------------
	-- Spin Web Cast Range
	------------------------------------------------------------------------------------

	if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION and EntIndexToHScript(keys.entindex_ability):GetName() == "imba_broodmother_spin_web" then
		local ability = EntIndexToHScript(keys.entindex_ability)
		if #Entities:FindAllByClassnameWithin("npc_dota_broodmother_web", Vector(keys.position_x, keys.position_y, keys.position_z), ability:GetSpecialValueFor("radius") * 2) > 0 then
			ability.range = 50000
		else
			ability.range = 0
		end
	end

	------------------------------------------------------------------------------------
	-- Boulder Smash Cast Range
	------------------------------------------------------------------------------------

	if (keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION or keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET) and EntIndexToHScript(keys.entindex_ability):GetName() == "imba_earth_spirit_boulder_smash" then
		local ability = EntIndexToHScript(keys.entindex_ability)
		if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION or FindStoneRemnant(ability:GetCaster():GetAbsOrigin(), ability:GetSpecialValueFor("rock_search_aoe")) then
			ability.range = 50000
		else
			ability.range = 0
		end
	end

	------------------------------------------------------------------------------------
	-- Queen of Pain's Sonic Wave confusion
	------------------------------------------------------------------------------------

	local confuse = unit:HasModifier("modifier_confuse")
	if confuse then

		-- Determine order type
		local rand = math.random
			
		-- Change "move to target" to "move to position"
		if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
			local target = EntIndexToHScript(keys["entindex_target"])
			local target_loc = target:GetAbsOrigin()
			keys.position_x = target_loc.x
			keys.position_y = target_loc.y
			keys.position_z = target_loc.z
			keys.entindex_target = 0
			keys.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
		end

		-- Change "attack target" to "attack move"
		if keys.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET then
			local target = EntIndexToHScript(keys["entindex_target"])
			local target_loc = target:GetAbsOrigin()
			keys.position_x = target_loc.x
			keys.position_y = target_loc.y
			keys.position_z = target_loc.z
			keys.entindex_target = 0
			keys.order_type = DOTA_UNIT_ORDER_ATTACK_MOVE
		end

		-- Change "cast on target" target
		if keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET or keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET_TREE then
			
			local target = EntIndexToHScript(keys["entindex_target"])
			local caster_loc = unit:GetAbsOrigin()
			local target_loc = target:GetAbsOrigin()
			local target_distance = (target_loc - caster_loc):Length2D()
			local found_new_target = false
			local nearby_units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster_loc, nil, target_distance, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
			if #nearby_units >= 1 then
				keys.entindex_target = nearby_units[1]:GetEntityIndex()

			-- If no target was found, change to "cast on position" order
			else
				keys.position_x = target_loc.x
				keys.position_y = target_loc.y
				keys.position_z = target_loc.z
				keys.entindex_target = 0
				keys.order_type = DOTA_UNIT_ORDER_CAST_POSITION
			end
		end

		-- Spin positional orders a random angle
		if keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or keys.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
			
			-- Calculate new order position
			local target_loc = Vector(keys.position_x, keys.position_y, keys.position_z)
			local origin_loc = unit:GetAbsOrigin()
			local order_vector = target_loc - origin_loc
			local new_order_vector = RotatePosition(origin_loc, QAngle(0, rand(45, 315), 0), origin_loc + order_vector)

			-- Override order
			keys.position_x = new_order_vector.x
			keys.position_y = new_order_vector.y
			keys.position_z = new_order_vector.z
		end
	end

	return true
end

function IMBA:HealFilter(keys)
	--[[
	entindex_healer_const: 329
	entindex_inflictor_const: 600
	entindex_target_const: 329
	heal: 60
	]]
	local target = EntIndexToHScript(keys.entindex_target_const)

	local heal_amount = EntIndexToHScript(keys.heal)

	local ability = keys.entindex_inflictor_const and EntIndexToHScript(keys.entindex_inflictor_const) or nil

	local healer = keys.entindex_healer_const and EntIndexToHScript(keys.entindex_healer_const) or nil

	--[[if ability then
		local healamp = target:GetIncomingHealAmp() / 100
		keys.heal = keys.heal * (1 + healamp)
	end]]

	return true
end

function IMBA:ItemPickFilter(keys)
	--[[
	inventory_parent_entindex_const: 428
	item_entindex_const: 857
	item_parent_entindex_const: -1
	suggested_slot: -1
	]]
	local picker = EntIndexToHScript(keys.inventory_parent_entindex_const)
	local item = EntIndexToHScript(keys.item_entindex_const)

	------------------------------------------------------------------------------------
	-- IMBA Aegis Pick Up
	------------------------------------------------------------------------------------

	if item:GetAbilityName() == "item_aegis" and not picker:IsBoss() and picker:IsTrueHero() then
		picker:AddNewModifier(picker, nil, "modifier_imba_aegis", {duration = 300.0})
		local stock = picker:GetItemInSlot(0)
		if stock then
			picker:DropItemAtPositionImmediate(stock, Vector(99999,99999,-1000))
		end
		Timers:CreateTimer(FrameTime(), function()
			UTIL_Remove(item)
			if stock then
				picker:AddItem(stock)
			end
			return nil
		end
		)
		return true
	end

	------------------------------------------------------------------------------------
	-- IMBA Rapier Pick Up
	------------------------------------------------------------------------------------

	if picker and picker:IsCourier() and string.find(item:GetAbilityName(), "item_imba_rapier") then
		local abs = item:GetAbsOrigin()
		Timers:CreateTimer(FrameTime(), function()
			picker:DropItemAtPositionImmediate(item, abs)
			return nil
		end
		)
	end


	return true
end

function IMBA:ModifierAddFilter(keys)
	--[[
	duration: -1
	entindex_ability_const: 966
	entindex_caster_const: 956
	entindex_parent_const: 956
	name_const: modifier_backdoor_protection_active
	]]
	local duration = keys.duration

	local ability = keys.entindex_ability_const and EntIndexToHScript(keys.entindex_ability_const) or nil

	local caster = keys.entindex_caster_const and EntIndexToHScript(keys.entindex_caster_const) or nil

	local target = EntIndexToHScript(keys.entindex_parent_const)

	local status_res = target:GetStatusResistance()

	local modifier_name = keys.name_const

	if target:GetUnitName() == "npc_dota_warlock_golem_1" and not modifier_name == "modifier_kill" then
		return false
	end

	-- volvo bugfix
	if modifier_name == "modifier_datadriven" then
		return false
	end

	-- don't add buyback penalty
	if modifier_name == "modifier_buyback_gold_penalty" then
		return false
	end

	if IsInTable(target:GetUnitName(), noDamageFilterUnits) then
		return true
	end

	------------------------------------------------------------------------------------
	-- Roshan Fucks Every Debuff
	------------------------------------------------------------------------------------

	if target:IsBoss() and caster and caster ~= target and keys.duration > 0 then
		keys.duration = keys.duration * 0.5
	end

	------------------------------------------------------------------------------------
	-- IMBA Rune Modifier Filter(Trans normal to IMBA), illusion rune setted in events.lua GameMode:OnRuneActivated
	------------------------------------------------------------------------------------

	if modifier_name == "modifier_rune_regen" then
		local buff = target:AddNewModifier(target, nil, "modifier_imba_rune_regeneration", {duration = 30.0})
		buff:SetStackCount(20)
		return false
	end
	if modifier_name == "modifier_rune_haste" then
		target:AddNewModifier(target, nil, "modifier_imba_rune_haste", {duration = 45.0})
		return false
	end
	if modifier_name == "modifier_rune_invis" then
		target:AddNewModifier(target, nil, "modifier_imba_rune_invisibility", {duration = 45.0})
		return false
	end
	if modifier_name == "modifier_rune_doubledamage" then
		target:AddNewModifier(target, nil, "modifier_imba_rune_doubledamage", {duration = 45.0})
		return false
	end
	if modifier_name == "modifier_rune_arcane" then
		target:AddNewModifier(target, nil, "modifier_imba_rune_arcane", {duration = 45.0})
		for i=0, 23 do
			local caster_ability = target:GetAbilityByIndex(i)
			if caster_ability and not caster_ability:IsCooldownReady() then
				local cd = caster_ability:GetCooldownTimeRemaining() * 0.6
				caster_ability:EndCooldown()
				caster_ability:StartCooldown(cd)
			end
		end
		for i=0, 23 do
			local caster_ability = target:GetItemInSlot(i)
			if caster_ability and not caster_ability:IsCooldownReady() then
				local cd = caster_ability:GetCooldownTimeRemaining() * 0.6
				caster_ability:EndCooldown()
				caster_ability:StartCooldown(cd)
			end
		end
		return false
	end

	------------------------------------------------------------------------------------
	-- Engima: Gravity Aura
	------------------------------------------------------------------------------------

	if (modifier_name == "modifier_stunned" or modifier_name == "modifier_imba_stunned" or modifier_name == "modifier_imba_bashed") and target:HasModifier("modifier_imba_enigma_gravity_aura") and keys.duration > 0 then
		keys.duration = keys.duration * (1 + (target:FindModifierByName("modifier_imba_enigma_gravity_aura"):GetAbility():GetSpecialValueFor("stun_increase") / 100))
	end

	------------------------------------------------------------------------------------
	-- IMBA Faceless Void Back Track
	------------------------------------------------------------------------------------

	if target:HasTalent("special_bonus_imba_faceless_void_2") and PseudoRandom:RollPseudoRandom(target:FindAbilityByName("special_bonus_imba_faceless_void_2"), target:GetTalentValue("special_bonus_imba_faceless_void_2")) and caster and IsEnemy(caster, target) then
		if attacker and attacker:GetName() == "dota_fountain" then
			--nothing
		else
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:ReleaseParticleIndex(pfx)
			return false
		end
	end

	------------------------------------------------------------------------------------
	-- Status With IMBA Stun
	------------------------------------------------------------------------------------

	if modifier_name == "modifier_imba_stunned" or modifier_name == "modifier_imba_bashed" then
		keys.duration = keys.duration * math.max((1 - status_res), 0)
	end

	return true
end

function IMBA:ExpFilter(keys)
	--[[
	experience: 69
	player_id_const: 0
	reason_const: 2
	]]
	keys.experience = keys.experience * ((100 + CUSTOM_XP_BONUS) / 100)
	--[[if keys.reason_const == DOTA_ModifyXP_HeroKill then
		print("hero", PlayerResource:GetPlayer(keys.player_id_const):GetAssignedHero():GetName(), "exp", keys.experience)
	end]]
	return true
end

local HeroKillAssistGold = {}
local firstBlood = true

function IMBA:HeroKillAssistGoldIncrease(hero, gold, time)
	local key = {hero, gold}
	if type(HeroKillAssistGold[time]) ~= "table" then
		HeroKillAssistGold[time] = {}
		Timers:CreateTimer(0.2, function()
			IMBA:GiveHeroHeroKillGold(time)
		end
		)
	end
	table.insert(HeroKillAssistGold[time], key)
end

function IMBA:GiveHeroHeroKillGold(time)
	if firstBlood then
		firstBlood = false
		return
	end
	table.sort(HeroKillAssistGold[time],
	function(a, b)
		return a[2] > b[2]
	end)
	if #HeroKillAssistGold[time] <= 2 then
		HeroKillAssistGold[time] = nil
		return
	end
	local killer = HeroKillAssistGold[time][1][1]
	local killBounty = 0
	for _, v in pairs(HeroKillAssistGold[time]) do
		if v[1] == killer then
			killBounty = killBounty + v[2]
		end
	end
	local GoldToGive = killBounty / (#HeroKillAssistGold[time] - 2)
	if #HeroKillAssistGold[time] == 3 then
		GoldToGive = GoldToGive / 2
	end
	for _, v in pairs(HeroKillAssistGold[time]) do
		if v[1] ~= killer then
			SendOverheadEventMessage(PlayerResource:GetPlayer(v[1]:GetPlayerID()), OVERHEAD_ALERT_GOLD, v[1], GoldToGive, nil)
			v[1]:ModifyGold(GoldToGive, true, DOTA_ModifyGold_Unspecified)
		end
		local high_five = v[1]:FindAbilityByName("high_five")
		if high_five then
			high_five:OnSpellStart()
		end
	end
	HeroKillAssistGold[time] = nil
end

function IMBA:GoldFilter(keys)
	--[[
	gold: 57
	player_id_const: 0
	reason_const: 13
	reliable: 0
	]]

	--PrintTable(keys)

	keys.gold = keys.gold * ((100 + CUSTOM_GOLD_BONUS) / 100)

	local hero = PlayerResource.IMBA_PLAYER_HERO[keys.player_id_const + 1]

	if keys.reason_const == DOTA_ModifyGold_HeroKill then
		--print("hero:", hero:GetName(), "gold = ", keys.gold, "time", GameRules:GetGameTime())
		IMBA:HeroKillAssistGoldIncrease(hero, keys.gold, GameRules:GetGameTime())
	end

	local multi = 0

	local buffs = hero:FindAllModifiers()
	for _, buff in pairs(buffs) do
		if buff.GetIMBAGoldPercentage and type(buff:GetIMBAGoldPercentage()) == "number" then
			multi = multi + buff:GetIMBAGoldPercentage()
		end
	end

	keys.gold = keys.gold * (1 + (multi / 100))

	return true
end

local runes = {}

for rune, enable in pairs(ENABLED_RUNES) do
	if enable and rune ~= DOTA_RUNE_BOUNTY then
		table.insert(runes, rune)
	end
end

function IMBA:RuneSpawnFilter(keys)
	--rune_type: 1
	--PrintTable(keys)

	keys.rune_type = RandomFromTable(runes)

	return true
end

function IMBA:SpawnRoshan()
	roshan_kill = roshan_kill + 1
	local unit = CreateUnitByName("npc_dota_roshan", GetGroundPosition(roshan_pos, nil), true, nil, nil, 0)
	Timers:CreateTimer(FrameTime() * 3, function()
		FindClearSpaceForUnit(unit, unit:GetAbsOrigin(), true)
		return nil
	end
	)
	unit:RemoveAbility("roshan_spell_block")
	unit:RemoveAbility("roshan_slam")
	unit:RemoveAbility("roshan_inherent_buffs")
	--unit:RemoveAbility("roshan_devotion")
	--unit:RemoveModifierByName("modifier_roshan_devotion")
	unit:AddItemByName("item_aegis")

	--- IMBA Roshan Set
	SetCreatureHealth(unit, 12000 + (roshan_kill - 1) * 2000, true)
	local ability1 = unit:AddAbility("imba_huskar_berserkers_blood")
	ability1:SetLevel(5)
	local ability2 = unit:AddAbility("imba_roshan_slam")
	ability2:SetLevel(1)
	local buff1 = unit:AddNewModifier(unit, nil, "modifier_imba_roshan_upgrade", {})
	buff1:SetStackCount(roshan_kill - 1)
	local buff2 = unit:AddNewModifier(unit, nil, "modifier_roshan_devotion", {})
	buff2:SetStackCount(roshan_kill - 1)
	---
	if roshan_kill >= 2 then
		unit:AddItemByName("item_imba_cheese"):SetCurrentCharges(RandomInt(1, roshan_kill-1))
	end
	if roshan_kill >= 5 then
		if RollPercentage(90) then
			unit:AddItemByName("item_refresher_shard")
		else
			unit:AddItemByName("item_ultimate_scepter_2")
		end
	end
	if roshan_kill >= 12 then
		unit:AddAbility("imba_tower_grievous_wounds"):SetLevel(1)
	end
	if roshan_kill >= 15 then
		unit:AddItemByName("item_aegis")
	end
	return unit
end

function IMBA:TrackingProjectileFilter(keys)
	--[[
	dodgeable: 1
	entindex_ability_const: 357
	entindex_source_const: 349
	entindex_target_const: 413
	expire_time: 99.298980712891
	is_attack: 0
	max_impact_time: 0
	move_speed: 3000
	]]
	return true
end

function IMBA:PlayerPickUpIllusionRune(player)
	local baseHero = player:GetAssignedHero()
	local enemies = FindUnitsInRadius(baseHero:GetTeamNumber(), Vector(0,0,0), nil, 50000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
	local delay = 0
	for _, enemy in pairs(enemies) do
		if enemy:IsTrueHero() and not enemy:IsClone() and not enemy:IsTempestDouble() and not enemy:IsCreep() and not enemy:IsCreature() then
			Timers:CreateTimer(delay, function()
				local illusion = IllusionManager:CreateIllusion(baseHero, (enemy:GetAbsOrigin() + enemy:GetForwardVector() * -100), enemy:GetForwardVector(), 10, 50, 0, 5.0, baseHero, nil)
				illusion:SetForceAttackTarget(enemy)
				illusion:AddNewModifier(illusion, nil, "modifier_imba_rune_illusion", {})
				return nil
			end
			)
			delay = delay + 0.5
		end
	end
end

 -- bitmask; 1 shares heroes, 2 shares units, 4 disables help 
function FlipUnitShareMaskBit(targetPlayerID, otherPlayerID, bitVal)
	local currentUnitShareMask = PlayerResource:GetUnitShareMaskForPlayer(targetPlayerID, otherPlayerID)
	if bit.band(currentUnitShareMask, bitVal) == bitVal then
		PlayerResource:SetUnitShareMaskForPlayer(targetPlayerID, otherPlayerID, bitVal, false)
	else
		PlayerResource:SetUnitShareMaskForPlayer(targetPlayerID, otherPlayerID, bitVal, true)
	end
end

function ToggleDisableShareUnit(unused, kv)
	FlipUnitShareMaskBit(kv.PlayerID, kv.otherPlayerID, 2)
end

function ToggleDisableShareHero(unused, kv)
	FlipUnitShareMaskBit(kv.PlayerID, kv.otherPlayerID, 1)
end

function ToggleDisablePlayerHelp(unused, kv)
	FlipUnitShareMaskBit(kv.PlayerID, kv.otherPlayerID, 4)
end

local endover = false

function UpDatePlayerInfo()
	if endover then
		return
	end
	endover = true
	for i=0, 19 do
		if PlayerResource:IsValidPlayerID(i) and CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1] then
			local playerTable = {["player_gold"] = PlayerResource:GetGold(i), ["hero_level"] = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetLevel()}
			for j=0, 8 do
				local item = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetItemInSlot(j)
				if item then
					playerTable["item_"..j] = item:GetName()
					playerTable["item_charges_"..j] = item:GetCurrentCharges()
				else
					playerTable["item_"..j] = "item_imba_dummy"
					playerTable["item_charges_"..j] = 0
				end
			end
			if CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:HasModifier("modifier_item_ultimate_scepter_consumed") or CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:HasModifier("modifier_imba_consumable_scepter_consumed") then
				playerTable["scepter_consumed"] = 1
			else
				playerTable["scepter_consumed"] = 0
			end
			playerTable["moon_consumed"] = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetModifierStackCount("modifier_imba_moon_shard_consume", nil)
			playerTable["connection_state"] = PlayerResource:GetConnectionState(i)
			CustomNetTables:SetTableValue("imba_hero_end_info", tostring(i), playerTable)
		end
	end
end

function VoteForOMG(unused, kv)
	local total = IMBA_PLAYER_COUNT
	local need = IMBA_VOTE_NEED
	local agree = CustomNetTables:GetTableValue("imba_omg", "enable_omg").agree
	agree = agree + 1
	enable = agree >= need and 1 or 0
	if enable == 1 then
		mode:SetDraftingBanningTimeOverride(0)
		mode:SetDraftingHeroPickSelectTimeOverride(0)
	end
	IMBA_OMG_ENABLE = enable == 1 and true or false
	CustomNetTables:SetTableValue("imba_omg", "enable_omg", {["agree"] = agree, ["enable"] = enable})
	CustomGameEventManager:Send_ServerToAllClients("updata_omg_vote", {})
	--print(total, need, CustomNetTables:GetTableValue("imba_omg", "enable_omg").agree, CustomNetTables:GetTableValue("imba_omg", "enable_omg").enable)
end

function VoteForAK(unused, kv)
	local total = IMBA_PLAYER_COUNT
	local need = IMBA_VOTE_NEED
	local agree = CustomNetTables:GetTableValue("imba_omg", "enable_ak").agree
	agree = agree + 1
	enable = agree >= need and 1 or 0
	CustomNetTables:SetTableValue("imba_omg", "enable_ak", {["agree"] = agree, ["enable"] = enable})
	CustomGameEventManager:Send_ServerToAllClients("updata_ak_vote", {})
	IMBA_AK_ENABLE = enable == 1 and true or false
	--print(total, need, CustomNetTables:GetTableValue("imba_omg", "enable_omg").agree, CustomNetTables:GetTableValue("imba_omg", "enable_omg").enable)
end

function VoteFor31(unused, kv)
	local total = IMBA_PLAYER_COUNT
	local need = IMBA_VOTE_NEED
	local agree = CustomNetTables:GetTableValue("imba_omg", "enable_31").agree
	agree = agree + 1
	enable = agree >= need and 1 or 0
	if enable == 1 then
		mode:SetDraftingBanningTimeOverride(0)
		mode:SetDraftingHeroPickSelectTimeOverride(HERO_SELECTION_TIME)
	else
		mode:SetDraftingBanningTimeOverride(15)
		mode:SetDraftingHeroPickSelectTimeOverride(HERO_SELECTION_TIME - 5)
	end
	IMBA_31_ENABLE = enable == 1 and true or false
	CustomNetTables:SetTableValue("imba_omg", "enable_31", {["agree"] = agree, ["enable"] = enable})
	CustomGameEventManager:Send_ServerToAllClients("updata_31_vote", {})
	--print(total, need, CustomNetTables:GetTableValue("imba_omg", "enable_omg").agree, CustomNetTables:GetTableValue("imba_omg", "enable_omg").enable)
end

function UpdateScoreBoardList()
	if IMBA_UPDATE_SCOREBOARD_LIST_PREVENT then
		return
	end
	IMBA_UPDATE_SCOREBOARD_LIST_PREVENT = true
	Timers:CreateTimer({
		useGameTime = false,
		endTime = 3.0, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			IMBA_UPDATE_SCOREBOARD_LIST_PREVENT = false
			return nil
		end
	})

	for i=1, 20 do
		if CDOTA_PlayerResource.IMBA_PLAYER_HERO[i] ~= nil then
			local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i]
			local ult = hero:GetAbilityByIndex(5)
			local ult_state = 0
			if ult then
				if ult:GetLevel() == 0 then
					ult_state = 1
				end
				if ult:GetLevel() > 0 and ult:IsCooldownReady() and ult:IsOwnersManaEnough() then
					ult_state = 2
				end
				if ult:GetLevel() > 0 and ult:IsCooldownReady() and not ult:IsOwnersManaEnough() then
					ult_state = 3
				end
				if ult:GetLevel() > 0 and not ult:IsCooldownReady() and not ult:IsOwnersManaEnough() then
					ult_state = 4
				end
				if ult:GetLevel() > 0 and not ult:IsCooldownReady() and ult:IsOwnersManaEnough() then
					ult_state = 5
				end
			end
			CustomNetTables:SetTableValue("imba_scoreboard_detail", tostring(i-1), {["ult_state"] = ult_state, ["level"] = hero:GetLevel(), ["gold"] = hero:GetGold()})
		end
	end
end

function CompareCursorPosition(unused, kv)
	--[[
	lua_x y z
	pan_x y z
	order_type
	player_id
	]]
	local lua_pos = Vector(kv.lua_x, kv.lua_y, 1500)
	local pan_pos = Vector(kv.pan_x, kv.pan_y, 1500)
	if GetGroundHeight(lua_pos, nil) - GetGroundHeight(pan_pos, nil) < 30 then
		lua_pos = Vector(kv.lua_x, kv.lua_y, kv.lua_z)
		pan_pos = Vector(kv.pan_x, kv.pan_y, kv.lua_z + 80)
		if (lua_pos - pan_pos):Length2D() > 500 and kv.order_type == DOTA_UNIT_ORDER_CAST_TARGET and CDOTA_PlayerResource.IMBA_PLAYER_HERO[kv.player_id + 1] then
			CDOTA_PlayerResource.IMBA_PLAYER_HERO[kv.player_id + 1].order = CDOTA_PlayerResource.IMBA_PLAYER_HERO[kv.player_id + 1].order + 1
		end
	end
	--PrintTable(kv)
end

function IMBA:StartGoldShare(nPlayerID)
	local player = nPlayerID
	local playerHero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[player + 1]
	local line_duration = 7.0
	Notifications:BottomToAll({hero = playerHero:GetName(), duration = line_duration})
	Notifications:BottomToAll({text = PlayerResource:GetPlayerName(player).." ", duration = line_duration, continue = true})
	Notifications:BottomToAll({text = "#imba_player_gold_share_message", duration = line_duration, style = {color = "DodgerBlue"}, continue = true})
	Timers:CreateTimer(1.0, function()
			if PlayerResource:GetConnectionState(player) == DOTA_CONNECTION_STATE_CONNECTED then
				return nil
			end
			local pl = 0
			for i=0, 19 do
				if CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1] and CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetTeamNumber() == playerHero:GetTeamNumber() and i ~= player then
					pl = pl + 1
				end
			end
			local gold = PlayerResource:GetGold(player) / pl
			PlayerResource:SetGold(player, 0, false)
			for i=0, 19 do
				if CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1] and CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetTeamNumber() == playerHero:GetTeamNumber() and i ~= player then
					PlayerResource:ModifyGold(i, gold, false, DOTA_ModifyGold_SharedGold)
					SendOverheadEventMessage(PlayerResource:GetPlayer(i), OVERHEAD_ALERT_GOLD, CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1], gold, PlayerResource:GetPlayer(i))
				end
			end
			return 60.0
		end
	)
end

function IMBA:SendHTTPRequest(sWeb, uHEAD, iRetry, hCallback)
	local retry = iRetry or 0
	local http_string = sWeb and IMBA_WEB_SERVER..sWeb or IMBA_WEB_SERVER
	http_string = http_string.."?key="..IMBA_WEB_KEY.."&"
	if uHEAD then
		for k, v in pairs(uHEAD) do
			http_string = http_string..tostring(k).."="..tostring(v).."&"
		end
	end
	local req = CreateHTTPRequestScriptVM("GET", http_string)
	req:Send(function(res)
		if res.StatusCode ~= 200 and retry <= 10 then
			retry = retry + 1
			print("HTTP ERROR CODE:", res.StatusCode)
			print("Retry..."..retry)
			IMBA:SendHTTPRequest(sWeb, uHEAD, retry, hCallback)
		else
			if res.StatusCode == 200 then
				if hCallback then
					hCallback(res)
				else
					print(res.Body)
				end
			else
				print("HTTP ERROR CODE:", res.StatusCode)
			end
		end
	end)
end

function IMBA:EndGameAPI(iWinnerTeam)
	IMBA:SendHTTPRequest("imba_end_match.php", {["match_id"] = GameRules:GetMatchID(), ["map_name"] = GetMapName()})
	for i=0, 19 do
		if CDOTA_PlayerResource.IMBA_PLAYER_HERO[i+1] and not PlayerResource:IsFakeClient(i) then
			local hero = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i+1]
			local team = hero:GetTeamNumber()
			local win = team == iWinnerTeam and 1 or 0
			local moons = hero:GetModifierStackCount("modifier_imba_moon_shard_consume", nil)
			local scepter = hero:HasScepter() and 1 or 0
			local order = hero.order or 0
			local infoTable = {["map_name"] = GetMapName(), ["match_id"] = GameRules:GetMatchID(), ["is_win"] = win, ["steamid_64"] = PlayerResource:GetSteamID(i), ["player_name"] = PlayerResource:GetPlayerName(i), ["player_hero"] = hero:GetUnitName(), ["kills"] = PlayerResource:GetKills(i), ["deaths"] = PlayerResource:GetDeaths(i), ["assists"] = PlayerResource:GetAssists(i), ["gpm"] = PlayerResource:GetGoldPerMin(i), ["order"] = order, ["damage"] = PlayerResource:GetRawPlayerDamage(i), ["moon_shard"] = moons, ["scepter"] = scepter, ["game_version"] = IMBA_GAME_VERSION}
			for i=0, 8 do
				local item = hero:GetItemInSlot(i)
				if item then
					infoTable["item_"..i+1] = item:GetName()
				end
			end
			local index = 1
			for i=0, 23 do
				local ability = hero:GetAbilityByIndex(i)
				if ability and string.find(ability:GetAbilityName(), "special_bonus_") and ability:GetLevel() > 0 then
					infoTable["talent_"..index] = ability:GetAbilityName()
					index = index + 1
				end
			end
			local player_table = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(i))
			--PrintTable(player_table)
			for k,v in pairs(player_table) do
				infoTable[k] = v
			end
			PrintTable(infoTable)
			IMBA:SendHTTPRequest("imba_end_game_player.php", infoTable)
		end
	end
end