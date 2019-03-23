

item_imba_moon_shard = class({})

LinkLuaModifier("modifier_imba_moon_shard_slot", "items/item_moon_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_moon_shard_consume", "items/item_moon_shard", LUA_MODIFIER_MOTION_NONE)

function item_imba_moon_shard:GetIntrinsicModifierName() return "modifier_imba_moon_shard_slot" end

function item_imba_moon_shard:CastFilterResultTarget(target)
	if not target:IsRealHero() or IsEnemy(self:GetCaster(), target) then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function item_imba_moon_shard:GetCustomCastErrorTarget(target) return "dota_hud_error_cant_cast_on_other" end

function item_imba_moon_shard:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local total = self:GetCurrentCharges()
	if target and target == caster then
		EmitSoundOnClient("Item.MoonShard.Consume", caster:GetPlayerOwner())
		local buff = caster:AddNewModifier(caster, self, "modifier_imba_moon_shard_consume", {})
		buff:SetStackCount(buff:GetStackCount() + total)
		caster:RemoveItem(self)
		return
	elseif target then
		EmitSoundOnClient("Item.MoonShard.Consume", caster:GetPlayerOwner())
		EmitSoundOnClient("Item.MoonShard.Consume", target:GetPlayerOwner())
		local buff = target:AddNewModifier(caster, self, "modifier_imba_moon_shard_consume", {})
		buff:SetStackCount(buff:GetStackCount() + 1)
	else
		caster:EmitSound("Item.DropWorld")
		local moon = CreateItem("item_imba_moon_shard", caster, caster)
		CreateItemOnPositionSync(caster:GetAbsOrigin(), moon)
		moon:SetPurchaser(caster)
		moon:SetPurchaseTime(self:GetPurchaseTime())
	end
	self:SetCurrentCharges(self:GetCurrentCharges() - 1)
	if self:GetCurrentCharges() < 1 then
		caster:RemoveItem(self)
	end
end

modifier_imba_moon_shard_slot = class({})

function modifier_imba_moon_shard_slot:IsDebuff()			return false end
function modifier_imba_moon_shard_slot:IsHidden() 			return false end
function modifier_imba_moon_shard_slot:IsPurgable() 		return false end
function modifier_imba_moon_shard_slot:IsPurgeException() 	return false end
function modifier_imba_moon_shard_slot:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BONUS_NIGHT_VISION} end
function modifier_imba_moon_shard_slot:GetModifierAttackSpeedBonus_Constant() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_attack_speed")) end
function modifier_imba_moon_shard_slot:GetBonusNightVision() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_night_vision")) end

function modifier_imba_moon_shard_slot:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_moon_shard_slot:OnIntervalThink()
	local items = self:GetAbility():GetCurrentCharges()
	local stack = 0
	for i=0, 5 do
		local item = self:GetParent():GetItemInSlot(i)
		if (item and item == self:GetAbility()) or not item then
			stack = stack + 1
		end
	end
	self:SetStackCount(math.min(items, stack))
end

modifier_imba_moon_shard_consume = class({})

function modifier_imba_moon_shard_consume:IsDebuff()			return false end
function modifier_imba_moon_shard_consume:IsHidden() 			return false end
function modifier_imba_moon_shard_consume:IsPurgable() 			return false end
function modifier_imba_moon_shard_consume:IsPurgeException() 	return false end
function modifier_imba_moon_shard_consume:GetTexture() return "imba_moon_shard" end
function modifier_imba_moon_shard_consume:RemoveOnDeath() return self:GetParent():IsIllusion() end

CONSUME_AS_1 = 70
CONSUME_AS_2 = 50
CONSUME_AS_3 = 30
CONSUME_NV_1 = 250
CONSUME_NV_2 = 150

function modifier_imba_moon_shard_consume:OnCreated()
	if self:GetParent():IsIllusion() then
		UTIL_Remove(self)
	end
	self.as_1 = CONSUME_AS_1
	self.as_2 = CONSUME_AS_2
	self.as = CONSUME_AS_3
	self.nv_1 = CONSUME_NV_1
	self.nv_2 = CONSUME_NV_2
end

function modifier_imba_moon_shard_consume:OnDestroy()
	self.as_1 = nil
	self.as_2 = nil
	self.as = nil
	self.nv_1 = nil
	self.nv_2 = nil
end

function modifier_imba_moon_shard_consume:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BONUS_NIGHT_VISION} end
function modifier_imba_moon_shard_consume:GetModifierAttackSpeedBonus_Constant()
	local stack = self:GetStackCount()
	local as = 0
	if stack == 1 then
		as = self.as_1
	elseif stack == 2 then
		as = self.as_1 + self.as_2
	else
		as = self.as_1 + self.as_2 + math.max(stack - 2, 0) * self.as
	end
	return as
end
function modifier_imba_moon_shard_consume:GetBonusNightVision()
	local stack = self:GetStackCount()
	local nv = 0
	if stack == 1 then
		nv = self.nv_1
	elseif stack >= 2 then
		nv = self.nv_1 + self.nv_2
	end
	return nv
end