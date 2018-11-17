item_imba_cheese = class({})

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