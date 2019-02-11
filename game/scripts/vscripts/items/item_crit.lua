
item_imba_greater_crit = class({})

LinkLuaModifier("modifier_imba_greater_crit_passive", "items/item_crit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_greater_crit_check", "items/item_crit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_greater_crit_increase_dummy", "items/item_crit", LUA_MODIFIER_MOTION_NONE)

function item_imba_greater_crit:GetIntrinsicModifierName() return "modifier_imba_greater_crit_passive" end

modifier_imba_greater_crit_check = class({})

function modifier_imba_greater_crit_check:IsHidden()			return true end
function modifier_imba_greater_crit_check:IsDebuff()			return false end
function modifier_imba_greater_crit_check:IsPurgable() 			return false end
function modifier_imba_greater_crit_check:IsPurgeException() 	return false end

modifier_imba_greater_crit_passive = class({})

function modifier_imba_greater_crit_passive:IsDebuff()			return false end
function modifier_imba_greater_crit_passive:IsHidden() 			return true end
function modifier_imba_greater_crit_passive:IsPurgable() 		return false end
function modifier_imba_greater_crit_passive:IsPurgeException() 	return false end
function modifier_imba_greater_crit_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_greater_crit_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_greater_crit_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end

function modifier_imba_greater_crit_passive:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() and keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and self:GetParent().splitattack then
		local pct = self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetParent():GetModifierStackCount("modifier_item_imba_greater_crit_increase_dummy", nil)
		local dmg = self:GetAbility():GetSpecialValueFor("base_crit_tooltip") + self:GetParent():GetModifierStackCount("modifier_item_imba_greater_crit_increase_dummy", nil)
		if PseudoRandom:RollPseudoRandom(self:GetAbility(), pct) then
			self:GetParent():EmitSound("DOTA_Item.Daedelus.Crit")
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_greater_crit_check", {})
			self:GetParent():RemoveModifierByName("modifier_item_imba_greater_crit_increase_dummy")
			return dmg
		else
			self:GetParent():RemoveModifierByName("modifier_imba_greater_crit_check")
			return 0
		end
	end
end

function modifier_imba_greater_crit_passive:OnAttackLanded(keys)
	local parent = self:GetParent()
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsOther() or keys.target:IsBuilding() or not keys.target:IsAlive() then
		return
	end
	if not parent:HasModifier("modifier_imba_greater_crit_check") and parent.splitattack then
		parent:AddModifierStacks(parent, self:GetAbility(), "modifier_item_imba_greater_crit_increase_dummy", {}, self:GetAbility():GetSpecialValueFor("crit_increase"), false, true)
	end
	Timers:CreateTimer(FrameTime(), function()
			if not parent:IsNull() then
				parent:RemoveModifierByName("modifier_imba_greater_crit_check")
			end
			return nil
		end
	)
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