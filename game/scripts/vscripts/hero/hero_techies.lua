

CreateEmptyTalents("techies")


imba_techies_land_mines = class({})

LinkLuaModifier("modifier_imba_land_mines", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_land_mines_charge", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_land_mines_throw_motion", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_land_mines_throw_mark", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_land_mines_explose_delay", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_land_mines_building_prevent", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)

function imba_techies_land_mines:IsHiddenWhenStolen() 		return false end
function imba_techies_land_mines:IsRefreshable() 			return true end
function imba_techies_land_mines:IsStealable() 				return true end
function imba_techies_land_mines:IsNetherWardStealable()	return false end
function imba_techies_land_mines:GetAOERadius() return self:GetSpecialValueFor("small_radius") end
function imba_techies_land_mines:GetIntrinsicModifierName() return "modifier_imba_land_mines_charge" end

function imba_techies_land_mines:CastFilterResultLocation(location)
	if IsNearEnemyFountain(location, self:GetCaster():GetTeamNumber(), 1600) then
		return UF_FAIL_CUSTOM
	end
end

function imba_techies_land_mines:GetCustomCastErrorLocation(location)
	if IsNearEnemyFountain(location, self:GetCaster():GetTeamNumber(), 1600) then
		return "#dota_hud_error_no_wards_here"
	end
end

function imba_techies_land_mines:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local pos0 = pos
	caster:AddModifierStacks(caster, self, "modifier_imba_land_mines_charge", {}, 1, false, true)
	local mine = CreateUnitByName("npc_imba_techies_land_mine", pos0, true, caster, caster, caster:GetTeamNumber())
	mine:FindAbilityByName("imba_techies_minefield_teleport"):SetLevel(1)
	mine:EmitSound("Hero_Techies.LandMine.Plant")
	mine:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	mine:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	mine:AddNewModifier(caster, self, "modifier_imba_land_mines", {duration = self:GetSpecialValueFor("duration")})
end

function imba_techies_land_mines:ThrowMine(target)
	local caster = self:GetCaster()
	local mine = CreateUnitByName("npc_imba_techies_land_mine", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	mine:FindAbilityByName("imba_techies_minefield_teleport"):SetLevel(1)
	mine:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	mine:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	mine:AddNewModifier(caster, self, "modifier_imba_land_mines_throw_motion", {duration = 3.0})
	mine:AddNewModifier(caster, self, "modifier_imba_land_mines", {duration = self:GetSpecialValueFor("duration")})
	mine:AddNewModifier(caster, self, "modifier_imba_land_mines_throw_mark", {duration = self:GetSpecialValueFor("duration")})
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = (caster:IsRangedAttacker() and caster:GetRangedProjectileName() or "particles/units/heroes/hero_techies/techies_base_attack.vpcf"),
		iMoveSpeed = (caster:IsRangedAttacker() and caster:GetProjectileSpeed() or 900),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		ExtraData = {mine = mine:entindex()}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_techies_land_mines:OnProjectileThink_ExtraData(location, keys)
	if EntIndexToHScript(keys.mine) then
		EntIndexToHScript(keys.mine):SetAbsOrigin(location)
	end
end

function imba_techies_land_mines:OnProjectileHit_ExtraData(target, location, keys)
	if EntIndexToHScript(keys.mine) then
		local mine = EntIndexToHScript(keys.mine)
		mine:SetAbsOrigin(GetGroundPosition(location, nil))
		mine:RemoveModifierByName("modifier_imba_land_mines_throw_motion")
	end
end

modifier_imba_land_mines = class({})

function modifier_imba_land_mines:IsDebuff()			return false end
function modifier_imba_land_mines:IsHidden() 			return true end
function modifier_imba_land_mines:IsPurgable() 			return false end
function modifier_imba_land_mines:IsPurgeException() 	return false end
function modifier_imba_land_mines:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_MAX, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE} end
function modifier_imba_land_mines:GetModifierMoveSpeed_Max() return 25 end
function modifier_imba_land_mines:GetModifierMoveSpeed_Absolute() return 25 end
function modifier_imba_land_mines:CheckState()
	if self.mine and self.mine:HasModifier("modifier_imba_land_mines_throw_motion") then
		return {[MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	else
		return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	end
end
function modifier_imba_land_mines:GetEffectName() return "particles/units/heroes/hero_techies/techies_land_mine.vpcf" end
function modifier_imba_land_mines:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_land_mines:OnCreated()
	self.ability = self:GetAbility()
	self.mine = self:GetParent()
	self.caster = self:GetCaster()
	self.damage = self.ability:GetSpecialValueFor("damage")
	self.big_radius = self.ability:GetSpecialValueFor("big_radius")
	self.small_radius = self.ability:GetSpecialValueFor("small_radius")
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_land_mines:OnIntervalThink()
	local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.mine:GetAbsOrigin(), nil, self.small_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	if #enemies > 0 and not self.mine:HasModifier("modifier_imba_land_mines_explose_delay") then
		local sound = CreateModifierThinker(self.caster, self.ability, "modifier_dummy_thinker", {duration = 0.5}, self.mine:GetAbsOrigin(), self.caster:GetTeamNumber(), false)
		sound:EmitSound("Hero_Techies.LandMine.Priming")
		self.mine:AddNewModifier(self.caster, self.ability, "modifier_imba_land_mines_explose_delay", {duration = self.ability:GetSpecialValueFor("activation_time")})
	end
	local enemies2 = FindUnitsInRadius(self.caster:GetTeamNumber(), self.mine:GetAbsOrigin(), nil, self.big_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
	if #enemies2 > 0 and not self.mine:HasModifier("modifier_imba_land_mines_throw_motion") then
		local target = enemies2[1]
		self.mine:SetAbsOrigin(GetGroundPosition(self.mine:GetAbsOrigin() + (target:GetAbsOrigin() - self.mine:GetAbsOrigin()):Normalized() * 1, nil))
	end
end

function modifier_imba_land_mines:OnDestroy()
	if IsServer() and self:GetStackCount() > 0 then
		local damage = self.ability:GetSpecialValueFor("damage") * math.floor(self.caster:GetLevel() / self.ability:GetSpecialValueFor("levels_per_mine") + 1)
		local building_dmg = self.ability:GetSpecialValueFor("damage")
		local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.mine:GetAbsOrigin(), nil, self.small_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		local enemies2 = FindUnitsInRadius(self.caster:GetTeamNumber(), self.mine:GetAbsOrigin(), nil, self.big_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy:IsBuilding() or self:GetParent():HasModifier("modifier_imba_land_mines_throw_mark") then
				ApplyDamage({victim = enemy, attacker = self.mine, damage = building_dmg, damage_type = self.ability:GetAbilityDamageType(), ability = self.ability})
			else
				ApplyDamage({victim = enemy, attacker = self.mine, damage = damage, damage_type = self.ability:GetAbilityDamageType(), ability = self.ability})
			end
		end
		for _, enemy in pairs(enemies2) do
			if not IsInTable(enemy, enemies) then
				if enemy:IsBuilding() or self:GetParent():HasModifier("modifier_imba_land_mines_throw_mark") then
					ApplyDamage({victim = enemy, attacker = self.mine, damage = (building_dmg / 2), damage_type = self.ability:GetAbilityDamageType(), ability = self.ability})
				else
					ApplyDamage({victim = enemy, attacker = self.mine, damage = (damage / 2), damage_type = self.ability:GetAbilityDamageType(), ability = self.ability})
				end
			end
		end
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self.mine:GetAbsOrigin())
		--ParticleManager:SetParticleControl(pfx, 1, Vector(0,0,self.big_radius))
		ParticleManager:SetParticleControl(pfx, 2, Vector(self.big_radius, self.big_radius, self.big_radius))
		Timers:CreateTimer(5.0, function()
				ParticleManager:DestroyParticle(pfx, true)
				ParticleManager:ReleaseParticleIndex(pfx)
				return nil
			end
		)
		local sound = CreateModifierThinker(self.caster, self.ability, "modifier_dummy_thinker", {duration = 0.5}, self.mine:GetAbsOrigin(), self.caster:GetTeamNumber(), false)
		sound:EmitSound("Hero_Techies.LandMine.Detonate")
		self:GetParent():ForceKill(false)
	end
	self.ability = nil
	self.mine = nil
	self.caster = nil
	self.damage = nil
	self.big_radius = nil
	self.small_radius = nil
end

modifier_imba_land_mines_throw_mark = class({})

function modifier_imba_land_mines_throw_mark:IsDebuff()			return false end
function modifier_imba_land_mines_throw_mark:IsHidden() 		return true end
function modifier_imba_land_mines_throw_mark:IsPurgable() 		return false end
function modifier_imba_land_mines_throw_mark:IsPurgeException() return false end

modifier_imba_land_mines_explose_delay = class({})

function modifier_imba_land_mines_explose_delay:IsDebuff()			return false end
function modifier_imba_land_mines_explose_delay:IsHidden() 			return true end
function modifier_imba_land_mines_explose_delay:IsPurgable() 		return false end
function modifier_imba_land_mines_explose_delay:IsPurgeException() 	return false end

function modifier_imba_land_mines_explose_delay:OnDestroy()
	if IsServer() then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("small_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		if #enemies > 0 and self:GetElapsedTime() >= self:GetDuration() then
			local buff = self:GetParent():FindModifierByName("modifier_imba_land_mines")
			if buff then
				buff:SetStackCount(1)
				buff:Destroy()
			end
		end
	end
end

modifier_imba_land_mines_building_prevent = class({})

function modifier_imba_land_mines_building_prevent:IsDebuff()			return false end
function modifier_imba_land_mines_building_prevent:IsHidden() 			return true end
function modifier_imba_land_mines_building_prevent:IsPurgable() 		return false end
function modifier_imba_land_mines_building_prevent:IsPurgeException() 	return false end

modifier_imba_land_mines_charge = class({})

function modifier_imba_land_mines_charge:IsDebuff()			return false end
function modifier_imba_land_mines_charge:IsHidden() 		return false end
function modifier_imba_land_mines_charge:IsPurgable() 		return false end
function modifier_imba_land_mines_charge:IsPurgeException() return false end
function modifier_imba_land_mines_charge:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK} end
function modifier_imba_land_mines_charge:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_land_mines_charge:OnDestroy() self.ability = nil end

function modifier_imba_land_mines_charge:OnAttack(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsCourier() or keys.target:IsBuilding() or keys.target:IsOther() or self:GetParent():IsIllusion() then
		return
	end
	local throw = false
	if self:GetStackCount() > 0 then
		self:SetStackCount(self:GetStackCount() - 1)
		throw = true
	elseif PseudoRandom:RollPseudoRandom(self.ability, self.ability:GetSpecialValueFor("throw_chance")) then  
		throw = true
	end
	if throw then
		self.ability:ThrowMine(keys.target)
	end
end

modifier_imba_land_mines_throw_motion = class({})

function modifier_imba_land_mines_throw_motion:IsHidden() return true end


imba_techies_stasis_trap = class({})

LinkLuaModifier("modifier_imba_stasis_trap", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stasis_trap_active_delay", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stasis_trap_explose_delay", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_stasis_trap_root_pfx", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)

function imba_techies_stasis_trap:IsHiddenWhenStolen() 		return false end
function imba_techies_stasis_trap:IsRefreshable() 			return true end
function imba_techies_stasis_trap:IsStealable() 			return true end
function imba_techies_stasis_trap:IsNetherWardStealable()	return false end
function imba_techies_stasis_trap:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_techies_stasis_trap:CastFilterResultLocation(location)
	if IsNearEnemyFountain(location, self:GetCaster():GetTeamNumber(), 1600) then
		return UF_FAIL_CUSTOM
	end
end

function imba_techies_stasis_trap:GetCustomCastErrorLocation(location)
	return "#dota_hud_error_no_wards_here"
end

function imba_techies_stasis_trap:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local mine = CreateUnitByName("npc_imba_techies_stasis_trap", pos, true, caster, caster, caster:GetTeamNumber())
	mine:FindAbilityByName("imba_techies_minefield_teleport"):SetLevel(1)
	mine:EmitSound("Hero_Techies.StasisTrap.Plant")
	mine:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	mine:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	mine:AddNewModifier(caster, self, "modifier_imba_stasis_trap_active_delay", {duration = self:GetSpecialValueFor("activation_delay")})
	mine:AddNewModifier(caster, self, "modifier_imba_stasis_trap", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_stasis_trap_active_delay = class({})

function modifier_imba_stasis_trap_active_delay:IsDebuff()			return false end
function modifier_imba_stasis_trap_active_delay:IsHidden() 			return true end
function modifier_imba_stasis_trap_active_delay:IsPurgable() 		return false end
function modifier_imba_stasis_trap_active_delay:IsPurgeException() 	return false end
function modifier_imba_stasis_trap_active_delay:GetEffectName() return "particles/units/heroes/hero_techies/techies_stasis_beams_heroelec.vpcf" end

modifier_imba_stasis_trap = class({})

function modifier_imba_stasis_trap:IsDebuff()			return false end
function modifier_imba_stasis_trap:IsHidden() 			return true end
function modifier_imba_stasis_trap:IsPurgable() 		return false end
function modifier_imba_stasis_trap:IsPurgeException() 	return false end
function modifier_imba_stasis_trap:DeclareFunctions() 	return {MODIFIER_PROPERTY_MOVESPEED_MAX, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE} end
function modifier_imba_stasis_trap:GetModifierMoveSpeed_Max() return 25 end
function modifier_imba_stasis_trap:GetModifierMoveSpeed_Absolute() return 25 end
function modifier_imba_stasis_trap:CheckState() return (self:GetParent():HasModifier("modifier_imba_stasis_trap_active_delay") and {[MODIFIER_STATE_NO_UNIT_COLLISION] = true} or {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true}) end

function modifier_imba_stasis_trap:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_stasis_trap:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #enemies > 0 and not self:GetParent():HasModifier("modifier_imba_stasis_trap_active_delay") and not self:GetParent():HasModifier("modifier_imba_stasis_trap_explose_delay") then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stasis_trap_explose_delay", {duration = self:GetAbility():GetSpecialValueFor("explosion_delay")})
	end
end

function modifier_imba_stasis_trap:OnDestroy()
	if IsServer() and self:GetStackCount() > 0 then
		local sound = CreateModifierThinker(self:GetCaster(), nil, "modifier_dummy_thinker", {duration = 1.0}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
		sound:EmitSound("Hero_Techies.StasisTrap.Stun")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"),0,0))
		Timers:CreateTimer(3.0, function()
				ParticleManager:DestroyParticle(pfx, true)
				ParticleManager:ReleaseParticleIndex(pfx)
				return nil
			end
		)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_rooted", {duration = self:GetAbility():GetSpecialValueFor("root_duration")})
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stasis_trap_root_pfx", {duration = self:GetAbility():GetSpecialValueFor("root_duration")})
			if enemy:GetMana() > 0 then
				enemy:SetMana(enemy:GetMana() * (1 - self:GetAbility():GetSpecialValueFor("current_mana_burn_pct") / 100))
			end
		end
		AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("vision_radius"), self:GetAbility():GetSpecialValueFor("vision_duration"), true)
	end
end

modifier_imba_stasis_trap_explose_delay = class({})

function modifier_imba_stasis_trap_explose_delay:IsDebuff()			return false end
function modifier_imba_stasis_trap_explose_delay:IsHidden() 		return true end
function modifier_imba_stasis_trap_explose_delay:IsPurgable() 		return false end
function modifier_imba_stasis_trap_explose_delay:IsPurgeException() return false end

function modifier_imba_stasis_trap_explose_delay:OnDestroy()
	if IsServer() then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		if #enemies > 0 and self:GetElapsedTime() >= self:GetDuration() then
			local buff = self:GetParent():FindModifierByName("modifier_imba_stasis_trap")
			if buff then
				buff:SetStackCount(1)
			end
			self:GetParent():ForceKill(false)
		end
	end
end

modifier_imba_stasis_trap_root_pfx = class({})

function modifier_imba_stasis_trap_root_pfx:IsDebuff()			return true end
function modifier_imba_stasis_trap_root_pfx:IsHidden() 			return true end
function modifier_imba_stasis_trap_root_pfx:IsPurgable() 		return true end
function modifier_imba_stasis_trap_root_pfx:IsPurgeException() 	return true end
function modifier_imba_stasis_trap_root_pfx:GetStatusEffectName() return "particles/status_fx/status_effect_techies_stasis.vpcf" end
function modifier_imba_stasis_trap_root_pfx:StatusEffectPriority() return 15 end
function modifier_imba_stasis_trap_root_pfx:GetEffectName() return "particles/units/heroes/hero_techies/techies_stasis_beams_heroelec.vpcf" end

imba_techies_suicide = class({})

LinkLuaModifier("modifier_imba_suicide_cast_point", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_suicide_motion", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)

function imba_techies_suicide:IsHiddenWhenStolen() 		return false end
function imba_techies_suicide:IsRefreshable() 			return true end
function imba_techies_suicide:IsStealable() 			return true end
function imba_techies_suicide:IsNetherWardStealable()	return false end
function imba_techies_suicide:GetIntrinsicModifierName() return "modifier_imba_suicide_cast_point" end
function imba_techies_suicide:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_techies_suicide:GetCastPoint() return (self:GetCaster():GetModifierStackCount("modifier_imba_suicide_cast_point", nil) / 100) end
function imba_techies_suicide:OnAbilityPhaseStart()
	local buff = self:GetCaster():FindModifierByName("modifier_imba_suicide_cast_point")
	buff:SetStackCount(self.BaseClass.GetCastPoint(self) * ((self:GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Length2D() / self:GetCastRange(self:GetCursorPosition(), self:GetCaster())) * 100)
	return true
end

function imba_techies_suicide:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	caster:EmitSound("Hero_Techies.BlastOff.Cast")
	caster:AddNewModifier(caster, self, "modifier_imba_suicide_motion", {duration = self:GetSpecialValueFor("duration"), pos_x = pos.x, pos_y = pos.y, pos_z = pos.z})
end

modifier_imba_suicide_cast_point = class({})

function modifier_imba_suicide_cast_point:IsDebuff()			return false end
function modifier_imba_suicide_cast_point:IsHidden() 			return true end
function modifier_imba_suicide_cast_point:IsPurgable() 			return false end
function modifier_imba_suicide_cast_point:IsPurgeException() 	return false end

modifier_imba_suicide_motion = class({})

function modifier_imba_suicide_motion:IsDebuff()			return false end
function modifier_imba_suicide_motion:IsHidden() 			return true end
function modifier_imba_suicide_motion:IsPurgable() 			return false end
function modifier_imba_suicide_motion:IsPurgeException() 	return false end
function modifier_imba_suicide_motion:IsMotionController()	return true end
function modifier_imba_suicide_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_LOW end
function modifier_imba_suicide_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_MOVESPEED_LIMIT} end
function modifier_imba_suicide_motion:GetModifierMoveSpeed_Absolute() if IsServer() then return 1 end end
function modifier_imba_suicide_motion:GetModifierMoveSpeed_Limit() if IsServer() then return 1 end end

function modifier_imba_suicide_motion:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.distance = (self.pos - self:GetParent():GetAbsOrigin()):Length() / (self:GetDuration() / FrameTime() - 2)
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_suicide_motion:OnIntervalThink()
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local height = 300
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + (self.pos - self:GetParent():GetAbsOrigin()):Normalized() * self.distance, nil)
	next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
	self:GetParent():SetAbsOrigin(next_pos)
end

function modifier_imba_suicide_motion:OnDestroy()
	if IsServer() then
		if self:GetElapsedTime() >= self:GetDuration() then
			local ability = self:GetAbility()
			local parent = self:GetParent()
			self:GetParent():EmitSound("Hero_Techies.Suicide")
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_suicide.vpcf", PATTACH_ABSORIGIN, parent)
			ParticleManager:SetParticleControl(pfx, 1, Vector(ability:GetSpecialValueFor("radius") / 4, 0, 0))
			ParticleManager:SetParticleControl(pfx, 2, Vector(ability:GetSpecialValueFor("radius"),1,1))
			ParticleManager:ReleaseParticleIndex(pfx)
			local hp_cost = parent:GetMaxHealth() * (ability:GetSpecialValueFor("hp_cost") / 100)
			ApplyDamage({victim = parent, attacker = parent, ability = ability, damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, damage = hp_cost})
			local enemies = FindUnitsInRadius(parent:GetTeamNumber(), parent:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				ApplyDamage({victim = enemy, attacker = parent, ability = ability, damage_type = ability:GetAbilityDamageType(), damage = ability:GetSpecialValueFor("damage")})
				enemy:AddNewModifier(self:GetCaster(), ability, "modifier_silence", {duration = ability:GetSpecialValueFor("silence_duration")})
			end

			local land_mine = parent:FindAbilityByName("imba_techies_land_mines")
			if land_mine and land_mine:GetLevel() > 0 then
				local pos = GetRandomPosition2D(parent:GetAbsOrigin(), ability:GetSpecialValueFor("radius"))
				local mine = CreateUnitByName("npc_imba_techies_land_mine", pos, true, parent, parent, parent:GetTeamNumber())
				mine:SetControllableByPlayer(parent:GetPlayerID(), true)
				mine:AddNewModifier(parent, land_mine, "modifier_kill", {duration = land_mine:GetSpecialValueFor("duration")})
				mine:AddNewModifier(parent, land_mine, "modifier_imba_land_mines", {duration = land_mine:GetSpecialValueFor("duration")})
				mine:AddNewModifier(caster, land_mine, "modifier_imba_land_mines_throw_mark", {})
			end

			local stasis_trap = parent:FindAbilityByName("imba_techies_stasis_trap")
			if stasis_trap and stasis_trap:GetLevel() > 0 then
				local pos = GetRandomPosition2D(parent:GetAbsOrigin(), ability:GetSpecialValueFor("radius"))
				local mine = CreateUnitByName("npc_imba_techies_stasis_trap", pos, true, parent, parent, parent:GetTeamNumber())
				mine:SetControllableByPlayer(parent:GetPlayerID(), true)
				mine:AddNewModifier(parent, stasis_trap, "modifier_kill", {duration = stasis_trap:GetSpecialValueFor("duration")})
				mine:AddNewModifier(parent, stasis_trap, "modifier_imba_stasis_trap_active_delay", {duration = stasis_trap:GetSpecialValueFor("activation_delay")})
				mine:AddNewModifier(parent, stasis_trap, "modifier_imba_stasis_trap", {duration = stasis_trap:GetSpecialValueFor("duration")})
			end

			local remote_mine = parent:FindAbilityByName("imba_techies_remote_mines")
			if remote_mine and remote_mine:GetLevel() > 0 then
				local pos = GetRandomPosition2D(parent:GetAbsOrigin(), ability:GetSpecialValueFor("radius"))
				local mine = CreateUnitByName("npc_imba_techies_remote_mine", pos, true, parent, parent, parent:GetTeamNumber())
				mine:EmitSound("Hero_Techies.RemoteMine.Plant")
				mine:SetControllableByPlayer(parent:GetPlayerID(), false)
				mine:AddNewModifier(parent, remote_mine, "modifier_kill", {duration = remote_mine:GetSpecialValueFor("duration")})
				mine:AddNewModifier(parent, remote_mine, "modifier_imba_remote_mines", {duration = remote_mine:GetSpecialValueFor("duration")})
				for i=0, 23 do
					local ability = mine:GetAbilityByIndex(i)
					if ability then
						ability:SetLevel(1)
					end
				end
			end
		end
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

imba_techies_minefield_sign = class({})

LinkLuaModifier("modifier_imba_minefield_sign_sign", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_minefield_sign_scepter", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)

function imba_techies_minefield_sign:IsHiddenWhenStolen() 		return false end
function imba_techies_minefield_sign:IsRefreshable() 			return true end
function imba_techies_minefield_sign:IsStealable() 				return false end
function imba_techies_minefield_sign:IsNetherWardStealable()	return false end
function imba_techies_minefield_sign:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_techies_minefield_sign:IsTalentAbility() return true end
function imba_techies_minefield_sign:OnUpgrade() self:UseResources(true, true, true) end

function imba_techies_minefield_sign:CastFilterResultLocation(location)
	if IsNearEnemyFountain(location, self:GetCaster():GetTeamNumber(), 5500) then
		return UF_FAIL_CUSTOM
	end
	if IsServer() then
		local buildings = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, 500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		if #buildings > 0 then
			return UF_FAIL_CUSTOM
		end
	end
end

function imba_techies_minefield_sign:GetCustomCastErrorLocation(location)
	return "#dota_hud_error_no_wards_here"
end

function imba_techies_minefield_sign:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	if not self.sign then
		local sign = CreateUnitByName("npc_imba_techies_minefield_sign", pos, true, caster, caster, caster:GetTeamNumber())
		sign:SetForwardVector(Vector(0,-1,0))
		sign:AddNewModifier(caster, self, "modifier_imba_minefield_sign_sign", {})
		self.sign = sign
	else
		FindClearSpaceForUnit(self.sign, pos, true)
	end
	self.sign:EmitSound("Hero_Techies.Sign")
end

modifier_imba_minefield_sign_sign = class({})

function modifier_imba_minefield_sign_sign:IsDebuff()			return false end
function modifier_imba_minefield_sign_sign:IsHidden() 			return true end
function modifier_imba_minefield_sign_sign:IsPurgable() 		return false end
function modifier_imba_minefield_sign_sign:IsPurgeException() 	return false end
function modifier_imba_minefield_sign_sign:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NOT_ON_MINIMAP_FOR_ENEMIES] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

function modifier_imba_minefield_sign_sign:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticleForPlayer("particles/basic_ambient/generic_range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), self:GetParent():GetPlayerOwner())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), 0, 0))
		ParticleManager:SetParticleControl(pfx, 2, Vector(3, 0, 0))
		ParticleManager:SetParticleControl(pfx, 3, Vector(50, 0, 0))
		ParticleManager:SetParticleControl(pfx, 15, Vector(255, 0, 0))
		self:AddParticle(pfx, true, false, 15, false, false)
	end
end

function modifier_imba_minefield_sign_sign:IsAura() return self:GetCaster():HasScepter() end
function modifier_imba_minefield_sign_sign:GetAuraDuration() return 0.1 end
function modifier_imba_minefield_sign_sign:GetModifierAura() return "modifier_imba_minefield_sign_scepter" end
function modifier_imba_minefield_sign_sign:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_minefield_sign_sign:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_minefield_sign_sign:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_minefield_sign_sign:GetAuraSearchType() return DOTA_UNIT_TARGET_OTHER end
function modifier_imba_minefield_sign_sign:GetAuraEntityReject(unit)
	if unit:GetName() ~= "npc_dota_techies_mines" or unit:GetPlayerOwnerID() ~= self:GetParent():GetPlayerOwnerID() then
		return true
	end
	return false
end

modifier_imba_minefield_sign_scepter = class({})

function modifier_imba_minefield_sign_scepter:IsDebuff()			return false end
function modifier_imba_minefield_sign_scepter:IsHidden() 			return true end
function modifier_imba_minefield_sign_scepter:IsPurgable() 			return false end
function modifier_imba_minefield_sign_scepter:IsPurgeException() 	return false end
function modifier_imba_minefield_sign_scepter:CheckState() return {[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true, [MODIFIER_STATE_INVISIBLE] = true} end
function modifier_imba_minefield_sign_scepter:DeclareFunctions() return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL} end
function modifier_imba_minefield_sign_scepter:GetModifierInvisibilityLevel() return 1 end

imba_techies_minefield_teleport = class({})

function imba_techies_minefield_teleport:IsHiddenWhenStolen() 		return false end
function imba_techies_minefield_teleport:IsRefreshable() 			return false end
function imba_techies_minefield_teleport:IsStealable() 				return false end
function imba_techies_minefield_teleport:IsNetherWardStealable()	return false end
function imba_techies_minefield_teleport:IsTalentAbility() return true end

function imba_techies_minefield_teleport:CastFilterResult()
	if IsServer() and not self:GetCaster():GetOwnerEntity():HasScepter() then
		return UF_FAIL_CUSTOM
	end
end

function imba_techies_minefield_teleport:GetCustomCastError()
	return "#IMBA_HUD_ERROR_NO_SCEPTER"
end

function imba_techies_minefield_teleport:OnSpellStart()
	local caster = self:GetCaster()
	local techies = caster:GetOwnerEntity()
	local ability = techies:FindAbilityByName("imba_techies_minefield_sign")
	if not ability or not techies or not ability.sign then
		self:EndCooldown()
	end
	FindClearSpaceForUnit(caster, GetRandomPosition2D(ability.sign:GetAbsOrigin(), self:GetSpecialValueFor("teleport_radius")), true)
end

imba_techies_remote_mines = class({})

LinkLuaModifier("modifier_imba_remote_mines", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)

function imba_techies_remote_mines:IsHiddenWhenStolen() 	return false end
function imba_techies_remote_mines:IsRefreshable() 			return true end
function imba_techies_remote_mines:IsStealable() 			return true end
function imba_techies_remote_mines:IsNetherWardStealable()	return false end
function imba_techies_remote_mines:GetCastRange(vLocation, hTarget) return (self:GetCaster():HasScepter() and self:GetSpecialValueFor("cast_range_scepter") or self:GetSpecialValueFor("cast_range_tooltip")) end
function imba_techies_remote_mines:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_techies_remote_mines:GetAssociatedSecondaryAbilities() return "imba_techies_focused_detonate" end

function imba_techies_remote_mines:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_techies_focused_detonate")
	if ability then
		ability:SetLevel(1)
	end
end

function imba_techies_remote_mines:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Techies.RemoteMine.Toss")
	local pos = self:GetCursorPosition()
	self.mine = CreateUnitByName("npc_imba_techies_remote_mine", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	self.mine:AddNoDraw()
	self.mine:SetControllableByPlayer(caster:GetPlayerID(), false)
	self.mine:AddNewModifier(caster, self, "modifier_kill", {duration = 3.0})
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mine_plant.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(self.pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_remote", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.pfx, 1, pos)
	ParticleManager:SetParticleControlEnt(self.pfx, 2, self.mine, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.mine:GetAbsOrigin(), true)
	return true
end

function imba_techies_remote_mines:OnAbilityPhaseInterrupted()
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	if self.mine then
		self.mine:ForceKill(false)
	end
end

function imba_techies_remote_mines:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local mine = CreateUnitByName("npc_imba_techies_remote_mine", pos, true, caster, caster, caster:GetTeamNumber())
	mine:EmitSound("Hero_Techies.RemoteMine.Plant")
	mine:SetControllableByPlayer(caster:GetPlayerID(), false)
	mine:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	mine:AddNewModifier(caster, self, "modifier_imba_remote_mines", {duration = self:GetSpecialValueFor("duration")})
	for i=0, 23 do
		local ability = mine:GetAbilityByIndex(i)
		if ability then
			ability:SetLevel(1)
		end
	end
end

imba_techies_remote_mines_self_detonate = class({})

function imba_techies_remote_mines_self_detonate:IsHiddenWhenStolen() 		return false end
function imba_techies_remote_mines_self_detonate:IsRefreshable() 			return true end
function imba_techies_remote_mines_self_detonate:IsStealable() 				return false end
function imba_techies_remote_mines_self_detonate:IsNetherWardStealable()	return false end
function imba_techies_remote_mines_self_detonate:IsTalentAbility() return true end

function imba_techies_remote_mines_self_detonate:OnSpellStart()
	local ability = self:GetCaster():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines")
	if ability then
		self:GetCaster():FindModifierByName("modifier_imba_remote_mines"):SetStackCount(1)
		self:GetCaster():FindModifierByName("modifier_imba_remote_mines"):Destroy()
	end
	self:GetCaster():ForceKill(false)
end

modifier_imba_remote_mines = class({})

function modifier_imba_remote_mines:IsDebuff()			return false end
function modifier_imba_remote_mines:IsHidden() 			return true end
function modifier_imba_remote_mines:IsPurgable() 		return false end
function modifier_imba_remote_mines:IsPurgeException() 	return false end
function modifier_imba_remote_mines:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_remote_mines:GetEffectName() return "particles/units/heroes/hero_techies/techies_remote_mine.vpcf" end
function modifier_imba_remote_mines:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_remote_mines:OnDestroy()
	if IsServer() and self:GetStackCount() > 0 then
		local ability = self:GetParent():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines")
		if not ability then
			return
		end
		local caster = self:GetParent():GetOwnerEntity()
		local dmg = caster:HasScepter() and ability:GetSpecialValueFor("damage_scepter") or ability:GetSpecialValueFor("damage")
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = dmg, damage_type = ability:GetAbilityDamageType(), ability = ability})
		end
		local sound = CreateModifierThinker(caster, nil, "modifier_dummy_thinker", {duration = 1.0}, self:GetParent():GetAbsOrigin(), caster:GetTeamNumber(), false)
		sound:EmitSound("Hero_Techies.RemoteMine.Detonate")
		sound:EmitSound("Hero_Techies.RemoteMine.Activate")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf", PATTACH_ABSORIGIN, sound)
		ParticleManager:SetParticleControl(pfx, 1, Vector(ability:GetSpecialValueFor("radius"), ability:GetSpecialValueFor("radius"), ability:GetSpecialValueFor("radius")))
		ParticleManager:ReleaseParticleIndex(pfx)
		AddFOWViewer(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), ability:GetSpecialValueFor("vision_radius"), ability:GetSpecialValueFor("vision_duration"), true)
	end
end

imba_techies_focused_detonate = class({})

function imba_techies_focused_detonate:IsHiddenWhenStolen() 	return false end
function imba_techies_focused_detonate:IsRefreshable() 			return true end
function imba_techies_focused_detonate:IsStealable() 			return false end
function imba_techies_focused_detonate:IsNetherWardStealable()	return false end
function imba_techies_focused_detonate:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_techies_focused_detonate:GetAssociatedPrimaryAbilities() return "imba_techies_remote_mines" end

function imba_techies_focused_detonate:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local mines = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, mine in pairs(mines) do
		if mine:GetPlayerOwnerID() == caster:GetPlayerOwnerID() and mine:GetUnitName() == "npc_imba_techies_remote_mine" and mine:HasAbility("imba_techies_remote_mines_self_detonate") then
			if mine:FindModifierByName("modifier_imba_remote_mines") then
				mine:FindModifierByName("modifier_imba_remote_mines"):SetStackCount(1)
				mine:FindModifierByName("modifier_imba_remote_mines"):Destroy()
				mine:ForceKill(false)
			end
		end
	end
end

imba_techies_remote_auto_creep = class({})

LinkLuaModifier("modifier_imba_remote_auto_creep", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)

function imba_techies_remote_auto_creep:IsHiddenWhenStolen() 	return false end
function imba_techies_remote_auto_creep:IsRefreshable() 		return true end
function imba_techies_remote_auto_creep:IsStealable() 			return false end
function imba_techies_remote_auto_creep:IsNetherWardStealable()	return false end
function imba_techies_remote_auto_creep:IsTalentAbility() return true end
function imba_techies_remote_auto_creep:GetIntrinsicModifierName() return "modifier_imba_remote_auto_creep" end

function imba_techies_remote_auto_creep:OnToggle()
	local ability = self:GetCaster():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines")
	if not ability or not self:GetCaster():IsAlive() then
		return
	end
	if self:GetToggleState() then
		self:GetCaster():FindModifierByName("modifier_imba_remote_auto_creep"):StartIntervalThink(0.1)
		ability.creep = true
	else
		self:GetCaster():FindModifierByName("modifier_imba_remote_auto_creep"):StartIntervalThink(-1)
		ability.creep = false
	end
end

modifier_imba_remote_auto_creep = class({})

function modifier_imba_remote_auto_creep:IsDebuff()			return false end
function modifier_imba_remote_auto_creep:IsHidden() 		return true end
function modifier_imba_remote_auto_creep:IsPurgable() 		return false end
function modifier_imba_remote_auto_creep:IsPurgeException() return false end

function modifier_imba_remote_auto_creep:OnCreated()
	if IsServer() and self:GetParent():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines") then
		if self:GetParent():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines").creep then
			self:GetAbility():ToggleAbility()
		end
	end
end

function modifier_imba_remote_auto_creep:OnIntervalThink()
	local ability = self:GetParent():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines")
	if not ability or not self:GetParent():IsAlive() then
		return
	end
	local caster = self:GetParent():GetOwnerEntity()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #enemies > 0 then
		self:GetParent():FindAbilityByName("imba_techies_remote_mines_self_detonate"):OnSpellStart()
	end
end

imba_techies_remote_auto_hero = class({})

LinkLuaModifier("modifier_imba_remote_auto_hero", "hero/hero_techies", LUA_MODIFIER_MOTION_NONE)

function imba_techies_remote_auto_hero:IsHiddenWhenStolen() 	return false end
function imba_techies_remote_auto_hero:IsRefreshable() 			return true end
function imba_techies_remote_auto_hero:IsStealable() 			return false end
function imba_techies_remote_auto_hero:IsNetherWardStealable()	return false end
function imba_techies_remote_auto_hero:IsTalentAbility() return true end
function imba_techies_remote_auto_hero:GetIntrinsicModifierName() return "modifier_imba_remote_auto_hero" end

function imba_techies_remote_auto_hero:OnToggle()
	local ability = self:GetCaster():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines")
	if not ability then
		return
	end
	if self:GetToggleState() or not self:GetCaster():IsAlive() then
		self:GetCaster():FindModifierByName("modifier_imba_remote_auto_hero"):StartIntervalThink(0.1)
		ability.hero = true
	else
		self:GetCaster():FindModifierByName("modifier_imba_remote_auto_hero"):StartIntervalThink(-1)
		ability.hero = false
	end
end

modifier_imba_remote_auto_hero = class({})

function modifier_imba_remote_auto_hero:IsDebuff()			return false end
function modifier_imba_remote_auto_hero:IsHidden() 			return true end
function modifier_imba_remote_auto_hero:IsPurgable() 		return false end
function modifier_imba_remote_auto_hero:IsPurgeException() 	return false end

function modifier_imba_remote_auto_hero:OnCreated()
	if IsServer() and self:GetParent():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines") then
		if self:GetParent():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines").hero then
			self:GetAbility():ToggleAbility()
		end
	end
end

function modifier_imba_remote_auto_hero:OnIntervalThink()
	if not IsServer() then
		return
	end
	local ability = self:GetParent():GetOwnerEntity():FindAbilityByName("imba_techies_remote_mines")
	if not ability or not self:GetParent():IsAlive() then
		return
	end
	local caster = self:GetParent():GetOwnerEntity()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	if #enemies > 0 then
		self:GetParent():FindAbilityByName("imba_techies_remote_mines_self_detonate"):OnSpellStart()
	end
end
