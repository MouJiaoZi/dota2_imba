CreateEmptyTalents("morphling")

imba_morphling_morphling = class({})

LinkLuaModifier("modifier_imba_morphling", "hero/hero_morphling", LUA_MODIFIER_MOTION_NONE)

function imba_morphling_morphling:GetIntrinsicModifierName() return "modifier_imba_morphling" end

modifier_imba_morphling = class({})

function modifier_imba_morphling:IsDebuff()			return false end
function modifier_imba_morphling:IsHidden() 		return true end
function modifier_imba_morphling:IsPurgable() 		return false end
function modifier_imba_morphling:IsPurgeException() return false end
function modifier_imba_morphling:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_morphling:GetModifierBonusStats_Agility() return (self:GetParent():GetBaseStrength() * (self:GetAbility():GetSpecialValueFor("conver_pct") / 100) + self:GetAbility():GetSpecialValueFor("bonus_attributes")) end
function modifier_imba_morphling:GetModifierBonusStats_Strength() return (self:GetParent():GetBaseAgility() * (self:GetAbility():GetSpecialValueFor("conver_pct") / 100) + self:GetAbility():GetSpecialValueFor("bonus_attributes")) end

function modifier_imba_morphling:OnCreated()
	if IsServer() then
		local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_morph_agi.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_morph_str.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx1, false, false, 15, false, false)
		self:AddParticle(pfx2, false, false, 15, false, false)
		for i=0, 23 do
			local abi = self:GetParent():GetAbilityByIndex(i)
			if abi and abi.ak then
				return
			end
		end
		local abi = self:GetParent():FindAbilityByName("generic_hidden")
		if abi then
			abi:SetHidden(false)
		end
	end
end