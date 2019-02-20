


item_imba_starfury = class({})

LinkLuaModifier("modifier_imba_starfury_passive", "items/item_starfury", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_starfury_unique", "items/item_starfury", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_starfury_buff_dummy", "items/item_starfury", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_starfury_dmg_reduce", "items/item_starfury", LUA_MODIFIER_MOTION_NONE)

function item_imba_starfury:GetIntrinsicModifierName() return "modifier_imba_starfury_passive" end

function item_imba_starfury:ProcProjectile(target, source)
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

function item_imba_starfury:OnProjectileHit(target, location)
	if not target or target:IsAttackImmune() then
		return
	end
	self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_multicast_attack_range", {})
	self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_imba_starfury_dmg_reduce", {})
	self:GetParent().splitattack = false
	self:GetCaster():PerformAttack(target, false, true, true, true, false, false, false)
	self:GetParent().splitattack = true
	self:GetParent():RemoveModifierByName("modifier_multicast_attack_range")
	self:GetParent():RemoveModifierByName("modifier_imba_starfury_dmg_reduce")
end

modifier_imba_starfury_passive = class({})

function modifier_imba_starfury_passive:IsDebuff()			return false end
function modifier_imba_starfury_passive:IsHidden() 			return true end
function modifier_imba_starfury_passive:IsPurgable() 		return false end
function modifier_imba_starfury_passive:IsPurgeException() 	return false end
function modifier_imba_starfury_passive:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_starfury_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_imba_starfury_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_starfury_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_imba_starfury_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_starfury_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_starfury_unique", {})
	end
end

function modifier_imba_starfury_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_starfury_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_starfury_unique")
	end
end
 
modifier_imba_starfury_unique = class({})

function modifier_imba_starfury_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_starfury_unique:OnDestroy() self.ability = nil end
function modifier_imba_starfury_unique:IsDebuff()			return false end
function modifier_imba_starfury_unique:IsHidden() 			return true end
function modifier_imba_starfury_unique:IsPurgable() 		return false end
function modifier_imba_starfury_unique:IsPurgeException() 	return false end
function modifier_imba_starfury_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_starfury_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and self.ability:IsCooldownReady() and self:GetParent().splitattack and not self:GetParent():IsIllusion() and keys.target:IsAlive() then
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= keys.target then
				self.ability:UseResources(true, true, true)
				self.ability:ProcProjectile(enemy, keys.target)
			end
		end
		if PseudoRandom:RollPseudoRandom(self.ability, self.ability:GetSpecialValueFor("proc_chance")) then
			self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_starfury_buff_dummy", {duration = self.ability:GetSpecialValueFor("proc_duration")})
		end
	end
end

modifier_item_imba_starfury_buff_dummy = class({})

function modifier_item_imba_starfury_buff_dummy:IsDebuff()			return false end
function modifier_item_imba_starfury_buff_dummy:IsHidden() 			return false end
function modifier_item_imba_starfury_buff_dummy:IsPurgable() 		return false end
function modifier_item_imba_starfury_buff_dummy:IsPurgeException() 	return false end
function modifier_item_imba_starfury_buff_dummy:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_item_imba_starfury_buff_dummy:GetModifierBonusStats_Agility() return self:GetStackCount() end

function modifier_item_imba_starfury_buff_dummy:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetParent():GetAgility() * (self:GetAbility():GetSpecialValueFor("proc_bonus") / 100))
	end
end

modifier_imba_starfury_dmg_reduce = class({})

function modifier_imba_starfury_dmg_reduce:IsDebuff()			return false end
function modifier_imba_starfury_dmg_reduce:IsHidden() 			return true end
function modifier_imba_starfury_dmg_reduce:IsPurgable() 		return false end
function modifier_imba_starfury_dmg_reduce:IsPurgeException() 	return false end
function modifier_imba_starfury_dmg_reduce:DeclareFunctions() return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_starfury_dmg_reduce:GetModifierTotalDamageOutgoing_Percentage()
	if IsServer() then
		return (0 - self:GetAbility():GetSpecialValueFor("dmg_reduction"))
	else
		return 0
	end
end