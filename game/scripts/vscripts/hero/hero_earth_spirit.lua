--hero_earth_spirit.lua

CreateEmptyTalents("earth_spirit")

imba_earth_spirit_stone_caller = class({})

LinkLuaModifier("modifier_imba_stone_remnant_status", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stone_remnant_prevent", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_earth_spirit_stone_caller:IsHiddenWhenStolen() 	return false end
function imba_earth_spirit_stone_caller:IsRefreshable() 		return true end
function imba_earth_spirit_stone_caller:IsStealable() 			return false end
function imba_earth_spirit_stone_caller:IsNetherWardStealable()	return false end
function imba_earth_spirit_stone_caller:IsTalentAbility() return true end

function imba_earth_spirit_stone_caller:CastFilterResultTarget(target)
	if target ~= self:GetCaster() then
		return UF_FAIL_CUSTOM
	end
end

function imba_earth_spirit_stone_caller:GetCustomCastErrorTarget(target) return "dota_hud_error_cant_cast_on_other" end

function imba_earth_spirit_stone_caller:OnUpgrade() AbilityChargeController:AbilityChargeInitialize(self, self:GetSpecialValueFor("charge_restore_time"), self:GetSpecialValueFor("max_charges"), 1, true, true) end

function imba_earth_spirit_stone_caller:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	if self:GetCursorTarget() == caster then
		pos = caster:GetAbsOrigin() + caster:GetForwardVector() * 100
	end
	local stone = CreateUnitByName("npc_imba_earth_spirit_stone", pos, false, caster, caster, caster:GetTeamNumber())
	stone:SetForwardVector(caster:GetForwardVector())
	stone:AddNewModifier(caster, self, "modifier_imba_stone_remnant_status", {})
	stone:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_stone_remnant_status = class({})

function modifier_imba_stone_remnant_status:IsDebuff()				return false end
function modifier_imba_stone_remnant_status:IsHidden() 				return false end
function modifier_imba_stone_remnant_status:IsPurgable() 			return false end
function modifier_imba_stone_remnant_status:IsPurgeException() 		return false end
function modifier_imba_stone_remnant_status:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FROZEN] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_stone_remnant_status:GetStatusEffectName() return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf" end
function modifier_imba_stone_remnant_status:StatusEffectPriority() return 20 end
function modifier_imba_stone_remnant_status:DeclareFunctions() return {MODIFIER_PROPERTY_BONUS_VISION_PERCENTAGE} end
function modifier_imba_stone_remnant_status:GetBonusVisionPercentage() return -1000 end

function modifier_imba_stone_remnant_status:OnCreated()
	if IsServer() then
		if not self:GetParent():IsHero() then
			self:GetParent():EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stoneremnant.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControl(pfx, 1, self:GetParent():GetAbsOrigin() + Vector(0,0,1200))
			self:AddParticle(pfx, false, false, 15, false, false)
		else
			self:GetParent():EmitSound("Hero_EarthSpirit.Petrify")
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_debuff_stoned.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx, false, false, 15, false, false)
		end
	end
end

function modifier_imba_stone_remnant_status:OnDestroy()
	if IsServer() then
		self:GetParent():EmitSound("Hero_EarthSpirit.StoneRemnant.Destroy")
		if self:GetParent():IsHero() then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_shockwave.vpcf", PATTACH_ABSORIGIN, self:GetParent())
			ParticleManager:SetParticleControl(pfx, 3, Vector(self:GetAbility():GetSpecialValueFor("aoe_scepter"),0,0))
			ParticleManager:ReleaseParticleIndex(pfx)
			local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("aoe_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = self:GetCaster(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("damage_scepter"), damage_type = self:GetAbility():GetAbilityDamageType()})
			end
		end
	end
end

modifier_imba_stone_remnant_prevent = class({})

function modifier_imba_stone_remnant_prevent:IsDebuff()			return false end
function modifier_imba_stone_remnant_prevent:IsHidden() 		return false end
function modifier_imba_stone_remnant_prevent:IsPurgable() 		return false end
function modifier_imba_stone_remnant_prevent:IsPurgeException()	return false end
function modifier_imba_stone_remnant_prevent:RemoveOnDeath() return false end

imba_earth_spirit_boulder_smash = class({})

LinkLuaModifier("modifier_imba_boulder_smash_move_to_cast", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_boulder_smash_slow", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_boulder_smash_silent", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_boulder_smash_motion", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_earth_spirit_boulder_smash:IsHiddenWhenStolen() 		return false end
function imba_earth_spirit_boulder_smash:IsRefreshable() 			return true end
function imba_earth_spirit_boulder_smash:IsStealable() 				return true end
function imba_earth_spirit_boulder_smash:IsNetherWardStealable()	return true end
function imba_earth_spirit_boulder_smash:GetCastRange()
	self.range = self.range or 50000
	if IsServer() then
		return self:GetSpecialValueFor("rock_search_aoe") + self.range
	else
		return self:GetSpecialValueFor("rock_search_aoe")
	end
end

function imba_earth_spirit_boulder_smash:CastFilterResultTarget(target)
	if target:IsInvulnerable() then
		return UF_FAIL_INVULNERABLE
	end
	if IsServer() and PlayerResource:IsDisableHelpSetForPlayerID(target:GetPlayerOwnerID(), self:GetCaster():GetPlayerOwnerID()) then
		return UF_FAIL_DISABLE_HELP
	end
	if target == self:GetCaster() or (not target:IsHero() and not target:IsCreep()) then
		return UF_FAIL_CUSTOM
	end
end

function imba_earth_spirit_boulder_smash:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	elseif not target:IsHero() then
		return "dota_hud_error_cant_cast_on_other"
	end
end

function imba_earth_spirit_boulder_smash:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = FindStoneRemnant(caster:GetAbsOrigin(), self:GetSpecialValueFor("rock_search_aoe"))
	if target then
		return true
	end
	target = self:GetCursorTarget()
	if target then
		return true
	end
	if not target then
		target = FindStoneRemnant(self:GetCursorPosition(), self:GetCastRange(caster:GetAbsOrigin(), caster) + caster:GetCastRangeBonus())
		if target then
			local moveToRock = {
		 		UnitIndex = caster:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		 		TargetIndex = nil, --Optional.  Only used when targeting units
		 		AbilityIndex = nil, --Optional.  Only used when casting abilities
		 		Position = target:GetAbsOrigin(), --Optional.  Only used when targeting the ground
		 		Queue = 0 --Optional.  Used for queueing up abilities
	 		}
	 		ExecuteOrderFromTable(moveToRock)
	 		caster:RemoveModifierByName("modifier_imba_boulder_smash_move_to_cast")
	 		caster:AddNewModifier(caster, self, "modifier_imba_boulder_smash_move_to_cast", {rock = target:entindex(), pos = self:GetCursorPosition()})
 		end
 	end
 	return false
end


function imba_earth_spirit_boulder_smash:OnSpellStart()
	local caster = self:GetCaster()
	local target = FindStoneRemnant(caster:GetAbsOrigin(), self:GetSpecialValueFor("rock_search_aoe")) or self:GetCursorTarget()

	if not target then
		self:EndCooldown()
		self:RefundManaCost()
		return
	end

	local pos0 = target:GetAbsOrigin()
	if target:HasModifier("modifier_imba_stone_remnant_status") then
		pos0 = self:GetCursorPosition()
	end
	caster:EmitSound("Hero_EarthSpirit.BoulderSmash.Cast")
	target:EmitSound("Hero_EarthSpirit.BoulderSmash.Target")
	local direction = (pos0 - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local pos = caster:GetAbsOrigin() + direction * 100
	pos = GetGroundPosition(pos, nil)
	if target:HasModifier("modifier_imba_stone_remnant_status") then
		target:SetOrigin(pos)
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_caster.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
	if not target:HasModifier("modifier_imba_stone_remnant_status") and IsEnemy(caster, target) then
		ApplyDamage({victim = target, attacker = caster, damage = self:GetSpecialValueFor("rock_damage"), ability = self, damage_type = self:GetAbilityDamageType()})
	end
	--Motion 
	local speed = self:GetSpecialValueFor("speed")
	local distance = target:HasModifier("modifier_imba_stone_remnant_status") and self:GetSpecialValueFor("rock_distance") or self:GetSpecialValueFor("unit_distance")
	distance = distance + caster:GetCastRangeBonus()
	local duration = distance / speed
	target:RemoveModifierByName("modifier_imba_geomagnetic_grip_motion")
	target:RemoveModifierByName("modifier_imba_boulder_smash_motion")
	target:AddNewModifier(target, self, "modifier_imba_boulder_smash_motion", {duration = duration, direction = direction})
end

modifier_imba_boulder_smash_move_to_cast = class({})

function modifier_imba_boulder_smash_move_to_cast:IsDebuff()			return false end
function modifier_imba_boulder_smash_move_to_cast:IsHidden() 			return true end
function modifier_imba_boulder_smash_move_to_cast:IsPurgable() 			return false end
function modifier_imba_boulder_smash_move_to_cast:IsPurgeException() 	return false end
function modifier_imba_boulder_smash_move_to_cast:DeclareFunctions() return {MODIFIER_EVENT_ON_ORDER} end

function modifier_imba_boulder_smash_move_to_cast:OnOrder(keys)
	if IsServer() and keys.unit == self:GetParent() and keys.order_type ~= DOTA_UNIT_ORDER_CAST_TOGGLE and keys.order_type ~= DOTA_UNIT_ORDER_TRAIN_ABILITY and keys.order_type ~= DOTA_UNIT_ORDER_SELL_ITEM and keys.order_type ~= DOTA_UNIT_ORDER_DISASSEMBLE_ITEM and keys.order_type ~= DOTA_UNIT_ORDER_MOVE_ITEM and keys.order_type ~= DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO and keys.order_type ~= DOTA_UNIT_ORDER_GLYPH then
		if self:GetElapsedTime() > FrameTime() then
			self:Destroy()
		end
	end
end

function modifier_imba_boulder_smash_move_to_cast:OnCreated(keys)
	if IsServer() then
		self.pos = StringToVector(keys.pos)
		self.rock = EntIndexToHScript(keys.rock)
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_boulder_smash_move_to_cast:OnIntervalThink()
	if not self.rock or (self.rock and (self.rock:IsNull() or not self.rock:IsAlive())) then
		self:Destroy()
		return
	end
	local rock = FindStoneRemnant(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("rock_search_aoe"))
	if rock == self.rock then
		self:GetParent():CastAbilityOnPosition(self.pos, self:GetAbility(), self:GetParent():GetPlayerOwnerID())
		self:Destroy()
	end
	--[[local rocks = Entities:FindAllInSphere(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("rock_search_aoe"))
	for _, rock in pairs(rocks) do
		if self.rock and not self.rock:IsNull() and self.rock:IsAlive() and self.rock == rock then
			self:GetParent():CastAbilityOnPosition(self.pos, self:GetAbility(), self:GetParent():GetPlayerOwnerID())
			self:Destroy()
			return
		end
	end]]
end

function modifier_imba_boulder_smash_move_to_cast:OnDestroy()
	if IsServer() then
		self.pos = nil
		self.rock = nil
	end
end

modifier_imba_boulder_smash_motion = class({})

function modifier_imba_boulder_smash_motion:IsDebuff()			return false end
function modifier_imba_boulder_smash_motion:IsHidden() 			return false end
function modifier_imba_boulder_smash_motion:IsPurgable() 		return false end
function modifier_imba_boulder_smash_motion:IsPurgeException() 	return false end
function modifier_imba_boulder_smash_motion:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_imba_boulder_smash_motion:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_boulder_smash_motion:IsMotionController() return true end
function modifier_imba_boulder_smash_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_imba_boulder_smash_motion:OnCreated(keys)
	if IsServer() then
		self.hitted = {}
		self.direction = StringToVector(keys.direction)
		self.distance = self:GetAbility():GetSpecialValueFor("speed") / (1.0 / FrameTime())
		self.radius = self:GetAbility():GetSpecialValueFor("radius")
		self.ability = self:GetAbility()
		self.caster = self.ability:GetCaster()
		self.parent = self:GetParent()
		self:StartIntervalThink(FrameTime())
		if not self:CheckMotionControllers() then
			self:Destroy()
		else
			if self.parent:HasModifier("modifier_imba_stone_remnant_status") then
				local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_pushrocks.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				self:AddParticle(pfx, false, false, 15, false, false)
			end
			local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:SetParticleControlForward(pfx2, 1, self.direction)
			ParticleManager:SetParticleControl(pfx2, 2, Vector(self:GetDuration(), 0, 0))
			ParticleManager:ReleaseParticleIndex(pfx2)
		end
	end
end

function modifier_imba_boulder_smash_motion:OnIntervalThink()
	local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not IsInTable(enemy, self.hitted) then
			self.hitted[#self.hitted+1] = enemy
			if self:GetParent():HasModifier("modifier_imba_stone_remnant_status") then
				if not enemy:IsMagicImmune() then
					enemy:AddNewModifier(self.caster, self.ability, "modifier_imba_stunned", {duration = self.ability:GetSpecialValueFor("stun_duration")})
				else
					enemy:AddNewEarthSpiritModifier(self.caster, self.ability, "modifier_imba_boulder_smash_slow", {duration = self.ability:GetSpecialValueFor("stun_duration")})
				end
				if enemy:IsAttackImmune() then
					enemy:AddNewEarthSpiritModifier(self.caster, self.ability, "modifier_imba_boulder_smash_silent", {duration = self.ability:GetSpecialValueFor("stun_duration")})
				end
			end
			ApplyDamage({victim = enemy, attacker = self.caster, damage = self.ability:GetSpecialValueFor("rock_damage"), ability = self.ability, damage_type = self.ability:GetAbilityDamageType()})
			enemy:EmitSound("Hero_EarthSpirit.BoulderSmash.Damage")
		end
	end
	GridNav:DestroyTreesAroundPoint(self.parent:GetAbsOrigin(), 80, true)
	local distance = self.distance
	local next_pos = self.parent:GetAbsOrigin() + self.direction * distance
	next_pos = GetGroundPosition(next_pos, nil)
	self:GetParent():SetOrigin(next_pos)
end

function modifier_imba_boulder_smash_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self.hitted = {}
		self.direction = nil
		self.distance = nil
		self.radius = nil
		self.ability = nil
		self.caster = nil
		self.parent = nil
	end
end

modifier_imba_boulder_smash_slow = class({})

function modifier_imba_boulder_smash_slow:IsDebuff()			return true end
function modifier_imba_boulder_smash_slow:IsHidden() 			return false end
function modifier_imba_boulder_smash_slow:IsPurgable() 			return true end
function modifier_imba_boulder_smash_slow:IsPurgeException() 	return true end
function modifier_imba_boulder_smash_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_boulder_smash_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("ms_slow")) end
function modifier_imba_boulder_smash_slow:GetEffectName() return "particles/units/heroes/hero_earth_spirit/espirit_bouldersmash_silence.vpcf" end
function modifier_imba_boulder_smash_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_imba_boulder_smash_silent = class({})

function modifier_imba_boulder_smash_silent:IsDebuff()			return true end
function modifier_imba_boulder_smash_silent:IsHidden() 			return false end
function modifier_imba_boulder_smash_silent:IsPurgable() 		return true end
function modifier_imba_boulder_smash_silent:IsPurgeException() 	return true end
function modifier_imba_boulder_smash_silent:GetEffectName() return "particles/generic_gameplay/generic_silence.vpcf" end
function modifier_imba_boulder_smash_silent:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_boulder_smash_silent:ShouldUseOverheadOffset() return true end
function modifier_imba_boulder_smash_silent:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end

imba_earth_spirit_rolling_boulder = class({})

LinkLuaModifier("modifier_imba_rolling_boulder_motion", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rolling_boulder_motion_delay", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rolling_boulder_slow", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rolling_boulder_extra_slow", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_earth_spirit_rolling_boulder:IsHiddenWhenStolen() 	return false end
function imba_earth_spirit_rolling_boulder:IsRefreshable() 			return true end
function imba_earth_spirit_rolling_boulder:IsStealable() 			return true end
function imba_earth_spirit_rolling_boulder:IsNetherWardStealable()	return false end

function imba_earth_spirit_rolling_boulder:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local delay = self:GetSpecialValueFor("delay")
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local speed = self:GetSpecialValueFor("speed")
	local distance = self:GetSpecialValueFor("distance") + caster:GetCastRangeBonus()
	local speed_rock = self:GetSpecialValueFor("rock_speed") + caster:GetCastRangeBonus()
	local distance_rock = self:GetSpecialValueFor("rock_distance")
	caster:AddNewModifier(caster, self, "modifier_imba_rolling_boulder_motion_delay", {duration = delay, direction = direction, speed = speed, distance = distance, speed_rock = speed_rock, distance_rock = distance_rock})
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_ES_ROLL_START, 1.0 / delay)
	caster:EmitSound("Hero_EarthSpirit.RollingBoulder.Cast")
end

modifier_imba_rolling_boulder_motion_delay = class({})

function modifier_imba_rolling_boulder_motion_delay:IsDebuff()			return false end
function modifier_imba_rolling_boulder_motion_delay:IsHidden() 			return true end
function modifier_imba_rolling_boulder_motion_delay:IsPurgable() 		return false end
function modifier_imba_rolling_boulder_motion_delay:IsPurgeException() 	return false end
function modifier_imba_rolling_boulder_motion_delay:DestroyOnExpire()   return false end
function modifier_imba_rolling_boulder_motion_delay:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end

function modifier_imba_rolling_boulder_motion_delay:OnCreated(keys)
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_rollingboulder.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		self.keys = keys
		self.keys['creationtime'] = nil
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_rolling_boulder_motion_delay:OnIntervalThink()
	if self:GetParent():IsStunned() or self:GetParent():IsNightmared() or self:GetParent():IsHexed() then
		self:Destroy()
	end
	if self:GetDuration() <= self:GetElapsedTime() then
		self.keys['duration'] = -1
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_rolling_boulder_motion", self.keys)
		self:StartIntervalThink(-1)
	end
end

modifier_imba_rolling_boulder_motion = class({})

function modifier_imba_rolling_boulder_motion:IsDebuff()			return false end
function modifier_imba_rolling_boulder_motion:IsHidden() 			return true end
function modifier_imba_rolling_boulder_motion:IsPurgable() 			return false end
function modifier_imba_rolling_boulder_motion:IsPurgeException() 	return false end
function modifier_imba_rolling_boulder_motion:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_rolling_boulder_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_rolling_boulder_motion:GetOverrideAnimation() return ACT_DOTA_CAST_ABILITY_2_ES_ROLL end
function modifier_imba_rolling_boulder_motion:IsMotionController() return true end
function modifier_imba_rolling_boulder_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_imba_rolling_boulder_motion:OnCreated(keys)
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
		else
			self.total = 0
			self.parent = self:GetParent()
			self.caster = self:GetCaster()
			self.radius = self:GetAbility():GetSpecialValueFor("radius")
			self.ability = self:GetAbility()
			self.direction = StringToVector(keys.direction)
			self.speed = keys.speed
			self.distance = keys.distance
			self.speed_rock = keys.speed_rock
			self.distance_rock = keys.distance_rock
			self.hitted = {}
			self:StartIntervalThink(FrameTime())
		end
	end
end

function modifier_imba_rolling_boulder_motion:OnIntervalThink()
	if self.parent:IsStunned() then
		self:Destroy()
		return
	end
	local ability = self.ability
	if self:GetStackCount() == 0 then
		local stone = FindStoneRemnant(self.parent:GetAbsOrigin(), self.radius)
		if stone then
			self:SetStackCount(1)
			self.parent:EmitSound("Hero_EarthSpirit.RollingBoulder.Stone")
			stone:RemoveModifierByName("modifier_imba_stone_remnant_status")
			stone:RemoveModifierByName("modifier_kill")
		end

		if self.total >= self.distance then
			self:Destroy()
			return
		end
		local distance = self.speed / (1.0 / FrameTime())
		if self.distance - self.total < distance then
			distance = self.distance - self.total
		end
		local next_pos = GetGroundPosition(self.parent:GetAbsOrigin() + self.direction * distance, nil)
		self.total = self.total + distance
		self.parent:SetOrigin(next_pos)
	end
	if self:GetStackCount() == 1 then
		if self.total >= self.distance_rock then
			self:Destroy()
			return
		end
		local distance = self.speed_rock / (1.0 / FrameTime())
		if self.distance_rock - self.total < distance then
			distance = self.distance_rock - self.total
		end
		local next_pos = GetGroundPosition(self.parent:GetAbsOrigin() + self.direction * distance, nil)
		self.total = self.total + distance
		self.parent:SetOrigin(next_pos)
	end
	GridNav:DestroyTreesAroundPoint(self.parent:GetAbsOrigin(), 80, true)
	local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not IsInTable(enemy, self.hitted) then
			self.hitted[#self.hitted+1] = enemy
			ApplyDamage({victim = enemy, attacker = self.caster, ability = ability, damage = ability:GetSpecialValueFor("damage"), damage_type = ability:GetAbilityDamageType()})
			if self:GetStackCount() == 1 then
				enemy:AddNewEarthSpiritModifier(self.caster, ability, "modifier_imba_rolling_boulder_slow", {duration = ability:GetSpecialValueFor("slow_duration")})
			end
			if enemy:IsTrueHero() then
				enemy:EmitSound("Hero_EarthSpirit.RollingBoulder.Target")
				if not self.caster:HasTalent("special_bonus_imba_earth_spirit_1") then
					self:SetStackCount(2)
					local direction = (enemy:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized()
					self.parent:SetOrigin(enemy:GetAbsOrigin() + direction * 100)
					self:Destroy()
				end
			end
		end
	end
end

function modifier_imba_rolling_boulder_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetOrigin(), true)
		self:GetParent():EmitSound("Hero_EarthSpirit.RollingBoulder.Destroy")
		self:GetParent():StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
		self:GetParent():RemoveModifierByName("modifier_imba_rolling_boulder_motion_delay")
		self.total = nil
		self.parent = nil
		self.caster = nil
		self.radius = nil
		self.ability = nil
		self.direction = nil
		self.speed = nil
		self.distance = nil
		self.speed_rock = nil
		self.distance_rock = nil
		self.hitted = nil
	end
end

modifier_imba_rolling_boulder_slow = class({})

function modifier_imba_rolling_boulder_slow:IsDebuff()			return true end
function modifier_imba_rolling_boulder_slow:IsHidden() 			return false end
function modifier_imba_rolling_boulder_slow:IsPurgable() 		return true end
function modifier_imba_rolling_boulder_slow:IsPurgeException() 	return true end
function modifier_imba_rolling_boulder_slow:DestroyOnExpire() return false end
function modifier_imba_rolling_boulder_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_rolling_boulder_slow:GetModifierMoveSpeedBonus_Percentage() return (self:GetStackCount() == self:GetAbility():GetSpecialValueFor("slow_count") and (0 - self:GetAbility():GetSpecialValueFor("move_slow") or 0)) end

function modifier_imba_rolling_boulder_slow:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("slow_count"))
	end
end

function modifier_imba_rolling_boulder_slow:OnIntervalThink()
	if self:GetElapsedTime() >= self:GetDuration() then
		self:SetStackCount(self:GetStackCount() - 1)
		self:SetDuration(self:GetDuration(), true)
		self:GetParent():RemoveModifierByName("modifier_imba_rolling_boulder_extra_slow")
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_rolling_boulder_extra_slow", {duration = self:GetDuration()})
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

modifier_imba_rolling_boulder_extra_slow = class({})

function modifier_imba_rolling_boulder_extra_slow:IsDebuff()			return true end
function modifier_imba_rolling_boulder_extra_slow:IsHidden() 			return false end
function modifier_imba_rolling_boulder_extra_slow:IsPurgable() 			return true end
function modifier_imba_rolling_boulder_extra_slow:IsPurgeException() 	return true end
function modifier_imba_rolling_boulder_extra_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_rolling_boulder_extra_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("move_slow") * (self:GetRemainingTime() / self:GetDuration())) end


imba_earth_spirit_geomagnetic_grip = class({})

LinkLuaModifier("modifier_imba_geomagnetic_grip_motion", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_geomagnetic_grip_debuff", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_earth_spirit_geomagnetic_grip:IsHiddenWhenStolen() 	return false end
function imba_earth_spirit_geomagnetic_grip:IsRefreshable() 		return true end
function imba_earth_spirit_geomagnetic_grip:IsStealable() 			return true end
function imba_earth_spirit_geomagnetic_grip:IsNetherWardStealable()	return false end

function imba_earth_spirit_geomagnetic_grip:CastFilterResultTarget(target)
	if IsEnemy(target, self:GetCaster()) then
		return UF_FAIL_ENEMY
	end
	if IsServer() and PlayerResource:IsDisableHelpSetForPlayerID(target:GetPlayerOwnerID(), self:GetCaster():GetPlayerOwnerID()) then
		return UF_FAIL_DISABLE_HELP
	end
	if target == self:GetCaster() or not target:IsHero() then
		return UF_FAIL_CUSTOM
	end
end

function imba_earth_spirit_geomagnetic_grip:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	elseif not target:IsHero() then
		return "dota_hud_error_cant_cast_on_other"
	end
end

function imba_earth_spirit_geomagnetic_grip:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or FindStoneRemnant(self:GetCursorPosition(), self:GetSpecialValueFor("radius"))
	if target then
		return true
	end
	return false
end

function imba_earth_spirit_geomagnetic_grip:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget() or FindStoneRemnant(self:GetCursorPosition(), self:GetSpecialValueFor("radius"))
	if not target then
		self:EndCooldown()
		self:RefundManaCost()
		return
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_grip_caster.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(pfx, 10, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
	caster:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Cast")
	target:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Target")
	local direction = (caster:GetAbsOrigin() - target:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	target:RemoveModifierByName("modifier_imba_boulder_smash_motion")
	target:AddNewModifier(target, self, "modifier_imba_geomagnetic_grip_motion", {duration = (target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() / self:GetSpecialValueFor("speed"), direction = direction})
end

modifier_imba_geomagnetic_grip_motion = class({})

function modifier_imba_geomagnetic_grip_motion:IsDebuff()			return false end
function modifier_imba_geomagnetic_grip_motion:IsHidden() 			return true end
function modifier_imba_geomagnetic_grip_motion:IsPurgable() 		return false end
function modifier_imba_geomagnetic_grip_motion:IsPurgeException() 	return false end
function modifier_imba_geomagnetic_grip_motion:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_imba_geomagnetic_grip_motion:CheckState()
	if not IsEnemy(self:GetCaster(), self:GetParent()) then
		return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_STUNNED] = true}
	end
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_STUNNED] = true}
end
function modifier_imba_geomagnetic_grip_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_geomagnetic_grip_motion:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_imba_geomagnetic_grip_motion:IsMotionController() return true end
function modifier_imba_geomagnetic_grip_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOW end

function modifier_imba_geomagnetic_grip_motion:OnCreated(keys)
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
		else
			self.caster = self:GetAbility():GetCaster()
			self.parent = self:GetParent()
			self.ability = self:GetAbility()
			self.radius = self:GetAbility():GetSpecialValueFor("radius")
			self.hitted = {}
			self.direction = StringToVector(keys.direction)
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_geomagentic_grip_target.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControl(pfx, 1, self:GetParent():GetAbsOrigin() - self.direction * 170)
			ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetDuration(),0,0))
			self:AddParticle(pfx, false, false, 15, false, false)
			self:StartIntervalThink(FrameTime())
		end
	end
end

function modifier_imba_geomagnetic_grip_motion:OnIntervalThink()
	if self:GetParent():HasModifier("modifier_imba_stone_remnant_status") then
		local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if not self.hitted[enemy:entindex()] then
				self.hitted[enemy:entindex()] = true
				ApplyDamage({victim = enemy, attacker = self.caster, damage = self.ability:GetSpecialValueFor("rock_damage"), ability = self.ability, damage_type = self.ability:GetAbilityDamageType()})
				enemy:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Damage")
				enemy:EmitSound("Hero_EarthSpirit.GeomagneticGrip.Stun")
				enemy:AddNewEarthSpiritModifier(self.caster, self:GetAbility(), "modifier_imba_geomagnetic_grip_debuff", {duration = self.ability:GetSpecialValueFor("miss_duration")})
			end
		end
	end
	----------
	local distance = self.ability:GetSpecialValueFor("speed") / (1.0 / FrameTime())
	local next_pos = GetGroundPosition(self.parent:GetAbsOrigin() + self.direction * distance, self.parent)
	self.parent:SetOrigin(next_pos)
end

function modifier_imba_geomagnetic_grip_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
		self.direction = nil
		self.hitted = nil
		self.caster = nil
		self.parent = nil
		self.ability = nil
		self.radius = nil
	end
end

modifier_imba_geomagnetic_grip_debuff = class({})

function modifier_imba_geomagnetic_grip_debuff:IsDebuff()			return true end
function modifier_imba_geomagnetic_grip_debuff:IsHidden() 			return false end
function modifier_imba_geomagnetic_grip_debuff:IsPurgable() 		return true end
function modifier_imba_geomagnetic_grip_debuff:IsPurgeException() 	return true end
function modifier_imba_geomagnetic_grip_debuff:GetEffectName() return "particles/generic_gameplay/generic_silence.vpcf" end
function modifier_imba_geomagnetic_grip_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_geomagnetic_grip_debuff:ShouldUseOverheadOffset() return true end
function modifier_imba_geomagnetic_grip_debuff:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_imba_geomagnetic_grip_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MISS_PERCENTAGE} end
function modifier_imba_geomagnetic_grip_debuff:GetModifierMiss_Percentage() return self:GetAbility():GetSpecialValueFor("miss_rate") end

imba_earth_spirit_petrify = class({})

LinkLuaModifier("modifier_imba_petrify_controller", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_petrify_motion", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_earth_spirit_petrify:IsHiddenWhenStolen() 	return false end
function imba_earth_spirit_petrify:IsRefreshable() 			return true end
function imba_earth_spirit_petrify:IsStealable() 			return false end
function imba_earth_spirit_petrify:IsNetherWardStealable()	return false end
function imba_earth_spirit_petrify:ProcsMagicStick()		return false end
function imba_earth_spirit_petrify:IsTalentAbility() return true end
function imba_earth_spirit_petrify:GetIntrinsicModifierName() return "modifier_imba_petrify_controller" end
function imba_earth_spirit_petrify:GetAbilityTextureName() return "earth_spirit_petrify_"..self:GetCaster():GetModifierStackCount("modifier_imba_petrify_controller", nil) end
function imba_earth_spirit_petrify:GetCooldown()
	if IsServer() then
		return (self:GetCaster():HasScepter() and (self:GetCaster() ~= self:GetCursorTarget() and self:GetSpecialValueFor("hero_cooldown_scepter") or 0) or 0)
	else
		return self:GetSpecialValueFor("hero_cooldown_scepter")
	end
end

function imba_earth_spirit_petrify:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target == caster then
		local buff = self:GetCaster():FindModifierByName("modifier_imba_petrify_controller")
		if buff then
			local stack = buff:GetStackCount()
			if stack == 2 then
				buff:SetStackCount(0)
			else
				buff:SetStackCount(buff:GetStackCount()+1)
			end
		end
	elseif caster:HasScepter() then
		if not self:GetCursorTarget():TriggerStandardTargetSpell(self) then
			if not PlayerResource:IsDisableHelpSetForPlayerID(target:GetPlayerOwnerID(), caster:GetPlayerOwnerID()) then
				target:AddNewModifier(caster, self, "modifier_imba_stone_remnant_status", {duration = self:GetSpecialValueFor("duration_scepter")})
			else
				caster:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("duration_scepter")})
				FindClearSpaceForUnit(caster, target:GetAbsOrigin(), true)
			end
		end
	end
end

modifier_imba_petrify_controller = class({})

function modifier_imba_petrify_controller:IsDebuff()			return false end
function modifier_imba_petrify_controller:IsHidden() 			return true end
function modifier_imba_petrify_controller:IsPurgable() 			return false end
function modifier_imba_petrify_controller:IsPurgeException() 	return false end

function modifier_imba_petrify_controller:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_petrify_controller:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.inflictor and keys.inflictor:GetName() == "imba_earth_spirit_magnetize" and not keys.unit:IsMagicImmune() then
		local ability = self:GetAbility()
		local temps = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.unit:GetAbsOrigin(), nil, ability:GetSpecialValueFor("search_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		local enemy = nil
		for _, temp in pairs(temps) do
			if temp ~= keys.unit and temp:HasModifier("modifier_imba_magnetize_debuff") then
				enemy = temp
				break
			end
		end
		if enemy then  -- 1: blue, go 2: red, come
			if self:GetStackCount() == 1 then
				local direction = (keys.unit:GetAbsOrigin() - enemy:GetAbsOrigin()):Normalized()
				local pos = keys.unit:GetAbsOrigin() + direction * ability:GetSpecialValueFor("pull_distance")
				keys.unit:AddNewModifier(keys.unit, nil, "modifier_imba_petrify_motion", {duration = 0, pos = pos})
			elseif self:GetStackCount() == 2 then
				local direction = (enemy:GetAbsOrigin() - keys.unit:GetAbsOrigin()):Normalized()
				local pos = keys.unit:GetAbsOrigin() + direction * ability:GetSpecialValueFor("pull_distance")
				keys.unit:AddNewModifier(keys.unit, nil, "modifier_imba_petrify_motion", {duration = 0, pos = pos})
			end
		end
	end
end

modifier_imba_petrify_motion = class({})

function modifier_imba_petrify_motion:IsDebuff()			return false end
function modifier_imba_petrify_motion:IsHidden() 			return true end
function modifier_imba_petrify_motion:IsPurgable() 			return false end
function modifier_imba_petrify_motion:IsPurgeException() 	return false end
function modifier_imba_petrify_motion:IsMotionController() return true end
function modifier_imba_petrify_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOWEST end

function modifier_imba_petrify_motion:OnCreated(keys)
	if IsServer() then
		if not self:CheckMotionControllers() then
			self:Destroy()
		else
			FindClearSpaceForUnit(self:GetParent(), StringToVector(keys.pos), true)
			self:Destroy()
		end
	end
end

imba_earth_spirit_magnetize = class({})

LinkLuaModifier("modifier_imba_magnetize_debuff", "hero/hero_earth_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_earth_spirit_magnetize:IsHiddenWhenStolen() 		return false end
function imba_earth_spirit_magnetize:IsRefreshable() 			return true end
function imba_earth_spirit_magnetize:IsStealable() 				return true end
function imba_earth_spirit_magnetize:IsNetherWardStealable()	return true end
function imba_earth_spirit_magnetize:GetCastRange() return self:GetSpecialValueFor("cast_radius") - self:GetCaster():GetCastRangeBonus() end

function imba_earth_spirit_magnetize:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	caster:EmitSound("Hero_EarthSpirit.Magnetize.Cast")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("cast_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_imba_magnetize_debuff", {duration = self:GetSpecialValueFor("damage_duration")})
	end
end

modifier_imba_magnetize_debuff = class({})

function modifier_imba_magnetize_debuff:IsDebuff()			return true end
function modifier_imba_magnetize_debuff:IsHidden() 			return false end
function modifier_imba_magnetize_debuff:IsPurgable() 		return false end
function modifier_imba_magnetize_debuff:IsPurgeException() 	return false end

function modifier_imba_magnetize_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
		local pfx = ParticleManager:CreateParticleForPlayer("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("rock_search_radius"),0,0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(10,0,0))
		ParticleManager:SetParticleControl(pfx, 3, Vector(100,0,0))
		ParticleManager:SetParticleControl(pfx, 15, Vector(0,255,0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_magnetize_debuff:OnIntervalThink()
	local parent = self:GetParent()
	parent:EmitSound("Hero_EarthSpirit.Magnetize.Target.Tick")
	local dmg = self:GetAbility():GetSpecialValueFor("damage_per_second") / (1.0 / self:GetAbility():GetSpecialValueFor('damage_interval'))
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnetize_target.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(pfx2, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx2, 2, Vector(self:GetAbility():GetSpecialValueFor("rock_search_radius"),0,0))
	ParticleManager:ReleaseParticleIndex(pfx2)
	ApplyDamage({victim = parent, attacker = self:GetCaster(), ability = self:GetAbility(), damage = dmg, damage_type = self:GetCaster():GetModifierStackCount("modifier_imba_petrify_controller", nil) == 0 and DAMAGE_TYPE_PURE or self:GetAbility():GetAbilityDamageType()})
	local stone = FindStoneRemnant(parent:GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("rock_search_radius"))
	if stone and not parent:IsMagicImmune() then
		stone:EmitSound("Imba.Hero_EarthSpirit.Magnetize.StoneBolt")
		if stone:IsHero() then
			stone:RemoveModifierByName("modifier_imba_stone_remnant_status")
		end
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), parent:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("rock_explosion_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_magnetize_debuff", {duration = self:GetAbility():GetSpecialValueFor("damage_duration")})
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_magnet_arclightning.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(pfx, 0, stone, PATTACH_POINT_FOLLOW, "attach_hitloc", stone:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
end

function modifier_imba_magnetize_debuff:OnDestroy()
	if IsServer() then
		self:GetParent():EmitSound("Hero_EarthSpirit.Magnetize.End")
	end
end