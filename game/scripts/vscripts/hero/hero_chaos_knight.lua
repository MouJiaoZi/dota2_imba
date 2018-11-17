
function modifier_special_bonus_imba_chaos_knight_1:OnCreated()
	if IsServer() then
		local abilty = self:GetParent():FindAbilityByName("chaos_knight_phantasm")
		if abilty then
			cd = abilty:GetCooldown(2)
			AbilityChargeController:AbilityChargeInitialize(abilty, cd, self:GetParent():GetTalentValue("special_bonus_imba_chaos_knight_1"), 1, true, true)
		end
	end
end