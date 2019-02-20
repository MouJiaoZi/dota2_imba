modifier_imba_ability_layout_contoroller = class({})

function modifier_imba_ability_layout_contoroller:IsDebuff()			return false end
function modifier_imba_ability_layout_contoroller:IsHidden() 			return true end
function modifier_imba_ability_layout_contoroller:IsPurgable() 			return false end
function modifier_imba_ability_layout_contoroller:IsPurgeException()	return false end
function modifier_imba_ability_layout_contoroller:RemoveOnDeath()		return self:GetParent():IsIllusion() end
function modifier_imba_ability_layout_contoroller:DeclareFunctions() 	return {MODIFIER_PROPERTY_ABILITY_LAYOUT} end
function modifier_imba_ability_layout_contoroller:GetModifierAbilityLayout() return self:GetStackCount() end

function modifier_imba_ability_layout_contoroller:OnCreated()
	if IsServer() then
		self:StartIntervalThink(5.0)
	end
end

function modifier_imba_ability_layout_contoroller:OnIntervalThink()
	local n = 0
	for i=0, 23 do
		local ability = self:GetParent():GetAbilityByIndex(i)
		if ability and not ability:IsHidden() and not string.find(ability:GetAbilityName(), "special_bonus_") then
			n = n + 1
		end
	end
	self:SetStackCount(n)
end