


CreateEmptyTalents("troll_warlord")



imba_troll_warlord_whirling_axes_melee = class({})

LinkLuaModifier("modifier_imba_whirling_axes_melee_debuff_dummy", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

function imba_troll_warlord_whirling_axes_melee:IsHiddenWhenStolen() 		return false end
function imba_troll_warlord_whirling_axes_melee:IsRefreshable() 			return true end
function imba_troll_warlord_whirling_axes_melee:IsStealable() 				return true end
function imba_troll_warlord_whirling_axes_melee:IsNetherWardStealable()		return true end
function imba_troll_warlord_whirling_axes_melee:GetCastRange()	return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_troll_warlord_whirling_axes_melee:OnSpellStart()
	local caster = self:GetCaster() 
	StartAnimation(caster, {duration=5, activity=ACT_DOTA_CAST_ABILITY_3, rate=1.5, translate="melee"})
	caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Melee")
	local particle_axe = "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_melee.vpcf"
	local damage = self:GetSpecialValueFor("damage")
	local damage_tick = self:GetSpecialValueFor("damage_tick")
	local damage_duration = self:GetSpecialValueFor("damage_duration")
	local radius = self:GetSpecialValueFor("radius")
	local elapsed_duration = 0
	local enemies_hit = {}
	Timers:CreateTimer(0, function()

		-- Update caster location and facing
		local caster_pos = caster:GetAbsOrigin()
		local caster_direction = caster:GetForwardVector()

		-- Create axe particles
		for i = 1,5 do
			local axe_target_point = RotatePosition(caster_pos, QAngle(0, i * 72 - 72 * elapsed_duration, 0), caster_pos + caster_direction * (radius-175))
			local axe_pfx = ParticleManager:CreateParticle(particle_axe, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(axe_pfx, 0, caster_pos + Vector(0, 0, 100))
			ParticleManager:SetParticleControl(axe_pfx, 1, axe_target_point + Vector(0, 0, 100))
			ParticleManager:SetParticleControl(axe_pfx, 4, Vector(0.65, 0, 0))	
			Timers:CreateTimer(0.4, function()
				ParticleManager:SetParticleControl(axe_pfx, 1, caster:GetAbsOrigin() + Vector(0, 0, 100))
				ParticleManager:ReleaseParticleIndex(axe_pfx)
			end)		
		end
		
		-- Iterate through affected enemies
		local nearby_enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster_pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _,enemy in pairs(nearby_enemies) do

			-- If this enemy is being hit for the first time, damage it
			if not enemies_hit[enemy:entindex()] then
				enemies_hit[enemy:entindex()] = true
				ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = self:GetAbilityDamageType()})
			end

			local buff = enemy:AddNewModifier(caster, self, "modifier_imba_whirling_axes_melee_debuff_dummy", {duration = self:GetSpecialValueFor("blind_duration")})
			buff:SetStackCount(buff:GetStackCount() + 1)

			-- Play hit sound
			enemy:EmitSound("Hero_TrollWarlord.WhirlingAxes.Target")

		end

		-- If the duration is over, end
		if elapsed_duration < damage_duration then

			-- Add a tick to the elapsed duration
			elapsed_duration = elapsed_duration + damage_tick
			return damage_tick
		end
	end)
end

modifier_imba_whirling_axes_melee_debuff_dummy = class({})

function modifier_imba_whirling_axes_melee_debuff_dummy:IsDebuff()			return true end
function modifier_imba_whirling_axes_melee_debuff_dummy:IsHidden() 			return false end
function modifier_imba_whirling_axes_melee_debuff_dummy:IsPurgable() 		return true end
function modifier_imba_whirling_axes_melee_debuff_dummy:IsPurgeException() 	return true end
function modifier_imba_whirling_axes_melee_debuff_dummy:DeclareFunctions() return {MODIFIER_PROPERTY_MISS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_FAIL} end
function modifier_imba_whirling_axes_melee_debuff_dummy:GetModifierMiss_Percentage() return 100 end
function modifier_imba_whirling_axes_melee_debuff_dummy:OnAttackFail(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() then
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

imba_troll_warlord_whirling_axes_ranged = class({})

LinkLuaModifier("modifier_imba_whirling_axes_ranged_debuff", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

function imba_troll_warlord_whirling_axes_ranged:IsHiddenWhenStolen() 		return false end
function imba_troll_warlord_whirling_axes_ranged:IsRefreshable() 			return true end
function imba_troll_warlord_whirling_axes_ranged:IsStealable() 				return true end
function imba_troll_warlord_whirling_axes_ranged:IsNetherWardStealable()	return true end
function imba_troll_warlord_whirling_axes_ranged:GetCastRange() return self:GetSpecialValueFor("range") end

function imba_troll_warlord_whirling_axes_ranged:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_TrollWarlord.WhirlingAxes.Ranged")
	local direction = (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized()
	local endpos = caster:GetAbsOrigin() + direction * (self:GetSpecialValueFor("range") + caster:GetCastRangeBonus())
	local axes = self:GetSpecialValueFor("base_axes") + math.floor(caster:GetAgility() / self:GetSpecialValueFor("agility_per_axe"))
	local angles = self:GetSpecialValueFor("spread_angle")
	local angle = angles / axes
	for i = (0 - axes / 2), (axes / 2) do
		local pos = RotatePosition(caster:GetAbsOrigin(), QAngle(0, i * angle, 0), endpos)
		local thinker = CreateModifierThinker(caster, self, "modifier_imba_whirling_axes_ranged_debuff", {}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false):entindex()
		EntIndexToHScript(thinker).hitted = {}
		local info = 
		{
			Ability = self,
			EffectName = "particles/units/heroes/hero_troll_warlord/troll_warlord_whirling_axe_ranged.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin(),
			fDistance = self:GetSpecialValueFor("range") + caster:GetCastRangeBonus(),
			fStartRadius = self:GetSpecialValueFor("radius"),
			fEndRadius = self:GetSpecialValueFor("radius"),
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = (pos - caster:GetAbsOrigin()):Normalized() * self:GetSpecialValueFor("speed"),
			bProvidesVision = false,
			ExtraData = {thinker = thinker}
		}
		ProjectileManager:CreateLinearProjectile(info)
	end
end

function imba_troll_warlord_whirling_axes_ranged:OnProjectileHit_ExtraData(target, location, keys)
	if target and not IsInTable(target, EntIndexToHScript(keys.thinker).hitted) then
		table.insert(EntIndexToHScript(keys.thinker).hitted, target)
		target:EmitSound("Hero_TrollWarlord.WhirlingAxes.Target")
		ApplyDamage({attacker = self:GetCaster(), victim = target, damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self})
		local buff = target:AddNewModifier(self:GetCaster(), self, "modifier_imba_whirling_axes_ranged_debuff", {duration = self:GetSpecialValueFor("duration")})
		buff:SetStackCount(buff:GetStackCount() + 1)
	else
		EntIndexToHScript(keys.thinker).hitted = nil
		EntIndexToHScript(keys.thinker):ForceKill(false)
	end
end

modifier_imba_whirling_axes_ranged_debuff = class({})

function modifier_imba_whirling_axes_ranged_debuff:IsDebuff()			return true end
function modifier_imba_whirling_axes_ranged_debuff:IsHidden() 			return false end
function modifier_imba_whirling_axes_ranged_debuff:IsPurgable() 		return true end
function modifier_imba_whirling_axes_ranged_debuff:IsPurgeException() 	return true end
function modifier_imba_whirling_axes_ranged_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_whirling_axes_ranged_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - (self:GetAbility():GetSpecialValueFor("base_slow") + self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stack_slow"))) end


imba_troll_warlord_fervor = class({})

LinkLuaModifier("modifier_imba_fervor_passive", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_fervor_dummy", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

function imba_troll_warlord_fervor:GetIntrinsicModifierName() return "modifier_imba_fervor_passive" end

modifier_imba_fervor_passive = class({})

function modifier_imba_fervor_passive:IsDebuff()			return false end
function modifier_imba_fervor_passive:IsHidden() 			return true end
function modifier_imba_fervor_passive:IsPurgable() 			return false end
function modifier_imba_fervor_passive:IsPurgeException() 	return false end
function modifier_imba_fervor_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_fervor_passive:OnAttackLanded(keys)
	if IsServer() then
		if not self:GetParent():PassivesDisabled() and keys.attacker == self:GetParent() and not self:GetParent():HasModifier("modifier_imba_berserkers_rage_no_dmg") and not self:GetParent():IsIllusion() and not keys.target:IsBoss() then
			local buff = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_fervor_dummy", {duration = self:GetAbility():GetSpecialValueFor("duration")})
			buff:SetStackCount(buff:GetStackCount() + 1)
		end
	end
end

function modifier_imba_fervor_passive:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_fervor_passive:OnIntervalThink()
	if self:GetParent():PassivesDisabled() then
		self:GetParent():RemoveModifierByName("modifier_imba_fervor_dummy")
	end
	IncreaseAttackSpeedCap(self:GetParent(), 10000)
end

modifier_imba_fervor_dummy = class({})

function modifier_imba_fervor_dummy:IsDebuff()			return false end
function modifier_imba_fervor_dummy:IsHidden() 			return false end
function modifier_imba_fervor_dummy:IsPurgable() 		return false end
function modifier_imba_fervor_dummy:IsPurgeException() 	return false end
function modifier_imba_fervor_dummy:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_fervor_dummy:GetModifierAttackSpeedBonus_Constant() return (self:GetParent():IsIllusion() and 0 or (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_as"))) end

imba_troll_warlord_berserkers_rage = class({})

LinkLuaModifier("modifier_imba_berserkers_rage_passive", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_berserkers_rage_no_dmg", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

function imba_troll_warlord_berserkers_rage:IsTalentAbility() return true end
function imba_troll_warlord_berserkers_rage:GetIntrinsicModifierName() return "modifier_imba_berserkers_rage_passive" end

modifier_imba_berserkers_rage_passive = class({})

function modifier_imba_berserkers_rage_passive:IsDebuff()			return false end
function modifier_imba_berserkers_rage_passive:IsHidden() 			return true end
function modifier_imba_berserkers_rage_passive:IsPurgable() 		return false end
function modifier_imba_berserkers_rage_passive:IsPurgeException() 	return false end
function modifier_imba_berserkers_rage_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_berserkers_rage_passive:OnAttackLanded(keys)
	if IsServer() and self:GetParent() == keys.attacker and self:GetParent().splitattack then
		if RollPercentage(self:GetAbility():GetSpecialValueFor("bash_chance")) and (keys.target:IsHero() or keys.target:IsCreep()) and self:GetParent():IsRealHero() then
			keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_stunned", {duration = self:GetAbility():GetSpecialValueFor("bash_duration")})
			keys.target:EmitSound("Hero_TrollWarlord.BerserkersRage.Stun")
			ApplyDamage({victim = keys.target, attacker = keys.attacker, damage = self:GetAbility():GetSpecialValueFor("bash_damage"), damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
		end
		self:GetParent():SetAttackCapability(1)
		self:GetParent().splitattack = false
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_berserkers_rage_no_dmg", {})
		self:GetParent():PerformAttack(keys.target, false, true, true, false, false, true, true)
		self:GetParent():RemoveModifierByName("modifier_imba_berserkers_rage_no_dmg")
		self:GetParent().splitattack = true
		self:GetParent():SetAttackCapability(2)
	end
end

modifier_imba_berserkers_rage_no_dmg = class({})

function modifier_imba_berserkers_rage_no_dmg:IsDebuff()			return false end
function modifier_imba_berserkers_rage_no_dmg:IsHidden() 			return true end
function modifier_imba_berserkers_rage_no_dmg:IsPurgable() 			return false end
function modifier_imba_berserkers_rage_no_dmg:IsPurgeException() 	return false end
function modifier_imba_berserkers_rage_no_dmg:DeclareFunctions() return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_berserkers_rage_no_dmg:GetModifierDamageOutgoing_Percentage() return (IsServer() and -100 or 0) end

imba_troll_warlord_battle_trance = class({})

LinkLuaModifier("modifier_imba_battle_trance", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_battle_trance_stacks", "hero/hero_troll_warlord", LUA_MODIFIER_MOTION_NONE)

function imba_troll_warlord_battle_trance:IsHiddenWhenStolen() 		return false end
function imba_troll_warlord_battle_trance:IsRefreshable() 			return true end
function imba_troll_warlord_battle_trance:IsStealable() 			return true end
function imba_troll_warlord_battle_trance:IsNetherWardStealable()	return true end

function imba_troll_warlord_battle_trance:OnSpellStart()
	local caster = self:GetCaster()
	EmitGlobalSound("Hero_TrollWarlord.BattleTrance.Cast.Team")
	caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_imba_battle_trance", {duration = self:GetSpecialValueFor("buff_duration")})
		ally:AddNewModifier(caster, self, "modifier_imba_battle_trance_stacks", {duration = self:GetSpecialValueFor("trance_duration")})
	end
end

modifier_imba_battle_trance = class({})

function modifier_imba_battle_trance:IsDebuff()			return false end
function modifier_imba_battle_trance:IsHidden() 		return true end
function modifier_imba_battle_trance:IsPurgable() 		return false end
function modifier_imba_battle_trance:IsPurgeException() return false end
function modifier_imba_battle_trance:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT} end
function modifier_imba_battle_trance:GetModifierBaseAttackTimeConstant() return (self:GetCaster():HasScepter() and (self.batreduc or 0) or 0) end
function modifier_imba_battle_trance:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_imba_battle_trance:GetEffectName() return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf" end
function modifier_imba_battle_trance:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_battle_trance:OnCreated() self.batreduc = self:GetParent():GetBaseAttackTime() * (self:GetAbility():GetSpecialValueFor("bat_scepter") / 100) end

modifier_imba_battle_trance_stacks = class({})

function modifier_imba_battle_trance_stacks:IsDebuff()			return false end
function modifier_imba_battle_trance_stacks:IsHidden() 			return false end
function modifier_imba_battle_trance_stacks:IsPurgable() 		return false end
function modifier_imba_battle_trance_stacks:IsPurgeException() 	return false end
function modifier_imba_battle_trance_stacks:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_imba_battle_trance_stacks:OnAttackLanded(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() and not self:GetParent():HasModifier("modifier_imba_berserkers_rage_no_dmg") then
			self:IncrementStackCount()
		end
	end
end
function modifier_imba_battle_trance_stacks:GetModifierAttackSpeedBonus_Constant() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("trance_as")) end