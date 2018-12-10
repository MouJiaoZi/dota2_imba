



CreateEmptyTalents("sven")



imba_sven_storm_bolt = class({})

LinkLuaModifier("modifier_imba_storm_bolt_caster", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE)

function imba_sven_storm_bolt:IsHiddenWhenStolen() 		return false end
function imba_sven_storm_bolt:IsRefreshable() 			return true end
function imba_sven_storm_bolt:IsStealable() 			return true end
function imba_sven_storm_bolt:IsNetherWardStealable()	return true end
function imba_sven_storm_bolt:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_sven_storm_bolt:GetCooldown(i) return self:GetSpecialValueFor("cooldown") + self:GetCaster():GetTalentValue("special_bonus_imba_sven_2") end

function imba_sven_storm_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:EmitSound("Hero_Sven.StormBolt")
	caster:AddNewModifier(caster, self, "modifier_imba_storm_bolt_caster", {})
	local pfxname = caster:HasModifier("modifier_imba_god_strength") and "particles/hero/sven/sven_ult_storm_bolt.vpcf" or "particles/units/heroes/hero_sven/sven_spell_storm_bolt.vpcf"
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = pfxname,
		iMoveSpeed = self:GetSpecialValueFor("speed"),
		vSourceLoc = caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_sven_storm_bolt:OnProjectileHit(target, location)
	local hTarget = target or self:GetCaster()
	hTarget:EmitSound("Hero_Sven.StormBoltImpact")
	if hTarget ~= self:GetCaster() then
		if hTarget:TriggerStandardTargetSpell(self) or hTarget:IsMagicImmune() then
			self:GetCaster():RemoveModifierByName("modifier_imba_storm_bolt_caster")
			return
		end
		local radius = self:GetSpecialValueFor("radius")
		local dmg = self:GetSpecialValueFor("damage")
		local buff = self:GetCaster():FindModifierByName("modifier_imba_god_strength")
		if buff then
			local ability = buff:GetAbility()
			radius = radius + ability:GetSpecialValueFor("storm_bolt_radius")
			dmg = dmg + ability:GetSpecialValueFor("storm_bolt_damage")
		end
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), hTarget:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("duration")})
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = dmg,
								damage_type = self:GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self, --Optional.
								}
			ApplyDamage(damageTable)
		end
	end
	FindClearSpaceForUnit(self:GetCaster(), hTarget:GetAbsOrigin(), true)
	self:GetCaster():RemoveModifierByName("modifier_imba_storm_bolt_caster")
	self:GetCaster():SetAttacking(hTarget)
end

modifier_imba_storm_bolt_caster = class({})

function modifier_imba_storm_bolt_caster:IsDebuff()			return false end
function modifier_imba_storm_bolt_caster:IsHidden() 		return true end
function modifier_imba_storm_bolt_caster:IsPurgable() 		return false end
function modifier_imba_storm_bolt_caster:IsPurgeException() return false end
function modifier_imba_storm_bolt_caster:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_UNSELECTABLE] = true} end

function modifier_imba_storm_bolt_caster:OnCreated()
	if IsServer() then
		self:GetParent():AddNoDraw()
	end
end

function modifier_imba_storm_bolt_caster:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveNoDraw()
	end
end


imba_sven_great_cleave = class({})

LinkLuaModifier("modifier_imba_great_cleave_passive", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_great_cleave_active", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_great_cleave_stack", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE)

function imba_sven_great_cleave:IsHiddenWhenStolen() 	return false end
function imba_sven_great_cleave:IsRefreshable() 		return true end
function imba_sven_great_cleave:IsStealable() 			return true end
function imba_sven_great_cleave:IsNetherWardStealable()	return true end
function imba_sven_great_cleave:GetIntrinsicModifierName() return "modifier_imba_great_cleave_passive" end

function imba_sven_great_cleave:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_great_cleave_active", {duration = self:GetSpecialValueFor("active_duration")})
	self:GetCaster():EmitSound("Imba.SvenGreatCleave")
end

modifier_imba_great_cleave_passive = class({})

function modifier_imba_great_cleave_passive:IsDebuff()			return false end
function modifier_imba_great_cleave_passive:IsHidden() 			return true end
function modifier_imba_great_cleave_passive:IsPurgable() 		return false end
function modifier_imba_great_cleave_passive:IsPurgeException() 	return false end
function modifier_imba_great_cleave_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_great_cleave_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or self:GetParent():PassivesDisabled() or not keys.target:IsAlive() then
		return
	end
	if not keys.attacker:HasModifier("modifier_imba_great_cleave_active") then
		local dmg = keys.damage * (self:GetAbility():GetSpecialValueFor("cleave_pct") / 100)
		DoCleaveAttack(self:GetParent(), keys.target, self:GetAbility(), dmg, self:GetAbility():GetSpecialValueFor("cleave_starting_width"), self:GetAbility():GetSpecialValueFor("cleave_ending_width"), self:GetAbility():GetSpecialValueFor("cleave_distance"), "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")
	else
		local buff = keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_great_cleave_stack", {duration = self:GetAbility():GetSpecialValueFor("stack_duration")})
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
end

modifier_imba_great_cleave_active = class({})

function modifier_imba_great_cleave_active:IsDebuff()			return false end
function modifier_imba_great_cleave_active:IsHidden() 			return false end
function modifier_imba_great_cleave_active:IsPurgable() 		return false end
function modifier_imba_great_cleave_active:IsPurgeException() 	return false end

modifier_imba_great_cleave_stack = class({})

function modifier_imba_great_cleave_stack:IsDebuff()			return true end
function modifier_imba_great_cleave_stack:IsHidden() 			return false end
function modifier_imba_great_cleave_stack:IsPurgable() 			return false end
function modifier_imba_great_cleave_stack:IsPurgeException() 	return false end
function modifier_imba_great_cleave_stack:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_imba_great_cleave_stack:GetModifierIncomingDamage_Percentage() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_stack")) end


imba_sven_warcry = class({})

LinkLuaModifier("modifier_imba_warcry_active", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE)

function imba_sven_warcry:IsHiddenWhenStolen() 		return false end
function imba_sven_warcry:IsRefreshable() 			return true end
function imba_sven_warcry:IsStealable() 			return true end
function imba_sven_warcry:IsNetherWardStealable()	return true end
function imba_sven_warcry:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_sven_warcry:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Sven.WarCry")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	--ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
	caster:Purge(false, true, false, true, true)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		local buff = ally:AddNewModifier(caster, self, "modifier_imba_warcry_active", {duration = self:GetSpecialValueFor("duration")})
		if not ally:IsCreep() then
			ally:CalculateStatBonus()
		end
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_warcry_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		--ParticleManager:SetParticleControlEnt(pfx, 0, ally, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
		--ParticleManager:SetParticleControlEnt(pfx, 1, ally, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
		buff:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_imba_warcry_active = class({})

function modifier_imba_warcry_active:IsDebuff()			return false end
function modifier_imba_warcry_active:IsHidden() 		return false end
function modifier_imba_warcry_active:IsPurgable() 		return true end
function modifier_imba_warcry_active:IsPurgeException() return true end
function modifier_imba_warcry_active:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_warcry_active:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("active_ms") end
function modifier_imba_warcry_active:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_warcry_active:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_str") end
function modifier_imba_warcry_active:OnCreated()
	if IsServer() then
		
	end
end


imba_sven_gods_strength = class({})

LinkLuaModifier("modifier_imba_god_strength", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_god_strength_allies", "hero/hero_sven", LUA_MODIFIER_MOTION_NONE)

function imba_sven_gods_strength:IsHiddenWhenStolen() 		return false end
function imba_sven_gods_strength:IsRefreshable() 			return true end
function imba_sven_gods_strength:IsStealable() 				return true end
function imba_sven_gods_strength:IsNetherWardStealable()	return true end

function imba_sven_gods_strength:OnSpellStart()
	local caster = self:GetCaster()
	if RollPercentage(30) then
		caster:EmitSound("Imba.SvenBeAMan")
	end
	caster:EmitSound("Hero_Sven.GodsStrength")
	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_3)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local buff = caster:AddNewModifier(caster, self, "modifier_imba_god_strength", {duration = self:GetSpecialValueFor("duration")})
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetAbsOrigin(), true)
	buff:AddParticle(pfx, false, false, 15, false, false)
end

modifier_imba_god_strength = class({})

function modifier_imba_god_strength:IsDebuff()			return false end
function modifier_imba_god_strength:IsHidden() 			return false end
function modifier_imba_god_strength:IsPurgable() 		return false end
function modifier_imba_god_strength:IsPurgeException() 	return false end
function modifier_imba_god_strength:GetStatusEffectName() return "particles/status_fx/status_effect_gods_strength.vpcf" end
function modifier_imba_god_strength:StatusEffectPriority() return 16 end
function modifier_imba_god_strength:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_god_strength:GetModifierBaseDamageOutgoing_Percentage() return self:GetAbility():GetSpecialValueFor("self_damage_bonus") end

function modifier_imba_god_strength:IsAura() return true end
function modifier_imba_god_strength:GetAuraDuration() return 0.1 end
function modifier_imba_god_strength:GetModifierAura() return "modifier_imba_god_strength_allies" end
function modifier_imba_god_strength:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_god_strength:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_god_strength:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_god_strength:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_god_strength:GetAuraEntityReject(unit)
	if unit == self:GetCaster() then
		return true
	end
	return false
end

modifier_imba_god_strength_allies = class({})

function modifier_imba_god_strength_allies:IsDebuff()			return false end
function modifier_imba_god_strength_allies:IsHidden() 			return false end
function modifier_imba_god_strength_allies:IsPurgable() 		return false end
function modifier_imba_god_strength_allies:IsPurgeException() 	return false end
function modifier_imba_god_strength_allies:GetStatusEffectName() return "particles/status_fx/status_effect_gods_strength.vpcf" end
function modifier_imba_god_strength_allies:StatusEffectPriority() return 16 end
function modifier_imba_god_strength_allies:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_god_strength_allies:GetModifierBaseDamageOutgoing_Percentage() return self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("ally_damage_bonus_scepter") or self:GetAbility():GetSpecialValueFor("ally_damage_bonus") end
function modifier_imba_god_strength_allies:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or self:GetParent():PassivesDisabled() or not self:GetCaster():HasScepter() or not keys.target:IsAlive() then
		return
	end
	local dmg = keys.damage * (self:GetAbility():GetSpecialValueFor("ally_cleave_pct_scepter") / 100)
	DoCleaveAttack(self:GetParent(), keys.target, self:GetAbility(), dmg, self:GetAbility():GetSpecialValueFor("ally_cleave_radius_scepter"), self:GetAbility():GetSpecialValueFor("ally_cleave_radius_scepter"), self:GetAbility():GetSpecialValueFor("ally_cleave_radius_scepter"), "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf")
end


function modifier_special_bonus_imba_sven_1:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_special_bonus_imba_sven_1:OnAttackLanded(keys)
	if IsServer() then
		if self:GetParent():FindAbilityByName("imba_sven_gods_strength") and keys.attacker == self:GetParent() and keys.target:IsAlive() then
			local ability = self:GetParent():FindAbilityByName("imba_sven_gods_strength")
			if not ability:IsCooldownReady() then
				ability_cd = ability:GetCooldownTimeRemaining()
				ability:EndCooldown()
				if ability_cd > self:GetParent():GetTalentValue("special_bonus_imba_sven_1") then
					ability:StartCooldown(ability_cd - self:GetParent():GetTalentValue("special_bonus_imba_sven_1"))
				end
			end
		end
	end
end