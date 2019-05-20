modifier_imba_rune_doubledamage = class({})

function modifier_imba_rune_doubledamage:IsDebuff()				return false end
function modifier_imba_rune_doubledamage:IsHidden() 			return false end
function modifier_imba_rune_doubledamage:IsPurgable() 			return false end
function modifier_imba_rune_doubledamage:IsPurgeException() 	return false end
function modifier_imba_rune_doubledamage:GetTexture() return "rune_doubledamage" end
function modifier_imba_rune_doubledamage:GetEffectName() return "particles/generic_gameplay/rune_doubledamage_owner.vpcf" end
function modifier_imba_rune_doubledamage:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_doubledamage:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_rune_doubledamage:GetModifierBaseDamageOutgoing_Percentage() return 100 end

function modifier_imba_rune_doubledamage:IsAura() return true end
function modifier_imba_rune_doubledamage:GetAuraDuration() return 0.1 end
function modifier_imba_rune_doubledamage:GetModifierAura() return "modifier_imba_rune_doubledamage_ally" end
function modifier_imba_rune_doubledamage:GetAuraRadius() return 900 end
function modifier_imba_rune_doubledamage:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_rune_doubledamage:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_rune_doubledamage:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_rune_doubledamage:GetAuraEntityReject(unit)
	if unit == self:GetParent() then
		return true
	end
	return false
end

modifier_imba_rune_doubledamage_ally = class({})

function modifier_imba_rune_doubledamage_ally:IsDebuff()			return false end
function modifier_imba_rune_doubledamage_ally:IsHidden() 			return false end
function modifier_imba_rune_doubledamage_ally:IsPurgable() 			return false end
function modifier_imba_rune_doubledamage_ally:IsPurgeException() 	return false end
function modifier_imba_rune_doubledamage_ally:GetTexture() return "rune_doubledamage" end
function modifier_imba_rune_doubledamage_ally:GetEffectName() return "particles/generic_gameplay/rune_doubledamage_owner.vpcf" end
function modifier_imba_rune_doubledamage_ally:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_doubledamage_ally:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_rune_doubledamage_ally:GetModifierBaseDamageOutgoing_Percentage() return 50 end

modifier_imba_rune_haste = class({})

function modifier_imba_rune_haste:IsDebuff()			return false end
function modifier_imba_rune_haste:IsHidden() 			return false end
function modifier_imba_rune_haste:IsPurgable() 			return false end
function modifier_imba_rune_haste:IsPurgeException() 	return false end
function modifier_imba_rune_haste:GetTexture() return "rune_haste" end
function modifier_imba_rune_haste:GetEffectName() return "particles/generic_gameplay/rune_haste_owner.vpcf" end
function modifier_imba_rune_haste:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_haste:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_rune_haste:GetIMBAMaxMovespeed() return 10000 end
function modifier_imba_rune_haste:GetModifierMoveSpeedBonus_Percentage() return 70 end
function modifier_imba_rune_haste:GetModifierAttackSpeedBonus_Constant() return 70 end

function modifier_imba_rune_haste:IsAura() return true end
function modifier_imba_rune_haste:GetAuraDuration() return 0.1 end
function modifier_imba_rune_haste:GetModifierAura() return "modifier_imba_rune_haste_ally" end
function modifier_imba_rune_haste:GetAuraRadius() return 900 end
function modifier_imba_rune_haste:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_rune_haste:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_rune_haste:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_rune_haste:GetAuraEntityReject(unit)
	if unit == self:GetParent() then
		return true
	end
	return false
end

modifier_imba_rune_haste_ally = class({})

function modifier_imba_rune_haste_ally:IsDebuff()			return false end
function modifier_imba_rune_haste_ally:IsHidden() 			return false end
function modifier_imba_rune_haste_ally:IsPurgable() 		return false end
function modifier_imba_rune_haste_ally:IsPurgeException() 	return false end
function modifier_imba_rune_haste_ally:GetTexture() return "rune_haste" end
function modifier_imba_rune_haste_ally:GetEffectName() return "particles/generic_gameplay/rune_haste_owner.vpcf" end
function modifier_imba_rune_haste_ally:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_haste_ally:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_rune_haste_ally:GetModifierMoveSpeedBonus_Percentage() return 35 end
function modifier_imba_rune_haste_ally:GetModifierAttackSpeedBonus_Constant() return 35 end

modifier_imba_rune_invisibility = class({})

function modifier_imba_rune_invisibility:IsDebuff()				return false end
function modifier_imba_rune_invisibility:IsHidden() 			return false end
function modifier_imba_rune_invisibility:IsPurgable() 			return false end
function modifier_imba_rune_invisibility:IsPurgeException() 	return false end
function modifier_imba_rune_invisibility:GetTexture() return "rune_invis" end
function modifier_imba_rune_invisibility:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_rune_invisibility:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_DISABLE_AUTOATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE} end
function modifier_imba_rune_invisibility:GetDisableAutoAttack() return true end
function modifier_imba_rune_invisibility:GetModifierInvisibilityLevel() return 1 end
function modifier_imba_rune_invisibility:GetModifierPercentageCasttime() return 100 end

function modifier_imba_rune_invisibility:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/rune_invisibility.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_rune_invisibility:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and self:GetParent():IsRangedAttacker() then
		self:Destroy()
	end
end

function modifier_imba_rune_invisibility:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():IsRangedAttacker() then
		self:Destroy()
	end
end

modifier_imba_rune_regeneration = class({})

function modifier_imba_rune_regeneration:IsDebuff()				return false end
function modifier_imba_rune_regeneration:IsHidden() 			return false end
function modifier_imba_rune_regeneration:IsPurgable() 			return false end
function modifier_imba_rune_regeneration:IsPurgeException() 	return false end
function modifier_imba_rune_regeneration:GetTexture() return "rune_regen" end
function modifier_imba_rune_regeneration:GetEffectName() return "particles/generic_gameplay/rune_regen_owner.vpcf" end
function modifier_imba_rune_regeneration:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_regeneration:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_rune_regeneration:GetModifierTotalPercentageManaRegen() return 5 end
function modifier_imba_rune_regeneration:GetModifierHealthRegenPercentage() return 5 end
function modifier_imba_rune_regeneration:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if IsEnemy(keys.attacker, self:GetParent()) and keys.unit == self:GetParent() and (keys.attacker:IsRealHero() or keys.attacker:IsBoss()) then
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function modifier_imba_rune_regeneration:IsAura() return true end
function modifier_imba_rune_regeneration:GetAuraDuration() return 0.1 end
function modifier_imba_rune_regeneration:GetModifierAura() return "modifier_imba_rune_regeneration_ally" end
function modifier_imba_rune_regeneration:GetAuraRadius() return 900 end
function modifier_imba_rune_regeneration:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_rune_regeneration:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_rune_regeneration:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_rune_regeneration:GetAuraEntityReject(unit)
	if unit == self:GetParent() then
		return true
	end
	return false
end

modifier_imba_rune_regeneration_ally = class({})

function modifier_imba_rune_regeneration_ally:IsDebuff()			return false end
function modifier_imba_rune_regeneration_ally:IsHidden() 			return false end
function modifier_imba_rune_regeneration_ally:IsPurgable() 			return false end
function modifier_imba_rune_regeneration_ally:IsPurgeException() 	return false end
function modifier_imba_rune_regeneration_ally:GetTexture() return "rune_regen" end
function modifier_imba_rune_regeneration_ally:GetEffectName() return "particles/generic_gameplay/rune_regen_owner.vpcf" end
function modifier_imba_rune_regeneration_ally:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_regeneration_ally:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE, MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE} end
function modifier_imba_rune_regeneration_ally:GetModifierTotalPercentageManaRegen() return 2.5 end
function modifier_imba_rune_regeneration_ally:GetModifierHealthRegenPercentage() return 2.5 end

modifier_imba_rune_arcane = class({})

function modifier_imba_rune_arcane:IsDebuff()			return false end
function modifier_imba_rune_arcane:IsHidden() 			return false end
function modifier_imba_rune_arcane:IsPurgable() 		return false end
function modifier_imba_rune_arcane:IsPurgeException() 	return false end
function modifier_imba_rune_arcane:GetTexture() return "rune_arcane" end
function modifier_imba_rune_arcane:GetEffectName() return "particles/generic_gameplay/rune_arcane_owner.vpcf" end
function modifier_imba_rune_arcane:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_arcane:DeclareFunctions() return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_imba_rune_arcane:GetModifierPercentageCooldown() return 40 end
function modifier_imba_rune_arcane:GetModifierPercentageManacostStacking() return 40 end
function modifier_imba_rune_arcane:GetModifierSpellAmplify_Percentage() return 40 end

function modifier_imba_rune_arcane:IsAura() return true end
function modifier_imba_rune_arcane:GetAuraDuration() return 0.1 end
function modifier_imba_rune_arcane:GetModifierAura() return "modifier_imba_rune_arcane_ally" end
function modifier_imba_rune_arcane:GetAuraRadius() return 900 end
function modifier_imba_rune_arcane:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_rune_arcane:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_rune_arcane:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_rune_arcane:GetAuraEntityReject(unit)
	if unit == self:GetParent() then
		return true
	end
	return false
end

modifier_imba_rune_arcane_ally = class({})

function modifier_imba_rune_arcane_ally:IsDebuff()			return false end
function modifier_imba_rune_arcane_ally:IsHidden() 			return false end
function modifier_imba_rune_arcane_ally:IsPurgable() 		return false end
function modifier_imba_rune_arcane_ally:IsPurgeException() 	return false end
function modifier_imba_rune_arcane_ally:GetTexture() return "rune_arcane" end
function modifier_imba_rune_arcane_ally:GetEffectName() return "particles/generic_gameplay/rune_arcane_owner.vpcf" end
function modifier_imba_rune_arcane_ally:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rune_arcane_ally:DeclareFunctions() return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_imba_rune_arcane_ally:GetModifierPercentageCooldown() return 20 end
function modifier_imba_rune_arcane_ally:GetModifierPercentageManacostStacking() return 20 end
function modifier_imba_rune_arcane_ally:GetModifierSpellAmplify_Percentage() return 20 end

modifier_imba_rune_bounty = class({})

function modifier_imba_rune_bounty:IsDebuff()			return false end
function modifier_imba_rune_bounty:IsHidden() 			return false end
function modifier_imba_rune_bounty:IsPurgable() 		return false end
function modifier_imba_rune_bounty:IsPurgeException() 	return false end
function modifier_imba_rune_bounty:GetTexture() return "imba_rune_bounty" end
function modifier_imba_rune_bounty:GetIMBAGoldPercentage() return 30 end
function modifier_imba_rune_bounty:GetEffectName() return "particles/generic_gameplay/rune_bounty_prespawn.vpcf" end
function modifier_imba_rune_bounty:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_imba_rune_illusion = class({})

function modifier_imba_rune_illusion:IsDebuff()			return false end
function modifier_imba_rune_illusion:IsHidden() 		return true end
function modifier_imba_rune_illusion:IsPurgable() 		return false end
function modifier_imba_rune_illusion:IsPurgeException() return false end
function modifier_imba_rune_illusion:CheckState() return {[MODIFIER_STATE_NOT_ON_MINIMAP] = true} end

function modifier_imba_rune_illusion:OnDestroy()
	if IsServer() then
		self:GetParent():SetForceAttackTarget(nil)
	end
end