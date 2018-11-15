
item_imba_mekansm = class({})

LinkLuaModifier("modifier_imba_mekansm_passive", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mekansm_aura", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mekansm_hot", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mekansm_heal_armor", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)

function item_imba_mekansm:GetIntrinsicModifierName() return "modifier_imba_mekansm_passive" end

function item_imba_mekansm:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_mekansm:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("aura_radius")
	caster:EmitSound("DOTA_Item.Mekansm.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		local heal_pfx = ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		ParticleManager:SetParticleControlEnt(heal_pfx, 0, ally, PATTACH_ABSORIGIN, "attach_hitloc", ally:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(heal_pfx, 1, Vector(1,0,0))
		ParticleManager:ReleaseParticleIndex(heal_pfx)
		local heal_pfx2 = ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		ParticleManager:SetParticleControlEnt(heal_pfx2, 1, ally, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(heal_pfx2)
		ally:Heal(self:GetSpecialValueFor("heal_amount"), self)
		ally:AddNewModifier(caster, self, "modifier_item_imba_mekansm_hot", {duration = self:GetSpecialValueFor("hot_duration")})
		ally:AddNewModifier(caster, self, "modifier_item_imba_mekansm_heal_armor", {duration = self:GetSpecialValueFor("heal_armor_duration")})
	end
end

modifier_imba_mekansm_passive = class({})

function modifier_imba_mekansm_passive:IsDebuff()			return false end
function modifier_imba_mekansm_passive:IsHidden() 			return true end
function modifier_imba_mekansm_passive:IsPurgable() 		return false end
function modifier_imba_mekansm_passive:IsPurgeException() 	return false end
function modifier_imba_mekansm_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_mekansm_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_mekansm_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_mekansm_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_mekansm_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_mekansm_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_mekansm_passive:IsAura() return true end
function modifier_imba_mekansm_passive:GetAuraDuration() return 0.1 end
function modifier_imba_mekansm_passive:GetModifierAura() return "modifier_item_imba_mekansm_aura" end
function modifier_imba_mekansm_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_mekansm_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_mekansm_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_mekansm_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_mekansm_passive:GetAuraEntityReject(unit)
	if unit:HasModifier("modifier_item_imba_mekansm_2_aura") or unit:HasModifier("modifier_item_imba_guardian_greaves_aura") then
		return true
	else
		return false
	end
end

modifier_item_imba_mekansm_aura = class({})

function modifier_item_imba_mekansm_aura:IsDebuff()			return false end
function modifier_item_imba_mekansm_aura:IsHidden() 		return false end
function modifier_item_imba_mekansm_aura:IsPurgable() 		return false end
function modifier_item_imba_mekansm_aura:IsPurgeException() return false end
function modifier_item_imba_mekansm_aura:GetTexture() return "custom/imba_mekansm" end
function modifier_item_imba_mekansm_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_mekansm_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_mekansm_aura:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_imba_mekansm_aura:GetModifierConstantHealthRegen() return self.ability:GetSpecialValueFor("aura_health_regen") end

modifier_item_imba_mekansm_hot = class({})

function modifier_item_imba_mekansm_hot:IsDebuff()			return false end
function modifier_item_imba_mekansm_hot:IsHidden() 			return false end
function modifier_item_imba_mekansm_hot:IsPurgable() 		return true end
function modifier_item_imba_mekansm_hot:IsPurgeException() 	return true end
function modifier_item_imba_mekansm_hot:GetTexture() return "custom/imba_mekansm" end
function modifier_item_imba_mekansm_hot:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_mekansm_hot:OnDestroy() self.ability = nil end
function modifier_item_imba_mekansm_hot:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end
function modifier_item_imba_mekansm_hot:GetModifierHealthRegenPercentage() return self.ability:GetSpecialValueFor("hot_percentage") end

modifier_item_imba_mekansm_heal_armor = class({})

function modifier_item_imba_mekansm_heal_armor:IsDebuff()			return false end
function modifier_item_imba_mekansm_heal_armor:IsHidden() 			return false end
function modifier_item_imba_mekansm_heal_armor:IsPurgable() 		return true end
function modifier_item_imba_mekansm_heal_armor:IsPurgeException() 	return true end
function modifier_item_imba_mekansm_heal_armor:GetTexture() return "custom/imba_mekansm" end
function modifier_item_imba_mekansm_heal_armor:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_mekansm_heal_armor:OnDestroy() self.ability = nil end
function modifier_item_imba_mekansm_heal_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_imba_mekansm_heal_armor:GetModifierPhysicalArmorBonus() return self.ability:GetSpecialValueFor("heal_bonus_armor") end


item_imba_mekansm_2 = class({})

LinkLuaModifier("modifier_imba_mekansm2_passive", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mekansm_2_aura", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mekansm_2_hot", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mekansm_2_heal_armor", "items/item_mekansm", LUA_MODIFIER_MOTION_NONE)

function item_imba_mekansm_2:GetIntrinsicModifierName() return "modifier_imba_mekansm2_passive" end

function item_imba_mekansm_2:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_mekansm_2:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("aura_radius")
	caster:EmitSound("DOTA_Item.Mekansm.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		local heal_pfx = ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		ParticleManager:SetParticleControlEnt(heal_pfx, 0, ally, PATTACH_ABSORIGIN, "attach_hitloc", ally:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(heal_pfx, 1, Vector(1,0,0))
		ParticleManager:ReleaseParticleIndex(heal_pfx)
		local heal_pfx2 = ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		ParticleManager:SetParticleControlEnt(heal_pfx2, 1, ally, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(heal_pfx2)
		ally:Heal(self:GetSpecialValueFor("heal_amount"), self)
		ally:AddNewModifier(caster, self, "modifier_item_imba_mekansm_2_hot", {duration = self:GetSpecialValueFor("hot_duration")})
		ally:AddNewModifier(caster, self, "modifier_item_imba_mekansm_2_heal_armor", {duration = self:GetSpecialValueFor("heal_armor_duration")})
	end
end

modifier_imba_mekansm2_passive = class({})

function modifier_imba_mekansm2_passive:IsDebuff()			return false end
function modifier_imba_mekansm2_passive:IsHidden() 			return true end
function modifier_imba_mekansm2_passive:IsPurgable() 		return false end
function modifier_imba_mekansm2_passive:IsPurgeException() 	return false end
function modifier_imba_mekansm2_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_mekansm2_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_mekansm2_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_mekansm2_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_mekansm2_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_all_stats") end
function modifier_imba_mekansm2_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_mekansm2_passive:IsAura() return true end
function modifier_imba_mekansm2_passive:GetAuraDuration() return 0.1 end
function modifier_imba_mekansm2_passive:GetModifierAura() return "modifier_item_imba_mekansm_2_aura" end
function modifier_imba_mekansm2_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_mekansm2_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_mekansm2_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_mekansm2_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_mekansm2_passive:GetAuraEntityReject(unit) return unit:HasModifier("modifier_item_imba_guardian_greaves_aura") end

modifier_item_imba_mekansm_2_aura = class({})

function modifier_item_imba_mekansm_2_aura:IsDebuff()			return false end
function modifier_item_imba_mekansm_2_aura:IsHidden() 			return false end
function modifier_item_imba_mekansm_2_aura:IsPurgable() 		return false end
function modifier_item_imba_mekansm_2_aura:IsPurgeException() 	return false end
function modifier_item_imba_mekansm_2_aura:GetTexture() return "custom/imba_mekansm_2" end
function modifier_item_imba_mekansm_2_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_mekansm_2_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_mekansm_2_aura:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_item_imba_mekansm_2_aura:GetModifierConstantHealthRegen() return self.ability:GetSpecialValueFor("aura_health_regen") end

modifier_item_imba_mekansm_2_hot = class({})

function modifier_item_imba_mekansm_2_hot:IsDebuff()			return false end
function modifier_item_imba_mekansm_2_hot:IsHidden() 			return false end
function modifier_item_imba_mekansm_2_hot:IsPurgable() 			return true end
function modifier_item_imba_mekansm_2_hot:IsPurgeException() 	return true end
function modifier_item_imba_mekansm_2_hot:GetTexture() return "custom/imba_mekansm_2" end
function modifier_item_imba_mekansm_2_hot:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_mekansm_2_hot:OnDestroy() self.ability = nil end
function modifier_item_imba_mekansm_2_hot:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end
function modifier_item_imba_mekansm_2_hot:GetModifierHealthRegenPercentage() return self.ability:GetSpecialValueFor("hot_percentage") end

modifier_item_imba_mekansm_2_heal_armor = class({})

function modifier_item_imba_mekansm_2_heal_armor:IsDebuff()			return false end
function modifier_item_imba_mekansm_2_heal_armor:IsHidden() 		return false end
function modifier_item_imba_mekansm_2_heal_armor:IsPurgable() 		return true end
function modifier_item_imba_mekansm_2_heal_armor:IsPurgeException() return true end
function modifier_item_imba_mekansm_2_heal_armor:GetTexture() return "custom/imba_mekansm_2" end
function modifier_item_imba_mekansm_2_heal_armor:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_mekansm_2_heal_armor:OnDestroy() self.ability = nil end
function modifier_item_imba_mekansm_2_heal_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_imba_mekansm_2_heal_armor:GetModifierPhysicalArmorBonus() return self.ability:GetSpecialValueFor("heal_bonus_armor") end