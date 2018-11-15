

function modifier_special_bonus_imba_dark_seer_1:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_special_bonus_imba_dark_seer_1:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and keys.inflictor and keys.inflictor:GetName() == "dark_seer_vacuum" then
		local ability = self:GetParent():FindAbilityByName("dark_seer_ion_shell")
		if ability then
			self:GetParent():SetCursorCastTarget(keys.unit)
			ability:OnSpellStart()
		end
	end
end