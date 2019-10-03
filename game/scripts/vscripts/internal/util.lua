
-- Adds [stack_amount] stacks to a modifier
function AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
	if unit:HasModifier(modifier) then
		if refresh then
			ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		end
		unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
	else
		ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		unit:SetModifierStackCount(modifier, ability, stack_amount)
	end
end

-- Adds [stack_amount] stacks to a lua-based modifier
function AddStacksLua(ability, caster, unit, modifier, stack_amount, refresh)
	if unit:HasModifier(modifier) then
		if refresh then
			unit:AddNewModifier(caster, ability, modifier, {})
		end
		unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
	else
		unit:AddNewModifier(caster, ability, modifier, {})
		unit:SetModifierStackCount(modifier, ability, stack_amount)
	end
end

-- Removes [stack_amount] stacks from a modifier
function RemoveStacks(ability, unit, modifier, stack_amount)
	if unit:HasModifier(modifier) then
		if unit:GetModifierStackCount(modifier, ability) > stack_amount then
			unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, ability) - stack_amount)
		else
			unit:RemoveModifierByName(modifier)
		end
	end
end

-- Switches one skill with another
function SwitchAbilities(hero, added_ability_name, removed_ability_name, keep_level, keep_cooldown)
	local removed_ability = hero:FindAbilityByName(removed_ability_name)
	local level = removed_ability:GetLevel()
	local cooldown = removed_ability:GetCooldownTimeRemaining()
	hero:RemoveAbility(removed_ability_name)
	hero:AddAbility(added_ability_name)
	local added_ability = hero:FindAbilityByName(added_ability_name)
	
	if keep_level then
		added_ability:SetLevel(level)
	end
	
	if keep_cooldown then
		added_ability:StartCooldown(cooldown)
	end
end

-- Removes unwanted passive modifiers from illusions upon their creation
function IllusionPassiveRemover( keys )
	local target = keys.target
	local modifier = keys.modifier

	if target:IsIllusion() or not target:GetPlayerOwner() then
		target:RemoveModifierByName(modifier)
	end
end

function ApplyDataDrivenModifierWhenPossible( caster, target, ability, modifier_name)
	Timers:CreateTimer(0, function()
		if target:IsOutOfGame() or target:IsInvulnerable() then
			return 0.1
		else
			ability:ApplyDataDrivenModifier(caster, target, modifier_name, {})
		end			
	end)
end

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	A helper method that switches the removed_item item to one with the inputted name.
================================================================================================================= ]]
function SwapToItem(caster, removed_item, added_item)
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = caster:GetItemInSlot(i)
		if current_item == nil then
			caster:AddItem(CreateItem("item_imba_dummy", caster, caster))
		end
	end
	
	caster:RemoveItem(removed_item)
	caster:AddItem(CreateItem(added_item, caster, caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_imba_dummy" then
				caster:RemoveItem(current_item)
			end
		end
	end
end



function DebugPrint(...)
	--local spew = Convars:GetInt('barebones_spew') or -1
	--if spew == -1 and BAREBONES_DEBUG_SPEW then
	--spew = 1
	--end

	--if spew == 1 then
	--print(...)
	--end
end

function DebugPrintTable(...)
	--local spew = Convars:GetInt('barebones_spew') or -1
	--if spew == -1 and BAREBONES_DEBUG_SPEW then
	--spew = 1
	--end

	--if spew == 1 then
	--PrintTable(...)
	--end
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
	table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
	-- Ignore FDesc
	if v ~= 'FDesc' then
		local value = t[v]

		if type(value) == "table" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..":")
		PrintTable (value, indent + 2, done)
		elseif type(value) == "userdata" and not done[value] then
		done [value] = true
		print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
		else
		if t.FDesc and t.FDesc[v] then
			print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
		else
			print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
		end
		end
	end
	end
end

key = ""
function GoodPrintTable(table , level)
	level = level or 1
	local indent = ""
	for i = 1, level do
		indent = indent.."  "
	end

	if key ~= "" then
		print(indent..key.." ".."=".." ".."{")
	else
		print(indent .. "{")
	end

	key = ""
	for k,v in pairs(table) do
		if type(v) == "table" then
			key = k
			PrintTable(v, level + 1)
		else
			local content = string.format("%s%s = %s", indent .. "  ",tostring(k), tostring(v))
			print(content)  
		end
	end
	print(indent .. "}")
end


-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

-- Returns a random value from a non-array table
function RandomFromTable(hTable)
	if #hTable == 0 then return nil end
	return hTable[RandomInt(1,#hTable)]
end

-------------------------------------------------------------------------------------------------
-- IMBA: custom utility functions
-------------------------------------------------------------------------------------------------

--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	A helper method that switches the removed_item item to one with the inputted name.
================================================================================================================= ]]
function SwapToItem(caster, removed_item, added_item)
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		local current_item = caster:GetItemInSlot(i)
		if current_item == nil then
			caster:AddItem(CreateItem("item_imba_dummy", caster, caster))
		end
	end
	
	caster:RemoveItem(removed_item)
	caster:AddItem(CreateItem(added_item, caster, caster))  --This should be put into the same slot that the removed item was in.
	
	for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		local current_item = caster:GetItemInSlot(i)
		if current_item ~= nil then
			if current_item:GetName() == "item_imba_dummy" then
				caster:RemoveItem(current_item)
			end
		end
	end
end

function KillPre(caster, target, ability)
	-- Shallow Grave is peskier
	target:RemoveModifierByName("modifier_imba_shallow_grave")

	-- Extremely specific blademail interaction because fuck everything
	if caster:HasModifier("modifier_item_blade_mail_reflect") then
		target:RemoveModifierByName("modifier_imba_purification_passive")
	end

	-- Deals lethal damage in order to trigger death-preventing abilities... Except for Reincarnation
	if not ( target:HasModifier("modifier_imba_reincarnation") or target:HasModifier("modifier_imba_reincarnation_scepter") ) then
		target:Kill(ability, caster)
	end

	-- Removes the relevant modifiers
	target:RemoveModifierByName("modifier_invulnerable")
	target:RemoveModifierByName("modifier_imba_shallow_grave")
	target:RemoveModifierByName("modifier_imba_aphotic_shield")
	target:RemoveModifierByName("modifier_imba_spiked_carapace")
	target:RemoveModifierByName("modifier_borrowed_time")
	target:RemoveModifierByName("modifier_imba_centaur_return")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_unique")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_active")
	target:RemoveModifierByName("modifier_item_crimson_guard_unique")
	target:RemoveModifierByName("modifier_item_crimson_guard_active")
	target:RemoveModifierByName("modifier_item_greatwyrm_plate_unique")
	target:RemoveModifierByName("modifier_item_vanguard_unique")
	target:RemoveModifierByName("modifier_item_imba_initiate_robe_stacks")
	target:RemoveModifierByName("modifier_imba_cheese_death_prevention")
	target:RemoveModifierByName("modifier_item_imba_rapier_cursed_unique")
	target:RemoveModifierByName("modifier_imba_reincarnation_scepter_aura")
	target:RemoveModifierByName("modifier_imba_vampiric_aura_effect")
	target:RemoveModifierByName("modifier_imba_balde_mail_2_active")
	target:RemoveModifierByName("modifier_imba_vampiric_aura_effect")
	target:RemoveModifierByName("modifier_legion_commander_duel")
end

-- 100% kills a unit. Activates death-preventing modifiers, then removes them. Does not killsteal from Reaper's Scythe.
function TrueKill(caster, target, ability)
	KillPre(caster, target, ability)
	-- Kills the target
	target:Kill(ability, caster)
end

function TrueKill2(caster, target, ability)
	KillPre(caster, target, ability)
	-- Kills the target
	target:ForceKill(false)
end

-- Checks if a unit is near units of a certain class not on its team
function IsNearEnemyClass(unit, radius, class)
	local class_units = Entities:FindAllByClassnameWithin(class, unit:GetAbsOrigin(), radius)

	for _,found_unit in pairs(class_units) do
		if found_unit:GetTeam() ~= unit:GetTeam() then
			return true
		end
	end
	
	return false
end

-- Checks if a unit is near units of a certain class on the same team
function IsNearFriendlyClass(unit, radius, class)
	local class_units = Entities:FindAllByClassnameWithin(class, unit:GetAbsOrigin(), radius)

	for _,found_unit in pairs(class_units) do
		if found_unit:GetTeam() == unit:GetTeam() then
			return true
		end
	end
	
	return false
end

function IsNearFriendlyEntityPoint(pos, radius, class)
	local class_units = Entities:FindAllByNameWithin(class, pos, radius)

	if #class_units > 0 then
		return true
	end
	
	return false
end

-- Returns if this unit is a fountain or not
function IsFountain( unit )
	if unit:GetName() == "ent_dota_fountain_bad" or unit:GetName() == "ent_dota_fountain_good" then
		return true
	end
	
	return false
end

-- Returns true if the target is hard disabled
function IsHardDisabled( unit )
	if unit:IsStunned() or unit:IsHexed() or unit:IsNightmared() or unit:IsOutOfGame() or unit:HasModifier("modifier_axe_berserkers_call") then
		return true
	end

	return false
end

-- Precaches an unit, or, if something else is being precached, enters it into the precache queue
function PrecacheUnitWithQueue(unit_name)
	if not IsInTable(unit_name, PRECACHED_UNIT) then
		table.insert(PRECACHED_UNIT, unit_name)
		Timers:CreateTimer({
			useGameTime = false,
			endTime = FrameTime(), -- when this timer should first execute, you can omit this if you want it to run first on the next frame
			callback = function()
				-- If something else is being precached, wait two seconds
				if UNIT_BEING_PRECACHED then
					return 2.0

				-- Otherwise, start precaching and block other calls from doing so
				else
					UNIT_BEING_PRECACHED = true
					print("Unit "..unit_name.." precaching...")
					PrecacheUnitByNameAsync(unit_name, function()
						UNIT_BEING_PRECACHED = false
					end)
					return nil
				end
			end
		})
	end
end

-- Simulates attack speed cap removal to a single unit through BAT manipulation
function IncreaseAttackSpeedCap(unit, new_cap)

	-- Fetch original BAT if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit:GetBaseAttackTime()
	end

	--[[ Get current attack speed, limited to new_cap
	local buffs = unit:FindAllModifiers()
	local as = 0
	for _, buff in pairs(buffs) do
		if buff.GetModifierAttackSpeedBonus_Constant then
			as = as + buff:GetModifierAttackSpeedBonus_Constant()
		end
	end
	if unit:IsHero() then
		local agi_as = GameRules:GetGameModeEntity():GetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, unit)
		as = as + agi_as * unit:GetAgility()
	end]]
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(new_cap)
	local as = unit:GetAttackSpeed() * 100
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed(MAXIMUM_ATTACK_SPEED)

	local current_as = math.min(as, new_cap)

	-- Should we reduce BAT?
	if current_as > MAXIMUM_ATTACK_SPEED then
		local new_bat = MAXIMUM_ATTACK_SPEED / current_as * unit:GetDefaultBAT()
		unit:SetBaseAttackTime(new_bat)
	else
		RevertAttackSpeedCap(unit)
	end
end

-- Returns a unit's attack speed cap
function RevertAttackSpeedCap( unit )

	-- Return to original BAT
	unit:SetBaseAttackTime(unit:GetDefaultBAT())

end

-- Sets a creature's max health to [health]
function SetCreatureHealth(unit, health, update_current_health)

	unit:SetBaseMaxHealth(health)
	unit:SetMaxHealth(health)

	if update_current_health then
		unit:SetHealth(health)
	end
end

function RemoveWearables( hero )

	-- Setup variables
	Timers:CreateTimer(0.1, function()
		hero.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
		local model = hero:FirstMoveChild()
		while model ~= nil do
			if model:GetClassname() == "dota_item_wearable" then
				model:AddEffects(EF_NODRAW) -- Set model hidden
				table.insert(hero.hiddenWearables, model)
			end
			model = model:NextMovePeer()
		end
	end)
end

function ShowWearables( event )
  local hero = event.caster

  for i,v in pairs(hero.hiddenWearables) do
	v:RemoveEffects(EF_NODRAW)
  end
end

function GetBaseRangedProjectileName( unit )
	local unit_name = unit:GetUnitName()
	unit_name = string.gsub(unit_name, "dota", "imba")
	local unit_table = unit:IsHero() and GameRules.HeroKV[unit_name] or GameRules.UnitKV[unit_name]
	return unit_table and unit_table["ProjectileModel"] or ""
end

function IsUninterruptableForcedMovement( unit )
	
	-- List of uninterruptable movement modifiers
	local modifier_list = {
		"modifier_spirit_breaker_charge_of_darkness",
		"modifier_magnataur_skewer_movement",
		"modifier_invoker_deafening_blast_knockback",
		"modifier_knockback",
		"modifier_item_forcestaff_active",
		"modifier_shredder_timber_chain",
		"modifier_batrider_flaming_lasso",
		"modifier_imba_leap_self_root",
		"modifier_faceless_void_chronosphere_freeze",
		"modifier_storm_spirit_ball_lightning",
		"modifier_morphling_waveform"
	}

	-- Iterate through the list
	for _,modifier_name in pairs(modifier_list) do
		if unit:HasModifier(modifier_name) then
			return true
		end
	end

	return false
end


-- Safely modify BAT while storing the unit's original value
function ModifyBAT(unit, modify_percent, modify_flat)

	-- Fetch base BAT if necessary
	if not unit.unmodified_bat then
		unit.unmodified_bat = unit:GetBaseAttackTime()
	end

	-- Create the current BAT variable if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit.unmodified_bat
	end

	-- Create the percent modifier variable if necessary
	if not unit.percent_bat_modifier then
		unit.percent_bat_modifier = 1
	end

	-- Create the flat modifier variable if necessary
	if not unit.flat_bat_modifier then
		unit.flat_bat_modifier = 0
	end

	-- Update BAT percent modifiers
	unit.percent_bat_modifier = unit.percent_bat_modifier * (100 + modify_percent) / 100

	-- Update BAT flat modifiers
	unit.flat_bat_modifier = unit.flat_bat_modifier + modify_flat

	-- Unmodified BAT special exceptions
	if unit:GetUnitName() == "npc_dota_hero_alchemist" then
		return nil
	end
	
	-- Update modifier BAT
	unit.current_modified_bat = (unit.unmodified_bat + unit.flat_bat_modifier) * unit.percent_bat_modifier

	-- Update unit's BAT
	unit:SetBaseAttackTime(unit.current_modified_bat)

end

-- Override all BAT modifiers and return the unit to its base value
function RevertBAT( unit )

	-- Fetch base BAT if necessary
	if not unit.unmodified_bat then
		unit.unmodified_bat = unit:GetBaseAttackTime()
	end

	-- Create the current BAT variable if necessary
	if not unit.current_modified_bat then
		unit.current_modified_bat = unit.unmodified_bat
	end

	-- Create the percent modifier variable if necessary
	if not unit.percent_bat_modifier then
		unit.percent_bat_modifier = 1
	end

	-- Create the flat modifier variable if necessary
	if not unit.flat_bat_modifier then
		unit.flat_bat_modifier = 0
	end

	-- Reset variables
	unit.percent_bat_modifier = 1
	unit.flat_bat_modifier = 0

	-- Reset BAT
	unit:SetBaseAttackTime(unit.unmodified_bat)

end

-- Detect hero-creeps with an inventory, like warlock golems or lone druid's bear
function IsHeroCreep( unit )
	return (unit:IsConsideredHero() and unit:IsCreep())
end

-- Changes the time of the day temporarily, memorizing the original time of the day to return to
function SetTimeOfDayTemp(time, duration)

	-- Store the original time of the day, if necessary
	local game_entity = GameRules:GetGameModeEntity()
	if not game_entity.tod_original_time then
		game_entity.tod_original_time = GameRules:GetTimeOfDay()
	end

	-- Initialize the time modification states, if necessary
	if not game_entity.tod_future_seconds then
		game_entity.tod_future_seconds = {}

		-- Start loop function
		Timers:CreateTimer(1, function()
			SetTimeOfDayTempLoop()
		end)
	end

	-- Store future time modification states
	for i = 1, duration do
		game_entity.tod_future_seconds[i] = time
	end

	-- Set the time of the day
	GameRules:SetTimeOfDay(time)
end

-- Auxiliary function to the one above
function SetTimeOfDayTempLoop()

	-- If there are no future time modification states, stop looping
	local game_entity = GameRules:GetGameModeEntity()
	if not game_entity.tod_future_seconds then
		return nil

	-- Else, move states one second forward
	elseif #game_entity.tod_future_seconds > 1 then
		for i = 1, (#game_entity.tod_future_seconds - 1) do
			game_entity.tod_future_seconds[i] = game_entity.tod_future_seconds[i + 1]
		end
		game_entity.tod_future_seconds[#game_entity.tod_future_seconds] = nil

		-- Keep the loop going
		GameRules:SetTimeOfDay(game_entity.tod_future_seconds[1])
		Timers:CreateTimer(1, function()
			SetTimeOfDayTempLoop()
		end)

	-- Else, the duration is over; restore the original time of the day, and exit the loop
	else
		game_entity.tod_future_seconds = nil
		Timers:CreateTimer(1, function()
			GameRules:SetTimeOfDay(game_entity.tod_original_time)
			game_entity.tod_original_time = nil
		end)
	end
end

-- Initialize Physics library on this target
function InitializePhysicsParameters(unit)

	if not IsPhysicsUnit(unit) then
		Physics:Unit(unit)
		unit:SetPhysicsVelocityMax(600)
		unit:PreventDI()
	end
end

-- Check if an unit is near the enemy fountain
function IsNearEnemyFountain(location, team, distance)

	local fountain_loc
	if team == DOTA_TEAM_GOODGUYS then
		fountain_loc = Vector(7472, 6912, 512)
	else
		fountain_loc = Vector(-7456, -6938, 528)
	end

	if (fountain_loc - location):Length2D() <= distance then
		return true
	end

	return false
end

-- Reaper's Scythe kill credit redirection
function TriggerNecrolyteReaperScytheDeath(target, caster)

	-- Find the Reaper's Scythe ability
	local ability = caster:FindAbilityByName("imba_necrolyte_reapers_scythe")
	if not ability then return nil end

	-- Attempt to kill the target
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = target:GetHealth(), damage_type = DAMAGE_TYPE_PURE})
end

function GetRandomPosition2D(vPosition, fRadius)
	local newPos = vPosition + Vector(1,0,0) * math.random(0-fRadius, fRadius)
	return RotatePosition(vPosition, QAngle(0,math.random(-360,360),0), newPos)
end

-- Finds units only on the outer layer of a ring
function FindUnitsInRing(teamNumber, position, cacheUnit, ring_radius, ring_width, teamFilter, typeFilter, flagFilter, order, canGrowCache)
	-- First checks all of the units in a radius
	local all_units	= FindUnitsInRadius(teamNumber, position, cacheUnit, ring_radius, teamFilter, typeFilter, flagFilter, order, canGrowCache)
	
	-- Then builds a table composed of the units that are in the outer ring, but not in the inner one.
	local outer_ring_units	=	{}

	for _,unit in pairs(all_units) do
		-- Custom function, checks if the unit is far enough away from the inner radius
		if CalculateDistance(unit:GetAbsOrigin(), position) >= ring_radius - ring_width then
			table.insert(outer_ring_units, unit)
		end
	end

	return outer_ring_units
end

-- Cleave-like cone search - returns the units in front of the caster in a cone.
function FindUnitsInCone(teamNumber, vDirection, vPosition, startRadius, endRadius, flLength, hCacheUnit, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local circle_r = math.sqrt(math.pow(endRadius / 2, 2) + math.pow(flLength, 2))
	local vDirectionCone = Vector( vDirection.y, -vDirection.x, 0.0 )
	local enemies = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, circle_r, targetTeam, targetUnit, targetFlags, findOrder, bCache )
	local unitTable = {}
	if #enemies > 0 then
		for _,enemy in pairs(enemies) do
			if enemy ~= nil then
				local vToPotentialTarget = enemy:GetOrigin() - vPosition
				local flSideAmount = math.abs( vToPotentialTarget.x * vDirectionCone.x + vToPotentialTarget.y * vDirectionCone.y + vToPotentialTarget.z * vDirectionCone.z )
				local enemy_distance_from_caster = ( vToPotentialTarget.x * vDirection.x + vToPotentialTarget.y * vDirection.y + vToPotentialTarget.z * vDirection.z )
				
				-- Author of this "increase over distance": Fudge, pretty proud of this :D 
				
				-- Calculate how much the width of the check can be higher than the starting point
				local max_increased_radius_from_distance = endRadius - startRadius
				
				-- Calculate how close the enemy is to the caster, in comparison to the total distance
				local pct_distance = enemy_distance_from_caster / flLength
				
				-- Calculate how much the width should be higher due to the distance of the enemy to the caster.
				local radius_increase_from_distance = max_increased_radius_from_distance * pct_distance
				
				if ( flSideAmount < startRadius + radius_increase_from_distance ) and ( enemy_distance_from_caster > 0.0 ) and ( enemy_distance_from_caster < flLength ) then
					table.insert(unitTable, enemy)
					--DebugDrawCircle(enemy:GetAbsOrigin(), Vector(255,0,0), 255, 30, false, 10)
				end
			end
		end
	end
	return unitTable
end

function FindUnitsInTrapezoid(teamNumber, vDirection, vPosition, startRadius, endRadius, flLength, hCacheUnit, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local circle_r = math.sqrt(math.pow(endRadius / 2, 2) + math.pow(flLength, 2))
	local enemy = FindUnitsInRadius(teamNumber, vPosition, hCacheUnit, circle_r, targetTeam, targetUnit, targetFlags, findOrder, bCache)
	local ta = {}
	local vStartPoint = {RotatePosition(vPosition, QAngle(0,90,0), vPosition + vDirection * (startRadius / 2)), RotatePosition(vPosition, QAngle(0,-90,0), vPosition + vDirection * (startRadius / 2))}
	local vEndPoint = {RotatePosition(vPosition + vDirection * flLength, QAngle(0,90,0), (vPosition + vDirection * flLength) + vDirection * (endRadius / 2)), RotatePosition(vPosition + vDirection * flLength, QAngle(0,-90,0), (vPosition + vDirection * flLength) + vDirection * (endRadius / 2))}
	local A = vStartPoint[1]
	local B = vEndPoint[1]
	local C = vEndPoint[2]
	local D = vStartPoint[2]
	if GameRules:IsCheatMode() then
		DebugDrawLine(A, B, 255, 0, 0, true, 5)
		DebugDrawLine(B, C, 255, 0, 0, true, 5)
		DebugDrawLine(C, D, 255, 0, 0, true, 5)
		DebugDrawLine(D, A, 255, 0, 0, true, 5)
	end
	for i=1, #enemy do
		local pos = enemy[i]:GetAbsOrigin()
		local a = (B.x - A.x) * (pos.y - A.y) - (B.y - A.y) * (pos.x - A.x)
		local b = (C.x - B.x) * (pos.y - B.y) - (C.y - B.y) * (pos.x - B.x)
		local c = (D.x - C.x) * (pos.y - C.y) - (D.y - C.y) * (pos.x - C.x)
		local d = (A.x - D.x) * (pos.y - D.y) - (A.y - D.y) * (pos.x - D.x)
		if (a >= 0 and b >= 0 and c >= 0 and d >= 0) or (a <= 0 and b <= 0 and c <= 0 and d <= 0) then
			table.insert(ta, enemy[i])
		end
	end
	return ta
end

function DoIMBACleaveAttack(hAttacker, hTarget, hAbility, fDamage, fStartRadius, fEndRadius, fDistance, sHitEffect)
	local target = hAttacker:IsRangedAttacker() and hTarget or hAttacker
	local direction = GetDirection2D(hTarget:GetAbsOrigin(), hAttacker:GetAbsOrigin())
	local enemy = FindUnitsInTrapezoid(hAttacker:GetTeamNumber(), direction, GetGroundPosition(target:GetAbsOrigin(), nil), fStartRadius, fEndRadius, fDistance, nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
	local pfx = nil
	if sHitEffect then
		pfx = ParticleManager:CreateParticle(sHitEffect, PATTACH_CUSTOMORIGIN, hAttacker)
		ParticleManager:SetParticleControl(pfx, 0, hAttacker:IsRangedAttacker() and hTarget:GetAbsOrigin() or hAttacker:GetAbsOrigin())
		ParticleManager:SetParticleControlForward(pfx, 0, (hTarget:GetAbsOrigin() - hAttacker:GetAbsOrigin()):Normalized())
	end
	for i=1, #enemy do
		if enemy[i] ~= hTarget then
			ApplyDamage({attacker = hAttacker, victim = enemy[i], ability = hAbility, damage = fDamage, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR})
			if pfx then
				ParticleManager:SetParticleControlEnt(pfx, i + 16, enemy[i], PATTACH_POINT, "attach_hitloc", enemy[i]:GetAbsOrigin(), true)
			end
		end
	end
	if pfx then
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function CDOTABaseAbility:HasFireSoulActive()
	return self:GetCaster():HasModifier("modifier_imba_fiery_soul_active")
end

function CDOTA_BaseNPC:GetIncomingHealAmp()
	local caster = self
	local buffs = caster:FindAllModifiers()
	local heal = 0
	for _, buff in pairs(buffs) do
		if buff.GetIMBAModifierIncomingHealAmp_Percentage and type(buff:GetIMBAModifierIncomingHealAmp_Percentage()) == "number" then
			heal = heal + buff:GetIMBAModifierIncomingHealAmp_Percentage()
		end
	end

	return heal
end

function CDOTA_BaseNPC_Hero:GetRespawnTimeChangeNormal()
	local caster = self
	local buffs = caster:FindAllModifiers()
	local respawn = 0
	local respawn_unique = {}
	for _, buff in pairs(buffs) do
		if buff.GetModifierStackingRespawnTime and type(buff:GetModifierStackingRespawnTime()) == "number" then
			respawn = respawn + buff:GetModifierStackingRespawnTime()
		end
		if buff.GetModifierConstantRespawnTime and type(buff:GetModifierConstantRespawnTime()) == "number" then
			respawn_unique[#respawn_unique + 1] = buff:GetModifierConstantRespawnTime()
		end
	end
	table.sort(respawn_unique)
	if #respawn_unique > 0 then
		respawn = respawn + respawn_unique[#respawn_unique]
	end

	for i=0, 23 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetLevel() > 0 and string.find(ability:GetAbilityName(), "special_bonus_respawn_reduction") then
			respawn = respawn - ability:GetSpecialValueFor("value")
		end
	end
	return respawn
end

function IsInTable(value, hTable)
	for i=0, #hTable do
		if hTable[i] == value then
			return true
		end
	end
	return false
end

function IsEnemy(unit1, unit2)
	if unit1:GetTeamNumber() == unit2:GetTeamNumber() then
		return false
	else
		return true
	end
end

function CDOTA_BaseNPC:TriggerStandardTargetSpell(ability)
	if IsEnemy(self, ability:GetCaster()) then
		self:TriggerSpellReflect(ability)
		return self:TriggerSpellAbsorb(ability)
	end
	return false
end

function CDOTA_BaseNPC:AddNewModifierWhenPossible(hCaster, hAbility, pszScriptName, hModifierTable)
	Timers:CreateTimer(0.1, function()
		if not self:IsAlive() or (IsEnemy(self, hCaster) and self:IsInvulnerable()) then
			return 0.1
		else
			self:AddNewModifier(hCaster, hAbility, pszScriptName, hModifierTable)
		end			
	end)
end

function CDOTA_BaseNPC:AddNewEarthSpiritModifier(hCaster, hAbility, pszScriptName, hModifierTable)
	local temps = FindUnitsInRadius(hCaster:GetTeamNumber(), self:GetAbsOrigin(), nil, 5000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local enemies = {}
	for _, temp in pairs(temps) do
		if temp:HasModifier("modifier_imba_magnetize_debuff") then
			enemies[#enemies + 1] = temp
		end
	end
	if not IsInTable(self, enemies) then
		table.insert(enemies, self)
	end
	local buffs = {}
	for _, enemy in pairs(enemies) do
		buffs[#buffs + 1] = enemy:AddNewModifier(hCaster, hAbility, pszScriptName, hModifierTable)
	end
	return buffs
end

function CDOTA_BaseNPC_Hero:GetIMBARespawnTime()
	
	local victim_respawn = self
	
	local respawn_time = 0

	respawn_time = victim_respawn:GetLevel() * HERO_LEVEL_RESPAWN_MULTIPLY

	respawn_time = respawn_time * (HERO_RESPAWN_TIME_MULTIPLIER / 100)

	respawn_time = respawn_time + victim_respawn:GetRespawnTimeChangeNormal()

	respawn_time = (math.max(respawn_time, 1))

	return respawn_time
end

function IsHeroDamage(attacker, damage)
	if damage > 0 then
		if attacker:IsBoss() or attacker:IsControllableByAnyPlayer() or attacker:GetName() == "npc_dota_shadowshaman_serpentward" then
			return true
		else
			return false
		end
	end
end

function CDOTA_BaseNPC:GetDefaultBAT()
	local BAT = 0
	if self:IsHero() then
		BAT = HeroKV[self:GetName()]['AttackRate'] or HeroKVBase[self:GetName()]['AttackRate']
	else
		BAT = UnitKV[self:GetName()]['AttackRate'] or UnitKVBase[self:GetName()]['AttackRate']
	end
	return BAT
end

function CDOTA_BaseNPC:GetGibType()
	local BAT = 0
	if self:IsHero() then
		BAT = HeroKV[self:GetName()]['GibType'] or HeroKVBase[self:GetName()]['GibType']
	else
		BAT = UnitKV[self:GetName()]['GibType'] or UnitKVBase[self:GetName()]['GibType']
	end
	return BAT
end

function SplitString(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
		if not nFindLastIndex then  
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
			break  
		end  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
		nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end

function HEXConvertToRGB(hex)
    hex = hex:gsub("#","")
    return {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
end

function RGBConvertToHSV(colorRGB)
	local r,g,b = colorRGB[1], colorRGB[2], colorRGB[3]
	local h,s,v = 0,0,0

	local max1 = math.max(r, math.max(g,b))
	local min1 = math.min(r, math.min(g,b))

	if max1 == min1 then
		h=0;
	else
		if r == max1 then
			if g >= b then
				h = 60 * (g-b) / (max1-min1)
			else
				h = 60 * (g-b) / (max1-min1) + 360
			end
		end
		if g == max1 then
			h = 60 * (b-r)/(max1-min1) + 120
		end
		if b == max1 then
			h = 60 * (r-g)/(max1-min1) + 240;
		end
	end    
	
	if max1 == 0 then
		s = 0
	else
		s = (1- min1 / max1) * 255
	end
	
	v = max1
	
	return {h, s, v}
end

function CDOTA_BaseNPC_Hero:GetHeroColor()
	local str = HeroKV[self:GetName()]['HeroGlowColor'] or HeroKVBase[self:GetName()]['HeroGlowColor'] or HeroKV[self:GetName()]['GibTintColor'] or HeroKVBase[self:GetName()]['GibTintColor']
	--print(str)
	if not str then
		local r = self:GetStrength()
		local g = self:GetAgility()
		local b = self:GetIntellect()
		local highest = math.max(r, math.max(g,b))
		r = math.max(255 - (highest - r) * 20, 0)
		g = math.max(255 - (highest - g) * 20, 0)
		b = math.max(255 - (highest - b) * 20, 0)
		return Vector(r,g,b)
	end
	local color = SplitString(str, " ")
	return {color[1], color[2], color[3]}
end

function CDOTA_BaseNPC:AddModifierStacks(hCaster, hAbility, sModifierName, tModifierTable, iStacks, bStatusResis, bRefresh)
	local buff = nil
	if self:HasModifier(sModifierName) then
		buff = self:FindModifierByName(sModifierName)
		buff:SetStackCount(buff:GetStackCount() + iStacks)
		if bRefresh then
			buff:SetDuration(buff:GetDuration(), true)
		end
	else
		buff = self:AddNewModifier(hCaster, hAbility, sModifierName, tModifierTable)
		if buff then
			buff:SetStackCount(buff:GetStackCount() + iStacks)
		end
	end
	return buff
end

function FindStoneRemnant(pos, radius)
	local stones = Entities:FindAllInSphere(pos, radius)
	local function CompareDistance(element1, element2)
		return ((element1:GetAbsOrigin() - pos):Length2D() < (element2:GetAbsOrigin() - pos):Length2D())
	end
	table.sort(stones, CompareDistance)
	for i=1, #stones do
		if (string.find(stones[i]:GetName(), "npc_")) and stones[i]:HasModifier("modifier_imba_stone_remnant_status") then
			return stones[i]
		end
	end
	return nil
end

function GetHeroMainAttr(sHeroname)
	if HeroKv[sHeroname] and HeroKv[sHeroname]['AttributePrimary'] then
		return HeroKv[sHeroname]['AttributePrimary']
	elseif HeroKVBase[sHeroname] and HeroKVBase[sHeroname]['AttributePrimary'] then
		return HeroKVBase[sHeroname]['AttributePrimary']
	else
		return nil
	end
end

function GetRandomAvailableHero()
	local hero = RandomFromTable(HeroList)
	while hero[2] == 0 do
		hero = RandomFromTable(HeroList)
	end
	return hero[1]
end

function GetRandomAbilityNormal()
	local hero = GetRandomAvailableHero()
	while (not Random_Abilities_Normal[hero] or not Random_Abilities_Normal[hero]['ability_count']) do
		hero = GetRandomAvailableHero()
	end
	local count = Random_Abilities_Normal[hero]['ability_count']
	local ability = Random_Abilities_Normal[hero]['Ability'..RandomInt(1, count)]
	while not ability do
		ability = Random_Abilities_Normal[hero]['Ability'..RandomInt(1, count)]
	end
	return {hero, ability}
end

function GetRandomAbilityUltimate()
	local hero = GetRandomAvailableHero()
	while (not Rnadom_Abilities_Ultimate[hero] or not Rnadom_Abilities_Ultimate[hero]['ability_count']) do
		hero = GetRandomAvailableHero()
	end
	local count = Rnadom_Abilities_Ultimate[hero]['ability_count']
	local ability = Rnadom_Abilities_Ultimate[hero]['Ability'..RandomInt(1, count)]
	while not ability do
		ability = Rnadom_Abilities_Ultimate[hero]['Ability'..RandomInt(1, count)]
	end
	return {hero, ability}
end

function GetRandomAKAbility()
	return (RollPercentage(20) and GetRandomAbilityUltimate() or GetRandomAbilityNormal())
end

function GetRandomAKAbility_Event()
	local rand_tab = {}
	for i=1, 3 do
		rand_tab[1 + (i - 1) * 6] = {"npc_dota_hero_ogre_magi", "imba_ogre_magi_multicast"}
		rand_tab[2 + (i - 1) * 6] = {"npc_dota_hero_lina", "imba_lina_fiery_soul"}
		rand_tab[3 + (i - 1) * 6] = {"npc_dota_hero_pudge", "imba_pudge_flesh_heap"}
		rand_tab[4 + (i - 1) * 6] = {"npc_dota_hero_slark", "slark_essence_shift"}
		rand_tab[5 + (i - 1) * 6] = {"npc_dota_hero_dazzle", "dazzle_bad_juju"}
		rand_tab[6 + (i - 1) * 6] = {"npc_dota_hero_venomancer", "imba_venomancer_poison_nova"}
	end
	rand_tab[#rand_tab + 1] = {"npc_dota_hero_tinker", "imba_tinker_rearm"}
	return rand_tab[RandomInt(1, #rand_tab)]
end

function CheckRandomAbilityKV()
	print("Normal Ability KV Check Start ...........")
	for k,v in pairs(Random_Abilities_Normal) do
		local hero = k
		local ability_count = Random_Abilities_Normal[k]['ability_count']
		if not ability_count then
			print("[ERROR] "..hero.." has no ability_count!")
		else
			for i=1, ability_count do
				local ability_name = Random_Abilities_Normal[k]['Ability'..i]
				if not ability_name then
					print("[ERROR] "..hero.." has no ability "..i.."!")
				end
			end
		end
	end
	print("Ultimate Ability KV Check Start ...........")
	for k,v in pairs(Rnadom_Abilities_Ultimate) do
		local hero = k
		local ability_count = Rnadom_Abilities_Ultimate[k]['ability_count']
		if not ability_count then
			print("[ERROR] "..hero.." has no ability_count!")
		else
			for i=1, ability_count do
				local ability_name = Rnadom_Abilities_Ultimate[k]['Ability'..i]
				if not ability_name then
					print("[ERROR] "..hero.." has no ability "..i.."!")
				end
			end
		end
	end
	print("Ability KV Check End ...........")
end

function CDOTA_BaseNPC:RemoveAllModifiers()
	local buff = self:FindAllModifiers()
	local no_move_buff_name = {	"modifier_imba_talent_modifier_adder",
								"modifier_imba_movespeed_controller",
								"modifier_imba_reapers_scythe_permanent",
								"modifier_imba_ability_layout_contoroller",
								"modifier_imba_rearm_fuck",
								"modifier_imba_illusion_hidden",
								"modifier_imba_illusion",
								"modifier_illusion",
								"modifier_imba_ability_charge",
								"modifier_item_ultimate_scepter_consumed",
								"modifier_imba_moon_shard_consume",
								"modifier_imba_consumable_scepter_consumed",
								"modifier_imba_atrophy_aura_permanent",
								"modifier_imba_ak_ability_controller",}
	for i=1, #buff do
		if not IsInTable(buff[i]:GetName(), no_move_buff_name) and not string.find(buff[i]:GetName(), "charge_counter") or (buff[i].CheckState and buff[i]:CheckState()[MODIFIER_STATE_STUNNED]) then
			if buff[i]:GetAbility() and buff[i]:GetAbility().GetIntrinsicModifierName and buff[i]:GetName() == buff[i]:GetAbility():GetIntrinsicModifierName() then
				--
			else
				buff[i]:Destroy()
			end
		end
	end
end

function CDOTA_BaseNPC:GetTP()
	return self:GetItemInSlot(15)
end

function PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
	--[[
	POPUP_SYMBOL_PRE_PLUS = 0
	POPUP_SYMBOL_PRE_MINUS = 1
	POPUP_SYMBOL_PRE_SADFACE = 2
	POPUP_SYMBOL_PRE_BROKENARROW = 3
	POPUP_SYMBOL_PRE_SHADES = 4
	POPUP_SYMBOL_PRE_MISS = 5
	POPUP_SYMBOL_PRE_EVADE = 6
	POPUP_SYMBOL_PRE_DENY = 7
	POPUP_SYMBOL_PRE_ARROW = 8

	POPUP_SYMBOL_POST_EXCLAMATION = 0
	POPUP_SYMBOL_POST_POINTZERO = 1
	POPUP_SYMBOL_POST_MEDAL = 2
	POPUP_SYMBOL_POST_DROP = 3
	POPUP_SYMBOL_POST_LIGHTNING = 4
	POPUP_SYMBOL_POST_SKULL = 5
	POPUP_SYMBOL_POST_EYE = 6
	POPUP_SYMBOL_POST_SHIELD = 7
	POPUP_SYMBOL_POST_POINTFIVE = 8
	]]
	local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN, target) -- target:GetOwner()

	local digits = 0
	if number ~= nil then
		digits = #tostring(number)
	end
	if presymbol ~= nil then
		digits = digits + 1
	end
	if postsymbol ~= nil then
		digits = digits + 1
	end
	local a = postsymbol or 0
	ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), a))
	ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
	ParticleManager:SetParticleControl(pidx, 3, color)
	ParticleManager:ReleaseParticleIndex(pidx)
end

function UpgradeTower(nTeamnumber)
	for i=1, 4 do
		for j=1, #CDOTAGamerules.IMBA_TOWER[nTeamnumber][i] do
			local tower = CDOTAGamerules.IMBA_TOWER[nTeamnumber][i][j]
			if tower and not tower:IsNull() and tower:IsAlive() then
				local ability_count = 0
				local upgrade = false
				for k=0, 23 do
					local ability = tower:GetAbilityByIndex(k)
					if ability and string.find(ability:GetAbilityName(), "imba_tower_") then
						ability_count = ability_count + 1
						if not upgrade and ability:GetLevel() < ability:GetMaxLevel() then
							ability:SetLevel(ability:GetLevel() + 1)
							upgrade = true
						end
					end
				end
				if ability_count < 3 then
					local new_ability_name = RandomFromTable(IMBA_TOWER_ABILITY_SUM[i])
					while tower:HasAbility(new_ability_name) and ability_count < #IMBA_TOWER_ABILITY_SUM[i] do
						new_ability_name = RandomFromTable(IMBA_TOWER_ABILITY_SUM[i])
					end
					local new_ability = tower:AddAbility(new_ability_name)
					new_ability:SetLevel(1)
				else
					tower:SetPhysicalArmorBaseValue(tower:GetPhysicalArmorBaseValue() + 0.5)
				end
			end
		end
	end
end

function IsRefreshableByAbility(str)
	local NO_REFRESH = {
		["imba_tinker_rearm"] = true,
		["ancient_apparition_ice_blast"] = true,
		["zuus_thundergods_wrath"] = true,
		["furion_wrath_of_nature"] = true,
		["imba_magnus_reverse_polarity"] = true,
		["imba_omniknight_guardian_angel"] = true,
		["imba_mirana_arrow"] = true,
		["imba_dazzle_shallow_grave"] = true,
		["imba_wraith_king_reincarnation"] = true,
		["imba_abaddon_borrowed_time"] = true,
		["imba_nyx_assassin_spiked_carapace"] = true,
		["elder_titan_earth_splitter"] = true,
		["imba_centaur_stampede"] = true,
		["silencer_global_silence"] = true,
		["imba_dark_seer_wall_of_replica"] = true,
		["item_imba_bloodstone"] = true,
		["item_imba_arcane_boots"] = true,
		["item_imba_mekansm"] = true,
		["item_imba_mekansm_2"] = true,
		["item_imba_guardian_greaves"] = true,
		["item_imba_hand_of_midas"] = true,
		["item_imba_white_queen_cape"] = true,
		["item_imba_black_king_bar"] = true,
		["item_imba_refresher"] = true,
		["item_imba_necronomicon"] = true,
		["item_imba_necronomicon_2"] = true,
		["item_imba_necronomicon_3"] = true,
		["item_imba_necronomicon_4"] = true,
		["item_imba_necronomicon_5"] = true,
		["item_imba_skadi"] = true,
		["item_imba_sphere"] = true,
		["item_aeon_disk"] = true,
		["zuus_cloud"] = true,
		["chen_hand_of_god"] = true,
		["invoker_sun_strike"] = true,
	}
	return NO_REFRESH[str]
end

function CDOTA_BaseNPC:GiveVisionForBothTeam(fDuration)
	if IMBA_TEAM_DUMMY_GOOD then
		self:AddNewModifier(IMBA_TEAM_DUMMY_GOOD, nil, "modifier_imba_seen", {duration = (fDuration or -1)})
	end
	if IMBA_TEAM_DUMMY_BAD then
		self:AddNewModifier(IMBA_TEAM_DUMMY_BAD, nil, "modifier_imba_seen", {duration = (fDuration or -1)})
	end
end

function StringToVector(sString)
	--Input: "123 123 123"
	local temp = {}
	for str in string.gmatch(sString, "%S+") do
		if tonumber(str) then
			temp[#temp + 1] = tonumber(str)
		else
			return nil
		end
	end
	return Vector(temp[1], temp[2], temp[3])
end

function CDOTABaseAbility:GetAbilityCurrentKV()
	local kv_to_return = {}
	local level = self:GetLevel()
	if level <= 0 then
		return nil
	end
	local kv = self:GetAbilityKeyValues()["AbilitySpecial"]
	for k, v in pairs(kv) do
		for a, b in pairs(v) do
			for str in string.gmatch(b, "%S+") do
				if tonumber(str) then
					local lv = 0
					for s in string.gmatch(b, "%S+") do
						lv = lv + 1
						if lv <= level then
							kv_to_return[a] = tonumber(s)
						else
							break
						end
					end
					break
				end
			end
		end
	end
	return kv_to_return == {} and nil or kv_to_return
end

function CDOTA_Buff:SetAbilityKV()
	self.kv = self:GetAbility():GetAbilityCurrentKV()
	return self.kv
end

function CDOTA_Buff:GetAbilityKV(sKeyname)
	return self.kv and (self.kv[sKeyname] or 0) or 0
end

function CDOTA_BaseNPC:RemoveAllModifiersByName(sBuffname)
	local buff = self:FindAllModifiersByName(sBuffname)
	for i=1, #buff do
		buff[i]:Destroy()
	end
end

function CDOTA_BaseNPC:IsUnit()
	return self:IsHero() or self:IsCreep() or self:IsBoss()
end

function CDOTA_BaseNPC:IsTrueHero()
	return (not self:IsTempestDouble() and self:IsRealHero() and not self:HasModifier("modifier_imba_meepo_clone_controller"))
end

function GetDirection2D(vEndPoint, vStartPoint)
	vEndPoint.z = 0
	vStartPoint.z = 0
	local direction = (vEndPoint - vStartPoint):Normalized()
	direction.z = 0
	return direction
end

function CDOTA_Modifier_Lua:CheckMotionControllers()
	local parent = self:GetParent()
	local modifier_priority = self:GetMotionControllerPriority()
	local is_motion_controller = false
	local motion_controller_priority
	local found_modifier_handler

	if parent:HasModifier("modifier_batrider_flaming_lasso") or parent:HasModifier("modifier_eul_cyclone") then
		self:Destroy()
		return false
	end

	local non_imba_motion_controllers ={
	"modifier_morphling_waveform",
	"modifier_morphling_adaptive_strike",
	"modifier_ember_spirit_fire_remnant",
	"modifier_monkey_king_bounce_leap",
	"modifier_batrider_flaming_lasso",
	"modifier_earth_spirit_boulder_smash",
	"modifier_earth_spirit_geomagnetic_grip",
	"modifier_tiny_toss",
	"modifier_tusk_walrus_punch_air_time",
	"modifier_rattletrap_hookshot",
	"modifier_rattletrap_cog_push",
	"modifier_beastmaster_prima_roar_push",
	"modifier_brewmaster_storm_cyclone",
	"modifier_dark_seer_vacuum",
	"modifier_eul_cyclone",
	"modifier_earth_spirit_rolling_boulder_caster",
	"modifier_huskar_life_break_charge",
	"modifier_invoker_deafening_blast_knockback",
	"modifier_invoker_tornado",
	"modifier_item_forcestaff_active",
	"modifier_rattletrap_hookshot",
	"modifier_phoenix_icarus_dive",
	"modifier_shredder_timber_chain",
	"modifier_slark_pounce",
	"modifier_spirit_breaker_charge_of_darkness",
	"modifier_earthshaker_enchant_totem_leap",
	"modifier_tusk_walrus_kick_air_time",
	}

	-- Fetch all modifiers
	local modifiers = parent:FindAllModifiers()	

	for _,modifier in pairs(modifiers) do		
		-- Ignore the modifier that is using this function
		if self ~= modifier then			

			-- Check if this modifier is assigned as a motion controller
			if modifier.IsMotionController then
				if modifier:IsMotionController() then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- Get the motion controller priority
					motion_controller_priority = modifier:GetMotionControllerPriority()
					if modifier.IsStunDebuff and modifier:IsStunDebuff() then
						motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST + 1
					end
					-- Stop iteration					
					break
				end
			end

			-- If not, check on the list
			for _,non_imba_motion_controller in pairs(non_imba_motion_controllers) do				
				if modifier:GetName() == non_imba_motion_controller then
					-- Get its handle
					found_modifier_handler = modifier

					is_motion_controller = true

					-- We assume that vanilla controllers are the highest priority
					motion_controller_priority = DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST

					-- Stop iteration					
					break
				end
			end
		end
	end

	-- If this is a motion controller, check its priority level
	if is_motion_controller and motion_controller_priority then

		-- If the priority of the modifier that was found is higher, override
		if motion_controller_priority > modifier_priority then			
			return false

		-- If they have the same priority levels, check which of them is older and remove it
		elseif motion_controller_priority == modifier_priority then			
			if found_modifier_handler:GetCreationTime() >= self:GetCreationTime() then				
				return false
			else				
				found_modifier_handler:Destroy()
				return true
			end

		-- If the modifier that was found is a lower priority, destroy it instead
		else			
			parent:InterruptMotionControllers(true)
			found_modifier_handler:Destroy()
			return true
		end
	else
		-- If no motion controllers were found, apply
		return true
	end
end

function DumpAllHeroCustomAbilityIcons()
	local a = LoadKeyValues("scripts/icon_info.txt")
	local b = a['items']
	for k, v in pairs(b) do
		b[k]['portraits'] = nil
		b[k]['static_attributes'] = nil
		b[k]['used_by_heroes'] = nil
		if b[k]['visuals'] then
			b[k]['visuals']['skip_model_combine'] = nil
		end
	end
	for _, v in pairs(b) do
		local icon = false
		if type(v) == "table" and v['visuals'] then
			for i, j in pairs(v['visuals']) do
				if type(j) == "table" and j['type'] == "ability_icon" then
					icon = true
					break
				end
			end
		end
		if icon then
			for i, j in pairs(v['visuals']) do
				if type(j) == "table" and j['type'] == "ability_icon" then
					if v['model_player'] then
						print('"'..j['asset']..'"')
						print("{")
						print("", '"'..v['model_player']..'"', '"'..j['modifier']..'"')
						print("}")
					else
						--print(v['model_player'], j['asset'], j['modifier'])
					end
				end
			end
		end
	end
end