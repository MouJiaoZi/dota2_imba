CreateEmptyTalents("drow_ranger")

----------------------------------------------------------
-------- DataDriven Unique Attack Modifier
----------------------------------------------------------

LinkLuaModifier("modifier_imba_frost_arrows_slow_stacks", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_frost_arrows_frozen", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)

function FrostArrows_Attack(keys)
	local ability = keys.ability
	ability:UseResources(true, true, true)
end

function FrostArrows_AttackLanded(keys)
	local caster = keys.attacker
	if caster:IsIllusion() then
		return
	end
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetSpecialValueFor("frost_arrows_creep_duration")
	if target:IsHero() then
		duration = ability:GetSpecialValueFor("frost_arrows_hero_duration")
	end
	target:AddNewModifier(caster, ability, "modifier_imba_frost_arrows_slow_stacks", {duration = duration})
end

modifier_imba_frost_arrows_slow_stacks = class({})

function modifier_imba_frost_arrows_slow_stacks:IsDebuff()				return true end
function modifier_imba_frost_arrows_slow_stacks:IsHidden() 				return false end
function modifier_imba_frost_arrows_slow_stacks:IsPurgable() 			return true end
function modifier_imba_frost_arrows_slow_stacks:IsPurgeException() 		return true end
function modifier_imba_frost_arrows_slow_stacks:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_imba_frost_arrows_slow_stacks:GetStatusEffectName() return "particles/status_fx/status_effect_frost.vpcf" end
function modifier_imba_frost_arrows_slow_stacks:StatusEffectPriority() return 15 end

function modifier_imba_frost_arrows_slow_stacks:OnCreated()
	self:SetStackCount(1)
end

function modifier_imba_frost_arrows_slow_stacks:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_imba_frost_arrows_slow_stacks:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("frost_arrows_slow")) end

function modifier_imba_frost_arrows_slow_stacks:OnRefresh()
	if not IsServer() then
		return
	end
	self:IncrementStackCount()
	if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("stacks_to_freeze") then
		self:SetStackCount(1)
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_frost_arrows_frozen", {duration = self:GetAbility():GetSpecialValueFor("freeze_duration")})
	end
end

modifier_imba_frost_arrows_frozen = class({})

function modifier_imba_frost_arrows_frozen:IsDebuff()				return true end
function modifier_imba_frost_arrows_frozen:IsHidden() 				return false end
function modifier_imba_frost_arrows_frozen:IsPurgable() 			return true end
function modifier_imba_frost_arrows_frozen:IsPurgeException() 		return true end
function modifier_imba_frost_arrows_frozen:GetEffectName() return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf" end
function modifier_imba_frost_arrows_frozen:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_frost_arrows_frozen:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end


imba_drow_ranger_gust = class({})

LinkLuaModifier("modifier_imba_drow_ranger_gust_debuff", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_drow_ranger_gust_enemy_motion", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_imba_drow_ranger_gust_self_motion", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_imba_drow_ranger_gust_cast", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)

function imba_drow_ranger_gust:IsHiddenWhenStolen() 	return false end
function imba_drow_ranger_gust:IsRefreshable() 			return true  end
function imba_drow_ranger_gust:IsStealable() 			return true  end
function imba_drow_ranger_gust:IsNetherWardStealable() 	return true end

function imba_drow_ranger_gust:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("distance") end

function imba_drow_ranger_gust:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local buff = CreateModifierThinker(caster, self, "modifier_imba_drow_ranger_gust_cast", {duration = 10.0, direction_x = direction.x, direction_y = direction.y}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	caster:EmitSound("Hero_DrowRanger.Silence")
	local info = {Ability = self,
					EffectName = "particles/units/heroes/hero_drow/drow_silence_wave.vpcf",
					vSpawnOrigin = caster:GetAbsOrigin() + caster:GetForwardVector() * self:GetSpecialValueFor("wave_width"),
					fDistance = self:GetSpecialValueFor("distance") + caster:GetCastRangeBonus(),
					fStartRadius = self:GetSpecialValueFor("wave_width"),
					fEndRadius = self:GetSpecialValueFor("wave_width"),
					Source = caster,
					StartPosition = "attach_attack1",
					bHasFrontalCone = false,
					bReplaceExisting = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
					fExpireTime = GameRules:GetGameTime() + 10.0,
					bDeleteOnHit = true,
					vVelocity = direction * self:GetSpecialValueFor("wave_speed"),
					bProvidesVision = false,
					ExtraData = {buffid = buff:entindex()},
				}
	ProjectileManager:CreateLinearProjectile(info)
end

function imba_drow_ranger_gust:OnProjectileHit_ExtraData(target, pos, keys)
	local direction = EntIndexToHScript(keys.buffid):FindModifierByName("modifier_imba_drow_ranger_gust_cast").direction
	local hitted = EntIndexToHScript(keys.buffid):FindModifierByName("modifier_imba_drow_ranger_gust_cast").hitted
	if not target then
		return
	end
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_drow_ranger_gust_debuff", {duration = self:GetSpecialValueFor("silence_duration")})
	target:RemoveModifierByName("modifier_imba_drow_ranger_gust_enemy_motion")
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_drow_ranger_gust_enemy_motion", {duration = self:GetSpecialValueFor("knockback_duration"), direction = direction})
	ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType()})
	if not hitted then
		EntIndexToHScript(keys.buffid):FindModifierByName("modifier_imba_drow_ranger_gust_cast").hitted = true
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_drow_ranger_gust_self_motion", {duration = self:GetSpecialValueFor("self_knockback_duration"), direction = direction, target = target:entindex()})
	end
end

modifier_imba_drow_ranger_gust_cast = class({})

function modifier_imba_drow_ranger_gust_cast:OnCreated(keys)
	if IsServer() then
		self.hitted = false
		self.direction = Vector(keys.direction_x, keys.direction_y, 0)
	end
end

function modifier_imba_drow_ranger_gust_cast:OnDestroy()
	if IsServer() then
		self.hitted = nil
		self.direction = nil
	end
end

modifier_imba_drow_ranger_gust_debuff = class({})

function modifier_imba_drow_ranger_gust_debuff:IsDebuff()				return true end
function modifier_imba_drow_ranger_gust_debuff:IsHidden() 				return false end
function modifier_imba_drow_ranger_gust_debuff:IsPurgable() 			return true end
function modifier_imba_drow_ranger_gust_debuff:IsPurgeException() 		return true end
function modifier_imba_drow_ranger_gust_debuff:DeclareFunctions()return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_drow_ranger_gust_debuff:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_imba_drow_ranger_gust_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("move_slow")) end
function modifier_imba_drow_ranger_gust_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("attack_slow")) end

modifier_imba_drow_ranger_gust_enemy_motion = class({})

function modifier_imba_drow_ranger_gust_enemy_motion:IsDebuff()				return false end
function modifier_imba_drow_ranger_gust_enemy_motion:IsHidden() 			return true end
function modifier_imba_drow_ranger_gust_enemy_motion:IsPurgable() 			return true end
function modifier_imba_drow_ranger_gust_enemy_motion:IsPurgeException() 	return true end
function modifier_imba_drow_ranger_gust_enemy_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_MOVESPEED_LIMIT} end
function modifier_imba_drow_ranger_gust_enemy_motion:GetModifierMoveSpeed_Absolute() if IsServer() then return 1 end end
function modifier_imba_drow_ranger_gust_enemy_motion:GetModifierMoveSpeed_Limit() if IsServer() then return 1 end end
function modifier_imba_drow_ranger_gust_enemy_motion:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_imba_drow_ranger_gust_enemy_motion:OnHorizontalMotionInterrupted() self:Destroy() end
function modifier_imba_drow_ranger_gust_enemy_motion:OnVerticalMotionInterrupted() self:Destroy() end

function modifier_imba_drow_ranger_gust_enemy_motion:OnCreated(keys)
	if IsServer() then
		self:SetPriority(DOTA_MOTION_CONTROLLER_PRIORITY_LOWEST)
		if not self:ApplyHorizontalMotionController() or not self:ApplyVerticalMotionController() then
			self:Destroy()
		else
			self.direction = StringToVector(keys.direction)
			self.knockback_distance = math.max((self:GetCaster():Script_GetAttackRange() - (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()) / 2, 0)
			self.knockback_height = self:GetAbility():GetSpecialValueFor("knockback_height")
			self:StartIntervalThink(FrameTime())
		end
	end
end

function modifier_imba_drow_ranger_gust_enemy_motion:OnIntervalThink()
	local total_ticks = self:GetDuration() / FrameTime()
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local distance = self.knockback_distance / total_ticks
	local height = self.knockback_height
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + self.direction * distance, nil)
	next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
	self:GetParent():SetAbsOrigin(next_pos)
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, false)
end

function modifier_imba_drow_ranger_gust_enemy_motion:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController(self)
		self:GetParent():RemoveVerticalMotionController(self)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self.direction = nil
		self.knockback_distance = nil
		self.knockback_height = nil
	end
end

modifier_imba_drow_ranger_gust_self_motion = class({})

function modifier_imba_drow_ranger_gust_self_motion:IsDebuff()				return false end
function modifier_imba_drow_ranger_gust_self_motion:IsHidden() 				return true end
function modifier_imba_drow_ranger_gust_self_motion:IsPurgable() 			return false end
function modifier_imba_drow_ranger_gust_self_motion:IsPurgeException() 		return false end
function modifier_imba_drow_ranger_gust_self_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_MOVESPEED_LIMIT} end
function modifier_imba_drow_ranger_gust_self_motion:GetModifierMoveSpeed_Absolute() if IsServer() then return 1 end end
function modifier_imba_drow_ranger_gust_self_motion:GetModifierMoveSpeed_Limit() if IsServer() then return 1 end end
function modifier_imba_drow_ranger_gust_self_motion:OnHorizontalMotionInterrupted() self:Destroy() end
function modifier_imba_drow_ranger_gust_self_motion:OnVerticalMotionInterrupted() self:Destroy() end

function modifier_imba_drow_ranger_gust_self_motion:OnCreated(keys)
	if IsServer() then
		self:SetPriority(DOTA_MOTION_CONTROLLER_PRIORITY_LOWEST)
		if not self:ApplyHorizontalMotionController() or not self:ApplyVerticalMotionController() then
			self:Destroy()
		else
			self.direction = StringToVector(keys.direction)
			self.knockback_distance = 0 - math.max((self:GetCaster():Script_GetAttackRange() - (EntIndexToHScript(keys.target):GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()) / 2, 0)
			self.knockback_height = self:GetAbility():GetSpecialValueFor("knockback_height")
			self:StartIntervalThink(FrameTime())
		end
	end
end

function modifier_imba_drow_ranger_gust_self_motion:OnIntervalThink()
	local total_ticks = self:GetDuration() / FrameTime()
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local distance = self.knockback_distance / total_ticks
	local height = self.knockback_height
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + (self.direction * distance), nil)
	next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
	self:GetParent():SetAbsOrigin(next_pos)
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, false)
end

function modifier_imba_drow_ranger_gust_self_motion:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController(self)
		self:GetParent():RemoveVerticalMotionController(self)
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self.direction = nil
		self.knockback_distance = nil
		self.knockback_height = nil
	end
end


imba_drow_ranger_trueshot = class({})

LinkLuaModifier("modifier_imba_trueshot_passive", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_trueshot_damage_stack", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_trueshot_active", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)

function imba_drow_ranger_trueshot:IsHiddenWhenStolen() 	return false end
function imba_drow_ranger_trueshot:IsRefreshable() 			return true  end
function imba_drow_ranger_trueshot:IsStealable() 			return false  end
function imba_drow_ranger_trueshot:IsNetherWardStealable() 	return false end

function imba_drow_ranger_trueshot:GetIntrinsicModifierName() return "modifier_imba_trueshot_passive" end

function imba_drow_ranger_trueshot:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_trueshot_active", {duration = self:GetSpecialValueFor("active_duration")})
	self:GetCaster():CalculateStatBonus()
end

modifier_imba_trueshot_passive = class({})
modifier_imba_trueshot_damage_stack = class({})
modifier_imba_trueshot_active = class({})

function modifier_imba_trueshot_passive:IsDebuff()				return false end
function modifier_imba_trueshot_passive:IsHidden() 				return true end
function modifier_imba_trueshot_passive:IsPurgable() 			return false end
function modifier_imba_trueshot_passive:IsPurgeException() 		return false end

function modifier_imba_trueshot_passive:IsAura()
	if self:GetParent():IsIllusion() or self:GetParent():PassivesDisabled() then
		return false
	end
	return true
end
function modifier_imba_trueshot_passive:GetAuraDuration() return 0.5 end
function modifier_imba_trueshot_passive:GetModifierAura() return "modifier_imba_trueshot_damage_stack" end
function modifier_imba_trueshot_passive:GetAuraRadius() return 100000 end
function modifier_imba_trueshot_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_trueshot_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_trueshot_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP end
function modifier_imba_trueshot_passive:GetAuraEntityReject(unit)
	if unit:IsTrueHero() or unit:IsIllusion() or self:GetParent():HasModifier("modifier_imba_trueshot_active") then
		return false
	end
	return true
end

function modifier_imba_trueshot_damage_stack:IsDebuff()				return false end
function modifier_imba_trueshot_damage_stack:IsHidden() 			return false end
function modifier_imba_trueshot_damage_stack:IsPurgable() 			return false end
function modifier_imba_trueshot_damage_stack:IsPurgeException() 	return false end

function modifier_imba_trueshot_damage_stack:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_trueshot_damage_stack:OnIntervalThink()
	self:SetStackCount(self:GetCaster():GetAgility() * (self:GetAbility():GetSpecialValueFor("trueshot_ranged_damage") / 100))
end

function modifier_imba_trueshot_damage_stack:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_trueshot_damage_stack:GetModifierPreAttack_BonusDamage() return self:GetStackCount() end

function modifier_imba_trueshot_active:IsDebuff()				return false end
function modifier_imba_trueshot_active:IsHidden() 				return false end
function modifier_imba_trueshot_active:IsPurgable() 			return false end
function modifier_imba_trueshot_active:IsPurgeException() 		return false end

function modifier_imba_trueshot_active:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_trueshot_active:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end

imba_drow_ranger_marksmanship = class({})

LinkLuaModifier("modifier_imba_marksmanship_effect", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_marksmanship_scepter_dmg_reduce", "hero/hero_drow_ranger", LUA_MODIFIER_MOTION_NONE)

function imba_drow_ranger_marksmanship:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_drow_ranger_marksmanship:GetIntrinsicModifierName() return "modifier_imba_marksmanship_effect" end

function imba_drow_ranger_marksmanship:OnUpgrade()
	self:GetCaster():CalculateStatBonus()
end

modifier_imba_marksmanship_effect = class({})

function modifier_imba_marksmanship_effect:IsDebuff()				return false end
function modifier_imba_marksmanship_effect:IsPurgable() 			return false end
function modifier_imba_marksmanship_effect:IsPurgeException() 		return false end
function modifier_imba_marksmanship_effect:GetPriority() 			return MODIFIER_PRIORITY_LOW end
function modifier_imba_marksmanship_effect:IsHidden()
	if self:GetStackCount() ~= 0 then
		return true
	else
		return false
	end
end

function modifier_imba_marksmanship_effect:OnCreated()
	if IsServer() then
		self.pfx = nil
		self:StartIntervalThink(0.1)
		self.split = true
	end
end

function modifier_imba_marksmanship_effect:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	if (#enemies > 0 or self:GetParent():PassivesDisabled()) and not self:GetCaster():HasTalent("special_bonus_imba_drow_ranger_1") then
		self:SetStackCount(1)
		if self.pfx then
			ParticleManager:DestroyParticle(self.pfx, false)
			ParticleManager:ReleaseParticleIndex(self.pfx)
			self.pfx = nil
		end
	else
		self:SetStackCount(0)
	end

	if self:GetStackCount() == 0 and not self.pfx then
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_drow/drow_marksmanship.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControl(self.pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.pfx, 2, Vector(2,0,0))
		ParticleManager:SetParticleControlEnt(self.pfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "bow_top", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.pfx, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "bow_bot", self:GetCaster():GetAbsOrigin(), true)
	end
end

function modifier_imba_marksmanship_effect:OnDestroy()
	if IsServer() and self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function modifier_imba_marksmanship_effect:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_PROJECTILE_NAME}
end

function modifier_imba_marksmanship_effect:GetModifierBonusStats_Agility() return self:GetStackCount() ~= 0 and 0 or self:GetAbility():GetSpecialValueFor("agility_bonus") end
function modifier_imba_marksmanship_effect:GetBonusNightVision() return self:GetStackCount() ~= 0 and 0 or self:GetAbility():GetSpecialValueFor("night_vision_bonus") end
function modifier_imba_marksmanship_effect:GetModifierMoveSpeedBonus_Percentage() return self:GetStackCount() ~= 0 and 0 or self:GetAbility():GetSpecialValueFor("movement_speed_bonus") end
function modifier_imba_marksmanship_effect:GetModifierAttackRangeBonus() return self:GetStackCount() ~= 0 and 0 or self:GetAbility():GetSpecialValueFor("range_bonus") end
function modifier_imba_marksmanship_effect:GetModifierProjectileName() return "particles/units/heroes/hero_drow/drow_marksmanship_attack.vpcf" end

function modifier_imba_marksmanship_effect:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and self:GetParent().splitattack and keys.target:IsAlive() and keys.target:IsUnit() then
		if self:GetParent():HasScepter() then
			local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("splinter_radius_scepter"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE + DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED, FIND_ANY_ORDER, false)
			for _ , enemy in pairs(enemies) do
				if enemy ~= keys.target then
					local info = 
					{
						hTarget = enemy,
						hCaster = keys.target,
						hAbility = self:GetAbility(),	
						EffectName = self:GetParent():GetRangedProjectileName(),
						iMoveSpeed = self:GetParent():GetProjectileSpeed(),
						vSourceLoc= self:GetParent():GetAbsOrigin(),
						flRadius = 1,
						SoundName = "",
						bDrawsOnMinimap = false,
						bDodgeable = true,
						bDestroyOnDodge = true,
						bIsAttack = false,
						bVisibleToEnemies = true,
						iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
						OnProjectileHitUnit = function(params, projectileID)
												Scepter_Arrow_hit(params, projectileID, self)
											end
					}
					TrackingProjectiles:Projectile(info)
				end
			end
		end
		if PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("pure_chance")) then
			keys.target:EmitSound("Hero_DrowRanger.Marksmanship.Target")
			local dmg = ApplyDamage({victim = keys.target, attacker = self:GetParent(), damage = self:GetParent():GetAverageTrueAttackDamage(keys.target) * (self:GetAbility():GetSpecialValueFor("pure_pct") / 100), damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, keys.target, dmg, nil)
		end
	end
end

function Scepter_Arrow_hit(keys, projectileID, buff)
	if not keys.hTarget then
		return
	end
	local caster = buff:GetCaster()
	local target = keys.hTarget
	local mark = caster:FindModifierByName("modifier_imba_marksmanship_effect")
	caster.splitattack = false
	caster:AddNewModifier(caster, buff:GetAbility(), "modifier_imba_marksmanship_scepter_dmg_reduce", {})
	caster:PerformAttack(target, false, true, true, false, false, false, false)
	caster.splitattack = true
	caster:RemoveModifierByName("modifier_imba_marksmanship_scepter_dmg_reduce")
end

modifier_imba_marksmanship_scepter_dmg_reduce = class({})
function modifier_imba_marksmanship_scepter_dmg_reduce:IsDebuff()				return false end
function modifier_imba_marksmanship_scepter_dmg_reduce:IsHidden() 				return true end
function modifier_imba_marksmanship_scepter_dmg_reduce:IsPurgable() 			return false end
function modifier_imba_marksmanship_scepter_dmg_reduce:IsPurgeException() 		return false end
function modifier_imba_marksmanship_scepter_dmg_reduce:DeclareFunctions() return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_marksmanship_scepter_dmg_reduce:GetModifierDamageOutgoing_Percentage() return (IsServer() and (0 - self:GetAbility():GetSpecialValueFor("damage_reduction_scepter")) or 0) end