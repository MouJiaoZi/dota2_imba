
function modifier_special_bonus_imba_chaos_knight_1:OnCreated()
	if IsServer() then
		local abilty = self:GetParent():FindAbilityByName("chaos_knight_phantasm")
		if abilty then
			cd = abilty:GetCooldown(2)
			AbilityChargeController:AbilityChargeInitialize(abilty, cd, self:GetParent():GetTalentValue("special_bonus_imba_chaos_knight_1"), 1, true, true)
		end
	end
end

function modifier_special_bonus_imba_chaos_knight_2:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.3)
	end
end

function modifier_special_bonus_imba_chaos_knight_2:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end

function modifier_special_bonus_imba_chaos_knight_2:GetModifierPreAttack_BonusDamage()
	if IsServer() then
		if self:GetParent():IsIllusion() then
			return 0
		else
			return self:GetStackCount()
		end
	end
	return self:GetStackCount()
end

function modifier_special_bonus_imba_chaos_knight_2:OnIntervalThink()
	self:SetStackCount(math.random(self:GetParent():GetTalentValue("special_bonus_imba_chaos_knight_2", "min"), self:GetParent():GetTalentValue("special_bonus_imba_chaos_knight_2", "max")))
end