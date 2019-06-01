item_imba_ultimate_scepter_synth = class({})

LinkLuaModifier("modifier_imba_consumable_scepter_passive", "items/item_scepter.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_consumable_scepter_consumed", "items/item_scepter.lua", LUA_MODIFIER_MOTION_NONE)

function item_imba_ultimate_scepter_synth:GetIntrinsicModifierName() return "modifier_imba_consumable_scepter_passive" end

function item_imba_ultimate_scepter_synth:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:IsClone() or target:IsTempestDouble() or target:HasModifier("modifier_item_ultimate_scepter_consumed") or target:HasModifier("modifier_imba_consumable_scepter_consumed") then
		return
	end
	target:AddNewModifier(caster, self, "modifier_imba_consumable_scepter_consumed", {})
	target:EmitSound("Hero_Alchemist.Scepter.Cast")
	Timers:CreateTimer(FrameTime(), function()
			self:RemoveSelf()
			return nil
		end
	)
end

modifier_imba_consumable_scepter_passive = class({})

function modifier_imba_consumable_scepter_passive:IsDebuff()			return false end
function modifier_imba_consumable_scepter_passive:IsHidden() 			return true end
function modifier_imba_consumable_scepter_passive:IsPurgable() 			return false end
function modifier_imba_consumable_scepter_passive:IsPurgeException() 	return false end
function modifier_imba_consumable_scepter_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_consumable_scepter_passive:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_consumable_scepter_passive:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_imba_consumable_scepter_passive:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_imba_consumable_scepter_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_consumable_scepter_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_consumable_scepter_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end

modifier_imba_consumable_scepter_consumed = class({})

function modifier_imba_consumable_scepter_consumed:IsDebuff()			return false end
function modifier_imba_consumable_scepter_consumed:IsHidden() 			return false end
function modifier_imba_consumable_scepter_consumed:IsPurgable() 		return false end
function modifier_imba_consumable_scepter_consumed:IsPurgeException() 	return false end
function modifier_imba_consumable_scepter_consumed:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end
function modifier_imba_consumable_scepter_consumed:GetTexture() return "imba_ultimate_scepter_synth" end

function modifier_imba_consumable_scepter_consumed:OnCreated()
	self:SetAbilityKV()
end

function modifier_imba_consumable_scepter_consumed:DeclareFunctions() return {MODIFIER_PROPERTY_IS_SCEPTER, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_consumable_scepter_consumed:GetModifierHealthBonus() return self:GetAbilityKV("bonus_health") end
function modifier_imba_consumable_scepter_consumed:GetModifierManaBonus() return self:GetAbilityKV("bonus_mana") end
function modifier_imba_consumable_scepter_consumed:GetModifierBonusStats_Strength() return self:GetAbilityKV("bonus_all_stats") end
function modifier_imba_consumable_scepter_consumed:GetModifierBonusStats_Intellect() return self:GetAbilityKV("bonus_all_stats") end
function modifier_imba_consumable_scepter_consumed:GetModifierBonusStats_Agility() return self:GetAbilityKV("bonus_all_stats") end