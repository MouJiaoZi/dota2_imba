CreateEmptyTalents("dazzle")

imba_dazzle_poison_touch = class({})

LinkLuaModifier("modifier_imba_poison_touch_slow", "hero/hero_dazzle", LUA_MODIFIER_MOTION_NONE)

function imba_dazzle_poison_touch:IsHiddenWhenStolen() 		return false end
function imba_dazzle_poison_touch:IsRefreshable() 			return true  end
function imba_dazzle_poison_touch:IsStealable() 			return true  end
function imba_dazzle_poison_touch:IsNetherWardStealable()	return true end

function imba_dazzle_poison_touch:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Dazzle.Poison_Cast", caster)
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_dazzle/dazzle_poison_touch.vpcf",
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
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_dazzle_poison_touch:OnProjectileHit(target, pos)
	local caster = self:GetCaster()
	if not target then
		return
	end
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:AddNewModifier(caster, self, "modifier_imba_poison_touch_slow", {duration = self:GetSpecialValueFor("slow_duration")})
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Dazzle.Poison_Touch", target)
end

modifier_imba_poison_touch_slow = class({})

function modifier_imba_poison_touch_slow:IsDebuff()				return true end
function modifier_imba_poison_touch_slow:IsHidden() 			return false end
function modifier_imba_poison_touch_slow:IsPurgable() 			return true end
function modifier_imba_poison_touch_slow:IsPurgeException() 	return true end
function modifier_imba_poison_touch_slow:GetStatusEffectName()  return "particles/status_fx/status_effect_poison_dazzle.vpcf" end
function modifier_imba_poison_touch_slow:StatusEffectPriority() return 15 end
function modifier_imba_poison_touch_slow:GetEffectName() return "particles/units/heroes/hero_dazzle/dazzle_poison_debuff.vpcf" end
function modifier_imba_poison_touch_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_poison_touch_slow:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_imba_poison_touch_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetStackCount()) end

function modifier_imba_poison_touch_slow:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() or (self:GetParent():IsStunned() and not self:GetCaster():HasTalent("special_bonus_imba_dazzle_1")) then
		return
	end
	if keys.damage < self:GetAbility():GetSpecialValueFor("dmg_to_slow") then
		return
	end
	local current_stack = self:GetStackCount()
	local next_stack = current_stack + self:GetAbility():GetSpecialValueFor("slow_per_hit")
	if next_stack < 100 then
		self:SetStackCount(next_stack)
	else
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("initial_slow"))
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
	end
end

function modifier_imba_poison_touch_slow:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("initial_slow"))
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	end
end

function modifier_imba_poison_touch_slow:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("damage") / (1.0 / self:GetAbility():GetSpecialValueFor("tick_interval"))
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self:GetParent(), dmg, nil)
	EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Dazzle.Poison_Tick", self:GetParent())
end


imba_dazzle_shallow_grave = class({})

LinkLuaModifier("modifier_imba_shallow_grave", "hero/hero_dazzle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shallow_grave_passive", "hero/hero_dazzle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shallow_grave_passive_cooldown", "hero/hero_dazzle", LUA_MODIFIER_MOTION_NONE)

function imba_dazzle_shallow_grave:IsHiddenWhenStolen() 		return false end
function imba_dazzle_shallow_grave:IsRefreshable() 			return true  end
function imba_dazzle_shallow_grave:IsStealable() 			return true  end
function imba_dazzle_shallow_grave:IsNetherWardStealable()	return true end

function imba_dazzle_shallow_grave:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("range_tooltip") end

function imba_dazzle_shallow_grave:GetIntrinsicModifierName() return "modifier_imba_shallow_grave_passive" end

function imba_dazzle_shallow_grave:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_imba_shallow_grave", {duration = self:GetSpecialValueFor("duration_tooltip")})
end

modifier_imba_shallow_grave = class({})

function modifier_imba_shallow_grave:IsDebuff()				return false end
function modifier_imba_shallow_grave:IsHidden() 			return false end
function modifier_imba_shallow_grave:IsPurgable() 			return false end
function modifier_imba_shallow_grave:IsPurgeException() 	return false end
function modifier_imba_shallow_grave:GetEffectName() return "particles/units/heroes/hero_dazzle/dazzle_shallow_grave.vpcf" end
function modifier_imba_shallow_grave:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_shallow_grave:OnCreated()
	if IsServer() then
		EmitSoundOn("Hero_Dazzle.Shallow_Grave", self:GetParent())
	end
end

function modifier_imba_shallow_grave:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MIN_HEALTH}
end

function modifier_imba_shallow_grave:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() or self:GetParent():GetHealth() ~= 1 then
		return
	end
	self:SetStackCount(self:GetStackCount() + keys.damage)
end

function modifier_imba_shallow_grave:GetMinHealth() return 1 end

function modifier_imba_shallow_grave:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Dazzle.Shallow_Grave", self:GetParent())
		self:GetParent():Heal(self:GetStackCount(), self:GetCaster())
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self:GetParent(), self:GetStackCount(), nil)
	end
end

modifier_imba_shallow_grave_passive = class({})
modifier_imba_shallow_grave_passive_cooldown = class({})

function modifier_imba_shallow_grave_passive:IsHidden()
	if self:GetCaster():HasModifier("modifier_imba_shallow_grave_passive_cooldown") then
		return true
	else
		return false
	end
end

function modifier_imba_shallow_grave_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MIN_HEALTH}
end

function modifier_imba_shallow_grave_passive:GetMinHealth()
	if self:GetParent():HasModifier("modifier_imba_shallow_grave_passive_cooldown") or self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then
		return nil
	else
		return 1
	end
end

function modifier_imba_shallow_grave_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	if self:GetParent():HasModifier("modifier_imba_shallow_grave_passive_cooldown") or self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then
		return
	end
	if self:GetParent():GetHealth() == 1 and not self:GetParent():HasModifier("modifier_imba_shallow_grave") then
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_imba_shallow_grave", {duration = self:GetAbility():GetSpecialValueFor("passive_duration")})
		self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_imba_shallow_grave_passive_cooldown", {duration = self:GetAbility():GetSpecialValueFor("passive_cooldown")})
	end
end

function modifier_imba_shallow_grave_passive_cooldown:IsDebuff()			return true end
function modifier_imba_shallow_grave_passive_cooldown:IsHidden() 			return false end
function modifier_imba_shallow_grave_passive_cooldown:IsPurgable() 			return false end
function modifier_imba_shallow_grave_passive_cooldown:IsPurgeException() 	return false end
function modifier_imba_shallow_grave_passive_cooldown:RemoveOnDeath()		return false end


imba_dazzle_shadow_wave = class({})

LinkLuaModifier("modifier_imba_shadow_wave_armor_bonus", "hero/hero_dazzle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_wave_armor_reduction", "hero/hero_dazzle", LUA_MODIFIER_MOTION_NONE)

function imba_dazzle_shadow_wave:IsHiddenWhenStolen() 		return false end
function imba_dazzle_shadow_wave:IsRefreshable() 			return true  end
function imba_dazzle_shadow_wave:IsStealable() 				return true  end
function imba_dazzle_shadow_wave:IsNetherWardStealable()	return true end

function imba_dazzle_shadow_wave:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local units = {}
	local radius = self:GetSpecialValueFor("bounce_radius")
	units[#units + 1] = target
	for _, aunit in pairs(units) do
		local units1 = FindUnitsInRadius(caster:GetTeamNumber(), aunit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false)
		for _, unit1 in pairs(units1) do
			local no_yet = true
			for _, unit in pairs(units) do
				if unit == unit1 or unit1 == caster then
					no_yet = false
					break
				end
			end
			if no_yet then
				units[#units + 1] = unit1
				break
			end
		end
	end
	if caster ~= target then
		table.insert(units, 1, caster)
	end

	for k, unit in pairs(units) do
		local i = (k == #units) and k or (k + 1)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, units[i], PATTACH_POINT_FOLLOW, "attach_hitloc", units[i]:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
		local health = (unit:GetMaxHealth() - unit:GetHealth()) * (self:GetSpecialValueFor("bonus_healing") / 100) + self:GetSpecialValueFor("damage")
		unit:Heal(health, caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, unit, health, nil)
		unit:AddNewModifier(caster, self, "modifier_imba_shadow_wave_armor_bonus", {duration = self:GetSpecialValueFor("duration")})
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Dazzle.Shadow_Wave", caster)

		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), unit:GetAbsOrigin(), nil, self:GetSpecialValueFor("damage_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			local damageTable = {
								victim = enemy,
								attacker = caster,
								damage = self:GetSpecialValueFor("damage"),
								damage_type = self:GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self, --Optional.
								}
			ApplyDamage(damageTable)
			enemy:AddNewModifier(caster, self, "modifier_imba_shadow_wave_armor_reduction", {duration = self:GetSpecialValueFor("duration")})
			local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave_impact_damage.vpcf", PATTACH_CUSTOMORIGIN, enemy)
			ParticleManager:SetParticleControlEnt(pfx2, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(pfx2, 1, enemy:GetAbsOrigin() + (enemy:GetAbsOrigin() - unit:GetAbsOrigin()):Normalized() * 100)
			ParticleManager:ReleaseParticleIndex(pfx2)
		end
	end
end

modifier_imba_shadow_wave_armor_bonus = class({})

function modifier_imba_shadow_wave_armor_bonus:IsDebuff()			return false end
function modifier_imba_shadow_wave_armor_bonus:IsHidden() 			return false end
function modifier_imba_shadow_wave_armor_bonus:IsPurgable() 		return true end
function modifier_imba_shadow_wave_armor_bonus:IsPurgeException() 	return true end

function modifier_imba_shadow_wave_armor_bonus:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_imba_shadow_wave_armor_bonus:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("armor_bonus") end

modifier_imba_shadow_wave_armor_reduction = class({})

function modifier_imba_shadow_wave_armor_reduction:IsDebuff()			return true end
function modifier_imba_shadow_wave_armor_reduction:IsHidden() 			return false end
function modifier_imba_shadow_wave_armor_reduction:IsPurgable() 		return true end
function modifier_imba_shadow_wave_armor_reduction:IsPurgeException() 	return true end

function modifier_imba_shadow_wave_armor_reduction:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_imba_shadow_wave_armor_reduction:GetModifierPhysicalArmorBonus() return (0 - self:GetAbility():GetSpecialValueFor("armor_reduction")) end


imba_dazzle_weave = class({})

LinkLuaModifier("modifier_imba_weave", "hero/hero_dazzle", LUA_MODIFIER_MOTION_NONE)

function imba_dazzle_weave:IsHiddenWhenStolen() 	return false end
function imba_dazzle_weave:IsRefreshable() 			return true  end
function imba_dazzle_weave:IsStealable() 			return true  end
function imba_dazzle_weave:IsNetherWardStealable()	return true end

function imba_dazzle_weave:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_dazzle_weave:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius") + caster:GetTalentValue("special_bonus_imba_dazzle_2")
	local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + ((caster:HasScepter() and DOTA_UNIT_TARGET_BUILDING or 0)), DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, unit in pairs(units) do
		unit:AddNewModifier(caster, self, "modifier_imba_weave", {duration = self:GetSpecialValueFor("duration")})
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_weave.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, Vector(pos.x, pos.y, pos.z + 128))
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("radius")))
	ParticleManager:ReleaseParticleIndex(pfx)
	AddFOWViewer(caster:GetTeamNumber(), pos, self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("vision_duration"), false)
	EmitSoundOnLocationWithCaster(pos, "Hero_Dazzle.Weave", caster)
end

modifier_imba_weave = class({})

function modifier_imba_weave:GetAttributes()		return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_weave:IsHidden() 			return false end
function modifier_imba_weave:IsPurgable() 			return false end
function modifier_imba_weave:IsPurgeException() 	return false end
function modifier_imba_weave:ShouldUseOverheadOffset() return true end
function modifier_imba_weave:IsDebuff()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end

function modifier_imba_weave:OnCreated()
	if IsServer() then
		local particle = "particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf"
		if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
			particle = "particles/units/heroes/hero_dazzle/dazzle_armor_friend.vpcf"
		end
		local pfx = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	end
end

function modifier_imba_weave:OnIntervalThink()
	self:IncrementStackCount()
end

function modifier_imba_weave:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_imba_weave:GetModifierPhysicalArmorBonus()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return (self:GetAbility():GetSpecialValueFor("armor_bonus") + self:GetStackCount() * (self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("armor_per_second_scepter") or self:GetAbility():GetSpecialValueFor("armor_per_second")) * (1.0 / self:GetAbility():GetSpecialValueFor("tick_interval")))
	else
		return (0 - (self:GetAbility():GetSpecialValueFor("armor_bonus") + self:GetStackCount() * (self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("armor_per_second_scepter") or self:GetAbility():GetSpecialValueFor("armor_per_second")) * (1.0 / self:GetAbility():GetSpecialValueFor("tick_interval"))))
	end
end