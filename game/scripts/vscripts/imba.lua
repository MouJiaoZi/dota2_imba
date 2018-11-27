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
end


function IMBA:BountyRuneFilter(keys)
	--[[
	gold_bounty: 40
	player_id_const: 0
	xp_bounty: 0
	]]
	local hero = PlayerResource:GetPlayer(keys.player_id_const):GetAssignedHero()
	hero:AddNewModifier(hero, nil, "modifier_imba_rune_bounty", {duration = 30})

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

	--[[if target:GetUnitName() == "npc_dota_badguys_fort" or target:GetUnitName() == "npc_dota_goodguys_fort" then
		if attacker and not attacker:IsRealHero() then
			attacker:ForceKill(false)
		end
		return false
	end]]


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

	if RollPercentage(target:GetTalentValue("special_bonus_imba_faceless_void_2")) then
		if attacker and attacker:GetName() == "dota_fountain" then
			--nothing
		else
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_faceless_void/faceless_void_backtrack.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:ReleaseParticleIndex(pfx)
			return false
		end
	end

	------------------------------------------------------------------------------------
	-- IMBA Physical Cirt Attack Logic
	------------------------------------------------------------------------------------

	if attacker and not ability and damage_type == DAMAGE_TYPE_PHYSICAL and not target:IsBuilding() and not target:IsOther() then
		local cirtBuffs = {}
		local cirtbuff = {}
		for _, buff in pairs(attacker_buffs) do
			if buff.GetIMBAPhysicalCirtChance and buff.GetIMBAPhysicalCirtBonus and type(buff:GetIMBAPhysicalCirtChance()) == "number" and type(buff:GetIMBAPhysicalCirtBonus()) == "number" and RollPercentage(buff:GetIMBAPhysicalCirtChance()) then
				--print(buff:GetName(), buff:GetIMBAPhysicalCirtChance(), GameRules:GetGameTime())
				cirtBuffs[#cirtBuffs + 1] = {buff, buff:GetIMBAPhysicalCirtBonus()}
				cirtbuff[#cirtbuff + 1] = buff
			end
		end
		if #cirtBuffs > 0 then
			table.sort(cirtBuffs, function(a, b) if a[2]>b[2] then return true end end )
			local cirtbuff = cirtBuffs[1][1]
			local cirtbonus = cirtBuffs[1][2] / 100
			red_cirt = true
			keys.damage = keys.damage * cirtbonus
			if cirtbuff.OnTriggerIMBAPhyicalCirt then
				cirtbuff:OnTriggerIMBAPhyicalCirt({damage = keys.damage, target = target})
			end
		end
		for _, buff in pairs(attacker_buffs) do
			if buff.GetIMBAPhysicalCirtChance and buff.GetIMBAPhysicalCirtBonus and type(buff:GetIMBAPhysicalCirtChance()) == "number" and type(buff:GetIMBAPhysicalCirtBonus()) == "number" and buff.OnNotTriggerIMBAPhyicalCirt and not IsInTable(buff, cirtbuff) then
				buff:OnNotTriggerIMBAPhyicalCirt(target)
			end
		end
	end

	------------------------------------------------------------------------------------
	-- Necrolyte Reapers Scythe Logic
	------------------------------------------------------------------------------------

	if target:HasModifier("modifier_imba_reapers_scythe_stundummy") then
		local scythe = target:FindModifierByName("modifier_imba_reapers_scythe_stundummy")
		if scythe and scythe:GetCaster() and scythe:GetAbility() and scythe:GetAbility() ~= ability and scythe:GetCaster() ~= attacker then
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

	if target:GetHealth() <= keys.damage and target:GetName() ~= "npc_dota_roshan" and not target:IsIllusion() then
		for i=0, 5 do
			local item = target:GetItemInSlot(i)
			if item and not item:IsNull() and item:GetName() == "item_imba_cheese" and item:IsCooldownReady() then
				item:OnSpellStart()
				item:UseResources(true, true, true)
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
	-- Remove item from Roshan
	------------------------------------------------------------------------------------

	if target:IsBoss() and keys.damage >= target:GetHealth() then
		for i=0, 8 do
			local item = target:GetItemInSlot(i)
			if item and (item:GetName() == "item_imba_greater_crit" or item:GetName() == "item_imba_reverb_rapier" or item:GetName() == "item_imba_monkey_king_bar") then
				target:RemoveItem(item)
			end
		end
	end

	------------------------------------------------------------------------------------
	-- True Hero Killed
	------------------------------------------------------------------------------------

	if target:IsRealHero() and keys.damage >= target:GetHealth() and IsInTable(target, CDOTA_PlayerResource.IMBA_PLAYER_HERO) then
		local victim = target
		local game_time = GameRules:GetDOTATime(false, false)
		local base_gold = victim:GetLevel() * 10
		if game_time > 90 then
			base_gold = base_gold + PlayerResource:GetGoldPerMin(victim:GetPlayerID()) * 0.05
		end
		local bounty = base_gold * math.max((1 - PlayerResource.IMBA_PLAYER_DEATH_STREAK[victim:GetPlayerID() + 1] / 10), 0)
		bounty = bounty * (1 + CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[victim:GetPlayerID() + 1] / 10)
		victim:SetMinimumGoldBounty(bounty)
		victim:SetMaximumGoldBounty(bounty)
		local hero_level = victim:GetLevel()
		local xp = HERO_XP_BOUNTY_PER_LEVEL[hero_level]
		xp = xp * (1 + CDOTA_PlayerResource.IMBA_PLAYER_KILL_STREAK[victim:GetPlayerID() + 1] / 10)
		victim:SetCustomDeathXP(xp)
		if PlayerResource:GetConnectionState(victim:GetPlayerID()) == DOTA_CONNECTION_STATE_ABANDONED then
			victim:SetMinimumGoldBounty(0)
			victim:SetMaximumGoldBounty(0)
		end

		Timers:CreateTimer(0.1, function()
				if not victim:IsAlive() and not victim:IsReincarnating() then
					local player_id = victim:GetPlayerID()
					local game_time = GameRules:GetDOTATime(false, false)

					local respawn_timer = victim:GetIMBARespawnTime()

					if game_time > 1800 then
						respawn_timer = respawn_timer + math.floor((game_time - 1800) / 60)
						GameRules:SetSafeToLeave(true)
					end

					-- Set up the respawn timer
					victim:SetTimeUntilRespawn(respawn_timer)

					local buy_back_cost = 0

					buy_back_cost = BUYBACK_BASE_COST + PlayerResource:GetGoldSpentOnBuybacks(victim:GetPlayerID()) / 20 + math.min(victim:GetLevel(), 25) * BUYBACK_COST_PER_LEVEL + math.max(victim:GetLevel() - 25, 0) * BUYBACK_COST_PER_LEVEL_AFTER_25 + game_time * BUYBACK_COST_PER_SECOND

					if GameRules:IsCheatMode() then
						--buy_back_cost = 0
					end

					PlayerResource:SetCustomBuybackCost(victim:GetPlayerID(), buy_back_cost)

					-- Setup buyback cooldown
					local buyback_cooldown = 0
					if BUYBACK_COOLDOWN_ENABLED and game_time > BUYBACK_COOLDOWN_START_POINT then
						buyback_cooldown = math.min(BUYBACK_COOLDOWN_GROW_FACTOR * (game_time - BUYBACK_COOLDOWN_START_POINT), BUYBACK_COOLDOWN_MAXIMUM)
					end

					PlayerResource:SetCustomBuybackCooldown(player_id, buyback_cooldown)
					--Lose Gold
					local maxLoseGold = PlayerResource:GetUnreliableGold(victim:GetPlayerID())
					local netWorth = PlayerResource:GetGoldSpentOnItems(victim:GetPlayerID())
					PlayerResource:ModifyGold(victim:GetPlayerID(), 0 - math.min(maxLoseGold, 50 + netWorth / 40), false, DOTA_ModifyGold_Death)

					print(victim:GetName(), "respawn time:", respawn_timer, "bb cd:", buyback_cooldown, "bb cost:", buy_back_cost, "lose gold:", math.min(maxLoseGold, 50 + netWorth / 40))

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
				end
				return nil
			end
		)
	end

	------------------------------------------------------------------------------------
	-- Courier Set
	------------------------------------------------------------------------------------

	if target:IsCourier() and target:HasModifier("modifier_imba_courier_marker") and not target:HasModifier("modifier_fountain_aura_buff") and target:GetHealth() <= keys.damage then
		local buff = target:FindModifierByName("modifier_imba_courier_marker")
		if buff then
			target:AddNewModifierWhenPossible(buff:GetCaster(), nil, "modifier_imba_courier_prevent", {duration = 600})
		end
	end

	if red_cirt then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, keys.damage, nil)
	end

	return true
end

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

	------------------------------------------------------------------------------------
	-- Courier Set
	------------------------------------------------------------------------------------

	if unit:IsCourier() then
		local hero = PlayerResource:GetPlayer(keys.issuer_player_id_const):GetAssignedHero()
		if hero then
			unit:RemoveModifierByName("modifier_imba_courier_marker")
			unit:AddNewModifier(hero, nil, "modifier_imba_courier_marker", {})
			if unit:FindModifierByNameAndCaster("modifier_imba_courier_prevent", hero) then
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
	-- Boulder Smash Cast Range
	------------------------------------------------------------------------------------

	--[[if keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET and EntIndexToHScript(keys.entindex_ability):GetName() == "imba_earth_spirit_boulder_smash" then
		local ability = EntIndexToHScript(keys.entindex_ability)
		ability.range = 0
	end]]

	if (keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION or keys.order_type == DOTA_UNIT_ORDER_CAST_TARGET) and EntIndexToHScript(keys.entindex_ability):GetName() == "imba_earth_spirit_boulder_smash" then
		local ability = EntIndexToHScript(keys.entindex_ability)
		if keys.order_type == DOTA_UNIT_ORDER_CAST_POSITION or FindStoneRemnant(ability:GetCaster():GetAbsOrigin(), ability:GetSpecialValueFor("rock_search_aoe")) then
			ability.range = 50000
		else
			ability.range = 0
		end
	end

	------------------------------------------------------------------------------------
	-- Prevent Couire Pick Up Rapier
	------------------------------------------------------------------------------------

	--[[if keys.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then
		local item = EntIndexToHScript(keys["entindex_target"])
		print(unit:GetName(), item:GetName())
		if (unit:IsTempestDouble() or not unit:IsRealHero() or unit:IsCourier()) and (item:GetName() == "item_imba_rapier" or item:GetName() == "item_imba_rapier_2" or item:GetName() == "item_imba_rapier_magic" or item:GetName() == "item_imba_rapier_magic_2" or item:GetName() == "item_imba_rapier_cursed") then
			return false
		end
	end]]

	------------------------------------------------------------------------------------
	-- Queen of Pain's Sonic Wave confusion
	------------------------------------------------------------------------------------

	local buffs = unit:FindAllModifiers()
	local confuse = false
	for _, buff in pairs(buffs) do
		if buff.IsConfuse and buff:IsConfuse() then
			confuse = true
			break
		end
	end

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

	if ability then
		local healamp = target:GetIncomingHealAmp() / 100
		keys.heal = keys.heal * (1 + healamp)
	end

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

	if item:GetName() == "item_aegis" and picker:GetUnitName() ~= "npc_dota_roshan" then
		UTIL_Remove(item)
		picker:AddNewModifier(picker, nil, "modifier_imba_aegis", {duration = 300.0})
		return false
	end

	if picker and picker:IsCourier() and string.find(item:GetName(), "item_imba_rapier") then
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

	-- volvo bugfix
	if modifier_name == "modifier_datadriven" then
		return false
	end

	-- don't add buyback penalty
	if modifier_name == "modifier_buyback_gold_penalty" then
		return false
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
		target:AddNewModifier(target, nil, "modifier_imba_rune_arcane", {duration = 30.0})
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

	if RollPercentage(target:GetTalentValue("special_bonus_imba_faceless_void_2")) and caster and IsEnemy(caster, target) then
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

	keys.gold = keys.gold * ((100 + CUSTOM_GOLD_BONUS) / 100)

	local hero = PlayerResource:GetPlayer(keys.player_id_const):GetAssignedHero()

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

	local items = {"item_imba_greater_crit", "item_imba_reverb_rapier", "item_imba_monkey_king_bar"}

	for i=1, 3 do
		if RollPercentage(roshan_kill * 3) then
			unit:AddItemByName(items[i])
		end
	end

	--- IMBA Roshan Set
	SetCreatureHealth(unit, 12000 + (roshan_kill - 1) * 2000, true)
	--local ability1 = unit:AddAbility("huskar_berserkers_blood")
	--ability1:SetLevel(4)
	local buff1 = unit:AddNewModifier(unit, nil, "modifier_imba_roshan_upgrade", {})
	buff1:SetStackCount(roshan_kill - 1)
	local buff2 = unit:AddNewModifier(unit, nil, "modifier_roshan_devotion", {})
	buff2:SetStackCount(roshan_kill - 1)
	---
	if roshan_kill >= 2 then
		unit:AddItemByName("item_imba_cheese")
	end
	if roshan_kill >= 5 then
		unit:AddItemByName("item_refresher_shard")
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
		if enemy:IsRealHero() and not enemy:IsClone() and not enemy:IsTempestDouble() and not enemy:IsCreep() and not enemy:IsCreature() then
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

function IMBA:StartGameAPI()
	IMBA_GAME_ID = GameRules:GetMatchID()
	if tostring(IMBA_GAME_ID) == "0" then
		IMBA_GAME_ID = RandomInt(0,100000)..RandomInt(0,100000).."000000"
	end
	local json = {}
	json["game_id"] = tostring(IMBA_GAME_ID)
	json["game_map"] = GetMapName()
	json["start_time"] = tostring(GetSystemDate().." "..GetSystemTime())
	local js = luaJson.table2json(json)
	local request = CreateHTTPRequestScriptVM("GET", "http://181.215.128.41/game_reg.php")
	request:SetHTTPRequestGetOrPostParameter("game_reg", js)
	request:Send(function(result)
		print(result.Body)
	end )

end

function IMBA:EndGameAPI()
	local endjson = {}
	endjson["game_id"] = tostring(IMBA_GAME_ID)
	endjson["game_duration"] = tostring(GameRules:GetDOTATime(true, true))
	endjson["end_time"] = tostring(GetSystemDate().." "..GetSystemTime())
	local endjs = luaJson.table2json(endjson)
	local request = CreateHTTPRequestScriptVM("GET", "http://181.215.128.41/game_end_time.php")
	request:SetHTTPRequestGetOrPostParameter("game_reg", endjs)
	request:Send(function(result)
		print("end", result.Body)
	end )

	for i=0, 19 do
		if PlayerResource:IsValidPlayerID(i) and PlayerResource:GetPlayer(i):GetAssignedHero() then
			local hero = PlayerResource:GetPlayer(i):GetAssignedHero()
			local json_basic = {}
			json_basic["game_id"] = tostring(IMBA_GAME_ID)
			json_basic["steam_id"] = tostring(PlayerResource:GetSteamID(i))
			json_basic["hero"] = hero:GetName()
			json_basic["team"] = tostring(hero:GetTeamNumber())
			json_basic["win"] = (hero:GetTeamNumber() == GAME_WINNER_TEAM and "1" or "0") -- win or lose
			json_basic["gpm"] = tostring(PlayerResource:GetGoldPerMin(i)) -- GPM
			json_basic["damage"] = tostring(PlayerResource:GetRawPlayerDamage(i)) -- DMG 
			json_basic["kills"] = tostring(PlayerResource:GetKills(i))
			json_basic["deaths"] = tostring(PlayerResource:GetDeaths(i))
			json_basic["assists"] = tostring(PlayerResource:GetAssists(i))

			local json_talent = {}
			json_talent["game_id"] = tostring(IMBA_GAME_ID)
			json_talent["steam_id"] = tostring(PlayerResource:GetSteamID(i))
			local talent = 1 -- get talent learnt
			for j=0, 23 do
				local ability = hero:GetAbilityByIndex(j)
				if ability and string.find(ability:GetAbilityName(), "special_bonus_") and ability:GetLevel() > 0 then
					json_talent["talent_"..talent] = ability:GetAbilityName()
					talent = talent + 1
				end
			end
			for j=1,8 do
				if not json_talent["talent_"..j] then
					json_talent["talent_"..j] = "no_talent"
				end
			end

			local json_item = {}
			json_item["game_id"] = tostring(IMBA_GAME_ID)
			json_item["steam_id"] = tostring(PlayerResource:GetSteamID(i))
			for j=0, 8 do
				local item = hero:GetItemInSlot(j)
				if item then
					json_item["item_"..(j+1)] = item:GetName()
				else
					json_item["item_"..(j+1)] = "no_item"
				end
			end

			local js = luaJson.table2json(json_basic)
			local js2 = luaJson.table2json(json_talent)
			local js3 = luaJson.table2json(json_item)

			local req = CreateHTTPRequestScriptVM("GET", "http://181.215.128.41/game_end_player_basic.php")
			req:SetHTTPRequestGetOrPostParameter("game_reg", js)
			req:Send(function(result)
				print(result.Body)
			end )
			local req2 = CreateHTTPRequestScriptVM("GET", "http://181.215.128.41/game_end_player_talents.php")
			req2:SetHTTPRequestGetOrPostParameter("game_reg", js2)
			req2:Send(function(result)
				print(result.Body)
			end )
			local req3 = CreateHTTPRequestScriptVM("GET", "http://181.215.128.41/game_end_player_items.php")
			req3:SetHTTPRequestGetOrPostParameter("game_reg", js3)
			req3:Send(function(result)
				print(result.Body)
			end )
		end
	end
end

function IMBA:ChangeUnitProjectile(hNPC, hModifier)
	if hModifier and hModifier.GetIMBAProjectileName and type(hModifier:GetIMBAProjectileName()) == "string" then
		hNPC:SetRangedProjectileName(hModifier:GetIMBAProjectileName())
	end
	if not hModifier then
		local buffs = hNPC:FindAllModifiers()
		for _, buff in pairs(buffs) do
			if buff.GetIMBAProjectileName and type(buff:GetIMBAProjectileName()) == "string" then
				hNPC:SetRangedProjectileName(buff:GetIMBAProjectileName())
				return
			end
		end
		local pfx = ""
		if hNPC:IsHero() then
			pfx = HeroKV[hNPC:GetUnitName()]['ProjectileModel'] or HeroKVBase[hNPC:GetUnitName()]['ProjectileModel']
		else
			pfx = UnitKV[hNPC:GetUnitName()]['ProjectileModel'] or UnitKVBase[hNPC:GetUnitName()]['ProjectileModel']
		end
		hNPC:SetRangedProjectileName(pfx)
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

function SetPlayerInfo()
	for i=0, 19 do
		if PlayerResource:IsValidPlayerID(i) and CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1] then
			local team = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetTeamNumber()
			local playerTable = {PlayerResource:GetSteamID(i), PlayerResource:GetPlayerName(i), CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetName(), team}
			CustomNetTables:SetTableValue("imba_player_base", tostring(i), playerTable)
		end
	end
end

local endover = false

function UpDatePlayerInfo()
	if endover then
		return
	end
	--SetPlayerInfo()
	endover = true
	for i=0, 19 do
		if PlayerResource:IsValidPlayerID(i) and CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1] then
			local team = PlayerResource:GetPlayer(i):GetAssignedHero():GetTeamNumber()
			local playerTable = {PlayerResource:GetGold(i),}
			for j=0, 8 do
				local item = CDOTA_PlayerResource.IMBA_PLAYER_HERO[i + 1]:GetItemInSlot(j)
				if item then
					playerTable[#playerTable + 1] = item:GetName()
				else
					playerTable[#playerTable + 1] = "item_imba_dummy"
				end
			end
			CustomNetTables:SetTableValue("imba_player_info", tostring(i), playerTable)
		end
	end
end