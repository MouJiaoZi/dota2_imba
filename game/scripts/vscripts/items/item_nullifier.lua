item_imba_nullifier_2 = class({})

LinkLuaModifier("modifier_imba_nullifier_2", "items/item_imba_nullifier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nullifier_aura", "items/item_imba_nullifier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nullifier_debuff", "items/item_imba_nullifier.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nullifier_slow", "items/item_imba_nullifier.lua", LUA_MODIFIER_MOTION_NONE)

function item_imba_nullifier_2:GetIntrinsicModifierName() return "modifier_imba_nullifier_2" end

function item_imba_nullifier_2:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		SourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		EffectName = "particles/item/nullifier/nullifier_proj.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		vSourceLoc= caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 30,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
	caster:EmitSound("DOTA_Item.Nullifier.Cast")
end

function item_imba_nullifier_2:OnProjectileHit(target, pos)
	if not target or target:IsMagicImmune() or target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("DOTA_Item.Nullifier.Target")
	target:Purge(true, false, false, false, true)
	local duration = self:GetSpecialValueFor("debuff_duration") + self:GetCurrentCharges() * self:GetSpecialValueFor("bonus_duration")
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_nullifier_debuff", {duration = duration})
end

modifier_imba_nullifier_2 = class({})

function modifier_imba_nullifier_2:IsDebuff()			return false end
function modifier_imba_nullifier_2:IsHidden() 			return true end
function modifier_imba_nullifier_2:IsPurgable() 		return false end
function modifier_imba_nullifier_2:IsPurgeException() 	return false end
function modifier_imba_nullifier_2:RemoveOnDeath()		return self:GetParent():IsIllusion() end
function modifier_imba_nullifier_2:GetAttributes() 		return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_nullifier_2:DeclareFunctions() 	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_nullifier_2:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_nullifier_2:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_nullifier_2:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_health") end
function modifier_imba_nullifier_2:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_imba_nullifier_2:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end
function modifier_imba_nullifier_2:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_hp_regen") end

function modifier_imba_nullifier_2:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and not keys.reincarnate then
		self:GetAbility():SetCurrentCharges(math.max(self:GetAbility():GetCurrentCharges() - self:GetAbility():GetCurrentCharges() * (self:GetAbility():GetSpecialValueFor("death_charge") / 100), 0))
	end
end

function modifier_imba_nullifier_2:IsAura() return true end
function modifier_imba_nullifier_2:GetAuraDuration() return 0.1 end
function modifier_imba_nullifier_2:GetModifierAura() return "modifier_imba_nullifier_aura" end
function modifier_imba_nullifier_2:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("death_range") end
function modifier_imba_nullifier_2:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_nullifier_2:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_nullifier_2:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_nullifier_aura = class({})

function modifier_imba_nullifier_aura:IsDebuff()			return true end
function modifier_imba_nullifier_aura:IsHidden() 			return true end
function modifier_imba_nullifier_aura:IsPurgable() 			return false end
function modifier_imba_nullifier_aura:IsPurgeException() 	return false end
function modifier_imba_nullifier_aura:DeclareFunctions()	return {MODIFIER_EVENT_ON_DEATH} end

function modifier_imba_nullifier_aura:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and not keys.reincarnate and self:GetAbility() then
		self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + self:GetAbility():GetSpecialValueFor("kill_charge"))
	end
end

modifier_imba_nullifier_debuff = class({})

function modifier_imba_nullifier_debuff:IsDebuff()			return true end
function modifier_imba_nullifier_debuff:IsHidden() 			return false end
function modifier_imba_nullifier_debuff:IsPurgable() 		return true end
function modifier_imba_nullifier_debuff:IsPurgeException() 	return true end
function modifier_imba_nullifier_debuff:ShouldUseOverheadOffset() return true end
function modifier_imba_nullifier_debuff:GetEffectName() return "particles/item/nullifier/nullifier_mute.vpcf" end
function modifier_imba_nullifier_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_nullifier_debuff:CheckState() return {[MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_BLOCK_DISABLED] = true, [MODIFIER_STATE_EVADE_DISABLED] = true} end
function modifier_imba_nullifier_debuff:DeclareFunctions()	return {MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_nullifier_debuff:GetModifierHPRegenAmplify_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("active_heal_pct")) end

function modifier_imba_nullifier_debuff:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/item/nullifier/nullifier_mute_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local pfx_ring = ParticleManager:CreateParticle("particles/items4_fx/spirit_vessel_damage_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local pfx_smoke = ParticleManager:CreateParticle("particles/items4_fx/spirit_vessel_damage_spirit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, 15, false, false)
		self:AddParticle(pfx_ring, false, false, 15, false, false)
		self:AddParticle(pfx_smoke, false, false, 15, false, false)
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_nullifier_debuff:OnIntervalThink()
	local dmg = self:GetParent():GetHealth() * (self:GetAbility():GetSpecialValueFor("damage_pct") / 100)
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = dmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility(), damage_flags = DOTA_DAMAGE_FLAG_HPLOSS})
end

function modifier_imba_nullifier_debuff:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.target == self:GetParent() then
		self:GetParent():EmitSound("DOTA_Item.Nullifier.Slow")
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_nullifier_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
		self:GetParent():Purge(true, false, false, false, true)
	end
end

function modifier_imba_nullifier_debuff:OnDeath(keys)
	if IsServer() and keys.unit == self:GetParent() and not keys.reincarnate and self:GetAbility() then
		self:GetAbility():SetCurrentCharges(self:GetAbility():GetCurrentCharges() + self:GetAbility():GetSpecialValueFor("kill_charge"))
	end
end

modifier_imba_nullifier_slow = class({})

function modifier_imba_nullifier_slow:IsDebuff()			return true end
function modifier_imba_nullifier_slow:IsHidden() 			return false end
function modifier_imba_nullifier_slow:IsPurgable() 			return true end
function modifier_imba_nullifier_slow:IsPurgeException() 	return true end
function modifier_imba_nullifier_slow:DeclareFunctions()	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_nullifier_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_ms")) end
function modifier_imba_nullifier_slow:GetEffectName() return "particles/item/nullifier/nullifier_slow.vpcf" end
function modifier_imba_nullifier_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end