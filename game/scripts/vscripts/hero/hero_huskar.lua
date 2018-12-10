CreateEmptyTalents("huskar")

imba_huskar_berserkers_blood = class({})

LinkLuaModifier("modifier_imba_berserkers_blood_passive", "hero/hero_huskar", LUA_MODIFIER_MOTION_NONE)

function imba_huskar_berserkers_blood:GetIntrinsicModifierName() return "modifier_imba_berserkers_blood_passive" end

modifier_imba_berserkers_blood_passive = class({})

function modifier_imba_berserkers_blood_passive:IsDebuff()			return false end
function modifier_imba_berserkers_blood_passive:IsHidden() 			return true end
function modifier_imba_berserkers_blood_passive:IsPurgable() 		return false end
function modifier_imba_berserkers_blood_passive:IsPurgeException() 	return false end
function modifier_imba_berserkers_blood_passive:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_imba_berserkers_blood_passive:GetModifierAttackSpeedBonus_Constant() return (self:GetParent():PassivesDisabled() and 0 or (self:GetAbility():GetSpecialValueFor("maximum_attack_speed") * (self:GetStackCount() / 100))) end
function modifier_imba_berserkers_blood_passive:GetModifierMagicalResistanceBonus() return (self:GetParent():PassivesDisabled() and 0 or (self:GetAbility():GetSpecialValueFor("maximum_resistance") * (self:GetStackCount() / 100))) end
function modifier_imba_berserkers_blood_passive:GetModifierHPRegenAmplify_Percentage() return ((self:GetParent():PassivesDisabled() or self:GetParent():IsBoss()) and 0 or (self:GetAbility():GetSpecialValueFor("maximum_health_regen") * (self:GetStackCount() / 100))) end
function modifier_imba_berserkers_blood_passive:GetActivityTranslationModifiers() return (self:GetParent():PassivesDisabled() and nil or (self:GetStackCount() > 50 and "berserkers_blood" or nil)) end

function modifier_imba_berserkers_blood_passive:OnCreated()
	if IsServer() then
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserkers_blood.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		if not self:GetParent():IsIllusion() then
			self:StartIntervalThink(0.1)
		end
	end
end

function modifier_imba_berserkers_blood_passive:OnIntervalThink()
	local current = self:GetParent():GetHealth() - (self:GetAbility():GetSpecialValueFor("hp_threshold_max") / 100) * self:GetParent():GetMaxHealth()
	local max = self:GetParent():GetMaxHealth() - (self:GetAbility():GetSpecialValueFor("hp_threshold_max") / 100) * self:GetParent():GetMaxHealth()
	local mamax = math.max
	local pct = math.floor(((1 - mamax(current / max, 0)) * 100) + 0.5)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(pct, 0, 0))
	self:SetStackCount(pct)
end

function modifier_imba_berserkers_blood_passive:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end