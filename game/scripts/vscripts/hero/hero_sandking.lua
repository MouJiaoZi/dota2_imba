




CreateEmptyTalents("sandking")


imba_sandking_burrowstrike = class({})

LinkLuaModifier("modifier_burrowstrike_caster_motion", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_burrowstrike_target_motion", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)

function imba_sandking_burrowstrike:IsHiddenWhenStolen() 	return false end
function imba_sandking_burrowstrike:IsRefreshable() 		return true end
function imba_sandking_burrowstrike:IsStealable() 			return true end
function imba_sandking_burrowstrike:IsNetherWardStealable()	return true end
function imba_sandking_burrowstrike:GetCastRange() return self:GetSpecialValueFor("tooltip_range") end

function imba_sandking_burrowstrike:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_burrowstrike.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, pos)
	ParticleManager:ReleaseParticleIndex(pfx)
	local duration = (pos - caster:GetAbsOrigin()):Length2D() / self:GetSpecialValueFor("burrow_speed")
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	caster:AddNewModifier(caster, self, "modifier_burrowstrike_caster_motion", {duration = duration, direction_x = direction.x, direction_y = direction.y, pos_x = pos.x, pos_y = pos.y, pos_z = pos.z})
	caster:StartGesture(ACT_DOTA_SAND_KING_BURROW_IN)
	caster:EmitSound("Ability.SandKing_BurrowStrike")
end

modifier_burrowstrike_caster_motion = class({})

function modifier_burrowstrike_caster_motion:IsMotionController()		return true end
function modifier_burrowstrike_caster_motion:IsDebuff()					return false end
function modifier_burrowstrike_caster_motion:IsHidden() 				return true end
function modifier_burrowstrike_caster_motion:IsPurgable() 				return false end
function modifier_burrowstrike_caster_motion:IsPurgeException() 		return false end
function modifier_burrowstrike_caster_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOW end
function modifier_burrowstrike_caster_motion:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

function modifier_burrowstrike_caster_motion:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.direction = Vector(keys.direction_x, keys.direction_y, 0)
		self.hitted = {}
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.width = self:GetAbility():GetSpecialValueFor("burrow_width")
		self.air_time = self:GetAbility():GetSpecialValueFor("air_time")
		self.stun_time = self:GetAbility():GetSpecialValueFor("burrow_duration")
		self.speed = self:GetAbility():GetSpecialValueFor("burrow_speed")
		self.ability = self:GetAbility()
		self.caster = self:GetCaster()
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_burrowstrike_caster_motion:OnIntervalThink()
	local distance = self.speed / (1.0 / FrameTime())
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + self.direction * distance, nil)
	local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, self.width, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	next_pos.z = next_pos.z - 100
	self:GetParent():SetAbsOrigin(next_pos)
	for _, enemy in pairs(enemies) do
		if not IsInTable(enemy, self.hitted) then
			table.insert(self.hitted, enemy)
			if not enemy:TriggerStandardTargetSpell(self.ability) then
				enemy:AddNewModifier(self.caster, self.ability, "modifier_burrowstrike_target_motion", {duration = self.air_time, pos_x = self.pos.x, pos_y = self.pos.y, pos_z = self.pos.z})
				enemy:AddNewModifier(self.caster, self.ability, "modifier_imba_stunned", {duration = self.stun_time})
				local damageTable = {
									victim = enemy,
									attacker = self.caster,
									damage = self.ability:GetSpecialValueFor("damage"),
									damage_type = self.ability:GetAbilityDamageType(),
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self.ability, --Optional.
									}
				ApplyDamage(damageTable)
			end
		end
	end
end

function modifier_burrowstrike_caster_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self.pos, true)
		self.pos = nil
		self:GetCaster():RemoveGesture(ACT_DOTA_SAND_KING_BURROW_IN)
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_SAND_KING_BURROW_OUT, 3.0)
		self.hitted = nil
		self.width = nil
		self.air_time = nil
		self.stun_time = nil
		self.speed = nil
		self.ability = nil
		self.caster = nil
	end
end

modifier_burrowstrike_target_motion = class({})

function modifier_burrowstrike_target_motion:IsMotionController()	return true end
function modifier_burrowstrike_target_motion:IsDebuff()				return true end
function modifier_burrowstrike_target_motion:IsHidden() 			return true end
function modifier_burrowstrike_target_motion:IsPurgable() 			return false end
function modifier_burrowstrike_target_motion:IsPurgeException() 	return true end
function modifier_burrowstrike_target_motion:IsStunDebuff() 		return true end
function modifier_burrowstrike_target_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_burrowstrike_target_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_burrowstrike_target_motion:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_burrowstrike_target_motion:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_burrowstrike_target_motion:OnRefresh(keys) self:OnCreated(keys) end

function modifier_burrowstrike_target_motion:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.distance = (self.pos - self:GetParent():GetAbsOrigin()):Length2D()
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_burrowstrike_target_motion:OnIntervalThink()
	if self:GetCaster():HasAbility("imba_sandking_treacherous_sands") and self:GetCaster():FindAbilityByName("imba_sandking_treacherous_sands"):GetToggleState() then
		local total_ticks = self:GetDuration() / FrameTime()
		local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
		local height = self:GetAbility():GetSpecialValueFor("air_height")
		local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin(), nil)
		next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
		next_pos = next_pos + (self.pos - self:GetParent():GetAbsOrigin()):Normalized() * (self.distance / total_ticks)
		self:GetParent():SetAbsOrigin(next_pos)
	end
end

function modifier_burrowstrike_target_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self.pos = nil
		self.distance = nil 
	end
end



imba_sandking_sand_storm = class({})

LinkLuaModifier("modifier_sand_storm_caster", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sand_storm_motion", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)

function imba_sandking_sand_storm:IsHiddenWhenStolen() 		return false end
function imba_sandking_sand_storm:IsRefreshable() 			return true end
function imba_sandking_sand_storm:IsStealable() 			return true end
function imba_sandking_sand_storm:IsNetherWardStealable()	return true end
function imba_sandking_sand_storm:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_sandking_sand_storm:GetChannelTime() return self:GetSpecialValueFor("max_duration") end
function imba_sandking_sand_storm:GetChannelAnimation() return ACT_DOTA_OVERRIDE_ABILITY_2 end

function imba_sandking_sand_storm:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_sand_storm_caster")
	caster:AddNewModifier(caster, self, "modifier_sand_storm_caster", {})
	self.dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
	if RollPercentage(30) then
		self.dummy:EmitSound("Imba.SandKingSandStorm")
	else
		self.dummy:EmitSound("Ability.SandKing_SandStorm.loop")
	end
	caster:EmitSound("Ability.SandKing_SandStorm.start")
end

function imba_sandking_sand_storm:OnChannelFinish(bInterrupted)
	local buff = self:GetCaster():FindModifierByName("modifier_sand_storm_caster")
	if buff then
		buff:StartIntervalThink(-1)
		buff:SetDuration(self:GetSpecialValueFor("invis_duration"), true)
	end
	self.dummy:StopSound("Imba.SandKingSandStorm")
	self.dummy:StopSound("Ability.SandKing_SandStorm.loop")
	self.dummy:ForceKill(false)
end

modifier_sand_storm_caster = class({})

function modifier_sand_storm_caster:IsDebuff()			return false end
function modifier_sand_storm_caster:IsHidden() 			return false end
function modifier_sand_storm_caster:IsPurgable() 		return false end
function modifier_sand_storm_caster:IsPurgeException() 	return false end
function modifier_sand_storm_caster:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_sand_storm_caster:GetModifierInvisibilityLevel() return 1 end
function modifier_sand_storm_caster:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true} end

function modifier_sand_storm_caster:OnCreated()
	if IsServer() then
		self.pos = self:GetParent():GetAbsOrigin()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_tick"))
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self.pos)
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor('radius') * 1.3, 1, 1))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_sand_storm_caster:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self.pos, nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = self:GetCaster(),
							damage = self:GetAbility():GetSpecialValueFor("damage"),
							damage_type = self:GetAbility():GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
		if self:GetCaster():HasAbility("imba_sandking_treacherous_sands") and self:GetCaster():FindAbilityByName("imba_sandking_treacherous_sands"):GetToggleState() then
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sand_storm_motion", {duration = 0.2})
		end
	end
end

modifier_sand_storm_motion = class({})

function modifier_sand_storm_motion:IsMotionController()	return true end
function modifier_sand_storm_motion:IsDebuff()				return false end
function modifier_sand_storm_motion:IsHidden() 				return true end
function modifier_sand_storm_motion:IsPurgable() 			return false end
function modifier_sand_storm_motion:IsPurgeException() 		return false end
function modifier_sand_storm_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOWEST end

function modifier_sand_storm_motion:OnCreated()
	if IsServer() then
		self:CheckMotionControllers()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_sand_storm_motion:OnIntervalThink()
	local distance = self:GetAbility():GetSpecialValueFor("wind_force_tooltip")
	distance = distance / (self:GetDuration() / FrameTime())
	local next_pos = self:GetParent():GetAbsOrigin() + (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized() * distance
	self:GetParent():SetAbsOrigin(next_pos)
end

function modifier_sand_storm_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end


imba_sandking_caustic_finale = class({})

LinkLuaModifier("modifier_imba_caustic_finale_passive", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_caustic_finale", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_caustic_finale_slow", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)

function imba_sandking_caustic_finale:GetIntrinsicModifierName() return "modifier_imba_caustic_finale_passive" end

modifier_imba_caustic_finale_passive = class({})

function modifier_imba_caustic_finale_passive:IsDebuff()			return false end
function modifier_imba_caustic_finale_passive:IsHidden() 			return true end
function modifier_imba_caustic_finale_passive:IsPurgable() 			return false end
function modifier_imba_caustic_finale_passive:IsPurgeException() 	return false end
function modifier_imba_caustic_finale_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_caustic_finale_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if not self:GetParent():IsIllusion() and not self:GetParent():PassivesDisabled() and keys.attacker == self:GetParent() and not keys.unit:IsBuilding() and not keys.unit:IsOther() and not keys.unit:IsCourier() and not keys.unit:HasModifier("modifier_imba_caustic_finale") and not keys.unit:IsMagicImmune() then
		if keys.inflictor and (keys.inflictor:GetName() == "imba_sandking_caustic_finale" or keys.inflictor:GetName() == "item_imba_nether_wand" or keys.inflictor:GetName() == "item_imba_elder_staff") then
			return
		end
		keys.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_caustic_finale", {duration = self:GetAbility():GetSpecialValueFor("debuff_duration")})
		return
	end
	if keys.inflictor and keys.inflictor:GetName() == "imba_sandking_caustic_finale" and keys.unit:HasModifier("modifier_imba_caustic_finale") then
		keys.unit:FindModifierByName("modifier_imba_caustic_finale"):Destroy()
	end
end

modifier_imba_caustic_finale = class({})

function modifier_imba_caustic_finale:IsDebuff()			return true end
function modifier_imba_caustic_finale:IsHidden() 			return false end
function modifier_imba_caustic_finale:IsPurgable() 			return true end
function modifier_imba_caustic_finale:IsPurgeException() 	return true end
function modifier_imba_caustic_finale:GetEffectName() return "particles/units/heroes/hero_sandking/sandking_caustic_finale_debuff.vpcf" end
function modifier_imba_caustic_finale:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_caustic_finale:OnDestroy()
	if IsServer() then
		self:GetParent():EmitSound("Ability.SandKing_CausticFinale")
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = self:GetAbility():GetSpecialValueFor("damage"),
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
		end
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_caustic_finale_explode.vpcf", PATTACH_ABSORIGIN, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_caustic_finale_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
	end
end

modifier_imba_caustic_finale_slow = class({})

function modifier_imba_caustic_finale_slow:IsDebuff()			return true end
function modifier_imba_caustic_finale_slow:IsHidden() 			return false end
function modifier_imba_caustic_finale_slow:IsPurgable() 		return true end
function modifier_imba_caustic_finale_slow:IsPurgeException() 	return true end
function modifier_imba_caustic_finale_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_caustic_finale_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("ms_slow")) end

imba_sandking_treacherous_sands = class({})

function imba_sandking_treacherous_sands:IsHiddenWhenStolen() 		return false end
function imba_sandking_treacherous_sands:IsRefreshable() 			return true end
function imba_sandking_treacherous_sands:IsStealable() 				return false end
function imba_sandking_treacherous_sands:IsNetherWardStealable()	return false end

function imba_sandking_treacherous_sands:IsTalentAbility() return true end

function imba_sandking_treacherous_sands:OnOwnerDied()
	self.toggle = self:GetToggleState()
end

function imba_sandking_treacherous_sands:OnOwnerSpawned()
	if self.toggle == nil then
		self:ToggleAbility()
		self.toggle = true
	end
	if self.toggle ~= self:GetToggleState() then
		self:ToggleAbility()
	end
end

function imba_sandking_treacherous_sands:OnToggle()
	self.toggle = self:GetToggleState()
end

imba_sandking_epicenter = class({})

LinkLuaModifier("modifier_imba_epicenter", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_epicenter_slow", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_epicenter_motion", "hero/hero_sandking", LUA_MODIFIER_MOTION_NONE)

function imba_sandking_epicenter:IsHiddenWhenStolen() 		return false end
function imba_sandking_epicenter:IsRefreshable() 			return true end
function imba_sandking_epicenter:IsStealable() 				return true end
function imba_sandking_epicenter:IsNetherWardStealable()	return true end
function imba_sandking_epicenter:GetChannelAnimation() return ACT_DOTA_CAST_ABILITY_4 end

function imba_sandking_epicenter:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Ability.SandKing_Epicenter.spell")
	self.max_stack = self:GetSpecialValueFor("max_pulses") + math.floor(caster:GetLevel() / self:GetSpecialValueFor("levels_per_pulse"))
	self.think_time = self:GetChannelTime() / self.max_stack
	self.buff = caster:AddNewModifier(caster, self, "modifier_imba_epicenter", {})
	self.totaltime = 0
	self.think = 0
	---interval 0.8 1.8
end

function imba_sandking_epicenter:OnChannelThink(time)
	self.totaltime = self.totaltime + time
	self.think = self.think + time
	for i=1, 4 do
		if self.totaltime <= i and i <= self.totaltime + time then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
			ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx, 1, Vector(275 + i*100,1,1))
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
	if self.think <= self.think_time and self.think_time <= self.think + time then
		self.buff:SetStackCount(math.min(self.buff:GetStackCount() + 1, self.max_stack))
		self.think = 0
	end
end

function imba_sandking_epicenter:OnChannelFinish(b)
	local interval = self:GetSpecialValueFor("pulse_duration") / self.buff:GetStackCount()
	if self.buff:GetStackCount() == 0 then
		interval = 0.1
	end
	self.buff:StartIntervalThink(interval)
	self:GetCaster():EmitSound("Ability.SandKing_Epicenter")
end

modifier_imba_epicenter = class({})

function modifier_imba_epicenter:IsDebuff()			return false end
function modifier_imba_epicenter:IsHidden() 		return false end
function modifier_imba_epicenter:IsPurgable() 		return false end
function modifier_imba_epicenter:IsPurgeException() return false end
function modifier_imba_epicenter:RemoveOnDeath() 	return false end
function modifier_imba_epicenter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_epicenter:OnIntervalThink()
	self.radius = self.radius or self:GetAbility():GetSpecialValueFor('base_radius')
	self:DecrementStackCount()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(self.radius,1,1))
	ParticleManager:ReleaseParticleIndex(pfx)
	local damage = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("damage") or self:GetAbility():GetSpecialValueFor("damage_scepter")
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = self:GetCaster(),
							damage = damage,
							damage_type = self:GetAbility():GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
		enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_epicenter_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
	end
	if self:GetCaster():HasAbility("imba_sandking_treacherous_sands") and self:GetCaster():FindAbilityByName("imba_sandking_treacherous_sands"):GetToggleState() then
		local pull_radius = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("pull_radius_scepter") or self:GetAbility():GetSpecialValueFor("pull_radius")
		local enemies_pull = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies_pull) do
			if (enemy:GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("pull_strength") * 2.0 then
				enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_epicenter_motion", {duration = 0.05})
			end
		end
	end
	self.radius = self.radius + self:GetAbility():GetSpecialValueFor("step_radius")
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end

function modifier_imba_epicenter:OnDestroy()
	if IsServer() then
		self.radius = nil
	end
end

modifier_imba_epicenter_slow = class({})

function modifier_imba_epicenter_slow:IsDebuff()			return true end
function modifier_imba_epicenter_slow:IsHidden() 			return false end
function modifier_imba_epicenter_slow:IsPurgable() 			return true end
function modifier_imba_epicenter_slow:IsPurgeException() 	return true end
function modifier_imba_epicenter_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_epicenter_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_ms")) end
function modifier_imba_epicenter_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("slow_as")) end

modifier_imba_epicenter_motion = class({})

function modifier_imba_epicenter_motion:IsMotionController()	return true end
function modifier_imba_epicenter_motion:IsDebuff()				return false end
function modifier_imba_epicenter_motion:IsHidden() 				return true end
function modifier_imba_epicenter_motion:IsPurgable() 			return false end
function modifier_imba_epicenter_motion:IsPurgeException() 		return false end
function modifier_imba_epicenter_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOWEST end

function modifier_imba_epicenter_motion:OnCreated()
	if IsServer() then
		self:CheckMotionControllers()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_epicenter_motion:OnIntervalThink()
	local distance = self:GetAbility():GetSpecialValueFor("pull_strength")
	distance = distance / (self:GetDuration() / FrameTime())
	local next_pos = self:GetParent():GetAbsOrigin() + (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized() * distance
	self:GetParent():SetAbsOrigin(next_pos)
end

function modifier_imba_epicenter_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end
