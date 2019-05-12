item_imba_blade_mail_2 = class({})

LinkLuaModifier("modifier_imba_balde_mail_2", "items/item_blade_mail", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_balde_mail_2_active", "items/item_blade_mail", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_balde_mail_2_debuff", "items/item_blade_mail", LUA_MODIFIER_MOTION_NONE)

function item_imba_blade_mail_2:GetIntrinsicModifierName() return "modifier_imba_balde_mail_2" end

function item_imba_blade_mail_2:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.BladeMail.Activate")
	caster:AddNewModifier(caster, self, "modifier_imba_balde_mail_2_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_balde_mail_2 = class({})

function modifier_imba_balde_mail_2:IsDebuff()			return false end
function modifier_imba_balde_mail_2:IsHidden() 			return true end
function modifier_imba_balde_mail_2:IsPurgable() 		return false end
function modifier_imba_balde_mail_2:IsPurgeException() 	return false end
function modifier_imba_balde_mail_2:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_balde_mail_2:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_balde_mail_2:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_balde_mail_2:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_balde_mail_2:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_intellect") end
function modifier_imba_balde_mail_2:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agility") end
function modifier_imba_balde_mail_2:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end

modifier_imba_balde_mail_2_active = class({})

function modifier_imba_balde_mail_2_active:IsDebuff()			return false end
function modifier_imba_balde_mail_2_active:IsHidden() 			return false end
function modifier_imba_balde_mail_2_active:IsPurgable() 		return false end
function modifier_imba_balde_mail_2_active:IsPurgeException() 	return false end
function modifier_imba_balde_mail_2_active:GetEffectName() return "particles/item/blademail/blademail2.vpcf" end
function modifier_imba_balde_mail_2_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_balde_mail_2_active:GetStatusEffectName() return "particles/item/blademail/status_effect_blademail2.vpcf" end
function modifier_imba_balde_mail_2_active:StatusEffectPriority() return 20 end
function modifier_imba_balde_mail_2_active:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_balde_mail_2_active:OnCreated()
	if IsClient() then
		local pfx = ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_balde_mail_2_active:OnDestroy()
	EmitSoundOn("DOTA_Item.BladeMail.Deactivate", self:GetParent())
end

function modifier_imba_balde_mail_2_active:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
		return
	end
	if keys.unit ~= self:GetParent() or not keys.attacker:IsUnit() or not self:GetParent():IsAlive() then
		return
	end
	local caster = self:GetCaster()
	local attacker = keys.attacker
	local ability = self:GetAbility()
	local damage_origin = keys.original_damage * (ability:GetSpecialValueFor("origin_pct") / 100)
	local damage_taken = keys.damage
	local bIsAttack = keys.inflictor
	local damage = math.max(damage_origin, damage_taken)
	ApplyDamage({victim = attacker, attacker = caster, damage = damage, ability = ability, damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION})
	attacker:EmitSound("DOTA_Item.BladeMail.Damage")
end

--particles/econ/items/batrider/batrider_ti8_immortal_mount/batrider_ti8_immortal_firefly.vpcf