
item_imba_echo_sabre = class({})
item_imba_reverb_rapier = class({})

function item_imba_echo_sabre:GetIntrinsicModifierName() return "modifier_imba_echo_sabre_passive" end
function item_imba_reverb_rapier:GetIntrinsicModifierName() return "modifier_imba_echo_sabre_passive" end

LinkLuaModifier("modifier_item_imba_echo_sabre_slow", "items/item_echo_sabre", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_imba_echo_sabre_passive", "items/item_echo_sabre", LUA_MODIFIER_MOTION_NONE)

modifier_imba_echo_sabre_passive = class({})

function modifier_imba_echo_sabre_passive:IsDebuff()			return false end
function modifier_imba_echo_sabre_passive:IsHidden() 			return true end
function modifier_imba_echo_sabre_passive:IsPurgable() 			return false end
function modifier_imba_echo_sabre_passive:IsPurgeException() 	return false end
function modifier_imba_echo_sabre_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_echo_sabre_passive:GetPriority()	return MODIFIER_PRIORITY_LOW end
function modifier_imba_echo_sabre_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_EVENT_ON_ATTACK} end
function modifier_imba_echo_sabre_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_imba_echo_sabre_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_echo_sabre_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_imba_echo_sabre_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_imba_echo_sabre_passive:GetModifierAttackSpeedBonus_Constant()
	if IsServer() and self:GetStackCount() > 0 then
		return (self:GetAbility():GetSpecialValueFor("bonus_attack_speed") + 10000)
	else
		return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	end
end
function modifier_imba_echo_sabre_passive:GetModifierBaseAttackTimeConstant()
	if IsServer() and self:GetStackCount() > 0 then
		return (1.0)
	else
		return nil
	end
end

function modifier_imba_echo_sabre_passive:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_echo_sabre_passive:OnIntervalThink()
	local hit = self:GetAbility():GetSpecialValueFor("max_hits")
	if self:GetParent():IsRangedAttacker() then
		hit = hit - 1
	end
	if self:GetAbility():IsCooldownReady() and self:GetStackCount() < hit then
		self:SetStackCount(hit)
	end
end

function modifier_imba_echo_sabre_passive:OnAttack(keys)
	if IsServer() and self:GetParent() == keys.attacker then
		if self:GetStackCount() > 0 then
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_echo_sabre_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
		end
		self:DecrementStackCount()
		if self:GetStackCount() ~= self:GetAbility():GetSpecialValueFor("max_hits") and self:GetAbility():IsCooldownReady() then
			if self:GetParent():IsRangedAttacker() then
				self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("ranged_cooldown") * (1 - self:GetParent():GetCooldownReduction() / 100))
			else
				self:GetAbility():UseResources(true, true, true)
			end
		end
	end
end

modifier_item_imba_echo_sabre_slow = class({})

function modifier_item_imba_echo_sabre_slow:IsDebuff()			return true end
function modifier_item_imba_echo_sabre_slow:IsHidden() 			return false end
function modifier_item_imba_echo_sabre_slow:IsPurgable() 		return false end
function modifier_item_imba_echo_sabre_slow:IsPurgeException() 	return false end
function modifier_item_imba_echo_sabre_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_echo_sabre_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("movement_slow")) end
function modifier_item_imba_echo_sabre_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attack_speed_slow")) end