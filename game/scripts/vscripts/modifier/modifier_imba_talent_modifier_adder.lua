modifier_imba_talent_modifier_adder = class({})

function modifier_imba_talent_modifier_adder:IsDebuff()				return false end
function modifier_imba_talent_modifier_adder:IsHidden() 			return true end
function modifier_imba_talent_modifier_adder:IsPurgable() 			return false end
function modifier_imba_talent_modifier_adder:IsPurgeException() 	return false end
function modifier_imba_talent_modifier_adder:DestroyOnExpire() return self:GetParent():IsIllusion() end
function modifier_imba_talent_modifier_adder:RemoveOnDeath()
	if self:GetParent():IsIllusion() or self:GetParent():IsTempestDouble() then
		return true
	else
		return false
	end
end
function modifier_imba_talent_modifier_adder:AllowIllusionDuplicate() return true end

function modifier_imba_talent_modifier_adder:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_talent_modifier_adder:OnIntervalThink()
	if self:GetRemainingTime() < 0.03 then
		self:SetDuration(-1, true)
	end
	for i=0,23 do
		local ability = self:GetParent():GetAbilityByIndex(i)
		if ability and ability:GetLevel() > 0 then
			if string.find(ability:GetName(), "special_bonus_imba_") then
				self:GetParent():AddNewModifier(self:GetParent(), ability, "modifier_"..ability:GetName(), {})
			end
		end
	end
	self:SetStackCount(self:GetParent():GetCastRangeBonus())
end
