CreateEmptyTalents("night_stalker")

imba_night_stalker_void = class({})

LinkLuaModifier("modifier_imba_void", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_void_day", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)

function imba_night_stalker_void:IsHiddenWhenStolen() 		return false end
function imba_night_stalker_void:IsRefreshable() 			return true end
function imba_night_stalker_void:IsStealable() 				return true end
function imba_night_stalker_void:IsNetherWardStealable()	return true end
function imba_night_stalker_void:GetIntrinsicModifierName() return "modifier_imba_void_day" end

function imba_night_stalker_void:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("Hero_Nightstalker.Void")
	target:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = 0.1})
	local duration = GameRules:IsDaytime() and self:GetSpecialValueFor("duration_day") or self:GetSpecialValueFor("duration_night")
	target:AddNewModifier(caster, self, "modifier_imba_void", {duration = duration})
	local damageTable = {
						victim =target,
						attacker = self:GetCaster(),
						damage = self:GetSpecialValueFor("damage"),
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
end

modifier_imba_void_day = class({})  -- use this to know day and night

function modifier_imba_void_day:IsDebuff()			return false end
function modifier_imba_void_day:IsHidden() 			return true end
function modifier_imba_void_day:IsPurgable() 		return false end
function modifier_imba_void_day:IsPurgeException() 	return false end
function modifier_imba_void_day:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end
function modifier_imba_void_day:OnIntervalThink()
	if GameRules:IsDaytime() then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

modifier_imba_void = class({})

function modifier_imba_void:IsDebuff()			return true end
function modifier_imba_void:IsHidden() 			return false end
function modifier_imba_void:IsPurgable() 		return true end
function modifier_imba_void:IsPurgeException() 	return true end
function modifier_imba_void:GetEffectName() return "particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf" end
function modifier_imba_void:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_void:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION, MODIFIER_PROPERTY_BONUS_NIGHT_VISION} end
function modifier_imba_void:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("movespeed_slow")) end
function modifier_imba_void:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attackspeed_slow")) end
function modifier_imba_void:GetModifierProvidesFOWVision()
	if self:GetCaster():GetModifierStackCount("modifier_imba_void_day", self:GetCaster()) == 1 then
		return 0
	else
		return 1
	end
end
function modifier_imba_void:GetBonusNightVision()
	if self:GetCaster():GetModifierStackCount("modifier_imba_void_day", self:GetCaster()) == 1 then
		return 0
	else
		return (0 - self:GetAbility():GetSpecialValueFor("vision_loss_tooltip"))
	end
end


imba_night_stalker_crippling_fear = class({})

LinkLuaModifier("modifier_imba_crippling_fear", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_crippling_fear_mute", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_crippling_fear_day", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)

function imba_night_stalker_crippling_fear:IsHiddenWhenStolen() 		return false end
function imba_night_stalker_crippling_fear:IsRefreshable() 				return true end
function imba_night_stalker_crippling_fear:IsStealable() 				return true end
function imba_night_stalker_crippling_fear:IsNetherWardStealable()		return true end
function imba_night_stalker_crippling_fear:GetIntrinsicModifierName() 	return "modifier_imba_void_day" end
function imba_night_stalker_crippling_fear:GetBehavior() return self:GetCaster():HasTalent("special_bonus_imba_night_stalker_1") and DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE or DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
function imba_night_stalker_crippling_fear:GetAOERadius() return self:GetCaster():GetTalentValue("special_bonus_imba_night_stalker_1") end

function imba_night_stalker_crippling_fear:OnSpellStart()
	local caster = self:GetCaster()
	if not caster:HasTalent("special_bonus_imba_night_stalker_1") then
		local target = self:GetCursorTarget()
		if target:TriggerStandardTargetSpell(self) then
			return
		end
		target:EmitSound("Hero_Nightstalker.Trickling_Fear")
		if GameRules:IsDaytime() then
			target:AddNewModifier(caster, self, "modifier_imba_crippling_fear", {duration = self:GetSpecialValueFor("duration_day")})
		else
			target:AddNewModifier(caster, self, "modifier_imba_crippling_fear", {duration = self:GetSpecialValueFor("duration_night")})
			target:AddNewModifier(caster, self, "modifier_imba_crippling_fear_mute", {duration = self:GetSpecialValueFor("duration_mute") + caster:GetTalentValue("special_bonus_imba_night_stalker_2")})
		end
	else
		local pos = self:GetCursorPosition()
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, caster:GetTalentValue("special_bonus_imba_night_stalker_1"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			enemy:EmitSound("Hero_Nightstalker.Trickling_Fear")
			if GameRules:IsDaytime() then
				enemy:AddNewModifier(caster, self, "modifier_imba_crippling_fear", {duration = self:GetSpecialValueFor("duration_day")})
			else
				enemy:AddNewModifier(caster, self, "modifier_imba_crippling_fear", {duration = self:GetSpecialValueFor("duration_night")})
				enemy:AddNewModifier(caster, self, "modifier_imba_crippling_fear_mute", {duration = self:GetSpecialValueFor("duration_mute") + caster:GetTalentValue("special_bonus_imba_night_stalker_2")})
			end
		end
	end
end

modifier_imba_crippling_fear_day = class({})  -- use this to know day and night

function modifier_imba_crippling_fear_day:IsDebuff()			return false end
function modifier_imba_crippling_fear_day:IsHidden() 			return true end
function modifier_imba_crippling_fear_day:IsPurgable() 		return false end
function modifier_imba_crippling_fear_day:IsPurgeException() 	return false end
function modifier_imba_crippling_fear_day:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end
function modifier_imba_crippling_fear_day:OnIntervalThink()
	if GameRules:IsDaytime() then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

modifier_imba_crippling_fear = class({})

function modifier_imba_crippling_fear:IsDebuff()		return true end
function modifier_imba_crippling_fear:IsHidden() 		return false end
function modifier_imba_crippling_fear:IsPurgable() 		return true end
function modifier_imba_crippling_fear:IsPurgeException() return true end
function modifier_imba_crippling_fear:GetEffectName() return "particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear.vpcf" end
function modifier_imba_crippling_fear:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_crippling_fear:ShouldUseOverheadOffset() return true end
function modifier_imba_crippling_fear:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_imba_crippling_fear:DeclareFunctions() return {MODIFIER_PROPERTY_MISS_PERCENTAGE} end
function modifier_imba_crippling_fear:GetModifierMiss_Percentage()
	if self:GetCaster():GetModifierStackCount("modifier_imba_crippling_fear_day", self:GetCaster()) == 1 then
		return (self:GetAbility():GetSpecialValueFor("miss_rate_day"))
	else
		return (self:GetAbility():GetSpecialValueFor("miss_rate_night"))
	end
end

modifier_imba_crippling_fear_mute = class({})

function modifier_imba_crippling_fear_mute:IsDebuff()			return true end
function modifier_imba_crippling_fear_mute:IsHidden() 			return false end
function modifier_imba_crippling_fear_mute:IsPurgable() 		return true end
function modifier_imba_crippling_fear_mute:IsPurgeException()	return true end
function modifier_imba_crippling_fear_mute:CheckState() return {[MODIFIER_STATE_MUTED] = true} end

imba_night_stalker_hunter_in_the_night = class({})

LinkLuaModifier("modifier_imba_hunter_in_the_night", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hunter_in_the_night_active", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hunter_in_the_night_dummy", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)

function imba_night_stalker_hunter_in_the_night:IsHiddenWhenStolen() 		return false end
function imba_night_stalker_hunter_in_the_night:IsRefreshable() 			return true end
function imba_night_stalker_hunter_in_the_night:IsStealable() 				return true end
function imba_night_stalker_hunter_in_the_night:IsNetherWardStealable()		return false end

function imba_night_stalker_hunter_in_the_night:GetIntrinsicModifierName() return "modifier_imba_hunter_in_the_night" end
function imba_night_stalker_hunter_in_the_night:GetBehavior() return (not self:GetCaster():HasModifier("modifier_imba_hunter_in_the_night_dummy") and DOTA_ABILITY_BEHAVIOR_PASSIVE or DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES + DOTA_ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL + DOTA_ABILITY_BEHAVIOR_IMMEDIATE) end

function imba_night_stalker_hunter_in_the_night:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_hunter_in_the_night_active", {duration = self:GetSpecialValueFor("duration") + self:GetCaster():GetTalentValue("special_bonus_imba_night_stalker_3")})
	self:GetCaster():EmitSound("Hero_Nightstalker.Wings")
end

modifier_imba_hunter_in_the_night = class({})

function modifier_imba_hunter_in_the_night:IsDebuff()			return false end
function modifier_imba_hunter_in_the_night:IsHidden()
	if self:GetCaster():HasModifier("modifier_imba_hunter_in_the_night_dummy") then
		return false
	else
		return true
	end
end
function modifier_imba_hunter_in_the_night:IsPurgable() 		return false end
function modifier_imba_hunter_in_the_night:IsPurgeException()	return false end
function modifier_imba_hunter_in_the_night:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_hunter_in_the_night:GetModifierMoveSpeedBonus_Percentage()
	if not self:GetCaster():HasModifier("modifier_imba_hunter_in_the_night_dummy") or self:GetParent():PassivesDisabled() then
		return 0
	else
		return (self:GetAbility():GetSpecialValueFor("bonus_ms") + self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stacking_ms"))
	end
end
function modifier_imba_hunter_in_the_night:GetModifierAttackSpeedBonus_Constant()
	if not self:GetCaster():HasModifier("modifier_imba_hunter_in_the_night_dummy") or self:GetParent():PassivesDisabled() then
		return 0
	else
		return (self:GetAbility():GetSpecialValueFor("bonus_as") + self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stacking_as"))
	end
end

function modifier_imba_hunter_in_the_night:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_hunter_in_the_night:OnIntervalThink()
	local caster = self:GetParent()
	if not GameRules:IsDaytime() then
		if not caster:HasModifier("modifier_imba_hunter_in_the_night_dummy") then
			caster:AddNewModifier(caster, self:GetAbility(), "modifier_imba_hunter_in_the_night_dummy", {})
		end
	else
		caster:RemoveModifierByName("modifier_imba_hunter_in_the_night_dummy")
	end
end

function modifier_imba_hunter_in_the_night:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_imba_hunter_in_the_night_dummy")
	end
end

modifier_imba_hunter_in_the_night_dummy = class({})

function modifier_imba_hunter_in_the_night_dummy:IsDebuff()			return false end
function modifier_imba_hunter_in_the_night_dummy:IsHidden() 		return true end
function modifier_imba_hunter_in_the_night_dummy:IsPurgable() 		return false end
function modifier_imba_hunter_in_the_night_dummy:IsPurgeException()	return false end
function modifier_imba_hunter_in_the_night_dummy:RemoveOnDeath() return false end
function modifier_imba_hunter_in_the_night_dummy:GetEffectName() return "particles/units/heroes/hero_night_stalker/nightstalker_night_buff.vpcf" end
function modifier_imba_hunter_in_the_night_dummy:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
--function modifier_imba_hunter_in_the_night_dummy:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE} end
function modifier_imba_hunter_in_the_night_dummy:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_change.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end
--function modifier_imba_hunter_in_the_night_dummy:GetModifierModelChange() return "models/heroes/nightstalker/nightstalker_night.vmdl" end

modifier_imba_hunter_in_the_night_active = class({})

function modifier_imba_hunter_in_the_night_active:IsDebuff()			return false end
function modifier_imba_hunter_in_the_night_active:IsHidden() 			return false end
function modifier_imba_hunter_in_the_night_active:IsPurgable() 			return true end
function modifier_imba_hunter_in_the_night_active:IsPurgeException()	return true end
function modifier_imba_hunter_in_the_night_active:DeclareFunctions() return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_imba_hunter_in_the_night_active:CheckState() return {[MODIFIER_STATE_FLYING] = true} end

function modifier_imba_hunter_in_the_night_active:OnCreated()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_hunter_in_the_night_active:OnIntervalThink() AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetParent():GetCurrentVisionRange(), FrameTime() * 2, false) end

function modifier_imba_hunter_in_the_night_active:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 200, false)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 200, false)
	end
end

function modifier_imba_hunter_in_the_night_active:GetActivityTranslationModifiers() return "hunter_night" end



imba_night_stalker_darkness = class({})

LinkLuaModifier("modifier_imba_darkness_caster", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_darkness_enemy", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_darkness_enemy_vision", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_darkness_scepter", "hero/hero_night_stalker", LUA_MODIFIER_MOTION_NONE)

function imba_night_stalker_darkness:IsHiddenWhenStolen() 		return false end
function imba_night_stalker_darkness:IsRefreshable() 			return true end
function imba_night_stalker_darkness:IsStealable() 				return true end
function imba_night_stalker_darkness:IsNetherWardStealable()	return true end
function imba_night_stalker_darkness:GetIntrinsicModifierName() return "modifier_imba_darkness_scepter" end

function imba_night_stalker_darkness:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Nightstalker.Darkness.Team")
	local heroes = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 100000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
	for _, hero in pairs(heroes) do
		if caster:HasAbility("imba_tinker_rearm") and hero:HasModifier("modifier_imba_darkness_enemy") then
			break
		end
		hero:AddNewModifier(caster, self, "modifier_imba_darkness_enemy_vision", {duration = self:GetSpecialValueFor("enemy_vision_duration")})
	end
	caster:AddNewModifier(caster, self, "modifier_imba_darkness_caster", {duration = self:GetSpecialValueFor("duration")})
	GameRules:BeginNightstalkerNight(self:GetSpecialValueFor("duration"))
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local a = caster:FindModifierByName("modifier_imba_hunter_in_the_night")
	if a then
		a:SetStackCount(a:GetStackCount() + 1)
	end
end

modifier_imba_darkness_scepter = class({})

function modifier_imba_darkness_scepter:IsDebuff()			return false end
function modifier_imba_darkness_scepter:IsHidden() 			return true end
function modifier_imba_darkness_scepter:IsPurgable() 		return false end
function modifier_imba_darkness_scepter:IsPurgeException()	return false end

function modifier_imba_darkness_scepter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_darkness_scepter:OnIntervalThink()
	if self:GetParent():HasScepter() and self:GetParent():IsAlive() and not GameRules:IsDaytime() then
		AddFOWViewer(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetParent():GetCurrentVisionRange(), 0.12, false)
	end
end

modifier_imba_darkness_enemy_vision = class({})

function modifier_imba_darkness_enemy_vision:IsDebuff()			return true end
function modifier_imba_darkness_enemy_vision:IsHidden() 		return false end
function modifier_imba_darkness_enemy_vision:IsPurgable() 		return false end
function modifier_imba_darkness_enemy_vision:IsPurgeException()	return false end
function modifier_imba_darkness_enemy_vision:DeclareFunctions() return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_darkness_enemy_vision:GetModifierProvidesFOWVision() return 1 end

modifier_imba_darkness_caster = class({})

function modifier_imba_darkness_caster:IsDebuff()			return false end
function modifier_imba_darkness_caster:IsHidden() 			return false end
function modifier_imba_darkness_caster:IsPurgable() 		return false end
function modifier_imba_darkness_caster:IsPurgeException()	return false end
function modifier_imba_darkness_caster:RemoveOnDeath()		return false end
function modifier_imba_darkness_caster:DeclareFunctions() return {MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT} end
function modifier_imba_darkness_caster:GetModifierIgnoreMovespeedLimit() return 1 end
function modifier_imba_darkness_caster:GetBonusNightVision() return self:GetAbility():GetSpecialValueFor("bonus_vision") end

function modifier_imba_darkness_caster:IsAura() return true end
function modifier_imba_darkness_caster:IsAuraActiveOnDeath() return true end
function modifier_imba_darkness_caster:GetAuraDuration() return 0.1 end
function modifier_imba_darkness_caster:GetModifierAura() return "modifier_imba_darkness_enemy" end
function modifier_imba_darkness_caster:GetAuraRadius() return 100000 end
function modifier_imba_darkness_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_imba_darkness_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_darkness_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_ALL end
function modifier_imba_darkness_caster:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_darkness_caster:OnIntervalThink() IncreaseAttackSpeedCap(self:GetParent(), 10000) end
function modifier_imba_darkness_caster:OnDestroy()
	if IsServer() then
		RevertAttackSpeedCap(self:GetParent())
	end
end

modifier_imba_darkness_enemy = class({})

function modifier_imba_darkness_enemy:IsDebuff()			return true end
function modifier_imba_darkness_enemy:IsHidden() 			return false end
function modifier_imba_darkness_enemy:IsPurgable() 			return false end
function modifier_imba_darkness_enemy:IsPurgeException()	return false end
function modifier_imba_darkness_enemy:DeclareFunctions() return {MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE} end
function modifier_imba_darkness_enemy:GetBonusVisionPercentage() return (0 - self:GetAbility():GetSpecialValueFor("vision_radius_pct")) end

--[[function modifier_imba_darkness_enemy:OnCreated()
	if IsServer() then
		self.vision = self:GetParent():GetNightTimeVisionRange()
		self:GetParent():SetNightTimeVisionRange(self:GetAbility():GetSpecialValueFor("vision_radius"))
	end
end

function modifier_imba_darkness_enemy:OnDestroy()
	if IsServer() then
		self:GetParent():SetNightTimeVisionRange(self.vision)
		self.vision = nil
	end
end]]