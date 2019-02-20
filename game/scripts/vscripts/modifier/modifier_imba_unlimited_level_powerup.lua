modifier_imba_unlimited_level_powerup = class({})

function modifier_imba_unlimited_level_powerup:IsDebuff()			return false end
function modifier_imba_unlimited_level_powerup:IsHidden() 			return (not (self:GetStackCount() > 0)) end
function modifier_imba_unlimited_level_powerup:IsPurgable() 		return false end
function modifier_imba_unlimited_level_powerup:IsPurgeException() 	return false end
function modifier_imba_unlimited_level_powerup:GetTexture() return "custom/unlimited_level_powerup" end
function modifier_imba_unlimited_level_powerup:RemoveOnDeath() return self:GetParent():IsIllusion() end

function modifier_imba_unlimited_level_powerup:OnCreated() self:StartIntervalThink(1.0) end

function modifier_imba_unlimited_level_powerup:OnIntervalThink()
	local level = 25
	if self:GetParent():HasModifier("modifier_imba_unlimited_powerup_ak") then
		level = 0
	end
	self:SetStackCount(math.max((self:GetParent():GetLevel() - level), 0))
end

function modifier_imba_unlimited_level_powerup:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_unlimited_level_powerup:GetModifierBonusStats_Intellect() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierBonusStats_Agility() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierBonusStats_Strength() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierPreAttack_BonusDamage() return (2 * self:GetStackCount()) end
function modifier_imba_unlimited_level_powerup:GetModifierMoveSpeedBonus_Constant() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierSpellAmplify_Percentage() return self:GetStackCount() end

modifier_imba_unlimited_powerup_ak = class({})

function modifier_imba_unlimited_powerup_ak:IsDebuff()			return false end
function modifier_imba_unlimited_powerup_ak:IsHidden() 			return true end
function modifier_imba_unlimited_powerup_ak:IsPurgable() 		return false end
function modifier_imba_unlimited_powerup_ak:IsPurgeException() 	return false end
function modifier_imba_unlimited_powerup_ak:GetTexture() return "custom/unlimited_level_powerup" end
function modifier_imba_unlimited_powerup_ak:RemoveOnDeath() return self:GetParent():IsIllusion() end

modifier_imba_ak_ability_adder = class({})

function modifier_imba_ak_ability_adder:IsDebuff()			return false end
function modifier_imba_ak_ability_adder:IsHidden() 			return false end
function modifier_imba_ak_ability_adder:IsPurgable() 		return false end
function modifier_imba_ak_ability_adder:IsPurgeException() 	return false end
function modifier_imba_ak_ability_adder:AllowIllusionDuplicate() return false end
function modifier_imba_ak_ability_adder:GetTexture() return "wisp/wisp_overcharge_alt" end
function modifier_imba_ak_ability_adder:RemoveOnDeath() return self:GetParent():IsIllusion() end

function modifier_imba_ak_ability_adder:OnCreated(keys)
	if IsServer() then
		self.ability_name = keys.ability_name
	end
end

function modifier_imba_ak_ability_adder:OnDestroy()
	if IsServer() then
		local ability = self:GetParent():AddAbility(self.ability_name)
		self:GetParent():SwapAbilities(self.ability_name, "generic_hidden", true, false)
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_imba_ak_ability_controller", {ability_name = self.ability_name})
		self.ability_name = nil
	end
end

modifier_imba_ak_ability_controller = class({})

function modifier_imba_ak_ability_controller:IsDebuff()			return false end
function modifier_imba_ak_ability_controller:IsHidden() 		return true end
function modifier_imba_ak_ability_controller:IsPurgable() 		return false end
function modifier_imba_ak_ability_controller:IsPurgeException() return false end
function modifier_imba_ak_ability_controller:RemoveOnDeath() return self:GetParent():IsIllusion() end

function modifier_imba_ak_ability_controller:OnCreated(keys)
	if IsServer() and self:GetParent():IsRealHero() then
		self.ability_name = keys.ability_name
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_ak_ability_controller:OnIntervalThink()
	local ability = self:GetParent():FindAbilityByName("self.ability_name")
	if not ability then
		return
	end
	local level = self:GetParent():GetLevel()
	if ability:GetAbilityType() == 1 then
		local level_to_set = math.min(math.floor(level / 6), ability:GetMaxLevel())
		if ability:GetLevel() ~= level_to_set then
			ability:SetLevel(level_to_set)
		end
	else
		local level_to_set = math.min((math.floor((level + 1) / 2) - 1), ability:GetMaxLevel())
		if ability:GetLevel() ~= level_to_set then
			ability:SetLevel(level_to_set)
		end
	end
end

function modifier_imba_ak_ability_controller:OnDestroy()
	if IsServer() then
		self.ability_name = nil
	end
end