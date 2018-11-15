


LinkLuaModifier("modifier_imba_diffusal_slow", "items/item_diffusal", LUA_MODIFIER_MOTION_NONE)

modifier_imba_diffusal_slow = class({})

function modifier_imba_diffusal_slow:IsDebuff()			return false end
function modifier_imba_diffusal_slow:IsHidden() 		return true end
function modifier_imba_diffusal_slow:IsPurgable() 		return true end
function modifier_imba_diffusal_slow:IsPurgeException() return true end
function modifier_imba_diffusal_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_diffusal_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - 100 * self:GetRemainingTime() / self:GetDuration()) end
function modifier_imba_diffusal_slow:GetEffectName() return "particles/items_fx/diffusal_slow.vpcf" end
function modifier_imba_diffusal_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

item_imba_diffusal_blade = class({})

LinkLuaModifier("modifier_imba_diffusal_1_passive", "items/item_diffusal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_diffusal_1_unique", "items/item_diffusal", LUA_MODIFIER_MOTION_NONE)

function item_imba_diffusal_blade:GetIntrinsicModifierName() return "modifier_imba_diffusal_1_passive" end

function item_imba_diffusal_blade:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("DOTA_Item.DiffusalBlade.Target")
	target:Purge(true, false, false, false, false)
	target:AddNewModifier(caster, self, "modifier_imba_diffusal_slow", {duration = self:GetSpecialValueFor("tooltip_duration")})
	local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(pfx)
	if target:IsIllusion() or (target:IsCreature() and not target:IsConsideredHero()) then
		target:Kill(self, caster)
	end
end


modifier_imba_diffusal_1_passive = class({})

function modifier_imba_diffusal_1_passive:IsDebuff()			return false end
function modifier_imba_diffusal_1_passive:IsHidden() 			return true end
function modifier_imba_diffusal_1_passive:IsPurgable() 			return false end
function modifier_imba_diffusal_1_passive:IsPurgeException() 	return false end
function modifier_imba_diffusal_1_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_diffusal_1_passive:DeclareFunctions() 	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_diffusal_1_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_imba_diffusal_1_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end

function modifier_imba_diffusal_1_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_diffusal_1_unique", {})
	end
end

function modifier_imba_diffusal_1_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_diffusal_1_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_diffusal_1_unique")
	end
end

modifier_imba_diffusal_1_unique = class({})

function modifier_imba_diffusal_1_unique:IsDebuff()			return false end
function modifier_imba_diffusal_1_unique:IsHidden() 		return true end
function modifier_imba_diffusal_1_unique:IsPurgable() 		return false end
function modifier_imba_diffusal_1_unique:IsPurgeException() return false end
function modifier_imba_diffusal_1_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_diffusal_1_unique:OnCreated()
	self.ability = self:GetAbility()
end

function modifier_imba_diffusal_1_unique:OnDestroy()
	self.ability = nil
end

function modifier_imba_diffusal_1_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsCourier() or keys.target:GetMaxMana() <= 0 or keys.target:IsMagicImmune() or not self:GetParent().splitattack then
		return
	end
	if self:GetParent():HasModifier("modifier_imba_diffusal_2_unique") or self:GetParent():HasModifier("modifier_imba_diffusal_3_unique") then
		return
	end
	local mana_burn = self:GetParent():IsIllusion() and self.ability:GetSpecialValueFor("illusion_mana_burn") or self.ability:GetSpecialValueFor("mana_burn")
	local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:ReleaseParticleIndex(pfx)
	local mana_burn = (keys.target:GetMana() >= mana_burn) and mana_burn or keys.target:GetMana()
	keys.target:SetMana(keys.target:GetMana() - mana_burn)
	ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self.ability, damage_type = DAMAGE_TYPE_PHYSICAL, damage = mana_burn})
end


item_imba_diffusal_blade_2 = class({})

LinkLuaModifier("modifier_imba_diffusal_2_passive", "items/item_diffusal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_diffusal_2_unique", "items/item_diffusal", LUA_MODIFIER_MOTION_NONE)

function item_imba_diffusal_blade_2:GetIntrinsicModifierName() return "modifier_imba_diffusal_2_passive" end

function item_imba_diffusal_blade_2:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("DOTA_Item.DiffusalBlade.Target")
	target:Purge(true, false, false, false, false)
	target:AddNewModifier(caster, self, "modifier_imba_diffusal_slow", {duration = self:GetSpecialValueFor("tooltip_duration")})
	local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(pfx)
	if target:IsIllusion() or (target:IsCreature() and not target:IsConsideredHero()) then
		target:Kill(self, caster)
	end
end


modifier_imba_diffusal_2_passive = class({})

function modifier_imba_diffusal_2_passive:IsDebuff()			return false end
function modifier_imba_diffusal_2_passive:IsHidden() 			return true end
function modifier_imba_diffusal_2_passive:IsPurgable() 			return false end
function modifier_imba_diffusal_2_passive:IsPurgeException() 	return false end
function modifier_imba_diffusal_2_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_diffusal_2_passive:DeclareFunctions() 	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_diffusal_2_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_imba_diffusal_2_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end

function modifier_imba_diffusal_2_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_diffusal_2_unique", {})
	end
end

function modifier_imba_diffusal_2_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_diffusal_2_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_diffusal_2_unique")
	end
end

modifier_imba_diffusal_2_unique = class({})

function modifier_imba_diffusal_2_unique:IsDebuff()			return false end
function modifier_imba_diffusal_2_unique:IsHidden() 		return true end
function modifier_imba_diffusal_2_unique:IsPurgable() 		return false end
function modifier_imba_diffusal_2_unique:IsPurgeException() return false end
function modifier_imba_diffusal_2_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_diffusal_2_unique:OnCreated()
	self.ability = self:GetAbility()
end

function modifier_imba_diffusal_2_unique:OnDestroy()
	self.ability = nil
end

function modifier_imba_diffusal_2_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsCourier() or keys.target:GetMaxMana() <= 0 or keys.target:IsMagicImmune() or not self:GetParent().splitattack then
		return
	end
	if self:GetParent():HasModifier("modifier_imba_diffusal_3_unique") then
		return
	end
	local mana_burn = self:GetParent():IsIllusion() and self.ability:GetSpecialValueFor("illusion_mana_burn") or self.ability:GetSpecialValueFor("mana_burn")
	local pfx = ParticleManager:CreateParticle("particles/item/diffusal/diffusal_manaburn_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:ReleaseParticleIndex(pfx)
	local mana_burn = (keys.target:GetMana() >= mana_burn) and mana_burn or keys.target:GetMana()
	keys.target:SetMana(keys.target:GetMana() - mana_burn)
	ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self.ability, damage_type = DAMAGE_TYPE_PHYSICAL, damage = mana_burn})
	if RollPercentage(self:GetAbility():GetSpecialValueFor("proc_chance")) and not self:GetParent():IsIllusion() then
		self:GetParent():SetCursorCastTarget(keys.target)
		self.ability:OnSpellStart()
	end
end

item_imba_diffusal_blade_3 = class({})

LinkLuaModifier("modifier_imba_diffusal_3_passive", "items/item_diffusal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_diffusal_3_unique", "items/item_diffusal", LUA_MODIFIER_MOTION_NONE)

function item_imba_diffusal_blade_3:GetIntrinsicModifierName() return "modifier_imba_diffusal_3_passive" end

function item_imba_diffusal_blade_3:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("DOTA_Item.DiffusalBlade.Target")
	target:Purge(true, false, false, false, false)
	target:AddNewModifier(caster, self, "modifier_imba_diffusal_slow", {duration = self:GetSpecialValueFor("tooltip_duration")})
	local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(pfx)
	if target:IsIllusion() or (target:IsCreature() and not target:IsConsideredHero()) then
		target:Kill(self, caster)
	end
end


modifier_imba_diffusal_3_passive = class({})

function modifier_imba_diffusal_3_passive:IsDebuff()			return false end
function modifier_imba_diffusal_3_passive:IsHidden() 			return true end
function modifier_imba_diffusal_3_passive:IsPurgable() 			return false end
function modifier_imba_diffusal_3_passive:IsPurgeException() 	return false end
function modifier_imba_diffusal_3_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_diffusal_3_passive:DeclareFunctions() 	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_diffusal_3_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_imba_diffusal_3_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end

function modifier_imba_diffusal_3_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_diffusal_3_unique", {})
	end
end

function modifier_imba_diffusal_3_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_diffusal_3_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_diffusal_3_unique")
	end
end

modifier_imba_diffusal_3_unique = class({})

function modifier_imba_diffusal_3_unique:IsDebuff()			return false end
function modifier_imba_diffusal_3_unique:IsHidden() 		return true end
function modifier_imba_diffusal_3_unique:IsPurgable() 		return false end
function modifier_imba_diffusal_3_unique:IsPurgeException() return false end
function modifier_imba_diffusal_3_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_diffusal_3_unique:OnCreated()
	self.ability = self:GetAbility()
end

function modifier_imba_diffusal_3_unique:OnDestroy()
	self.ability = nil
end

function modifier_imba_diffusal_3_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsCourier() or keys.target:GetMaxMana() <= 0 or keys.target:IsMagicImmune() or not self:GetParent().splitattack then
		return
	end
	local mana_burn = self:GetParent():IsIllusion() and self.ability:GetSpecialValueFor("illusion_mana_burn") or self.ability:GetSpecialValueFor("mana_burn")
	local pfx = ParticleManager:CreateParticle("particles/item/diffusal/diffusal_manaburn_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:ReleaseParticleIndex(pfx)
	local mana_burn = (keys.target:GetMana() >= mana_burn) and mana_burn or keys.target:GetMana()
	keys.target:SetMana(keys.target:GetMana() - mana_burn)
	ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self.ability, damage_type = DAMAGE_TYPE_PHYSICAL, damage = mana_burn})
	if RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) and not self:GetParent():IsIllusion() then
		self:GetParent():SetCursorCastTarget(keys.target)
		self.ability:OnSpellStart()
	end
end
