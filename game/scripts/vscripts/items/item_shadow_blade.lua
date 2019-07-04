

item_imba_shadow_blade = class({})

LinkLuaModifier("modifier_imba_shadow_blade_passive", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_blade_fade", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_silver_edge_detected", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_silver_edge_detect_thinker", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shadow_blade_phase_disable", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_shadow_blade_invis", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)

function item_imba_shadow_blade:GetIntrinsicModifierName() return "modifier_imba_shadow_blade_passive" end

function item_imba_shadow_blade:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.InvisibilitySword.Activate")
	caster:AddNewModifier(caster, self, "modifier_imba_shadow_blade_fade", {duration = self:GetSpecialValueFor("invis_fade_time")})
end

function item_imba_shadow_blade:RangedAttackerBreakInvisAttack(target)
	local info = 
	{
		Target = target,
		Source = self:GetCaster(),
		Ability = self,	
		EffectName = nil,
		iMoveSpeed = self:GetCaster():GetProjectileSpeed(),
		vSourceLoc = self:GetCaster():GetAbsOrigin(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function item_imba_shadow_blade:OnProjectileHit(target, location)
	if not target then
		return
	end
	target:EmitSound("DOTA_Item.Maim")
	ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("invis_damage"), damage_type = DAMAGE_TYPE_PHYSICAL})
end

modifier_imba_shadow_blade_passive = class({})

function modifier_imba_shadow_blade_passive:IsDebuff()			return false end
function modifier_imba_shadow_blade_passive:IsHidden() 			return true end
function modifier_imba_shadow_blade_passive:IsPurgable() 		return false end
function modifier_imba_shadow_blade_passive:IsPurgeException() 	return false end
function modifier_imba_shadow_blade_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_shadow_blade_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_shadow_blade_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_shadow_blade_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end

modifier_imba_shadow_blade_fade = class({}) 

function modifier_imba_shadow_blade_fade:IsDebuff()			return false end
function modifier_imba_shadow_blade_fade:IsHidden() 		return true end
function modifier_imba_shadow_blade_fade:IsPurgable() 		return false end
function modifier_imba_shadow_blade_fade:IsPurgeException() return false end
function modifier_imba_shadow_blade_fade:GetStatusEffectName() return "particles/generic_hero_status/status_invisibility_start.vpcf" end
function modifier_imba_shadow_blade_fade:StatusEffectPriority() return 15 end

function modifier_imba_shadow_blade_fade:OnDestroy()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_imba_shadow_blade_invis", {duration = self:GetAbility():GetSpecialValueFor("invis_duration")})
	end
end

modifier_item_imba_shadow_blade_invis = class({})

function modifier_item_imba_shadow_blade_invis:IsDebuff()			return false end
function modifier_item_imba_shadow_blade_invis:IsHidden() 			return false end
function modifier_item_imba_shadow_blade_invis:IsPurgable() 		return false end
function modifier_item_imba_shadow_blade_invis:IsPurgeException() 	return false end
function modifier_item_imba_shadow_blade_invis:CheckState()
	if self:GetParent():HasModifier("modifier_imba_shadow_blade_phase_disable") then
		return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	else
		return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} 
	end
end
function modifier_item_imba_shadow_blade_invis:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_DISABLE_AUTOATTACK, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ABILITY_EXECUTED} end
function modifier_item_imba_shadow_blade_invis:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("invis_ms") end
function modifier_item_imba_shadow_blade_invis:GetDisableAutoAttack() return true end
function modifier_item_imba_shadow_blade_invis:GetBonusNightVision() return self:GetAbility():GetSpecialValueFor("invis_night_vision") end
function modifier_item_imba_shadow_blade_invis:GetModifierInvisibilityLevel() return 1 end

function modifier_item_imba_shadow_blade_invis:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and IsEnemy(keys.unit, keys.attacker) and IsHeroDamage(keys.attacker, keys.damage) then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), false)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_shadow_blade_phase_disable", {duration = self:GetAbility():GetSpecialValueFor("invis_phase_cooldown")})
	end
end

function modifier_item_imba_shadow_blade_invis:OnAttackLanded(keys)
	if not IsServer() or self:GetParent():IsRangedAttacker() then
		return
	end
	if keys.attacker ~= self:GetParent() then
		return
	end
	self:Destroy()
	if not keys.target:IsOther() and keys.target:IsBuilding() then
		ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("invis_damage"), damage_type = DAMAGE_TYPE_PHYSICAL})
		keys.target:EmitSound("DOTA_Item.Maim")
	end
end

function modifier_item_imba_shadow_blade_invis:OnAttack(keys)
	if not IsServer() or not self:GetParent():IsRangedAttacker() then
		return
	end
	if keys.attacker ~= self:GetParent() then
		return
	end
	self:Destroy()
	if not keys.target:IsOther() and keys.target:IsBuilding() then
		self:GetAbility():RangedAttackerBreakInvisAttack(keys.target)
	end
end

function modifier_item_imba_shadow_blade_invis:OnAbilityExecuted(keys)
	if IsServer() and keys.unit == self:GetParent() then
		self:Destroy()
	end
end

function modifier_item_imba_shadow_blade_invis:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), false)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
	end
end

modifier_imba_shadow_blade_phase_disable = class({})

function modifier_imba_shadow_blade_phase_disable:IsDebuff()			return false end
function modifier_imba_shadow_blade_phase_disable:IsHidden() 			return true end
function modifier_imba_shadow_blade_phase_disable:IsPurgable() 			return false end
function modifier_imba_shadow_blade_phase_disable:IsPurgeException() 	return false end


item_imba_silver_edge = class({})

LinkLuaModifier("modifier_imba_silver_edge_passive", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_silver_edge_fade", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_silver_edge_phase_disable", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_silver_edge_invis", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_silver_edge_detected", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_silver_edge_break", "items/item_shadow_blade", LUA_MODIFIER_MOTION_NONE)

function item_imba_silver_edge:GetIntrinsicModifierName() return "modifier_imba_silver_edge_passive" end

function item_imba_silver_edge:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.InvisibilitySword.Activate")
	caster:AddNewModifier(caster, self, "modifier_imba_silver_edge_fade", {duration = self:GetSpecialValueFor("invis_fade_time")})
end

function item_imba_silver_edge:RangedAttackerBreakInvisAttack(target)
	local info = 
	{
		Target = target,
		Source = self:GetCaster(),
		Ability = self,	
		EffectName = nil,
		iMoveSpeed = self:GetCaster():GetProjectileSpeed(),
		vSourceLoc = self:GetCaster():GetAbsOrigin(),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function item_imba_silver_edge:OnProjectileHit(target, location)
	if not target then
		return
	end
	target:EmitSound("DOTA_Item.SilverEdge.Target")
	ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("invis_damage"), damage_type = DAMAGE_TYPE_PHYSICAL})
	local pfx = ParticleManager:CreateParticle("particles/item/silver_edge/silver_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(pfx)
	target:AddNewModifier(self:GetParent(), self, "modifier_item_imba_silver_edge_break", {duration = self:GetSpecialValueFor("break_duration")})
end

modifier_imba_silver_edge_passive = class({})

function modifier_imba_silver_edge_passive:IsDebuff()			return false end
function modifier_imba_silver_edge_passive:IsHidden() 			return true end
function modifier_imba_silver_edge_passive:IsPurgable() 		return false end
function modifier_imba_silver_edge_passive:IsPurgeException() 	return false end
function modifier_imba_silver_edge_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_silver_edge_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_silver_edge_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_silver_edge_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_silver_edge_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_silver_edge_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_stats") end
function modifier_imba_silver_edge_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_stats") end

modifier_imba_silver_edge_fade = class({}) 

function modifier_imba_silver_edge_fade:IsDebuff()			return false end
function modifier_imba_silver_edge_fade:IsHidden() 			return true end
function modifier_imba_silver_edge_fade:IsPurgable() 		return false end
function modifier_imba_silver_edge_fade:IsPurgeException() 	return false end
function modifier_imba_silver_edge_fade:GetStatusEffectName() return "particles/generic_hero_status/status_invisibility_start.vpcf" end
function modifier_imba_silver_edge_fade:StatusEffectPriority() return 15 end

function modifier_imba_silver_edge_fade:OnDestroy()
	if IsServer() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_imba_silver_edge_invis", {duration = self:GetAbility():GetSpecialValueFor("invis_duration")})
	end
end

modifier_item_imba_silver_edge_invis = class({})

function modifier_item_imba_silver_edge_invis:IsDebuff()			return false end
function modifier_item_imba_silver_edge_invis:IsHidden() 			return false end
function modifier_item_imba_silver_edge_invis:IsPurgable() 		return false end
function modifier_item_imba_silver_edge_invis:IsPurgeException() 	return false end
function modifier_item_imba_silver_edge_invis:CheckState()
	if self:GetParent():HasModifier("modifier_imba_silver_edge_phase_disable") then
		return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	else
		return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} 
	end
end
function modifier_item_imba_silver_edge_invis:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_DISABLE_AUTOATTACK, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_ABILITY_EXECUTED} end
function modifier_item_imba_silver_edge_invis:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("invis_ms") end
function modifier_item_imba_silver_edge_invis:GetDisableAutoAttack() return true end
function modifier_item_imba_silver_edge_invis:GetBonusNightVision() return self:GetAbility():GetSpecialValueFor("invis_night_vision") end
function modifier_item_imba_silver_edge_invis:GetModifierInvisibilityLevel() return 1 end

function modifier_item_imba_silver_edge_invis:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and IsEnemy(keys.unit, keys.attacker) and IsHeroDamage(keys.attacker, keys.damage) then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), false)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_silver_edge_phase_disable", {duration = self:GetAbility():GetSpecialValueFor("invis_phase_cooldown")})
	end
end

function modifier_item_imba_silver_edge_invis:OnAttackLanded(keys)
	if not IsServer() or self:GetParent():IsRangedAttacker() then
		return
	end
	if keys.attacker ~= self:GetParent() then
		return
	end
	self:Destroy()
	if keys.target:IsOther() or keys.target:IsBuilding() or keys.attacker ~= self:GetParent() then
		return
	end
	ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("invis_damage"), damage_type = DAMAGE_TYPE_PHYSICAL})
	local pfx = ParticleManager:CreateParticle("particles/item/silver_edge/silver_edge.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:ReleaseParticleIndex(pfx)
	keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_silver_edge_break", {duration = self:GetAbility():GetSpecialValueFor("break_duration")})
	keys.target:EmitSound("DOTA_Item.SilverEdge.Target")
end

function modifier_item_imba_silver_edge_invis:OnAttack(keys)
	if not IsServer() or not self:GetParent():IsRangedAttacker() then
		return
	end
	if keys.attacker ~= self:GetParent() then
		return
	end
	self:Destroy()
	if keys.target:IsOther() or keys.target:IsBuilding() or keys.attacker ~= self:GetParent() then
		return
	end
	self:GetAbility():RangedAttackerBreakInvisAttack(keys.target)
end

function modifier_item_imba_silver_edge_invis:OnAbilityExecuted(keys)
	if IsServer() and keys.unit == self:GetParent() then
		self:Destroy()
	end
end

function modifier_item_imba_silver_edge_invis:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), false)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
	end
end

function modifier_item_imba_silver_edge_invis:IsAura() return true end
function modifier_item_imba_silver_edge_invis:GetAuraDuration() return 0.1 end
function modifier_item_imba_silver_edge_invis:GetModifierAura() return "modifier_imba_silver_edge_detected" end
function modifier_item_imba_silver_edge_invis:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("detection_radius") end
function modifier_item_imba_silver_edge_invis:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_item_imba_silver_edge_invis:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_imba_silver_edge_invis:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_silver_edge_detected = class({})

function modifier_imba_silver_edge_detected:IsDebuff()			return true end
function modifier_imba_silver_edge_detected:IsHidden() 			return true end
function modifier_imba_silver_edge_detected:IsPurgable() 		return false end
function modifier_imba_silver_edge_detected:IsPurgeException() 	return false end
function modifier_imba_silver_edge_detected:GetEffectName() return "particles/item/silver_edge/silver_edge_target.vpcf" end
function modifier_imba_silver_edge_detected:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_silver_edge_detected:DeclareFunctions() return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_silver_edge_detected:GetModifierProvidesFOWVision() return 1 end

modifier_imba_silver_edge_phase_disable = class({})

function modifier_imba_silver_edge_phase_disable:IsDebuff()				return false end
function modifier_imba_silver_edge_phase_disable:IsHidden() 			return true end
function modifier_imba_silver_edge_phase_disable:IsPurgable() 			return false end
function modifier_imba_silver_edge_phase_disable:IsPurgeException() 	return false end

modifier_item_imba_silver_edge_break = class({})

function modifier_item_imba_silver_edge_break:IsDebuff()			return true end
function modifier_item_imba_silver_edge_break:IsHidden() 			return false end
function modifier_item_imba_silver_edge_break:IsPurgable() 			return false end
function modifier_item_imba_silver_edge_break:IsPurgeException() 	return false end
function modifier_item_imba_silver_edge_break:CheckState() return {[MODIFIER_STATE_PASSIVES_DISABLED] = true} end
function modifier_item_imba_silver_edge_break:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end
function modifier_item_imba_silver_edge_break:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("break_slow")) end
function modifier_item_imba_silver_edge_break:GetModifierDamageOutgoing_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("break_damage_reduction")) end
function modifier_item_imba_silver_edge_break:GetEffectName() return "particles/items3_fx/silver_edge_slow.vpcf" end
function modifier_item_imba_silver_edge_break:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end