

CreateEmptyTalents("omniknight")


imba_omniknight_purification = class({})

LinkLuaModifier("modifier_imba_purification_passive", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_purification_passive_cooldown", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_a", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_b", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_c", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_d", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)

function imba_omniknight_purification:IsHiddenWhenStolen() 		return false end
function imba_omniknight_purification:IsRefreshable() 			return true end
function imba_omniknight_purification:IsStealable() 			return true end
function imba_omniknight_purification:IsNetherWardStealable()	return true end
function imba_omniknight_purification:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_omniknight_purification:GetIntrinsicModifierName() return "modifier_imba_purification_passive" end

function imba_omniknight_purification:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:EmitSound("Hero_Omniknight.Purification")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(pfx2, 1, Vector(self:GetSpecialValueFor("radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(pfx2)
	local heal = self:GetSpecialValueFor("heal_base") + target:GetMaxHealth() * (self:GetSpecialValueFor("heal_pct") / 100)
	target:Heal(heal, self)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, target, heal, nil)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = heal * (self:GetSpecialValueFor("damage_factor") / 100),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		local pfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx3, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx3, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx3)
	end
end

modifier_imba_purification_passive = class({})
modifier_imba_purification_passive_cooldown = class({})

function modifier_imba_purification_passive:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_wings.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_purification_passive:IsHidden()
	if self:GetCaster():HasModifier("modifier_imba_purification_passive_cooldown") then
		return true
	else
		return false
	end
end

function modifier_imba_purification_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_imba_purification_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	if self:GetParent():HasModifier("modifier_imba_purification_passive_cooldown") or self:GetParent():IsIllusion() then
		return
	end
	if self:GetParent():GetHealth() <= self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("passive_threshold") / 100) and self:GetParent():IsAlive() then
		self:GetParent():SetCursorCastTarget(self:GetParent())
		self:GetAbility():OnSpellStart()
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_purification_passive_cooldown", {duration = self:GetAbility():GetSpecialValueFor("passive_cooldown")})
	end
end

function modifier_imba_purification_passive_cooldown:IsDebuff()				return true end
function modifier_imba_purification_passive_cooldown:IsHidden() 			return false end
function modifier_imba_purification_passive_cooldown:IsPurgable() 			return false end
function modifier_imba_purification_passive_cooldown:IsPurgeException() 	return false end
function modifier_imba_purification_passive_cooldown:RemoveOnDeath()		return false end


imba_omniknight_repel = class({})

LinkLuaModifier("modifier_imba_repel", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)

function imba_omniknight_repel:IsHiddenWhenStolen() 	return false end
function imba_omniknight_repel:IsRefreshable() 			return true end
function imba_omniknight_repel:IsStealable() 			return true end
function imba_omniknight_repel:IsNetherWardStealable()	return true end

function imba_omniknight_repel:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:Purge(false, true, false, true, true)
	target:AddNewModifier(caster, self, "modifier_imba_repel", {duration = self:GetSpecialValueFor("duration")})
	if target ~= caster then
		caster:AddNewModifier(caster, self, "modifier_imba_repel", {duration = self:GetSpecialValueFor("self_duration")})
	end
end

modifier_imba_repel = class({})

function modifier_imba_repel:IsDebuff()				return false end
function modifier_imba_repel:IsHidden() 			return false end
function modifier_imba_repel:IsPurgable() 			return true end
function modifier_imba_repel:IsPurgeException() 	return true end
function modifier_imba_repel:CheckState() return {[MODIFIER_STATE_MAGIC_IMMUNE] = true} end
function modifier_imba_repel:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_imba_repel:GetModifierMagicalResistanceBonus() return 100 end

function modifier_imba_repel:GetEffectName() return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf" end
function modifier_imba_repel:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_repel:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Omniknight.Repel")
	end
end


imba_omniknight_degen_aura = class({})

LinkLuaModifier("modifier_imba_degen_aura_passive", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_degen_aura_stacks", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)

function imba_omniknight_degen_aura:GetCastRange() return self:GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_omniknight_1") - self:GetCaster():GetCastRangeBonus() end
function imba_omniknight_degen_aura:GetIntrinsicModifierName() return "modifier_imba_degen_aura_passive" end

modifier_imba_degen_aura_passive = class({})

function modifier_imba_degen_aura_passive:IsDebuff()			return false end
function modifier_imba_degen_aura_passive:IsHidden() 			return true end
function modifier_imba_degen_aura_passive:IsPurgable() 			return false end
function modifier_imba_degen_aura_passive:IsPurgeException() 	return false end
function modifier_imba_degen_aura_passive:IsAura()
	if self:GetParent():PassivesDisabled() then
		return false
	else
		return true
	end
end
function modifier_imba_degen_aura_passive:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("sticky_time") end
function modifier_imba_degen_aura_passive:GetModifierAura() return "modifier_imba_degen_aura_stacks" end
function modifier_imba_degen_aura_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_omniknight_1") end
function modifier_imba_degen_aura_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_degen_aura_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_degen_aura_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_degen_aura_stacks = class({})

function modifier_imba_degen_aura_stacks:IsDebuff()				return true end
function modifier_imba_degen_aura_stacks:IsHidden() 			return false end
function modifier_imba_degen_aura_stacks:IsPurgable() 			return false end
function modifier_imba_degen_aura_stacks:IsPurgeException() 	return false end
function modifier_imba_degen_aura_stacks:GetEffectName() return "particles/units/heroes/hero_omniknight/omniknight_degen_aura_debuff.vpcf" end
function modifier_imba_degen_aura_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_degen_aura_stacks:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("as_reduction")) end
function modifier_imba_degen_aura_stacks:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("ms_reduction")) end
function modifier_imba_degen_aura_stacks:GetModifierBaseDamageOutgoing_Percentage() return (0 - self:GetStackCount()) end
function modifier_imba_degen_aura_stacks:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("stack_rate"))
	end
end
function modifier_imba_degen_aura_stacks:OnIntervalThink()
	self:SetStackCount(self:GetStackCount() + self:GetAbility():GetSpecialValueFor("reduction_tooltip"))
end

imba_omniknight_guardian_angel = class({})

LinkLuaModifier("modifier_imba_guardian_angel", "hero/hero_omniknight", LUA_MODIFIER_MOTION_NONE)

function imba_omniknight_guardian_angel:IsHiddenWhenStolen() 	return false end
function imba_omniknight_guardian_angel:IsRefreshable() 		return true end
function imba_omniknight_guardian_angel:IsStealable() 			return true end
function imba_omniknight_guardian_angel:IsNetherWardStealable()	return true end
function imba_omniknight_guardian_angel:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_omniknight_guardian_angel:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
	local pos = caster:GetAbsOrigin()
	local radius = caster:HasScepter() and 50000 or self:GetSpecialValueFor("radius")
	local duration = caster:HasScepter() and self:GetSpecialValueFor("duration_scepter") or self:GetSpecialValueFor("duration")
	local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	local ability = caster:FindAbilityByName("imba_omniknight_repel")
	for _, unit in pairs(units) do
		unit:EmitSound("Hero_Omniknight.GuardianAngel")
		buff = unit:AddNewModifier(caster, self, "modifier_imba_guardian_angel", {duration = duration})
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
		ParticleManager:SetParticleControlEnt(pfx, 5, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
		buff:AddParticle(pfx, false, false, 15, false, false)
		if ability and ability:GetLevel() > 0 then
			unit:AddNewModifier(caster, ability, "modifier_imba_repel", {duration = self:GetSpecialValueFor("repel_duration")})
		end
	end
end

modifier_imba_guardian_angel = class({})

function modifier_imba_guardian_angel:IsDebuff()			return false end
function modifier_imba_guardian_angel:IsHidden() 			return false end
function modifier_imba_guardian_angel:IsPurgable() 			return true end
function modifier_imba_guardian_angel:IsPurgeException() 	return true end
function modifier_imba_guardian_angel:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_imba_guardian_angel:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_imba_guardian_angel:GetStatusEffectName() return "particles/status_fx/status_effect_guardian_angel.vpcf" end
function modifier_imba_guardian_angel:StatusEffectPriority() return 15 end
function modifier_imba_guardian_angel:GetEffectName() return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_wings_buff.vpcf" end
function modifier_imba_guardian_angel:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_guardian_angel:ShouldUseOverheadOffset() return true end
function modifier_imba_guardian_angel:GetModifierConstantHealthRegen()
	if not self:GetParent():IsBuilding() then
		return self:GetCaster():GetTalentValue("special_bonus_imba_omniknight_2")
	else
		return 0
	end
end