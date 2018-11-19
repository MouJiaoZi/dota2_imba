CreateEmptyTalents("luna")



imba_luna_moon_glaive = class({})

LinkLuaModifier("modifier_imba_luna_moon_glaive", "hero/hero_luna", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_luna_moon_glaive_nodmg", "hero/hero_luna", LUA_MODIFIER_MOTION_NONE)

function imba_luna_moon_glaive:GetIntrinsicModifierName() return "modifier_imba_luna_moon_glaive" end

function imba_luna_moon_glaive:GlaiveAttck(source, damage, bounce)
	local target = nil
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), source:GetAbsOrigin(), nil, self:GetSpecialValueFor("range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= source then
			target = enemy
			break
		end
	end
	if target == nil then
		return
	end
	local info = 
	{
		Target = target,
		Source = source,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_luna/luna_moon_glaive.vpcf",
		iMoveSpeed = (self:GetCaster():IsRangedAttacker() and self:GetCaster():GetProjectileSpeed() or 900),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		ExtraData = {bounces = bounce, dmg = damage}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_luna_moon_glaive:OnProjectileHit_ExtraData(target, location, keys)
	local damage = keys.dmg * (1 - self:GetSpecialValueFor("damage_reduction_percent") / 100)
	if target then
		target:EmitSound("Hero_Luna.MoonGlaive.Impact")
		ApplyDamage({victim = target, attacker = self:GetCaster(), damage = damage, ability = self, damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL})
		if RollPercentage(self:GetSpecialValueFor("attack_effect_change")) and not self:GetCaster():IsIllusion() then
			self.GetCaster().splitattack = false
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_luna_moon_glaive_nodmg", {})
			self:GetCaster():PerformAttack(target, false, true, true, false, false, true, true)
			self:GetCaster():RemoveModifierByName("modifier_imba_luna_moon_glaive_nodmg")
			self.GetCaster().splitattack = true
		end
		local bounce = keys.bounces + 1
		if bounce >= self:GetSpecialValueFor("bounces") then
			return
		end
		local next_target = target
		self:GlaiveAttck(next_target, damage, bounce)
	end
end

modifier_imba_luna_moon_glaive = class({})

function modifier_imba_luna_moon_glaive:IsDebuff()			return false end
function modifier_imba_luna_moon_glaive:IsHidden() 			return true end
function modifier_imba_luna_moon_glaive:IsPurgable() 		return false end
function modifier_imba_luna_moon_glaive:IsPurgeException() 	return false end
function modifier_imba_luna_moon_glaive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_luna_moon_glaive:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_ambient_moon_glaive.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_weapon", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_luna_moon_glaive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsOther() or self:GetParent():PassivesDisabled() or self:GetParent():HasModifier("modifier_imba_luna_moon_glaive_nodmg") or not self:GetParent().splitattack then
		return
	end
	local dmg = keys.original_damage
	self:GetAbility():GlaiveAttck(keys.target, dmg, 0)
end

modifier_imba_luna_moon_glaive_nodmg = class({})

function modifier_imba_luna_moon_glaive_nodmg:IsDebuff()			return false end
function modifier_imba_luna_moon_glaive_nodmg:IsHidden() 			return true end
function modifier_imba_luna_moon_glaive_nodmg:IsPurgable() 			return false end
function modifier_imba_luna_moon_glaive_nodmg:IsPurgeException() 	return false end
function modifier_imba_luna_moon_glaive_nodmg:DeclareFunctions() return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_luna_moon_glaive_nodmg:GetModifierDamageOutgoing_Percentage() return (IsServer() and -100 or 0) end
