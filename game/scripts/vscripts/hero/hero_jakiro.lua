CreateEmptyTalents("jakiro")

imba_jakiro_dual_breath = class({})

LinkLuaModifier("modifier_imba_dual_breath_debuff", "hero/hero_jakiro", LUA_MODIFIER_MOTION_NONE)

function imba_jakiro_dual_breath:IsHiddenWhenStolen() 		return false end
function imba_jakiro_dual_breath:IsRefreshable() 			return true  end
function imba_jakiro_dual_breath:IsStealable() 				return true  end
function imba_jakiro_dual_breath:IsNetherWardStealable() 	return true end
function imba_jakiro_dual_breath:GetCastRange() if IsClient() then return self:GetSpecialValueFor("max_range") end end

function imba_jakiro_dual_breath:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	self.direction = (pos - caster:GetAbsOrigin()):Normalized()
	self.direction.z = 0
end

function imba_jakiro_dual_breath:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	if not caster:IsAlive() then
		return
	end
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
	caster:EmitSound("Hero_Jakiro.DualBreath.Cast")
	local distance = self:GetSpecialValueFor("base_range") + caster:GetCastRangeBonus() + (self:GetSpecialValueFor("max_range") - self:GetSpecialValueFor("base_range")) * math.min(1.0, (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime())
	local speed = self:GetSpecialValueFor("base_speed") + caster:GetCastRangeBonus() + (self:GetSpecialValueFor("max_speed") - self:GetSpecialValueFor("base_speed")) * math.min(1.0, (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime())
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_fire.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = self:GetSpecialValueFor("radius") / 2,
		fEndRadius = self:GetSpecialValueFor("radius") / 2,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = self.direction * speed,
		bProvidesVision = false,
		--ExtraData = {sound = sound:entindex()},
	}
	ProjectileManager:CreateLinearProjectile(info)
	local info2 = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_jakiro/jakiro_dual_breath_ice.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = self:GetSpecialValueFor("radius") / 2,
		fEndRadius = self:GetSpecialValueFor("radius") / 2,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = self.direction * speed,
		bProvidesVision = false,
		--ExtraData = {sound = sound:entindex()},
	}
	ProjectileManager:CreateLinearProjectile(info2)
end

function imba_jakiro_dual_breath:OnProjectileHit(target, pos)
	if not target then
		return
	end
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_dual_breath_debuff", {duration = self:GetSpecialValueFor("duration")})
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
end

modifier_imba_dual_breath_debuff = class({})

function modifier_imba_dual_breath_debuff:IsDebuff()			return true end
function modifier_imba_dual_breath_debuff:IsHidden() 			return false end
function modifier_imba_dual_breath_debuff:IsPurgable() 			return true end
function modifier_imba_dual_breath_debuff:IsPurgeException() 	return true end
function modifier_imba_dual_breath_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_dual_breath_debuff:GetModifierTurnRate_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("turn_slow")) end
function modifier_imba_dual_breath_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("move_slow")) end
function modifier_imba_dual_breath_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attack_slow")) end

function modifier_imba_dual_breath_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("damage_interval"))
	end
end

function modifier_imba_dual_breath_debuff:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local caster = self:GetCaster()
	local dmg = ability:GetSpecialValueFor("damage_per_second") / (1.0 / ability:GetSpecialValueFor("damage_interval"))
	if not parent:IsHero() and (parent:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() > ability:GetSpecialValueFor("base_range") + caster:GetCastRangeBonus() then
		dmg = dmg * (1 - ((parent:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() / ability:GetSpecialValueFor("max_range")))
	end
	ApplyDamage({victim = parent, attacker = caster, ability = ability, damage = dmg, damage_type = ability:GetAbilityDamageType()})
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, parent, dmg, nil)
end

imba_jakiro_ice_path = class({})

function imba_jakiro_ice_path:IsHiddenWhenStolen() 		return false end
function imba_jakiro_ice_path:IsRefreshable() 			return true end
function imba_jakiro_ice_path:IsStealable() 			return true end
function imba_jakiro_ice_path:IsNetherWardStealable() 	return true end

function imba_jakiro_ice_path:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	local length = self:GetCastRange(pos, caster) + caster:GetCastRangeBonus()
	
end

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
	if not target then
		return
	end
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
	direction.z = 0
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
		self:StartIntervalThink(1.0)
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
	"modifier_imba_dual_breath_debuff",
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