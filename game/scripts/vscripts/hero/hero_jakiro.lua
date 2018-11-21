CreateEmptyTalents("jakiro")

imba_jakiro_fire_breath = class({})

LinkLuaModifier("modifier_imba_jakiro_fire_breath_motion", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fire_breath", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)

function imba_jakiro_fire_breath:IsHiddenWhenStolen() 		return false end
function imba_jakiro_fire_breath:IsRefreshable() 			return true  end
function imba_jakiro_fire_breath:IsStealable() 				return true  end
function imba_jakiro_fire_breath:IsNetherWardStealable() 	return true end

function imba_jakiro_fire_breath:GetAssociatedSecondaryAbilities() return "imba_jakiro_ice_breath" end

function imba_jakiro_fire_breath:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_jakiro_ice_breath")
	if ability and ability:GetLevel() ~= self:GetLevel() then
		ability:SetLevel(self:GetLevel())
	end
end

function imba_jakiro_fire_breath:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Jakiro.DualBreath.Cast", caster)
	local pos = self:GetCursorPosition()
	local distance = (pos - caster:GetAbsOrigin()):Length2D()
	local target_point = caster:GetAbsOrigin() + (pos - caster:GetAbsOrigin()):Normalized() * distance
	local duration = distance / self:GetSpecialValueFor("speed")
	if distance > self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus() then
		target_point = caster:GetAbsOrigin() + (pos - caster:GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus())
		duration = (self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed")
	end
	caster:AddNewModifier(caster, self, "modifier_imba_jakiro_fire_breath_motion", {duration = duration, pos_x = target_point.x, pos_y = target_point.y, pos_z = target_point.z})
end

modifier_imba_jakiro_fire_breath_motion = class({})

function modifier_imba_jakiro_fire_breath_motion:IsMotionController()		return true end
function modifier_imba_jakiro_fire_breath_motion:IsDebuff()					return false end
function modifier_imba_jakiro_fire_breath_motion:IsHidden() 				return true end
function modifier_imba_jakiro_fire_breath_motion:IsPurgable() 				return false end
function modifier_imba_jakiro_fire_breath_motion:IsPurgeException() 		return false end
function modifier_imba_jakiro_fire_breath_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOW end

function modifier_imba_jakiro_fire_breath_motion:OnCreated(keys)
	if IsServer() then
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.direction = (self.pos - self:GetParent():GetAbsOrigin()):Normalized()
		self.current_pos = self:GetParent():GetAbsOrigin()
		self.pfx_tick = 10
		local a = self:CheckMotionControllers() and self:StartIntervalThink(FrameTime()) or 1
		self:OnIntervalThink()
	end
end

function modifier_imba_jakiro_fire_breath_motion:OnIntervalThink()
	local caster = self:GetParent()
	if caster:IsStunned() then
		self:Destroy()
	end
	local distance = (self.current_pos - self.pos):Length2D()
	local next_pos = self.current_pos + distance * (self.direction / (self:GetRemainingTime() / FrameTime()))
	caster:SetAbsOrigin(next_pos)
	caster:SetForwardVector(self.direction)
	if self.pfx_tick == 10 then
		self.pfx_tick = 1
		local breath_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(breath_pfx, 0, self.current_pos)
		ParticleManager:SetParticleControl(breath_pfx, 1, self.direction * self:GetAbility():GetSpecialValueFor("speed") * 1.2 )
		ParticleManager:SetParticleControl(breath_pfx, 3, Vector(0,0,0))
		ParticleManager:SetParticleControl(breath_pfx, 9, self.current_pos)
		Timers:CreateTimer(0.4, function()
			ParticleManager:DestroyParticle(breath_pfx, false)
			ParticleManager:ReleaseParticleIndex(breath_pfx)
		end)
	else
		self.pfx_tick = self.pfx_tick + 1
	end
	local enemies = FindUnitsInCone(caster:GetTeamNumber(), self.direction, self.current_pos, self:GetAbility():GetSpecialValueFor("path_radius") / 2, self:GetAbility():GetSpecialValueFor("spill_radius") / 2, self:GetAbility():GetSpecialValueFor("path_radius"), nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self:GetAbility(), "modifier_imba_fire_breath", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
	self.current_pos = next_pos
	GridNav:DestroyTreesAroundPoint(self.current_pos + self.direction * (self:GetAbility():GetSpecialValueFor("path_radius") / 2), self:GetAbility():GetSpecialValueFor("path_radius") / 2, false)
end

function modifier_imba_jakiro_fire_breath_motion:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		local ice = caster:FindAbilityByName("imba_jakiro_ice_breath")
		local fire = caster:FindAbilityByName("imba_jakiro_fire_breath")
		if ice and fire then
			caster:SwapAbilities("imba_jakiro_ice_breath", "imba_jakiro_fire_breath", true, false)
		end
		self.pos = nil
		self.direction = nil
		self.current_pos = nil
		self.pfx_tick = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

modifier_imba_fire_breath = class({})

function modifier_imba_fire_breath:IsDebuff()			return true end
function modifier_imba_fire_breath:IsHidden() 			return false end
function modifier_imba_fire_breath:IsPurgable() 		return true end
function modifier_imba_fire_breath:IsPurgeException() 	return true end

function modifier_imba_fire_breath:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
	end
end

function modifier_imba_fire_breath:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("damage") / (1.0 / self:GetAbility():GetSpecialValueFor("damage_interval"))
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

function modifier_imba_fire_breath:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE}
end

function modifier_imba_fire_breath:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attack_slow")) end
function modifier_imba_fire_breath:GetModifierTurnRate_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("turn_slow")) end


imba_jakiro_ice_breath = class({})

LinkLuaModifier("modifier_imba_jakiro_ice_breath_motion", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ice_breath", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)

function imba_jakiro_ice_breath:IsHiddenWhenStolen() 		return true end
function imba_jakiro_ice_breath:IsRefreshable() 			return true end
function imba_jakiro_ice_breath:IsStealable() 				return true end
function imba_jakiro_ice_breath:IsNetherWardStealable() 	return true end

function imba_jakiro_ice_breath:GetAssociatedPrimaryAbilities() return "imba_jakiro_fire_breath" end

function imba_jakiro_ice_breath:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_jakiro_fire_breath")
	if ability and ability:GetLevel() ~= self:GetLevel() then
		ability:SetLevel(self:GetLevel())
	end
end

function imba_jakiro_ice_breath:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Jakiro.DualBreath.Cast", caster)
	local pos = self:GetCursorPosition()
	local distance = (pos - caster:GetAbsOrigin()):Length2D()
	local target_point = caster:GetAbsOrigin() + (pos - caster:GetAbsOrigin()):Normalized() * distance
	local duration = distance / self:GetSpecialValueFor("speed")
	if distance > self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus() then
		target_point = caster:GetAbsOrigin() + (pos - caster:GetAbsOrigin()):Normalized() * (self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus())
		duration = (self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()) / self:GetSpecialValueFor("speed")
	end
	caster:AddNewModifier(caster, self, "modifier_imba_jakiro_ice_breath_motion", {duration = duration, pos_x = target_point.x, pos_y = target_point.y, pos_z = target_point.z})
end

modifier_imba_jakiro_ice_breath_motion = class({})

function modifier_imba_jakiro_ice_breath_motion:IsMotionController()		return true end
function modifier_imba_jakiro_ice_breath_motion:IsDebuff()					return false end
function modifier_imba_jakiro_ice_breath_motion:IsHidden() 				return true end
function modifier_imba_jakiro_ice_breath_motion:IsPurgable() 				return false end
function modifier_imba_jakiro_ice_breath_motion:IsPurgeException() 		return false end
function modifier_imba_jakiro_ice_breath_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOW end

function modifier_imba_jakiro_ice_breath_motion:OnCreated(keys)
	if IsServer() then
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.direction = (self.pos - self:GetParent():GetAbsOrigin()):Normalized()
		self.current_pos = self:GetParent():GetAbsOrigin()
		self.pfx_tick = 10
		local a = self:CheckMotionControllers() and self:StartIntervalThink(FrameTime()) or 1
		self:OnIntervalThink()
	end
end

function modifier_imba_jakiro_ice_breath_motion:OnIntervalThink()
	local caster = self:GetParent()
	if caster:IsStunned() then
		self:Destroy()
	end
	local distance = (self.current_pos - self.pos):Length2D()
	local next_pos = self.current_pos + distance * (self.direction / (self:GetRemainingTime() / FrameTime()))
	caster:SetAbsOrigin(next_pos)
	caster:SetForwardVector(self.direction)
	if self.pfx_tick == 10 then
		self.pfx_tick = 1
		local breath_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(breath_pfx, 0, self.current_pos)
		ParticleManager:SetParticleControl(breath_pfx, 1, self.direction * self:GetAbility():GetSpecialValueFor("speed") * 1.2 )
		ParticleManager:SetParticleControl(breath_pfx, 3, Vector(0,0,0))
		ParticleManager:SetParticleControl(breath_pfx, 9, self.current_pos)
		Timers:CreateTimer(0.4, function()
			ParticleManager:DestroyParticle(breath_pfx, false)
			ParticleManager:ReleaseParticleIndex(breath_pfx)
		end)
	else
		self.pfx_tick = self.pfx_tick + 1
	end
	local enemies = FindUnitsInCone(caster:GetTeamNumber(), self.direction, self.current_pos, self:GetAbility():GetSpecialValueFor("path_radius") / 2, self:GetAbility():GetSpecialValueFor("spill_radius") / 2, self:GetAbility():GetSpecialValueFor("path_radius"), nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self:GetAbility(), "modifier_imba_ice_breath", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	end
	self.current_pos = next_pos
	GridNav:DestroyTreesAroundPoint(self.current_pos + self.direction * (self:GetAbility():GetSpecialValueFor("path_radius") / 2), self:GetAbility():GetSpecialValueFor("path_radius") / 2, false)
end

function modifier_imba_jakiro_ice_breath_motion:OnDestroy()
	if IsServer() then
		local caster = self:GetParent()
		local ice = caster:FindAbilityByName("imba_jakiro_ice_breath")
		local fire = caster:FindAbilityByName("imba_jakiro_fire_breath")
		if ice and fire then
			caster:SwapAbilities("imba_jakiro_ice_breath", "imba_jakiro_fire_breath", false, true)
		end
		self.pos = nil
		self.direction = nil
		self.current_pos = nil
		self.pfx_tick = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

modifier_imba_ice_breath = class({})

function modifier_imba_ice_breath:IsDebuff()			return true end
function modifier_imba_ice_breath:IsHidden() 			return false end
function modifier_imba_ice_breath:IsPurgable() 			return true end
function modifier_imba_ice_breath:IsPurgeException() 	return true end

function modifier_imba_ice_breath:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
	end
end

function modifier_imba_ice_breath:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("damage") / (1.0 / self:GetAbility():GetSpecialValueFor("damage_interval"))
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

function modifier_imba_ice_breath:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_imba_ice_breath:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attack_slow")) end
function modifier_imba_ice_breath:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("move_slow")) end

imba_jakiro_liquid_fire = class({})

LinkLuaModifier("modifier_imba_liquid_fire", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_liquid_fire_orb", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)

function imba_jakiro_liquid_fire:IsHiddenWhenStolen() 		return false end
function imba_jakiro_liquid_fire:IsRefreshable() 			return true end
function imba_jakiro_liquid_fire:IsStealable() 				return false end
function imba_jakiro_liquid_fire:IsNetherWardStealable() 	return false end

function imba_jakiro_liquid_fire:GetIntrinsicModifierName() return "modifier_imba_liquid_fire_orb" end

function imba_jakiro_liquid_fire:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("cast_range_tooltip") end

function imba_jakiro_liquid_fire:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local info = 
	{
		Target = target,
		Source = caster,
		SourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("speed"),
		vSourceLoc= caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	projectile = ProjectileManager:CreateTrackingProjectile(info)
end

function imba_jakiro_liquid_fire:OnProjectileHit(target, location)
	local caster = self:GetCaster()
	local enemies =  FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_imba_liquid_fire", {duration = self:GetSpecialValueFor("duration")})
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(pfx, 0, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z + 64))
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("radius")))
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Jakiro.LiquidFire", target)
end

modifier_imba_liquid_fire = class({})

function modifier_imba_liquid_fire:IsDebuff()			return true end
function modifier_imba_liquid_fire:IsHidden() 			return false end
function modifier_imba_liquid_fire:IsPurgable() 		return true end
function modifier_imba_liquid_fire:IsPurgeException() 	return true end

function modifier_imba_liquid_fire:GetEffectName() return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf" end
function modifier_imba_liquid_fire:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_liquid_fire:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
	end
end

function modifier_imba_liquid_fire:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("damage") / (1.0 / self:GetAbility():GetSpecialValueFor("damage_interval"))
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

function modifier_imba_liquid_fire:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_liquid_fire:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attack_slow")) end

modifier_imba_liquid_fire_orb = class({})

function modifier_imba_liquid_fire_orb:IsDebuff()			return false end
function modifier_imba_liquid_fire_orb:IsHidden() 			return true end
function modifier_imba_liquid_fire_orb:IsPurgable() 		return false end
function modifier_imba_liquid_fire_orb:IsPurgeException() 	return false end

function modifier_imba_liquid_fire_orb:OnCreated()
	if IsServer() then
		if self:GetParent():IsRangedAttacker() then
			self.pfx = self:GetParent():GetRangedProjectileName()
		end
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_liquid_fire_orb:OnIntervalThink()
	if self:GetAbility():IsCooldownReady() and self:GetAbility():GetAutoCastState() then
		if self.pfx then
			self:GetParent():SetRangedProjectileName("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf")
		end
		if not self.pfx2 then
			self.pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_ready.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(self.pfx2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
		end
	else
		if self.pfx then
			self:GetParent():SetRangedProjectileName(self.pfx)
		end
		if self.pfx2 then
			ParticleManager:DestroyParticle(self.pfx2, false)
			ParticleManager:ReleaseParticleIndex(self.pfx2)
			self.pfx2 = nil
		end
	end
end

function modifier_imba_liquid_fire_orb:OnDestroy()
	if IsServer() and self.pfx then
		self.pfx = nil
		if self.pfx2 then
			ParticleManager:DestroyParticle(self.pfx2, false)
			ParticleManager:ReleaseParticleIndex(self.pfx2)
			self.pfx2 = nil
		end
	end
end

function modifier_imba_liquid_fire_orb:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_liquid_fire_orb:OnAttack(keys)
	if not IsServer() then
		return 
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsSilenced() or self:GetParent():IsIllusion() or not self:GetAbility():IsCooldownReady() or not self:GetAbility():GetAutoCastState() then
		return
	end
	self:SetStackCount(1)
	self:GetParent():StartGesture(ACT_DOTA_ATTACK2)
	self:GetAbility():UseResources(true, true, true)
end
function modifier_imba_liquid_fire_orb:OnAttackLanded(keys)
	if not IsServer() then
		return 
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() then
		return
	end
	if self:GetStackCount() ~= 1 then
		return
	end
	self:SetStackCount(0)
	self:GetAbility():OnProjectileHit(keys.target, keys.target:GetAbsOrigin())
end

imba_jakiro_macropyre = class({})

LinkLuaModifier("modifier_imba_jakiro_macropyre_pfxthinker", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_jakiro_macropyre_thinker", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_macropyre", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)

function imba_jakiro_macropyre:IsHiddenWhenStolen() 	return false end
function imba_jakiro_macropyre:IsRefreshable() 			return true end
function imba_jakiro_macropyre:IsStealable() 			return true end
function imba_jakiro_macropyre:IsNetherWardStealable() 	return true end

function imba_jakiro_macropyre:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("range") end

function imba_jakiro_macropyre:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local duration = caster:HasScepter() and self:GetSpecialValueFor("duration_scepter") or self:GetSpecialValueFor("duration")
	local trail_angle = self:GetSpecialValueFor("trail_angle") 
	local trail_amount = self:GetSpecialValueFor("trail_amount")
	local path_length = self:GetSpecialValueFor("range") + self:GetCaster():GetCastRangeBonus()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	local start_pos = caster:GetAbsOrigin() + direction * self:GetSpecialValueFor("path_radius")
	local end_pos = start_pos
	local trail_start = ( -1 ) * ( trail_amount - 1 ) / 2
	local trail_end = ( trail_amount - 1 ) / 2
	for i = trail_start, trail_end do
		end_pos = RotatePosition(start_pos, QAngle(0, i * trail_angle, 0), start_pos + direction * path_length)
		local dummy_pfx = CreateModifierThinker(caster, self, "modifier_imba_jakiro_macropyre_pfxthinker", {duration = duration, end_x = end_pos.x, end_y = end_pos.y, end_z = end_pos.z}, start_pos, caster:GetTeamNumber(), false)
		if i == trail_start and not caster:HasScepter() then
			EmitSoundOn("hero_jakiro.macropyre", dummy_pfx)
		end
		if i == trail_start and caster:HasScepter() then
			EmitSoundOn("hero_jakiro.macropyre.scepter", dummy_pfx)
		end
		local total_thinker = math.ceil((end_pos - start_pos):Length2D() / self:GetSpecialValueFor("path_radius"))
		local dummy_direction = (end_pos - start_pos):Normalized()
		local space = (end_pos - start_pos):Length2D() / total_thinker
		for j=0, total_thinker - 1 do
			local dummy_pos = start_pos + dummy_direction * j * space
			CreateModifierThinker(caster, self, "modifier_imba_jakiro_macropyre_thinker", {duration = duration}, dummy_pos, caster:GetTeamNumber(), false)
		end
	end
	EmitSoundOnLocationWithCaster(start_pos, "Hero_Jakiro.Macropyre.Cast", caster)
end

modifier_imba_jakiro_macropyre_pfxthinker = class({})
modifier_imba_jakiro_macropyre_thinker = class({})

function modifier_imba_jakiro_macropyre_pfxthinker:OnCreated(keys)
	if IsServer() then
		local pfx_name = self:GetCaster():HasScepter() and "particles/hero/jakiro/jakiro_macropyre_blue.vpcf" or "particles/hero/jakiro/jakiro_macropyre.vpcf"
		local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(keys.end_x, keys.end_y, keys.end_z))
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetDuration(), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_jakiro_macropyre_pfxthinker:OnDestroy()
	if IsServer() then
		StopSoundOn("hero_jakiro.macropyre", self:GetParent())
	end
end

function modifier_imba_jakiro_macropyre_thinker:IsAura() return true end
function modifier_imba_jakiro_macropyre_thinker:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("stickyness") end
function modifier_imba_jakiro_macropyre_thinker:GetModifierAura() return "modifier_imba_macropyre" end
function modifier_imba_jakiro_macropyre_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("path_radius") end
function modifier_imba_jakiro_macropyre_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_jakiro_macropyre_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_jakiro_macropyre_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

function modifier_imba_jakiro_macropyre_thinker:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_jakiro_macropyre_thinker:OnIntervalThink() GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("path_radius"), false) end

modifier_imba_macropyre = class({})

function modifier_imba_macropyre:IsDebuff()			return true end
function modifier_imba_macropyre:IsHidden() 		return false end
function modifier_imba_macropyre:IsPurgable() 		return false end
function modifier_imba_macropyre:IsPurgeException() return false end

function modifier_imba_macropyre:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("burn_interval"))
	end
end

function modifier_imba_macropyre:OnIntervalThink()
	local dmg = self:GetAbility():GetSpecialValueFor("tooltip_damage") / (1.0 / self:GetAbility():GetSpecialValueFor("burn_interval"))
	if self:GetCaster():HasScepter() then
		dmg = self:GetAbility():GetSpecialValueFor("tooltip_damage_scepter") / (1.0 / self:GetAbility():GetSpecialValueFor("burn_interval"))
		self:SetStackCount(self:GetStackCount() + 1)
		if self:GetStackCount() == self:GetAbility():GetSpecialValueFor("max_stacks_scepter") then
			self:SetStackCount(0)
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_time_scepter")})
		end
	end
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
	local jakiro_debuff = {
	"modifier_imba_fire_breath",
	"modifier_imba_ice_breath",
	"modifier_imba_liquid_fire",}
	for _, buff in pairs(jakiro_debuff) do
		local debuff = self:GetParent():FindModifierByName(buff)
		if debuff then
			debuff:SetDuration(debuff:GetDuration(), true)
		end
	end
end

function modifier_imba_macropyre:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_macropyre:GetEffectName()
	if self:GetCaster():HasScepter() then
		return "particles/generic_gameplay/generic_slowed_cold.vpcf"
	else
		return nil
	end
end

function modifier_imba_macropyre:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_macropyre:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("slow_stack_scepter")) end