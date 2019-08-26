--[[	Author: Firetoad
		Date: 16.08.2015	]]


function NecrowarriorTrample( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_cast = keys.sound_cast
	local sound_hit = keys.sound_hit
	local particle_hit = keys.particle_hit
	local modifier_dummy = keys.modifier_dummy

	-- Parameters
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local speed = ability:GetLevelSpecialValueFor("speed", ability_level)
	local caster_loc = caster:GetAbsOrigin()
	local direction = (target - caster_loc):Normalized()
	local distance = (target - caster_loc):Length2D()

	-- Play sound
	caster:EmitSound(sound_cast)

	-- Play animation
	StartAnimation(caster, {activity = ACT_DOTA_ATTACK, rate = 1.2})

	-- Movement parameters
	local current_distance = 0
	local tick_rate = 0.03
	local distance_tick = direction * speed * tick_rate

	-- Move the caster
	Timers:CreateTimer(0, function()
		caster:SetOrigin(caster:GetAbsOrigin() + distance_tick)
		current_distance = current_distance + speed * tick_rate
		
		-- If the movement has ended, find a legal position and exit
		if current_distance >= distance then
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)

		-- Else, keep moving
		else

			-- Destroy trees
			GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 175, false)

			-- Iterate through nearby enemies
			local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _,enemy in pairs(nearby_enemies) do
				if not enemy:HasModifier(modifier_dummy) then
					
					-- Apply the multiple-hit-prevention modifier
					ability:ApplyDataDrivenModifier(caster, enemy, modifier_dummy, {})

					-- Play hit sound
					enemy:EmitSound(sound_hit)

					-- Play hit particle
					local trample_hit_pfx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN, enemy)
					ParticleManager:SetParticleControl(trample_hit_pfx, 0, enemy:GetAbsOrigin())

					-- Deal damage
					ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
				end
			end

			-- Keep moving
			return tick_rate
		end
	end)
end

function NecrowarriorBlazeSpikes( keys )
	local caster = keys.caster
	local target = keys.attacker
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_hit = keys.particle_hit
	local sound_hit = keys.sound_hit

	-- Parameters
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)

	-- Play sound
	target:EmitSound(sound_hit)

	-- Play particle
	local blaze_pfx = ParticleManager:CreateParticle(particle_hit, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(blaze_pfx, 0, target:GetAbsOrigin())

	-- Deal damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL})
end










imba_fountain_buffs = class({})

LinkLuaModifier("modifier_imba_fountain_buff", "hero/npc_upgrades", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fountain_disabled", "hero/npc_upgrades", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_game_start_pause", "hero/npc_upgrades", LUA_MODIFIER_MOTION_NONE)

function imba_fountain_buffs:GetIntrinsicModifierName() return "modifier_imba_fountain_buff" end

modifier_imba_fountain_buff = class({})

function modifier_imba_fountain_buff:IsDebuff()			return false end
function modifier_imba_fountain_buff:IsHidden() 		return true end
function modifier_imba_fountain_buff:IsPurgable() 		return false end
function modifier_imba_fountain_buff:IsPurgeException() return false end
function modifier_imba_fountain_buff:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_fountain_buff:GetModifierAttackRangeBonus() return self:GetAbility():GetSpecialValueFor("range_bonus") end
function modifier_imba_fountain_buff:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("as_bonus") end
function modifier_imba_fountain_buff:GetModifierBaseAttack_BonusDamage() return 200 end

function modifier_imba_fountain_buff:OnAttack(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() then
		return
	end
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local enemy = keys.target
	local bash_duration = self:GetAbility():GetSpecialValueFor("bash_duration")
	local bash_distance = self:GetAbility():GetSpecialValueFor("bash_distance")
	local bash_height = self:GetAbility():GetSpecialValueFor("bash_height")
	local fountain_loc = self:GetParent():GetAbsOrigin()
	local point = enemy:GetAbsOrigin() + (enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized() * 100
	-- Knockback table
	local fountain_bash =	{
		should_stun = 1,
		knockback_duration = bash_duration,
		duration = bash_duration,
		knockback_distance = bash_distance,
		knockback_height = bash_height,
		center_x = point.x,
		center_y = point.y,
		center_z = point.z
	}
	enemy:RemoveModifierByName("modifier_knockback")
	enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_knockback", fountain_bash)
	enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_stunned", {duration = bash_duration})
	enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_silver_edge_debuff", {duration = bash_duration})
	enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_nullifier_debuff", {duration = bash_duration})
end

function modifier_imba_fountain_buff:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_imba_game_start_pause", {duration = IMBA_LOADING_DELAY})
		self:StartIntervalThink(0.5)
		if GetMapName() == "dbii_death_match" then
			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_imba_fountain_disabled", {})
		end
	end
end

function modifier_imba_fountain_buff:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_imba_fountain_disabled") then
		return
	end
	local pfx = ParticleManager:CreateParticle("particles/ambient/fountain_danger_circle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_imba_fountain_disabled = class({})

function modifier_imba_fountain_disabled:IsDebuff()			return true end
function modifier_imba_fountain_disabled:IsHidden() 		return false end
function modifier_imba_fountain_disabled:IsPurgable() 		return false end
function modifier_imba_fountain_disabled:IsPurgeException() return false end
function modifier_imba_fountain_disabled:CheckState() return {[MODIFIER_STATE_DISARMED] = true} end
function modifier_imba_fountain_disabled:GetTexture() return "imba_ancient_dire_spawn_behemoth" end

modifier_imba_game_start_pause = class({})

function modifier_imba_game_start_pause:IsDebuff()			return false end
function modifier_imba_game_start_pause:IsHidden() 			return true end
function modifier_imba_game_start_pause:IsPurgable() 		return false end
function modifier_imba_game_start_pause:IsPurgeException() 	return false end
function modifier_imba_game_start_pause:IsAura() return true end
function modifier_imba_game_start_pause:GetAuraDuration() return 0.1 end
function modifier_imba_game_start_pause:GetModifierAura() return "modifier_imba_stunned" end
function modifier_imba_game_start_pause:GetAuraRadius() return 50000 end
function modifier_imba_game_start_pause:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_DEAD end
function modifier_imba_game_start_pause:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function modifier_imba_game_start_pause:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end

function modifier_imba_game_start_pause:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
		if GameRules:IsCheatMode() then
			self:Destroy()
		end
	end
end

function modifier_imba_game_start_pause:OnIntervalThink()
	if not CustomNetTables:GetTableValue("imba_hero_selection_list", "selection_phase_done") then
		self:SetDuration(self:GetDuration(), false)
	else
		self:StartIntervalThink(-1)
		print("123")
	end
end