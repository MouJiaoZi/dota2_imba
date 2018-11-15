
item_imba_greater_crit = class({})

LinkLuaModifier("modifier_imba_greater_crit_passive", "items/item_crit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_greater_crit_increase_dummy", "items/item_crit", LUA_MODIFIER_MOTION_NONE)

function item_imba_greater_crit:GetIntrinsicModifierName() return "modifier_imba_greater_crit_passive" end

modifier_imba_greater_crit_passive = class({})

function modifier_imba_greater_crit_passive:IsDebuff()			return false end
function modifier_imba_greater_crit_passive:IsHidden() 			return true end
function modifier_imba_greater_crit_passive:IsPurgable() 		return false end
function modifier_imba_greater_crit_passive:IsPurgeException() 	return false end
function modifier_imba_greater_crit_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_greater_crit_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_START} end
function modifier_imba_greater_crit_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_greater_crit_passive:GetIMBAPhysicalCirtChance() return self.cirt end
function modifier_imba_greater_crit_passive:GetIMBAPhysicalCirtBonus() return (self:GetAbility():GetSpecialValueFor("base_crit_tooltip") + self:GetParent():GetModifierStackCount("modifier_item_imba_greater_crit_increase_dummy", nil)) end

function modifier_imba_greater_crit_passive:OnTriggerIMBAPhyicalCirt(keys)
	self:GetParent():RemoveModifierByName("modifier_item_imba_greater_crit_increase_dummy")
	self:GetParent():EmitSound("DOTA_Item.Daedelus.Crit")
end

function modifier_imba_greater_crit_passive:OnNotTriggerIMBAPhyicalCirt(target)
	if self:GetParent():IsIllusion() or not self:GetParent().splitattack then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_imba_greater_crit_increase_dummy", {})
	buff:SetStackCount(math.min((buff:GetStackCount() + self:GetAbility():GetSpecialValueFor("crit_increase")), (100 - self:GetAbility():GetSpecialValueFor("crit_chance"))))
end

function modifier_imba_greater_crit_passive:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():IsRangedAttacker() then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetParent():GetModifierStackCount("modifier_item_imba_greater_crit_increase_dummy", nil)) then
			self.cirt = 100
			self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed())
		else
			self.cirt = 0
		end
	end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and self:GetParent():IsRangedAttacker() then
		self.cirt = (self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetParent():GetModifierStackCount("modifier_item_imba_greater_crit_increase_dummy", nil))
	end
end

function modifier_imba_greater_crit_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_greater_crit_passive") then
		self:GetParent():RemoveModifierByName("modifier_item_imba_greater_crit_increase_dummy")
	end
end

modifier_item_imba_greater_crit_increase_dummy = class({})

function modifier_item_imba_greater_crit_increase_dummy:IsDebuff()			return false end
function modifier_item_imba_greater_crit_increase_dummy:IsHidden() 			return false end
function modifier_item_imba_greater_crit_increase_dummy:IsPurgable() 		return false end
function modifier_item_imba_greater_crit_increase_dummy:IsPurgeException() 	return false end