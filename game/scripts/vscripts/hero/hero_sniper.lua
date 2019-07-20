

CreateEmptyTalents("sniper")


imba_sniper_headshot = class({})

LinkLuaModifier("modifier_imba_headshot", "hero/hero_sniper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_headshot_normal_debuff", "hero/hero_sniper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_headshot_far_debuff", "hero/hero_sniper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_headshot_far_motion", "hero/hero_sniper", LUA_MODIFIER_MOTION_HORIZONTAL)

function imba_sniper_headshot:GetIntrinsicModifierName() return "modifier_imba_headshot" end

function imba_sniper_headshot:ProcFarAimAttack(target)
	local caster = self:GetCaster()
	caster:EmitSound("Ability.Assassinate")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("far_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local info = 
		{
			Target = enemy,
			Source = caster,
			Ability = self,	
			EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
			iMoveSpeed = self:GetSpecialValueFor("far_shot_speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
			bDrawsOnMinimap = false,
			bDodgeable = true,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 10,
			bProvidesVision = false,	
		}
		ProjectileManager:CreateTrackingProjectile(info)
	end
end

function imba_sniper_headshot:OnProjectileHit(target, location)
	if not target then
		return
	end
	local damageTable = {
						victim = target,
						attacker = self:GetCaster(),
						damage = self:GetSpecialValueFor("far_damage"),
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
	target:EmitSound("Hero_Sniper.AssassinateDamage")
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_headshot_far_motion", {duration = self:GetSpecialValueFor("far_knockback") / self:GetSpecialValueFor("knockback_speed")})
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_headshot_far_debuff", {duration = self:GetSpecialValueFor("far_duration")})
end


--[[
modifier_imba_take_aim_far
modifier_imba_take_aim_near
]]

modifier_imba_headshot = class({})

function modifier_imba_headshot:IsDebuff()			return false end
function modifier_imba_headshot:IsHidden() 			return true end
function modifier_imba_headshot:IsPurgable() 		return false end
function modifier_imba_headshot:IsPurgeException() 	return false end
function modifier_imba_headshot:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_imba_headshot:GetModifierAttackRangeBonus() return self:GetParent():PassivesDisabled() and 0 or self:GetAbility():GetSpecialValueFor("attack_range") end

function modifier_imba_headshot:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and (keys.target:IsHero() or keys.target:IsCreep()) and not self:GetParent():IsIllusion() and keys.target:IsAlive() then
		if not self:GetParent():HasModifier("modifier_imba_take_aim_far") and not self:GetParent():HasModifier("modifier_imba_take_aim_near") and PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("proc_chance")) then
			keys.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_headshot_normal_debuff", {duration = self:GetAbility():GetSpecialValueFor('normal_duration')})
			local damageTable = {
								victim = keys.target,
								attacker = self:GetCaster(),
								damage = self:GetAbility():GetSpecialValueFor("normal_damage"),
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
			keys.target:EmitSound("Hero_Sniper.DuckTarget")
		end
		if not self:GetParent():HasModifier("modifier_imba_take_aim_far") and self:GetParent():HasModifier("modifier_imba_take_aim_near") and PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("proc_chance")) then
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_stunned", {duration = self:GetAbility():GetSpecialValueFor("near_duration")})
		end
	end
end

function modifier_imba_headshot:OnAttack(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and (keys.target:IsHero() or keys.target:IsCreep()) and not self:GetParent():IsIllusion() then
		if self:GetParent():HasModifier("modifier_imba_take_aim_far") and not self:GetParent():HasModifier("modifier_imba_take_aim_near") and PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("far_proc_chance")) then
			self:GetAbility():ProcFarAimAttack(keys.target)
		end
	end
end

modifier_imba_headshot_normal_debuff = class({})

function modifier_imba_headshot_normal_debuff:IsDebuff()			return true end
function modifier_imba_headshot_normal_debuff:IsHidden() 			return false end
function modifier_imba_headshot_normal_debuff:IsPurgable() 			return false end
function modifier_imba_headshot_normal_debuff:IsPurgeException() 	return false end
function modifier_imba_headshot_normal_debuff:GetEffectName() return "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf" end
function modifier_imba_headshot_normal_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_headshot_normal_debuff:ShouldUseOverheadOffset() return true end
function modifier_imba_headshot_normal_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_headshot_normal_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("normal_move_slow")) end
function modifier_imba_headshot_normal_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("normal_attack_slow")) end

modifier_imba_headshot_far_motion = class({})

function modifier_imba_headshot_far_motion:IsDebuff()				return false end
function modifier_imba_headshot_far_motion:IsHidden() 				return true end
function modifier_imba_headshot_far_motion:IsPurgable() 			return false end
function modifier_imba_headshot_far_motion:IsPurgeException() 		return false end
function modifier_imba_headshot_far_motion:OnHorizontalMotionInterrupted() self:Destroy() end

function modifier_imba_headshot_far_motion:OnCreated()
	if IsServer() then
		if self:GetParent():IsMagicImmune() then
			self:Destroy()
			return
		end
		self:SetPriority(DOTA_MOTION_CONTROLLER_PRIORITY_LOW)
		self.direction = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
		if self:ApplyHorizontalMotionController() then
			self:StartIntervalThink(FrameTime())
		else
			self:Destroy()
		end
	end
end

function modifier_imba_headshot_far_motion:OnIntervalThink()
	local distance = self:GetAbility():GetSpecialValueFor("knockback_speed") * FrameTime()
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + (self.direction * distance), nil)
	self:GetParent():SetOrigin(next_pos)
end

function modifier_imba_headshot_far_motion:OnDestroy()
	if IsServer() then
		self.direction = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 100, false)
	end
end

modifier_imba_headshot_far_debuff = class({})

function modifier_imba_headshot_far_debuff:IsDebuff()			return true end
function modifier_imba_headshot_far_debuff:IsHidden() 			return false end
function modifier_imba_headshot_far_debuff:IsPurgable() 		return false end
function modifier_imba_headshot_far_debuff:IsPurgeException() 	return false end
function modifier_imba_headshot_far_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_headshot_far_debuff:GetModifierPhysicalArmorBonus() return (0 - self:GetAbility():GetSpecialValueFor("far_armor")) end

imba_sniper_take_aim_near = class({})

LinkLuaModifier("modifier_imba_take_aim_near", "hero/hero_sniper", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_take_aim_range", "hero/hero_sniper", LUA_MODIFIER_MOTION_NONE)

function imba_sniper_take_aim_near:IsHiddenWhenStolen() 	return true end
function imba_sniper_take_aim_near:IsRefreshable() 			return true end
function imba_sniper_take_aim_near:IsStealable() 			return false end
function imba_sniper_take_aim_near:IsNetherWardStealable()	return false end
function imba_sniper_take_aim_near:IsHiddenWhenStolen() return true end

function imba_sniper_take_aim_near:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_sniper_take_aim_far")
	if ability and ability:GetLevel() ~= self:GetLevel() then
		ability:SetLevel(self:GetLevel())
	end
	if self:GetCaster():HasModifier("modifier_morphling_replicate") then
		self:SetActivated(false)
		return
	end
end

function imba_sniper_take_aim_near:OnSpellStart()
	if self:GetCaster():HasModifier("modifier_morphling_replicate") then
		self:SetActivated(false)
		return
	end
	local caster = self:GetCaster()
	self:GetCaster():EmitSound("Ability.AssassinateLoad")
	caster:RemoveModifierByName("modifier_imba_take_aim_far")
	local ability = caster:FindAbilityByName("imba_sniper_take_aim_far")
	if caster:HasModifier("modifier_imba_take_aim_near") then
		caster:RemoveModifierByName("modifier_imba_take_aim_near")
	else
		caster:AddNewModifier(self:GetCaster(), self, "modifier_imba_take_aim_near", {})
	end
	self:EndCooldown()
	self:StartCooldown(self:GetSpecialValueFor("cooldown"))
	ability:EndCooldown()
	ability:StartCooldown(self:GetSpecialValueFor("cooldown"))
end

modifier_imba_take_aim_near = class({})

function modifier_imba_take_aim_near:IsDebuff()			return false end
function modifier_imba_take_aim_near:IsHidden() 		return false end
function modifier_imba_take_aim_near:IsPurgable() 		return false end
function modifier_imba_take_aim_near:IsPurgeException() return false end
function modifier_imba_take_aim_near:AllowIllusionDuplicate() return false end
function modifier_imba_take_aim_near:RemoveOnDeath()	return true end
function modifier_imba_take_aim_near:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT} end
function modifier_imba_take_aim_near:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("move_speed") end
function modifier_imba_take_aim_near:GetModifierBaseDamageOutgoing_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("damage_reduction")) end
function modifier_imba_take_aim_near:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("BAT") end

function modifier_imba_take_aim_near:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_take_aim_range", {})
		--self:GetParent():SetBaseAttackTime(self:GetAbility():GetSpecialValueFor("BAT"))
	end
end

function modifier_imba_take_aim_near:OnDestroy()
	if IsServer() then
		--self:GetParent():SetBaseAttackTime(self:GetParent():GetDefaultBAT())
		self:GetParent():RemoveModifierByName("modifier_imba_take_aim_range")
	end
end

modifier_imba_take_aim_range = class({})

function modifier_imba_take_aim_range:IsDebuff()		return false end
function modifier_imba_take_aim_range:IsHidden() 		return true end
function modifier_imba_take_aim_range:IsPurgable() 		return false end
function modifier_imba_take_aim_range:IsPurgeException() return false end
function modifier_imba_take_aim_range:AllowIllusionDuplicate() return false end
function modifier_imba_take_aim_range:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_imba_take_aim_range:GetModifierAttackRangeBonus() return (0 - self:GetStackCount()) end

function modifier_imba_take_aim_range:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_take_aim_range:OnIntervalThink()
	self:SetStackCount(self:GetParent():Script_GetAttackRange() + self:GetStackCount() - self:GetAbility():GetSpecialValueFor("range"))
end

imba_sniper_take_aim_far = class({})

LinkLuaModifier("modifier_imba_take_aim_far", "hero/hero_sniper", LUA_MODIFIER_MOTION_NONE)

function imba_sniper_take_aim_far:IsHiddenWhenStolen() 		return true end
function imba_sniper_take_aim_far:IsRefreshable() 			return true end
function imba_sniper_take_aim_far:IsStealable() 			return false end
function imba_sniper_take_aim_far:IsNetherWardStealable()	return false end

function imba_sniper_take_aim_far:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_sniper_take_aim_near")
	if ability and ability:GetLevel() ~= self:GetLevel() then
		ability:SetLevel(self:GetLevel())
	end
	if self:GetCaster():HasModifier("modifier_morphling_replicate") then
		self:SetActivated(false)
		return
	end
end

function imba_sniper_take_aim_far:OnSpellStart()
	if self:GetCaster():HasModifier("modifier_morphling_replicate") then
		self:SetActivated(false)
		return
	end
	local caster = self:GetCaster()
	self:GetCaster():EmitSound("Ability.AssassinateLoad")
	caster:RemoveModifierByName("modifier_imba_take_aim_near")
	local ability = caster:FindAbilityByName("imba_sniper_take_aim_far")
	if caster:HasModifier("modifier_imba_take_aim_far") then
		caster:RemoveModifierByName("modifier_imba_take_aim_far")
	else
		caster:AddNewModifier(self:GetCaster(), self, "modifier_imba_take_aim_far", {})
	end
	self:EndCooldown()
	self:StartCooldown(self:GetSpecialValueFor("cooldown"))
	ability:EndCooldown()
	ability:StartCooldown(self:GetSpecialValueFor("cooldown"))
end

modifier_imba_take_aim_far = class({})

function modifier_imba_take_aim_far:IsDebuff()			return false end
function modifier_imba_take_aim_far:IsHidden() 			return false end
function modifier_imba_take_aim_far:IsPurgable() 		return false end
function modifier_imba_take_aim_far:IsPurgeException() 	return false end
function modifier_imba_take_aim_far:AllowIllusionDuplicate() return false end
function modifier_imba_take_aim_far:RemoveOnDeath()	return true end
function modifier_imba_take_aim_far:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_MOVESPEED_LIMIT, MODIFIER_PROPERTY_MOVESPEED_MAX} end
function modifier_imba_take_aim_far:GetModifierAttackRangeBonus() return self:GetAbility():GetSpecialValueFor("range") end
function modifier_imba_take_aim_far:GetModifierBaseAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("damage_bonus") end
function modifier_imba_take_aim_far:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("BAT") end
function modifier_imba_take_aim_far:GetModifierMoveSpeed_Absolute() return 0.01 end
function modifier_imba_take_aim_far:GetModifierMoveSpeed_Limit() return 0.01 end
function modifier_imba_take_aim_far:GetModifierMoveSpeed_Max() return 0.01 end

--modifier_sniper_shrapnel_slow

imba_sniper_assassinate = class({})

LinkLuaModifier("modifier_imba_assassinate_target", "hero/hero_sniper", LUA_MODIFIER_MOTION_NONE)

function imba_sniper_assassinate:IsHiddenWhenStolen() 		return false end
function imba_sniper_assassinate:IsRefreshable() 			return true end
function imba_sniper_assassinate:IsStealable() 				return true end
function imba_sniper_assassinate:IsNetherWardStealable()	return true end
function imba_sniper_assassinate:GetCastPoint() return self:GetSpecialValueFor("charge_time") end
function imba_sniper_assassinate:GetCooldown(i) return self:GetSpecialValueFor("cooldown") end
function imba_sniper_assassinate:GetCastRange()	--see orderfilter
	if IsServer() then
		if self.global == nil then
			self.global = 50000
		end
		return self:GetSpecialValueFor("regular_range") + self.global
	else
		return self:GetSpecialValueFor("regular_range")
	end
end

function imba_sniper_assassinate:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Ability.AssassinateLoad")
	self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_imba_assassinate_target", {duration = self:GetCastPoint()})
	return true
end

function imba_sniper_assassinate:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	caster:EmitSound("Ability.Assassinate")
	local thinker = CreateModifierThinker(caster, self, "modifier_imba_headshot", {}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false):entindex()
	EntIndexToHScript(thinker).hitted = {}
	EntIndexToHScript(thinker):EmitSound("Hero_Sniper.AssassinateProjectile")
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_sniper/sniper_assassinate.vpcf",
		iMoveSpeed = 3000,
		vSourceLoc = caster:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		ExtraData = {thinker = thinker},
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_sniper_assassinate:OnProjectileThink_ExtraData(location, keys)
	local thinker = EntIndexToHScript(keys.thinker)
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, self:GetSpecialValueFor("aoe_size"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not IsInTable(enemy, thinker.hitted) then
			table.insert(thinker.hitted, enemy)
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = self:GetCaster():HasScepter() and self:GetSpecialValueFor("damage_scepter") or self:GetSpecialValueFor('damage'),
								damage_type = self:GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self, --Optional.
								}
			ApplyDamage(damageTable)
			if self:GetCaster():HasScepter() then
				self:GetCaster():PerformAttack(enemy, false, true, true, true, true, false, true)
			end
		end
	end
end

function imba_sniper_assassinate:OnProjectileHit_ExtraData(target, location, keys)
	EntIndexToHScript(keys.thinker).hitted = nil
	EntIndexToHScript(keys.thinker):ForceKill(false)
end

modifier_imba_assassinate_target = class({})

function modifier_imba_assassinate_target:IsDebuff()			return true end
function modifier_imba_assassinate_target:IsHidden() 			return false end
function modifier_imba_assassinate_target:IsPurgable() 			return false end
function modifier_imba_assassinate_target:IsPurgeException() 	return false end
function modifier_imba_assassinate_target:GetEffectName() return "particles/units/heroes/hero_sniper/sniper_crosshair.vpcf" end
function modifier_imba_assassinate_target:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_assassinate_target:ShouldUseOverheadOffset() return true end