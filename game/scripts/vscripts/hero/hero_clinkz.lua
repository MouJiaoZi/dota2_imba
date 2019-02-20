CreateEmptyTalents("clinkz")

imba_clinkz_strafe = class({})

LinkLuaModifier("modifier_imba_strafe_active", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_strafe_passive", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)

function imba_clinkz_strafe:IsHiddenWhenStolen() 	return false end
function imba_clinkz_strafe:IsRefreshable() 		return true  end
function imba_clinkz_strafe:IsStealable() 			return true  end
function imba_clinkz_strafe:IsNetherWardStealable() return true end

function imba_clinkz_strafe:GetIntrinsicModifierName() return "modifier_imba_strafe_passive" end

function imba_clinkz_strafe:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_strafe_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_Clinkz.Strafe", self:GetCaster())
end

modifier_imba_strafe_active = class({})

function modifier_imba_strafe_active:IsDebuff()				return false end
function modifier_imba_strafe_active:IsHidden() 			return false end
function modifier_imba_strafe_active:IsPurgable() 			return true end
function modifier_imba_strafe_active:IsPurgeException() 	return true end
function modifier_imba_strafe_active:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_imba_strafe_active:CheckState()
	if self:GetCaster():HasTalent("special_bonus_imba_clinkz_1") then
		return {[MODIFIER_STATE_DISARMED] = false}
	end
end

function modifier_imba_strafe_active:GetEffectName() return "particles/units/heroes/hero_clinkz/clinkz_strafe.vpcf" end
function modifier_imba_strafe_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_strafe_active:OnCreated()
	if IsServer() then
		local interval = self:GetAbility():GetSpecialValueFor("strafe_interval")
		if self:GetCaster():HasScepter() then
			interval = self:GetAbility():GetSpecialValueFor("strafe_interval_scepter")
		end
		self:StartIntervalThink(interval)
	end
end

function modifier_imba_strafe_active:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:IsInvisible() or caster:IsStunned() or caster:IsDisarmed() or caster:IsHexed() then
		return
	end
	local target = caster:GetAttackTarget()
	local range = caster:Script_GetAttackRange()
	if target and (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= (range + 100) then
		caster:StartGesture(ACT_DOTA_ATTACK)
		caster:PerformAttack(target, true, true, true, false, true, false, false)
	else
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, range+100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
		if #enemies > 0 then
			caster:StartGesture(ACT_DOTA_ATTACK)
			caster:PerformAttack(enemies[1], true, true, true, false, true, false, false)
		end
	end
end

modifier_imba_strafe_passive = class({})

function modifier_imba_strafe_passive:IsDebuff()			return false end
function modifier_imba_strafe_passive:IsHidden() 			return true end
function modifier_imba_strafe_passive:IsPurgable() 			return false end
function modifier_imba_strafe_passive:IsPurgeException() 	return false end

function modifier_imba_strafe_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_imba_strafe_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("as_bonus") end

imba_clinkz_searing_arrows = class({})

LinkLuaModifier("modifier_imba_searing_arrows_debuff", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_searing_arrows_passive", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)

function imba_clinkz_searing_arrows:GetIntrinsicModifierName() return "modifier_imba_searing_arrows_passive" end

modifier_imba_searing_arrows_passive = class({})

function modifier_imba_searing_arrows_passive:IsDebuff()			return false end
function modifier_imba_searing_arrows_passive:IsHidden() 			return true end
function modifier_imba_searing_arrows_passive:IsPurgable() 			return false end
function modifier_imba_searing_arrows_passive:IsPurgeException() 	return false end
function modifier_imba_searing_arrows_passive:GetPriority() 		return MODIFIER_PRIORITY_LOW end

function modifier_imba_searing_arrows_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_PROJECTILE_NAME}
end

function modifier_imba_searing_arrows_passive:GetModifierProjectileName() return "particles/units/heroes/hero_clinkz/clinkz_searing_arrow.vpcf" end

function modifier_imba_searing_arrows_passive:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() then
		return
	end
	EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Clinkz.SearingArrows", self:GetParent())
end

function modifier_imba_searing_arrows_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or self:GetParent():IsIllusion() or not keys.target:IsAlive() then
		return
	end
	local target = keys.target
	local damageTable = {
						victim = target,
						attacker = self:GetCaster(),
						damage = self:GetAbility():GetSpecialValueFor("bonus_damage"),
						damage_type = self:GetAbility():GetAbilityDamageType(),
						ability = self:GetAbility(),
						damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE,
						}
	ApplyDamage(damageTable)
	target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_searing_arrows_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Clinkz.SearingArrows.Impact", target)
end

modifier_imba_searing_arrows_debuff = class({})

function modifier_imba_searing_arrows_debuff:IsDebuff()				return true end
function modifier_imba_searing_arrows_debuff:IsHidden() 			return false end
function modifier_imba_searing_arrows_debuff:IsPurgable() 			return true end
function modifier_imba_searing_arrows_debuff:IsPurgeException() 	return true end

function modifier_imba_searing_arrows_debuff:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_searing_arrow_trail_ember.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_searing_arrows_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_imba_searing_arrows_debuff:GetModifierPhysicalArmorBonus() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor_reduction")) end

function modifier_imba_searing_arrows_debuff:OnRefresh()
	if self:GetStackCount() < self:GetAbility():GetSpecialValueFor("max_stacks") then
		self:IncrementStackCount()
	end
end

imba_clinkz_skeleton_walk = class({})

LinkLuaModifier("modifier_imba_skeleton_walk", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_skeleton_walk_extra", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)

function imba_clinkz_skeleton_walk:IsHiddenWhenStolen() 	return false end
function imba_clinkz_skeleton_walk:IsRefreshable() 			return true  end
function imba_clinkz_skeleton_walk:IsStealable() 			return true  end
function imba_clinkz_skeleton_walk:IsNetherWardStealable()	return true end

function imba_clinkz_skeleton_walk:OnSpellStart()
	local caster = self:GetCaster()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	caster:AddNewModifier(caster, self, "modifier_imba_skeleton_walk", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Clinkz.WindWalk", caster)
end

modifier_imba_skeleton_walk = class({})

function modifier_imba_skeleton_walk:IsDebuff()				return false end
function modifier_imba_skeleton_walk:IsHidden() 			return false end
function modifier_imba_skeleton_walk:IsPurgable() 			return false end
function modifier_imba_skeleton_walk:IsPurgeException() 	return false end
function modifier_imba_skeleton_walk:GetEffectName() return "particles/generic_hero_status/status_invisibility_start.vpcf" end
function modifier_imba_skeleton_walk:GetEffectAttachType() return PATTACH_ABSORIGIN end

function modifier_imba_skeleton_walk:CheckState()
	return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_imba_skeleton_walk:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_DISABLE_AUTOATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_imba_skeleton_walk:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("ms_bonus") end

function modifier_imba_skeleton_walk:GetDisableAutoAttack() return true end

function modifier_imba_skeleton_walk:OnAttack(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and self:GetParent():IsRangedAttacker() then
		self:Destroy()
	end
end

function modifier_imba_skeleton_walk:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():IsRangedAttacker() then
		self:Destroy()
	end
end

function modifier_imba_skeleton_walk:OnAbilityExecuted(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	self:Destroy()
end

function modifier_imba_skeleton_walk:GetModifierInvisibilityLevel() return 1 end

function modifier_imba_skeleton_walk:OnDestroy()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_skeleton_walk_extra", {duration = self:GetAbility():GetSpecialValueFor("extra_duration")})
	end
end

modifier_imba_skeleton_walk_extra = class({})

function modifier_imba_skeleton_walk_extra:IsDebuff()			return false end
function modifier_imba_skeleton_walk_extra:IsHidden() 			return false end
function modifier_imba_skeleton_walk_extra:IsPurgable() 		return false end
function modifier_imba_skeleton_walk_extra:IsPurgeException() 	return false end

function modifier_imba_skeleton_walk_extra:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_imba_skeleton_walk_extra:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("ms_bonus") end

imba_clinkz_death_pact = class({})

LinkLuaModifier("modifier_imba_death_pact_caster", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_death_pact_caster_str", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_death_pact_caster_agi", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_death_pact_caster_permanent", "hero/hero_clinkz", LUA_MODIFIER_MOTION_NONE)

function imba_clinkz_death_pact:IsHiddenWhenStolen() 	return false end
function imba_clinkz_death_pact:IsRefreshable() 		return true  end
function imba_clinkz_death_pact:IsStealable() 			return true  end
function imba_clinkz_death_pact:IsNetherWardStealable()	return true end

function imba_clinkz_death_pact:GetIntrinsicModifierName() return "modifier_imba_death_pact_caster_permanent" end

function imba_clinkz_death_pact:CastFilterResultTarget(target)
	if target == self:GetCaster() or (not target:IsCreep() and not target:IsHero()) or target:IsAncient() then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function imba_clinkz_death_pact:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() or (not target:IsCreep() and not target:IsHero()) or target:IsAncient() then
		return "dota_hud_error_cant_cast_on_other"
	end
end

function imba_clinkz_death_pact:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Clinkz.BurningArmy.SpellStart")
	return true
end

function imba_clinkz_death_pact:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("Hero_Clinkz.BurningArmy.Cast")
	local duration = self:GetSpecialValueFor("duration_creep")
	if target:IsHero() then
		local damageTable = {
							victim = target,
							attacker = caster,
							damage = (self:GetSpecialValueFor("damage_hero") / 100 * target:GetMaxHealth()),
							damage_type = self:GetAbilityDamageType(),
							ability = self,
							}
		ApplyDamage(damageTable)
		duration = self:GetSpecialValueFor("duration_hero")
	else
		target:Kill(self, caster)
	end
	caster:AddNewModifier(target, self, "modifier_imba_death_pact_caster", {duration = duration})
	local death_pact_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(death_pact_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(death_pact_pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(death_pact_pfx)
	self.hero = target
end

modifier_imba_death_pact_caster = class({})

function modifier_imba_death_pact_caster:IsDebuff()				return false end
function modifier_imba_death_pact_caster:IsHidden() 			return false end
function modifier_imba_death_pact_caster:IsPurgable() 			return false end
function modifier_imba_death_pact_caster:IsPurgeException() 	return false end

function modifier_imba_death_pact_caster:OnCreated()
	if IsServer() then
		local target = self:GetCaster()
		local caster = self:GetParent()
		local str
		local agi
		local duration
		if target:IsHero() then
			duration = self:GetAbility():GetSpecialValueFor("duration_hero")
			str = self:GetAbility():GetSpecialValueFor("str_pct_hero") / 100 * target:GetMaxHealth()
			agi = self:GetAbility():GetSpecialValueFor("agi_pct_hero") / 100 * target:GetMaxHealth()
		else
			duration = self:GetAbility():GetSpecialValueFor("duration_creep")
			str = self:GetAbility():GetSpecialValueFor("str_pct_creep") / 100 * target:GetMaxHealth()
			agi = self:GetAbility():GetSpecialValueFor("agi_pct_creep") / 100 * target:GetMaxHealth()
		end
		self:SetDuration(duration, true)
		if caster:HasModifier("modifier_imba_death_pact_caster_str") then
			caster:FindModifierByName("modifier_imba_death_pact_caster_str"):ForceRefresh()
			caster:FindModifierByName("modifier_imba_death_pact_caster_str"):SetStackCount(str)
		else
			local str_buff = caster:AddNewModifier(caster, self:GetAbility(), "modifier_imba_death_pact_caster_str", {duration = duration})
			str_buff:SetStackCount(str)
		end
		if caster:HasModifier("modifier_imba_death_pact_caster_agi") then
			caster:FindModifierByName("modifier_imba_death_pact_caster_agi"):ForceRefresh()
			caster:FindModifierByName("modifier_imba_death_pact_caster_agi"):SetStackCount(agi)
		else
			local agi_buff = caster:AddNewModifier(caster, self:GetAbility(), "modifier_imba_death_pact_caster_agi", {duration = duration})
			agi_buff:SetStackCount(agi)
		end
		caster:CalculateStatBonus()
	end
end

function modifier_imba_death_pact_caster:OnRefresh()
	self:OnCreated()
end

modifier_imba_death_pact_caster_str = class({})
modifier_imba_death_pact_caster_agi = class({})

function modifier_imba_death_pact_caster_str:IsDebuff()				return false end
function modifier_imba_death_pact_caster_str:IsHidden() 			return true end
function modifier_imba_death_pact_caster_str:IsPurgable() 			return false end
function modifier_imba_death_pact_caster_str:IsPurgeException() 	return false end

function modifier_imba_death_pact_caster_agi:IsDebuff()				return false end
function modifier_imba_death_pact_caster_agi:IsHidden() 			return true end
function modifier_imba_death_pact_caster_agi:IsPurgable() 			return false end
function modifier_imba_death_pact_caster_agi:IsPurgeException() 	return false end

function modifier_imba_death_pact_caster_str:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,} end
function modifier_imba_death_pact_caster_agi:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS,} end

function modifier_imba_death_pact_caster_str:GetModifierBonusStats_Strength() return self:GetStackCount() end
function modifier_imba_death_pact_caster_agi:GetModifierBonusStats_Agility() return self:GetStackCount() end

modifier_imba_death_pact_caster_permanent = class({})

function modifier_imba_death_pact_caster_permanent:IsDebuff()				return false end
function modifier_imba_death_pact_caster_permanent:IsPurgable() 			return false end
function modifier_imba_death_pact_caster_permanent:IsPurgeException() 		return false end
function modifier_imba_death_pact_caster_permanent:IsHidden()
	if self:GetCaster():HasScepter() then
		return false
	else
		return true
	end
end

function modifier_imba_death_pact_caster_permanent:DeclareFunctions()
	return {MODIFIER_EVENT_ON_HERO_KILLED, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_imba_death_pact_caster_permanent:GetModifierBonusStats_Strength()
	if self:GetCaster():HasScepter() then
		return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_str_scepter"))
	else
		return 0
	end
end

function modifier_imba_death_pact_caster_permanent:GetModifierBonusStats_Agility()
	if self:GetCaster():HasScepter() then
		return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_agi_scepter"))
	else
		return 0
	end
end

function modifier_imba_death_pact_caster_permanent:OnHeroKilled(keys)
	if not IsServer() then
		return
	end
	if self:GetAbility().hero == keys.target and self:GetCaster():HasModifier("modifier_imba_death_pact_caster") then
		self:SetStackCount(self:GetStackCount() + 1)
	elseif keys.target == self:GetCaster() then
		self:SetStackCount(math.max(self:GetStackCount() - 1, 0))
	end
end
