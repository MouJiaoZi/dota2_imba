CreateEmptyTalents("rattletrap")

imba_rattletrap_battery_assault = class({})

LinkLuaModifier("modifier_imba_battery_assault", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_battery_assault_passive", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)

function imba_rattletrap_battery_assault:IsHiddenWhenStolen() 		return false end
function imba_rattletrap_battery_assault:IsRefreshable() 			return true end
function imba_rattletrap_battery_assault:IsStealable() 				return true end
function imba_rattletrap_battery_assault:IsNetherWardStealable()	return true end
function imba_rattletrap_battery_assault:GetCastAnimation()			return ACT_DOTA_RATTLETRAP_BATTERYASSAULT end
function imba_rattletrap_battery_assault:GetCastRange()	return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_rattletrap_battery_assault:GetIntrinsicModifierName() return "modifier_imba_battery_assault_passive" end

function imba_rattletrap_battery_assault:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_imba_battery_assault", {duration = (self:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_imba_rattletrap_1"))})
end

modifier_imba_battery_assault = class({})

function modifier_imba_battery_assault:IsDebuff()			return false end
function modifier_imba_battery_assault:IsHidden() 			return false end
function modifier_imba_battery_assault:IsPurgable() 		return false end
function modifier_imba_battery_assault:IsPurgeException() 	return false end
function modifier_imba_battery_assault:GetAttributes()		return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_battery_assault:OnCreated()
	if IsServer() then
		self:GetCaster():EmitSound("Hero_Rattletrap.Battery_Assault")
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("interval") + self:GetCaster():GetTalentValue("special_bonus_imba_rattletrap_2"))
	end
end

function modifier_imba_battery_assault:OnIntervalThink()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Rattletrap.Battery_Assault_Launch")
	local ability = self:GetAbility()
	local attach = "attach_batAss_"..RandomInt(1, 4)
	local pfx_origin = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(pfx_origin, 0, caster, PATTACH_POINT, attach, caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx_origin)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
	for i=1, ability:GetSpecialValueFor("max_targets") do
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_shrapnel.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT, attach, caster:GetAbsOrigin(), true)
		if enemy[i] then
			ParticleManager:SetParticleControlEnt(pfx, 1, enemy[i], PATTACH_POINT, "attach_hitloc", enemy[i]:GetAbsOrigin(), true)
			enemy[i]:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
			ApplyDamage({attacker = caster, victim = enemy[i], ability = ability, damage = ability:GetSpecialValueFor("damage"), damage_type = ability:GetAbilityDamageType()})
			enemy[i]:EmitSound("Hero_Rattletrap.Battery_Assault_Impact")
		else
			ParticleManager:SetParticleControl(pfx, 1, GetRandomPosition2D(caster:GetAbsOrigin() + Vector(0, 0, 50), ability:GetSpecialValueFor("radius")))
		end
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function modifier_imba_battery_assault:OnDestroy()
	if IsServer() then
		self:GetCaster():StopSound("Hero_Rattletrap.Battery_Assault")
	end
end

modifier_imba_battery_assault_passive = class({})

function modifier_imba_battery_assault_passive:IsDebuff()			return false end
function modifier_imba_battery_assault_passive:IsHidden() 			return true end
function modifier_imba_battery_assault_passive:IsPurgable() 		return false end
function modifier_imba_battery_assault_passive:IsPurgeException() 	return false end
function modifier_imba_battery_assault_passive:DestroyOnExpire()	return false end
function modifier_imba_battery_assault_passive:DeclareFunctions()	return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_battery_assault_passive:OnCreated()
	if IsServer() then
		self:SetDuration(0.01, true)
	end
end

function modifier_imba_battery_assault_passive:OnRefresh()
	if IsServer() then
		self:SetDuration(0.01, true)
	end
end

function modifier_imba_battery_assault_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	local caster = self:GetParent()
	local ability = self:GetAbility()
	if keys.unit ~= caster or caster:IsIllusion() or caster:PassivesDisabled() then
		return
	end
	if self:GetRemainingTime() <= 0 then
		if PseudoRandom:RollPseudoRandom(ability, ability:GetSpecialValueFor("passive_chance")) then
			self:SetDuration(ability:GetSpecialValueFor("interval"), true)
			caster:EmitSound("Hero_Rattletrap.Battery_Assault_Launch")
			local attach = "attach_batAss_"..RandomInt(1, 4)
			local pfx_origin = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_assault.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(pfx_origin, 0, caster, PATTACH_POINT, attach, caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx_origin)
			local enemy = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_battery_shrapnel.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT, attach, caster:GetAbsOrigin(), true)
			if enemy[1] then
				ParticleManager:SetParticleControlEnt(pfx, 1, enemy[1], PATTACH_POINT, "attach_hitloc", enemy[1]:GetAbsOrigin(), true)
				enemy[1]:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
				ApplyDamage({attacker = caster, victim = enemy[1], ability = ability, damage = ability:GetSpecialValueFor("damage"), damage_type = ability:GetAbilityDamageType()})
				enemy[1]:EmitSound("Hero_Rattletrap.Battery_Assault_Impact")
			else
				ParticleManager:SetParticleControl(pfx, 1, GetRandomPosition2D(caster:GetAbsOrigin() + Vector(0, 0, 50), ability:GetSpecialValueFor("radius")))
			end
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
end

imba_rattletrap_power_cogs = class({})

LinkLuaModifier("modifier_imba_power_cog", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_power_cog_block", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_power_cog_flying", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_power_cog_knocback", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)

function imba_rattletrap_power_cogs:IsHiddenWhenStolen() 		return false end
function imba_rattletrap_power_cogs:IsRefreshable() 			return true end
function imba_rattletrap_power_cogs:IsStealable() 				return true end
function imba_rattletrap_power_cogs:IsNetherWardStealable()		return true end
function imba_rattletrap_power_cogs:GetCastAnimation()			return ACT_DOTA_RATTLETRAP_POWERCOGS end
function imba_rattletrap_power_cogs:GetCastRange()				return self:GetSpecialValueFor("cogs_radius") - self:GetCaster():GetCastRangeBonus() end

function imba_rattletrap_power_cogs:OnSpellStart()
	--8
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	local direction = caster:GetForwardVector()
	direction.z = 0
	local first = pos + direction * self:GetSpecialValueFor("cogs_radius")
	for i=0, 7 do
		local pos_cog = RotatePosition(pos, QAngle(0, (360 / 8) * i, 0), first)
		pos_cog = GetGroundPosition(pos_cog, nil)
		local cog = CreateUnitByName("npc_dota_rattletrap_cog", pos_cog, false, caster, caster, caster:GetTeamNumber())
		cog:AddNewModifier(caster, self, "modifier_imba_power_cog", {duration = self:GetSpecialValueFor("duration") + 0.1})
		local timer = cog:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration") + 0.1})
		local pfx_cog = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_ambient.vpcf", PATTACH_CUSTOMORIGIN, cog)
		ParticleManager:SetParticleControlEnt(pfx_cog, 0, cog, PATTACH_POINT_FOLLOW, "attach_attack1", cog:GetAbsOrigin(), true)
		timer:AddParticle(pfx_cog, false, false, 15, false, false)
		local block = CreateModifierThinker(cog, self, "modifier_imba_power_cog_block", {duration = self:GetSpecialValueFor("duration")}, pos_cog, caster:GetTeamNumber(), true)
		block:SetHullRadius(80)
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_deploy.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:SetParticleControlForward(pfx, 0, direction)
	ParticleManager:ReleaseParticleIndex(pfx)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("cogs_radius") * 2, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		enemy[i]:AddNewModifier(caster, self, "modifier_phased", {duration = FrameTime() * 2})
	end
end

modifier_imba_power_cog_block = class({})

function modifier_imba_power_cog_block:OnCreated()
	if IsServer() then
		self.center = self:GetCaster():GetOwnerEntity():GetAbsOrigin()
		self:GetCaster():EmitSound("Hero_Rattletrap.Power_Cogs")
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_power_cog_block:OnIntervalThink()
	--DebugDrawCircle(self:GetParent():GetAbsOrigin(), Vector(255,0,0), 100, 100, true, FrameTime() * 2)
	if not self:GetCaster() or not self:GetCaster():IsAlive() then
		self:Destroy()
		return
	end
	local ability = self:GetAbility()
	local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, ability:GetSpecialValueFor("trigger_distance"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		if not enemy[i]:HasModifier("modifier_imba_power_cog_knocback") and (enemy[i]:GetAbsOrigin() - self.center):Length2D() > ability:GetSpecialValueFor("cogs_radius") then
			enemy[i]:EmitSound("Hero_Rattletrap.Power_Cogs_Impact")
			enemy[i]:AddNewModifier(self:GetCaster():GetOwnerEntity(), ability, "modifier_imba_power_cog_knocback", {duration = ability:GetSpecialValueFor("push_duration"), center_x = self.center.x, center_y = self.center.y, center_z = self.center.z, cog = self:GetCaster():entindex()})
		end
	end
end

function modifier_imba_power_cog_block:OnDestroy()
	if IsServer() and self:GetCaster() then
		self.center = nil
		self:GetCaster():StopSound("Hero_Rattletrap.Power_Cogs")
		self:GetCaster():EmitSound("Hero_Rattletrap.Power_Cog.Destroy")
	end
end

function modifier_imba_power_cog_block:IsAura() return true end
function modifier_imba_power_cog_block:GetAuraDuration() return 0.04 end
function modifier_imba_power_cog_block:GetModifierAura() return "modifier_imba_power_cog_flying" end
function modifier_imba_power_cog_block:GetAuraRadius() return 200 end
function modifier_imba_power_cog_block:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_power_cog_block:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_power_cog_block:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

function modifier_imba_power_cog_block:GetAuraEntityReject(unit)
	if self:GetCaster() and unit ~= self:GetCaster():GetOwnerEntity() then
		return true
	end
	return false
end

modifier_imba_power_cog_flying = class({})

function modifier_imba_power_cog_flying:IsDebuff()			return false end
function modifier_imba_power_cog_flying:IsHidden() 			return true end
function modifier_imba_power_cog_flying:IsPurgable() 		return false end
function modifier_imba_power_cog_flying:IsPurgeException() 	return false end
function modifier_imba_power_cog_flying:CheckState() return {[MODIFIER_STATE_FLYING] = true} end
function modifier_imba_power_cog_flying:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_power_cog_flying:GetModifierPhysicalArmorBonus()
	if self:GetCaster() then
		return (self:GetCaster():GetPlayerOwnerID() == self:GetParent():GetPlayerOwnerID() and self:GetAbility():GetSpecialValueFor("bonus_armor") or 0)
	end
end

function modifier_imba_power_cog_flying:OnDestroy()
	if IsServer() then
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 180, false)
	end
end

modifier_imba_power_cog_knocback = class({})

function modifier_imba_power_cog_knocback:IsDebuff()			return true end
function modifier_imba_power_cog_knocback:IsHidden() 			return false end
function modifier_imba_power_cog_knocback:IsPurgable() 			return false end
function modifier_imba_power_cog_knocback:IsPurgeException() 	return false end
function modifier_imba_power_cog_knocback:IsStunDebuff()		return true end
function modifier_imba_power_cog_knocback:IsMotionController()	return true end
function modifier_imba_power_cog_knocback:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_power_cog_knocback:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_power_cog_knocback:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_power_cog_knocback:GetOverrideAnimation() return ACT_DOTA_FLAIL end

function modifier_imba_power_cog_knocback:OnCreated(keys)
	if IsServer() and self:CheckMotionControllers() then
		self.pos = Vector(keys.center_x, keys.center_y, keys.center_z)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_cog_attack.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, EntIndexToHScript(keys.cog), PATTACH_POINT_FOLLOW, "attach_attack1", EntIndexToHScript(keys.cog):GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_power_cog_knocback:OnIntervalThink()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local distance = ability:GetSpecialValueFor("push_length") / (ability:GetSpecialValueFor("push_duration") / FrameTime())
	local direction = (parent:GetAbsOrigin() - self.pos):Normalized()
	direction.z = 0
	parent:SetAbsOrigin(parent:GetAbsOrigin() + direction * distance)
end

function modifier_imba_power_cog_knocback:OnDestroy()
	if IsServer() then
		self.pos = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), 180, false)
		ApplyDamage({attacker = self:GetCaster(), victim = self:GetParent(), damage = self:GetAbility():GetSpecialValueFor("damage"), ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType()})
		self:GetParent():SetMana(math.max(0, self:GetParent():GetMana() - self:GetAbility():GetSpecialValueFor("mana_burn")))
	end
end

modifier_imba_power_cog = class({})

function modifier_imba_power_cog:IsDebuff()				return false end
function modifier_imba_power_cog:IsHidden() 			return true end
function modifier_imba_power_cog:IsPurgable() 			return false end
function modifier_imba_power_cog:IsPurgeException() 	return false end
function modifier_imba_power_cog:CheckState() return {[MODIFIER_STATE_SPECIALLY_DENIABLE] = true} end
function modifier_imba_power_cog:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_power_cog:GetModifierIncomingDamage_Percentage() return -1000 end

function modifier_imba_power_cog:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("attacks_to_destroy"))
	end
end

function modifier_imba_power_cog:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.target == self:GetParent() and keys.attacker:IsHero() then
		self:SetStackCount(self:GetStackCount() - 1)
		if self:GetStackCount() <= 0 or keys.attacker == self:GetCaster() then
			self:GetParent():Kill(self:GetAbility(), keys.attacker)
			self:Destroy()
		end
	end
end

imba_rattletrap_rocket_flare = class({})

LinkLuaModifier("modifier_imba_rocket_flare_vision", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)

function imba_rattletrap_rocket_flare:IsHiddenWhenStolen() 		return false end
function imba_rattletrap_rocket_flare:IsRefreshable() 			return true end
function imba_rattletrap_rocket_flare:IsStealable() 			return true end
function imba_rattletrap_rocket_flare:IsNetherWardStealable()	return true end
function imba_rattletrap_rocket_flare:GetAOERadius()			return self:GetSpecialValueFor("radius") end

function imba_rattletrap_rocket_flare:OnSpellStart()
	local caster = self:GetCaster()
	local target_pos = self:GetCursorPosition()
	for i=1, (caster:GetTalentValue("special_bonus_imba_rattletrap_4") + 1) do
		local pos = GetRandomPosition2D(target_pos, self:GetSpecialValueFor("radius"))
		if i == 1 then
			pos = target_pos
		end
		local direction = (pos - caster:GetAbsOrigin()):Normalized()
		direction.z = 0
		local target = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 60}, pos, caster:GetTeamNumber(), false)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_rocket")))
		ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0))
		ParticleManager:SetParticleControlEnt(pfx, 7, caster, PATTACH_INVALID, nil, caster:GetAbsOrigin(), true)
		local rocket = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 60.0}, pos, caster:GetTeamNumber(), false)
		local info = 
		{
			Target = target,
			Source = caster,
			Ability = self,	
			EffectName = nil,
			iMoveSpeed = self:GetSpecialValueFor("speed"),
			vSourceLoc = caster:GetAttachmentOrigin(caster:ScriptLookupAttachment("attach_rocket")),
			bDrawsOnMinimap = false,
			bDodgeable = false,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			flExpireTime = GameRules:GetGameTime() + 60,
			bProvidesVision = false,
			ExtraData = {pfx = pfx, rocket = rocket:entindex()}
		}
		ProjectileManager:CreateTrackingProjectile(info)
		caster:EmitSound("Hero_Rattletrap.Rocket_Flare.Fire")
		rocket:EmitSound("Hero_Rattletrap.Rocket_Flare.Travel")
	end
end

function imba_rattletrap_rocket_flare:OnProjectileThink_ExtraData(pos, keys)
	local caster = self:GetCaster()
	local rocket = EntIndexToHScript(keys.rocket)
	rocket:SetAbsOrigin(pos)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), pos, self:GetSpecialValueFor("radius"), FrameTime(), false)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		enemy[i]:AddNewModifier(caster, self, "modifier_imba_rocket_flare_vision", {duration = (self:GetSpecialValueFor("lock_duration") + caster:GetTalentValue("special_bonus_imba_rattletrap_3"))})
	end
end

function imba_rattletrap_rocket_flare:OnProjectileHit_ExtraData(target, pos, keys)
	local caster = self:GetCaster()
	ParticleManager:DestroyParticle(keys.pfx, false)
	ParticleManager:ReleaseParticleIndex(keys.pfx)
	local rocket = EntIndexToHScript(keys.rocket)
	rocket:StopSound("Hero_Rattletrap.Rocket_Flare.Travel")
	rocket:EmitSound("Hero_Rattletrap.Rocket_Flare.Explode")
	rocket:ForceKill(false)
	local pfx_name = "particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_illumination.vpcf"
	if HeroItems:UnitHasItem(caster, "paraflare_cannon") then
		pfx_name = "particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_illumination.vpcf"
	end
	local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("duration") + caster:GetTalentValue("special_bonus_imba_rattletrap_3"), 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
	AddFOWViewer(caster:GetTeamNumber(), pos, self:GetSpecialValueFor("radius"), self:GetSpecialValueFor("duration"), false)
	local truesight = CreateUnitByName("npc_dummy_unit", pos, false, caster, caster, caster:GetTeamNumber())
	truesight:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("truesight_duration") + caster:GetTalentValue("special_bonus_imba_rattletrap_3")})
	truesight:AddNewModifier(caster, self, "modifier_item_gem_of_true_sight", {duration = self:GetSpecialValueFor("truesight_duration") + caster:GetTalentValue("special_bonus_imba_rattletrap_3")})
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		ApplyDamage({attacker = caster, victim = enemy[i], damage = self:GetSpecialValueFor("damage"), ability = self, damage_type = self:GetAbilityDamageType()})
	end
end

modifier_imba_rocket_flare_vision = class({})

function modifier_imba_rocket_flare_vision:IsDebuff()			return true end
function modifier_imba_rocket_flare_vision:IsHidden() 			return false end
function modifier_imba_rocket_flare_vision:IsPurgable() 		return true end
function modifier_imba_rocket_flare_vision:IsPurgeException() 	return true end
function modifier_imba_rocket_flare_vision:CheckState() return {[MODIFIER_STATE_PROVIDES_VISION] = true} end

function modifier_imba_rocket_flare_vision:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_rocket_flare_sparks.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

imba_rattletrap_hookshot = class({})

LinkLuaModifier("modifier_imba_hookshot_hookcheck", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hookshot_motion", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_hookshot_stunned", "hero/hero_rattletrap.lua", LUA_MODIFIER_MOTION_NONE)

function imba_rattletrap_hookshot:IsHiddenWhenStolen() 		return false end
function imba_rattletrap_hookshot:IsRefreshable() 			return true end
function imba_rattletrap_hookshot:IsStealable() 			return true end
function imba_rattletrap_hookshot:IsNetherWardStealable()	return true end
function imba_rattletrap_hookshot:GetCastRange()			return self:GetCaster():HasScepter() and self:GetSpecialValueFor("range_scepter") or self:GetSpecialValueFor("range") end
function imba_rattletrap_hookshot:GetCooldown()				return self:GetCaster():HasScepter() and self:GetSpecialValueFor("cooldown_scepter") or self.BaseClass.GetCooldown(self, -1) end
function imba_rattletrap_hookshot:GetCastAnimation() return ACT_DOTA_RATTLETRAP_HOOKSHOT_START end
function imba_rattletrap_hookshot:GetAssociatedSecondaryAbilities() return "imba_rattletrap_hookshot_stop" end
function imba_rattletrap_hookshot:OnUpgrade()
	if IsServer() then
		if self:GetCaster():HasAbility("imba_rattletrap_hookshot_stop") then
			self:GetCaster():FindAbilityByName("imba_rattletrap_hookshot_stop"):SetLevel(1)
		end
	end
end

function imba_rattletrap_hookshot:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0
	local distance = self:GetSpecialValueFor("max_range") + caster:GetCastRangeBonus()
	local max_time = (distance / self:GetSpecialValueFor("speed")) * 3
	caster:EmitSound("Hero_Rattletrap.Hookshot.Fire")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin() + direction * (self:GetSpecialValueFor("max_range") + caster:GetCastRangeBonus()))
	ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("speed"), 0, 0))
	ParticleManager:SetParticleControl(pfx, 3, Vector(max_time, 0, 0))
	ParticleManager:SetParticleControlEnt(pfx, 7, caster, PATTACH_INVALID, nil, caster:GetAbsOrigin(), true)
	local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = max_time * 1.5}, pos, caster:GetTeamNumber(), false)
	--sound:EmitSound("Hero_Rattletrap.Hookshot.Retract")
	local info = 
	{
		Ability = self,
		EffectName = nil,
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = distance,
		fStartRadius = self:GetSpecialValueFor("latch_radius"),
		fEndRadius = self:GetSpecialValueFor("latch_radius"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction * self:GetSpecialValueFor("speed"),
		bProvidesVision = false,
		ExtraData = {pfx = pfx, sound = sound:entindex()}
	}
	ProjectileManager:CreateLinearProjectile(info)
	caster:AddNewModifier(caster, self, "modifier_imba_hookshot_hookcheck", {})
	local weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
	if weapon_hook ~= nil then
		weapon_hook:AddEffects(EF_NODRAW)
	end
end

function imba_rattletrap_hookshot:OnProjectileThink_ExtraData(pos, keys)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), pos, self:GetSpecialValueFor("latch_radius"), FrameTime(), false)
	local sound = EntIndexToHScript(keys.sound)
	sound:SetAbsOrigin(pos)
end

function imba_rattletrap_hookshot:OnProjectileHit_ExtraData(target, pos, keys)
	if target and (target == self:GetCaster() or target:IsCourier()) then
		return false
	end
	local caster = self:GetCaster()
	local sound = EntIndexToHScript(keys.sound)
	sound:ForceKill(false)
	if target and caster:IsAlive() and not caster:HasModifier("modifier_imba_hookshot_motion") then
		target:EmitSound("Hero_Rattletrap.Hookshot.Impact")
		ParticleManager:SetParticleControlEnt(keys.pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		if IsEnemy(caster, target) then
			target:AddNewModifier(caster, self, "modifier_imba_hookshot_stunned", {})
		end
		caster:AddNewModifier(caster, self, "modifier_imba_hookshot_motion", {pfx = keys.pfx, target = target:entindex(), thinker = 0})
		return true
	else
		ParticleManager:SetParticleControlEnt(keys.pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
		local thinker = CreateModifierThinker(caster, self, "modifier_imba_hookshot_motion", {pfx = keys.pfx, target = caster:entindex(), thinker = 1}, pos, caster:GetTeamNumber(), false)
		--ParticleManager:DestroyParticle(keys.pfx, false)
		--ParticleManager:ReleaseParticleIndex(keys.pfx)
		return true
	end
end

modifier_imba_hookshot_hookcheck = class({})

function modifier_imba_hookshot_hookcheck:IsDebuff()			return false end
function modifier_imba_hookshot_hookcheck:IsHidden() 			return true end
function modifier_imba_hookshot_hookcheck:IsPurgable() 			return false end
function modifier_imba_hookshot_hookcheck:IsPurgeException() 	return false end
function modifier_imba_hookshot_hookcheck:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_imba_hookshot_stunned = class({})

function modifier_imba_hookshot_stunned:IsDebuff()			return true end
function modifier_imba_hookshot_stunned:IsHidden() 			return true end
function modifier_imba_hookshot_stunned:IsPurgable() 		return false end
function modifier_imba_hookshot_stunned:IsPurgeException() 	return false end
function modifier_imba_hookshot_stunned:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_hookshot_stunned:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

modifier_imba_hookshot_motion = class({})

function modifier_imba_hookshot_motion:IsDebuff()			return false end
function modifier_imba_hookshot_motion:IsHidden() 			return true end
function modifier_imba_hookshot_motion:IsPurgable() 		return false end
function modifier_imba_hookshot_motion:IsPurgeException() 	return false end
function modifier_imba_hookshot_motion:RemoveOnDeath()		return false end
function modifier_imba_hookshot_motion:IsStunDebuff()		return true end
function modifier_imba_hookshot_motion:IsMotionController()	return true end
function modifier_imba_hookshot_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_hookshot_motion:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_hookshot_motion:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_hookshot_motion:GetOverrideAnimation() return ACT_DOTA_RATTLETRAP_HOOKSHOT_LOOP end

function modifier_imba_hookshot_motion:OnCreated(keys)
	if IsServer() and self:CheckMotionControllers() then
		self.pfx = keys.pfx
		self.hitted = {}
		self.target = EntIndexToHScript(keys.target)
		if keys.thinker == 1 then
			self:SetStackCount(1)
		end
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_hookshot_motion:OnIntervalThink()
	local caster = self:GetParent()
	if (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() <= caster:GetHullRadius() and self:GetStackCount() ~= 1 then
		self:SetStackCount(2)
		self:Destroy()
		return
	end
	local ability = self:GetAbility()
	local direction = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
	if self:GetStackCount() ~= 1 then
		local enemy = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("stun_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for i=1, #enemy do
			if not IsInTable(enemy[i], self.hitted) then
				self.hitted[#self.hitted + 1] = enemy[i]
				enemy[i]:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = ability:GetSpecialValueFor("duration")})
				ApplyDamage({attacker = caster, victim = enemy[i], damage = ability:GetSpecialValueFor("damage"), ability = ability, damage_type = ability:GetAbilityDamageType()})
			end
		end
	end
	direction.z = 0
	caster:SetForwardVector(direction)
	local distance = ability:GetSpecialValueFor("speed") / (1.0 / FrameTime())
	if (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D() < distance then
		distance = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()
	end
	local pos = GetGroundPosition(caster:GetAbsOrigin() + direction * distance, nil)
	caster:SetAbsOrigin(pos)
end

function modifier_imba_hookshot_motion:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		local buff = self.target:FindModifierByNameAndCaster("modifier_imba_hookshot_stunned", caster)
		if buff then
			buff:Destroy()
		end
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if self:GetStackCount() == 2 then
			self.target:EmitSound("Hero_Rattletrap.Hookshot.Damage")
			local enemy = FindUnitsInRadius(caster:GetTeamNumber(), self.target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("stun_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			for i=1, #enemy do
				if not IsInTable(enemy[i], self.hitted) then
					self.hitted[#self.hitted + 1] = enemy[i]
					enemy[i]:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = ability:GetSpecialValueFor("duration")})
					ApplyDamage({attacker = caster, victim = enemy[i], damage = ability:GetSpecialValueFor("damage"), ability = ability, damage_type = ability:GetAbilityDamageType()})
				end
			end
		end
		self.target = nil
		self.pfx = nil
		self.hitted = nil
		caster:RemoveModifierByName("modifier_imba_hookshot_hookcheck")
		local weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if not caster:HasModifier("modifier_imba_hookshot_hookcheck") and weapon_hook ~= nil then
			weapon_hook:RemoveEffects(EF_NODRAW)
		end
	end
end

imba_rattletrap_hookshot_stop = class({})

function imba_rattletrap_hookshot_stop:IsHiddenWhenStolen() 	return false end
function imba_rattletrap_hookshot_stop:IsRefreshable() 			return true end
function imba_rattletrap_hookshot_stop:IsStealable() 			return false end
function imba_rattletrap_hookshot_stop:IsNetherWardStealable()	return false end
function imba_rattletrap_hookshot_stop:ProcsMagicStick()		return false end

function imba_rattletrap_hookshot_stop:CastFilterResult()
	if not self:GetCaster():HasModifier("modifier_imba_hookshot_motion") then
		return UF_FAIL_CUSTOM
	end
end

function imba_rattletrap_hookshot_stop:GetCustomCastError()
	if not self:GetCaster():HasModifier("modifier_imba_hookshot_motion") then
		return "#dota_hud_error_ability_inactive"
	end
end

function imba_rattletrap_hookshot_stop:OnSpellStart()
	local caster = self:GetCaster()
	caster:RemoveModifierByName("modifier_imba_hookshot_motion")
end