item_imba_yasha = class({})

LinkLuaModifier("modifier_imba_yasha_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_yasha_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_yasha_stacks", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_yasha:GetIntrinsicModifierName() return "modifier_imba_yasha_passive" end

function item_imba_yasha:TriggerYashaAttack(target)
	local info = 
	{
		Target = target,
		Source = self:GetCaster(),
		Ability = self,	
		EffectName = "particles/item/yasha/yasha_projectile.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("proc_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function item_imba_yasha:OnProjectileHit(target, location)
	if target then
		self:GetCaster().splitattack = false
		self:GetCaster():PerformAttack(target, true, true, true, false, false, false, false)
		self:GetCaster().splitattack = true
	end
end

modifier_imba_yasha_passive = class({})

function modifier_imba_yasha_passive:IsDebuff()			return false end
function modifier_imba_yasha_passive:IsHidden() 		return true end
function modifier_imba_yasha_passive:IsPurgable() 		return false end
function modifier_imba_yasha_passive:IsPurgeException() return false end
function modifier_imba_yasha_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_yasha_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE_2} end
function modifier_imba_yasha_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_yasha_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_yasha_passive:GetModifierMoveSpeedBonus_Percentage_Unique_2() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end

function modifier_imba_yasha_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_yasha_unique", {})
	end
end

function modifier_imba_yasha_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_yasha_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_yasha_unique")
	end
end

modifier_imba_yasha_unique = class({})

function modifier_imba_yasha_unique:IsDebuff()			return false end
function modifier_imba_yasha_unique:IsHidden() 			return true end
function modifier_imba_yasha_unique:IsPurgable() 		return false end
function modifier_imba_yasha_unique:IsPurgeException() 	return false end
function modifier_imba_yasha_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_yasha_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_yasha_unique:OnDestroy() self.ability = nil end

function modifier_imba_yasha_unique:OnAttackLanded(keys)
	if not IsServer() or keys.attacker ~= self:GetParent() or not self:GetParent().splitattack or self:GetParent():IsIllusion() then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_yasha_stacks", {duration = self.ability:GetSpecialValueFor("stack_duration")})
	if buff:GetStackCount() < self.ability:GetSpecialValueFor("max_stacks") then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	if not keys.target:IsBuilding() and not keys.target:IsOther() and RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) then
		local pfx = ParticleManager:CreateParticle("particles/item/yasha/yasha_attack_ghost.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_PhantomLancer.Doppelganger.Appear")
		self.ability:TriggerYashaAttack(keys.target)
	end
end

modifier_item_imba_yasha_stacks = class({})

function modifier_item_imba_yasha_stacks:IsDebuff()			return false end
function modifier_item_imba_yasha_stacks:IsHidden() 		return false end
function modifier_item_imba_yasha_stacks:IsPurgable() 		return false end
function modifier_item_imba_yasha_stacks:IsPurgeException() return false end
function modifier_item_imba_yasha_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_yasha_stacks:GetModifierMoveSpeedBonus_Percentage() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stacking_ms")) end
function modifier_item_imba_yasha_stacks:GetModifierAttackSpeedBonus_Constant() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stacking_as")) end


item_imba_sange = class({})

LinkLuaModifier("modifier_imba_sange_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_sange_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_sange_maim", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_sange_disarm", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_sange:GetIntrinsicModifierName() return "modifier_imba_sange_passive" end

modifier_imba_sange_passive = class({})

function modifier_imba_sange_passive:IsDebuff()			return false end
function modifier_imba_sange_passive:IsHidden() 		return true end
function modifier_imba_sange_passive:IsPurgable() 		return false end
function modifier_imba_sange_passive:IsPurgeException() return false end
function modifier_imba_sange_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_sange_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_sange_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_sange_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end

function modifier_imba_sange_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_sange_unique", {})
	end
end

function modifier_imba_sange_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_sange_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_sange_unique")
	end
end

modifier_imba_sange_unique = class({})

function modifier_imba_sange_unique:IsDebuff()			return false end
function modifier_imba_sange_unique:IsHidden() 			return true end
function modifier_imba_sange_unique:IsPurgable() 		return false end
function modifier_imba_sange_unique:IsPurgeException() 	return false end
function modifier_imba_sange_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_sange_unique:OnDestroy() self.ability = nil end
function modifier_imba_sange_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_sange_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():IsIllusion() or self:GetParent() ~= keys.attacker or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() then
		return
	end
	local max_stacks = (self.ability:GetSpecialValueFor("maim_cap") - self.ability:GetSpecialValueFor("maim_base")) / self.ability:GetSpecialValueFor('maim_stacking')
	local buff = keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_maim", {duration = self.ability:GetSpecialValueFor("maim_duration")})
	if buff:GetStackCount() < max_stacks then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	keys.target:EmitSound("DOTA_Item.Maim")
	if RollPercentage(self.ability:GetSpecialValueFor("disarm_chance")) and self.ability:IsCooldownReady() then
		keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_disarm", {duration = self.ability:GetSpecialValueFor("disarm_duration")})
		keys.target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
		self.ability:UseResources(true, true, true)
	end
end

modifier_item_imba_sange_maim = class({})

function modifier_item_imba_sange_maim:IsDebuff()			return true end
function modifier_item_imba_sange_maim:IsHidden() 			return false end
function modifier_item_imba_sange_maim:IsPurgable() 		return false end
function modifier_item_imba_sange_maim:IsPurgeException() 	return false end
function modifier_item_imba_sange_maim:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_sange_maim:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("maim_base") - math.max(0, self:GetStackCount() - 1) * self:GetAbility():GetSpecialValueFor("maim_stacking")) end
function modifier_item_imba_sange_maim:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("maim_base") - math.max(0, self:GetStackCount() - 1) * self:GetAbility():GetSpecialValueFor("maim_stacking")) end
function modifier_item_imba_sange_maim:GetEffectName() return "particles/items2_fx/sange_maim.vpcf" end
function modifier_item_imba_sange_maim:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_item_imba_sange_maim:OnRefresh()
	if IsServer() and self:GetParent():IsBoss() and self:GetStackCount() > 5 then
		self:SetStackCount(5)
	end
end

modifier_item_imba_sange_disarm = class({})

function modifier_item_imba_sange_disarm:IsDebuff()			return true end
function modifier_item_imba_sange_disarm:IsHidden() 		return false end
function modifier_item_imba_sange_disarm:IsPurgable() 		return false end
function modifier_item_imba_sange_disarm:IsPurgeException() return false end
function modifier_item_imba_sange_disarm:CheckState() return {[MODIFIER_STATE_DISARMED] = true} end
function modifier_item_imba_sange_disarm:GetEffectName() return "particles/items2_fx/heavens_halberd.vpcf" end
function modifier_item_imba_sange_disarm:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_item_imba_sange_disarm:ShouldUseOverheadOffset() return true end

item_imba_azura = class({})

LinkLuaModifier("modifier_imba_azura_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_azura_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_azura:GetIntrinsicModifierName() return "modifier_imba_azura_passive" end

modifier_imba_azura_passive = class({})

function modifier_imba_azura_passive:IsDebuff()			return false end
function modifier_imba_azura_passive:IsHidden() 		return true end
function modifier_imba_azura_passive:IsPurgable() 		return false end
function modifier_imba_azura_passive:IsPurgeException() return false end
function modifier_imba_azura_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_azura_passive:DeclareFunctions() return {MODIFIER_PROPERTY_MANACOST_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_azura_passive:GetModifierPercentageManacost() return self:GetAbility():GetSpecialValueFor("mana_cost_reduce") end
function modifier_imba_azura_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end
function modifier_imba_azura_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end

function modifier_imba_azura_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_azura_unique", {})
	end
end

function modifier_imba_azura_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_azura_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_azura_unique")
	end
end

modifier_imba_azura_unique = class({})

function modifier_imba_azura_unique:IsDebuff()			return false end
function modifier_imba_azura_unique:IsHidden() 			return true end
function modifier_imba_azura_unique:IsPurgable() 		return false end
function modifier_imba_azura_unique:IsPurgeException() 	return false end
function modifier_imba_azura_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_azura_unique:OnDestroy() self.ability = nil end
function modifier_imba_azura_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_azura_unique:OnAttackLanded(keys)
	if not IsServer() or self:GetParent() ~= keys.attacker then
		return
	end
	if RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) then
		self:GetParent():EmitSound("DOTA_Item.FaerieSpark.Activate")
		local pfx = ParticleManager:CreateParticle("particles/item/azura/azura_mana_regen.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():GiveMana(self.ability:GetSpecialValueFor("mana_regen"))
	end
end

item_imba_sange_and_yasha = class({})

LinkLuaModifier("modifier_imba_sange_and_yasha_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_sange_and_yasha_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_sange_and_yasha:GetIntrinsicModifierName() return "modifier_imba_sange_and_yasha_passive" end

function item_imba_sange_and_yasha:TriggerYashaAttack(target)
	local info = 
	{
		Target = target,
		Source = self:GetCaster(),
		Ability = self,	
		EffectName = "particles/item/yasha/yasha_projectile.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("proc_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function item_imba_sange_and_yasha:OnProjectileHit(target, location)
	if target then
		self:GetCaster().splitattack = false
		self:GetCaster():PerformAttack(target, true, true, true, false, false, false, false)
		self:GetCaster().splitattack = true
	end
end

modifier_imba_sange_and_yasha_passive = class({})

function modifier_imba_sange_and_yasha_passive:IsDebuff()			return false end
function modifier_imba_sange_and_yasha_passive:IsHidden() 			return true end
function modifier_imba_sange_and_yasha_passive:IsPurgable() 		return false end
function modifier_imba_sange_and_yasha_passive:IsPurgeException() 	return false end
function modifier_imba_sange_and_yasha_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_sange_and_yasha_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE_2, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_sange_and_yasha_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_sange_and_yasha_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_sange_and_yasha_passive:GetModifierMoveSpeedBonus_Percentage_Unique_2() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end
function modifier_imba_sange_and_yasha_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_sange_and_yasha_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end

function modifier_imba_sange_and_yasha_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_sange_and_yasha_unique", {})
	end
end

function modifier_imba_sange_and_yasha_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_sange_and_yasha_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_sange_and_yasha_unique")
	end
end

modifier_imba_sange_and_yasha_unique = class({})

function modifier_imba_sange_and_yasha_unique:IsDebuff()			return false end
function modifier_imba_sange_and_yasha_unique:IsHidden() 			return true end
function modifier_imba_sange_and_yasha_unique:IsPurgable() 			return false end
function modifier_imba_sange_and_yasha_unique:IsPurgeException() 	return false end
function modifier_imba_sange_and_yasha_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_sange_and_yasha_unique:OnDestroy() self.ability = nil end
function modifier_imba_sange_and_yasha_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_sange_and_yasha_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():IsIllusion() or self:GetParent() ~= keys.attacker or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_yasha_stacks", {duration = self.ability:GetSpecialValueFor("passive_duration")})
	if buff:GetStackCount() < self.ability:GetSpecialValueFor("buff_stacks") then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	local buff2 = keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_maim", {duration = self.ability:GetSpecialValueFor("passive_duration")})
	buff2:SetStackCount(buff2:GetStackCount() + 1)
	keys.target:EmitSound("DOTA_Item.Maim")
	if RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) and self:GetParent().splitattack and self.ability:IsCooldownReady() then
		local pfx = ParticleManager:CreateParticle("particles/item/yasha/yasha_attack_ghost.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_PhantomLancer.Doppelganger.Appear")
		self.ability:TriggerYashaAttack(keys.target)
		keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_disarm", {duration = self.ability:GetSpecialValueFor("proc_duration")})
		keys.target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
		self.ability:UseResources(true, true, true)
	end
end

item_imba_sange_and_azura = class({})

LinkLuaModifier("modifier_imba_sange_and_azura_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_sange_and_azura_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_sange_and_azura:GetIntrinsicModifierName() return "modifier_imba_sange_and_azura_passive" end

modifier_imba_sange_and_azura_passive = class({})

function modifier_imba_sange_and_azura_passive:IsDebuff()			return false end
function modifier_imba_sange_and_azura_passive:IsHidden() 			return true end
function modifier_imba_sange_and_azura_passive:IsPurgable() 		return false end
function modifier_imba_sange_and_azura_passive:IsPurgeException() 	return false end
function modifier_imba_sange_and_azura_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_sange_and_azura_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_MANACOST_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_sange_and_azura_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_sange_and_azura_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_imba_sange_and_azura_passive:GetModifierPercentageManacost() return self:GetAbility():GetSpecialValueFor("mana_cost_reduce") end
function modifier_imba_sange_and_azura_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end
function modifier_imba_sange_and_azura_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end

function modifier_imba_sange_and_azura_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_sange_and_azura_unique", {})
	end
end

function modifier_imba_sange_and_azura_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_sange_and_azura_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_sange_and_azura_unique")
	end
end

modifier_imba_sange_and_azura_unique = class({})

function modifier_imba_sange_and_azura_unique:IsDebuff()			return false end
function modifier_imba_sange_and_azura_unique:IsHidden() 			return true end
function modifier_imba_sange_and_azura_unique:IsPurgable() 			return false end
function modifier_imba_sange_and_azura_unique:IsPurgeException() 	return false end
function modifier_imba_sange_and_azura_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_sange_and_azura_unique:OnDestroy() self.ability = nil end
function modifier_imba_sange_and_azura_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_sange_and_azura_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent() ~= keys.attacker or self:GetParent():IsIllusion() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsCourier() then
		return
	end
	local buff2 = keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_maim", {duration = self.ability:GetSpecialValueFor("passive_duration")})
	buff2:SetStackCount(buff2:GetStackCount() + 1)
	keys.target:EmitSound("DOTA_Item.Maim")
	if RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) and self.ability:IsCooldownReady() then
		keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_disarm", {duration = self.ability:GetSpecialValueFor("proc_duration")})
		keys.target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
		self.ability:UseResources(true, true, true)
		self:GetParent():EmitSound("DOTA_Item.FaerieSpark.Activate")
		local pfx = ParticleManager:CreateParticle("particles/item/azura/azura_mana_regen.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():GiveMana(self.ability:GetSpecialValueFor("mana_regen"))
		self.ability:UseResources(true, true, true)
	end
end

item_imba_azura_and_yasha = class({})

LinkLuaModifier("modifier_imba_azura_and_yasha_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_azura_and_yasha_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_azura_and_yasha:GetIntrinsicModifierName() return "modifier_imba_azura_and_yasha_passive" end

function item_imba_azura_and_yasha:TriggerYashaAttack(target)
	local info = 
	{
		Target = target,
		Source = self:GetCaster(),
		Ability = self,	
		EffectName = "particles/item/yasha/yasha_projectile.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("proc_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function item_imba_azura_and_yasha:OnProjectileHit(target, location)
	if target then
		self:GetCaster().splitattack = false
		self:GetCaster():PerformAttack(target, true, true, true, false, false, false, false)
		self:GetCaster().splitattack = true
	end
end

modifier_imba_azura_and_yasha_passive = class({})

function modifier_imba_azura_and_yasha_passive:IsDebuff()			return false end
function modifier_imba_azura_and_yasha_passive:IsHidden() 			return true end
function modifier_imba_azura_and_yasha_passive:IsPurgable() 		return false end
function modifier_imba_azura_and_yasha_passive:IsPurgeException() 	return false end
function modifier_imba_azura_and_yasha_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_azura_and_yasha_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE_2, MODIFIER_PROPERTY_MANACOST_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_azura_and_yasha_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_azura_and_yasha_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_azura_and_yasha_passive:GetModifierMoveSpeedBonus_Percentage_Unique_2() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end
function modifier_imba_azura_and_yasha_passive:GetModifierPercentageManacost() return self:GetAbility():GetSpecialValueFor("mana_cost_reduce") end
function modifier_imba_azura_and_yasha_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end
function modifier_imba_azura_and_yasha_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end

function modifier_imba_azura_and_yasha_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_azura_and_yasha_unique", {})
	end
end

function modifier_imba_azura_and_yasha_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_azura_and_yasha_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_azura_and_yasha_unique")
	end
end

modifier_imba_azura_and_yasha_unique = class({})

function modifier_imba_azura_and_yasha_unique:IsDebuff()			return false end
function modifier_imba_azura_and_yasha_unique:IsHidden() 			return true end
function modifier_imba_azura_and_yasha_unique:IsPurgable() 			return false end
function modifier_imba_azura_and_yasha_unique:IsPurgeException() 	return false end
function modifier_imba_azura_and_yasha_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_azura_and_yasha_unique:OnDestroy() self.ability = nil end
function modifier_imba_azura_and_yasha_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_azura_and_yasha_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsCourier() then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_yasha_stacks", {duration = self.ability:GetSpecialValueFor("stack_duration")})
	if buff:GetStackCount() < self.ability:GetSpecialValueFor("buff_stacks") then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	if RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) and self:GetParent().splitattack and self.ability:IsCooldownReady() then
		local pfx = ParticleManager:CreateParticle("particles/item/yasha/yasha_attack_ghost.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_PhantomLancer.Doppelganger.Appear")
		self.ability:TriggerYashaAttack(keys.target)
		self:GetParent():EmitSound("DOTA_Item.FaerieSpark.Activate")
		local pfx = ParticleManager:CreateParticle("particles/item/azura/azura_mana_regen.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():GiveMana(self.ability:GetSpecialValueFor("mana_regen"))
		self.ability:UseResources(true, true, true)
	end
end

item_imba_sange_and_azura_and_yasha = class({})

LinkLuaModifier("modifier_imba_triumvirate_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_triumvirate_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_sange_and_azura_and_yasha:GetIntrinsicModifierName() return "modifier_imba_triumvirate_passive" end

function item_imba_sange_and_azura_and_yasha:TriggerYashaAttack(target)
	local info = 
	{
		Target = target,
		Source = self:GetCaster(),
		Ability = self,	
		EffectName = "particles/item/yasha/yasha_projectile.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("proc_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = true,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function item_imba_sange_and_azura_and_yasha:OnProjectileHit(target, location)
	if target then
		self:GetCaster().splitattack = false
		self:GetCaster():PerformAttack(target, true, true, true, false, false, false, false)
		self:GetCaster().splitattack = true
	end
end

modifier_imba_triumvirate_passive = class({})

function modifier_imba_triumvirate_passive:IsDebuff()			return false end
function modifier_imba_triumvirate_passive:IsHidden() 			return true end
function modifier_imba_triumvirate_passive:IsPurgable() 		return false end
function modifier_imba_triumvirate_passive:IsPurgeException() 	return false end
function modifier_imba_triumvirate_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_triumvirate_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE_2, MODIFIER_PROPERTY_MANACOST_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_triumvirate_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_triumvirate_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_triumvirate_passive:GetModifierMoveSpeedBonus_Percentage_Unique_2() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end
function modifier_imba_triumvirate_passive:GetModifierPercentageManacost() return self:GetAbility():GetSpecialValueFor("mana_cost_reduce") end
function modifier_imba_triumvirate_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end
function modifier_imba_triumvirate_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_imba_triumvirate_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_triumvirate_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_str") end

function modifier_imba_triumvirate_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_triumvirate_unique", {})
	end
end

function modifier_imba_triumvirate_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_triumvirate_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_triumvirate_unique")
	end
end

modifier_imba_triumvirate_unique = class({})

function modifier_imba_triumvirate_unique:IsDebuff()			return false end
function modifier_imba_triumvirate_unique:IsHidden() 			return true end
function modifier_imba_triumvirate_unique:IsPurgable() 			return false end
function modifier_imba_triumvirate_unique:IsPurgeException() 	return false end
function modifier_imba_triumvirate_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_triumvirate_unique:OnDestroy() self.ability = nil end
function modifier_imba_triumvirate_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_triumvirate_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsCourier() then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_yasha_stacks", {duration = self.ability:GetSpecialValueFor("stack_duration")})
	if buff:GetStackCount() < self.ability:GetSpecialValueFor("buff_stacks") then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	local buff2 = keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_maim", {duration = self.ability:GetSpecialValueFor("stack_duration")})
	buff2:SetStackCount(buff2:GetStackCount() + 1)
	keys.target:EmitSound("DOTA_Item.Maim")
	if RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) and self:GetParent().splitattack and self.ability:IsCooldownReady() then
		local pfx = ParticleManager:CreateParticle("particles/item/yasha/yasha_attack_ghost.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_PhantomLancer.Doppelganger.Appear")
		self.ability:TriggerYashaAttack(keys.target)
		self:GetParent():EmitSound("DOTA_Item.FaerieSpark.Activate")
		local pfx = ParticleManager:CreateParticle("particles/item/azura/azura_mana_regen.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():GiveMana(self.ability:GetSpecialValueFor("mana_regen"))
		keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_disarm", {duration = self.ability:GetSpecialValueFor("proc_duration")})
		keys.target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
		self.ability:UseResources(true, true, true)
	end
end


item_imba_manta = class({})

LinkLuaModifier("modifier_imba_manta_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_manta_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_manta_active_invuln", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_manta_passive_illusion", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_manta:GetIntrinsicModifierName() return "modifier_imba_manta_passive" end

function item_imba_manta:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_imba_manta_active_invuln", {duration = self:GetSpecialValueFor("invuln_duration")})
	caster:Purge(false, true, false, false, false)
end

modifier_imba_manta_active_invuln = class({})

function modifier_imba_manta_active_invuln:IsDebuff()			return false end
function modifier_imba_manta_active_invuln:IsHidden() 			return true end
function modifier_imba_manta_active_invuln:IsPurgable() 		return false end
function modifier_imba_manta_active_invuln:IsPurgeException() 	return false end
function modifier_imba_manta_active_invuln:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

function modifier_imba_manta_active_invuln:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/manta_phase.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(pfx, false, false, 15, false, false)
		self:GetParent():AddNoDraw()
		self:GetParent():EmitSound("DOTA_Item.Manta.Activate")
	end
end

function modifier_imba_manta_active_invuln:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
		local pos = self:GetParent():GetAbsOrigin()
		local dmg_in = self.ability:GetSpecialValueFor("illusion_in")
		local dmg_out = self.ability:GetSpecialValueFor("illusion_out")
		local duration = self.ability:GetSpecialValueFor("illusion_duration")
		for i=1, self.ability:GetSpecialValueFor("images_count") do
			IllusionManager:CreateIllusion(self:GetParent(), pos, nil, dmg_out, dmg_in, 0, duration, self:GetParent(), "manta_illusion"..self:GetParent():entindex().."_"..i)
		end
		FindClearSpaceForUnit(self:GetParent(), pos, true)
		self:GetParent():EmitSound("DOTA_Item.Manta.End")
	end
	self.ability = nil
end

modifier_imba_manta_passive = class({})

function modifier_imba_manta_passive:IsDebuff()			return false end
function modifier_imba_manta_passive:IsHidden() 		return true end
function modifier_imba_manta_passive:IsPurgable() 		return false end
function modifier_imba_manta_passive:IsPurgeException() return false end
function modifier_imba_manta_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_manta_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE_2, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_manta_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_manta_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_manta_passive:GetModifierMoveSpeedBonus_Percentage_Unique_2() return self:GetAbility():GetSpecialValueFor("movement_speed_percent_bonus") end
function modifier_imba_manta_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_imba_manta_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end

function modifier_imba_manta_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_manta_unique", {})
	end
end

function modifier_imba_manta_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_manta_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_manta_unique")
	end
end

modifier_imba_manta_unique = class({})

function modifier_imba_manta_unique:IsDebuff()			return false end
function modifier_imba_manta_unique:IsHidden() 			return true end
function modifier_imba_manta_unique:IsPurgable() 		return false end
function modifier_imba_manta_unique:IsPurgeException() 	return false end
function modifier_imba_manta_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_manta_unique:OnDestroy() self.ability = nil end
function modifier_imba_manta_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_manta_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or keys.target:IsBuilding() or keys.target:IsOther() or keys.target:IsCourier() then
		return
	end
	local max_stacks = (self.ability:GetSpecialValueFor("proc_max_illusions") - 1)
	if RollPercentage(self.ability:GetSpecialValueFor("proc_chance")) then
		local dmg_in = self.ability:GetSpecialValueFor("illusion_in")
		local dmg_out = self.ability:GetSpecialValueFor("illusion_out")
		local duration = self.ability:GetSpecialValueFor("illusion_duration")
		local pos = self:GetParent():GetAbsOrigin() + self:GetParent():GetForwardVector() * 100
		pos = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, math.random(0,360), 0), pos)
		local illusion = IllusionManager:CreateIllusion(self:GetParent(), pos, self:GetParent():GetForwardVector(), dmg_out, dmg_in, 0, duration, self:GetParent(), "manta_passive"..self:GetParent():entindex().."_"..self:GetStackCount())
		illusion:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_manta_passive_illusion", {})
		self:SetStackCount(self:GetStackCount() + 1)
		if self:GetStackCount() > max_stacks then
			self:SetStackCount(0)
		end
	end
end

modifier_imba_manta_passive_illusion = class({})

function modifier_imba_manta_passive_illusion:IsDebuff()			return false end
function modifier_imba_manta_passive_illusion:IsHidden() 			return true end
function modifier_imba_manta_passive_illusion:IsPurgable() 			return false end
function modifier_imba_manta_passive_illusion:IsPurgeException() 	return false end
function modifier_imba_manta_passive_illusion:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_manta_passive_illusion:GetStatusEffectName() return "particles/item/manta/status_effect_manta_passive_illusion.vpcf" end
function modifier_imba_manta_passive_illusion:StatusEffectPriority() return 30 end


item_imba_heavens_halberd = class({})

LinkLuaModifier("modifier_imba_heavens_halberd_passive", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_heavens_halberd_unique", "items/item_knieves", LUA_MODIFIER_MOTION_NONE)

function item_imba_heavens_halberd:GetIntrinsicModifierName() return "modifier_imba_heavens_halberd_passive" end

function item_imba_heavens_halberd:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local duration = target:IsRangedAttacker() and self:GetSpecialValueFor("disarm_range") or self:GetSpecialValueFor("disarm_melee")
	duration = target:IsMagicImmune() and duration * (1 - self:GetSpecialValueFor("mm_duration_reduce") / 100) or duration
	if target:HasModifier("modifier_imba_fervor_passive") or target:HasModifier("modifier_imba_darkness_caster") or target:HasModifier("modifier_imba_faceless_void_timelord_thinker") or target:HasModifier("modifier_imba_take_aim_near") then
		duration = target:IsRangedAttacker() and self:GetSpecialValueFor("disarm_range") or self:GetSpecialValueFor("disarm_melee")
	end
	target:AddNewModifier(caster, self, "modifier_item_imba_sange_disarm", {duration = duration})
	target:EmitSound("DOTA_Item.HeavensHalberd.Target")
	caster:EmitSound("DOTA_Item.HeavensHalberd.Activate")
end

modifier_imba_heavens_halberd_passive = class({})

function modifier_imba_heavens_halberd_passive:IsDebuff()			return false end
function modifier_imba_heavens_halberd_passive:IsHidden() 			return true end
function modifier_imba_heavens_halberd_passive:IsPurgable() 		return false end
function modifier_imba_heavens_halberd_passive:IsPurgeException() 	return false end
function modifier_imba_heavens_halberd_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_heavens_halberd_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT} end
function modifier_imba_heavens_halberd_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_heavens_halberd_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end
function modifier_imba_heavens_halberd_passive:GetModifierEvasion_Constant() return self:GetAbility():GetSpecialValueFor("bonus_evasion") end

function modifier_imba_heavens_halberd_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_heavens_halberd_unique", {})
	end
end

function modifier_imba_heavens_halberd_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_heavens_halberd_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_heavens_halberd_unique")
	end
end

modifier_imba_heavens_halberd_unique = class({})

function modifier_imba_heavens_halberd_unique:IsDebuff()			return false end
function modifier_imba_heavens_halberd_unique:IsHidden() 			return true end
function modifier_imba_heavens_halberd_unique:IsPurgable() 			return false end
function modifier_imba_heavens_halberd_unique:IsPurgeException() 	return false end
function modifier_imba_heavens_halberd_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_heavens_halberd_unique:OnDestroy() self.ability = nil end
function modifier_imba_heavens_halberd_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_heavens_halberd_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():IsIllusion() or self:GetParent() ~= keys.attacker or keys.target:IsBuilding() or keys.target:IsCourier() or keys.target:IsOther() then
		return
	end
	local max_stacks = (self.ability:GetSpecialValueFor("maim_cap") - self.ability:GetSpecialValueFor("maim_base")) / self.ability:GetSpecialValueFor('maim_stacking')
	local buff = keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_maim", {duration = self.ability:GetSpecialValueFor("maim_duration")})
	if buff:GetStackCount() < max_stacks then
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
	keys.target:EmitSound("DOTA_Item.Maim")
	if RollPercentage(self.ability:GetSpecialValueFor("disarm_chance")) and self.ability:IsCooldownReady() then
		keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_sange_disarm", {duration = self.ability:GetSpecialValueFor("disarm_passive")})
		keys.target:EmitSound("DOTA_Item.HeavensHalberd.Activate")
	end
end
