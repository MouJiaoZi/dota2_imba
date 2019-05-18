CreateEmptyTalents("storm_spirit")

imba_storm_spirit_static_remnant = class({})

LinkLuaModifier("modifier_imba_static_remnant_thinker", "hero/hero_storm_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_storm_spirit_static_remnant:IsHiddenWhenStolen() 		return false end
function imba_storm_spirit_static_remnant:IsRefreshable() 			return true end
function imba_storm_spirit_static_remnant:IsStealable() 			return true end
function imba_storm_spirit_static_remnant:IsNetherWardStealable()	return true end
function imba_storm_spirit_static_remnant:GetCastRange() return self:GetSpecialValueFor("static_remnant_radius") - self:GetCaster():GetCastRangeBonus() end

function imba_storm_spirit_static_remnant:OnSpellStart(location)
	local caster = self:GetCaster()
	local pos = location or caster:GetAbsOrigin()
	caster:EmitSound("Hero_StormSpirit.StaticRemnantPlant")
	CreateModifierThinker(caster, self, "modifier_imba_static_remnant_thinker", {duration = self:GetSpecialValueFor("duration")}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_static_remnant_thinker = class({})

function modifier_imba_static_remnant_thinker:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControlForward(pfx, 0, self:GetCaster():GetForwardVector())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		local gesture = math.random(84, 96)
		local steal_gesture = {53, 59, 65, 66, 70, 77, 88, 101, 114, 121}
		if self:GetAbility():IsStolen() then
			gesture = RandomFromTable(steal_gesture)
		end
		ParticleManager:SetParticleControl(pfx, 2, Vector(gesture, self:GetCaster():GetModelScale(), 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_static_remnant_thinker:OnIntervalThink()
	local ability = self:GetAbility()
	if self:GetElapsedTime() < ability:GetSpecialValueFor("static_remnant_delay") then
		return
	end
	local caster = self:GetCaster()
	local pos = self:GetParent():GetAbsOrigin()
	local checks = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, ability:GetSpecialValueFor("static_remnant_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	if #checks > 0 then
		self:Destroy()
	end
	AddFOWViewer(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), ability:GetSpecialValueFor("static_remnant_radius"), 0.3, false)
end

function modifier_imba_static_remnant_thinker:OnDestroy()
	if not IsServer() then
		return
	end
	self:GetParent():EmitSound("Hero_StormSpirit.StaticRemnantExplode")
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local pos = self:GetParent():GetAbsOrigin()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, ability:GetSpecialValueFor("static_remnant_damage_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, ability, "modifier_paralyzed", {duration = ability:GetSpecialValueFor("slow_duration") + caster:GetTalentValue("special_bonus_imba_storm_spirit_1")})
		ApplyDamage({victim = enemy, attacker = caster, ability = ability, damage_type = ability:GetAbilityDamageType(), damage = ability:GetSpecialValueFor("static_remnant_damage")})
	end
end

imba_storm_spirit_electric_vortex = class({})

LinkLuaModifier("modifier_imba_electric_vortex_motion", "hero/hero_storm_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_storm_spirit_electric_vortex:IsHiddenWhenStolen() 	return false end
function imba_storm_spirit_electric_vortex:IsRefreshable() 			return true end
function imba_storm_spirit_electric_vortex:IsStealable() 			return true end
function imba_storm_spirit_electric_vortex:IsNetherWardStealable()	return true end
function imba_storm_spirit_electric_vortex:GetBehavior()
	if not self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	end
end

function imba_storm_spirit_electric_vortex:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target and target:TriggerStandardTargetSpell(self) then
		return
	end
	local max_target = caster:HasScepter() and 9999 or self:GetSpecialValueFor("extra_target")
	local target_enemies = {}
	if target then
		target_enemies[#target_enemies + 1] = target
	end
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, max_target do
		if enemies[i] and not IsInTable(enemies[i], target_enemies) then
			target_enemies[#target_enemies + 1] = enemies[i]
		end
	end
	if target_enemies[1] then
		target_enemies[1]:EmitSound("Hero_StormSpirit.ElectricVortex")
	end
	for _, enemy in pairs(target_enemies) do
		enemy:AddNewModifier(caster, self, "modifier_imba_electric_vortex_motion", {duration = self:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_imba_storm_spirit_2")})
	end
	caster:EmitSound("Hero_StormSpirit.ElectricVortexCast")

	local ability = caster:FindAbilityByName("imba_storm_spirit_static_remnant")
	if ability and ability:GetLevel() > 0 then
		local pos = caster:GetAbsOrigin() + caster:GetForwardVector():Normalized() * self:GetSpecialValueFor("radius")
		local remnants = self:GetSpecialValueFor("remnant_counts")
		for i=1, remnants do
			local pos0 = RotatePosition(caster:GetAbsOrigin(), QAngle(0, i*(360/remnants), 0), pos)
			pos0 = GetGroundPosition(pos0, caster)
			ability:OnSpellStart(pos0)
		end
	end
end

modifier_imba_electric_vortex_motion = class({})

function modifier_imba_electric_vortex_motion:IsDebuff()			return true end
function modifier_imba_electric_vortex_motion:IsHidden() 			return false end
function modifier_imba_electric_vortex_motion:IsPurgable() 			return false end
function modifier_imba_electric_vortex_motion:IsPurgeException() 	return true end
function modifier_imba_electric_vortex_motion:IsMotionController() return true end
function modifier_imba_electric_vortex_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_electric_vortex_motion:IsStunDebuff() return true end
function modifier_imba_electric_vortex_motion:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_electric_vortex_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_electric_vortex_motion:GetOverrideAnimation() return ACT_DOTA_FLAIL end

function modifier_imba_electric_vortex_motion:OnCreated()
	if IsServer() then
		self:CheckMotionControllers()
		self.pos = self:GetCaster():GetAbsOrigin()
		self:StartIntervalThink(FrameTime())
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_electric_vortex_motion:OnIntervalThink()
	local distance = self:GetAbility():GetSpecialValueFor("electric_vortex_pull_units_per_second") / (1.0 / FrameTime())
	local direction = (self.pos - self:GetParent():GetAbsOrigin()):Normalized()
	local pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + direction * distance, nil)
	self:GetParent():SetAbsOrigin(pos)
end

function modifier_imba_electric_vortex_motion:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_StormSpirit.ElectricVortex")
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self.pos = nil
	end
end

imba_storm_spirit_overload = class({}) --overload

LinkLuaModifier("modifier_imba_overload_passive", "hero/hero_storm_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_overload_effect", "hero/hero_storm_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_overload_slow", "hero/hero_storm_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_storm_spirit_overload:GetIntrinsicModifierName() return "modifier_imba_overload_passive" end

modifier_imba_overload_passive = class({})

function modifier_imba_overload_passive:IsDebuff()			return false end
function modifier_imba_overload_passive:IsHidden() 			return true end
function modifier_imba_overload_passive:IsPurgable() 		return false end
function modifier_imba_overload_passive:IsPurgeException() 	return false end
function modifier_imba_overload_passive:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_overload_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_overload_passive:OnAbilityExecuted(keys)
	if not IsServer() or keys.ability:IsItem() or keys.unit ~= self:GetParent() then
		return
	end
	self:GetParent():AddModifierStacks(self:GetParent(), self:GetAbility(), "modifier_imba_overload_effect", {}, 1, false, true)
end

function modifier_imba_overload_passive:OnAttackLanded(keys)
	if not IsServer() or keys.attacker ~= self:GetParent() then
		return
	end
	if keys.target:IsBuilding() or keys.target:IsCourier() or not keys.target:IsAlive() then
		return
	end
	local caster = self:GetParent()
	local ability = self:GetAbility()
	if caster:HasModifier("modifier_imba_overload_effect") or PseudoRandom:RollPseudoRandom(self:GetAbility(), ability:GetSpecialValueFor("passive_chance")) then
		local stacks = caster:GetModifierStackCount("modifier_imba_overload_effect", nil)
		if stacks == 0 then
			stacks = 1
		end
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("overload_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = caster, ability = ability, damage = ability:GetSpecialValueFor("damage"), damage_type = ability:GetAbilityDamageType()})
			enemy:AddNewModifier(caster, ability, "modifier_imba_overload_slow", {duration = ability:GetSpecialValueFor("duration") * stacks})
		end
		caster:RemoveModifierByName("modifier_imba_overload_effect")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf", PATTACH_ABSORIGIN, keys.target)
		ParticleManager:ReleaseParticleIndex(pfx)
		keys.target:EmitSound("Hero_StormSpirit.Overload")
	end
end

modifier_imba_overload_effect = class({})

function modifier_imba_overload_effect:IsDebuff()			return false end
function modifier_imba_overload_effect:IsHidden() 			return false end
function modifier_imba_overload_effect:IsPurgable() 		return false end
function modifier_imba_overload_effect:IsPurgeException() 	return false end
function modifier_imba_overload_effect:DeclareFunctions() return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS} end
function modifier_imba_overload_effect:GetActivityTranslationModifiers() return "overload" end

function modifier_imba_overload_effect:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_imba_overload_slow = class({})

function modifier_imba_overload_slow:IsDebuff()			return true end
function modifier_imba_overload_slow:IsHidden() 		return false end
function modifier_imba_overload_slow:IsPurgable() 		return true end
function modifier_imba_overload_slow:IsPurgeException() return true end
function modifier_imba_overload_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_overload_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("overload_move_slow")) end
function modifier_imba_overload_slow:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("overload_attack_slow")) end

imba_storm_spirit_ball_lightning = class({})

LinkLuaModifier("modifier_imba_ball_lightning_travel", "hero/hero_storm_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ball_lightning_mana_penalty", "hero/hero_storm_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_storm_spirit_ball_lightning:IsHiddenWhenStolen() 		return false end
function imba_storm_spirit_ball_lightning:IsRefreshable() 			return true end
function imba_storm_spirit_ball_lightning:IsStealable() 			return true end
function imba_storm_spirit_ball_lightning:IsNetherWardStealable()	return false end
function imba_storm_spirit_ball_lightning:GetManaCost() return (self:GetSpecialValueFor("ball_lightning_initial_mana_base") + self:GetCaster():GetMaxMana() * (self:GetSpecialValueFor("ball_lightning_initial_mana_percentage") / 100)) * (1 + self:GetCaster():GetModifierStackCount("modifier_imba_ball_lightning_mana_penalty", nil) * (self:GetSpecialValueFor("mana_penalty_pct") / 100)) end

function imba_storm_spirit_ball_lightning:GetCastRange() return (IsServer() and 9999999 or self:GetSpecialValueFor("ball_lightning_aoe")) end

function imba_storm_spirit_ball_lightning:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	caster:AddNewModifier(caster, self, "modifier_invulnerable", {duration = self:GetSpecialValueFor("cast_invul_duration")})
	caster:AddNewModifier(caster, self, "modifier_imba_ball_lightning_travel", {pos_x = pos.x, pos_y = pos.y, pos_z = pos.z})
	ProjectileManager:ProjectileDodge(caster)
	if (caster:GetAbsOrigin() - pos):Length2D() >= self:GetSpecialValueFor("mana_penalty_distance") then
		caster:AddModifierStacks(caster, self, "modifier_imba_ball_lightning_mana_penalty", {}, 1, false, true):SetDuration(-1, true)
	end
end

modifier_imba_ball_lightning_travel = class({})

function modifier_imba_ball_lightning_travel:IsDebuff()			return false end
function modifier_imba_ball_lightning_travel:IsHidden() 		return false end
function modifier_imba_ball_lightning_travel:IsPurgable() 		return false end
function modifier_imba_ball_lightning_travel:IsPurgeException() return false end
function modifier_imba_ball_lightning_travel:IsMotionController() return true end
function modifier_imba_ball_lightning_travel:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_imba_ball_lightning_travel:CheckState() return {[MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_ball_lightning_travel:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_ball_lightning_travel:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_4 end

function modifier_imba_ball_lightning_travel:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.start_pos = self:GetParent():GetAbsOrigin()
		self.current_pos = self:GetParent():GetAbsOrigin()
		self.ability = self:GetAbility()
		self:StartIntervalThink(FrameTime())
		self:GetParent():EmitSound("Hero_StormSpirit.BallLightning")
		self:GetParent():EmitSound("Hero_StormSpirit.BallLightning.Loop")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_pos, true)
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self.current_pos, true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_ball_lightning_travel:OnIntervalThink()
	self.current_pos = self:GetParent():GetAbsOrigin()
	if (self.current_pos - self.pos):Length2D() <= 50 or self:GetParent():IsStunned() or self:GetParent():IsSilenced() or self:GetParent():IsHexed() then
		self:Destroy()
		return
	end
	AddFOWViewer(self:GetParent():GetTeamNumber(), self.current_pos, self.ability:GetSpecialValueFor("ball_lightning_vision_radius"), 0.1, false)
	self:SetStackCount((self.current_pos - self.start_pos):Length2D())
	local direction = (self.pos - self:GetParent():GetAbsOrigin()):Normalized()
	local distance = (self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), false) * ((self.ability:GetSpecialValueFor("ball_lightning_move_speed") + self:GetParent():GetTalentValue("special_bonus_imba_storm_spirit_3")) / 100)) / (1.0 / FrameTime())
	if distance > (self.current_pos - self.pos):Length2D() then
		distance = (self.current_pos - self.pos):Length2D()
	end
	local next_pos = GetGroundPosition(self.current_pos + direction * distance, nil)
	self:GetParent():SetAbsOrigin(next_pos)
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 180, true)
end

function modifier_imba_ball_lightning_travel:OnDestroy()
	if IsServer() then
		local damage = self:GetStackCount() / 100 * self.ability:GetSpecialValueFor("travel_damage")
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self:GetParent(), damage, nil)
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("ball_lightning_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = damage, ability = self.ability, damage_type = self.ability:GetAbilityDamageType()})
		end
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self:GetParent():RemoveModifierByName("modifier_invulnerable")
		self:GetParent():StopSound("Hero_StormSpirit.BallLightning.Loop")
		self.pos = nil
		self.start_pos = nil
		self.current_pos = nil
		self.ability = nil
		self.talent_travel = nil
	end
end

modifier_imba_ball_lightning_mana_penalty = class({})

function modifier_imba_ball_lightning_mana_penalty:IsDebuff()			return false end
function modifier_imba_ball_lightning_mana_penalty:IsHidden() 			return false end
function modifier_imba_ball_lightning_mana_penalty:IsPurgable() 		return false end
function modifier_imba_ball_lightning_mana_penalty:IsPurgeException() 	return false end
function modifier_imba_ball_lightning_mana_penalty:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_ball_lightning_mana_penalty:AllowIllusionDuplicate() return false end
function modifier_imba_ball_lightning_mana_penalty:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_TOOLTIP} end

function modifier_imba_ball_lightning_mana_penalty:OnTooltip() return self:GetAbility():GetSpecialValueFor("mana_penalty_pct") * self:GetStackCount() end

function modifier_imba_ball_lightning_mana_penalty:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and IsEnemy(keys.unit, keys.attacker) and keys.unit:IsHero() then
		if self:GetDuration() <= 0 then
			self:SetDuration(self:GetAbility():GetSpecialValueFor("mana_penalty_remove_delay"), true)
		end
	end
end