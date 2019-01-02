CreateEmptyTalents("lion")

imba_lion_earth_spike = class({})

LinkLuaModifier("modifier_earth_spike_motion", "hero/hero_lion", LUA_MODIFIER_MOTION_NONE)

function imba_lion_earth_spike:IsHiddenWhenStolen() 	return false end
function imba_lion_earth_spike:IsRefreshable() 			return true end
function imba_lion_earth_spike:IsStealable() 			return true end
function imba_lion_earth_spike:IsNetherWardStealable()	return true end

function imba_lion_earth_spike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local pos = target and target:GetAbsOrigin() or self:GetCursorPosition()
	local start_pos = caster:GetAbsOrigin()
	local end_pos = start_pos + (pos - start_pos):Normalized() * (self:GetCastRange(pos, caster) + caster:GetCastRangeBonus() + caster:GetTalentValue("special_bonus_imba_lion_1"))
	local marker = CreateModifierThinker(caster, self, "modifier_earth_spike_motion", {duration = 20.0}, start_pos, caster:GetTeamNumber(), false):entindex()
	local sound = CreateModifierThinker(caster, self, "modifier_earth_spike_motion", {duration = 20.0}, start_pos, caster:GetTeamNumber(), false):entindex()
	EntIndexToHScript(sound):EmitSound("Hero_Lion.Impale")
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf",
		vSpawnOrigin = start_pos,
		fDistance = (start_pos - end_pos):Length2D(),
		fStartRadius = self:GetSpecialValueFor("spikes_radius"),
		fEndRadius = self:GetSpecialValueFor("spikes_radius"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = (end_pos - start_pos):Normalized() * self:GetSpecialValueFor("spike_speed"),
		bProvidesVision = false,
		ExtraData = {marker = marker, sound = sound}
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function imba_lion_earth_spike:OnProjectileThink_ExtraData(location, keys) EntIndexToHScript(keys.sound):SetAbsOrigin(location) end

function imba_lion_earth_spike:OnProjectileHit_ExtraData(target, location, keys)
	local caster = self:GetCaster()
	local marker = EntIndexToHScript(keys.marker)
	local marker_ent = marker:entindex()
	if not marker.hitted then
		marker.hitted = {}
	end

	if target then
		for _, hit in pairs(marker.hitted) do
			if hit == target then
				return false
			end
		end
		if target:TriggerStandardTargetSpell(self) then
			return
		end
		target:EmitSound("Hero_Lion.ImpaleHitTarget")
		target:AddNewModifier(caster, self, "modifier_earth_spike_motion", {duration = self:GetSpecialValueFor("knock_up_time")})
		marker.hitted[#marker.hitted+1] = target
		target:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf", PATTACH_CUSTOMORIGIN, nil)
		for i=0, 2 do
			ParticleManager:SetParticleControl(pfx, i, GetGroundPosition(target:GetAbsOrigin(), nil))
		end
		local damageTable = {
							victim = target,
							attacker = caster,
							damage = self:GetSpecialValueFor("damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		ParticleManager:ReleaseParticleIndex(pfx)
		local delay = self:GetSpecialValueFor("wait_interval")
		Timers:CreateTimer(delay, function()
			local spike = true
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("extra_spike_AOE") + caster:GetTalentValue("special_bonus_imba_lion_1"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			for _, enemy in pairs(enemies) do
				local hitted = false
				for _, hit in pairs(marker.hitted) do
					if hit == enemy then
						hitted = true
					end
				end
				if not hitted and spike then
					spike = false
					local start_pos = target:GetAbsOrigin()
					local end_pos = start_pos + (enemy:GetAbsOrigin() - start_pos):Normalized() * (self:GetCastRange(location, caster) + caster:GetCastRangeBonus() + caster:GetTalentValue("special_bonus_imba_lion_1"))
					local info = 
					{
						Ability = self,
						EffectName = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf",
						vSpawnOrigin = target:GetAbsOrigin(),
						fDistance = (start_pos - end_pos):Length2D(),
						fStartRadius = self:GetSpecialValueFor("spikes_radius"),
						fEndRadius = self:GetSpecialValueFor("spikes_radius"),
						Source = caster,
						bHasFrontalCone = false,
						bReplaceExisting = false,
						iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
						iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
						iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						fExpireTime = GameRules:GetGameTime() + 10.0,
						bDeleteOnHit = true,
						vVelocity = (end_pos - start_pos):Normalized() * self:GetSpecialValueFor("spike_speed"),
						bProvidesVision = false,
						ExtraData = {marker = marker_ent, sound = keys.sound}
					}
					ProjectileManager:CreateLinearProjectile(info)
				end
			end
		return nil
		end
		)
	end
end

modifier_earth_spike_motion = class({})

function modifier_earth_spike_motion:IsMotionController()	return true end
function modifier_earth_spike_motion:IsDebuff()				return true end
function modifier_earth_spike_motion:IsHidden() 			return true end
function modifier_earth_spike_motion:IsPurgable() 			return false end
function modifier_earth_spike_motion:IsPurgeException() 	return true end
function modifier_earth_spike_motion:IsStunDebuff() 		return true end
function modifier_earth_spike_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_earth_spike_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_earth_spike_motion:GetModifierMoveSpeed_Absolute() return 1 end
function modifier_earth_spike_motion:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_earth_spike_motion:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end

function modifier_earth_spike_motion:OnCreated()
	if IsServer() then
		self:CheckMotionControllers()
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_earth_spike_motion:OnIntervalThink()
	local total_ticks = self:GetDuration() / FrameTime()
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local height = self:GetAbility():GetSpecialValueFor("knock_up_height")
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin(), nil)
	next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
	self:GetParent():SetAbsOrigin(next_pos)
end

function modifier_earth_spike_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		if self:GetParent():GetName() ~= "npc_dota_thinker" then
			self:GetParent():EmitSound("Hero_Lion.ImpaleTargetLand")
		end
		if self.hitted then
			self.hitted = nil
		end
	end
end

imba_lion_hex = class({})

LinkLuaModifier("modifier_imba_lion_hex", "hero/hero_lion", LUA_MODIFIER_MOTION_NONE)

function imba_lion_hex:IsHiddenWhenStolen() 	return false end
function imba_lion_hex:IsRefreshable() 			return true end
function imba_lion_hex:IsStealable() 			return true end
function imba_lion_hex:IsNetherWardStealable()	return true end

function imba_lion_hex:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	if target:IsIllusion() then
		target:Kill(self, caster)
		return
	end
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Lion.Voodoo", caster)
	target:AddNewModifier(caster, self, "modifier_imba_lion_hex", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_lion_hex = class({})

function modifier_imba_lion_hex:IsDebuff()			return true end
function modifier_imba_lion_hex:IsHidden() 			return false end
function modifier_imba_lion_hex:IsPurgable() 		return false end
function modifier_imba_lion_hex:IsPurgeException() 	return false end
function modifier_imba_lion_hex:CheckState() return {[MODIFIER_STATE_SILENCED] = true, [MODIFIER_STATE_MUTED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_HEXED] = true} end
function modifier_imba_lion_hex:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_imba_lion_hex:GetModifierModelChange() return "models/props_gameplay/frog.vmdl" end
function modifier_imba_lion_hex:GetModifierMoveSpeedBonus_Constant() return -50000 end

function modifier_imba_lion_hex:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_Lion.Hex.Target")
		local interval = self:GetAbility():GetSpecialValueFor("bounce_duration")
		self:StartIntervalThink(interval)
	end
end

function modifier_imba_lion_hex:OnIntervalThink()
	self:StartIntervalThink(-1)
	local target_num = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("target_scepter") or 1
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("hex_bounce_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local tars = 0
	for _, enemy in pairs(enemies) do
		if enemy ~= self:GetParent() and not enemy:IsHexed() then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_lion_hex", {duration = self:GetAbility():GetSpecialValueFor("duration")})
			tars = tars + 1
			if tars == target_num then
				break
			end
		end
	end
end


imba_lion_mana_drain = class({})

LinkLuaModifier("modifier_imba_mana_drain_aura_effect", "hero/hero_lion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_mana_drain_hero_effect", "hero/hero_lion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_mana_drain_thinker", "hero/hero_lion", LUA_MODIFIER_MOTION_NONE)

function imba_lion_mana_drain:IsHiddenWhenStolen() 		return false end
function imba_lion_mana_drain:IsRefreshable() 			return true end
function imba_lion_mana_drain:IsStealable() 			return true end
function imba_lion_mana_drain:IsNetherWardStealable()	return true end
function imba_lion_mana_drain:GetChannelTime() 			return self:GetSpecialValueFor("max_channel_time") end

modifier_imba_mana_drain_thinker = class({})

function imba_lion_mana_drain:GetIntrinsicModifierName() return "modifier_imba_mana_drain_aura_effect" end

function imba_lion_mana_drain:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	if target:IsIllusion() then
		target:Kill(self, caster)
		return
	end
	self.pfx = ParticleManager:CreateParticle("particles/econ/items/lion/lion_demon_drain/lion_spell_mana_drain_demon.vpcf", PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(self.pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(self.pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.pfx, 2, caster:GetForwardVector())
	self.tick = 0
	target:EmitSound("Hero_Lion.ManaDrain")
end

function imba_lion_mana_drain:OnChannelThink(a)
	local distance = (self:GetCaster():GetAbsOrigin() - self:GetCursorTarget():GetAbsOrigin()):Length2D()
	if distance > self:GetSpecialValueFor("break_distance") or self:GetCursorTarget():IsInvulnerable() or self:GetCursorTarget():IsMagicImmune() or not self:GetCaster():CanEntityBeSeenByMyTeam(self:GetCursorTarget()) then
		self:GetCaster():Interrupt()
		return
	end
	local tick = self:GetSpecialValueFor("interval")
	self.tick = self.tick + a
	if tick >= self.tick and tick <= self.tick + a then
		self.tick = 0
		local mana_to_drain = self:GetSpecialValueFor("mana_drain_sec") / (1.0 / self:GetSpecialValueFor("interval"))
		local mana = self:GetCursorTarget():GetMana()
		mana_to_drain = mana < mana_to_drain and mana or mana_to_drain
		if mana_to_drain > 0 then
			self:GetCursorTarget():SetMana(self:GetCursorTarget():GetMana() - mana_to_drain)
			local dmg = mana_to_drain * (self:GetSpecialValueFor("mana_pct_as_damage") / 100)
			local damageTable = {
								victim = self:GetCursorTarget(),
								attacker = self:GetCaster(),
								damage = dmg,
								damage_type = self:GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self, --Optional.
								}
			ApplyDamage(damageTable)
			local caster_mana = self:GetCaster():GetMana()
			if caster_mana < self:GetCaster():GetMaxMana() then
				self:GetCaster():SetMana(caster_mana + mana_to_drain)
			else
				self:GetCaster():Heal(mana_to_drain, self)
			end
		elseif not self:GetCursorTarget():IsHero() then
			self:GetCaster():Interrupt()
		end
	end
end

function imba_lion_mana_drain:OnChannelFinish(b)
	ParticleManager:DestroyParticle(self.pfx, false)
	ParticleManager:ReleaseParticleIndex(self.pfx)
	self:GetCursorTarget():StopSound("Hero_Lion.ManaDrain")
end

modifier_imba_mana_drain_aura_effect = class({})

function modifier_imba_mana_drain_aura_effect:IsDebuff()			return false end
function modifier_imba_mana_drain_aura_effect:IsHidden() 			return false end
function modifier_imba_mana_drain_aura_effect:IsPurgable() 			return false end
function modifier_imba_mana_drain_aura_effect:IsPurgeException() 	return false end
function modifier_imba_mana_drain_aura_effect:IsAura() return true end
function modifier_imba_mana_drain_aura_effect:GetAuraDuration() return 0.1 end
function modifier_imba_mana_drain_aura_effect:GetModifierAura() return "modifier_imba_mana_drain_hero_effect" end
function modifier_imba_mana_drain_aura_effect:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_mana_drain_aura_effect:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_mana_drain_aura_effect:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_mana_drain_aura_effect:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_mana_drain_hero_effect = class({})

function modifier_imba_mana_drain_hero_effect:IsDebuff()			return true end
function modifier_imba_mana_drain_hero_effect:IsHidden() 			return false end
function modifier_imba_mana_drain_hero_effect:IsPurgable() 			return false end
function modifier_imba_mana_drain_hero_effect:IsPurgeException() 	return false end

function modifier_imba_mana_drain_hero_effect:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval"))
	end
end

function modifier_imba_mana_drain_hero_effect:OnIntervalThink()
	local mana_to_drain = self:GetParent():GetMaxMana() * (self:GetAbility():GetSpecialValueFor("aura_max_mana_drain") / 100) / (1.0 / self:GetAbility():GetSpecialValueFor("interval"))
	mana_to_drain = mana_to_drain < self:GetParent():GetMana() and mana_to_drain or self:GetParent():GetMana()
	if mana_to_drain > 0 then
		self:GetParent():SetMana(self:GetParent():GetMana() - mana_to_drain)
		local caster_mana = self:GetCaster():GetMana()
		if caster_mana < self:GetCaster():GetMaxMana() then
			self:GetCaster():SetMana(caster_mana + mana_to_drain)
		else
			self:GetCaster():Heal(mana_to_drain, self)
		end
	end
end

imba_lion_finger_of_death = class({})

LinkLuaModifier("modifier_imba_finger_of_death_kill", "hero/hero_lion", LUA_MODIFIER_MOTION_NONE)

function imba_lion_finger_of_death:IsHiddenWhenStolen() 	return false end
function imba_lion_finger_of_death:IsRefreshable() 			return true end
function imba_lion_finger_of_death:IsStealable() 			return true end
function imba_lion_finger_of_death:IsNetherWardStealable()	return true end
function imba_lion_finger_of_death:GetManaCost(i) return (1 + (self:GetSpecialValueFor("mana_increase_pct") / 100) * self:GetCaster():GetModifierStackCount("modifier_imba_finger_of_death_kill", self:GetCaster())) * self:GetSpecialValueFor("base_mana_cost") end
function imba_lion_finger_of_death:GetCooldown(i) return self:GetCaster():HasScepter() and self:GetSpecialValueFor("cooldown_scepter") or self:GetSpecialValueFor("cd") end
function imba_lion_finger_of_death:GetAOERadius() return self:GetCaster():HasScepter() and self:GetSpecialValueFor("radius_scepter") or 0 end

function imba_lion_finger_of_death:OnSpellStart()
	self.wait = false
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Lion.FingerOfDeath")
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local enemies = {}
	table.insert(enemies, target)
	local dmg = self:GetSpecialValueFor("damage")
	if caster:HasScepter() then
		dmg = self:GetSpecialValueFor("damage_scepter")
		local enemies2 = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies2) do
			if (enemy:IsStunned() or enemy:IsHexed()) and enemy ~= target then
				enemies[#enemies+1] = enemy
			end
		end
	end
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = dmg,
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		local direction = (enemy:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 2, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 3, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 4, enemy:GetAbsOrigin())
		ParticleManager:SetParticleControlForward(pfx, 3, direction)
		ParticleManager:ReleaseParticleIndex(pfx)
		enemy:EmitSound("Hero_Lion.FingerOfDeathImpact")
		Timers:CreateTimer(self:GetSpecialValueFor("damage_delay"), function()
			local damage_done = ApplyDamage(damageTable)
			return nil
		end
		)
	end
end

function imba_lion_finger_of_death:KillCredit(target) -- set in vscripts/events.lua -- function GameMode:OnEntityKilled( keys )
	if not self.wait and target:IsHero() then
		local buff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_finger_of_death_kill", {duration = self:GetSpecialValueFor("mana_add_duration")})
		buff:SetStackCount(buff:GetStackCount() + 1)
		self.wait = true
		self:EndCooldown()
	end
end

modifier_imba_finger_of_death_kill = class({})

function modifier_imba_finger_of_death_kill:IsDebuff()			return false end
function modifier_imba_finger_of_death_kill:IsHidden() 			return false end
function modifier_imba_finger_of_death_kill:IsPurgable() 		return false end
function modifier_imba_finger_of_death_kill:IsPurgeException() 	return false end
