

item_imba_shotgun = class({})

LinkLuaModifier("modifier_imba_shotgun_passive", "items/item_shotgun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shotgun_unique", "items/item_shotgun", LUA_MODIFIER_MOTION_NONE)

function item_imba_shotgun:GetIntrinsicModifierName() return "modifier_imba_shotgun_passive" end

function item_imba_shotgun:ProcProjectile(target, source)
	local info = 
	{
		Target = target,
		Source = source,
		Ability = self,	
		EffectName = "particles/item/starfury/starfury_projectile.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		vSourceLoc = self:GetCaster():GetAbsOrigin(),
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

function item_imba_shotgun:OnProjectileHit(target, location)
	if not target then
		return
	end
	self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_multicast_attack_range", {})
	self:GetParent().splitattack = false
	self:GetCaster():PerformAttack(target, false, true, true, true, false, false, false)
	self:GetParent().splitattack = true
	self:GetParent():RemoveModifierByName("modifier_multicast_attack_range")
end

modifier_imba_shotgun_passive = class({})

function modifier_imba_shotgun_passive:IsDebuff()			return false end
function modifier_imba_shotgun_passive:IsHidden() 			return true end
function modifier_imba_shotgun_passive:IsPurgable() 		return false end
function modifier_imba_shotgun_passive:IsPurgeException() 	return false end
function modifier_imba_shotgun_passive:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_shotgun_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_imba_shotgun_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_shotgun_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_imba_shotgun_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_shotgun_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_shotgun_unique", {})
	end
end

function modifier_imba_shotgun_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_shotgun_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_shotgun_unique")
	end
end
 
modifier_imba_shotgun_unique = class({})

function modifier_imba_shotgun_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_shotgun_unique:OnDestroy() self.ability = nil end
function modifier_imba_shotgun_unique:IsDebuff()			return false end
function modifier_imba_shotgun_unique:IsHidden() 			return true end
function modifier_imba_shotgun_unique:IsPurgable() 			return false end
function modifier_imba_shotgun_unique:IsPurgeException() 	return false end
function modifier_imba_shotgun_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_shotgun_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and self.ability:IsCooldownReady() and self:GetParent().splitattack and not self:GetParent():HasModifier("modifier_imba_starfury_unique") and not self:GetParent():IsIllusion() and keys.target:IsAlive() then
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("proc_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
		local targets = self.ability:GetSpecialValueFor("max_targets")
		local target = 0
		for _, enemy in pairs(enemies) do
			if enemy ~= keys.target then
				self.ability:UseResources(true, true, true)
				target = target + 1
				self.ability:ProcProjectile(enemy, keys.target)
				if target >= targets then
					self:GetParent():EmitSound("Hero_PhantomLancer.Doppelganger.Appear")
					break
				end
			end
		end
	end
end