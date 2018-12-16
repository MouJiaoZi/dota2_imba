


item_imba_sheepstick = class({})

LinkLuaModifier("modifier_imba_sheepstick_passive", "items/item_sheepstick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_sheepstick_debuff", "items/item_sheepstick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_sheepstick_prevent", "items/item_sheepstick", LUA_MODIFIER_MOTION_NONE)

function item_imba_sheepstick:GetIntrinsicModifierName() return "modifier_imba_sheepstick_passive" end

function item_imba_sheepstick:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) or target:IsMagicImmune() then
		return
	end
	target:EmitSound("DOTA_Item.Sheepstick.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items_fx/item_sheepstick.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(pfx)
	if target:IsIllusion() then
		target:Kill(self, caster)
		return
	end
	local stacks = target:GetModifierStackCount("modifier_item_imba_sheepstick_prevent", nil)
	local duration = self:GetSpecialValueFor("sheep_duration")
	if stacks >= 1 then
		duration = self:GetSpecialValueFor("sheep_duration") / (2 * stacks)
	end
	target:AddNewModifier(caster, self, "modifier_imba_sheepstick_debuff", {duration = duration})
	local buff = target:AddNewModifier(caster, self, "modifier_item_imba_sheepstick_prevent", {duration = duration + self:GetSpecialValueFor("sheep_duration")})
	buff:SetStackCount(buff:GetStackCount() + 1)
	if target:IsIllusion() then
		target:Kill(self, caster)
	end
end

modifier_imba_sheepstick_passive = class({})

function modifier_imba_sheepstick_passive:IsDebuff()			return false end
function modifier_imba_sheepstick_passive:IsHidden() 			return true end
function modifier_imba_sheepstick_passive:IsPurgable() 			return false end
function modifier_imba_sheepstick_passive:IsPurgeException() 	return false end
function modifier_imba_sheepstick_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_sheepstick_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_imba_sheepstick_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_imba_sheepstick_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_sheepstick_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_imba_sheepstick_passive:GetModifierConstantManaRegenUnique() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

modifier_imba_sheepstick_debuff = class({})

function modifier_imba_sheepstick_debuff:IsDebuff()			return true end
function modifier_imba_sheepstick_debuff:IsHidden() 			return false end
function modifier_imba_sheepstick_debuff:IsPurgable() 		return false end
function modifier_imba_sheepstick_debuff:IsPurgeException() 	return false end
function modifier_imba_sheepstick_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_imba_sheepstick_debuff:CheckState() return {[MODIFIER_STATE_HEXED] = true, [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_EVADE_DISABLED]= true, [MODIFIER_STATE_BLOCK_DISABLED] = true, [MODIFIER_STATE_DISARMED] = true} end
function modifier_imba_sheepstick_debuff:GetModifierModelChange() return "models/props_gameplay/pig.vmdl" end
function modifier_imba_sheepstick_debuff:GetModifierMoveSpeedBonus_Constant() return -50000 end
function modifier_imba_sheepstick_debuff:GetModifierMagicalResistanceBonus() return self.mr end
function modifier_imba_sheepstick_debuff:GetModifierPhysicalArmorBonus() return self.ar end

function modifier_imba_sheepstick_debuff:OnCreated()
	self.ar = 0 - math.min(self:GetAbility():GetSpecialValueFor("armor_reduction"), self:GetParent():GetPhysicalArmorValue())
	self.mr = 0 - self:GetParent():GetMagicalArmorValue() * 100
end

function modifier_imba_sheepstick_debuff:OnDestroy()
	self.model = nil
	self.ar = nil
	self.mr = nil
end

modifier_item_imba_sheepstick_prevent = class({})

function modifier_item_imba_sheepstick_prevent:IsDebuff()			return true end
function modifier_item_imba_sheepstick_prevent:IsHidden() 			return false end
function modifier_item_imba_sheepstick_prevent:IsPurgable() 		return false end
function modifier_item_imba_sheepstick_prevent:IsPurgeException() 	return false end
function modifier_item_imba_sheepstick_prevent:GetTexture() return "custom/imba_sheepstick_recast" end