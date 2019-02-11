

item_imba_orchid = class({})

LinkLuaModifier("modifier_imba_orchid_passive", "items/item_orchid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_orchid_debuff", "items/item_orchid", LUA_MODIFIER_MOTION_NONE)

function item_imba_orchid:GetIntrinsicModifierName() return "modifier_imba_orchid_passive" end

function item_imba_orchid:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) or target:IsMagicImmune() then
		return
	end
	target:EmitSound("DOTA_Item.Orchid.Activate")
	target:AddNewModifier(caster, self, "modifier_item_imba_orchid_debuff", {duration = self:GetSpecialValueFor("silence_duration")})
end

modifier_imba_orchid_passive = class({})

function modifier_imba_orchid_passive:IsDebuff()			return false end
function modifier_imba_orchid_passive:IsHidden() 			return true end
function modifier_imba_orchid_passive:IsPurgable() 			return false end
function modifier_imba_orchid_passive:IsPurgeException() 	return false end
function modifier_imba_orchid_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_orchid_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_imba_orchid_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_imba_orchid_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_orchid_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_orchid_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_imba_orchid_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end

modifier_item_imba_orchid_debuff = class({})

function modifier_item_imba_orchid_debuff:IsDebuff()			return true end
function modifier_item_imba_orchid_debuff:IsHidden() 			return false end
function modifier_item_imba_orchid_debuff:IsPurgable() 			return true end
function modifier_item_imba_orchid_debuff:IsPurgeException() 	return true end
function modifier_item_imba_orchid_debuff:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_item_imba_orchid_debuff:IMBARedCirtIncomingDamage() return true end
function modifier_item_imba_orchid_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_item_imba_orchid_debuff:GetModifierIncomingDamage_Percentage() return self:GetAbility():GetSpecialValueFor("silence_damage_percent") end
function modifier_item_imba_orchid_debuff:GetEffectName() return "particles/items2_fx/orchid.vpcf" end
function modifier_item_imba_orchid_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_item_imba_orchid_debuff:ShouldUseOverheadOffset() return true end
function modifier_item_imba_orchid_debuff:OnDestroy()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop_die.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

item_imba_bloodthorn = class({})

LinkLuaModifier("modifier_imba_bloodthorn_passive", "items/item_orchid", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_bloodthorn_debuff", "items/item_orchid", LUA_MODIFIER_MOTION_NONE)

function item_imba_bloodthorn:GetIntrinsicModifierName() return "modifier_imba_bloodthorn_passive" end

function item_imba_bloodthorn:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) or target:IsMagicImmune() then
		return
	end
	target:EmitSound("DOTA_Item.Bloodthorn.Activate")
	target:AddNewModifier(caster, self, "modifier_item_imba_bloodthorn_debuff", {duration = self:GetSpecialValueFor("silence_duration")})
end

modifier_imba_bloodthorn_passive = class({})

function modifier_imba_bloodthorn_passive:IsDebuff()			return false end
function modifier_imba_bloodthorn_passive:IsHidden() 			return true end
function modifier_imba_bloodthorn_passive:IsPurgable() 			return false end
function modifier_imba_bloodthorn_passive:IsPurgeException() 	return false end
function modifier_imba_bloodthorn_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_bloodthorn_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE} end
function modifier_imba_bloodthorn_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_imba_bloodthorn_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_bloodthorn_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_bloodthorn_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_imba_bloodthorn_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end

function modifier_imba_bloodthorn_passive:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() and keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():PassivesDisabled() then
		if PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("crit_chance")) then
			return self:GetAbility():GetSpecialValueFor("crit_damage")
		else
			return 0
		end
	end
end


modifier_item_imba_bloodthorn_debuff = class({})

function modifier_item_imba_bloodthorn_debuff:IsDebuff()			return true end
function modifier_item_imba_bloodthorn_debuff:IsHidden() 			return false end
function modifier_item_imba_bloodthorn_debuff:IsPurgable() 			return true end
function modifier_item_imba_bloodthorn_debuff:IsPurgeException() 	return true end
function modifier_item_imba_bloodthorn_debuff:CheckState() return {[MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_EVADE_DISABLED] = true} end
function modifier_item_imba_bloodthorn_debuff:IMBARedCirtIncomingDamage() return true end
function modifier_item_imba_bloodthorn_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_item_imba_bloodthorn_debuff:GetModifierIncomingDamage_Percentage() return self:GetAbility():GetSpecialValueFor("silence_damage_percent") end
function modifier_item_imba_bloodthorn_debuff:GetEffectName() return "particles/items2_fx/orchid.vpcf" end
function modifier_item_imba_bloodthorn_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_item_imba_bloodthorn_debuff:ShouldUseOverheadOffset() return true end

function modifier_item_imba_bloodthorn_debuff:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() then
		self:SetStackCount(self:GetStackCount() + keys.damage)
	end
end

function modifier_item_imba_bloodthorn_debuff:OnDestroy()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/orchid_pop.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 1, Vector(1,0,0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(1,0,0))
		ParticleManager:ReleaseParticleIndex(pfx)
		local dmg = self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("target_crit_multiplier") / 100)
		ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, self:GetParent(), dmg, nil)
	end
end
