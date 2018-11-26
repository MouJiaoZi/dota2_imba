
item_imba_heart = class({})

LinkLuaModifier("modifier_imba_heart_passive", "items/item_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_heart_unique", "items/item_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_heart_disable", "items/item_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_heart_aura_effect", "items/item_heart", LUA_MODIFIER_MOTION_NONE)

function item_imba_heart:GetIntrinsicModifierName() return "modifier_imba_heart_passive" end

function item_imba_heart:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

modifier_imba_heart_passive = class({})

function modifier_imba_heart_passive:IsDebuff()			return false end
function modifier_imba_heart_passive:IsHidden() 		return true end
function modifier_imba_heart_passive:IsPurgable() 		return false end
function modifier_imba_heart_passive:IsPurgeException() return false end
function modifier_imba_heart_passive:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_heart_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_heart_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_heart_passive:GetModifierHealthBonus() return self.ability:GetSpecialValueFor("bonus_health") end
function modifier_imba_heart_passive:GetModifierBonusStats_Strength() return self.ability:GetSpecialValueFor("bonus_strength") end

function modifier_imba_heart_passive:OnTakeDamage(keys)
	if IsServer() and keys.unit == self:GetParent() and IsHeroDamage(keys.attacker, keys.damage) and IsEnemy(keys.attacker, self:GetParent()) then
		self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_imba_heart_disable", {duration = self.ability:GetSpecialValueFor("regen_cooldown")})
		self:GetAbility():StartCooldown(self.ability:GetSpecialValueFor("regen_cooldown"))
	end
end

function modifier_imba_heart_passive:OnCreated()
	if IsServer() then
		self.ability = self:GetAbility()
		self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_imba_heart_unique", {})
	end
end

function modifier_imba_heart_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_heart_passive") then
		self.ability = nil
		self:GetParent():RemoveModifierByName("modifier_imba_heart_unique")
	end
end

function modifier_imba_heart_passive:IsAura() return true end
function modifier_imba_heart_passive:GetAuraDuration() return 0.1 end
function modifier_imba_heart_passive:GetModifierAura() return "modifier_item_heart_aura_effect" end
function modifier_imba_heart_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_heart_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_heart_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_heart_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_heart_unique = class({})

function modifier_imba_heart_unique:IsDebuff()			return false end
function modifier_imba_heart_unique:IsHidden() 			return true end
function modifier_imba_heart_unique:IsPurgable() 		return false end
function modifier_imba_heart_unique:IsPurgeException() 	return false end
function modifier_imba_heart_unique:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_heart_unique:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end

function modifier_imba_heart_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_heart_unique:OnDestroy() self.ability = nil end

function modifier_imba_heart_unique:GetModifierHealthRegenPercentage()
	if self:GetParent():HasModifier("modifier_imba_heart_disable") then
		return self.ability:GetSpecialValueFor("base_regen")
	else
		return self.ability:GetSpecialValueFor("regen_tooltip")
	end
end

modifier_imba_heart_disable = class({})

function modifier_imba_heart_disable:IsDebuff()			return false end
function modifier_imba_heart_disable:IsHidden() 		return true end
function modifier_imba_heart_disable:IsPurgable() 		return false end
function modifier_imba_heart_disable:IsPurgeException() return false end
function modifier_imba_heart_disable:RemoveOnDeath() return self:GetParent():IsIllusion() end

modifier_item_heart_aura_effect = class({})

function modifier_item_heart_aura_effect:IsDebuff()			return false end
function modifier_item_heart_aura_effect:IsHidden() 		return false end
function modifier_item_heart_aura_effect:IsPurgable() 		return false end
function modifier_item_heart_aura_effect:IsPurgeException() return false end
function modifier_item_heart_aura_effect:GetTexture() return "custom/imba_heart" end
function modifier_item_heart_aura_effect:OnCreated() self.ability = self:GetAbility() end
function modifier_item_heart_aura_effect:OnDestroy() self.ability = nil end
function modifier_item_heart_aura_effect:DeclareFunctions() return  {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE} end
function modifier_item_heart_aura_effect:GetModifierBonusStats_Strength() return self.ability:GetSpecialValueFor("aura_str") end
function modifier_item_heart_aura_effect:GetModifierHPRegenAmplify_Percentage() return self.ability:GetSpecialValueFor("regen_pct") end