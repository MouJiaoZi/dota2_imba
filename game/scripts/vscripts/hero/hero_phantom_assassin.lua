

CreateEmptyTalents("phantom_assassin")



imba_phantom_assassin_stifling_dagger = class({})

LinkLuaModifier("modifier_imba_stifling_dagger_slow", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stifling_dagger_atk", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_stifling_dagger:IsHiddenWhenStolen() 	return false end
function imba_phantom_assassin_stifling_dagger:IsRefreshable() 			return true end
function imba_phantom_assassin_stifling_dagger:IsStealable() 			return true end
function imba_phantom_assassin_stifling_dagger:IsNetherWardStealable()	return true end

function imba_phantom_assassin_stifling_dagger:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast")
	local target = self:GetCursorTarget()
	local pos = target:GetAbsOrigin()
	local daggers = self:GetSpecialValueFor("dagger_count") + caster:GetTalentValue("special_bonus_imba_phantom_assassin_1")
	local targets = {target,}
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetCastRange(pos, target), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if #targets >= daggers then
			break
		end
		if not IsInTable(enemy, targets) then
			targets[#targets+1] = enemy
		end
	end
	for i=1, math.min(#targets, daggers) do
		local info = 
		{
			Target = targets[i],
			Source = caster,
			Ability = self,	
			EffectName = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf",
			iMoveSpeed = self:GetSpecialValueFor("dagger_speed"),
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
end

function imba_phantom_assassin_stifling_dagger:OnProjectileThink(location)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, 450, FrameTime(), false)
end

function imba_phantom_assassin_stifling_dagger:OnProjectileHit(target, location)
	if not target then
		return
	end
	if target:TriggerStandardTargetSpell(self) then
		return true
	end
	target:EmitSound("Hero_PhantomAssassin.Dagger.Target")
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, 450, self:GetSpecialValueFor("slow_duration"), false)
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_imba_stifling_dagger_atk", {})
	caster:PerformAttack(target, true, true, true, false, false, false, true)
	caster:RemoveModifierByName("modifier_imba_stifling_dagger_atk")
	if not target:IsMagicImmune() then
		target:AddNewModifier(caster, self, "modifier_imba_stifling_dagger_slow", {duration = self:GetSpecialValueFor("slow_duration")})
		target:AddNewModifier(caster, self, "modifier_silence", {duration = self:GetSpecialValueFor("silence_duration")})
	end
end

modifier_imba_stifling_dagger_atk = class({})

function modifier_imba_stifling_dagger_atk:IsDebuff()			return false end
function modifier_imba_stifling_dagger_atk:IsHidden() 			return true end
function modifier_imba_stifling_dagger_atk:IsPurgable() 		return false end
function modifier_imba_stifling_dagger_atk:IsPurgeException() 	return false end
function modifier_imba_stifling_dagger_atk:DeclareFunctions() return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE} end
function modifier_imba_stifling_dagger_atk:GetModifierBaseAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end

modifier_imba_stifling_dagger_slow = class({})

function modifier_imba_stifling_dagger_slow:IsDebuff()			return true end
function modifier_imba_stifling_dagger_slow:IsHidden() 			return false end
function modifier_imba_stifling_dagger_slow:IsPurgable() 		return false end
function modifier_imba_stifling_dagger_slow:IsPurgeException() 	return false end
function modifier_imba_stifling_dagger_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_stifling_dagger_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("move_slow")) end
function modifier_imba_stifling_dagger_slow:GetEffectName() return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf" end


imba_phantom_assassin_phantom_strike = class({})

LinkLuaModifier("modifier_imba_phantom_strike", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_phantom_strike:IsHiddenWhenStolen() 		return false end
function imba_phantom_assassin_phantom_strike:IsRefreshable() 			return true end
function imba_phantom_assassin_phantom_strike:IsStealable() 			return true end
function imba_phantom_assassin_phantom_strike:IsNetherWardStealable()	return true end

function imba_phantom_assassin_phantom_strike:CastFilterResultTarget(target)
	if target:IsInvulnerable() then
		return UF_FAIL_INVULNERABLE
	end
	if target == self:GetCaster() or target:IsOther() or target:IsCourier() then
		return UF_FAIL_CUSTOM
	end
end

function imba_phantom_assassin_phantom_strike:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	else
		return "#dota_hud_error_cant_cast_on_other"
	end
end

function imba_phantom_assassin_phantom_strike:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_PhantomAssassin.Strike.Start", caster)
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local startpos = caster:GetAbsOrigin()
	local endpos = target:GetAbsOrigin() + (target:GetForwardVector() * -1) * 100
	FindClearSpaceForUnit(caster, endpos, true)
	local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_blur.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx1, 0, startpos)
	ParticleManager:ReleaseParticleIndex(pfx1)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf", PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(pfx2, 0, endpos)
	ParticleManager:ReleaseParticleIndex(pfx2)
	caster:AddNewModifier(caster, self, "modifier_imba_phantom_strike", {duration = self:GetSpecialValueFor("buff_duration")})
	if target:GetTeamNumber() ~= caster:GetTeamNumber() then
		caster:SetAttacking(target)
		caster:SetForceAttackTarget(target)
		Timers:CreateTimer(0.03, function()
			caster:SetForceAttackTarget(nil)
		end)
	end
	local enemies = FindUnitsInLine(caster:GetTeamNumber(), startpos, endpos, nil, 128, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS)
	local ability = caster:FindAbilityByName("imba_phantom_assassin_coup_de_grace")
	if ability and ability:GetLevel() > 0 then
		for i=1, #enemies do
			for j=1, ability:GetSpecialValueFor("crit_increase") do
				buff = caster:AddNewModifier(caster, ability, "modifier_imba_coup_de_grace_stacks", {duration = ability:GetSpecialValueFor("crit_increase_duration")})
				buff:SetStackCount(buff:GetStackCount() + 1)
			end
		end
	end
	EmitSoundOnLocationWithCaster(endpos, "Hero_PhantomAssassin.Strike.End", caster)
end

modifier_imba_phantom_strike = class({})

function modifier_imba_phantom_strike:IsDebuff()			return false end
function modifier_imba_phantom_strike:IsHidden() 			return false end
function modifier_imba_phantom_strike:IsPurgable() 			return true end
function modifier_imba_phantom_strike:IsPurgeException() 	return true end
function modifier_imba_phantom_strike:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_phantom_strike:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end


imba_phantom_assassin_blur = class({})

LinkLuaModifier("modifier_imba_blur", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_blur_detected", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_blur:GetIntrinsicModifierName() return "modifier_imba_blur" end

modifier_imba_blur = class({})

function modifier_imba_blur:IsDebuff()			return false end
function modifier_imba_blur:IsHidden() 			return true end
function modifier_imba_blur:IsPurgable() 		return false end
function modifier_imba_blur:IsPurgeException() 	return false end
function modifier_imba_blur:GetEffectName() return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf" end
function modifier_imba_blur:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_blur:DeclareFunctions() return {MODIFIER_PROPERTY_EVASION_CONSTANT} end
function modifier_imba_blur:GetModifierEvasion_Constant() return self:GetCaster():PassivesDisabled() and 0 or self:GetAbility():GetSpecialValueFor("evasion") end
function modifier_imba_blur:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.3)
	end
end

function modifier_imba_blur:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	if #enemies > 0 and not self:GetParent():PassivesDisabled() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_blur_detected", {duration = 0.5})
	end
end

modifier_imba_blur_detected = class({})

function modifier_imba_blur_detected:IsDebuff()			return false end
function modifier_imba_blur_detected:IsHidden() 		return false end
function modifier_imba_blur_detected:IsPurgable() 		return false end
function modifier_imba_blur_detected:IsPurgeException() return false end
function modifier_imba_blur_detected:GetStatusEffectName() return "particles/status_fx/status_effect_blur.vpcf" end
function modifier_imba_blur_detected:StatusEffectPriority() return 15 end
function modifier_imba_blur_detected:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_imba_blur_detected:GetModifierMoveSpeedBonus_Percentage() return self:GetCaster():PassivesDisabled() and 0 or self:GetAbility():GetSpecialValueFor("blur_ms") end
function modifier_imba_blur_detected:CheckState()
	if self:GetParent():HasTalent("special_bonus_imba_phantom_assassin_2") then
		return {[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true}
	else
		return {[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true}
	end
end
--function modifier_imba_blur_detected:GetModifierInvisibilityLevel() return (self:GetParent():HasTalent("special_bonus_imba_phantom_assassin_2") and 1 or 0) end

imba_phantom_assassin_coup_de_grace = class({})

LinkLuaModifier("modifier_imba_coup_de_grace", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_coup_de_grace_stacks", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_coup_de_grace:GetIntrinsicModifierName() return "modifier_imba_coup_de_grace" end

modifier_imba_coup_de_grace = class({})

function modifier_imba_coup_de_grace:IsDebuff()			return false end
function modifier_imba_coup_de_grace:IsHidden() 		return true end
function modifier_imba_coup_de_grace:IsPurgable() 		return false end
function modifier_imba_coup_de_grace:IsPurgeException() return false end
function modifier_imba_coup_de_grace:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_START} end
function modifier_imba_coup_de_grace:GetIMBAPhysicalCirtChance() return self.cirt end
function modifier_imba_coup_de_grace:GetIMBAPhysicalCirtBonus() return self:GetAbility():GetSpecialValueFor("crit_bonus") end

function modifier_imba_coup_de_grace:OnTriggerIMBAPhyicalCirt(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():IsRangedAttacker() then
		self:GetParent():EmitSound("Hero_PhantomAssassin.CoupDeGrace")
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, keys.target)
	ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 1, keys.target:GetAbsOrigin())
	ParticleManager:SetParticleControlOrientation(pfx, 1, self:GetParent():GetForwardVector() * -1, self:GetParent():GetRightVector(), self:GetParent():GetUpVector())
	ParticleManager:ReleaseParticleIndex(pfx)
end

function modifier_imba_coup_de_grace:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and not self:GetParent():IsRangedAttacker() then
		if RollPercentage((self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetParent():GetModifierStackCount("modifier_imba_coup_de_grace_stacks", self:GetParent()))) then
			self.cirt = 100
			self:GetParent():EmitSound("Hero_PhantomAssassin.CoupDeGrace")
			self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK_EVENT, self:GetParent():GetAttackSpeed())
		else
			self.cirt = 0
		end
	end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and self:GetParent():IsRangedAttacker() then
		self.cirt = (self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetParent():GetModifierStackCount("modifier_imba_coup_de_grace_stacks", self:GetParent()))
	end
end

function modifier_imba_coup_de_grace:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or not keys.target:IsAlive() then
		return
	end
	if RollPercentage(self:GetAbility():GetSpecialValueFor("crit_chance_scepter")) and self:GetParent():HasScepter() and keys.target:IsRealHero() and self:GetParent():IsRealHero() then
		TrueKill(self:GetParent(), keys.target, self:GetAbility())
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, keys.target, 999999, nil)
		local blood_pfx = ParticleManager:CreateParticle("particles/hero/phantom_assassin/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, keys.target)
		ParticleManager:ReleaseParticleIndex(blood_pfx)

		-- Play fatality message
		Notifications:BottomToAll({text = "#coup_de_grace_fatality", duration = 4.0, style = {["font-size"] = "50px", color = "Red"} })

		-- Play global sounds
		EmitGlobalSound("Hero_PhantomAssassin.CoupDeGrace")
		EmitGlobalSound("Imba.PhantomAssassinFatality")
	end
end

modifier_imba_coup_de_grace_stacks = class({})

function modifier_imba_coup_de_grace_stacks:IsDebuff()			return false end
function modifier_imba_coup_de_grace_stacks:IsHidden() 			return false end
function modifier_imba_coup_de_grace_stacks:IsPurgable() 		return false end
function modifier_imba_coup_de_grace_stacks:IsPurgeException() 	return false end