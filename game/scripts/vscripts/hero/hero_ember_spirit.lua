CreateEmptyTalents("ember_spirit")


local function FindFireRemnants(caster)
	local remnants = {}
	local temp = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, 999999, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
	for k, v in pairs(temp) do
		if v:GetPlayerOwnerID() == caster:GetPlayerID() and v:HasModifier("modifier_imba_fire_remnant_state") and not v:HasModifier("modifier_imba_fire_remnant_target") then
			remnants[#remnants+1] = v
		end
	end
	return remnants
end

imba_ember_spirit_searing_chains = class({})

LinkLuaModifier("modifier_imba_searing_chains", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_ember_spirit_searing_chains:IsHiddenWhenStolen() 		return false end
function imba_ember_spirit_searing_chains:IsRefreshable() 			return true end
function imba_ember_spirit_searing_chains:IsStealable() 			return true end
function imba_ember_spirit_searing_chains:IsNetherWardStealable()	return true end
function imba_ember_spirit_searing_chains:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_ember_spirit_searing_chains:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_EmberSpirit.SearingChains.Cast")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlForward(pfx, 0, caster:GetForwardVector())
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
	local pos = caster:GetAbsOrigin()
	local chains = self:GetSpecialValueFor("unit_count")
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	for k, v in pairs(units) do
		heroes[#heroes + 1] = v
	end
	for i=1, chains do
		if heroes[i] then
			heroes[i]:Stop()
			heroes[i]:AddNewModifier(caster, self, "modifier_imba_searing_chains", {duration = self:GetSpecialValueFor("duration")})
			heroes[i]:EmitSound("Hero_EmberSpirit.SearingChains.Target")
			heroes[i]:EmitSound("Hero_EmberSpirit.SearingChains.Burn")
			local pfx_chain = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_start.vpcf", PATTACH_CUSTOMORIGIN, heroes[i])
			ParticleManager:SetParticleControlEnt(pfx_chain, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx_chain, 1, heroes[i], PATTACH_POINT_FOLLOW, "attach_hitloc", heroes[i]:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx_chain)
		end
	end
end

modifier_imba_searing_chains = class({})

function modifier_imba_searing_chains:IsDebuff()			return true end
function modifier_imba_searing_chains:IsHidden() 			return false end
function modifier_imba_searing_chains:IsPurgable() 			return true end
function modifier_imba_searing_chains:IsPurgeException() 	return true end
function modifier_imba_searing_chains:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_searing_chains:GetEffectName() return "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf" end
function modifier_imba_searing_chains:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_searing_chains:CheckState() return {[MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true} end

function modifier_imba_searing_chains:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	end
end

function modifier_imba_searing_chains:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetCaster()
	local target = self:GetParent()
	local dmg = ability:GetSpecialValueFor("chains_damage") / (1.0 / ability:GetSpecialValueFor("tick_interval"))
	ApplyDamage({victim = target, attacker = caster, ability = ability, damage = dmg, damage_type = ability:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE})
end

function modifier_imba_searing_chains:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_searing_chains") then
		self:GetParent():StopSound("Hero_EmberSpirit.SearingChains.Burn")
	end
end

imba_ember_spirit_sleight_of_fist = class({})

LinkLuaModifier("modifier_imba_sleight_of_fist_caster", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_ember_spirit_sleight_of_fist:IsHiddenWhenStolen() 	return false end
function imba_ember_spirit_sleight_of_fist:IsRefreshable() 			return true end
function imba_ember_spirit_sleight_of_fist:IsStealable() 			return true end
function imba_ember_spirit_sleight_of_fist:IsNetherWardStealable()	return false end
function imba_ember_spirit_sleight_of_fist:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_ember_spirit_sleight_of_fist:CastFilterResultLocation()
	if self:GetCaster():HasModifier("modifier_imba_sleight_of_fist_caster") then
		return UF_FAIL_CUSTOM
	end
end

function imba_ember_spirit_sleight_of_fist:GetCustomCastErrorLocation()
	if self:GetCaster():HasModifier("modifier_imba_sleight_of_fist_caster") then
		return "#dota_hud_error_ability_inactive"
	end
end

function imba_ember_spirit_sleight_of_fist:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_EmberSpirit.SleightOfFist.Cast")
	caster:AddNewModifier(caster, self, "modifier_imba_sleight_of_fist_caster", {})
	local pos = self:GetCursorPosition()
	local cast_pos = caster:GetAbsOrigin()
	local radius = self:GetSpecialValueFor("radius")
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local overhead_pfx = {}
	local ability = caster:FindAbilityByName("imba_ember_spirit_searing_chains")
	local pfx_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx_cast, 0, pos)
	ParticleManager:SetParticleControl(pfx_cast, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx_cast)

	local pfx_self = nil

	if #enemies > 0 then
		pfx_self = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_caster.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControl(pfx_self, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(pfx_self, 1, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward(pfx_self, 1, (pos - caster:GetAbsOrigin()):Normalized())
	end

	for i, enemy in pairs(enemies) do
		overhead_pfx[i] = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_targetted_marker.vpcf", PATTACH_OVERHEAD_FOLLOW, enemy)
	end

	for i, enemy in pairs(enemies) do
		Timers:CreateTimer((self:GetSpecialValueFor("attack_interval") * (i - 1)), function()
			local pos0 = GetRandomPosition2D(enemy:GetAbsOrigin(), 128)
			local direction = (enemy:GetAbsOrigin() - pos0):Normalized()
			caster:SetOrigin(pos0)
			caster:SetForwardVector(Vector(direction[1], direction[2], 0))
			if not caster:IsDisarmed() then
				caster:SetAttacking(enemy)
				caster:PerformAttack(enemy, false, true, true, false, false, false, false)
			end
			if ability and ability:GetLevel() > 0 and PseudoRandom:RollPseudoRandom(self, self:GetSpecialValueFor("chain_chance")) and not enemy:IsMagicImmune() then
				enemy:AddNewModifier(caster, ability, "modifier_imba_searing_chains", {duration = ability:GetSpecialValueFor("duration")})
				enemy:EmitSound("Hero_EmberSpirit.SearingChains.Target")
				local pfx_chain = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_start.vpcf", PATTACH_CUSTOMORIGIN, enemy)
				ParticleManager:SetParticleControl(pfx_chain, 0, cast_pos)
				ParticleManager:SetParticleControlEnt(pfx_chain, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(pfx_chain)
			end
			if overhead_pfx[i] ~= nil and type(overhead_pfx[i]) == "number" then
				ParticleManager:DestroyParticle(overhead_pfx[i], false)
				ParticleManager:ReleaseParticleIndex(overhead_pfx[i])
				overhead_pfx[i] = nil
			end
			return nil
		end
		)
		
		if i == #enemies and pfx_self then
			Timers:CreateTimer((self:GetSpecialValueFor("attack_interval") * (i - 0) + FrameTime()), function()
				ParticleManager:DestroyParticle(pfx_self, false)
				ParticleManager:ReleaseParticleIndex(pfx_self)
				FindClearSpaceForUnit(caster, cast_pos, true)
				caster:RemoveModifierByName("modifier_imba_sleight_of_fist_caster")
				caster:SetAttacking(nil)
				return nil
			end
			)
		end
	end
	Timers:CreateTimer((self:GetSpecialValueFor("attack_interval") * (#enemies + 1)), function()
		caster:RemoveModifierByName("modifier_imba_sleight_of_fist_caster")
		return nil
	end
	)
end

modifier_imba_sleight_of_fist_caster = class({})

function modifier_imba_sleight_of_fist_caster:IsDebuff()			return false end
function modifier_imba_sleight_of_fist_caster:IsHidden() 			return true end
function modifier_imba_sleight_of_fist_caster:IsPurgable() 			return false end
function modifier_imba_sleight_of_fist_caster:IsPurgeException() 	return false end
function modifier_imba_sleight_of_fist_caster:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_CANNOT_MISS] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_sleight_of_fist_caster:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_imba_sleight_of_fist_caster:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_sleight_of_fist_caster:GetModifierAttackRangeBonus() return 10000 end

function modifier_special_bonus_imba_ember_spirit_1:OnCreated()
	if IsServer() then
		local ability = self:GetParent():FindAbilityByName("imba_ember_spirit_sleight_of_fist")
		if ability then
			AbilityChargeController:AbilityChargeInitialize(ability, ability:GetCooldown(4 - 1), self:GetParent():GetTalentValue("special_bonus_imba_ember_spirit_1"), 1, true, true)
		end
	end
end

imba_ember_spirit_flame_guard = class({})

LinkLuaModifier("modifier_imba_flame_guard_passive", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_flame_guard", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_ember_spirit_flame_guard:IsHiddenWhenStolen() 	return false end
function imba_ember_spirit_flame_guard:IsRefreshable() 			return true end
function imba_ember_spirit_flame_guard:IsStealable() 			return true end
function imba_ember_spirit_flame_guard:IsNetherWardStealable()	return true end
function imba_ember_spirit_flame_guard:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_ember_spirit_flame_guard:GetIntrinsicModifierName() return "modifier_imba_flame_guard_passive" end

function imba_ember_spirit_flame_guard:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_flame_guard", {duration = self:GetSpecialValueFor("duration")})
	self:GetCaster():EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
end

modifier_imba_flame_guard_passive = class({})

function modifier_imba_flame_guard_passive:IsDebuff()			return false end
function modifier_imba_flame_guard_passive:IsHidden() 			return true end
function modifier_imba_flame_guard_passive:IsPurgable() 		return false end
function modifier_imba_flame_guard_passive:IsPurgeException() 	return false end

function modifier_imba_flame_guard_passive:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("duration"))
	end
end

function modifier_imba_flame_guard_passive:OnIntervalThink()
	self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("duration"))
	self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_flame_guard", {duration = self:GetAbility():GetSpecialValueFor("duration")})
	self:GetParent():EmitSound("Hero_EmberSpirit.FlameGuard.Cast")
end

modifier_imba_flame_guard = class({})

function modifier_imba_flame_guard:IsDebuff()			return false end
function modifier_imba_flame_guard:IsHidden() 			return false end
function modifier_imba_flame_guard:IsPurgable() 		return false end
function modifier_imba_flame_guard:IsPurgeException() 	return false end
function modifier_imba_flame_guard:DeclareFunctions() return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK} end

function modifier_imba_flame_guard:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_EmberSpirit.FlameGuard.Loop")
		self.health = self:GetAbility():GetSpecialValueFor("absorb_amount")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
		ParticleManager:SetParticleControl(pfx, 3, Vector(5.0, 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	end
end

function modifier_imba_flame_guard:OnRefresh()
	if IsServer() then
		self.health = self:GetAbility():GetSpecialValueFor("absorb_amount")
	end
end

function modifier_imba_flame_guard:OnIntervalThink()
	local ability = self:GetAbility()
	local caster = self:GetParent()
	local dmg = ability:GetSpecialValueFor("damage_per_second") / (1.0 / ability:GetSpecialValueFor("tick_interval"))
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		ApplyDamage({victim = enemy, attacker = caster, ability = ability, damage_type = ability:GetAbilityDamageType(), damage = dmg, damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE})
	end
end

function modifier_imba_flame_guard:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_EmberSpirit.FlameGuard.Loop")
		self.health = nil
	end
end

function modifier_imba_flame_guard:GetModifierTotal_ConstantBlock(keys)
	if not IsServer() then
		return
	end
	if keys.damage_type ~= DAMAGE_TYPE_MAGICAL and not self:GetParent():HasTalent("special_bonus_imba_ember_spirit_2") then
		return
	end
	local stack = self.health
	self.health = stack - math.max(0, keys.damage)
	if self.health <= 0 then
		self:Destroy()
	end
	return stack
end

imba_ember_spirit_fire_remnant = class({})

LinkLuaModifier("modifier_imba_fire_remnant_state", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fire_remnant_target", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fire_remnant_timer", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fire_remnant_scepter", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_ember_spirit_fire_remnant:IsHiddenWhenStolen() 	return false end
function imba_ember_spirit_fire_remnant:IsRefreshable() 		return true end
function imba_ember_spirit_fire_remnant:IsStealable() 			return true end
function imba_ember_spirit_fire_remnant:IsNetherWardStealable()	return false end
function imba_ember_spirit_fire_remnant:GetIntrinsicModifierName() return "modifier_imba_fire_remnant_scepter" end
function imba_ember_spirit_fire_remnant:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cast_range") * self:GetSpecialValueFor("multiplier_scepter")
	else
		return self:GetSpecialValueFor("cast_range")
	end
end
function imba_ember_spirit_fire_remnant:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_ember_spirit_activate_fire_remnant")
	if ability then
		ability:SetLevel(self:GetLevel())
	end
	if not AbilityChargeController:IsChargeTypeAbility(self) then
		AbilityChargeController:AbilityChargeInitialize(self, self:GetSpecialValueFor("charge_restore_time"), self:GetSpecialValueFor("max_charges"), 1, true, true)
	else
		AbilityChargeController:ChangeChargeAbilityConfig(self, self:GetSpecialValueFor("charge_restore_time"), self:GetSpecialValueFor("max_charges"), 1, true, true)
	end
end
function imba_ember_spirit_fire_remnant:GetAssociatedSecondaryAbilities() return "imba_ember_spirit_activate_fire_remnant" end

function imba_ember_spirit_fire_remnant:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local distance = (caster:GetAbsOrigin() - pos):Length2D()
	caster:EmitSound("Hero_EmberSpirit.FireRemnant.Cast")
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local timer = caster:AddNewModifier(caster, self, "modifier_imba_fire_remnant_timer", {duration = self:GetSpecialValueFor("duration")})
	local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, self:GetCaster():GetTeamNumber())
	dummy:AddNewModifier(caster, nil, "modifier_rooted", {duration = self:GetSpecialValueFor("duration") + 10.0})
	timer.target = dummy
	dummy:AddNewModifier(self:GetCaster(), self, "modifier_imba_fire_remnant_state", {duration = self:GetSpecialValueFor("duration")})
	dummy:AddNewModifier(self:GetCaster(), nil, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = 0,
		fEndRadius = 0,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_NONE,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_NONE,
		fExpireTime = GameRules:GetGameTime() + 30.0,
		bDeleteOnHit = true,
		vVelocity = direction * (self:GetSpecialValueFor("speed") * (self:GetCaster():HasScepter() and self:GetSpecialValueFor("multiplier_scepter") or 1)),
		bProvidesVision = false,
		ExtraData = {dummy = dummy:entindex()}
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function imba_ember_spirit_fire_remnant:OnProjectileThink_ExtraData(pos, keys)
	if keys.dummy and EntIndexToHScript(keys.dummy) then
		EntIndexToHScript(keys.dummy):SetOrigin(GetGroundPosition(pos, nil))
	end
end

function imba_ember_spirit_fire_remnant:OnProjectileHit_ExtraData(hTarget, pos, keys)
	if keys.dummy and EntIndexToHScript(keys.dummy) then
		EntIndexToHScript(keys.dummy):SetOrigin(GetGroundPosition(pos, nil))
		local dummy = EntIndexToHScript(keys.dummy)
		if dummy:FindModifierByName("modifier_imba_fire_remnant_state") then
			dummy:FindModifierByName("modifier_imba_fire_remnant_state"):CreatePfx()
		end
	end
end

modifier_imba_fire_remnant_scepter = class({})

function modifier_imba_fire_remnant_scepter:IsDebuff()			return false end
function modifier_imba_fire_remnant_scepter:IsHidden() 			return true end
function modifier_imba_fire_remnant_scepter:IsPurgable() 		return false end
function modifier_imba_fire_remnant_scepter:IsPurgeException() 	return false end

function modifier_imba_fire_remnant_scepter:OnCreated()
	if IsServer() and not self:GetParent():IsIllusion() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_fire_remnant_scepter:OnIntervalThink()
	if self:GetParent():HasScepter() then
		AbilityChargeController:ChangeChargeAbilityConfig(self:GetAbility(), self:GetAbility():GetSpecialValueFor("charge_restore_time"), self:GetAbility():GetSpecialValueFor("max_charges") * self:GetAbility():GetSpecialValueFor("multiplier_scepter"), 1, true, true)
	else
		AbilityChargeController:ChangeChargeAbilityConfig(self:GetAbility(), self:GetAbility():GetSpecialValueFor("charge_restore_time"), self:GetAbility():GetSpecialValueFor("max_charges"), 1, true, true)
	end
end

modifier_imba_fire_remnant_state = class({})

function modifier_imba_fire_remnant_state:CheckState() return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_fire_remnant_state:CreatePfx()
	if IsServer() then
		self:GetParent():EmitSound("Hero_EmberSpirit.Remnant.Appear")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		local gesture = math.random(67, 69)
		local steal_gesture = {53, 59, 65, 66, 70, 77, 88, 101, 114, 121}
		if self:GetAbility():IsStolen() then
			gesture = RandomFromTable(steal_gesture)
		end
		ParticleManager:SetParticleControl(pfx, 2, Vector(gesture, 0, 0))
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetCaster(), PATTACH_CUSTOMORIGIN, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(pfx, false, false, 15, false, false)
		self:SetStackCount(1)
	end
end

function modifier_imba_fire_remnant_state:Explode(bActive)
	if not IsServer() then
		return
	end
	self:GetParent():EmitSound("Hero_EmberSpirit.FireRemnant.Explode")
	if not bActive then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
	else
		local remnants = FindFireRemnants(self:GetCaster())
		for _, remnant in pairs(remnants) do
			if remnant ~= self:GetParent() and remnant:HasModifier("modifier_imba_fire_remnant_state") then
				local buff = remnant:FindModifierByName("modifier_imba_fire_remnant_state")
				buff:Explode(false)
			end
		end
		local timers = self:GetCaster():FindAllModifiersByName("modifier_imba_fire_remnant_timer")
		for _, timer in pairs(timers) do
			if timer.target == self:GetParent() then
				timer:Destroy()
			end
		end
		self:GetParent():ForceKill(false)
	end
	local chain = self:GetCaster():FindAbilityByName("imba_ember_spirit_searing_chains")
	local shell = self:GetCaster():FindAbilityByName("imba_ember_spirit_flame_guard")
	if shell and shell:GetLevel() > 0 then
		self:GetParent():AddNewModifier(self:GetCaster(), shell, "modifier_imba_flame_guard", {duration = shell:GetSpecialValueFor("duration")})
	end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local dmg = self:GetAbility():GetSpecialValueFor("damage")
	if self:GetCaster():HasScepter() then
		dmg = dmg / self:GetAbility():GetSpecialValueFor("multiplier_scepter")
	end
	for _, enemy in pairs(enemies) do
		ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = dmg, ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_PROPERTY_FIRE})
		if PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("chain_chance")) and chain and chain:GetLevel() > 0 then
			enemy:AddNewModifier(self:GetCaster(), chain, "modifier_imba_searing_chains", {duration = chain:GetSpecialValueFor("duration")})
			enemy:EmitSound("Hero_EmberSpirit.SearingChains.Target")
			local pfx_chain = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_start.vpcf", PATTACH_CUSTOMORIGIN, enemy)
			ParticleManager:SetParticleControl(pfx_chain, 0, self:GetParent():GetAbsOrigin())
			ParticleManager:SetParticleControlEnt(pfx_chain, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx_chain)
		end
	end
end

function modifier_imba_fire_remnant_state:OnDestroy()
	if IsServer() then
		
	end
end

modifier_imba_fire_remnant_target = class({})

modifier_imba_fire_remnant_timer = class({})

function modifier_imba_fire_remnant_timer:IsDebuff()			return true end
function modifier_imba_fire_remnant_timer:IsHidden() 			return false end
function modifier_imba_fire_remnant_timer:IsPurgable() 			return false end
function modifier_imba_fire_remnant_timer:IsPurgeException() 	return false end
function modifier_imba_fire_remnant_timer:RemoveOnDeath() return false end
function modifier_imba_fire_remnant_timer:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_fire_remnant_timer:DeclareFunctions() return {MODIFIER_PROPERTY_TOOLTIP} end
function modifier_imba_fire_remnant_timer:OnTooltip() return self:GetRemainingTime() end

function modifier_imba_fire_remnant_timer:OnDestroy() self.target = nil end

imba_ember_spirit_activate_fire_remnant = class({})

LinkLuaModifier("modifier_imba_fire_remnant_active_caster", "hero/hero_ember_spirit", LUA_MODIFIER_MOTION_NONE)

function imba_ember_spirit_activate_fire_remnant:IsHiddenWhenStolen() 		return false end
function imba_ember_spirit_activate_fire_remnant:IsRefreshable() 			return true end
function imba_ember_spirit_activate_fire_remnant:IsStealable() 				return true end
function imba_ember_spirit_activate_fire_remnant:IsNetherWardStealable()	return false end
function imba_ember_spirit_activate_fire_remnant:GetAssociatedPrimaryAbilities() return "imba_ember_spirit_fire_remnant" end
function imba_ember_spirit_activate_fire_remnant:GetManaCost(iLevel) return self:GetCaster():HasScepter() and 0 or self.BaseClass.GetManaCost(self, iLevel) end

function imba_ember_spirit_activate_fire_remnant:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("imba_ember_spirit_fire_remnant") 
	local pos = self:GetCursorPosition()
	local buffs = caster:FindAllModifiersByName("modifier_imba_fire_remnant_timer")
	local target = nil
	local distance = 1000000
	for i=1, #buffs do
		local remnant = buffs[i].target
		if (pos - remnant:GetAbsOrigin()):Length2D() <= distance then
			target = remnant
		end
	end
	if not target then
		return false
	else
		return true
	end
end

function imba_ember_spirit_activate_fire_remnant:OnSpellStart()
	local caster = self:GetCaster()
	local ability = caster:FindAbilityByName("imba_ember_spirit_fire_remnant") 
	local pos = self:GetCursorPosition()
	local buffs = caster:FindAllModifiersByName("modifier_imba_fire_remnant_timer")
	local target = nil
	local distance = 1000000
	for i=1, #buffs do
		local remnant = buffs[i].target
		if (pos - remnant:GetAbsOrigin()):Length2D() <= distance then
			target = remnant
		end
	end
	if target then
		caster:AddNewModifier(caster, ability, "modifier_imba_fire_remnant_active_caster", {target = target:entindex()})
	else
		self:RefundManaCost()
		self:EndCooldown()
	end
end

modifier_imba_fire_remnant_active_caster = class({})

function modifier_imba_fire_remnant_active_caster:IsDebuff()			return false end
function modifier_imba_fire_remnant_active_caster:IsHidden() 			return true end
function modifier_imba_fire_remnant_active_caster:IsPurgable() 			return false end
function modifier_imba_fire_remnant_active_caster:IsPurgeException() 	return false end
function modifier_imba_fire_remnant_active_caster:CheckState() return {[MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_fire_remnant_active_caster:IsMotionController() return true end
function modifier_imba_fire_remnant_active_caster:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end

function modifier_imba_fire_remnant_active_caster:OnCreated(keys)
	if IsServer() then
		self:GetParent():EmitSound("Hero_EmberSpirit.FireRemnant.Activate")
		self.target = EntIndexToHScript(keys.target)
		self.pos = self.target:GetAbsOrigin()
		self.speed = self:GetAbility():GetSpecialValueFor("speed")
		if self:GetParent():HasScepter() then
			self.speed = self.speed * self:GetAbility():GetSpecialValueFor("multiplier_scepter")
		end
		if self:CheckMotionControllers() then
			self:OnIntervalThink()
			self:StartIntervalThink(FrameTime())
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_remnant_dash.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx, false, false, 15, false, false)
		else
			self:Destroy()
		end
	end
end

function modifier_imba_fire_remnant_active_caster:OnIntervalThink()
	self.pos = self.target:GetAbsOrigin()
	local distance = (self.pos - self:GetParent():GetAbsOrigin()):Length2D() < (self.speed / (1.0 / FrameTime())) and (self.pos - self:GetParent():GetAbsOrigin()):Length2D() or (self.speed / (1.0 / FrameTime()))
	local direction = (self.pos - self:GetParent():GetAbsOrigin()):Normalized()
	direction.z = 0.0
	--self:GetParent():SetForwardVector(Vector(direction[1], direction[2], 0))
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + direction * distance, nil)
	self:GetParent():SetOrigin(next_pos)
	if (self:GetParent():GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D() <= 30 then
		self:Destroy()
	end
	GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 200, false)
end

function modifier_imba_fire_remnant_active_caster:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_EmberSpirit.FireRemnant.Activate")
		self:GetParent():EmitSound("Hero_EmberSpirit.FireRemnant.Stop")
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		if self.target and not self.target:IsNull() and self.target:IsAlive() and self.target:HasModifier("modifier_imba_fire_remnant_state") then
			local buff = self.target:FindModifierByName("modifier_imba_fire_remnant_state")
			buff:Explode(true)
		end
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 400, false)
		self.target = nil
		self.pos = nil
		self.speed = nil
	end
end