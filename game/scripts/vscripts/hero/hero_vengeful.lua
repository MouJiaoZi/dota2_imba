

CreateEmptyTalents("vengeful")

imba_vengeful_magic_missile = class({})

function imba_vengeful_magic_missile:IsHiddenWhenStolen() 		return false end
function imba_vengeful_magic_missile:IsRefreshable() 			return true end
function imba_vengeful_magic_missile:IsStealable() 				return true end
function imba_vengeful_magic_missile:IsNetherWardStealable()	return true end
function imba_vengeful_magic_missile:GetAOERadius() return self:GetSpecialValueFor("rancor_radius") end

function imba_vengeful_magic_missile:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_VengefulSpirit.MagicMissile")
	local target = self:GetCursorTarget()
	local pfxName = target:HasModifier("modifier_imba_rancor") and "particles/hero/vengeful/rancor_magic_missile.vpcf" or "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf"
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = pfxName,
		iMoveSpeed = self:GetSpecialValueFor("speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		bDrawsOnMinimap = false,
		bDodgeable = target:HasModifier("modifier_imba_rancor"),
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		ExtraData = {main = 1}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_vengeful_magic_missile:OnProjectileHit_ExtraData(target, location, keys)
	if not target or target:IsMagicImmune() then
		return
	end
	if keys.main == 1 then
		if target:TriggerStandardTargetSpell(self) then
			return
		end
	end 
	target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
	local dmg = self:GetSpecialValueFor("base_damage") + target:GetModifierStackCount("modifier_imba_rancor", self:GetCaster()) * self:GetSpecialValueFor("rancor_damage")
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self})
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
	if keys.main == 1 then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), location, nil, self:GetSpecialValueFor("rancor_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy ~= target and enemy:HasModifier("modifier_imba_rancor") then
				local info = 
				{
					Target = enemy,
					Source = target,
					Ability = self,	
					EffectName = "particles/hero/vengeful/rancor_magic_missile.vpcf",
					iMoveSpeed = self:GetSpecialValueFor("speed"),
					vSourceLoc = target:GetAbsOrigin(),
					bDrawsOnMinimap = false,
					bDodgeable = false,
					bIsAttack = false,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					flExpireTime = GameRules:GetGameTime() + 10,
					bProvidesVision = false,
					ExtraData = {main = 0}
				}
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end
	end
end

imba_vengeful_wave_of_terror = class({})

LinkLuaModifier("modifier_imba_wave_of_terror_armor", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)

function imba_vengeful_wave_of_terror:IsHiddenWhenStolen() 		return false end
function imba_vengeful_wave_of_terror:IsRefreshable() 			return true end
function imba_vengeful_wave_of_terror:IsStealable() 			return true end
function imba_vengeful_wave_of_terror:IsNetherWardStealable()	return true end
function imba_vengeful_wave_of_terror:GetCastRange() return self:GetSpecialValueFor("length") end

function imba_vengeful_wave_of_terror:OnSpellStart()
	local caster = self:GetCaster()
	local direction = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
	local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 3.0}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false):entindex()
	EntIndexToHScript(sound):EmitSound("Hero_VengefulSpirit.WaveOfTerror")
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror.vpcf",
		vSpawnOrigin = caster:GetAbsOrigin(),
		fDistance = self:GetSpecialValueFor("length") + caster:GetCastRangeBonus(),
		fStartRadius = self:GetSpecialValueFor("width"),
		fEndRadius = self:GetSpecialValueFor("width"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction * self:GetSpecialValueFor("speed"),
		bProvidesVision = false,
		ExtraData = {thinker = sound}
	}
	ProjectileManager:CreateLinearProjectile(info)
end

function imba_vengeful_wave_of_terror:OnProjectileThink_ExtraData(location, keys)
	if EntIndexToHScript(keys.thinker) then
		EntIndexToHScript(keys.thinker):SetAbsOrigin(location)
	end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("width"), self:GetSpecialValueFor("vision_duration"), false)
end

function imba_vengeful_wave_of_terror:OnProjectileHit(target, location)
	if target then
		ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self})
		target:AddNewModifier(self:GetCaster(), self, "modifier_imba_wave_of_terror_armor", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_imba_wave_of_terror_armor = class({})

function modifier_imba_wave_of_terror_armor:IsDebuff()			return true end
function modifier_imba_wave_of_terror_armor:IsHidden() 			return false end
function modifier_imba_wave_of_terror_armor:IsPurgable() 		return true end
function modifier_imba_wave_of_terror_armor:IsPurgeException() 	return true end
function modifier_imba_wave_of_terror_armor:GetEffectName() return "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf" end
function modifier_imba_wave_of_terror_armor:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_wave_of_terror_armor:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_wave_of_terror_armor:GetModifierPhysicalArmorBonus() return (0 - self:GetAbility():GetSpecialValueFor("armor") - self:GetParent():GetModifierStackCount("modifier_imba_rancor", self:GetCaster())) end

imba_vengeful_command_aura = class({})

LinkLuaModifier("modifier_imba_command_aura_caster", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_command_aura_positive", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_command_aura_killer", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_command_aura_negative", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)

function imba_vengeful_command_aura:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_vengeful_command_aura:GetIntrinsicModifierName() return "modifier_imba_command_aura_caster" end

modifier_imba_command_aura_caster = class({})

function modifier_imba_command_aura_caster:IsDebuff()			return false end
function modifier_imba_command_aura_caster:IsHidden() 			return true end
function modifier_imba_command_aura_caster:IsPurgable() 		return false end
function modifier_imba_command_aura_caster:IsPurgeException() 	return false end
function modifier_imba_command_aura_caster:IsAura() return true end
function modifier_imba_command_aura_caster:GetAuraDuration() return 0.5 end
function modifier_imba_command_aura_caster:GetModifierAura() return "modifier_imba_command_aura_positive" end
function modifier_imba_command_aura_caster:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_command_aura_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_command_aura_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_command_aura_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_command_aura_caster:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end

function modifier_imba_command_aura_caster:OnDeath(keys)
	if not IsServer() or self:GetParent():IsIllusion() then
		return
	end
	if keys.unit == self:GetParent() and IsEnemy(keys.attacker, self:GetParent()) then
		keys.attacker:AddNewModifier(keys.attacker, self:GetAbility(), "modifier_imba_command_aura_killer", {duration = self:GetParent():GetIMBARespawnTime()})
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_negative_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, keys.attacker, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", keys.attacker:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function modifier_imba_command_aura_caster:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_command_aura_caster:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
	local stack = 0
	for _, enemy in pairs(enemies) do
		stack = stack + enemy:GetModifierStackCount("modifier_imba_rancor", self:GetCaster())
	end
	self:SetStackCount(stack)
end

modifier_imba_command_aura_positive = class({})

function modifier_imba_command_aura_positive:IsDebuff()			return false end
function modifier_imba_command_aura_positive:IsHidden() 		return false end
function modifier_imba_command_aura_positive:IsPurgable() 		return false end
function modifier_imba_command_aura_positive:IsPurgeException() return false end
function modifier_imba_command_aura_positive:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_command_aura_positive:GetModifierBaseDamageOutgoing_Percentage() return (self:GetAbility():GetSpecialValueFor("damage_bonus") + self:GetAbility():GetSpecialValueFor("rancor_damage_bonus") * self:GetCaster():GetModifierStackCount("modifier_imba_command_aura_caster", self:GetCaster())) end

modifier_imba_command_aura_killer = class({})

function modifier_imba_command_aura_killer:IsDebuff()			return false end
function modifier_imba_command_aura_killer:IsHidden() 			return true end
function modifier_imba_command_aura_killer:IsPurgable() 		return false end
function modifier_imba_command_aura_killer:IsPurgeException() 	return false end
function modifier_imba_command_aura_killer:IsAura() return true end
function modifier_imba_command_aura_killer:GetAuraDuration() return 0.5 end
function modifier_imba_command_aura_killer:GetModifierAura() return "modifier_imba_command_aura_negative" end
function modifier_imba_command_aura_killer:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_command_aura_killer:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_command_aura_killer:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_command_aura_killer:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_command_aura_negative = class({})

function modifier_imba_command_aura_negative:IsDebuff()			return true end
function modifier_imba_command_aura_negative:IsHidden() 		return false end
function modifier_imba_command_aura_negative:IsPurgable() 		return false end
function modifier_imba_command_aura_negative:IsPurgeException() return false end
function modifier_imba_command_aura_negative:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_command_aura_negative:GetModifierBaseDamageOutgoing_Percentage() return ( 0 - self:GetAbility():GetSpecialValueFor("damage_bonus")) end

imba_vengeful_rancor = class({})

LinkLuaModifier("modifier_imba_rancor", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rancor_passive", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)

function imba_vengeful_rancor:IsTalentAbility() return true end
function imba_vengeful_rancor:GetIntrinsicModifierName() return "modifier_imba_rancor_passive" end

modifier_imba_rancor = class({})

function modifier_imba_rancor:IsDebuff()			return true end
function modifier_imba_rancor:IsHidden() 			return false end
function modifier_imba_rancor:IsPurgable() 			return false end
function modifier_imba_rancor:IsPurgeException() 	return false end
function modifier_imba_rancor:RemoveOnDeath() 		return false end

modifier_imba_rancor_passive = class({})

function modifier_imba_rancor_passive:IsDebuff()			return false end
function modifier_imba_rancor_passive:IsHidden() 			return true end
function modifier_imba_rancor_passive:IsPurgable() 			return false end
function modifier_imba_rancor_passive:IsPurgeException() 	return false end
function modifier_imba_rancor_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_rancor_passive:OnDeath(keys)
	if not IsServer() or self:GetParent():IsIllusion() then
		return
	end
	local caster = self:GetCaster()
	local attacker = keys.attacker
	local unit = keys.unit
	if IsEnemy(caster, attacker) and not IsEnemy(caster, unit) and attacker:IsRealHero() and not attacker:IsTempestDouble() and unit:IsRealHero() and not unit:IsTempestDouble() then
		if attacker:IsClone() then
			attacker = attacker:GetCloneSource()
		end
		local stacks = caster == unit and 2 or 1
		local buff = attacker:AddNewModifier(caster, self:GetAbility(), "modifier_imba_rancor", {})
		buff:SetStackCount(buff:GetStackCount() + stacks)
	end
	if IsEnemy(caster, unit) and unit:HasModifier("modifier_imba_rancor") then
		local buff = unit:FindModifierByName("modifier_imba_rancor")
		buff:SetStackCount(math.max(buff:GetStackCount() - (math.floor(buff:GetStackCount() / 2) + 1), 0))
		if buff:GetStackCount() == 0 then
			buff:Destroy()
		end
	end
end

imba_vengeful_swap_back = class({})

function imba_vengeful_swap_back:IsHiddenWhenStolen() 		return false end
function imba_vengeful_swap_back:IsRefreshable() 			return true end
function imba_vengeful_swap_back:IsStealable() 				return false end
function imba_vengeful_swap_back:IsNetherWardStealable()	return false end
function imba_vengeful_swap_back:GetAssociatedPrimaryAbilities() return "imba_vengeful_nether_swap" end

function imba_vengeful_swap_back:CastFilterResult()
	if self:GetCaster():HasModifier("modifier_imba_nether_swap_disable") or not self:GetCaster():HasModifier("modifier_imba_nether_swap_enable") then
		return UF_FAIL_CUSTOM
	end
end

function imba_vengeful_swap_back:GetCustomCastError()
	if self:GetCaster():HasModifier("modifier_imba_nether_swap_disable") or not self:GetCaster():HasModifier("modifier_imba_nether_swap_enable") then
		return "#dota_hud_error_ability_inactive"
	end
end

function imba_vengeful_swap_back:OnSpellStart()
	local caster = self:GetCaster()
	local target = CreateModifierThinker(caster, self, "modifier_imba_nether_swap_disable", {duration = 3.0}, self.pos, caster:GetTeamNumber(), false)
	local caster_loc = caster:GetAbsOrigin()
	local target_loc = target:GetAbsOrigin()
	caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
	target:EmitSound("Hero_VengefulSpirit.NetherSwap")
	local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx1, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx1, 1, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx1)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(pfx2, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx2, 1, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx2)
	FindClearSpaceForUnit(caster, target_loc, true)
	FindClearSpaceForUnit(target, caster_loc, true)
end


imba_vengeful_nether_swap = class({})

LinkLuaModifier("modifier_imba_nether_swap_disable", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_nether_swap_enable", "hero/hero_vengeful", LUA_MODIFIER_MOTION_NONE)

function imba_vengeful_nether_swap:IsHiddenWhenStolen() 	return false end
function imba_vengeful_nether_swap:IsRefreshable() 			return true end
function imba_vengeful_nether_swap:IsStealable() 			return true end
function imba_vengeful_nether_swap:IsNetherWardStealable()	return false end
function imba_vengeful_nether_swap:GetCastRange() return self:GetSpecialValueFor("range") end
function imba_vengeful_nether_swap:GetCooldown(i) return self:GetCaster():HasScepter() and self:GetSpecialValueFor("cooldown_scepter") or self:GetSpecialValueFor("cooldown") end
function imba_vengeful_nether_swap:GetAssociatedSecondaryAbilities() return "imba_vengeful_swap_back" end
function imba_vengeful_nether_swap:OnUpgrade()
	local ability = self:GetCaster():FindAbilityByName("imba_vengeful_swap_back")
	if ability then
		ability:SetLevel(1)
	end
end

function imba_vengeful_nether_swap:CastFilterResultTarget(target)
	if target == self:GetCaster() or not target:IsHero() then
		return UF_FAIL_CUSTOM
	else
		return UF_SUCCESS
	end
end

function imba_vengeful_nether_swap:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	elseif not target:IsHero() then
		return "dota_hud_error_cant_cast_on_other"
	end
end

function imba_vengeful_nether_swap:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local caster_loc = caster:GetAbsOrigin()
	local target_loc = target:GetAbsOrigin()
	local pos = {}
	table.insert(pos, caster_loc)
	table.insert(pos, target_loc)
	caster:EmitSound("Hero_VengefulSpirit.NetherSwap")
	target:EmitSound("Hero_VengefulSpirit.NetherSwap")
	target:Interrupt()
	local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx1, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx1, 1, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx1)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_nether_swap_target.vpcf", PATTACH_CUSTOMORIGIN, target)
	ParticleManager:SetParticleControlEnt(pfx2, 0, target, PATTACH_POINT, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx2, 1, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx2)
	FindClearSpaceForUnit(caster, target_loc, true)
	FindClearSpaceForUnit(target, caster_loc, true)
	GridNav:DestroyTreesAroundPoint(target_loc, 300, true)
	GridNav:DestroyTreesAroundPoint(caster_loc, 300, true)
	local ability = caster:FindAbilityByName("imba_vengeful_swap_back")
	if ability then
		ability.pos = caster_loc
	end
	if not caster:HasModifier("modifier_imba_nether_swap_enable") then
		caster:AddNewModifier(caster, self, "modifier_imba_nether_swap_disable", {duration = self:GetSpecialValueFor("swapback_min_time")})
	end
	caster:AddNewModifier(caster, self, "modifier_imba_nether_swap_enable", {duration = self:GetSpecialValueFor("swapback_max_time")})

	for _, loc in pairs(pos) do
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), loc, nil, self:GetSpecialValueFor("rancor_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local dummy = CreateModifierThinker(caster, self, "modifier_imba_nether_swap_disable", {duration = 3.0}, loc, caster:GetTeamNumber(), false)
		if #enemies > 0 then
			dummy:EmitSound("Hero_VengefulSpirit.MagicMissile")
		end
		for _, enemy in pairs(enemies) do
			if enemy:HasModifier("modifier_imba_rancor") then
				local info = 
				{
					Target = enemy,
					Source = dummy,
					Ability = self,	
					EffectName = "particles/hero/vengeful/rancor_magic_missile.vpcf",
					iMoveSpeed = self:GetSpecialValueFor("rancor_speed"),
					vSourceLoc = loc,
					bDrawsOnMinimap = false,
					bDodgeable = false,
					bIsAttack = false,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					flExpireTime = GameRules:GetGameTime() + 10,
					bProvidesVision = false,
				}
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end
	end
end

function imba_vengeful_nether_swap:OnProjectileHit(target, location)
	if not target then
		return
	end
	target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("rancor_stun")})
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = self:GetSpecialValueFor("rancor_damage"), damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self})
end

modifier_imba_nether_swap_disable = class({})

function modifier_imba_nether_swap_disable:IsDebuff()			return false end
function modifier_imba_nether_swap_disable:IsHidden() 			return true end
function modifier_imba_nether_swap_disable:IsPurgable() 		return false end
function modifier_imba_nether_swap_disable:IsPurgeException() 	return false end

modifier_imba_nether_swap_enable = class({})

function modifier_imba_nether_swap_enable:IsDebuff()			return false end
function modifier_imba_nether_swap_enable:IsHidden() 			return true end
function modifier_imba_nether_swap_enable:IsPurgable() 			return false end
function modifier_imba_nether_swap_enable:IsPurgeException() 	return false end

