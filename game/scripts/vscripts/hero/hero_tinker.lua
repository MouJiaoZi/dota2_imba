
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
		if keys.target:IsRealHero() then
			self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_march_of_the_machines_cooldown", {duration = self:GetAbility():GetSpecialValueFor("hero_cooldown")})
		end
		if (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > self:GetAbility():GetSpecialValueFor("break_distance") then
			return (self:GetAbility():GetSpecialValueFor("break_dmg_pct") - 100)
		elseif keys.target:IsRealHero() then
			return (self:GetAbility():GetSpecialValueFor("break_dmg_pct") - 100)
		else
			return 100
		end
	end
end

function modifier_imba_march_of_the_machines_thinker:OnCreated()
	if IsServer() then
		self.range = self:GetAbility():GetSpecialValueFor("search_range")
		self.pfx = ParticleManager:CreateParticleForPlayer("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		self.color = PLAYER_COLORS[self:GetCaster():GetPlayerID()]
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.range,0,0))
		ParticleManager:SetParticleControl(self.pfx, 2, Vector(10,0,0))
		ParticleManager:SetParticleControl(self.pfx, 3, Vector(100,0,0))
		ParticleManager:SetParticleControl(self.pfx, 15, Vector(self.color[1], self.color[2], self.color[3]))
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_march_of_the_machines_thinker:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	if caster:IsNull() or ability:IsNull() or not caster:HasAbility("imba_tinker_march_of_the_machines") then
		parent:ForceKill(false)
		self:Destroy()
		return
	end

	local range = ability:GetSpecialValueFor("search_range") + ability:GetSpecialValueFor("stack_range") * caster:GetModifierStackCount("modifier_imba_rearm_stack", nil)
	if self.range ~= range then
		self.range = range
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = ParticleManager:CreateParticleForPlayer("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetCaster():GetPlayerOwner())
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(range,0,0))
		ParticleManager:SetParticleControl(self.pfx, 2, Vector(10,0,0))
		ParticleManager:SetParticleControl(self.pfx, 3, Vector(100,0,0))
		ParticleManager:SetParticleControl(self.pfx, 15, Vector(self.color[1], self.color[2], self.color[3]))
	end
	local laser = caster:FindAbilityByName("imba_tinker_laser")
	local missile = caster:FindAbilityByName("imba_tinker_heat_seeking_missile")

	local self_laser = parent:FindAbilityByName("imba_tinker_laser")
	local self_missile = parent:FindAbilityByName("imba_tinker_heat_seeking_missile")

	if laser then
		self_laser:SetLevel(laser:GetLevel())
	end
	if missile then
		self_missile:SetLevel(missile:GetLevel())
	end

	if self:GetStackCount() == 0 then
		if (caster:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D() > 550 then
			parent:SetAbsOrigin(GetRandomPosition2D(caster:GetAbsOrigin(), 300))
		else
			parent:MoveToNPC(caster)
		end
	end

	if not parent:HasModifier("modifier_imba_march_of_the_machines_cooldown") and not ability:GetAutoCastState() and caster:IsAlive() then
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_FARTHEST, false)
		local hero = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_FARTHEST, false)
		if #enemies > 0 then
			if self_laser:GetLevel() > 0 then
				local target = enemies[1]
				if #hero > 0 then
					target = hero[1]
				end
				parent:SetCursorCastTarget(target)
				self_laser:OnSpellStart()
			end
			if self_missile:GetLevel() > 0 then
				self_missile:OnSpellStart()
			end
			parent:AddNewModifier(caster, ability, "modifier_imba_march_of_the_machines_cooldown", {duration = ability:GetSpecialValueFor("cast_cooldown")})
		end
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
function modifier_imba_march_of_the_machines_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("search_range") end
function modifier_imba_march_of_the_machines_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_march_of_the_machines_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_march_of_the_machines_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_CREEP end
function modifier_imba_march_of_the_machines_thinker:GetAuraEntityReject(unit)
	if string.find(unit:GetUnitName(), "creep") then
		return false
	else
		return true
	end
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

LinkLuaModifier("modifier_imba_rearm_fuck", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rearm_stack", "hero/hero_tinker", LUA_MODIFIER_MOTION_NONE)

function imba_tinker_rearm:IsHiddenWhenStolen() 	return false end
function imba_tinker_rearm:IsRefreshable() 			return true end
function imba_tinker_rearm:IsStealable() 			return true end
function imba_tinker_rearm:IsNetherWardStealable()	return false end
function imba_tinker_rearm:GetIntrinsicModifierName() return "modifier_imba_rearm_fuck" end

function imba_tinker_rearm:OnSpellStart()
	local caster = self:GetCaster()
	self:EndCooldown()
	self:StartCooldown(self:GetSpecialValueFor("cooldown_tooltip"))
	-- List of unrefreshable abilities (for Random OMG/LOD modes)
	local forbidden_abilities = {
		"imba_tinker_rearm",
		"ancient_apparition_ice_blast",
		"zuus_thundergods_wrath",
		"furion_wrath_of_nature",
		"imba_magnus_reverse_polarity",
		"imba_omniknight_guardian_angel",
		"imba_mirana_arrow",
		"imba_dazzle_shallow_grave",
		"imba_wraith_king_reincarnation",
		"imba_abaddon_borrowed_time",
		"furion_force_of_nature",
		"imba_nyx_assassin_spiked_carapace",
		"elder_titan_earth_splitter",
		"imba_centaur_stampede",
		"silencer_global_silence"
	}

	-- List of unrefreshable items
	local forbidden_items = {
		"item_imba_bloodstone",
		"item_imba_arcane_boots",
		"item_imba_mekansm",
		"item_imba_mekansm_2",
		"item_imba_guardian_greaves",
		"item_imba_hand_of_midas",
		"item_imba_white_queen_cape",
		"item_imba_black_king_bar",
		"item_imba_refresher",
		"item_imba_necronomicon",
		"item_imba_necronomicon_2",
		"item_imba_necronomicon_3",
		"item_imba_necronomicon_4",
		"item_imba_necronomicon_5",
		"item_imba_skadi",
		"item_imba_sphere",
		"item_aeon_disk"
	}
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
		if current_ability and not IsInTable(current_ability:GetName(), forbidden_abilities) then
			current_ability:EndCooldown()
		end
	end

	-- Refresh items
	for i = 0, 8 do
		local current_item = caster:GetItemInSlot(i)
		if current_item and not IsInTable(current_item:GetName(), forbidden_items) then
			current_item:EndCooldown()
		end
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

modifier_imba_rearm_fuck = class({})

function modifier_imba_rearm_fuck:IsDebuff()			return false end
function modifier_imba_rearm_fuck:IsHidden() 			return true end
function modifier_imba_rearm_fuck:IsPurgable() 			return false end
function modifier_imba_rearm_fuck:IsPurgeException() 	return false end
function modifier_imba_rearm_fuck:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_EXECUTED} end

function modifier_imba_rearm_fuck:OnCreated()
	if IsServer() then
		if self:GetParent():IsIllusion() then
			return
		end
		self.time = -10000
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_rearm_fuck:OnIntervalThink()
	if not self:GetParent():IsAlive() then
		return
	end
	local range = 1000 + self:GetParent():GetCastRangeBonus()
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	if #enemies > 0 and self.time == -10000 then
		self.time = GameRules:GetGameTime()
	elseif #enemies == 0 then
		self.time = -10000
	end
end

function modifier_imba_rearm_fuck:OnAbilityExecuted(keys)
	if not IsServer() then
		return
	end
	if (keys.ability:GetName() == "item_imba_sheepstick" or string.find(keys.ability:GetName(), "dagon") or keys.ability:GetName() == "item_ethereal_blade") and keys.unit == self:GetParent() then
		if (GameRules:GetGameTime() - self.time) <= 0.1 then
			--Notifications:BottomToAll({text="检测到修补匠从发现敌方英雄到使用邪恶镰刀/大根/虚灵刀的时间间隔小于0.1秒！！", duration = 5})
			self:SetStackCount(self:GetStackCount() + 1)
			if self:GetStackCount() >= 23 then
				self:GetParent():ForceKill(false)
			end
		end
	end
end