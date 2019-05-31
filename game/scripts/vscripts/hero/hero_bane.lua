CreateEmptyTalents("bane")

imba_bane_enfeeble = class({})

LinkLuaModifier("modifier_imba_bane_enfeeble", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_bane_enfeeble_str", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_bane_enfeeble_agi", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_bane_enfeeble_int", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)

function imba_bane_enfeeble:IsHiddenWhenStolen() 		return false end
function imba_bane_enfeeble:IsRefreshable() 			return true end
function imba_bane_enfeeble:IsStealable() 				return true end
function imba_bane_enfeeble:IsNetherWardStealable() 	return true end

function imba_bane_enfeeble:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Bane.Enfeeble.Cast")
	return true
end

function imba_bane_enfeeble:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Bane.Enfeeble", caster)
	local buff = target:FindModifierByName("modifier_imba_bane_enfeeble")
	if buff then
		buff:ForceRefresh()
	else
		target:AddNewModifier(caster, self, "modifier_imba_bane_enfeeble", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_imba_bane_enfeeble = class({})
modifier_imba_bane_enfeeble_str = class({})
modifier_imba_bane_enfeeble_agi = class({})
modifier_imba_bane_enfeeble_int = class({})
function modifier_imba_bane_enfeeble_str:IsDebuff()				return true end
function modifier_imba_bane_enfeeble_str:IsHidden() 			return true end
function modifier_imba_bane_enfeeble_str:IsPurgable() 			return false end
function modifier_imba_bane_enfeeble_str:IsPurgeException() 	return false end
function modifier_imba_bane_enfeeble_str:DeclareFunctions() 	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_bane_enfeeble_str:GetModifierBonusStats_Strength() return (0-self:GetStackCount()) end

function modifier_imba_bane_enfeeble_agi:IsDebuff()				return true end
function modifier_imba_bane_enfeeble_agi:IsHidden() 			return true end
function modifier_imba_bane_enfeeble_agi:IsPurgable() 			return false end
function modifier_imba_bane_enfeeble_agi:IsPurgeException() 	return false end
function modifier_imba_bane_enfeeble_agi:DeclareFunctions() 	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_bane_enfeeble_agi:GetModifierBonusStats_Agility() return (0-self:GetStackCount()) end

function modifier_imba_bane_enfeeble_int:IsDebuff()				return true end
function modifier_imba_bane_enfeeble_int:IsHidden() 			return true end
function modifier_imba_bane_enfeeble_int:IsPurgable() 			return false end
function modifier_imba_bane_enfeeble_int:IsPurgeException() 	return false end
function modifier_imba_bane_enfeeble_int:DeclareFunctions() 	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_bane_enfeeble_int:GetModifierBonusStats_Intellect() return (0-self:GetStackCount()) end

function modifier_imba_bane_enfeeble:IsDebuff()				return true end
function modifier_imba_bane_enfeeble:IsHidden() 			return false end
function modifier_imba_bane_enfeeble:IsPurgable() 			return false end
function modifier_imba_bane_enfeeble:IsPurgeException() 	return false end

function modifier_imba_bane_enfeeble:GetEffectName() return "particles/units/heroes/hero_bane/bane_enfeeble.vpcf" end
function modifier_imba_bane_enfeeble:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_bane_enfeeble:ShouldUseOverheadOffset() return true end

function modifier_imba_bane_enfeeble:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end

function modifier_imba_bane_enfeeble:OnCreated()
	if not IsServer() then
		return
	end
	local str = self:GetParent():GetStrength() * (self:GetAbility():GetSpecialValueFor("stat_reduction") / 100)
	local agi = self:GetParent():GetAgility() * (self:GetAbility():GetSpecialValueFor("stat_reduction") / 100)
	local int = self:GetParent():GetIntellect() * (self:GetAbility():GetSpecialValueFor("stat_reduction") / 100)
	local caster = self:GetCaster()
	local target = self:GetParent()
	local buff1 = target:AddNewModifier(caster, self:GetAbility(), "modifier_imba_bane_enfeeble_str", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	local buff2 = target:AddNewModifier(caster, self:GetAbility(), "modifier_imba_bane_enfeeble_agi", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	local buff3 = target:AddNewModifier(caster, self:GetAbility(), "modifier_imba_bane_enfeeble_int", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	buff1:SetStackCount(str)
	buff2:SetStackCount(agi)
	buff3:SetStackCount(int)
end

function modifier_imba_bane_enfeeble:GetModifierPreAttack_BonusDamage()	return (0-self:GetAbility():GetSpecialValueFor("attack_reduction")) end

imba_bane_brain_sap = class({})

LinkLuaModifier("modifier_imba_bane_brain_sap", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)

function imba_bane_brain_sap:IsHiddenWhenStolen() 		return false end
function imba_bane_brain_sap:IsRefreshable() 			return true end
function imba_bane_brain_sap:IsStealable() 				return true end
function imba_bane_brain_sap:IsNetherWardStealable() 	return true end
function imba_bane_brain_sap:GetCooldown(i) return self:GetCaster():HasScepter() and self:GetSpecialValueFor("cooldown_scepter") or self.BaseClass.GetCooldown(self, i) end

function imba_bane_brain_sap:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local damageTable = {
						victim = target,
						attacker = caster,
						damage = self:GetSpecialValueFor("heal_amt"),
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	local dmg = ApplyDamage(damageTable)
	caster:Heal(dmg, caster)
	target:AddNewModifier(caster, self, "modifier_imba_bane_brain_sap", {duration = self:GetSpecialValueFor("duration")})
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Bane.BrainSap", caster)
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Bane.BrainSap.Target", target)
end

modifier_imba_bane_brain_sap = class({})

function modifier_imba_bane_brain_sap:IsDebuff()			return true end
function modifier_imba_bane_brain_sap:IsHidden() 			return false end
function modifier_imba_bane_brain_sap:IsPurgable() 			return true end
function modifier_imba_bane_brain_sap:IsPurgeException() 	return true end

function modifier_imba_bane_brain_sap:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_START,}
end

function modifier_imba_bane_brain_sap:OnAbilityStart(keys)
	if keys.unit ~= self:GetParent() then
		return 
	end
	local drain_amount = self:GetParent():GetMana() * (self:GetAbility():GetSpecialValueFor("mana_percent") / 100)
	self:GetParent():SetMana(self:GetParent():GetMana() - drain_amount)
	self:GetCaster():Heal(drain_amount, self:GetParent())
	self:GetCaster():SetMana(math.min(self:GetCaster():GetMana() + drain_amount, self:GetCaster():GetMaxMana()))
	local caster = self:GetCaster()
	local target = self:GetParent()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_sap.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Bane.BrainSap", caster)
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Bane.BrainSap.Target", target)
end

imba_bane_nightmare = class({})

LinkLuaModifier("modifier_imba_bane_nightmare", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_bane_nightmare_invul", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)

function imba_bane_nightmare:IsHiddenWhenStolen() 		return false end
function imba_bane_nightmare:IsRefreshable() 			return true end
function imba_bane_nightmare:IsStealable() 				return true end
function imba_bane_nightmare:IsNetherWardStealable() 	return true end

function imba_bane_nightmare:GetAssociatedSecondaryAbilities() return "imba_bane_nightmare_end" end

function imba_bane_nightmare:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	if not IsEnemy(caster, target) and PlayerResource:IsDisableHelpSetForPlayerID(target:GetPlayerOwnerID(), caster:GetPlayerOwnerID()) then
		target = caster
	end
	target:AddNewModifier(caster, self, "modifier_imba_bane_nightmare", {duration = self:GetSpecialValueFor("duration")})
	target:AddNewModifier(caster, self, "modifier_imba_bane_nightmare_invul", {duration = self:GetSpecialValueFor("nightmare_invuln_time")})
end

modifier_imba_bane_nightmare = class({})
modifier_imba_bane_nightmare_invul = class({})

function modifier_imba_bane_nightmare:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_bane_nightmare_end")
	if ability then
		ability:SetLevel(1)
	end
end

function modifier_imba_bane_nightmare:IsDebuff()			return true end
function modifier_imba_bane_nightmare:IsHidden() 			return false end
function modifier_imba_bane_nightmare:IsPurgable() 			return false end
function modifier_imba_bane_nightmare:IsPurgeException() 	return true end

function modifier_imba_bane_nightmare:GetEffectName() return "particles/units/heroes/hero_bane/bane_nightmare.vpcf" end
function modifier_imba_bane_nightmare:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_bane_nightmare:ShouldUseOverheadOffset() return true end

function modifier_imba_bane_nightmare:OnCreated()
	EmitSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
	if IsServer() then
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Bane.Nightmare", self:GetParent())
		self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_FLAIL, self:GetAbility():GetSpecialValueFor("animation_rate"))
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("nightmare_dot_interval"))
	end
end

function modifier_imba_bane_nightmare:OnIntervalThink()
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = self:GetAbility():GetSpecialValueFor("damage_per_second"),
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	local dmg = ApplyDamage(damageTable)
end

function modifier_imba_bane_nightmare:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_BONUS_DAY_VISION, MODIFIER_PROPERTY_BONUS_NIGHT_VISION}
end

function modifier_imba_bane_nightmare:GetBonusNightVision() return -5000 end
function modifier_imba_bane_nightmare:GetBonusDayVision() return -5000 end

function modifier_imba_bane_nightmare:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.target ~= self:GetParent() then
		return
	end
	if keys.attacker == self:GetCaster() then
		return
	end
	local target = keys.attacker
	if target:TriggerSpellAbsorb(self:GetAbility()) or target:IsMagicImmune() then
		return
	end
	target:TriggerSpellReflect(self:GetAbility())
	target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_bane_nightmare", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_bane_nightmare_invul", {duration = self:GetAbility():GetSpecialValueFor("nightmare_invuln_time")})
end

function modifier_imba_bane_nightmare:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() or keys.inflictor == self:GetAbility() or keys.attacker == self:GetCaster() then
		return
	end
	self:Destroy()
end

function modifier_imba_bane_nightmare:CheckState()
	return {[MODIFIER_STATE_NIGHTMARED] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_SPECIALLY_DENIABLE] = true, [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true}
end

function modifier_imba_bane_nightmare:OnDestroy()
	StopSoundOn("Hero_Bane.Nightmare.Loop", self:GetParent())
	if IsServer() then
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Bane.Nightmare.End", self:GetParent())
		self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
	end
end

function modifier_imba_bane_nightmare_invul:IsDebuff()			return false end
function modifier_imba_bane_nightmare_invul:IsHidden() 			return false end
function modifier_imba_bane_nightmare_invul:IsPurgable() 		return false end
function modifier_imba_bane_nightmare_invul:IsPurgeException() 	return false end

function modifier_imba_bane_nightmare_invul:CheckState()
	return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true}
end

imba_bane_nightmare_end = class({})

function imba_bane_nightmare_end:IsHiddenWhenStolen() 		return false end
function imba_bane_nightmare_end:IsRefreshable() 			return true end
function imba_bane_nightmare_end:IsStealable() 				return false end
function imba_bane_nightmare_end:IsNetherWardStealable() 	return false end
function imba_bane_nightmare_end:IsTalentAbility() return true end

function imba_bane_nightmare_end:GetAssociatedPrimaryAbilities() return "imba_bane_nightmare" end

function imba_bane_nightmare_end:OnSpellStart()
	local target = self:GetCursorTarget()
	local buff1 = target:FindModifierByNameAndCaster("modifier_imba_bane_nightmare", self:GetCaster())
	local buff2 = target:FindModifierByNameAndCaster("modifier_imba_bane_nightmare_invul", self:GetCaster())
	if buff1 then
		buff1:Destroy()
	end
	if buff2 then
		buff2:Destroy()
	end
end

imba_bane_fiends_grip = class({})

LinkLuaModifier("modifier_imba_bane_fiends_grip", "hero/hero_bane", LUA_MODIFIER_MOTION_NONE)

function imba_bane_fiends_grip:IsHiddenWhenStolen() 	return false end
function imba_bane_fiends_grip:IsRefreshable() 			return true end
function imba_bane_fiends_grip:IsStealable() 			return true end
function imba_bane_fiends_grip:IsNetherWardStealable() 	return true end

function imba_bane_fiends_grip:GetChannelTime() return self:GetSpecialValueFor("fiends_grip_duration") end

function imba_bane_fiends_grip:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		Timers:CreateTimer(FrameTime(), function()
				self:EndChannel(true)
				caster:Stop()
				return nil
			end
		)
		return
	end
	local buff = target:AddNewModifier(caster, self, "modifier_imba_bane_fiends_grip", {duration = (self:GetChannelTime() + FrameTime() * 2)})
	buff:ForceRefresh()
	buff.cast = true
end

function imba_bane_fiends_grip:OnChannelFinish(bInterrupted)
	local extra_duration = self:GetSpecialValueFor("fiends_grip_extra_duration")
	if self:GetCaster():HasScepter() then
		extra_duration = self:GetSpecialValueFor("fiends_grip_extra_duration_scepter")
	end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), Vector(0,0,0), nil, 250000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_DEAD, FIND_UNITS_EVERYWHERE, false)
	for _, enemy in pairs(enemies) do
		local buffs = enemy:FindAllModifiersByName("modifier_imba_bane_fiends_grip")
		for _, buff in pairs(buffs) do
			if buff:GetCaster() == self:GetCaster() then
				buff:SetDuration(extra_duration, true)
			end
		end
	end
end

modifier_imba_bane_fiends_grip = class({})

function modifier_imba_bane_fiends_grip:IsDebuff()			return true end
function modifier_imba_bane_fiends_grip:IsHidden() 			return false end
function modifier_imba_bane_fiends_grip:IsPurgable() 		return false end
function modifier_imba_bane_fiends_grip:IsPurgeException() 	return false end
function modifier_imba_bane_fiends_grip:IsStunDebuff() 		return true end
function modifier_imba_bane_fiends_grip:RemoveOnDeath() 	return false end
function modifier_imba_bane_fiends_grip:GetAttributes()		return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_imba_bane_fiends_grip:GetEffectName()	return "particles/units/heroes/hero_bane/bane_fiends_grip.vpcf"	 end
function modifier_imba_bane_fiends_grip:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_bane_fiends_grip:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_imba_bane_fiends_grip:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_INVISIBLE] = false}
end

function modifier_imba_bane_fiends_grip:OnCreated()
	EmitSoundOn("Hero_Bane.FiendsGrip", self:GetParent())
	if not IsServer() then 
		return
	end
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("fiends_grip_tick_interval"))
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_FLAIL, 1.0)
end

function modifier_imba_bane_fiends_grip:OnIntervalThink()
	local ability = self:GetAbility()
	local target = self:GetParent()
	local caster = self:GetCaster()
	local dmg = ability:GetSpecialValueFor("fiends_grip_damage_tooltip") / (1.0 / ability:GetSpecialValueFor("fiends_grip_tick_interval"))
	local mana = ability:GetSpecialValueFor("fiends_grip_mana_drain_tooltip") / (1.0 / ability:GetSpecialValueFor("fiends_grip_tick_interval")) / 100
	if caster:HasScepter() then
		dmg = ability:GetSpecialValueFor("fiends_grip_damage_tooltip_scepter") / (1.0 / ability:GetSpecialValueFor("fiends_grip_tick_interval"))
		mana = ability:GetSpecialValueFor("fiends_grip_mana_drain_tooltip_scepter") / (1.0 / ability:GetSpecialValueFor("fiends_grip_tick_interval")) / 100
	end
	local damageTable = {
						victim = target,
						attacker = caster,
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = ability, --Optional.
						}
	ApplyDamage(damageTable)
	local mana_todrain = math.min(target:GetMana(), mana * target:GetMaxMana())
	caster:SetMana(math.min(caster:GetMana() + mana_todrain, caster:GetMaxMana()))
	target:SetMana(math.max(0, target:GetMana() - mana_todrain))

	if caster:HasScepter() and self.cast then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("fiends_grip_scepter_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			-- If this enemy is already Gripped, do nothing
			if not enemy:FindModifierByNameAndCaster("modifier_imba_bane_fiends_grip", caster) then
				local vision_cone = ability:GetSpecialValueFor("fiends_grip_scepter_vision_cone")
				local enemy_location =  enemy:GetAbsOrigin()
				local enemy_to_caster_direction = (caster:GetAbsOrigin() - enemy_location):Normalized()
				local enemy_forward_vector =  enemy:GetForwardVector()

				-- This is the angle between the enemy's forward vector and the line between them and the caster
				local view_angle = math.abs(RotationDelta(VectorToAngles(enemy_to_caster_direction), VectorToAngles(enemy_forward_vector)).y)

				-- If the angle is inside the vision cone, and the channeling caster can be seen by the enemy team, GET GRIPPED NOOB
				if view_angle <= ( vision_cone / 2 ) then
					local grip_duration = self:GetRemainingTime()
					if self:GetDuration() <= 0 then
						grip_duration = -1
					end
					enemy:AddNewModifier(caster, ability, "modifier_imba_bane_fiends_grip", {duration = grip_duration})
				end
			end
		end
	end
end

function modifier_imba_bane_fiends_grip:OnDestroy()
	StopSoundOn("Hero_Bane.FiendsGrip", self:GetParent())
	if not IsServer() then
		return
	end
	self.cast = nil
	self:GetParent():RemoveGesture(ACT_DOTA_FLAIL)
end