item_imba_cheese = class({})

LinkLuaModifier("modifier_imba_cheese_auto_cooldown", "items/item_cheese.lua", LUA_MODIFIER_MOTION_NONE)

function item_imba_cheese:OnSpellStart()
	local caster = self:GetCaster()
	local target = caster
	target:EmitSound("DOTA_Item.Cheese.Activate")
	target:Heal(target:GetMaxHealth(), self)
	target:GiveMana(target:GetMaxMana())
	self:SetCurrentCharges(self:GetCurrentCharges() - 1)
	if self:GetCurrentCharges() == 0 then
		caster:RemoveItem(self)
	end
end

modifier_imba_cheese_auto_cooldown = class({})

function modifier_imba_cheese_auto_cooldown:IsDebuff()			return true end
function modifier_imba_cheese_auto_cooldown:IsHidden() 			return false end
function modifier_imba_cheese_auto_cooldown:IsPurgable() 		return false end
function modifier_imba_cheese_auto_cooldown:IsPurgeException() 	return false end
function modifier_imba_cheese_auto_cooldown:RemoveOnDeath() 	return self:GetParent():IsIllusion() end
function modifier_imba_cheese_auto_cooldown:GetTexture()	return "imba_cheese_cooldown" end