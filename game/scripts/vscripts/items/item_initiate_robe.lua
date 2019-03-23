

item_imba_initiate_robe = class({})

LinkLuaModifier("modifier_imba_initiate_robe_passive", "items/item_initiate_robe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_initiate_robe_stacks", "items/item_initiate_robe", LUA_MODIFIER_MOTION_NONE)

function item_imba_initiate_robe:GetIntrinsicModifierName() return "modifier_imba_initiate_robe_passive" end

modifier_imba_initiate_robe_passive = class({})

function modifier_imba_initiate_robe_passive:IsDebuff()			return false end
function modifier_imba_initiate_robe_passive:IsHidden() 		return true end
function modifier_imba_initiate_robe_passive:IsPurgable() 		return false end
function modifier_imba_initiate_robe_passive:IsPurgeException() return false end
function modifier_imba_initiate_robe_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_initiate_robe_passive:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_imba_initiate_robe_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("mana_regen") end
function modifier_imba_initiate_robe_passive:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("magic_resist") end

function modifier_imba_initiate_robe_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_initiate_robe_stacks", {})
	end
end

function modifier_imba_initiate_robe_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_initiate_robe_passive") then
		self:GetParent():RemoveModifierByName("modifier_item_imba_initiate_robe_stacks")
	end
end

modifier_item_imba_initiate_robe_stacks = class({})

function modifier_item_imba_initiate_robe_stacks:IsDebuff()			return false end
function modifier_item_imba_initiate_robe_stacks:IsHidden() 		return false end
function modifier_item_imba_initiate_robe_stacks:IsPurgable() 		return false end
function modifier_item_imba_initiate_robe_stacks:IsPurgeException() return false end
function modifier_item_imba_initiate_robe_stacks:GetTexture() return "imba_initiate_robe" end
function modifier_item_imba_initiate_robe_stacks:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_initiate_robe_stacks:OnDestroy() self.ability = nil end
function modifier_item_imba_initiate_robe_stacks:DeclareFunctions() return {MODIFIER_EVENT_ON_SPENT_MANA, MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK} end

function modifier_item_imba_initiate_robe_stacks:OnSpentMana(keys)
	if IsServer() and keys.unit == self:GetParent() then
		self:SetStackCount(math.min((self:GetStackCount() + keys.cost) * (self.ability:GetSpecialValueFor("mana_conversion_rate") / 100), self.ability:GetSpecialValueFor("max_stacks")))
	end
end

function modifier_item_imba_initiate_robe_stacks:GetModifierTotal_ConstantBlock(keys)
	local stack = self:GetStackCount()
	self:SetStackCount(math.max(0, stack - math.max(0,keys.damage)))
	return stack
end