CreateEmptyTalents("mirana")

local function StarFallAttack(ability, caster, target, damage)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:ReleaseParticleIndex(pfx)
	Timers:CreateTimer(0.57, function()
		local damageTable = {
							victim = target,
							attacker = caster,
							damage = damage,
							damage_type = ability:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = ability, --Optional.
							}
		ApplyDamage(damageTable)
		target:EmitSound("Ability.StarfallImpact")
		return nil
	end
	)
end

imba_mirana_starfall = class({})

LinkLuaModifier("modifier_imba_starfall_debuff", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)

function imba_mirana_starfall:IsHiddenWhenStolen() 		return false end
function imba_mirana_starfall:IsRefreshable() 			return true end
function imba_mirana_starfall:IsStealable() 			return true end
function imba_mirana_starfall:IsNetherWardStealable()	return true end
function imba_mirana_starfall:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_mirana_starfall:OnUpgrade() local a = self:GetCaster():FindAbilityByName("imba_mirana_cosmic_dust") and self:GetCaster():FindAbilityByName("imba_mirana_cosmic_dust"):SetLevel(self:GetLevel()) or 1 end
function imba_mirana_starfall:GetAssociatedSecondaryAbilities() return "imba_mirana_cosmic_dust" end

function imba_mirana_starfall:OnSpellStart()
	local caster = self:GetCaster()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_circle.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
	AddFOWViewer(caster:GetTeam(), caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("vision_duration"), true)
	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		StarFallAttack(self, caster, enemy, self:GetSpecialValueFor("damage"))
		enemy:AddNewModifier(caster, self, "modifier_imba_starfall_debuff", {duration = self:GetSpecialValueFor("secondary_duration")})
	end
	caster:EmitSound("Ability.Starfall")
	local ability = caster:FindAbilityByName("imba_mirana_cosmic_dust")
	if ability and ability:GetAutoCastState() and (not GameRules:IsDaytime() or caster:HasScepter()) and ability:IsCooldownReady() then
		ability:OnSpellStart()
		ability:UseResources(true, true, true)
	end
end

modifier_imba_starfall_debuff = class({})

function modifier_imba_starfall_debuff:IsDebuff()			return true end
function modifier_imba_starfall_debuff:IsHidden() 			return false end
function modifier_imba_starfall_debuff:IsPurgable() 		return true end
function modifier_imba_starfall_debuff:IsPurgeException() 	return true end
function modifier_imba_starfall_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_starfall_debuff:GetEffectName() return "particles/hero/mirana/mirana_cosmic_dust.vpcf" end
function modifier_imba_starfall_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_starfall_debuff:ShouldUseOverheadOffset() return true end
function modifier_imba_starfall_debuff:OnDestroy()
	if IsServer() then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("secondary_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
		for _,enemy in pairs(enemies) do
			StarFallAttack(self:GetAbility(), self:GetCaster(), enemy, self:GetAbility():GetSpecialValueFor("damage"))
		end
	end
end

imba_mirana_arrow = class({})

LinkLuaModifier("modifier_imba_mirana_arrow_thinker", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)

function imba_mirana_arrow:IsHiddenWhenStolen() 	return false end
function imba_mirana_arrow:IsRefreshable() 			return true end
function imba_mirana_arrow:IsStealable() 			return true end
function imba_mirana_arrow:IsNetherWardStealable()	return true end

function imba_mirana_arrow:OnSpellStart()
	local caster = self:GetCaster()
	local direction = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	caster:EmitSound("Hero_Mirana.ArrowCast")
	local thinker = CreateModifierThinker(caster, self, "modifier_imba_mirana_arrow_thinker", {}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false):entindex()
	EntIndexToHScript(thinker):EmitSound("Hero_Mirana.Arrow")
	local info = 
	{
		Ability = self,
		EffectName = "",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = 90000,
		fStartRadius = self:GetSpecialValueFor("arrow_width"),
		fEndRadius = self:GetSpecialValueFor("arrow_width"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 90.0,
		bDeleteOnHit = true,
		vVelocity = direction * self:GetSpecialValueFor("arrow_speed"),
		bProvidesVision = false,
		ExtraData = {thinker = thinker}
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function imba_mirana_arrow:OnProjectileThink_ExtraData(location, keys)
	AddFOWViewer(self:GetCaster():GetTeam(), location, self:GetSpecialValueFor("arrow_vision"), 0.03, false)
	local pos = GetGroundPosition(location, nil)
	EntIndexToHScript(keys.thinker):SetOrigin(Vector(pos.x,pos.y,pos.z+200))
end

function imba_mirana_arrow:OnProjectileHit_ExtraData(target, location, keys)
	local kill_creeps = self:GetCaster():HasScepter() or not GameRules:IsDaytime()
	if not target then
		EntIndexToHScript(keys.thinker):ForceKill(false)
		return true
	end
	if kill_creeps and not target:IsBoss() and not target:IsAncient() and not target:IsRealHero() then
		target:Kill(self, self:GetCaster())
		return false
	end
	if IsNearEnemyFountain(location, self:GetCaster():GetTeamNumber(), 1200) then
		return false
	end
	local buff = EntIndexToHScript(keys.thinker):FindModifierByName("modifier_imba_mirana_arrow_thinker")
	local distance = self:GetSpecialValueFor("arrow_speed") * buff:GetElapsedTime()
	local stun_duration = math.max((math.min(1.0, distance / self:GetSpecialValueFor("arrow_max_stunrange")) * self:GetSpecialValueFor("arrow_max_stun")), self:GetSpecialValueFor("arrow_min_stun"))
	local dmg = self:GetSpecialValueFor("base_damage")
	if distance > self:GetSpecialValueFor("arrow_max_stunrange") then
		local pct_dmg = math.min((distance - self:GetSpecialValueFor("arrow_max_stunrange")) / 1000 * self:GetSpecialValueFor("arrow_bonus_damage"), self:GetSpecialValueFor("arrow_max_damage"))
		dmg = dmg + target:GetMaxHealth() * (pct_dmg / 100)
	end
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_stunned", {duration = stun_duration})
	EntIndexToHScript(keys.thinker):ForceKill(false)
	local damageTable = {
						victim = target,
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	local dmg_done = ApplyDamage(damageTable)
	AddFOWViewer(self:GetCaster():GetTeam(), location, self:GetSpecialValueFor("arrow_vision"), stun_duration, false)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, target, dmg_done, nil)
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Mirana.ArrowImpact", target)
	return true
end

modifier_imba_mirana_arrow_thinker = class({})
function modifier_imba_mirana_arrow_thinker:GetEffectName() return "particles/hero/mirana/mirana_sacred_arrow.vpcf" end
function modifier_imba_mirana_arrow_thinker:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

imba_mirana_leap = class({})

LinkLuaModifier("modifier_imba_leap", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_leap_motion", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_leap_day", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)

function imba_mirana_leap:IsHiddenWhenStolen() 		return false end
function imba_mirana_leap:IsRefreshable() 			return true end
function imba_mirana_leap:IsStealable() 			return true end
function imba_mirana_leap:IsNetherWardStealable()	return true end
function imba_mirana_leap:GetIntrinsicModifierName() return "modifier_imba_leap_day" end
function imba_mirana_leap:GetCastRange() return ((self:GetCaster():GetModifierStackCount("modifier_imba_leap_day", self:GetCaster()) == 0 or self:GetCaster():HasScepter()) and 50000 or self:GetSpecialValueFor("base_distance")) end

function imba_mirana_leap:OnSpellStart()
	local caster = self:GetCaster() 
	local pos = self:GetCursorPosition()
	local distance = (pos - caster:GetAbsOrigin()):Length2D()
	local time = distance / self:GetSpecialValueFor("min_speed")
	local extra_cd = math.max(0, (distance - self:GetSpecialValueFor("base_distance")) / self:GetSpecialValueFor("base_distance")) * self:GetSpecialValueFor("cooldown_increase")
	local height = self:GetSpecialValueFor("base_height") + math.min(math.max(0, (distance - self:GetSpecialValueFor("base_distance")) / self:GetSpecialValueFor("base_distance")) * self:GetSpecialValueFor("height_step"), self:GetSpecialValueFor("max_height"))
	self:EndCooldown()
	self:StartCooldown((self:GetCooldown(self:GetLevel() - 1) + extra_cd) * (1 - caster:GetCooldownReduction() / 100))
	caster:AddNewModifier(caster, self, "modifier_imba_leap_motion", {duration = time, pos_x = pos.x, pos_y = pos.y, pos_z = pos.z, height = height})
	--caster:StartGesture(ACT_DOTA_CAST3_STATUE)
	caster:EmitSound("Ability.Leap")
end

modifier_imba_leap_day = class({})  -- use this to know day and night

function modifier_imba_leap_day:IsDebuff()			return false end
function modifier_imba_leap_day:IsHidden() 			return true end
function modifier_imba_leap_day:IsPurgable() 		return false end
function modifier_imba_leap_day:IsPurgeException() 	return false end
function modifier_imba_leap_day:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end
function modifier_imba_leap_day:OnIntervalThink()
	if GameRules:IsDaytime() then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

modifier_imba_leap_motion = class({})

function modifier_imba_leap_motion:IsDebuff()			return false end
function modifier_imba_leap_motion:IsHidden() 			return true end
function modifier_imba_leap_motion:IsPurgable() 		return false end
function modifier_imba_leap_motion:IsPurgeException() 	return false end
function modifier_imba_leap_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_leap_motion:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_3 end
function modifier_imba_leap_motion:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_leap_motion:IsMotionController() return true end
function modifier_imba_leap_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_imba_leap_motion:OnCreated(keys)
	if IsServer() then
		if self:CheckMotionControllers() then
			self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
			self.height = keys.height
			self:OnIntervalThink()
			self:StartIntervalThink(FrameTime())
		else
			self:Destroy()
		end
	end
end

function modifier_imba_leap_motion:OnIntervalThink()
	local total_ticks = self:GetDuration() / FrameTime()
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local distance = self:GetAbility():GetSpecialValueFor("min_speed") / (1.0 / FrameTime())
	local height = self.height
	local direction = (self.pos - self:GetParent():GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + direction * distance, nil)
	next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
	self:GetParent():SetOrigin(next_pos)
	local allies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), next_pos, nil, self:GetAbility():GetSpecialValueFor("buff_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		ally:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_leap", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
	end
end

function modifier_imba_leap_motion:OnDestroy()
	if IsServer() then
		self.pos = nil
		self.height = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

modifier_imba_leap = class({})

function modifier_imba_leap:IsDebuff()			return false end
function modifier_imba_leap:IsHidden() 			return false end
function modifier_imba_leap:IsPurgable() 		return true end
function modifier_imba_leap:IsPurgeException() 	return true end
function modifier_imba_leap:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_leap:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("leap_speedbonus") end
function modifier_imba_leap:GetModifierAttackSpeedBonus_Constant() return (self:GetAbility():GetSpecialValueFor("leap_speedbonus_as") + self:GetCaster():GetTalentValue("special_bonus_imba_mirana_2")) end

imba_mirana_cosmic_dust = class({})

LinkLuaModifier("modifier_imba_cosmic_dust_day", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)

function imba_mirana_cosmic_dust:IsHiddenWhenStolen() 		return false end
function imba_mirana_cosmic_dust:IsRefreshable() 			return true end
function imba_mirana_cosmic_dust:IsStealable() 				return true end
function imba_mirana_cosmic_dust:IsNetherWardStealable()	return true end
function imba_mirana_cosmic_dust:GetAssociatedPrimaryAbilities() return "imba_mirana_starfall" end
function imba_mirana_cosmic_dust:GetIntrinsicModifierName() return "modifier_imba_cosmic_dust_day" end

function imba_mirana_cosmic_dust:CastFilterResult()
	if self:GetCaster():GetModifierStackCount("modifier_imba_cosmic_dust_day", self:GetCaster()) == 1 and not self:GetCaster():HasScepter() then
		return UF_FAIL_CUSTOM
	end
end

function imba_mirana_cosmic_dust:GetCustomCastError()
	if self:GetCaster():GetModifierStackCount("modifier_imba_cosmic_dust_day", self:GetCaster()) == 1 and not self:GetCaster():HasScepter() then
		return "#dota_hud_error_ability_inactive"
	end
end

function imba_mirana_cosmic_dust:OnSpellStart()
	local ability = self:GetCaster():FindAbilityByName("imba_mirana_starfall")
	if ability then
		ability:OnSpellStart()
	end
end


modifier_imba_cosmic_dust_day = class({})  -- use this to know day and night

function modifier_imba_cosmic_dust_day:IsDebuff()			return false end
function modifier_imba_cosmic_dust_day:IsHidden() 			return true end
function modifier_imba_cosmic_dust_day:IsPurgable() 		return false end
function modifier_imba_cosmic_dust_day:IsPurgeException() 	return false end
function modifier_imba_cosmic_dust_day:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end
function modifier_imba_cosmic_dust_day:OnIntervalThink()
	if GameRules:IsDaytime() then
		self:SetStackCount(1)
	else
		self:SetStackCount(0)
	end
end

imba_mirana_moonlight_shadow = class({})

LinkLuaModifier("modifier_imba_moonlight_shadow_caster", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_moonlight_shadow", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_moonlight_shadow_fade", "hero/hero_mirana", LUA_MODIFIER_MOTION_NONE)

function imba_mirana_moonlight_shadow:IsHiddenWhenStolen() 		return false end
function imba_mirana_moonlight_shadow:IsRefreshable() 			return true end
function imba_mirana_moonlight_shadow:IsStealable() 			return true end
function imba_mirana_moonlight_shadow:IsNetherWardStealable()	return true end
function imba_mirana_moonlight_shadow:GetCooldown()				return self:GetSpecialValueFor("cd") + self:GetCaster():GetTalentValue("special_bonus_imba_mirana_1") end

function imba_mirana_moonlight_shadow:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Ability.MoonlightShadow")
	caster:AddNewModifier(caster, self, "modifier_imba_moonlight_shadow_caster", {duration = self:GetSpecialValueFor("duration")})
	local cast_response = {"mirana_mir_ability_moon_02", "mirana_mir_ability_moon_03", "mirana_mir_ability_moon_04", "mirana_mir_ability_moon_07", "mirana_mir_ability_moon_08"}
	EmitSoundOn(cast_response[math.random(1, 5)], caster)
end

modifier_imba_moonlight_shadow_caster = class({})

function modifier_imba_moonlight_shadow_caster:IsDebuff()				return false end
function modifier_imba_moonlight_shadow_caster:IsHidden() 				return true end
function modifier_imba_moonlight_shadow_caster:IsPurgable() 			return false end
function modifier_imba_moonlight_shadow_caster:IsPurgeException() 		return false end
function modifier_imba_moonlight_shadow_caster:IsAura() return true end
function modifier_imba_moonlight_shadow_caster:GetAuraDuration() return 0.1 end
function modifier_imba_moonlight_shadow_caster:GetModifierAura() return "modifier_imba_moonlight_shadow" end
function modifier_imba_moonlight_shadow_caster:GetAuraRadius() return 100000 end
function modifier_imba_moonlight_shadow_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD end
function modifier_imba_moonlight_shadow_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_moonlight_shadow_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_moonlight_shadow = class({})

function modifier_imba_moonlight_shadow:IsDebuff()				return false end
function modifier_imba_moonlight_shadow:IsHidden() 				return false end
function modifier_imba_moonlight_shadow:IsPurgable() 			return false end
function modifier_imba_moonlight_shadow:IsPurgeException() 		return false end
function modifier_imba_moonlight_shadow:GetEffectName() return "particles/units/heroes/hero_mirana/mirana_moonlight_owner.vpcf" end
function modifier_imba_moonlight_shadow:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_moonlight_shadow:ShouldUseOverheadOffset() return true end
function modifier_imba_moonlight_shadow:CheckState()
	if self:GetParent():HasModifier("modifier_imba_moonlight_shadow_fade") then
		return nil
	else
		return {[MODIFIER_STATE_INVISIBLE] = true}
	end
end
function modifier_imba_moonlight_shadow:DeclareFunctions() 
	return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_DISABLE_AUTOATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ABILITY_EXECUTED, MODIFIER_PROPERTY_INVISIBILITY_LEVEL, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,}
end
function modifier_imba_moonlight_shadow:GetModifierInvisibilityLevel()
	if self:GetParent():HasModifier("modifier_imba_moonlight_shadow_fade") then
		return 0
	else
		return 1
	end
end
function modifier_imba_moonlight_shadow:GetDisableAutoAttack() return true end

function modifier_imba_moonlight_shadow:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and self:GetParent():IsRangedAttacker() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_moonlight_shadow_fade", {duration = self:GetAbility():GetSpecialValueFor("fade_delay")})
	end
end

function modifier_imba_moonlight_shadow:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():IsRangedAttacker() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_moonlight_shadow_fade", {duration = self:GetAbility():GetSpecialValueFor("fade_delay")})
	end
end

function modifier_imba_moonlight_shadow:OnAbilityExecuted(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() then
		return
	end
	self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_moonlight_shadow_fade", {duration = self:GetAbility():GetSpecialValueFor("fade_delay")})
end

function modifier_imba_moonlight_shadow:OnCreated()
	self.ms = self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), false)
	if IsServer() then
		self:StartIntervalThink(0.1)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_moonlight_shadow_fade", {duration = self:GetAbility():GetSpecialValueFor("fade_delay")})
	end
end

function modifier_imba_moonlight_shadow:OnIntervalThink()
	local buff = self:GetCaster():FindModifierByName("modifier_imba_moonlight_shadow_caster")
	if buff then
		self:SetStackCount(math.ceil(buff:GetRemainingTime()))
	end
end

function modifier_imba_moonlight_shadow:GetModifierMoveSpeed_AbsoluteMin() return self.ms end

modifier_imba_moonlight_shadow_fade = class({})

function modifier_imba_moonlight_shadow_fade:IsDebuff()				return true end
function modifier_imba_moonlight_shadow_fade:IsHidden() 			return false end
function modifier_imba_moonlight_shadow_fade:IsPurgable() 			return false end
function modifier_imba_moonlight_shadow_fade:IsPurgeException() 	return false end
function modifier_imba_moonlight_shadow_fade:GetEffectName() return "particles/generic_hero_status/status_invisibility_start.vpcf" end
function modifier_imba_moonlight_shadow_fade:GetEffectAttachType() return PATTACH_ABSORIGIN end

function modifier_imba_moonlight_shadow_fade:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_moonlight_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end
