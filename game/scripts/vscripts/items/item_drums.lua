

item_imba_ancient_janggo = class({})

LinkLuaModifier("modifier_imba_janggo_passive", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_drums_aura", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_janggo_active_hero", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_janggo_active_creep", "items/item_drums", LUA_MODIFIER_MOTION_NONE)

function item_imba_ancient_janggo:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_ancient_janggo:GetIntrinsicModifierName() return "modifier_imba_janggo_passive" end

function item_imba_ancient_janggo:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.DoE.Activate")
	local radius = self:GetSpecialValueFor("radius")
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, hero in pairs(heroes) do
		local buff1 = hero:AddNewModifier(caster, self, "modifier_imba_janggo_active_hero", {duration = self:GetSpecialValueFor("duration")})
		buff1:SetStackCount(#heroes)
		local buff2 = hero:AddNewModifier(caster, self, "modifier_imba_janggo_active_creep", {duration = self:GetSpecialValueFor("duration")})
		buff2:SetStackCount(#creeps)
	end
	for _, creep in pairs(creeps) do
		local buff2 = creep:AddNewModifier(caster, self, "modifier_imba_janggo_active_creep", {duration = self:GetSpecialValueFor("duration")})
		buff2:SetStackCount(#creeps)
	end
end

modifier_imba_janggo_passive = class({})

function modifier_imba_janggo_passive:IsDebuff()			return false end
function modifier_imba_janggo_passive:IsHidden() 			return true end
function modifier_imba_janggo_passive:IsPurgable() 			return false end
function modifier_imba_janggo_passive:IsPurgeException() 	return false end
function modifier_imba_janggo_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_janggo_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_imba_janggo_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_str") end
function modifier_imba_janggo_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_imba_janggo_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_imba_janggo_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_janggo_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

function modifier_imba_janggo_passive:IsAura() return true end
function modifier_imba_janggo_passive:GetAuraDuration() return 0.1 end
function modifier_imba_janggo_passive:GetModifierAura() return "modifier_item_imba_drums_aura" end
function modifier_imba_janggo_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_janggo_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_janggo_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_janggo_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_janggo_passive:GetAuraEntityReject(unit)
	if unit:HasModifier("modifier_item_imba_siege_cuirass_positive_aura") or unit:HasModifier("modifier_item_imba_assault_positive_aura") then
		return true
	else
		return false
	end
end

modifier_item_imba_drums_aura = class({})

function modifier_item_imba_drums_aura:IsDebuff()			return false end
function modifier_item_imba_drums_aura:IsHidden() 			return false end
function modifier_item_imba_drums_aura:IsPurgable() 		return true end
function modifier_item_imba_drums_aura:IsPurgeException() 	return true end
function modifier_item_imba_drums_aura:GetTexture() return "imba_ancient_janggo" end
function modifier_item_imba_drums_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_drums_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_drums_aura:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_drums_aura:GetModifierMoveSpeedBonus_Percentage() return self.ability:GetSpecialValueFor("aura_ms") end
function modifier_item_imba_drums_aura:GetModifierAttackSpeedBonus_Constant() return self.ability:GetSpecialValueFor("aura_as") end

modifier_imba_janggo_active_hero = class({})

function modifier_imba_janggo_active_hero:IsDebuff()			return false end
function modifier_imba_janggo_active_hero:IsHidden() 			return true end
function modifier_imba_janggo_active_hero:IsPurgable() 			return true end
function modifier_imba_janggo_active_hero:IsPurgeException() 	return true end
function modifier_imba_janggo_active_hero:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_janggo_active_hero:OnDestroy() self.ability = nil end
function modifier_imba_janggo_active_hero:GetEffectName() return "particles/items_fx/drum_of_endurance_buff.vpcf" end
function modifier_imba_janggo_active_hero:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_janggo_active_hero:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_janggo_active_hero:GetModifierMoveSpeedBonus_Constant() return self.ability:GetSpecialValueFor("active_ms_per_hero") * self:GetStackCount() end
function modifier_imba_janggo_active_hero:GetModifierAttackSpeedBonus_Constant() return self.ability:GetSpecialValueFor("active_as_per_hero") * self:GetStackCount() end

modifier_imba_janggo_active_creep = class({})

function modifier_imba_janggo_active_creep:IsDebuff()			return false end
function modifier_imba_janggo_active_creep:IsHidden() 			return true end
function modifier_imba_janggo_active_creep:IsPurgable() 		return true end
function modifier_imba_janggo_active_creep:IsPurgeException() 	return true end
function modifier_imba_janggo_active_creep:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_janggo_active_creep:OnDestroy() self.ability = nil end
function modifier_imba_janggo_active_creep:GetEffectName() return "particles/items_fx/drum_of_endurance_buff.vpcf" end
function modifier_imba_janggo_active_creep:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_janggo_active_creep:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_janggo_active_creep:GetModifierMoveSpeedBonus_Percentage() return self.ability:GetSpecialValueFor("active_as_per_creep") * self:GetStackCount() end
function modifier_imba_janggo_active_creep:GetModifierAttackSpeedBonus_Constant() return self.ability:GetSpecialValueFor("active_ms_per_creep") * self:GetStackCount() end


item_imba_assault = class({})

LinkLuaModifier("modifier_imba_assault_passive", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_assault_positive_aura", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_assault_aura_passive", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_assault_negative_aura", "items/item_drums", LUA_MODIFIER_MOTION_NONE)

function item_imba_assault:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_assault:GetIntrinsicModifierName() return "modifier_imba_assault_passive" end

modifier_imba_assault_passive = class({})

function modifier_imba_assault_passive:IsDebuff()			return false end
function modifier_imba_assault_passive:IsHidden() 			return true end
function modifier_imba_assault_passive:IsPurgable() 		return false end
function modifier_imba_assault_passive:IsPurgeException() 	return false end
function modifier_imba_assault_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_assault_passive:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_assault_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_imba_assault_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

function modifier_imba_assault_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_assault_aura_passive", {})
	end
end

function modifier_imba_assault_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_assault_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_assault_aura_passive")
	end
end

function modifier_imba_assault_passive:IsAura() return true end
function modifier_imba_assault_passive:GetAuraDuration() return 0.1 end
function modifier_imba_assault_passive:GetModifierAura() return "modifier_item_imba_assault_positive_aura" end
function modifier_imba_assault_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_assault_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_assault_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_assault_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end
function modifier_imba_assault_passive:GetAuraEntityReject(unit)
	if unit:HasModifier("modifier_item_imba_siege_cuirass_positive_aura") then
		return true
	else
		return false
	end
end

modifier_imba_assault_aura_passive = class({})

function modifier_imba_assault_aura_passive:IsDebuff()			return false end
function modifier_imba_assault_aura_passive:IsHidden() 			return true end
function modifier_imba_assault_aura_passive:IsPurgable() 		return false end
function modifier_imba_assault_aura_passive:IsPurgeException() 	return false end
function modifier_imba_assault_aura_passive:IsAura() return true end
function modifier_imba_assault_aura_passive:GetAuraDuration() return 0.1 end
function modifier_imba_assault_aura_passive:GetModifierAura() return "modifier_item_imba_assault_negative_aura" end
function modifier_imba_assault_aura_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_assault_aura_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_assault_aura_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_assault_aura_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end
function modifier_imba_assault_aura_passive:GetAuraEntityReject(unit)
	if unit:HasModifier("modifier_item_imba_siege_cuirass_negative_aura") then
		return true
	else
		return false
	end
end

modifier_item_imba_assault_positive_aura = class({})

function modifier_item_imba_assault_positive_aura:IsDebuff()			return false end
function modifier_item_imba_assault_positive_aura:IsHidden() 			return false end
function modifier_item_imba_assault_positive_aura:IsPurgable() 			return false end
function modifier_item_imba_assault_positive_aura:IsPurgeException() 	return false end
function modifier_item_imba_assault_positive_aura:GetTexture() return "imba_assault" end
function modifier_item_imba_assault_positive_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_assault_positive_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_assault_positive_aura:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_imba_assault_positive_aura:GetModifierAttackSpeedBonus_Constant() return self.ability:GetSpecialValueFor("aura_as_ally") end
function modifier_item_imba_assault_positive_aura:GetModifierPhysicalArmorBonus() return self.ability:GetSpecialValueFor("aura_armor_ally") end

modifier_item_imba_assault_negative_aura = class({})

function modifier_item_imba_assault_negative_aura:IsDebuff()			return true end
function modifier_item_imba_assault_negative_aura:IsHidden() 			return false end
function modifier_item_imba_assault_negative_aura:IsPurgable() 			return false end
function modifier_item_imba_assault_negative_aura:IsPurgeException() 	return false end
function modifier_item_imba_assault_negative_aura:GetTexture() return "imba_assault" end
function modifier_item_imba_assault_negative_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_assault_negative_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_assault_negative_aura:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_item_imba_assault_negative_aura:GetModifierPhysicalArmorBonus() return (0 - self.ability:GetSpecialValueFor("aura_armor_enemy")) end



item_imba_siege_cuirass = class({})

LinkLuaModifier("modifier_imba_siege_passive", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_siege_cuirass_positive_aura", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_siege_aura_passive", "items/item_drums", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_siege_cuirass_negative_aura", "items/item_drums", LUA_MODIFIER_MOTION_NONE)

function item_imba_siege_cuirass:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_siege_cuirass:GetIntrinsicModifierName() return "modifier_imba_siege_passive" end

function item_imba_siege_cuirass:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.DoE.Activate")
	local radius = self:GetSpecialValueFor("radius")
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, hero in pairs(heroes) do
		local buff1 = hero:AddNewModifier(caster, self, "modifier_imba_janggo_active_hero", {duration = self:GetSpecialValueFor("duration")})
		buff1:SetStackCount(#heroes)
		local buff2 = hero:AddNewModifier(caster, self, "modifier_imba_janggo_active_creep", {duration = self:GetSpecialValueFor("duration")})
		buff2:SetStackCount(#creeps)
	end
	for _, creep in pairs(creeps) do
		local buff2 = creep:AddNewModifier(caster, self, "modifier_imba_janggo_active_creep", {duration = self:GetSpecialValueFor("duration")})
		buff2:SetStackCount(#creeps)
	end
end

modifier_imba_siege_passive = class({})

function modifier_imba_siege_passive:IsDebuff()			return false end
function modifier_imba_siege_passive:IsHidden() 		return true end
function modifier_imba_siege_passive:IsPurgable() 		return false end
function modifier_imba_siege_passive:IsPurgeException() return false end
function modifier_imba_siege_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_siege_passive:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT} end
function modifier_imba_siege_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_imba_siege_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_siege_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_str") end
function modifier_imba_siege_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end
function modifier_imba_siege_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_imba_siege_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_siege_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

function modifier_imba_siege_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_siege_aura_passive", {})
	end
end

function modifier_imba_siege_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_siege_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_siege_aura_passive")
	end
end

function modifier_imba_siege_passive:IsAura() return true end
function modifier_imba_siege_passive:GetAuraDuration() return 0.1 end
function modifier_imba_siege_passive:GetModifierAura() return "modifier_item_imba_siege_cuirass_positive_aura" end
function modifier_imba_siege_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_siege_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_siege_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_siege_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end


modifier_imba_siege_aura_passive = class({})

function modifier_imba_siege_aura_passive:IsDebuff()			return false end
function modifier_imba_siege_aura_passive:IsHidden() 			return true end
function modifier_imba_siege_aura_passive:IsPurgable() 			return false end
function modifier_imba_siege_aura_passive:IsPurgeException() 	return false end
function modifier_imba_siege_aura_passive:IsAura() return true end
function modifier_imba_siege_aura_passive:GetAuraDuration() return 0.1 end
function modifier_imba_siege_aura_passive:GetModifierAura() return "modifier_item_imba_siege_cuirass_negative_aura" end
function modifier_imba_siege_aura_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_siege_aura_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_siege_aura_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_siege_aura_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING end

modifier_item_imba_siege_cuirass_positive_aura = class({})

function modifier_item_imba_siege_cuirass_positive_aura:IsDebuff()			return false end
function modifier_item_imba_siege_cuirass_positive_aura:IsHidden() 			return false end
function modifier_item_imba_siege_cuirass_positive_aura:IsPurgable() 		return false end
function modifier_item_imba_siege_cuirass_positive_aura:IsPurgeException() 	return false end
function modifier_item_imba_siege_cuirass_positive_aura:GetTexture() return "imba_siege_cuirass" end
function modifier_item_imba_siege_cuirass_positive_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_siege_cuirass_positive_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_siege_cuirass_positive_aura:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_item_imba_siege_cuirass_positive_aura:GetModifierAttackSpeedBonus_Constant() return self.ability:GetSpecialValueFor("aura_as") end
function modifier_item_imba_siege_cuirass_positive_aura:GetModifierPhysicalArmorBonus() return self.ability:GetSpecialValueFor("aura_armor") end
function modifier_item_imba_siege_cuirass_positive_aura:GetModifierMoveSpeedBonus_Constant() return self.ability:GetSpecialValueFor("aura_ms") end

modifier_item_imba_siege_cuirass_negative_aura = class({})

function modifier_item_imba_siege_cuirass_negative_aura:IsDebuff()			return true end
function modifier_item_imba_siege_cuirass_negative_aura:IsHidden() 			return false end
function modifier_item_imba_siege_cuirass_negative_aura:IsPurgable() 		return false end
function modifier_item_imba_siege_cuirass_negative_aura:IsPurgeException() 	return false end
function modifier_item_imba_siege_cuirass_negative_aura:GetTexture() return "imba_siege_cuirass" end
function modifier_item_imba_siege_cuirass_negative_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_siege_cuirass_negative_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_siege_cuirass_negative_aura:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_item_imba_siege_cuirass_negative_aura:GetModifierAttackSpeedBonus_Constant() return (0 - self.ability:GetSpecialValueFor("aura_as")) end
function modifier_item_imba_siege_cuirass_negative_aura:GetModifierPhysicalArmorBonus() return (0 - self.ability:GetSpecialValueFor("aura_armor")) end
function modifier_item_imba_siege_cuirass_negative_aura:GetModifierMoveSpeedBonus_Constant() return (0 - self.ability:GetSpecialValueFor("aura_ms")) end
