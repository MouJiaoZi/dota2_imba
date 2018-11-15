modifier_imba_unlimited_level_powerup = class({})

function modifier_imba_unlimited_level_powerup:IsDebuff()			return false end
function modifier_imba_unlimited_level_powerup:IsHidden() 			return (self:GetParent():GetLevel() <= 25) end
function modifier_imba_unlimited_level_powerup:IsPurgable() 		return false end
function modifier_imba_unlimited_level_powerup:IsPurgeException() 	return false end
function modifier_imba_unlimited_level_powerup:GetTexture() return "custom/unlimited_level_powerup" end
function modifier_imba_unlimited_level_powerup:RemoveOnDeath() return self:GetParent():IsIllusion() end

function modifier_imba_unlimited_level_powerup:OnCreated() self:StartIntervalThink(1.0) end

function modifier_imba_unlimited_level_powerup:OnIntervalThink() self:SetStackCount(math.max((self:GetParent():GetLevel() - 25), 0)) end

function modifier_imba_unlimited_level_powerup:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_unlimited_level_powerup:GetModifierBonusStats_Intellect() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierBonusStats_Agility() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierBonusStats_Strength() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierPreAttack_BonusDamage() return (2 * self:GetStackCount()) end
function modifier_imba_unlimited_level_powerup:GetModifierMoveSpeedBonus_Constant() return self:GetStackCount() end
function modifier_imba_unlimited_level_powerup:GetModifierSpellAmplify_Percentage() return self:GetStackCount() end