


CreateEmptyTalents("skeleton_king")

imba_wraith_king_wraithfire_blast = class({})

LinkLuaModifier("modifier_imba_wraithfire_blast_slow", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)

function imba_wraith_king_wraithfire_blast:IsHiddenWhenStolen() 	return false end
function imba_wraith_king_wraithfire_blast:IsRefreshable() 			return true end
function imba_wraith_king_wraithfire_blast:IsStealable() 			return true end
function imba_wraith_king_wraithfire_blast:IsNetherWardStealable()	return true end
function imba_wraith_king_wraithfire_blast:GetAOERadius() return self:GetSpecialValueFor("bounce_range") end

function imba_wraith_king_wraithfire_blast:OnSpellStart(passive)
	local caster = self:GetCaster() 
	caster:EmitSound("Hero_SkeletonKing.Hellfire_Blast")
	local bool = passive and 1 or 0
	local target = self:GetCursorTarget()
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
		ExtraData = {main = 1, passive = bool},
	}
	ProjectileManager:CreateTrackingProjectile(info)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_warmup.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
end

function imba_wraith_king_wraithfire_blast:OnProjectileHit_ExtraData(target, location, keys)
	if not target then
		return
	end
	local caster = self:GetCaster()
	if keys.main == 1 and target:TriggerStandardTargetSpell(self) or target:IsMagicImmune() then
		return
	end
	if keys.main == 1 then
		target:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
		if keys.passive ~= 1 then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("bounce_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				local info = 
				{
					Target = enemy,
					Source = target,
					Ability = self,	
					EffectName = "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast.vpcf",
					iMoveSpeed = self:GetSpecialValueFor("speed"),
					vSourceLoc = target:GetAbsOrigin(),
					bDrawsOnMinimap = false,
					bDodgeable = true,
					bIsAttack = false,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					flExpireTime = GameRules:GetGameTime() + 10,
					bProvidesVision = false,	
					ExtraData = {main = 0},
				}
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end
	end
	local damageTable = {
						victim = target,
						attacker = self:GetCaster(),
						damage = self:GetSpecialValueFor("damage"),
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
	target:EmitSound("Hero_SkeletonKing.Hellfire_BlastImpact")
	target:AddNewModifier(caster, self, "modifier_imba_wraithfire_blast_slow", {duration = self:GetSpecialValueFor("slow_duration")})
end

modifier_imba_wraithfire_blast_slow = class({})

function modifier_imba_wraithfire_blast_slow:IsDebuff()				return true end
function modifier_imba_wraithfire_blast_slow:IsHidden() 			return false end
function modifier_imba_wraithfire_blast_slow:IsPurgable() 			return true end
function modifier_imba_wraithfire_blast_slow:IsPurgeException() 	return true end
function modifier_imba_wraithfire_blast_slow:GetEffectName() return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf" end
function modifier_imba_wraithfire_blast_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_wraithfire_blast_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_wraithfire_blast_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("ms_slow")) end

function modifier_imba_wraithfire_blast_slow:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_wraithfire_blast_slow:OnIntervalThink()
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = self:GetAbility():GetSpecialValueFor("damage_per_second"),
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

function modifier_imba_wraithfire_blast_slow:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and not keys.attacker:IsBuilding() and not keys.attacker:IsOther() and not keys.inflictor and not self:GetCaster():PassivesDisabled() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_CUSTOMORIGIN, keys.attacker)
		ParticleManager:SetParticleControlEnt(pfx, 0, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, keys.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.unit:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
		keys.attacker:Heal(keys.damage * (self:GetAbility():GetSpecialValueFor("bonus_lifesteal") / 100), self:GetAbility())
	end
end


imba_wraith_king_vampiric_aura = class({})

LinkLuaModifier("modifier_imba_vampiric_aura", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_vampiric_aura_effect", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)

function imba_wraith_king_vampiric_aura:IsHiddenWhenStolen() 	return false end
function imba_wraith_king_vampiric_aura:IsRefreshable() 		return true end
function imba_wraith_king_vampiric_aura:IsStealable() 			return false end
function imba_wraith_king_vampiric_aura:IsNetherWardStealable()	return false end
function imba_wraith_king_vampiric_aura:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_wraith_king_vampiric_aura:GetIntrinsicModifierName() return "modifier_imba_vampiric_aura" end
function imba_wraith_king_vampiric_aura:OnToggle()
	if self:GetToggleState() then
		self:GetCaster():FindModifierByName("modifier_imba_vampiric_aura"):SetStackCount(1)
	else
		self:GetCaster():FindModifierByName("modifier_imba_vampiric_aura"):SetStackCount(0)
	end
end

modifier_imba_vampiric_aura = class({})

function modifier_imba_vampiric_aura:IsDebuff()				return false end
function modifier_imba_vampiric_aura:IsHidden() 			return true end
function modifier_imba_vampiric_aura:IsPurgable() 			return false end
function modifier_imba_vampiric_aura:IsPurgeException() 	return false end
function modifier_imba_vampiric_aura:IsAura() return true end
function modifier_imba_vampiric_aura:GetAuraDuration() return 0.5 end
function modifier_imba_vampiric_aura:GetModifierAura() return "modifier_imba_vampiric_aura_effect" end
function modifier_imba_vampiric_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_vampiric_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_vampiric_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_vampiric_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_vampiric_aura:GetAuraEntityReject(unit)
	if self:GetStackCount() == 1 and not unit:IsHero() then
		return true
	end
	return false
end

modifier_imba_vampiric_aura_effect = class({})

function modifier_imba_vampiric_aura_effect:IsDebuff()			return false end
function modifier_imba_vampiric_aura_effect:IsHidden() 			return false end
function modifier_imba_vampiric_aura_effect:IsPurgable() 		return false end
function modifier_imba_vampiric_aura_effect:IsPurgeException() 	return false end
function modifier_imba_vampiric_aura_effect:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_vampiric_aura_effect:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not keys.unit:IsBuilding() and not keys.unit:IsOther() and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_CUSTOMORIGIN, keys.attacker)
		ParticleManager:SetParticleControlEnt(pfx, 0, keys.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, keys.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.unit:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
		local steal_pct = self:GetParent() == self:GetCaster() and self:GetAbility():GetSpecialValueFor("lifesteal_self") or self:GetAbility():GetSpecialValueFor("lifesteal_ally")
		keys.attacker:Heal(keys.damage * (steal_pct / 100), self:GetAbility())
	end
end


imba_wraith_king_mortal_strike = class({})

LinkLuaModifier("modifier_imba_mortal_strike", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_mortal_strike_counter", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)

function imba_wraith_king_mortal_strike:GetIntrinsicModifierName() return "modifier_imba_mortal_strike" end

modifier_imba_mortal_strike = class({})

function modifier_imba_mortal_strike:IsDebuff()			return false end
function modifier_imba_mortal_strike:IsHidden() 		return self:GetStackCount() == 0 and true or false end
function modifier_imba_mortal_strike:IsPurgable() 		return false end
function modifier_imba_mortal_strike:IsPurgeException() return false end
function modifier_imba_mortal_strike:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_EVENT_ON_ATTACK_START} end
function modifier_imba_mortal_strike:GetModifierBonusStats_Strength() return self:GetStackCount() end
function modifier_imba_mortal_strike:GetIMBAPhysicalCirtChance() return self.cirt end
function modifier_imba_mortal_strike:GetIMBAPhysicalCirtBonus() return self:GetAbility():GetSpecialValueFor("crit_power") end

function modifier_imba_mortal_strike:OnTriggerIMBAPhyicalCirt(keys)
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_mortal_strike_counter", {duration = self:GetAbility():GetSpecialValueFor("drain_duration")})
	buff:SetStackCount(keys.damage * (self:GetAbility():GetSpecialValueFor("str_drain_pct") / 100))
	if self:GetParent():IsRangedAttacker() then
		self:GetParent():EmitSound("Hero_SkeletonKing.CriticalStrike")
	end
	if not keys.target:IsConsideredHero() and not keys.target:IsOther() and not keys.target:IsBoss() then
		keys.target:Kill(self:GetAbility(), self:GetParent())
	end
end

function modifier_imba_mortal_strike:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and not self:GetParent():IsRangedAttacker() then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("crit_chance")) then
			self.cirt = 100
			self:GetParent():EmitSound("Hero_SkeletonKing.CriticalStrike")
			self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed())
		else
			self.cirt = 0
		end
	end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and self:GetParent():IsRangedAttacker() then
		self.cirt = self:GetAbility():GetSpecialValueFor("crit_chance")
	end
end

function modifier_imba_mortal_strike:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_mortal_strike:OnIntervalThink()
	local buffs = self:GetParent():FindAllModifiersByName("modifier_imba_mortal_strike_counter")
	local stack = 0
	for _, buff in pairs(buffs) do
		stack = stack + buff:GetStackCount()
	end
	if stack ~= self:GetStackCount() then
		self:SetStackCount(stack)
		self:GetParent():CalculateStatBonus()
	end
end

modifier_imba_mortal_strike_counter = class({})

function modifier_imba_mortal_strike_counter:IsDebuff()			return false end
function modifier_imba_mortal_strike_counter:IsHidden() 		return true end
function modifier_imba_mortal_strike_counter:IsPurgable() 		return false end
function modifier_imba_mortal_strike_counter:IsPurgeException() return false end
function modifier_imba_mortal_strike_counter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end


imba_wraith_king_reincarnation = class({})

LinkLuaModifier("modifier_imba_reincarnation", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reincarnation_slow", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reincarnation_ms", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reincarnation_scepter_aura", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reincarnation_scepter_wraith", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reincarnation_scepter_no", "hero/hero_skeleton_king", LUA_MODIFIER_MOTION_NONE)

function imba_wraith_king_reincarnation:GetCastRange() return self:GetSpecialValueFor("slow_radius") - self:GetCaster():GetCastRangeBonus() end
function imba_wraith_king_reincarnation:GetManaCost(i) return self:GetSpecialValueFor("mana_cost") + self:GetCaster():GetTalentValue("special_bonus_imba_skeleton_king_1") end
function imba_wraith_king_reincarnation:GetIntrinsicModifierName() return "modifier_imba_reincarnation" end

modifier_imba_reincarnation = class({})

function modifier_imba_reincarnation:IsDebuff()			return false end
function modifier_imba_reincarnation:IsHidden() 		return true end
function modifier_imba_reincarnation:IsPurgable() 		return false end
function modifier_imba_reincarnation:IsPurgeException() return false end
function modifier_imba_reincarnation:AllowIllusionDuplicate() return false end
function modifier_imba_reincarnation:DeclareFunctions() return {MODIFIER_PROPERTY_REINCARNATION, MODIFIER_EVENT_ON_DEATH, MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_imba_reincarnation:GetActivityTranslationModifiers() return self:GetStackCount() == 1 and "reincarnate" or nil end

function modifier_imba_reincarnation:IsAura() return (not self:GetCaster():IsIllusion() and self:GetCaster():HasScepter()) end
function modifier_imba_reincarnation:IsAuraActiveOnDeath() return true end
function modifier_imba_reincarnation:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("aura_linger") end
function modifier_imba_reincarnation:GetModifierAura() return "modifier_imba_reincarnation_scepter_aura" end
function modifier_imba_reincarnation:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius_scepter") end
function modifier_imba_reincarnation:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end 
function modifier_imba_reincarnation:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_reincarnation:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_reincarnation:GetAuraEntityReject(unit)
	if unit:HasModifier("modifier_imba_reincarnation_scepter_wraith") or unit:GetModifierStackCount("modifier_imba_reincarnation", unit) == 1 or unit:HasModifier("modifier_imba_reincarnation_scepter_no") or unit:HasModifier("modifier_imba_aegis") or unit:GetUnitName() == "npc_dota_unit_undying_zombie_torso" then
		return true
	else
		return false
	end
end

function modifier_imba_reincarnation:OnCreated()
	if IsServer() and not self:GetParent():IsIllusion() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_reincarnation:OnIntervalThink()
	if self:ReincarnateTime() then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

function modifier_imba_reincarnation:ReincarnateTime()
	if IsServer() then
		if self:GetAbility():IsOwnersManaEnough() and self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_imba_aegis") then
			return self:GetAbility():GetSpecialValueFor("reincarnate_delay")
		else
			return nil
		end
	end
end

function modifier_imba_reincarnation:OnDeath(keys)
	if IsServer() then
		if keys.unit == self:GetParent() and self:ReincarnateTime() and not self:GetParent():IsIllusion() then
			local ability = self:GetAbility()
			local radius = self:GetAbility():GetSpecialValueFor("slow_radius")
			local damage = self:GetAbility():GetSpecialValueFor("kingdom_damage")
			local stun = self:GetAbility():GetSpecialValueFor("kingdom_stun")
			local caster = self:GetCaster()
			caster:EmitSound("Hero_SkeletonKing.Reincarnate")
			--caster:EmitSound("Hero_SkeletonKing.Reincarnate.Stinger")
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(pfx, 1, Vector(self:ReincarnateTime(), 0, 0))
			ParticleManager:ReleaseParticleIndex(pfx)
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				enemy:AddNewModifier(caster, ability, "modifier_imba_reincarnation_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
				if caster:HasTalent("special_bonus_imba_skeleton_king_1") and caster:HasAbility("imba_wraith_king_wraithfire_blast") then
					local ab = caster:FindAbilityByName("imba_wraith_king_wraithfire_blast")
					caster:SetCursorCastTarget(enemy)
					ab:OnSpellStart(true)
				end
			end
			ability:UseResources(true, true, true)
			Timers:CreateTimer(ability:GetSpecialValueFor("reincarnate_delay") + FrameTime() * 3, function()
				local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, enemy in pairs(enemies) do
					if (enemy:IsCreep() and not enemy:IsConsideredHero()) or (enemy:IsIllusion() and not enemy:IsTempestDouble() and not enemy:IsClone()) and not enemy:IsBoss() then
						enemy:Kill(ability, caster)
					else
						enemy:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = stun})
						local damageTable = {
											victim = enemy,
											attacker = caster,
											damage = damage,
											damage_type = ability:GetAbilityDamageType(),
											damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
											ability = ability, --Optional.
											}
						ApplyDamage(damageTable)
						local buff = caster:AddNewModifier(caster, ability, "modifier_imba_reincarnation_ms", {duration = ability:GetSpecialValueFor("slow_duration")})
						buff:SetStackCount(buff:GetStackCount() + 1)
					end
				end
				return nil
			end
			)
		end
	end
end

modifier_imba_reincarnation_slow = class({})

function modifier_imba_reincarnation_slow:IsDebuff()			return true end
function modifier_imba_reincarnation_slow:IsHidden() 			return false end
function modifier_imba_reincarnation_slow:IsPurgable() 			return true end
function modifier_imba_reincarnation_slow:IsPurgeException() 	return true end
function modifier_imba_reincarnation_slow:GetEffectName() return "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_slow_debuff.vpcf" end
function modifier_imba_reincarnation_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_reincarnation_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_reincarnation_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_amount")) end

modifier_imba_reincarnation_ms = class({})

function modifier_imba_reincarnation_ms:IsDebuff()			return false end
function modifier_imba_reincarnation_ms:IsHidden() 			return false end
function modifier_imba_reincarnation_ms:IsPurgable() 		return true end
function modifier_imba_reincarnation_ms:IsPurgeException() 	return true end
function modifier_imba_reincarnation_ms:GetEffectName() return "particles/units/heroes/hero_skeletonking/wraith_king_reincarnate_slow_debuff.vpcf" end
function modifier_imba_reincarnation_ms:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_reincarnation_ms:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_reincarnation_ms:GetModifierMoveSpeedBonus_Percentage() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("kingdom_ms")) end


modifier_imba_reincarnation_scepter_aura = class({})

function modifier_imba_reincarnation_scepter_aura:IsDebuff()			return false end
function modifier_imba_reincarnation_scepter_aura:IsHidden() 			return false end
function modifier_imba_reincarnation_scepter_aura:IsPurgable() 			return false end
function modifier_imba_reincarnation_scepter_aura:IsPurgeException() 	return false end
function modifier_imba_reincarnation_scepter_aura:DeclareFunctions() return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_MODEL_SCALE} end
function modifier_imba_reincarnation_scepter_aura:GetModifierModelScale() return 1.5 end
function modifier_imba_reincarnation_scepter_aura:GetMinHealth() return 1 end

function modifier_imba_reincarnation_scepter_aura:OnCreated()
	if IsServer() then
		self.hp = self:GetParent():GetHealth()
	end
end

function modifier_imba_reincarnation_scepter_aura:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and self.hp <= keys.damage then
		if self:GetParent():IsRealHero() then
			self:GetParent():EmitSound("Hero_SkeletonKing.Reincarnate.Ghost")
		end
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_reincarnation_scepter_wraith", {duration = self:GetAbility():GetSpecialValueFor("wraith_duration_scepter"), attacker = keys.attacker:entindex()})
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_reincarnation_scepter_no", {duration = self:GetAbility():GetSpecialValueFor("wraith_duration_scepter") + FrameTime()})
	else
		self.hp = self:GetParent():GetHealth()
	end
end

function modifier_imba_reincarnation_scepter_aura:OnDestroy()
	if IsServer() then
		self.hp = nil
	end
end

modifier_imba_reincarnation_scepter_no = class({})

function modifier_imba_reincarnation_scepter_no:IsDebuff()			return false end
function modifier_imba_reincarnation_scepter_no:IsHidden() 			return true end
function modifier_imba_reincarnation_scepter_no:IsPurgable() 		return false end
function modifier_imba_reincarnation_scepter_no:IsPurgeException() 	return false end
function modifier_imba_reincarnation_scepter_no:RemoveOnDeath() 	return false end

modifier_imba_reincarnation_scepter_wraith = class({})

function modifier_imba_reincarnation_scepter_wraith:IsDebuff()			return false end
function modifier_imba_reincarnation_scepter_wraith:IsHidden() 			return false end
function modifier_imba_reincarnation_scepter_wraith:IsPurgable() 		return false end
function modifier_imba_reincarnation_scepter_wraith:IsPurgeException() 	return false end
function modifier_imba_reincarnation_scepter_wraith:GetStatusEffectName() return "particles/status_fx/status_effect_wraithking_ghosts.vpcf" end
function modifier_imba_reincarnation_scepter_wraith:StatusEffectPriority() return 16 end
function modifier_imba_reincarnation_scepter_wraith:CheckState() return {[MODIFIER_STATE_NO_HEALTH_BAR]= true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_reincarnation_scepter_wraith:DeclareFunctions() return {MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_reincarnation_scepter_wraith:GetMinHealth() return 1 end

function modifier_imba_reincarnation_scepter_wraith:OnCreated(keys)
	if IsServer() then
		self.attacker = EntIndexToHScript(keys.attacker)
		self:SetStackCount(self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("wraith_health_pct_scepter") / 100))
	end
end

function modifier_imba_reincarnation_scepter_wraith:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() then
		self:SetStackCount(math.max(0, self:GetStackCount() - math.floor(keys.damage)))
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function modifier_imba_reincarnation_scepter_wraith:OnDestroy()
	if IsServer() then
		TrueKill(self.attacker, self:GetParent(), self:GetAbility())
		self.attacker = nil
	end
end