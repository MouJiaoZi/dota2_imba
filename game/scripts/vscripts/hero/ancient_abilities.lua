--[[	Author: Firetoad
		Date: 10.01.2016	]]

function AncientHealth( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Parameters
	local health = ability:GetLevelSpecialValueFor("ancient_health", 0)

	-- Update health
	SetCreatureHealth(caster, health, true)
end

function AncientThink( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- If the game is set to end on kills, make the ancient invulnerable
	if END_GAME_ON_KILLS then

		-- Make the ancient invulnerable
		caster:AddNewModifier(caster, ability, "modifier_fountain_glyph", {})
		caster:AddNewModifier(caster, ability, "modifier_invulnerable", {})

		-- Kill any nearby creeps (prevents lag)
		local enemy_creeps = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemy_creeps) do
			enemy:Kill(ability, caster)
		end
		return nil
	end

	-- Parameters
	local ancient_health = caster:GetHealth() / caster:GetMaxHealth()

	-- Search for nearby units
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- If there are no nearby enemies, do nothing
	if #enemies == 0 then
		return nil
	end
	
	-- Ancient abilities logic
	local behemoth_adjustment = 0
	if SPAWN_ANCIENT_BEHEMOTHS then behemoth_adjustment = -1 end
	local tier_1_ability = caster:GetAbilityByIndex(4 + behemoth_adjustment)
	local tier_2_ability = caster:GetAbilityByIndex(5 + behemoth_adjustment)
	local tier_3_ability = caster:GetAbilityByIndex(6 + behemoth_adjustment)

	-- If health < 40%, refresh abilities once
	if (( ancient_health < 0.40 and IMBA_PLAYERS_ON_GAME == 20 ) and not caster.abilities_refreshed ) then
		caster.tier_1_cast = false
		caster.tier_3_cast = false
		tier_1_ability:SetActivated(true)
		tier_3_ability:SetActivated(true)
		caster.abilities_refreshed = true

		-- Small delay for tier 2 (defensive) abilities
		Timers:CreateTimer(2, function()
			caster.tier_2_cast = false
			tier_2_ability:SetActivated(true)
		end)
	end

	-- If health < 50%, use the tier 3 ability
	if ancient_health < 0.5 and tier_3_ability and not caster.tier_3_cast then
		tier_3_ability:OnSpellStart()
		tier_3_ability:SetActivated(false)
		caster.tier_3_cast = true
		return nil
	end

	-- If health < 70%, use the tier 2 ability
	if ancient_health < 0.7 and tier_2_ability and not caster.tier_2_cast then
		tier_2_ability:OnSpellStart()
		tier_2_ability:SetActivated(false)
		caster.tier_2_cast = true
		return nil
	end

	-- If health < 90%, use the tier 1 ability
	if ancient_health < 0.9 and tier_1_ability and not caster.tier_1_cast then
		tier_1_ability:OnSpellStart()
		tier_1_ability:SetActivated(false)
		caster.tier_1_cast = true
		return nil
	end
end

function AncientAttacked( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Parameters
	local ancient_health = caster:GetHealth() / caster:GetMaxHealth()

	-- Search for nearby units
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- If there are no nearby enemies, do nothing
	if #enemies == 0 then
		return nil
	end
	
	-- Ancient abilities logic
	local behemoth_adjustment = 0
	if SPAWN_ANCIENT_BEHEMOTHS then behemoth_adjustment = -1 end
	local tier_1_ability = caster:GetAbilityByIndex(4 + behemoth_adjustment)
	local tier_2_ability = caster:GetAbilityByIndex(5 + behemoth_adjustment)
	local tier_3_ability = caster:GetAbilityByIndex(6 + behemoth_adjustment)

	-- If health < 40%, refresh abilities once
	if (( ancient_health < 0.40 and IMBA_PLAYERS_ON_GAME == 20 ) and not caster.abilities_refreshed ) then
		caster.tier_1_cast = false
		caster.tier_3_cast = false
		tier_1_ability:SetActivated(true)
		tier_3_ability:SetActivated(true)
		caster.abilities_refreshed = true

		-- Small delay for tier 2 (defensive) abilities
		Timers:CreateTimer(2, function()
			caster.tier_2_cast = false
			tier_2_ability:SetActivated(true)
		end)
	end

	-- If health < 50%, use the tier 3 ability
	if ancient_health < 0.5 and tier_3_ability and not caster.tier_3_cast then
		tier_3_ability:OnSpellStart()
		tier_3_ability:SetActivated(false)
		caster.tier_3_cast = true
		return nil
	end

	-- If health < 70%, use the tier 2 ability
	if ancient_health < 0.7 and tier_2_ability and not caster.tier_2_cast then
		tier_2_ability:OnSpellStart()
		tier_2_ability:SetActivated(false)
		caster.tier_2_cast = true
		return nil
	end

	-- If health < 90%, use the tier 1 ability
	if ancient_health < 0.9 and tier_1_ability and not caster.tier_1_cast then
		tier_1_ability:OnSpellStart()
		tier_1_ability:SetActivated(false)
		caster.tier_1_cast = true
		return nil
	end
end

function SpawnRadiantBehemoth( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_stack = keys.modifier_stack
	local particle_ambient = keys.particle_ambient

	-- Prevents the ability from working on hero-creeps
	if IsHeroCreep(keys.unit) then
		return nil
	end

	-- Increase body count by 1
	if not caster.ancient_recently_dead_enemies then
		caster.ancient_recently_dead_enemies = 1
	else
		caster.ancient_recently_dead_enemies = caster.ancient_recently_dead_enemies + 1
	end

	-- Keep track of body count
	local this_call_body_count = caster.ancient_recently_dead_enemies

	-- If no other hero died after 10 seconds, spawn the Behemoth
	Timers:CreateTimer(12, function()

		-- If body count is a match, this is the right spawn call
		if caster.ancient_recently_dead_enemies and (this_call_body_count == caster.ancient_recently_dead_enemies) then

			-- Parameters
			local base_health = ability:GetLevelSpecialValueFor("base_health", ability:GetLevel() - 1)
			local health_per_minute = ability:GetLevelSpecialValueFor("health_per_minute", ability:GetLevel() - 1)
			local health_per_hero = ability:GetLevelSpecialValueFor("health_per_hero", ability:GetLevel() - 1)
			local game_time = GameRules:GetDOTATime(false, false) * CREEP_POWER_FACTOR / 60
			
			-- Spawn the Behemoth
			local spawn_loc = Entities:FindByName(nil, "radiant_reinforcement_spawn_mid"):GetAbsOrigin()
			local behemoth = CreateUnitByName("npc_imba_goodguys_mega_hulk", spawn_loc, true, caster, caster, caster:GetTeam())
			FindClearSpaceForUnit(behemoth, spawn_loc, true)

			-- Adjust health
			SetCreatureHealth(behemoth, base_health + this_call_body_count * health_per_hero + game_time * health_per_minute, true)
			
			-- Adjust armor & health regeneration
			AddStacks(ability, caster, behemoth, modifier_stack, game_time, true)

			-- Grant extra abilities
			behemoth:AddAbility("imba_behemoth_aura_goodguys")
			local aura_ability = behemoth:FindAbilityByName("imba_behemoth_aura_goodguys")
			aura_ability:SetLevel(math.min(this_call_body_count, 5))
			behemoth:AddAbility("imba_behemoth_dearmor")
			local dearmor_ability = behemoth:FindAbilityByName("imba_behemoth_dearmor")
			dearmor_ability:SetLevel(1)

			-- Increase Behemoth size according to its power
			behemoth:SetModelScale(0.85 + 0.06 * this_call_body_count)

			-- Play ambient particle
			local ambient_pfx = ParticleManager:CreateParticle(particle_ambient, PATTACH_CUSTOMORIGIN, behemoth)
			ParticleManager:SetParticleControlEnt(ambient_pfx, 0, behemoth, PATTACH_POINT_FOLLOW, "attach_mane1", behemoth:GetAbsOrigin(), true)

			-- Make Behemoth attack-move the opposing ancient
			local target_loc = Entities:FindByName(nil, "dire_reinforcement_spawn_mid"):GetAbsOrigin()
			Timers:CreateTimer(0.5, function()
				behemoth:MoveToPositionAggressive(target_loc)
			end)

			-- Reset body count
			caster.ancient_recently_dead_enemies = nil
		end
	end)
end

function SpawnDireBehemoth( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_stack = keys.modifier_stack
	local particle_ambient = keys.particle_ambient

	-- Prevents the ability from working on hero-creeps
	if IsHeroCreep(keys.unit) then
		return nil
	end

	-- Increase body count by 1
	if not caster.ancient_recently_dead_enemies then
		caster.ancient_recently_dead_enemies = 1
	else
		caster.ancient_recently_dead_enemies = caster.ancient_recently_dead_enemies + 1
	end

	-- Keep track of body count
	local this_call_body_count = caster.ancient_recently_dead_enemies

	-- If no other hero died after 10 seconds, spawn the Behemoth
	Timers:CreateTimer(12, function()

		-- If body count is a match, this is the right spawn call
		if caster.ancient_recently_dead_enemies and (this_call_body_count == caster.ancient_recently_dead_enemies) then

			-- Parameters
			local base_health = ability:GetLevelSpecialValueFor("base_health", ability:GetLevel() - 1)
			local health_per_minute = ability:GetLevelSpecialValueFor("health_per_minute", ability:GetLevel() - 1)
			local health_per_hero = ability:GetLevelSpecialValueFor("health_per_hero", ability:GetLevel() - 1)
			local game_time = GameRules:GetDOTATime(false, false) * CREEP_POWER_FACTOR / 60
			
			-- Spawn the Behemoth
			local spawn_loc = Entities:FindByName(nil, "dire_reinforcement_spawn_mid"):GetAbsOrigin()
			local behemoth = CreateUnitByName("npc_imba_badguys_mega_hulk", spawn_loc, true, nil, nil, caster:GetTeam())
			FindClearSpaceForUnit(behemoth, spawn_loc, true)

			-- Adjust health
			SetCreatureHealth(behemoth, base_health + this_call_body_count * health_per_hero + game_time * health_per_minute, true)

			-- Adjust armor & health regeneration
			AddStacks(ability, caster, behemoth, modifier_stack, game_time, true)

			-- Grant extra abilities
			behemoth:AddAbility("imba_behemoth_aura_badguys")
			local aura_ability = behemoth:FindAbilityByName("imba_behemoth_aura_badguys")
			aura_ability:SetLevel(math.min(this_call_body_count, 5))
			behemoth:AddAbility("imba_behemoth_dearmor")
			local dearmor_ability = behemoth:FindAbilityByName("imba_behemoth_dearmor")
			dearmor_ability:SetLevel(1)

			-- Increase Behemoth size according to its power
			behemoth:SetModelScale(0.85 + 0.06 * this_call_body_count)

			-- Play ambient particle
			local ambient_pfx = ParticleManager:CreateParticle(particle_ambient, PATTACH_CUSTOMORIGIN, behemoth)
			ParticleManager:SetParticleControlEnt(ambient_pfx, 0, behemoth, PATTACH_POINT_FOLLOW, "attach_mane1", behemoth:GetAbsOrigin(), true)

			-- Make Behemoth move to the opposing ancient
			local target_loc = Entities:FindByName(nil, "radiant_reinforcement_spawn_mid"):GetAbsOrigin()
			Timers:CreateTimer(0.5, function()
				behemoth:MoveToPositionAggressive(target_loc)
			end)

			-- Reset body count
			caster.ancient_recently_dead_enemies = nil
		end
	end)
end

function BehemothAttacked( keys )
	local caster = keys.caster
	local ability = keys.ability
	local attacker = keys.attacker
	local modifier_stack = keys.modifier_stack

	-- If the attacker is a hero, reduce the Behemoth's armor
	if attacker:IsHero() then
		AddStacks(ability, caster, caster, modifier_stack, 1, true)
	end
end

function StalwartDefense( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier_buff = keys.modifier_buff
	local sound_cast = keys.sound_cast
	local particle_hit = keys.particle_hit
	local particle_buff = keys.particle_buff

	-- Prevents the ability from working on hero-creeps
	if IsHeroCreep(keys.unit) then
		return nil
	end

	-- Parameters
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)

	-- Find nearby allied heroes
	local nearby_heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)

	-- Do nothing if there are no other nearby heroes
	if #nearby_heroes > 0 then
		
		-- Play LOUD VUVUZELA SOUNDS
		caster:EmitSound(sound_cast)

		-- Iterate through nearby allies
		for _,hero in pairs(nearby_heroes) do

			-- Purge debuffs
			hero:Purge(false, true, false, true, false)	
			
			-- Apply the modifier
			ability:ApplyDataDrivenModifier(caster, hero, modifier_buff, {})

			-- Play the light particles
			if hero.stalwart_defense_light_pfx then
				ParticleManager:DestroyParticle(hero.stalwart_defense_light_pfx, true)
			end
			hero.stalwart_defense_light_pfx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN_FOLLOW, hero)
			ParticleManager:SetParticleControl(hero.stalwart_defense_light_pfx, 0, hero:GetAbsOrigin())
			ParticleManager:SetParticleControl(hero.stalwart_defense_light_pfx, 1, caster:GetAbsOrigin())

			-- Play the buff particles
			if not hero.stalwart_defense_buff_pfx then
				hero.stalwart_defense_buff_pfx = ParticleManager:CreateParticle(particle_buff, PATTACH_ABSORIGIN_FOLLOW, hero)
				ParticleManager:SetParticleControlEnt(hero.stalwart_defense_buff_pfx, 0, hero, PATTACH_POINT_FOLLOW, "attach_attack1", hero:GetAbsOrigin(), true)
			end
		end
	end
end

function StalwartDefenseParticleEnd( keys )
	local unit = keys.target

	-- Destroy buff particles
	if unit.stalwart_defense_light_pfx then
		ParticleManager:DestroyParticle(unit.stalwart_defense_light_pfx, false)
		unit.stalwart_defense_light_pfx = nil
	end
	if unit.stalwart_defense_buff_pfx then
		ParticleManager:DestroyParticle(unit.stalwart_defense_buff_pfx, false)
		unit.stalwart_defense_buff_pfx = nil
	end
end

imba_ancient_aura = class({})

LinkLuaModifier("modifier_imba_ancient_buff_think", "hero/ancient_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ancient_soullink_thinker", "hero/ancient_abilities", LUA_MODIFIER_MOTION_NONE)

function imba_ancient_aura:GetIntrinsicModifierName() return "modifier_imba_ancient_buff_think" end

modifier_imba_ancient_buff_think = class({})

function modifier_imba_ancient_buff_think:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_ancient_buff_think:IsHidden() return true end

function modifier_imba_ancient_buff_think:OnTakeDamage(keys)
	if IsServer() and keys.unit == self:GetParent() then
		local magnus = self:GetParent():FindAbilityByName("magnataur_reverse_polarity")
		local venomancer = self:GetParent():FindAbilityByName("venomancer_poison_nova")
		local jugg = self:GetParent():FindAbilityByName("juggernaut_blade_fury")
		if self:GetParent():GetHealthPercent() <= 80 and venomancer and not venomancer:IsHidden() then
			venomancer:OnSpellStart()
			venomancer:SetHidden(true)
		end
		if self:GetParent():GetHealthPercent() <= 60 and jugg and not jugg:IsHidden() then
			jugg:OnSpellStart()
			jugg:SetHidden(true)
		end
		if self:GetParent():GetHealthPercent() <= 40 and magnus and not magnus:IsHidden() then
			magnus:OnSpellStart()
			magnus:SetHidden(true)
		end
		if self:GetParent():GetHealthPercent() <= 20 and self:GetAbility():IsCooldownReady() then
			self:GetAbility():StartCooldown(600)
			CreateModifierThinker(self:GetParent(), nil, "modifier_imba_ancient_soullink_thinker", {duration = 10.0}, self:GetParent():GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
		end
	end
end

modifier_imba_ancient_soullink_thinker = class({})

function modifier_imba_ancient_soullink_thinker:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/basic_ambient/ancient_soullink.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(1500,1,1))
		ParticleManager:SetParticleControl(pfx, 2, Vector(10,0,0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_ancient_soullink_thinker:OnIntervalThink()
	local heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	local hp_pct = 0
	if #heroes > 1 then
		for _, hero in pairs(heroes) do
			hp_pct = hp_pct + hero:GetHealthPercent()
		end
		hp_pct = (hp_pct / #heroes) / 100
		for _, hero in pairs(heroes) do
			hero:SetHealth(hero:GetMaxHealth() * hp_pct)
		end
	end
end



IMBA_COURIER_POSITION = {}

IMBA_COURIER_POSITION[2] = {}
IMBA_COURIER_POSITION[2][1] = Vector(-7450, -6550, 256)
IMBA_COURIER_POSITION[2][2] = Vector(-7350, -6650, 256)
IMBA_COURIER_POSITION[2][3] = Vector(-7250, -6750, 256)
IMBA_COURIER_POSITION[2][4] = Vector(-7150, -6850, 256)
IMBA_COURIER_POSITION[2][5] = Vector(-7050, -6950, 256)
IMBA_COURIER_POSITION[2][6] = Vector(-7325, -6425, 256)
IMBA_COURIER_POSITION[2][7] = Vector(-7225, -6525, 256)
IMBA_COURIER_POSITION[2][8] = Vector(-7125, -6625, 256)
IMBA_COURIER_POSITION[2][9] = Vector(-7025, -6725, 256)
IMBA_COURIER_POSITION[2][10] = Vector(-6925, -6825, 256)

IMBA_COURIER_POSITION[3] = {}
IMBA_COURIER_POSITION[3][1] = Vector(7400, 6500, 256)
IMBA_COURIER_POSITION[3][2] = Vector(7300, 6600, 256)
IMBA_COURIER_POSITION[3][3] = Vector(7200, 6700, 256)
IMBA_COURIER_POSITION[3][4] = Vector(7100, 6800, 256)
IMBA_COURIER_POSITION[3][5] = Vector(7000, 6900, 256)
IMBA_COURIER_POSITION[3][6] = Vector(7275, 6375, 256)
IMBA_COURIER_POSITION[3][7] = Vector(7175, 6475, 256)
IMBA_COURIER_POSITION[3][8] = Vector(7075, 6575, 256)
IMBA_COURIER_POSITION[3][9] = Vector(6975, 6675, 256)
IMBA_COURIER_POSITION[3][10] = Vector(6875, 6775, 256)

IMBA_COURIER_ORDER = {}

imba_courier_speed = class({})

LinkLuaModifier("modifier_imba_courier_buff", "hero/ancient_abilities", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_courier_transfer_owning", "hero/ancient_abilities", LUA_MODIFIER_MOTION_NONE)

function imba_courier_speed:GetIntrinsicModifierName() return "modifier_imba_courier_buff" end

modifier_imba_courier_buff = class({})

function modifier_imba_courier_buff:IsHidden() return true end
function modifier_imba_courier_buff:IsPurgable() return false end
function modifier_imba_courier_buff:IsPurgeException() return false end

function modifier_imba_courier_buff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_MAX, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_EVENT_ON_ORDER, MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_courier_buff:GetModifierMoveSpeed_Max() return 10000 end
function modifier_imba_courier_buff:GetModifierMoveSpeed_Absolute() return 1000 end
function modifier_imba_courier_buff:GetModifierMoveSpeedBonus_Percentage() return 100 end
function modifier_imba_courier_buff:GetModifierPercentageCooldown() return 90 end

function modifier_imba_courier_buff:OnCreated()
	if IsServer() then
		self.courier = self:GetParent()
		self.distance = 0
		self:StartIntervalThink(1.0)
		self:OnIntervalThink()
	end
end

function modifier_imba_courier_buff:OnIntervalThink()
	if not self.pos and self.courier.courier_num then
		self.pos = IMBA_COURIER_POSITION[self.courier:GetTeamNumber()][self.courier.courier_num]
	end
	if not self.courier:IsIdle() or not self.courier:HasModifier("modifier_fountain_aura_buff") then
		return
	end
	if self.pos then
		self.courier:MoveToPosition(self.pos)
	end
end

function modifier_imba_courier_buff:OnOrder(keys)
	if IsServer() and keys.unit == self.courier and self.pos then
		if (keys.ability and (keys.ability:GetAbilityName() == "courier_go_to_secretshop" or keys.ability:GetAbilityName() == "courier_transfer_items" or keys.ability:GetAbilityName() == "courier_take_stash_and_transfer_items")) then
			--self.courier:SetCustomHealthLabel(tostring(PlayerResource:GetSteamID(keys.issuer_player_index)), PLAYER_COLORS[keys.issuer_player_index][1], PLAYER_COLORS[keys.issuer_player_index][2], PLAYER_COLORS[keys.issuer_player_index][3])
			self.id = tostring(PlayerResource:GetSteamID(keys.issuer_player_index))
			self.pid = keys.issuer_player_index
			self:SetStackCount(keys.issuer_player_index + 1)
		elseif keys.new_pos ~= Vector(0,0,0) then
			local distance = (keys.new_pos - self.pos):Length2D()
			if distance > self.distance then
				--self.courier:SetCustomHealthLabel(tostring(PlayerResource:GetSteamID(keys.issuer_player_index)), PLAYER_COLORS[keys.issuer_player_index][1], PLAYER_COLORS[keys.issuer_player_index][2], PLAYER_COLORS[keys.issuer_player_index][3])
				self.id = tostring(PlayerResource:GetSteamID(keys.issuer_player_index))
				self.pid = keys.issuer_player_index
				self:SetStackCount(keys.issuer_player_index + 1)
			end
			self.distance = distance
			local time = GameRules:GetGameTime()
			if not IMBA_COURIER_ORDER[time] then
				IMBA_COURIER_ORDER[time] = {}
			end
			IMBA_COURIER_ORDER[time][#IMBA_COURIER_ORDER[time] + 1] = self.courier
			local buff = self
			Timers:CreateTimer(0.1, function()
					if #IMBA_COURIER_ORDER[time] > 1 then
						Notifications:Bottom(PlayerResource:GetPlayer(buff.pid), {text="#imba_introduction_line_04", duration = 10, style={["font-size"] = "30px"}})
						for i=1, #IMBA_COURIER_ORDER[time] do
							IMBA_COURIER_ORDER[time][i]:FindAbilityByName("courier_return_to_base"):OnSpellStart()
						end
					end
					Timers:CreateTimer(1.0, function()
							IMBA_COURIER_ORDER[time] = nil
							return nil
						end
					)
					return nil
				end
			)
		elseif keys.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
			--self.courier:SetCustomHealthLabel(tostring(PlayerResource:GetSteamID(keys.issuer_player_index)), PLAYER_COLORS[keys.issuer_player_index][1], PLAYER_COLORS[keys.issuer_player_index][2], PLAYER_COLORS[keys.issuer_player_index][3])
			self.id = tostring(PlayerResource:GetSteamID(keys.issuer_player_index))
			self.pid = keys.issuer_player_index
			self:SetStackCount(keys.issuer_player_index + 1)
			--[[Timers:CreateTimer(0.1, function()
					self.courier:FindAbilityByName("courier_return_to_base"):OnSpellStart()
					return nil
				end
			)]]
		end
	end
end

function modifier_imba_courier_buff:OnDeath(keys)
	if IsServer() and keys.unit == self.courier then
		if GameRules:IsCheatMode() then
			return
		end
		if GameRules:GetGameTime() >= 2400 and not IMBA_RESET_COURIER_FEEDING then
			IMBA_RESET_COURIER_FEEDING = true
			for i=0, 23 do
				IMBA_COURIER_FEEDING[self.pid] = 0
			end
		end
		GameRules:SendCustomMessage("Courier Controller: "..self.id..". Game Time: "..GameRules:GetGameTime()..". Player: "..PlayerResource:GetPlayerName(tonumber(self.pid)), 0, 0)
		IMBA_COURIER_FEEDING[self.pid] = IMBA_COURIER_FEEDING[self.pid] + 1
		if IMBA_COURIER_FEEDING[self.pid] >= 7 then
			IMBA_DISABLE_PLAYER[self.pid] = true
			IMBA:SendHTTPRequest("imba_add_disable.php", {["steamid_64"] = tostring(PlayerResource:GetSteamID(self.pid)), ["match_id"] = GameRules:GetMatchID(), ["game_time"] = GameRules:GetGameTime(), ["add_type"] = "record"}, nil, nil)
			IMBA:SendHTTPRequest("imba_add_disable.php", {["steamid_64"] = tostring(PlayerResource:GetSteamID(self.pid)), ["add_type"] = "disable"}, nil, nil)
			Notifications:BottomToAll({text = PlayerResource:GetPlayerName(self.pid).."(ID:"..tostring(PlayerResource:GetSteamID(self.pid))..") ", duration = 20.0})
			Notifications:BottomToAll({text = "#imba_player_banned_message", duration = 20.0, continue = true})
		else
			IMBA:SendHTTPRequest("imba_add_disable.php", {["steamid_64"] = tostring(PlayerResource:GetSteamID(self.pid)), ["match_id"] = GameRules:GetMatchID(), ["game_time"] = GameRules:GetGameTime(), ["add_type"] = "record"}, nil, nil)
		end
	end
end

-- good : -7000, -6537, 512
-- bad :  7040 6332 518

modifier_imba_courier_transfer_owning = class({})

function modifier_imba_courier_transfer_owning:IsHidden() return (not self:GetParent():HasModifier("modifier_courier_transfer_items")) end
function modifier_imba_courier_transfer_owning:IsPurgable() return false end
function modifier_imba_courier_transfer_owning:IsPurgeException() return false end
function modifier_imba_courier_transfer_owning:GetTexture() return "shadow_shaman_voodoo" end

function modifier_imba_courier_transfer_owning:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_courier_transfer_owning:OnIntervalThink()
	if not self:GetParent():HasModifier("modifier_courier_transfer_items") then
		self:Destroy()
	end
end