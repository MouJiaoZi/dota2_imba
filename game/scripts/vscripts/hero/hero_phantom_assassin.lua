

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
	caster:PerformAttack(target, false, true, true, false, false, false, true)
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
	local pfx_name1 = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_blur.vpcf"
	local pfx_name2 = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_phantom_strike_end.vpcf"
	if HeroItems:UnitHasItem(caster, "pa_arcana") then
		pfx_name1 = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_start.vpcf"
		pfx_name2 = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_end.vpcf"
	end
	local pfx1 = ParticleManager:CreateParticle(pfx_name1, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx1, 0, startpos)
	ParticleManager:ReleaseParticleIndex(pfx1)
	local pfx2 = ParticleManager:CreateParticle(pfx_name2, PATTACH_WORLDORIGIN, caster)
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
	caster:EmitSound("Hero_PhantomAssassin.Strike.End")
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
LinkLuaModifier("modifier_imba_blur_active", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_blur:IsHiddenWhenStolen() 		return false end
function imba_phantom_assassin_blur:IsRefreshable() 			return true end
function imba_phantom_assassin_blur:IsStealable() 				return true end
function imba_phantom_assassin_blur:IsNetherWardStealable()		return true end
function imba_phantom_assassin_blur:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_phantom_assassin_blur:GetIntrinsicModifierName() return "modifier_imba_blur" end

function imba_phantom_assassin_blur:OnHeroDiedNearby(unit, attacker, keys)
	if self:GetCaster():HasScepter() and IsEnemy(unit, self:GetCaster()) and (unit:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() <= self:GetSpecialValueFor("radius") then
		local caster = self:GetCaster()
		for i = 0, 23 do
			local current_ability = caster:GetAbilityByIndex(i)
			if current_ability and not IsRefreshableByAbility(current_ability:GetName()) then
				current_ability:EndCooldown()
			end
		end
	end
end

function imba_phantom_assassin_blur:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_PhantomAssassin.Blur")
	caster:Purge(false, true, false, false, false)
	caster:AddNewModifier(caster, self, "modifier_imba_blur_active", {duration = self:GetSpecialValueFor("duration")})
	local pfx = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_death_lines.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_ABSORIGIN_FOLLOW, nil, caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_imba_blur_active = class({})

function modifier_imba_blur_active:IsDebuff()			return false end
function modifier_imba_blur_active:IsHidden() 			return false end
function modifier_imba_blur_active:IsPurgable() 		return false end
function modifier_imba_blur_active:IsPurgeException() 	return false end
function modifier_imba_blur_active:GetEffectName() return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_active_blur.vpcf" end
function modifier_imba_blur_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_blur_active:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

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
function modifier_imba_blur_detected:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_blur_detected:GetModifierMoveSpeedBonus_Percentage() return self:GetCaster():PassivesDisabled() and 0 or self:GetAbility():GetSpecialValueFor("blur_ms") end
function modifier_imba_blur_detected:CheckState()
	if self:GetParent():HasTalent("special_bonus_imba_phantom_assassin_2") then
		return {[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true}
	else
		return {[MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true}
	end
end

imba_phantom_assassin_coup_de_grace = class({})

LinkLuaModifier("modifier_imba_coup_de_grace", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_coup_de_grace_check", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_coup_de_grace_stacks", "hero/hero_phantom_assassin", LUA_MODIFIER_MOTION_NONE)

function imba_phantom_assassin_coup_de_grace:GetIntrinsicModifierName() return "modifier_imba_coup_de_grace" end

modifier_imba_coup_de_grace_check = class({})

function modifier_imba_coup_de_grace_check:IsHidden()			return true end
function modifier_imba_coup_de_grace_check:IsDebuff()			return false end
function modifier_imba_coup_de_grace_check:IsPurgable() 		return false end
function modifier_imba_coup_de_grace_check:IsPurgeException() 	return false end

modifier_imba_coup_de_grace = class({})

function modifier_imba_coup_de_grace:IsDebuff()			return false end
function modifier_imba_coup_de_grace:IsHidden() 		return true end
function modifier_imba_coup_de_grace:IsPurgable() 		return false end
function modifier_imba_coup_de_grace:IsPurgeException() return false end
function modifier_imba_coup_de_grace:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE} end

function modifier_imba_coup_de_grace:GetModifierPreAttack_CriticalStrike(keys)
	if IsServer() and keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():PassivesDisabled() and self:GetParent().splitattack then
		local pct = self:GetAbility():GetSpecialValueFor("crit_chance") + self:GetParent():GetModifierStackCount("modifier_imba_coup_de_grace_stacks", nil)
		if PseudoRandom:RollPseudoRandom(self:GetAbility(), pct) then
			if HeroItems:UnitHasItem(self:GetParent(), "pa_arcana") then
				self:GetParent():EmitSound("Hero_PhantomAssassin.CoupDeGrace.Arcana")
			else
				self:GetParent():EmitSound("Hero_PhantomAssassin.CoupDeGrace")
			end
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_coup_de_grace_check", {})
			return self:GetAbility():GetSpecialValueFor("crit_bonus")
		else
			self:GetParent():RemoveModifierByName("modifier_imba_coup_de_grace_check")
			return 0
		end
	end
end

function modifier_imba_coup_de_grace:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or not keys.target:IsAlive() then
		return
	end
	local caster = self:GetParent()
	if caster:HasModifier("modifier_imba_coup_de_grace_check") then
		local pfx_name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
		if HeroItems:UnitHasItem(caster, "pa_arcana") then
			pfx_name = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_arcana_swoop.vpcf"
		end
		local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN, keys.target)
		ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 1, keys.target:GetAbsOrigin())
		ParticleManager:SetParticleControlOrientation(pfx, 1, caster:GetForwardVector() * -1, caster:GetRightVector(), caster:GetUpVector())
		ParticleManager:ReleaseParticleIndex(pfx)
		caster:RemoveModifierByName("modifier_imba_coup_de_grace_check")
	end
	if caster:HasScepter() and caster:IsRealHero() and PseudoRandom:RollPseudoRandom(self:GetCreationTime(), self:GetAbility():GetSpecialValueFor("crit_chance_scepter")) and keys.target:IsRealHero() then
		TrueKill(caster, keys.target, self:GetAbility())
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, keys.target, 999999, nil)
		local blood_pfx = ParticleManager:CreateParticle("particles/hero/phantom_assassin/screen_blood_splatter.vpcf", PATTACH_EYES_FOLLOW, keys.target)
		ParticleManager:ReleaseParticleIndex(blood_pfx)

		for i=0, 3 do
			local pfx = ParticleManager:CreateParticle("particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_arcana_swoop.vpcf", PATTACH_ABSORIGIN, keys.target)
			ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.target:GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(pfx, 1, keys.target:GetAbsOrigin())
			local direction = caster:GetForwardVector()
			direction.z = 0
			local point = caster:GetAbsOrigin() + direction * 100
			point = RotatePosition(caster:GetAbsOrigin(), QAngle(0, 90 * i, 0), point)
			ParticleManager:SetParticleControlOrientation(pfx, 1, (point - caster:GetAbsOrigin()):Normalized(), caster:GetRightVector(), caster:GetUpVector())
			ParticleManager:ReleaseParticleIndex(pfx)
		end

		-- Play fatality message
		Notifications:BottomToAll({text = "#coup_de_grace_fatality", duration = 4.0, style = {["font-size"] = "50px", color = "Red"} })

		-- Play global sounds
		keys.target:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
		keys.target:EmitSound("Imba.PhantomAssassinFatality")
	end
end

modifier_imba_coup_de_grace_stacks = class({})

function modifier_imba_coup_de_grace_stacks:IsDebuff()			return false end
function modifier_imba_coup_de_grace_stacks:IsHidden() 			return false end
function modifier_imba_coup_de_grace_stacks:IsPurgable() 		return false end
function modifier_imba_coup_de_grace_stacks:IsPurgeException() 	return false end