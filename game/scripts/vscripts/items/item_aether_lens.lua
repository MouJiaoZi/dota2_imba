

item_imba_aether_lens = class({})

LinkLuaModifier("modifier_imba_aether_lens_passive", "items/item_aether_lens", LUA_MODIFIER_MOTION_NONE)

function item_imba_aether_lens:GetIntrinsicModifierName() return "modifier_imba_aether_lens_passive" end

modifier_imba_aether_lens_passive = class({})

function modifier_imba_aether_lens_passive:IsDebuff()			return false end
function modifier_imba_aether_lens_passive:IsHidden() 			return true end
function modifier_imba_aether_lens_passive:IsPurgable() 		return false end
function modifier_imba_aether_lens_passive:IsPurgeException() 	return false end
function modifier_imba_aether_lens_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_aether_lens_passive:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_CAST_RANGE_BONUS, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end 
function modifier_imba_aether_lens_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_imba_aether_lens_passive:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_imba_aether_lens_passive:GetModifierCastRangeBonus() return self:GetAbility():GetSpecialValueFor("cast_range_bonus") end
function modifier_imba_aether_lens_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end