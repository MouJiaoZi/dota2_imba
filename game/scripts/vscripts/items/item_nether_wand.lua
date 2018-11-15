

item_imba_nether_wand = class({})

LinkLuaModifier("modifier_item_imba_nether_wand_burn", "items/item_nether_wand", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nether_wand_passive", "items/item_nether_wand", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nether_wand_unique", "items/item_nether_wand", LUA_MODIFIER_MOTION_NONE)

function item_imba_nether_wand:GetIntrinsicModifierName() return "modifier_imba_nether_wand_passive" end

modifier_imba_nether_wand_passive = class({})

function modifier_imba_nether_wand_passive:IsDebuff()			return false end
function modifier_imba_nether_wand_passive:IsHidden() 			return true end
function modifier_imba_nether_wand_passive:IsPurgable() 		return false end
function modifier_imba_nether_wand_passive:IsPurgeException() 	return false end
function modifier_imba_nether_wand_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_nether_wand_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT_SECONDARY, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_imba_nether_wand_passive:GetModifierBonusStats_Intellect() return self.int end
function modifier_imba_nether_wand_passive:GetModifierAttackSpeedBonus_Constant() return self.as end
function modifier_imba_nether_wand_passive:GetModifierPreAttack_BonusDamage() return self.damage end
function modifier_imba_nether_wand_passive:GetModifierSpellAmplify_Percentage() return self.spellamp end

function modifier_imba_nether_wand_passive:OnCreated()
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_as")
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.spellamp = self:GetAbility():GetSpecialValueFor("spell_power")
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_nether_wand_unique", {})
	end
end

function modifier_imba_nether_wand_passive:OnDestroy()
	self.int = nil
	self.as = nil
	self.damage = nil
	self.spellamp = nil
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_nether_wand_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_nether_wand_unique")
	end
end

modifier_imba_nether_wand_unique = class({})

function modifier_imba_nether_wand_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_nether_wand_unique:OnDestroy() self.ability = nil end
function modifier_imba_nether_wand_unique:IsDebuff()			return false end
function modifier_imba_nether_wand_unique:IsHidden() 			return true end
function modifier_imba_nether_wand_unique:IsPurgable() 			return false end
function modifier_imba_nether_wand_unique:IsPurgeException() 	return false end
function modifier_imba_nether_wand_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_nether_wand_unique:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and IsEnemy(keys.unit, keys.attacker) and (keys.unit:GetAbsOrigin() - keys.attacker:GetAbsOrigin()):Length2D() < self.ability:GetSpecialValueFor("max_distance") and not keys.unit:HasModifier("modifier_item_imba_nether_wand_burn") and not keys.unit:HasModifier("modifier_item_imba_elder_staff_burn") and not self:GetParent():HasModifier("modifier_imba_elder_staff_unquie") and (keys.unit:IsHero() or keys.unit:IsCreep()) and not keys.unit:IsMagicImmune() then
		keys.unit:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_nether_wand_burn", {duration = self.ability:GetSpecialValueFor("burn_duration")})
	end
end

modifier_item_imba_nether_wand_burn = class({})

function modifier_item_imba_nether_wand_burn:IsDebuff()				return true end
function modifier_item_imba_nether_wand_burn:IsHidden() 			return false end
function modifier_item_imba_nether_wand_burn:IsPurgable() 			return false end
function modifier_item_imba_nether_wand_burn:IsPurgeException() 	return false end
function modifier_item_imba_nether_wand_burn:GetEffectName() return "particles/item/nether_wand/nether_burn_debuff.vpcf" end
function modifier_item_imba_nether_wand_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_imba_nether_wand_burn:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:SetStackCount(self:GetParent():GetHealth() * (self.ability:GetSpecialValueFor("burn_amount") / 100))
		self:StartIntervalThink(self.ability:GetSpecialValueFor("burn_tick"))
	end
end

function modifier_item_imba_nether_wand_burn:OnDestroy() self.ability = nil end

function modifier_item_imba_nether_wand_burn:OnIntervalThink()
	local dmg = self:GetStackCount() / (self:GetDuration() / self.ability:GetSpecialValueFor("burn_tick"))
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability, damage = dmg})
end


item_imba_elder_staff = class({})

LinkLuaModifier("modifier_item_imba_elder_staff_burn", "items/item_nether_wand", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_elder_staff_passive", "items/item_nether_wand", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_elder_staff_unique", "items/item_nether_wand", LUA_MODIFIER_MOTION_NONE)

function item_imba_elder_staff:GetIntrinsicModifierName() return "modifier_imba_elder_staff_passive" end

modifier_imba_elder_staff_passive = class({})

function modifier_imba_elder_staff_passive:IsDebuff()			return false end
function modifier_imba_elder_staff_passive:IsHidden() 			return true end
function modifier_imba_elder_staff_passive:IsPurgable() 		return false end
function modifier_imba_elder_staff_passive:IsPurgeException() 	return false end
function modifier_imba_elder_staff_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_elder_staff_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT_SECONDARY, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT} end
function modifier_imba_elder_staff_passive:GetModifierBonusStats_Intellect() return self.int end
function modifier_imba_elder_staff_passive:GetModifierAttackSpeedBonus_Constant() return self.as end
function modifier_imba_elder_staff_passive:GetModifierPreAttack_BonusDamage() return self.damage end
function modifier_imba_elder_staff_passive:GetModifierSpellAmplify_Percentage() return self.spellamp end
function modifier_imba_elder_staff_passive:GetModifierManaBonus() return self.mana end
function modifier_imba_elder_staff_passive:GetModifierConstantHealthRegen() return self.hpregen end

function modifier_imba_elder_staff_passive:OnCreated()
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_as")
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.spellamp = self:GetAbility():GetSpecialValueFor("spell_power")
	self.mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.hpregen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_elder_staff_unique", {})
	end
end

function modifier_imba_elder_staff_passive:OnDestroy()
	self.int = nil
	self.as = nil
	self.damage = nil
	self.spellamp = nil
	self.mana = nil
	self.hpregen = nil
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_elder_staff_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_elder_staff_unique")
	end
end

modifier_imba_elder_staff_unique = class({})

function modifier_imba_elder_staff_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_elder_staff_unique:OnDestroy() self.ability = nil end
function modifier_imba_elder_staff_unique:IsDebuff()			return false end
function modifier_imba_elder_staff_unique:IsHidden() 			return true end
function modifier_imba_elder_staff_unique:IsPurgable() 			return false end
function modifier_imba_elder_staff_unique:IsPurgeException() 	return false end
function modifier_imba_elder_staff_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_CAST_RANGE_BONUS} end
function modifier_imba_elder_staff_unique:GetModifierCastRangeBonus() return self.ability:GetSpecialValueFor("cast_range_bonus") end

function modifier_imba_elder_staff_unique:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and IsEnemy(keys.unit, keys.attacker) and (keys.unit:GetAbsOrigin() - keys.attacker:GetAbsOrigin()):Length2D() < self.ability:GetSpecialValueFor("max_distance") and not keys.unit:HasModifier("modifier_item_imba_nether_wand_burn") and not keys.unit:HasModifier("modifier_item_imba_elder_staff_burn")  and (keys.unit:IsHero() or keys.unit:IsCreep()) and not keys.unit:IsMagicImmune() then
		keys.unit:AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_elder_staff_burn", {duration = self.ability:GetSpecialValueFor("burn_duration")})
	end
end

modifier_item_imba_elder_staff_burn = class({})

function modifier_item_imba_elder_staff_burn:IsDebuff()				return true end
function modifier_item_imba_elder_staff_burn:IsHidden() 			return false end
function modifier_item_imba_elder_staff_burn:IsPurgable() 			return false end
function modifier_item_imba_elder_staff_burn:IsPurgeException() 	return false end
function modifier_item_imba_elder_staff_burn:GetEffectName() return "particles/item/nether_wand/nether_burn_debuff.vpcf" end
function modifier_item_imba_elder_staff_burn:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_imba_elder_staff_burn:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:SetStackCount(self:GetParent():GetHealth() * (self.ability:GetSpecialValueFor("burn_amount") / 100))
		self:StartIntervalThink(self.ability:GetSpecialValueFor("burn_tick"))
	end
end

function modifier_item_imba_elder_staff_burn:OnDestroy() self.ability = nil end

function modifier_item_imba_elder_staff_burn:OnIntervalThink()
	local dmg = self:GetStackCount() / (self:GetDuration() / self.ability:GetSpecialValueFor("burn_tick"))
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability, damage = dmg})
end
