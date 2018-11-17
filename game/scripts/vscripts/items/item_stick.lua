



item_imba_magic_stick = class({})

LinkLuaModifier("modifier_magic_stick_unique", "items/item_stick", LUA_MODIFIER_MOTION_NONE)

function item_imba_magic_stick:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("charge_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_magic_stick:GetIntrinsicModifierName() return "modifier_magic_stick_unique" end

function item_imba_magic_stick:OnSpellStart()
	local charges = self:GetCurrentCharges()
	local caster = self:GetCaster()
	if charges > 0 then
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/magic_stick.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(pfx)
		caster:Heal(charges * self:GetSpecialValueFor("restore_per_charge"), self)
		caster:GiveMana(charges * self:GetSpecialValueFor("restore_per_charge"))
		caster:EmitSound("DOTA_Item.MagicStick.Activate")
		self:SetCurrentCharges(0)
	end
end

modifier_magic_stick_unique = class({})

function modifier_magic_stick_unique:IsDebuff()			return false end
function modifier_magic_stick_unique:IsHidden() 		return true end
function modifier_magic_stick_unique:IsPurgable() 		return false end
function modifier_magic_stick_unique:IsPurgeException() return false end
function modifier_magic_stick_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_magic_stick_unique:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if IsEnemy(keys.unit, self:GetParent()) and self:GetParent():CanEntityBeSeenByMyTeam(keys.unit) and CalcDistanceBetweenEntityOBB(keys.unit, self:GetParent()) <= self:GetAbility():GetSpecialValueFor("charge_radius") and not keys.ability:IsItem() then
		self:GetAbility():SetCurrentCharges(math.min(self:GetAbility():GetCurrentCharges() +1, self:GetAbility():GetSpecialValueFor("max_charges")))
	end
end

item_imba_magic_wand = class({})

LinkLuaModifier("modifier_magic_wand_passive", "items/item_stick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magic_wand_unique", "items/item_stick", LUA_MODIFIER_MOTION_NONE)

function item_imba_magic_wand:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("charge_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_magic_wand:GetIntrinsicModifierName() return "modifier_magic_wand_passive" end

function item_imba_magic_wand:OnSpellStart()
	local charges = self:GetCurrentCharges()
	local caster = self:GetCaster()
	print(caster:GetAbsOrigin())
	if charges > 0 then
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/magic_stick.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:ReleaseParticleIndex(pfx)
		caster:Heal(charges * self:GetSpecialValueFor("restore_per_charge"), self)
		caster:GiveMana(charges * self:GetSpecialValueFor("restore_per_charge"))
		caster:EmitSound("DOTA_Item.MagicStick.Activate")
		self:SetCurrentCharges(0)
	end
end

modifier_magic_wand_passive = class({})

function modifier_magic_wand_passive:IsDebuff()			return false end
function modifier_magic_wand_passive:IsHidden() 		return true end
function modifier_magic_wand_passive:IsPurgable() 		return false end
function modifier_magic_wand_passive:IsPurgeException() return false end
function modifier_magic_wand_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_magic_wand_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_magic_wand_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_magic_wand_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_magic_wand_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end

function modifier_magic_wand_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_magic_wand_unique", {})
	end
end

function modifier_magic_wand_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_magic_wand_passive") then
		self:GetParent():RemoveModifierByName("modifier_magic_wand_unique")
	end
	if IsServer() and self:GetParent():FindModifierByName("modifier_magic_wand_passive") then
		self:GetParent():FindModifierByName("modifier_magic_wand_passive"):ForceRefresh()
	end
end

modifier_magic_wand_unique = class({})

function modifier_magic_wand_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_magic_wand_unique:OnDestroy() self.ability = nil end
function modifier_magic_wand_unique:IsDebuff()			return false end
function modifier_magic_wand_unique:IsHidden() 			return true end
function modifier_magic_wand_unique:IsPurgable() 		return false end
function modifier_magic_wand_unique:IsPurgeException() 	return false end
function modifier_magic_wand_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_magic_wand_unique:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if IsEnemy(keys.unit, self:GetParent()) and self:GetParent():CanEntityBeSeenByMyTeam(keys.unit) and CalcDistanceBetweenEntityOBB(keys.unit, self:GetParent()) <= self.ability:GetSpecialValueFor("charge_radius") and not keys.ability:IsItem() then
		self.ability:SetCurrentCharges(math.min(self.ability:GetCurrentCharges() +1, self.ability:GetSpecialValueFor("max_charges")))
	end
end