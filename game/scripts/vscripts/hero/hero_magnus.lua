CreateEmptyTalents("magnus")

imba_magnus_shockwave = class({})

function imba_magnus_shockwave:IsHiddenWhenStolen() 	return false end
function imba_magnus_shockwave:IsRefreshable() 			return true  end
function imba_magnus_shockwave:IsStealable() 			return true  end
function imba_magnus_shockwave:IsNetherWardStealable()	return true end

function imba_magnus_shockwave:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0
	local distance = self:GetSpecialValueFor("shock_distance") + caster:GetCastRangeBonus()
	local thinker = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false):entindex()
	EntIndexToHScript(thinker):EmitSound("Hero_Magnataur.ShockWave.Particle")
	EntIndexToHScript(thinker).hit = {}
	EntIndexToHScript(thinker).hitted = 0
	EntIndexToHScript(thinker).direction = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = self:GetSpecialValueFor("shock_width"),
		fEndRadius = self:GetSpecialValueFor("shock_width"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = direction * self:GetSpecialValueFor("shock_speed"),
		bProvidesVision = false,
		ExtraData = {primary = 1, thinker = thinker}
	}
	ProjectileManager:CreateLinearProjectile(info)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Magnataur.ShockWave.Cast", caster)
end

function imba_magnus_shockwave:OnProjectileThink_ExtraData(location, keys)
	EntIndexToHScript(keys.thinker):SetAbsOrigin(location)
end

function imba_magnus_shockwave:OnProjectileHit_ExtraData(target, location, keys)
	if not target then
		EntIndexToHScript(keys.thinker):ForceKill(false)
		return true
	end
	if target and not IsInTable(target, EntIndexToHScript(keys.thinker).hit) then
		target:EmitSound("Hero_Magnataur.ShockWave.Target")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_shockwave_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
	if target and keys.primary == 1 and not IsInTable(target, EntIndexToHScript(keys.thinker).hit) then
		local damageTable = {
							victim = target,
							attacker = self:GetCaster(),
							damage = self:GetSpecialValueFor("shock_damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		if EntIndexToHScript(keys.thinker).hitted < self:GetSpecialValueFor("max_secondary") and target:IsTrueHero() then
			EntIndexToHScript(keys.thinker).hitted = EntIndexToHScript(keys.thinker).hitted + 1
			local angle = self:GetCaster():HasScepter() and 2 or 1
			local secondary_angle = self:GetSpecialValueFor("secondary_angle")
			local target_pos = target:GetAbsOrigin()
			local direction = EntIndexToHScript(keys.thinker).direction
			for i=(-1)*angle, angle do
				if i ~= 0 then
					local new_pos = RotatePosition(target_pos, QAngle(0, secondary_angle * i, 0), target_pos + direction * 100)
					local new_direction = (new_pos - target_pos):Normalized()
					new_direction.z = 0
					local thinker = CreateModifierThinker(self:GetCaster(), self, "modifier_dummy_thinker", {}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false):entindex()
					EntIndexToHScript(thinker):EmitSound("Hero_Magnataur.ShockWave.Particle")
					EntIndexToHScript(thinker).hit = {}
					local info = 
					{
						Ability = self,
						EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
						vSpawnOrigin = target:GetAbsOrigin(),
						fDistance = self:GetSpecialValueFor("shock_distance") + self:GetCaster():GetCastRangeBonus(),
						fStartRadius = self:GetSpecialValueFor("shock_width"),
						fEndRadius = self:GetSpecialValueFor("shock_width"),
						Source = self:GetCaster(),
						bHasFrontalCone = false,
						bReplaceExisting = false,
						iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
						iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
						iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
						fExpireTime = GameRules:GetGameTime() + 10.0,
						bDeleteOnHit = true,
						vVelocity = new_direction * self:GetSpecialValueFor("shock_speed"),
						bProvidesVision = false,
						ExtraData = {primary = 0, thinker = thinker}
					}
					ProjectileManager:CreateLinearProjectile(info)
					EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Magnataur.ShockWave.Cast", target)
				end
			end
		end
	end
	if target and keys.primary == 0 and not IsInTable(target, EntIndexToHScript(keys.thinker).hit) then
		local damageTable = {
							victim = target,
							attacker = self:GetCaster(),
							damage = self:GetSpecialValueFor("secondary_damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
	end
end

imba_magnus_empower = class({})

LinkLuaModifier("modifier_imba_empower", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_supercharged", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_empower_aura", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)

function imba_magnus_empower:IsHiddenWhenStolen() 	return false end
function imba_magnus_empower:IsRefreshable() 		return true  end
function imba_magnus_empower:IsStealable() 			return true  end
function imba_magnus_empower:IsNetherWardStealable()return true end

function imba_magnus_empower:GetIntrinsicModifierName() return "modifier_imba_empower_aura" end

function imba_magnus_empower:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local buff = target:FindModifierByName("modifier_imba_empower") and "modifier_imba_supercharged" or "modifier_imba_empower"
	local duration = target:FindModifierByName("modifier_imba_empower") and self:GetSpecialValueFor("supercharge_duration") or self:GetSpecialValueFor("empower_duration")
	target:AddNewModifier(caster, self, buff, {duration = duration})
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Magnataur.Empower.Cast", caster)
	target:EmitSound("Hero_Magnataur.Empower.Target")
end

modifier_imba_empower_aura = class({})

function modifier_imba_empower_aura:IsDebuff()			return false end
function modifier_imba_empower_aura:IsHidden() 			return true end
function modifier_imba_empower_aura:IsPurgable() 		return false end
function modifier_imba_empower_aura:IsPurgeException() 	return false end

function modifier_imba_empower_aura:IsAura() return true end
function modifier_imba_empower_aura:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("scepter_aura_duration") end
function modifier_imba_empower_aura:GetModifierAura() return "modifier_imba_empower" end
function modifier_imba_empower_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius_scepter") end
function modifier_imba_empower_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_empower_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_empower_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_empower_aura:GetAuraEntityReject(unit)
	if not self:GetParent():HasScepter() and unit ~= self:GetParent() then
		return true
	end
	return false
end

modifier_imba_empower = class({})

function modifier_imba_empower:IsDebuff()			return false end
function modifier_imba_empower:IsHidden() 			return false end
function modifier_imba_empower:IsPurgable() 		return true end
function modifier_imba_empower:IsPurgeException() 	return true end
function modifier_imba_empower:GetEffectName() return "particles/units/heroes/hero_magnataur/magnataur_empower.vpcf" end
function modifier_imba_empower:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_empower:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_empower:GetModifierBaseDamageOutgoing_Percentage() return self:GetAbility():GetSpecialValueFor("bonus_damage_pct") end

function modifier_imba_empower:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or not keys.target:IsAlive() then
		return
	end
	local dmg = keys.damage * ((self:GetParent():IsRangedAttacker() and self:GetAbility():GetSpecialValueFor("cleave_damage_ranged") or self:GetAbility():GetSpecialValueFor("cleave_damage_pct")) / 100)
	local target = keys.target
	if self:GetParent():IsIllusion() then
		dmg = 0
	end
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("cleave_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= target then
			local damageTable = {
								victim = enemy,
								attacker = self:GetParent(),
								damage = dmg,
								damage_type = DAMAGE_TYPE_PHYSICAL,
								damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, --Optional.
								ability = nil, --Optional.
								}
			ApplyDamage(damageTable)
		end
	end
	local pfxname = self:GetParent():HasModifier("modifier_imba_supercharged") and "particles/hero/magnus/magnus_empower_red_cleave.vpcf" or "particles/hero/magnus/magnus_empower_cleave.vpcf"
	local pfx = ParticleManager:CreateParticle(pfxname, PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("cleave_radius"), 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_imba_supercharged = class({})

function modifier_imba_supercharged:IsDebuff()			return false end
function modifier_imba_supercharged:IsHidden() 			return false end
function modifier_imba_supercharged:IsPurgable() 		return true end
function modifier_imba_supercharged:IsPurgeException() 	return true end
function modifier_imba_supercharged:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_supercharged:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("supercharge_ms") end
function modifier_imba_supercharged:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("supercharge_as") end
function modifier_imba_supercharged:GetEffectName() return "particles/hero/magnus/magnus_empower_red.vpcf" end
function modifier_imba_supercharged:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_supercharged:GetTexture() return "magnus_supercharge" end

imba_magnus_skewer = class({})

LinkLuaModifier("modifier_imba_skewer_debuff", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_skewer_caster_motion", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_skewer_target_stun", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)

function imba_magnus_skewer:IsHiddenWhenStolen() 	return false end
function imba_magnus_skewer:IsRefreshable() 		return true  end
function imba_magnus_skewer:IsStealable() 			return true  end
function imba_magnus_skewer:IsNetherWardStealable()	return true end
function imba_magnus_skewer:GetCastRange() if IsClient() then return (self:GetSpecialValueFor("range") + self:GetCaster():GetTalentValue("special_bonus_imba_magnus_1")) end end

function imba_magnus_skewer:OnSpellStart()
	local caster = self:GetCaster()
	local direction = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local pos = (self:GetCursorPosition() - caster:GetAbsOrigin()):Length2D() <= (self:GetSpecialValueFor("range") + self:GetCaster():GetTalentValue("special_bonus_imba_magnus_1")) and self:GetCursorPosition() or caster:GetAbsOrigin() + direction * (self:GetSpecialValueFor("range") + self:GetCaster():GetTalentValue("special_bonus_imba_magnus_1"))
	local duration = (caster:GetAbsOrigin() - pos):Length2D() / (self:GetSpecialValueFor("skewer_speed") + self:GetCaster():GetTalentValue("special_bonus_imba_magnus_1"))
	caster:AddNewModifier(caster, self, "modifier_imba_skewer_caster_motion", {duration = duration, pos_x = pos.x, pos_y = pos.y, pos_z = pos.z})
	caster:EmitSound("Hero_Magnataur.Skewer.Cast")
	ProjectileManager:ProjectileDodge(caster)
	caster:Purge(false, true, false, false, false)
end

modifier_imba_skewer_caster_motion = class({})

function modifier_imba_skewer_caster_motion:IsMotionController()return true end
function modifier_imba_skewer_caster_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_skewer_caster_motion:IsDebuff()			return false end
function modifier_imba_skewer_caster_motion:IsHidden() 			return true end
function modifier_imba_skewer_caster_motion:IsPurgable() 		return false end
function modifier_imba_skewer_caster_motion:IsPurgeException() 	return false end
function modifier_imba_skewer_caster_motion:IsStunDebuff()		return true end
function modifier_imba_skewer_caster_motion:CheckState() return {[MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_MAGIC_IMMUNE] = true} end
function modifier_imba_skewer_caster_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_skewer_caster_motion:GetOverrideAnimation() return ACT_DOTA_CAST_ABILITY_3 end
function modifier_imba_skewer_caster_motion:OnCreated(keys)
	if IsServer() then
		self.hitted = {}
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.speed = self:GetAbility():GetSpecialValueFor("skewer_speed") + self:GetParent():GetTalentValue("special_bonus_imba_magnus_1")
		self:CheckMotionControllers()
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_skewer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_horn", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_skewer_caster_motion:OnIntervalThink()
	local current_pos = self:GetParent():GetAbsOrigin()
	local distacne = self.speed / (1.0 / FrameTime())
	local direction = (self.pos - current_pos):Normalized()
	direction.z = 0
	local next_pos = GetGroundPosition((current_pos + direction * distacne), nil)
	self:GetParent():SetForwardVector((self.pos - current_pos):Normalized())
	self:GetParent():SetAbsOrigin(next_pos)
	local horn_pos = self:GetParent():GetAttachmentOrigin(self:GetParent():ScriptLookupAttachment("attach_horn"))
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("skewer_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not IsInTable(enemy, self.hitted) and not enemy:HasModifier("modifier_imba_tricks_of_the_trade_caster") then
			enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_skewer_target_stun", {})
			self.hitted[#self.hitted+1] = enemy
		end
	end
	for i, enemy in pairs(self.hitted) do
		if enemy and enemy:IsAlive() then
			enemy:SetAbsOrigin(GetGroundPosition(horn_pos, nil))
		else
			self.hitted[i] = nil
		end
	end
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), false)
end

function modifier_imba_skewer_caster_motion:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		for _, enemy in pairs(self.hitted) do
			if enemy then
				local a = enemy:FindModifierByNameAndCaster("modifier_imba_skewer_target_stun", self:GetParent()) and enemy:FindModifierByNameAndCaster("modifier_imba_skewer_target_stun", self:GetParent()):Destroy() or 1
				FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), true)
				enemy:Stop()
				enemy:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_skewer_debuff", {duration = self:GetAbility():GetSpecialValueFor("slow_duration")})
				local damageTable = {
									victim = enemy,
									attacker = self:GetParent(),
									damage = self:GetAbility():GetSpecialValueFor("skewer_damage"),
									damage_type = self:GetAbility():GetAbilityDamageType(),
									damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
									ability = self:GetAbility(), --Optional.
									}
				ApplyDamage(damageTable)
				enemy:EmitSound("Hero_Magnataur.Skewer.Target")
			end
		end
		self.hitted = nil
		self.pos = nil
		self.speed = nil
		self:GetParent():SetForwardVector(Vector(self:GetParent():GetForwardVector()[1], self:GetParent():GetForwardVector()[2], 0))
	end
end

modifier_imba_skewer_target_stun = class({})

function modifier_imba_skewer_target_stun:GetAttributes()	return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_skewer_target_stun:IsDebuff()			return true end
function modifier_imba_skewer_target_stun:IsHidden() 			return false end
function modifier_imba_skewer_target_stun:IsPurgable() 			return false end
function modifier_imba_skewer_target_stun:IsPurgeException() 	return true end
function modifier_imba_skewer_target_stun:IsStunDebuff()		return true end
function modifier_imba_skewer_target_stun:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end

modifier_imba_skewer_debuff = class({})

function modifier_imba_skewer_debuff:IsDebuff()			return true end
function modifier_imba_skewer_debuff:IsHidden() 		return false end
function modifier_imba_skewer_debuff:IsPurgable() 		return true end
function modifier_imba_skewer_debuff:IsPurgeException() return true end
function modifier_imba_skewer_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_skewer_debuff:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("slow_pct") end
function modifier_imba_skewer_debuff:GetEffectName() return "particles/units/heroes/hero_magnataur/magnataur_skewer_debuff.vpcf" end
function modifier_imba_skewer_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

imba_magnus_magnetize = class({})

LinkLuaModifier("modifier_imba_magnetize_aura_counter", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_magnetize_aura", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_magnus_magnetize_debuff", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)

function imba_magnus_magnetize:IsTalentAbility() return true end

function imba_magnus_magnetize:GetIntrinsicModifierName() return "modifier_imba_magnus_magnetize_debuff" end

modifier_imba_magnus_magnetize_debuff = class({})

function modifier_imba_magnus_magnetize_debuff:IsDebuff()			return true end
function modifier_imba_magnus_magnetize_debuff:IsPurgable() 		return true end
function modifier_imba_magnus_magnetize_debuff:IsPurgeException() 	return true end
function modifier_imba_magnus_magnetize_debuff:IsHidden()
	if self:GetParent() == self:GetCaster() then
		return true
	else
		return false
	end
end

function modifier_imba_magnus_magnetize_debuff:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_magnus_magnetize_debuff:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if self:GetParent() ~= self:GetCaster() or keys.attacker ~= self:GetParent() or keys.unit:IsBuilding() or keys.unit:IsOther() or keys.attacker:GetTeamNumber() == keys.unit:GetTeamNumber() then
		return
	end
	keys.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_magnus_magnetize_debuff", {duration = self:GetAbility():GetSpecialValueFor("duration")})
end

function modifier_imba_magnus_magnetize_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("think_interval"))
	end
end

function modifier_imba_magnus_magnetize_debuff:OnIntervalThink()
	local units = FindUnitsInRadius(1, self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(units) do
		if unit ~= self:GetCaster() and not unit:FindModifierByNameAndCaster("modifier_imba_magnetize_aura", self:GetParent()) and unit:HasModifier("modifier_imba_magnus_magnetize_debuff") and unit ~= self:GetParent() then
			unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_magnetize_aura", {})
		end
	end
end

modifier_imba_magnetize_aura = class({})

function modifier_imba_magnetize_aura:IsDebuff()			return true end
function modifier_imba_magnetize_aura:IsPurgable() 			return false end
function modifier_imba_magnetize_aura:IsPurgeException() 	return false end
function modifier_imba_magnetize_aura:IsHidden()			return true end
function modifier_imba_magnetize_aura:GetAttributes()		return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_magnetize_aura:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_magnetize_aura_counter", {})
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_magnetize_aura:OnIntervalThink()
	if not self:GetCaster():HasModifier("modifier_imba_magnus_magnetize_debuff") or (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("radius") or not self:GetParent():HasModifier("modifier_imba_magnus_magnetize_debuff") then
		self:Destroy()
	end
end

modifier_imba_magnetize_aura_counter = class({})

function modifier_imba_magnetize_aura_counter:IsDebuff()			return true end
function modifier_imba_magnetize_aura_counter:IsPurgable() 			return false end
function modifier_imba_magnetize_aura_counter:IsPurgeException() 	return false end
function modifier_imba_magnetize_aura_counter:IsHidden()			return false end

function modifier_imba_magnetize_aura_counter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_magnetize_aura_counter:OnIntervalThink()
	local buffs = self:GetParent():FindAllModifiersByName("modifier_imba_magnetize_aura")
	self:SetStackCount(#buffs)
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end

function modifier_imba_magnetize_aura_counter:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_magnetize_aura_counter:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("ms_slow")) end

--particles/units/heroes/hero_magnataur/magnataur_reverse_polarity_field_lines.vpcf

imba_magnus_reverse_polarity = class({})

LinkLuaModifier("modifier_imba_reverse_polarity_slow", "hero/hero_magnus", LUA_MODIFIER_MOTION_NONE)

function imba_magnus_reverse_polarity:IsHiddenWhenStolen() 		return false end
function imba_magnus_reverse_polarity:IsRefreshable() 			return true  end
function imba_magnus_reverse_polarity:IsStealable() 			return true  end
function imba_magnus_reverse_polarity:IsNetherWardStealable()	return true end
function imba_magnus_reverse_polarity:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("normal_pull") - self:GetCaster():GetCastRangeBonus() end

function imba_magnus_reverse_polarity:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local radius = self:GetCastRange(Vector(0,0,0), caster)
	caster:EmitSound("Hero_Magnataur.ReversePolarity.Anim")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(pfx, 2, Vector(0.3, 0, 0))
	ParticleManager:SetParticleControl(pfx, 3, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
	return true
end

function imba_magnus_reverse_polarity:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("normal_pull")
	local enemies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local horn_pos = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_attack1"))
	for _, enemy in pairs(enemies) do
		FindClearSpaceForUnit(enemy, horn_pos, true)
		enemy:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
		ApplyDamage({victim = enemy, attacker = caster, damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
	end
	local heroes = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 100000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, hero in pairs(heroes) do
		if not IsInTable(hero, enemies) then
			hero:AddNewModifier(caster, self, "modifier_imba_reverse_polarity_slow", {duration = self:GetSpecialValueFor("stun_duration")})
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity_pull.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(pfx, 1, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
end

modifier_imba_reverse_polarity_slow = class({})

function modifier_imba_reverse_polarity_slow:IsMotionController()	return true end
function modifier_imba_reverse_polarity_slow:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_reverse_polarity_slow:IsDebuff()				return true end
function modifier_imba_reverse_polarity_slow:IsHidden() 			return false end
function modifier_imba_reverse_polarity_slow:IsPurgable() 			return true end
function modifier_imba_reverse_polarity_slow:IsPurgeException() 	return true end
function modifier_imba_reverse_polarity_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_reverse_polarity_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("global_slow")) end
function modifier_imba_reverse_polarity_slow:OnCreated()
	if IsServer() then
		self:CheckMotionControllers()
		local direction = (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
		direction.z = 0.0
		local distance = self:GetParent():HasModifier("modifier_imba_magnus_magnetize_debuff") and self:GetAbility():GetSpecialValueFor("magnetize_pull") or self:GetAbility():GetSpecialValueFor("normal_pull")
		local length = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
		distance =  length <= distance and length or distance
		local new_pos = self:GetParent():GetAbsOrigin() + direction * distance
		FindClearSpaceForUnit(self:GetParent(), new_pos, true)
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("tree_radius"), false)
	end
end
function modifier_imba_reverse_polarity_slow:OnRefresh() self:OnCreated() end
