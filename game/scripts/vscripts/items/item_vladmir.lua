


item_imba_vladmir = class({})

LinkLuaModifier("modifier_vladmir_passive", "items/item_vladmir", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_vladmir_aura", "items/item_vladmir", LUA_MODIFIER_MOTION_NONE)

function item_imba_vladmir:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_vladmir:GetIntrinsicModifierName() return "modifier_vladmir_passive" end

modifier_vladmir_passive = class({})

function modifier_vladmir_passive:IsDebuff()			return false end
function modifier_vladmir_passive:IsHidden() 			return true end
function modifier_vladmir_passive:IsPurgable() 			return false end
function modifier_vladmir_passive:IsPurgeException() 	return false end
function modifier_vladmir_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_vladmir_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_vladmir_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("stat_bonus") end
function modifier_vladmir_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("stat_bonus") end
function modifier_vladmir_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("stat_bonus") end

function modifier_vladmir_passive:IsAura() return true end
function modifier_vladmir_passive:GetAuraDuration() return 0.1 end
function modifier_vladmir_passive:GetModifierAura() return "modifier_item_imba_vladmir_aura" end
function modifier_vladmir_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_vladmir_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_vladmir_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_vladmir_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_vladmir_passive:GetAuraEntityReject(unit)
	if unit:HasModifier("modifier_item_imba_vladmir_2_aura") then
		return true
	else
		return false
	end
end

modifier_item_imba_vladmir_aura = class({})

function modifier_item_imba_vladmir_aura:IsDebuff()			return false end
function modifier_item_imba_vladmir_aura:IsHidden() 		return false end
function modifier_item_imba_vladmir_aura:IsPurgable() 		return false end
function modifier_item_imba_vladmir_aura:IsPurgeException() return false end
function modifier_item_imba_vladmir_aura:GetTexture() return "imba_vladmir" end
function modifier_item_imba_vladmir_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_vladmir_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_vladmir_aura:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_item_imba_vladmir_aura:GetModifierBaseDamageOutgoing_Percentage() return self.ability:GetSpecialValueFor("damage_aura") end
function modifier_item_imba_vladmir_aura:GetModifierPhysicalArmorBonus() return self.ability:GetSpecialValueFor("armor_aura") end
function modifier_item_imba_vladmir_aura:GetModifierConstantManaRegen() return self.ability:GetSpecialValueFor("mana_regen_aura") end
function modifier_item_imba_vladmir_aura:GetModifierConstantHealthRegen() return self.ability:GetSpecialValueFor("hp_regen_aura") end

function modifier_item_imba_vladmir_aura:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and (keys.target:IsHero() or keys.target:IsCreep() or keys.target:IsBoss()) then
		local lifesteal = keys.damage * (self.ability:GetSpecialValueFor("vampiric_aura") / 100)
		self:GetParent():Heal(lifesteal, self.ability)
		local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end



item_imba_vladmir_2 = class({})

LinkLuaModifier("modifier_vladmir2_passive", "items/item_vladmir", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_vladmir_2_aura", "items/item_vladmir", LUA_MODIFIER_MOTION_NONE)

function item_imba_vladmir_2:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_vladmir_2:GetIntrinsicModifierName() return "modifier_vladmir2_passive" end

modifier_vladmir2_passive = class({})

function modifier_vladmir2_passive:IsDebuff()			return false end
function modifier_vladmir2_passive:IsHidden() 			return true end
function modifier_vladmir2_passive:IsPurgable() 			return false end
function modifier_vladmir2_passive:IsPurgeException() 	return false end
function modifier_vladmir2_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_vladmir2_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_vladmir2_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("stat_bonus") end
function modifier_vladmir2_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("stat_bonus") end
function modifier_vladmir2_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("stat_bonus") end

function modifier_vladmir2_passive:IsAura() return true end
function modifier_vladmir2_passive:GetAuraDuration() return 0.1 end
function modifier_vladmir2_passive:GetModifierAura() return "modifier_item_imba_vladmir_2_aura" end
function modifier_vladmir2_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_vladmir2_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_vladmir2_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_vladmir2_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_item_imba_vladmir_2_aura = class({})

function modifier_item_imba_vladmir_2_aura:IsDebuff()			return false end
function modifier_item_imba_vladmir_2_aura:IsHidden() 			return false end
function modifier_item_imba_vladmir_2_aura:IsPurgable() 		return false end
function modifier_item_imba_vladmir_2_aura:IsPurgeException() 	return false end
function modifier_item_imba_vladmir_2_aura:GetTexture() return "imba_vladmir_2" end
function modifier_item_imba_vladmir_2_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_vladmir_2_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_vladmir_2_aura:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_item_imba_vladmir_2_aura:GetModifierBaseDamageOutgoing_Percentage() return self.ability:GetSpecialValueFor("damage_aura") end
function modifier_item_imba_vladmir_2_aura:GetModifierPhysicalArmorBonus() return self.ability:GetSpecialValueFor("armor_aura") end
function modifier_item_imba_vladmir_2_aura:GetModifierConstantManaRegen() return self.ability:GetSpecialValueFor("mana_regen_aura") end
function modifier_item_imba_vladmir_2_aura:GetModifierConstantHealthRegen() return self.ability:GetSpecialValueFor("hp_regen_aura") end

function modifier_item_imba_vladmir_2_aura:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and (keys.unit:IsHero() or keys.unit:IsCreep() or keys.unit:IsBoss()) and IsEnemy(keys.attacker, keys.unit) and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
		local lifesteal = keys.damage * (self.ability:GetSpecialValueFor("hero_lifesteal") / 100)
		if keys.unit:IsCreep() and keys.inflictor then
			lifesteal = lifesteal / 5
		end
		self:GetParent():Heal(lifesteal, self.ability)
		local pfx = ParticleManager:CreateParticle("particles/item/vladmir/vladmir_blood_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end