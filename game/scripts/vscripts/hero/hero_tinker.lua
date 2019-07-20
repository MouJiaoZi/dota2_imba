
CreateEmptyTalents("tinker")


imba_tinker_laser = class({})

LinkLuaModifier("modifier_imba_laser_blind", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)

function imba_tinker_laser:IsHiddenWhenStolen() 	return false end
function imba_tinker_laser:IsRefreshable() 			return true end
function imba_tinker_laser:IsStealable() 			return true end
function imba_tinker_laser:IsNetherWardStealable()	return true end

function imba_tinker_laser:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	caster:EmitSound("Hero_Tinker.Laser")
	local stack = caster:GetModifierStackCount("modifier_imba_rearm_stack", caster)
	local units = {target}
	local radius = self:GetSpecialValueFor("bounce_range_scepter")
	if caster:HasScepter() then
		for i, aunit in pairs(units) do
			local units1 = FindUnitsInRadius(caster:GetTeamNumber(), aunit:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
			for _, unit1 in pairs(units1) do
				local no_yet = true
				for _, unit in pairs(units) do
					if unit == unit1 or unit1 == caster then
						no_yet = false
						break
					end
				end
				if no_yet then
					table.insert(units, unit1)
					break
				end
			end
		end
	end
	table.insert(units, 1, caster)
	for k, unit in pairs(units) do
		if k < #units then
			units[k+1]:EmitSound("Hero_Tinker.LaserImpact")
			units[k+1]:EmitSound("Hero_Tinker.Laser")
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_laser.vpcf", PATTACH_POINT_FOLLOW, unit)
			ParticleManager:SetParticleControlEnt(pfx, 9, units[k], PATTACH_POINT_FOLLOW, (units[k] == caster and "attach_attack2" or "attach_hitloc"), units[k]:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, units[k+1], PATTACH_POINT_FOLLOW, "attach_hitloc", units[k+1 >= #units and k or k+1]:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx)
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), units[k+1]:GetAbsOrigin(), nil, self:GetSpecialValueFor("blind_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				if caster:IsHero() then
					enemy:AddNewModifier(caster, self, "modifier_imba_laser_blind", {duration = (self:GetSpecialValueFor("base_duration") + stack * self:GetSpecialValueFor("stack_duration"))})
				end
			end
			local damageTable = {
								victim = units[k+1],
								attacker = self:GetCaster(),
								damage = self:GetSpecialValueFor("damage") + stack * self:GetSpecialValueFor("stack_damage"),
								damage_type = self:GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self, --Optional.
								}
			ApplyDamage(damageTable)
		end
	end
end

modifier_imba_laser_blind = class({})

function modifier_imba_laser_blind:IsDebuff()			return true end
function modifier_imba_laser_blind:IsHidden() 			return false end
function modifier_imba_laser_blind:IsPurgable() 		return true end
function modifier_imba_laser_blind:IsPurgeException() 	return true end
function modifier_imba_laser_blind:DeclareFunctions() return {MODIFIER_PROPERTY_BONUS_DAY_VISION, MODIFIER_PROPERTY_BONUS_NIGHT_VISION, MODIFIER_PROPERTY_MISS_PERCENTAGE} end
function modifier_imba_laser_blind:GetBonusDayVision() return (0 - self:GetAbility():GetSpecialValueFor("vision_reduction")) end
function modifier_imba_laser_blind:GetBonusNightVision() return (0 - self:GetAbility():GetSpecialValueFor("vision_reduction")) end
function modifier_imba_laser_blind:GetModifierMiss_Percentage() return self:GetAbility():GetSpecialValueFor("blind_amount") end

imba_tinker_heat_seeking_missile = class({})

LinkLuaModifier("modifier_imba_heat_seeking_missile_vision", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)

function imba_tinker_heat_seeking_missile:IsHiddenWhenStolen() 		return false end
function imba_tinker_heat_seeking_missile:IsRefreshable() 			return true end
function imba_tinker_heat_seeking_missile:IsStealable() 			return true end
function imba_tinker_heat_seeking_missile:IsNetherWardStealable()	return true end
function imba_tinker_heat_seeking_missile:GetCastRange() return self:GetSpecialValueFor("search_range") - self:GetCaster():GetCastRangeBonus() end

function imba_tinker_heat_seeking_missile:OnSpellStart()
	local caster = self:GetCaster()
	local stack = caster:GetModifierStackCount("modifier_imba_rearm_stack", caster)
	local missiles = self:GetSpecialValueFor("base_count") + math.floor(stack * self:GetSpecialValueFor("stack_count")) + (caster:HasScepter() and self:GetSpecialValueFor("add_missile_scepter") or 0)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("search_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("search_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
	if #heroes < missiles then
		local more = missiles - #heroes
		for i=1, more do
			if i <= #units then
				table.insert(heroes, units[i])
			end
		end
	end
	if #heroes + #units == 0 then
		caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile_Dud")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missile_dud.vpcf", PATTACH_POINT, caster)
		ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT, "attach_attack3", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
	else
		caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile")
	end
	for i=1, missiles do
		if not heroes[i] then
			break
		end
		local info = 
		{
			Target = heroes[i],
			Source = caster,
			Ability = self,	
			EffectName = "particles/units/heroes/hero_tinker/tinker_missile.vpcf",
			iMoveSpeed = self:GetSpecialValueFor("speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_3,
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

function imba_tinker_heat_seeking_missile:OnProjectileHit(target, location)
	if not target or (target and target:IsMagicImmune()) then
		return
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_POINT, target)
	ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT, "attach_hitloc", location, true)
	ParticleManager:ReleaseParticleIndex(pfx)
	target:EmitSound("Hero_Tinker.Heat-Seeking_Missile.Impact")
	local damageTable = {
						victim = target,
						attacker = self:GetCaster(),
						damage = self:GetSpecialValueFor("damage"),
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_heat_seeking_missile_vision", {duration = self:GetSpecialValueFor("vision_duration")})
end

modifier_imba_heat_seeking_missile_vision = class({})

function modifier_imba_heat_seeking_missile_vision:IsDebuff()			return true end
function modifier_imba_heat_seeking_missile_vision:IsHidden() 			return false end
function modifier_imba_heat_seeking_missile_vision:IsPurgable() 		return true end
function modifier_imba_heat_seeking_missile_vision:IsPurgeException() 	return true end
function modifier_imba_heat_seeking_missile_vision:DeclareFunctions() return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_heat_seeking_missile_vision:GetModifierProvidesFOWVision() return 1 end



imba_tinker_march_of_the_machines = class({})

LinkLuaModifier("modifier_imba_march_of_the_machines_thinker", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_march_of_the_machines_cooldown", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_march_of_the_machines_creep_vision", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_march_of_the_machines_scepter", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)

function imba_tinker_march_of_the_machines:IsHiddenWhenStolen() 	return false end
function imba_tinker_march_of_the_machines:IsRefreshable() 			return true end
function imba_tinker_march_of_the_machines:IsStealable() 			return false end
function imba_tinker_march_of_the_machines:IsNetherWardStealable()	return false end
function imba_tinker_march_of_the_machines:GetIntrinsicModifierName() return "modifier_imba_march_of_the_machines_scepter" end

function imba_tinker_march_of_the_machines:CastFilterResultTarget(target)
	if target == self:GetCaster() then
		return UF_SUCCESS
	else
		return UF_FAIL_FRIENDLY
	end
end

function imba_tinker_march_of_the_machines:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Tinker.March_of_the_Machines.Cast")
	return true
end

function imba_tinker_march_of_the_machines:OnUpgrade()
	if not self:GetCaster():IsIllusion() and not self.spawner and not self:GetCaster():HasModifier("modifier_morphling_replicate") then
		local caster = self:GetCaster()
		self.spawner = CreateUnitByName("npc_imba_tinker_mom_spawner", GetRandomPosition2D(caster:GetAbsOrigin(), 300), false, caster, caster, caster:GetTeamNumber())
		self.spawner:AddNewModifier(self:GetCaster(), self, "modifier_imba_march_of_the_machines_thinker", {})
	end
	if self:GetCaster():HasModifier("modifier_morphling_replicate") then
		self:SetActivated(false)
	end
end

function imba_tinker_march_of_the_machines:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	self.spawner:MoveToPosition(pos)
	local buff = self.spawner:FindModifierByName("modifier_imba_march_of_the_machines_thinker")
	if self:GetCursorTarget() and self:GetCursorTarget() == caster then
		buff:SetStackCount(0)
	else
		buff:SetStackCount(1)
	end
end

modifier_imba_march_of_the_machines_scepter = class({})

function modifier_imba_march_of_the_machines_scepter:IsDebuff()			return false end
function modifier_imba_march_of_the_machines_scepter:IsHidden() 		return true end
function modifier_imba_march_of_the_machines_scepter:IsPurgable() 		return false end
function modifier_imba_march_of_the_machines_scepter:IsPurgeException() return false end
function modifier_imba_march_of_the_machines_scepter:AllowIllusionDuplicate() return false end

function modifier_imba_march_of_the_machines_scepter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_march_of_the_machines_scepter:OnIntervalThink()
	if not self:GetAbility().spawner then
		return
	end
	if self:GetParent():HasScepter() then
		self:GetAbility().spawner:AddNewModifier(self:GetParent(), nil, "modifier_item_ultimate_scepter_consumed", {})
	else
		self:GetAbility().spawner:RemoveModifierByName("modifier_item_ultimate_scepter_consumed")
	end
end

modifier_imba_march_of_the_machines_thinker = class({})

function modifier_imba_march_of_the_machines_thinker:IsDebuff()			return false end
function modifier_imba_march_of_the_machines_thinker:IsHidden() 		return true end
function modifier_imba_march_of_the_machines_thinker:IsPurgable() 		return false end
function modifier_imba_march_of_the_machines_thinker:IsPurgeException() return false end
function modifier_imba_march_of_the_machines_thinker:CheckState()
	if not self:GetCaster():IsInvisible() then
		return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true}
	else
		return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_TRUESIGHT_IMMUNE] = true}
	end
end
function modifier_imba_march_of_the_machines_thinker:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_MIN_HEALTH, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_march_of_the_machines_thinker:GetModifierIncomingDamage_Percentage() return -100000 end
function modifier_imba_march_of_the_machines_thinker:GetMinHealth() return 1 end

function modifier_imba_march_of_the_machines_thinker:GetModifierTotalDamageOutgoing_Percentage(keys)
	if IsServer() then
		if keys.target:IsTrueHero() then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_march_of_the_machines_cooldown", {duration = self:GetAbility():GetSpecialValueFor("hero_cooldown")})
		end
		if (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("break_distance") then
			return (self:GetAbility():GetSpecialValueFor("break_dmg_pct") - 100)
		elseif keys.target:IsTrueHero() then
			return (self:GetAbility():GetSpecialValueFor("break_dmg_pct") - 100)
		else
			return 100
		end
	end
end

function modifier_imba_march_of_the_machines_thinker:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.range = self:GetAbility():GetSpecialValueFor("search_range")
		--[[self.pfx = ParticleManager:CreateParticleForPlayer("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		self.color = PLAYER_COLORS[self:GetCaster():GetPlayerID()]
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.range,0,0))
		ParticleManager:SetParticleControl(self.pfx, 2, Vector(10,0,0))
		ParticleManager:SetParticleControl(self.pfx, 3, Vector(100,0,0))
		ParticleManager:SetParticleControl(self.pfx, 15, Vector(self.color[1], self.color[2], self.color[3]))]]
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_march_of_the_machines_thinker:OnIntervalThink()
	if not self.ability or self.caster:IsNull() or self.ability:IsNull() or not self.caster:HasAbility("imba_tinker_march_of_the_machines") then
		self.parent:ForceKill(false)
		self:Destroy()
		return
	end

	local range = self.ability:GetSpecialValueFor("search_range") + self.ability:GetSpecialValueFor("stack_range") * self.caster:GetModifierStackCount("modifier_imba_rearm_stack", nil)
	if self.range ~= range then
		self.range = range
		--[[ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = ParticleManager:CreateParticleForPlayer("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.self.parent, self.self.caster:GetPlayerOwner())
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(range,0,0))
		ParticleManager:SetParticleControl(self.pfx, 2, Vector(10,0,0))
		ParticleManager:SetParticleControl(self.pfx, 3, Vector(100,0,0))
		ParticleManager:SetParticleControl(self.pfx, 15, Vector(self.color[1], self.color[2], self.color[3]))]]
	end
	local laser = self.caster:FindAbilityByName("imba_tinker_laser")
	local missile = self.caster:FindAbilityByName("imba_tinker_heat_seeking_missile")

	local self_laser = self.parent:FindAbilityByName("imba_tinker_laser")
	local self_missile = self.parent:FindAbilityByName("imba_tinker_heat_seeking_missile")

	if laser then
		self_laser:SetLevel(laser:GetLevel())
	end
	if missile then
		self_missile:SetLevel(missile:GetLevel())
	end

	if self:GetStackCount() == 0 then
		if (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D() > 550 then
			self.parent:SetOrigin(GetRandomPosition2D(self.caster:GetAbsOrigin(), 300))
		else
			self.parent:MoveToNPC(self.caster)
		end
	end

	if not self.parent:HasModifier("modifier_imba_march_of_the_machines_cooldown") and not self.ability:GetAutoCastState() and self.caster:IsAlive() then
		local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_FARTHEST, false)
		local hero = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_FARTHEST, false)
		if #enemies > 0 then
			if self_laser:GetLevel() > 0 then
				local target = enemies[1]
				if #hero > 0 then
					target = hero[1]
				end
				self.parent:SetCursorCastTarget(target)
				self_laser:OnSpellStart()
			end
			if self_missile:GetLevel() > 0 then
				self_missile:OnSpellStart()
			end
			self.parent:AddNewModifier(self.caster, self.ability, "modifier_imba_march_of_the_machines_cooldown", {duration = self.ability:GetSpecialValueFor("cast_cooldown")})
		end
	end
end

function modifier_imba_march_of_the_machines_thinker:OnDestroy()
	if IsServer() then
		self.caster = nil
		self.parent = nil
		self.ability = nil
		self.range = nil
	end
end

function modifier_imba_march_of_the_machines_thinker:IsAura()
	if not IsServer() then
		return false
	end
	if self:GetStackCount() == 1 and self:GetCaster():IsAlive() then
		return true
	end
	return false
end
function modifier_imba_march_of_the_machines_thinker:GetAuraDuration() return 0.1 end
function modifier_imba_march_of_the_machines_thinker:GetModifierAura() return "modifier_imba_march_of_the_machines_creep_vision" end
function modifier_imba_march_of_the_machines_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("search_range") + self:GetAbility():GetSpecialValueFor("stack_range") * self:GetCaster():GetModifierStackCount("modifier_imba_rearm_stack", nil) end
function modifier_imba_march_of_the_machines_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_march_of_the_machines_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_march_of_the_machines_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_CREEP end
function modifier_imba_march_of_the_machines_thinker:GetAuraEntityReject(unit)
	return (unit:GetTeamNumber() == DOTA_TEAM_NEUTRALS)
end

modifier_imba_march_of_the_machines_creep_vision =({})

function modifier_imba_march_of_the_machines_creep_vision:IsDebuff()			return false end
function modifier_imba_march_of_the_machines_creep_vision:IsHidden() 			return true end
function modifier_imba_march_of_the_machines_creep_vision:IsPurgable() 			return false end
function modifier_imba_march_of_the_machines_creep_vision:IsPurgeException() 	return false end
function modifier_imba_march_of_the_machines_creep_vision:DeclareFunctions() return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_march_of_the_machines_creep_vision:GetModifierProvidesFOWVision() return 1 end

modifier_imba_march_of_the_machines_cooldown = class({})

function modifier_imba_march_of_the_machines_cooldown:IsDebuff()			return false end
function modifier_imba_march_of_the_machines_cooldown:IsHidden() 			return true end
function modifier_imba_march_of_the_machines_cooldown:IsPurgable() 			return false end
function modifier_imba_march_of_the_machines_cooldown:IsPurgeException() 	return false end

function modifier_imba_march_of_the_machines_cooldown:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_march_of_the_machines_cooldown:OnIntervalThink()
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MAGICAL_BLOCK, self:GetParent(), math.floor(self:GetRemainingTime() + 0.5), self:GetParent():GetPlayerOwner())
end

imba_tinker_rearm = class({})

LinkLuaModifier("modifier_imba_rearm_stack", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)

function imba_tinker_rearm:IsHiddenWhenStolen() 	return false end
function imba_tinker_rearm:IsRefreshable() 			return true end
function imba_tinker_rearm:IsStealable() 			return true end
function imba_tinker_rearm:IsNetherWardStealable()	return false end

function imba_tinker_rearm:OnSpellStart()
	local caster = self:GetCaster()
	self:EndCooldown()
	self:StartCooldown(self:GetSpecialValueFor("cooldown_tooltip"))
	if self:GetLevel() == 1 then
		StartAnimation(caster, {duration = 3.0, activity = ACT_DOTA_TINKER_REARM1, rate = 1.0})
	elseif self:GetLevel() == 2 then
		StartAnimation(caster, {duration = 2.0, activity = ACT_DOTA_TINKER_REARM2, rate = 1.0})
	elseif self:GetLevel() == 3 then
		StartAnimation(caster, {duration = 1.0, activity = ACT_DOTA_TINKER_REARM3, rate = 1.0})
	end

	-- Refresh abilities
	for i = 0, 23 do
		local current_ability = caster:GetAbilityByIndex(i)
		if current_ability and not IsRefreshableByAbility(current_ability:GetName()) then
			current_ability:EndCooldown()
		end
	end

	-- Refresh items
	for i = 0, 8 do
		local current_item = caster:GetItemInSlot(i)
		if current_item and not IsRefreshableByAbility(current_item:GetName()) then
			current_item:EndCooldown()
		end
	end

	-- Refresh TP
	local tp = caster:GetTP()
	if tp then
		tp:EndCooldown()
	end

	local buff = caster:AddNewModifier(caster, self, "modifier_imba_rearm_stack", {duration = self:GetSpecialValueFor("stack_duration")})
	buff:SetStackCount(buff:GetStackCount() + 1)
	if IsNearFriendlyClass(caster, 1360, "ent_dota_fountain") then
		buff:Destroy()
	end
	
end

modifier_imba_rearm_stack = class({})

function modifier_imba_rearm_stack:IsDebuff()			return false end
function modifier_imba_rearm_stack:IsHidden() 			return false end
function modifier_imba_rearm_stack:IsPurgable() 		return false end
function modifier_imba_rearm_stack:IsPurgeException() 	return false end
function modifier_imba_rearm_stack:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE} end
function modifier_imba_rearm_stack:GetModifierTotalPercentageManaRegen() return (0 - self:GetAbility():GetSpecialValueFor("mana_penalty") * self:GetStackCount()) end

function March( keys )
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local ability_rearm = caster:FindAbilityByName(keys.ability_rearm)
	local sound_cast = keys.sound_cast
	local modifier_machine = keys.modifier_machine
	local modifier_rearm_stack = keys.modifier_rearm_stack
	local modifier_rearm_mana = keys.modifier_rearm_mana
	local scepter = caster:HasScepter()
	
	-- Parameters
	local spawner_width = ability:GetLevelSpecialValueFor("spawner_width", ability_level)
	local spawner_amount = ability:GetLevelSpecialValueFor("spawner_amount", ability_level)
	local movement_scepter = ability:GetLevelSpecialValueFor("movement_scepter", ability_level)

	-- Play cast sound
	caster:EmitSound(sound_cast)

	-- Rearm stacks logic
	local rearm_stacks = caster:GetModifierStackCount(modifier_rearm_stack, caster)
	spawner_amount = spawner_amount + rearm_stacks

	-- Calculate fixed spawn point positions
	local spawn_points = {}
	local caster_pos = caster:GetAbsOrigin()
	local target_direction = (target - caster_pos):Normalized()
	if target == caster_pos then
		target_direction = caster:GetForwardVector()
	end
	spawn_points[1] = RotatePosition(target, QAngle(0, -90, 0), target + target_direction * spawner_width / 2 )
	spawn_points[2] = RotatePosition(target, QAngle(0, 90, 0), target + target_direction * spawner_width / 2 )

	-- Calculate variable spawn point positions
	if spawner_amount <= 3 then
		spawn_points[3] = target
	else
		for i = 3,spawner_amount do
			spawn_points[i] = RotatePosition(target, QAngle(0, (i - 2) * 360 / (spawner_amount - 2), 0), target + target_direction * spawner_width / 4 )
		end
	end

	-- Place spawners on spawn positions
	for _,spawn_point in pairs(spawn_points) do

		-- Spawn spawner
		local spawner = CreateUnitByName("npc_imba_tinker_mom_spawner", spawn_point, false, nil, nil, caster:GetTeamNumber())

		-- Apply spawner modifier (controls projectile spawning)
		ability:ApplyDataDrivenModifier(caster, spawner, modifier_machine, {})

		-- Align spawner to face the cast direction
		spawner:SetForwardVector(target_direction)
		
		-- If scepter, make the spawners controllable
		if scepter then
			Physics:Unit(spawner)
			spawner:SetPhysicsVelocity(target_direction * movement_scepter)	
			spawner:SetPhysicsFriction(0)
			spawner:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		else
			spawner:AddNewModifier(spawner, ability, "modifier_rooted", {})
		end

		-- Movement animation
		StartAnimation(spawner, {duration = 12, activity = ACT_DOTA_RUN, rate = 1.0})
	end
end

function MarchSpawn( keys )
	local caster = keys.caster
	local spawner = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_machine = keys.particle_machine

	-- If the ability was unlearned, or the spawner is near the enemy fountain, destroy it
	if not ability or IsNearEnemyClass(spawner, 1360, "ent_dota_fountain")then
		spawner:Destroy()
		return nil
	end
	
	-- Parameters
	local spawn_radius = ability:GetLevelSpecialValueFor("spawn_radius", ability_level)
	local spawn_length = ability:GetLevelSpecialValueFor("spawn_length", ability_level)
	local collision_radius = ability:GetLevelSpecialValueFor("collision_radius", ability_level)
	local speed = ability:GetLevelSpecialValueFor("speed", ability_level)

	-- Calculate spawn point
	local spawner_loc = spawner:GetAbsOrigin()
	local forward_direction = spawner:GetForwardVector()
	local spawn_start = spawner_loc - forward_direction * spawn_length / 3
	local spawn_point = RotatePosition(spawn_start, QAngle(0, 90, 0), spawn_start + forward_direction * ( RandomInt(0, 10) - 5 ) * spawn_radius / 5 )

	-- Spawn projectile
	local machine_projectile = {
		Ability				= ability,
		EffectName			= particle_machine,
		vSpawnOrigin		= spawn_point,
		fDistance			= spawn_length,
		fStartRadius		= collision_radius,
		fEndRadius			= collision_radius,
		Source				= caster,
		bHasFrontalCone		= false,
		bReplaceExisting	= false,
		iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
	--	iUnitTargetFlags	= ,
		iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
	--	fExpireTime			= ,
		bDeleteOnHit		= true,
		vVelocity			= Vector(forward_direction.x, forward_direction.y, 0) * speed,
		bProvidesVision		= false,
	--	iVisionRadius		= ,
	--	iVisionTeamNumber	= caster:GetTeamNumber(),
	}
	ProjectileManager:CreateLinearProjectile(machine_projectile)

	-- If this spawner is dying, destroy it
	if spawner:GetHealth() <= 1 then
		spawner:Destroy()

	-- If not, reduce its health by 1
	else
		spawner:SetHealth( spawner:GetHealth() - 1 )
	end
end

function MarchDamage( keys )
	local caster = keys.caster
	local spawner = keys.target
	local attacker = keys.attacker
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- If the ability was unlearned, do nothing
	if not ability then
		return nil
	end
	
	-- Parameters
	local attacks_to_kill = ability:GetLevelSpecialValueFor("attacks_to_kill", ability_level)
	local max_spawns = ability:GetLevelSpecialValueFor("max_spawns", ability_level)
	local damage = 1

	-- If the attacker is a hero, deal more damage
	if attacker:IsHero() then
		damage = math.ceil( max_spawns / attacks_to_kill )
	end

	-- If the damage is enough to kill the spawner, destroy it
	if spawner:GetHealth() <= damage then
		spawner:Destroy()

	-- Else, reduce its HP
	else
		spawner:SetHealth(spawner:GetHealth() - damage)
	end
end

--[[

		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines"							"空战机械"
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Description"					"<font color='#FF7800'>被动召唤一个空战机械为修补匠作战，空战机械拥有激光和热导飞弹两个技能，技能等级和神杖加成与修补匠同步。</font>\n机械自动对%search_range%范围内的敌人施放技能，如果机械对敌方英雄造成了伤害，则机械的技能将进入较长的冷却中。\n开启本技能的自动施放将使空战机械停止施放技能。\n<font color='#FF7800'>部署：</font>令空战机械停留在目标位置并获得%search_range%范围内所有小兵的视野，对自身施法将召回机械。\n<font color='#FF7800'>过载：</font>每层过载效果提高机械%stack_range%搜索范围。"
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Lore"						"就算实验室最后被封锁了，呼叫机械兵锋的无线电还是通的。"
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Note0"						"如果目标是英雄或空战机械与修补匠之间超过1000距离，那么它造成的伤害降低50%。"
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Note1"						"修补匠死亡时空战机械不会施法，空战机械不会施加激光的致盲和降低视野效果。"
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_cast_cooldown"				"机械技能冷却时间："
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_hero_cooldown"				"击中英雄冷却时间："


		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines"							"Air Combat Machinery"
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Description"					"<font color='#FF7800'>Summon a Air combat machinery for Tinker passively, machinery has Laser and Heat-Seeking Missiles abilities, their level and scepter upgrade is same as Tinker's.</font>\nMachinery casts abilities automatically on enemies in %search_range% radius, if it deals damage to enemy hero, it's abilities will turn into a longer cooldown time.\nEnable auto-cast can disable machinery's abilities.\n<font color='#FF7800'>Deploy:</font>Let machinery stay in target location and gain enemy creeps' vision in %search_range% radius, cast this ability on yourself will call back the machinery.\n<font color='#FF7800'>Overdrive:</font>Every stack conut increases the search range by %stack_range%."
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Lore"						"Even though the laboratory has since been sealed off, the ability to radio in robotic drones is still in working order."
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Note0"						"If the target is a hero or the distance between Tinker and Machinery is over 1000, the machinery's outgoing damage will reduced by 50%."
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_Note1"						"Won't cast if Tinker is dead, won't apply Laser's debuff."
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_cast_cooldown"				"MACHINERY ABILITY COOLDOWN:"
		"DOTA_Tooltip_ability_imba_tinker_march_of_the_machines_hero_cooldown"				"HIT HERO COOLDOWN:"


]]