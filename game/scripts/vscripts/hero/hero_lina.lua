CreateEmptyTalents("lina")

imba_lina_dragon_slave = class({})

LinkLuaModifier("modifier_imba_lina_dragon_slave_thinker", "hero/hero_lina", LUA_MODIFIER_MOTION_NONE)

function imba_lina_dragon_slave:IsHiddenWhenStolen() 		return false end
function imba_lina_dragon_slave:IsRefreshable() 			return true  end
function imba_lina_dragon_slave:IsStealable() 				return true  end
function imba_lina_dragon_slave:IsNetherWardStealable()		return true end
function imba_lina_dragon_slave:GetManaCost(a) return self:HasFireSoulActive() and self:GetSpecialValueFor("mana_super") or self:GetSpecialValueFor("mana_normal") end
function imba_lina_dragon_slave:GetCooldown(a) return self:HasFireSoulActive() and self:GetSpecialValueFor("cd_super") or self:GetSpecialValueFor("cd_normal") end
function imba_lina_dragon_slave:GetAbilityTextureName() return self:HasFireSoulActive() and "lina_dragon_slave_fiery" or "lina_dragon_slave" end

function imba_lina_dragon_slave:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Lina.DragonSlave.Cast", caster)
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local super_state = self:HasFireSoulActive() and 1 or 0
	local primary_length = self:GetCastRange(pos, caster)
	local primary_speed = self:HasFireSoulActive() and self:GetSpecialValueFor("primary_speed_super") or self:GetSpecialValueFor("primary_speed")
	local primary_start = self:HasFireSoulActive() and self:GetSpecialValueFor("primary_start_width_super") or self:GetSpecialValueFor("primary_start_width")
	local primary_end = self:HasFireSoulActive() and self:GetSpecialValueFor("primary_end_width_super") or self:GetSpecialValueFor("primary_end_width")
	local primary_dmg = self:HasFireSoulActive() and self:GetSpecialValueFor("primary_damage_super") or self:GetSpecialValueFor("primary_damage")
	local primary_delay = self:HasFireSoulActive() and self:GetSpecialValueFor("secondary_delay_super") or self:GetSpecialValueFor("secondary_delay")
	local secondary_amount = self:HasFireSoulActive() and self:GetSpecialValueFor("secondary_amount_super") or self:GetSpecialValueFor("secondary_amount")
	local secondary_speed = self:GetSpecialValueFor("secondary_speed")
	local secondary_start = self:GetSpecialValueFor("secondary_start_width")
	local secondary_end = self:GetSpecialValueFor("secondary_end_width")
	local secondary_length = self:GetSpecialValueFor("secondary_distance")
	local thinker = CreateModifierThinker(caster, self, "modifier_imba_lina_dragon_slave_thinker", {super = super_state, primary = 1}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false):entindex()
	local pfxname = self:HasFireSoulActive() and "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf" or "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf"
	local info = 
	{
		Ability = self,
		EffectName = pfxname,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = primary_length + caster:GetCastRangeBonus(),
		fStartRadius = 0,
		fEndRadius = 0,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = direction * primary_speed,
		bProvidesVision = false,
		ExtraData = {thinker = thinker, super = super_state, direction_x = direction.x, direction_y = direction.y, primary = 1}
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function imba_lina_dragon_slave:OnProjectileThink_ExtraData(location, keys)
	local thinker = EntIndexToHScript(keys.thinker)
	local super = keys.super
	thinker:SetAbsOrigin(location)
end

function imba_lina_dragon_slave:OnProjectileHit_ExtraData(target, location, keys)
	if target then
		return false
	end
	
	if keys.primary == 1 then
		local super = keys.super
		local pfxname = super == 1 and "particles/econ/items/lina/lina_head_headflame/lina_spell_dragon_slave_headflame.vpcf" or "particles/units/heroes/hero_lina/lina_spell_dragon_slave.vpcf"
		local direction = Vector(keys.direction_x, keys.direction_y, 0)
		local primary_delay = super == 1 and self:GetSpecialValueFor("secondary_delay_super") or self:GetSpecialValueFor("secondary_delay")
		local secondary_amount = super == 1 and self:GetSpecialValueFor("secondary_amount_super") or self:GetSpecialValueFor("secondary_amount")
		local secondary_speed = self:GetSpecialValueFor("secondary_speed")
		local secondary_length = self:GetSpecialValueFor("secondary_distance")
		local angular_opening = 100
		local projectile_directions = {}
		for i = 1, secondary_amount do
			projectile_directions[i] = (RotatePosition(location, QAngle(0, (-1) * angular_opening / 2 + (i - 1) * angular_opening / (secondary_amount - 1) , 0), location + direction * secondary_length) - location):Normalized()
		end
		for i = 1, secondary_amount do
			Timers:CreateTimer(primary_delay, function()
				local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_imba_lina_dragon_slave_thinker", {super = super, primary = 0}, location, self:GetCaster():GetTeamNumber(), false):entindex()
				local info = 
				{
					Ability = self,
					EffectName = pfxname,
					vSpawnOrigin = location,
					fDistance = secondary_length,
					fStartRadius = 0,
					fEndRadius = 0,
					Source = EntIndexToHScript(keys.thinker),
					bHasFrontalCone = false,
					bReplaceExisting = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					fExpireTime = GameRules:GetGameTime() + 10.0,
					bDeleteOnHit = true,
					vVelocity = projectile_directions[i] * secondary_speed,
					bProvidesVision = false,
					ExtraData = {thinker = thinker, super = super}
				}
				ProjectileManager:CreateLinearProjectile(info)
				return nil
			end
			)
		end
	end
	EntIndexToHScript(keys.thinker):ForceKill(false)
end

modifier_imba_lina_dragon_slave_thinker = class({})

function modifier_imba_lina_dragon_slave_thinker:OnCreated(keys)
	if IsServer() then
		self.super = keys.super
		if self.super == 1 then
			self:GetParent():EmitSound("Hero_Lina.DragonSlave.FireHair")
		else
			self:GetParent():EmitSound("Hero_Lina.DragonSlave")
		end
		self.pr = keys.primary
		self:StartIntervalThink(0.06)
		self.hitted = {}
	end
end

function modifier_imba_lina_dragon_slave_thinker:OnIntervalThink()
	if self.super == 1 then
		if self.pr == 1 then -- Super PRI
			local length = self:GetAbility():GetCastRange(Vector(0,0,0), self:GetCaster())
			local speed = self:GetAbility():GetSpecialValueFor("primary_speed_super")
			local total_duration = length / speed
			local sw = self:GetAbility():GetSpecialValueFor("primary_start_width_super")
			local ew = self:GetAbility():GetSpecialValueFor("primary_end_width_super")
			local radius = sw + (ew - sw) * math.min((self:GetElapsedTime() / total_duration), 1.0)
			local dmg = self:GetAbility():GetSpecialValueFor("primary_damage_super")
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				local hit = false
				for _, unit in pairs(self.hitted) do
					if enemy == unit then
						hit = true
						break
					end
				end
				if not hit then
					self.hitted[#self.hitted+1] = enemy
					local damageTable = {
										victim = enemy,
										attacker = self:GetCaster(),
										damage = dmg,
										damage_type = self:GetAbility():GetAbilityDamageType(),
										damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
										ability = self:GetAbility(), --Optional.
										}
					ApplyDamage(damageTable)
				end
			end
		else  -- Super SEC
			local length = self:GetAbility():GetSpecialValueFor("secondary_distance")
			local speed = self:GetAbility():GetSpecialValueFor("secondary_speed")
			local total_duration = length / speed
			local sw = self:GetAbility():GetSpecialValueFor("secondary_start_width")
			local ew = self:GetAbility():GetSpecialValueFor("secondary_end_width")
			local radius = sw + (ew - sw) * math.min((self:GetElapsedTime() / total_duration), 1.0)
			local dmg = self:GetAbility():GetSpecialValueFor("secondary_damage_super")
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				local hit = false
				for _, unit in pairs(self.hitted) do
					if enemy == unit then
						hit = true
						break
					end
				end
				if not hit then
					self.hitted[#self.hitted+1] = enemy
					local damageTable = {
										victim = enemy,
										attacker = self:GetCaster(),
										damage = dmg,
										damage_type = self:GetAbility():GetAbilityDamageType(),
										damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
										ability = self:GetAbility(), --Optional.
										}
					ApplyDamage(damageTable)
				end
			end
		end
	else
		if self.pr == 1 then --Normal PRI
			local length = self:GetAbility():GetCastRange(Vector(0,0,0), self:GetCaster())
			local speed = self:GetAbility():GetSpecialValueFor("primary_speed")
			local total_duration = length / speed
			local sw = self:GetAbility():GetSpecialValueFor("primary_start_width")
			local ew = self:GetAbility():GetSpecialValueFor("primary_end_width")
			local radius = sw + (ew - sw) * math.min((self:GetElapsedTime() / total_duration), 1.0)
			local dmg = self:GetAbility():GetSpecialValueFor("primary_damage")
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				local hit = false
				for _, unit in pairs(self.hitted) do
					if enemy == unit then
						hit = true
						break
					end
				end
				if not hit then
					self.hitted[#self.hitted+1] = enemy
					local damageTable = {
										victim = enemy,
										attacker = self:GetCaster(),
										damage = dmg,
										damage_type = self:GetAbility():GetAbilityDamageType(),
										damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
										ability = self:GetAbility(), --Optional.
										}
					ApplyDamage(damageTable)
				end
			end
		else --Normal SCE
			local length = self:GetAbility():GetSpecialValueFor("secondary_distance")
			local speed = self:GetAbility():GetSpecialValueFor("secondary_speed")
			local total_duration = length / speed
			local sw = self:GetAbility():GetSpecialValueFor("secondary_start_width")
			local ew = self:GetAbility():GetSpecialValueFor("secondary_end_width")
			local radius = sw + (ew - sw) * math.min((self:GetElapsedTime() / total_duration), 1.0)
			local dmg = self:GetAbility():GetSpecialValueFor("secondary_damage")
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				local hit = false
				for _, unit in pairs(self.hitted) do
					if enemy == unit then
						hit = true
						break
					end
				end
				if not hit then
					self.hitted[#self.hitted+1] = enemy
					local damageTable = {
										victim = enemy,
										attacker = self:GetCaster(),
										damage = dmg,
										damage_type = self:GetAbility():GetAbilityDamageType(),
										damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
										ability = self:GetAbility(), --Optional.
										}
					ApplyDamage(damageTable)
				end
			end
		end
	end
end

function modifier_imba_lina_dragon_slave_thinker:OnDestroy()
	if IsServer() then
		self.hitted = nil
	end
end

imba_lina_light_strike_array = class({})

LinkLuaModifier("modifier_imba_lina_light_strike_array_thinker_mom", "hero/hero_lina", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_lina_light_strike_array_thinker_son", "hero/hero_lina", LUA_MODIFIER_MOTION_NONE)

function imba_lina_light_strike_array:IsHiddenWhenStolen() 		return false end
function imba_lina_light_strike_array:IsRefreshable() 			return true end
function imba_lina_light_strike_array:IsStealable() 			return true end
function imba_lina_light_strike_array:IsNetherWardStealable()	return true end
function imba_lina_light_strike_array:GetAOERadius() return self:GetSpecialValueFor("aoe_radius") end
function imba_lina_light_strike_array:GetManaCost(a) return self:HasFireSoulActive() and self:GetSpecialValueFor("mana_super") or self:GetSpecialValueFor("mana_normal") end
function imba_lina_light_strike_array:GetCooldown(a) return self:HasFireSoulActive() and self:GetSpecialValueFor("cd_super") or self:GetSpecialValueFor("cd_normal") end
function imba_lina_light_strike_array:GetAbilityTextureName() return self:HasFireSoulActive() and "lina_light_strike_array_fiery" or "lina_light_strike_array" end

function imba_lina_light_strike_array:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin() + (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized() * (self:GetCastRange(Vector(0,0,0), caster) + caster:GetCastRangeBonus())
	local start_pos = caster:GetAbsOrigin() + (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("aoe_radius")
	local super_state = self:HasFireSoulActive() and 1 or 0
	CreateModifierThinker(caster, self, "modifier_imba_lina_light_strike_array_thinker_mom", {duration = 3.0, super = super_state, endpos_x = pos.x, endpos_y = pos.y, endpos_z = pos.z}, start_pos, caster:GetTeamNumber(), false)
end

modifier_imba_lina_light_strike_array_thinker_mom = class({})

function modifier_imba_lina_light_strike_array_thinker_mom:OnCreated(keys)
	if IsServer() then
		local endpos = Vector(keys.endpos_x, keys.endpos_y, keys.endpos_z)
		local direction = (endpos - self:GetParent():GetAbsOrigin()):Normalized()
		direction.z = 0.0
		local delay = keys.super == 1 and self:GetAbility():GetSpecialValueFor("secondary_delay_super") or self:GetAbility():GetSpecialValueFor("secondary_delay")
		local array_amount = math.ceil((endpos - self:GetParent():GetAbsOrigin()):Length2D() / self:GetAbility():GetSpecialValueFor("aoe_radius"))
		local distance
		if array_amount ~= 1 then
			distance = (endpos - self:GetParent():GetAbsOrigin()):Length2D() / (array_amount - 1)
		end
		local strike_delay = self:GetAbility():GetSpecialValueFor("cast_delay")
		for i = 1, array_amount do
			Timers:CreateTimer(i * delay, function()
				CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_lina_light_strike_array_thinker_son", {duration = strike_delay}, self:GetParent():GetAbsOrigin() + direction * ((i - 1) * distance), self:GetCaster():GetTeamNumber(), false)
				return nil
			end
			)
		end
	end
end

modifier_imba_lina_light_strike_array_thinker_son = class({})

function modifier_imba_lina_light_strike_array_thinker_son:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true} end

function modifier_imba_lina_light_strike_array_thinker_son:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Ability.PreLightStrikeArray")
		local pfx_name = "particles/units/heroes/hero_lina/lina_spell_light_strike_array_ray_team.vpcf"
		if self:GetAbility():HasFireSoulActive() then
			pfx_name = "particles/econ/items/lina/lina_ti7/light_strike_array_pre_ti7.vpcf"
		end
		local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("aoe_radius"), self:GetAbility():GetSpecialValueFor("aoe_radius"), self:GetAbility():GetSpecialValueFor("aoe_radius")))
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function modifier_imba_lina_light_strike_array_thinker_son:OnDestroy()
	if IsServer() then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("aoe_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = self:GetAbility():GetSpecialValueFor("damage"),
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
		end
		local pfx_name = "particles/units/heroes/hero_lina/lina_spell_light_strike_array.vpcf"
		if self:GetAbility():HasFireSoulActive() then
			pfx_name = "particles/econ/items/lina/lina_ti7/lina_spell_light_strike_array_ti7.vpcf"
		end
		local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("aoe_radius"), 0, 0))
		ParticleManager:ReleaseParticleIndex(pfx)
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("aoe_radius"), false)
		EmitSoundOn("Ability.LightStrikeArray", self:GetParent())
	end
end

imba_lina_fiery_soul = class({})
LinkLuaModifier("modifier_imba_fiery_soul_stacks", "hero/hero_lina", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fiery_soul_active", "hero/hero_lina", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fiery_soul_passive", "hero/hero_lina", LUA_MODIFIER_MOTION_NONE)

function imba_lina_fiery_soul:IsHiddenWhenStolen() 		return false end
function imba_lina_fiery_soul:IsRefreshable() 			return false end
function imba_lina_fiery_soul:IsStealable() 			return false end
function imba_lina_fiery_soul:IsNetherWardStealable()	return false end
function imba_lina_fiery_soul:GetIntrinsicModifierName() return "modifier_imba_fiery_soul_passive" end
function imba_lina_fiery_soul:GetAbilityTextureName() return self:HasFireSoulActive() and "lina_fiery_soul_fiery" or "lina_fiery_soul" end

function imba_lina_fiery_soul:CastFilterResult()
	if self:GetCaster():HasModifier("modifier_imba_fiery_soul_active") or self:GetCaster():GetModifierStackCount("modifier_imba_fiery_soul_stacks", self:GetCaster()) < self:GetSpecialValueFor("active_stacks") then
		return UF_FAIL_CUSTOM
	end
end

function imba_lina_fiery_soul:GetCustomCastError()
	if self:GetCaster():HasModifier("modifier_imba_fiery_soul_active") or self:GetCaster():GetModifierStackCount("modifier_imba_fiery_soul_stacks", self:GetCaster()) < self:GetSpecialValueFor("active_stacks") then
		return "#dota_hud_error_ability_inactive"
	end
end

function imba_lina_fiery_soul:OnSpellStart()
	local buff = self:GetCaster():FindModifierByName("modifier_imba_fiery_soul_stacks")
	if buff:GetStackCount() == self:GetSpecialValueFor("active_stacks") then
		buff:Destroy()
	else
		buff:SetStackCount(buff:GetStackCount() - self:GetSpecialValueFor("active_stacks"))
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_fiery_soul_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_fiery_soul_passive = class({})

function modifier_imba_fiery_soul_passive:IsDebuff()			return false end
function modifier_imba_fiery_soul_passive:IsHidden() 			return true end
function modifier_imba_fiery_soul_passive:IsPurgable() 			return false end
function modifier_imba_fiery_soul_passive:IsPurgeException() 	return false end

function modifier_imba_fiery_soul_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_imba_fiery_soul_passive:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():PassivesDisabled() or keys.unit ~= self:GetParent() or keys.ability:IsItem() or keys.ability == self:GetAbility() then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_fiery_soul_stacks", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	if not self:GetParent():HasModifier("modifier_imba_fiery_soul_active") or self:GetParent():HasTalent("special_bonus_imba_lina_1") then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
end

modifier_imba_fiery_soul_stacks = class({})

function modifier_imba_fiery_soul_stacks:IsDebuff()			return false end
function modifier_imba_fiery_soul_stacks:IsHidden() 		return false end
function modifier_imba_fiery_soul_stacks:IsPurgable() 		return false end
function modifier_imba_fiery_soul_stacks:IsPurgeException() return false end
function modifier_imba_fiery_soul_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_fiery_soul_stacks:GetModifierMoveSpeedBonus_Percentage() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_ms")) end
function modifier_imba_fiery_soul_stacks:GetModifierAttackSpeedBonus_Constant() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_as")) end
function modifier_imba_fiery_soul_stacks:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_fiery_soul.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 1, Vector(3,0,0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_imba_fiery_soul_active = class({})

function modifier_imba_fiery_soul_active:GetTexture()	return "lina_fiery_soul_fiery" end
function modifier_imba_fiery_soul_active:IsDebuff()			return false end
function modifier_imba_fiery_soul_active:IsHidden() 		return false end
function modifier_imba_fiery_soul_active:IsPurgable() 		return false end
function modifier_imba_fiery_soul_active:IsPurgeException() return false end
function modifier_imba_fiery_soul_active:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/econ/courier/courier_polycount_01/courier_trail_polycount_01a.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 5, Vector(1,1,1))
		ParticleManager:SetParticleControl(pfx, 15, Vector(252,46,0)) --- RGB 252,46,0
		ParticleManager:SetParticleControl(pfx, 16, Vector(1,1,1))
		self:AddParticle(pfx, false, false, 15, false, false)
		self.cd = {}
		for i=0, 23 do
			local ability = self:GetCaster():GetAbilityByIndex(i)
			if ability and not ability:IsCooldownReady() and (ability:GetName() == "imba_lina_dragon_slave" or ability:GetName() == "imba_lina_light_strike_array" or ability:GetName() == "imba_lina_laguna_blade") then
				local table_cd = {ability, ability:GetCooldownTimeRemaining()}
				ability:EndCooldown()
				self.cd[#self.cd+1] = table_cd
			end
		end
	end
end

function modifier_imba_fiery_soul_active:OnDestroy()
	if IsServer() then
		local time = self:GetElapsedTime()
		for _, v in pairs(self.cd) do
			if v[1] and v[2] - time > 0 then
				v[1]:StartCooldown(v[2] - time)
			end
			if v[1] and v[2] - time <= 0 then
				v[1]:EndCooldown()
			end
		end
	end
end

imba_lina_laguna_blade = class({})

function imba_lina_laguna_blade:IsHiddenWhenStolen() 		return false end
function imba_lina_laguna_blade:IsRefreshable() 			return true end
function imba_lina_laguna_blade:IsStealable() 			return true end
function imba_lina_laguna_blade:IsNetherWardStealable()	return true end
function imba_lina_laguna_blade:GetManaCost(a) return self:HasFireSoulActive() and self:GetSpecialValueFor("mana_super") or self:GetSpecialValueFor("mana_normal") end
function imba_lina_laguna_blade:GetCooldown(a) return self:HasFireSoulActive() and self:GetSpecialValueFor("cd_super") or self:GetSpecialValueFor("cd_normal") end
function imba_lina_laguna_blade:GetAbilityTextureName() return self:HasFireSoulActive() and "lina_laguna_blade_fiery" or "lina_laguna_blade" end

function imba_lina_laguna_blade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	if self:HasFireSoulActive() then
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Lina.LagunaBlade.Immortal", caster)
	else
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ability.LagunaBlade", caster)
	end
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = nil,
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		vSourceLoc= caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function imba_lina_laguna_blade:OnProjectileHit(target, location)
	if not target then
		target = CreateModifierThinker(self:GetCaster(), nil, "modifier_dummy_thinker", {duration = 1.0}, location, self:GetCaster():GetTeamNumber(), false)
	end
	local caster = self:GetCaster()
	local direction = (location - caster:GetAbsOrigin()):Normalized()
	local startRadius = self:HasFireSoulActive() and self:GetSpecialValueFor("start_width_super") or self:GetSpecialValueFor("start_width")
	local endRadius = self:HasFireSoulActive() and self:GetSpecialValueFor("end_width_super") or self:GetSpecialValueFor("end_width")
	local length = self:HasFireSoulActive() and self:GetSpecialValueFor("extra_length_super") or self:GetSpecialValueFor("extra_length")
	local flag = caster:HasScepter() and DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES or DOTA_UNIT_TARGET_FLAG_NONE
	local dmgType = caster:HasScepter() and DAMAGE_TYPE_PURE or DAMAGE_TYPE_MAGICAL
	local dmg = self:GetSpecialValueFor("damage") + (caster:HasScepter() and caster:GetIntellect() * self:GetSpecialValueFor("int_damage_scepter") or 0)
	local pfxname
	if self:HasFireSoulActive() then
		pfxname = "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade.vpcf"
	else
		pfxname = "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
	end
	local enemies = FindUnitsInCone(caster:GetTeamNumber(), direction, target:GetAbsOrigin(), startRadius, endRadius, length, nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, flag, FIND_ANY_ORDER, false)
	
	if not IsInTable(target, enemies) then
		table.insert(enemies, target)
	end
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = self:GetCaster(),
							damage = dmg,
							damage_type = dmgType,
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		if self:HasFireSoulActive() then
			enemy:EmitSound("Hero_Lina.LagunaBladeImpact.Immortal")
		else
			enemy:EmitSound("Ability.LagunaBladeImpact")
		end
		local pfx = ParticleManager:CreateParticle(pfxname, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end