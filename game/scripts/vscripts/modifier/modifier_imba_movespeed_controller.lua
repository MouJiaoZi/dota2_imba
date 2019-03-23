modifier_imba_movespeed_controller = class({})

function modifier_imba_movespeed_controller:IsDebuff()			return false end
function modifier_imba_movespeed_controller:IsHidden() 			return true end
function modifier_imba_movespeed_controller:IsPurgable() 		return false end
function modifier_imba_movespeed_controller:IsPurgeException()	return false end
function modifier_imba_movespeed_controller:RemoveOnDeath()		return self:GetParent():IsIllusion() end
function modifier_imba_movespeed_controller:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT} end
function modifier_imba_movespeed_controller:GetModifierIgnoreMovespeedLimit() return 1 end
function modifier_imba_movespeed_controller:GetModifierMoveSpeed_AbsoluteMin() return self:GetStackCount() end

function modifier_imba_movespeed_controller:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_movespeed_controller:OnIntervalThink()
	local caster = self:GetParent()
	if caster:HasModifier("modifier_death_prophet_exorcism") and caster:HasTalent("special_bonus_unique_death_prophet_4") then
		self:SetStackCount(550)
		return
	end
	if caster:IsHexed() then
		self:SetStackCount(100)
		return
	end
	local buffs = caster:FindAllModifiers()
	local ms = 0
	local found = false
	for i=1, #buffs do
		if buffs[i].GetIMBAMaxMovespeed and buffs[i]:GetIMBAMaxMovespeed() then
			if buffs[i]:GetIMBAMaxMovespeed() > ms then
				ms = buffs[i]:GetIMBAMaxMovespeed()
				found = true
			end
		end
	end
	if found then
		self:SetStackCount(math.min(ms, (caster:GetBaseMoveSpeed() + caster:GetMoveSpeedIncrease())))
		return
	end
	self:SetStackCount(100)
end