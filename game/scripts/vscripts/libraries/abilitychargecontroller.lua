--[[
		Author: MouJiaoZi
		Email: moujiaozi@gmail.com / ww64646464@vip.qq.com

	usage:
		To set an ability as charge-type:
			AbilityChargeController:AbilityChargeInitialize(hAbility, fChargeTime, iMaxCharges, iChargeCost, bResetByRefresh, bCDR)
			hAbility: the ability you want to set
			fChargeTime: the cooldown of charge
			iMaxCharges: the maximum charge points
			iChargeCost(optional): the cost of the ability, eg set it to 2 will cost 2 point when trigger cost
			bResetByRefresh(optional): should we set the ability to full points when use refresher or tinker's rearm
			bCDR(optional): if this charge can reduce the charge time by CoolDown Reduction

		To trigger the ability's cost:
			bool AbilityChargeController:CostCharge(hAbility, iCost, bIncreaseType)
			hAbility: the ability you want to trigger the cost
			iCost(optional): how many cost do you want to spend? default is the iChargeCost set by AbilityChargeInitialize function
							this can be a negative number, to increase the charge point
			bIncreaseType(optional x 2): if you set iCost a negative number, this will determin how we increase the charges
										if it's true, then we will remove the cooldown buffs which is the longest duration
										if it's false, we will remove that shortest buffs
			**IMPORTANT**
			this function will return a bool to let you know if it runs successfully, if it returns false, that means no hAbility recieved or no enough charge to cost, if it returns true, all work fine!
			you needn't to get this bool studiously, when there is no charge, the ability will go into cooldown automatically
			**IMPORTANT**

		To change the setting of a charge-type ability:
			AbilityChargeController:ChangeChargeAbilityConfig(hAbility, fChargeTime, iMaxCharges, iChargeCost, bResetByRefresh, bCDR)
			same as AbilityChargeInitialize function, but only hAbility is necessary, others are all optional
			if set one, it will overwrite previous setting

		API:
			bool AbilityChargeController:IsChargeTypeAbility(hAbility) : is this ability a charge-type ability?

			handle AbilityChargeController:GetChargeModifier(hAbility) : Get an ability's charge controller modifier, the abiliy must be a charge-type ability firstly
				in this way you can get this charge-type ability's setting, all are in below:
				handle buff.ability
				handle buff.caster
				float buff.chargetime
				int buff.maxcharges
				int buff.chargecost
				bool buff.refresh
				bool buff.getcdr

]]

AbilityChargeController = AbilityChargeController or class({})

LinkLuaModifier("modifier_imba_ability_charge", "libraries/abilitychargecontroller.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ability_charge_cd_dummy", "libraries/abilitychargecontroller.lua", LUA_MODIFIER_MOTION_NONE)

modifier_imba_ability_charge = modifier_imba_ability_charge or class({})
modifier_imba_ability_charge_cd_dummy = modifier_imba_ability_charge_cd_dummy or class({})

function modifier_imba_ability_charge:IsDebuff()		return false end
function modifier_imba_ability_charge:IsHidden() 		return false end
function modifier_imba_ability_charge:IsPurgable() 		return false end
function modifier_imba_ability_charge:IsPurgeException() return false end
function modifier_imba_ability_charge:IsStunDebuff() 	return false end
function modifier_imba_ability_charge:RemoveOnDeath() 	return self:GetParent():IsIllusion() end
function modifier_imba_ability_charge:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_ability_charge:DestroyOnExpire()	return false end

function modifier_imba_ability_charge:OnCreated(keys)
	if not IsServer() then
		return
	end
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.chargetime = keys.chargetime
	self.maxcharges = keys.maxcharges
	self.chargecost = keys.chargecost
	if keys.refresh == 1 then
		self.refresh = true
	else
		self.refresh = false
	end
	if keys.getcdr == 1 then
		self.getcdr = true
	else
		self.getcdr = false
	end
	self:SetStackCount(self.maxcharges)
	self:StartIntervalThink(0.1)
end

function modifier_imba_ability_charge:OnIntervalThink()
	if self.ability:IsNull() or not self.caster:HasAbility(self.ability:GetAbilityName()) then
		self:Destroy()
	end
	local duration = self.chargetime
	if self.getcdr then
		duration = duration * self.caster:GetCooldownReduction()
	end
	if self:GetStackCount() > self.maxcharges or (self:GetStackCount() == self.maxcharges - 1 and self:GetRemainingTime() <= 0) then
		self:SetStackCount(self.maxcharges)
	end
	if self:GetStackCount() < self.maxcharges - 1 and self:GetDuration() < 0 then
		self:SetStackCount(self:GetStackCount() + 1)
		self:SetDuration(duration, true)
	end
	if self:GetRemainingTime() <= 0 or self:GetStackCount() >= self.maxcharges then
		self:SetDuration(-1, true)
	end
	if self:GetStackCount() <= 0 and self:GetDuration() > 0 and math.abs(self.ability:GetCooldownTimeRemaining() - self:GetRemainingTime()) > 0.3 then
		self.ability:EndCooldown()
		self.ability:StartCooldown(self:GetRemainingTime() + 0.2)
	end
	if self:GetStackCount() > 0 then
		self.ability:EndCooldown()
	end
end

function modifier_imba_ability_charge:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}

	return funcs
end

function modifier_imba_ability_charge:OnAbilityFullyCast( keys )
	if not IsServer() then
		return
	end
	if keys.unit == self.caster and string.find(keys.ability:GetAbilityName(), "refresh") then
		if self.refresh then
			self:SetStackCount(self.maxcharges)
			self:SetDuration(-1, true)
		end
	end
	if keys.ability == self.ability then
		local duration = self.chargetime
		print(duration)
		if self.getcdr then
			duration = duration * self.caster:GetCooldownReduction()
		end
		if self:GetDuration() == -1 then
			self:SetDuration(duration, true)
		end
		self:DecrementStackCount()
	end
end

function modifier_imba_ability_charge_cd_dummy:IsDebuff()		return false end
function modifier_imba_ability_charge_cd_dummy:IsHidden() 		return false end
function modifier_imba_ability_charge_cd_dummy:IsPurgable() 	return false end
function modifier_imba_ability_charge_cd_dummy:IsPurgeException() return false end
function modifier_imba_ability_charge_cd_dummy:IsStunDebuff() 	return false end
function modifier_imba_ability_charge_cd_dummy:RemoveOnDeath() 	return false end
function modifier_imba_ability_charge_cd_dummy:GetAttributes() 	return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_ability_charge_cd_dummy:OnCreated()
	self.ability = self:GetAbility()
end

function modifier_imba_ability_charge_cd_dummy:OnDestroy()
	if not IsServer() then
		return
	end
	self.chargebuff:SetDuration(-1, true)
end

function AbilityChargeController:AbilityChargeInitialize(hAbility, fChargeTime, iMaxCharges, iChargeCost, bResetByRefresh, bCDR)
	Timers:CreateTimer((hAbility:GetLevel() * 0.2), function()
			if not hAbility or not fChargeTime or not iMaxCharges then
				print("parameter error! please check your code!!")
				return
			end
			if iChargeCost < 0 or iMaxCharges <= 0 or fChargeTime <= 0 then
				print("Number error, what are you doing?")
				return
			end
			local caster = hAbility:GetCaster()
			local bRefresh = 1
			local bGetCDR = 0
			if not bResetByRefresh or bResetByRefresh == true then
				bRefresh = 1
			else
				bRefresh = 0
			end
			if not bCDR or bCDR == false then
				bGetCDR = 0
			else
				bGetCDR = 1
			end
			if AbilityChargeController:IsChargeTypeAbility(hAbility) then
				AbilityChargeController:ChangeChargeAbilityConfig(hAbility, fChargeTime, iMaxCharges, iChargeCost, bResetByRefresh, bCDR)
				print("Already has charge buff!!")
			else
				caster:AddNewModifierWhenPossible(caster, hAbility, "modifier_imba_ability_charge", {chargetime = fChargeTime, maxcharges = iMaxCharges, chargecost = iChargeCost, refresh = bRefresh, getcdr = bGetCDR})
			end
			return nil
		end
	)
end

function AbilityChargeController:ChangeChargeAbilityConfig(hAbility, fChargeTime, iMaxCharges, iChargeCost, bResetByRefresh, bCDR)
	if not hAbility then return end
	if not AbilityChargeController:IsChargeTypeAbility(hAbility) then
		print("Not a charge type ability!")
		return
	end
	local buff = AbilityChargeController:GetChargeModifier(hAbility)

	buff.chargetime = fChargeTime or buff.chargetime 
	buff.maxcharges = iMaxCharges or buff.maxcharges 
	buff.chargecost = iChargeCost or buff.chargecost 
	buff.refresh = bResetByRefresh or buff.refresh 
	buff.getcdr = bCDR or buff.getcdr
end

function AbilityChargeController:CostCharge(hAbility, iCost, bIncreaseType)  --bIncreaseType: true is destroy the longest duration buff, false is shortest, default is shortest.
	if not hAbility then
		return false
	end
	local ability = hAbility
	local caster = ability:GetCaster()
	local control_buffs = caster:FindAllModifiersByName("modifier_imba_ability_charge")
	local control_buff = nil
	for _, buff in pairs(control_buffs) do
		if buff.ability == ability then
			control_buff = buff
			break
		end
	end
	if not control_buff then
		print("No charge buff found! Does this ability have any charge?")
		return false
	end
	local cost = iCost or control_buff.chargecost
	local charge_time = control_buff.chargetime
	local current_charge = control_buff:GetStackCount()
	if cost >= 0 then
		if control_buff.getcdr then
			local cdr_pct = caster:GetCooldownReduction()
			charge_time = charge_time * (1 - cdr_pct)
		end
		if current_charge >= cost then
			for i=1,cost do
				local cdbuff = caster:AddNewModifier(caster, ability, "modifier_imba_ability_charge_cd_dummy", {duration = charge_time + ((control_buff.maxcharges - control_buff:GetStackCount()) * charge_time)})
				cdbuff.chargebuff = control_buff
			end
		else
			return false
		end
	else -- cost<0
		local incre = bIncreaseType or false
		cost = 0 - cost
		local cd_buff = {}
		local buffs = caster:FindAllModifiersByName("modifier_imba_ability_charge_cd_dummy")
		for _, buff in pairs(buffs) do
			if buff:GetAbility() == control_buff.ability then
				table.insert(cd_buff, buff)
			end
		end
		if control_buff.maxcharges - control_buff:GetStackCount() < cost then
			for _,buff in pairs(cd_buff) do
				buff:Destroy()
			end
		else
			if incre then
				for j=1,cost do
					local pin = 0
					local longest = nil
					local longesttime = 0
					for k=1, #cd_buff do
						if cd_buff[k]:GetRemainingTime() > longesttime then
							longesttime = cd_buff[k]:GetRemainingTime()
							longest = cd_buff[k]
							pin = k
						end
					end
					longest:Destroy()
					table.remove(cd_buff, pin)
				end
			else
				for j=1,cost do
					local pin = 0
					local shortest = nil
					local shortesttime = 99999
					for k=1, #cd_buff do
						if cd_buff[k]:GetRemainingTime() < shortesttime then
							shortesttime = cd_buff[k]:GetRemainingTime()
							shortest = cd_buff[k]
							pin = k
						end
					end
					shortest:Destroy()
					table.remove(cd_buff, pin)
				end
			end
		end
	end
	return true
end

function AbilityChargeController:IsChargeTypeAbility(hAbility)
	if not hAbility then return end
	local ability = hAbility
	local caster = ability:GetCaster()
	local control_buffs = caster:FindAllModifiersByName("modifier_imba_ability_charge")
	for _, buff in pairs(control_buffs) do
		if buff:GetAbility() == ability then
			return buff
		end
	end
	return false
end

function AbilityChargeController:GetChargeModifier(hAbility)
	if not hAbility then
		return
	end
	if not AbilityChargeController:IsChargeTypeAbility(hAbility) then return nil end
	local ability = hAbility
	local caster = ability:GetCaster()
	local control_buffs = caster:FindAllModifiersByName("modifier_imba_ability_charge")
	local control_buff = nil
	for _, buff in pairs(control_buffs) do
		if buff.ability == ability then
			control_buff = buff
			return control_buff
		end
	end
	return nil
end
