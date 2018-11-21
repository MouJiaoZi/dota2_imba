

CreateEmptyTalents("venomancer")



imba_venomancer_venomous_gale = class({})

LinkLuaModifier("modifier_imba_venomous_gale_slow", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)

function imba_venomancer_venomous_gale:IsHiddenWhenStolen() 	return false end
function imba_venomancer_venomous_gale:IsRefreshable() 			return true end
function imba_venomancer_venomous_gale:IsStealable() 			return true end
function imba_venomancer_venomous_gale:IsNetherWardStealable()	return true end

function imba_venomancer_venomous_gale:GetCastRange()
	if IsServer() then
		return 0
	else
		return self:GetSpecialValueFor("distance")
	end
end

function imba_venomancer_venomous_gale:OnSpellStart(vOrigin)
	local caster = self:GetCaster()
	local pos0 = vOrigin or caster:GetAbsOrigin()
	pos0.z = pos0.z + 100
	local pos = self:GetCursorPosition()
	local sound = CreateUnitByName("npc_dummy_unit", pos0, false, nil, nil, 0)
	sound:EmitSound("Hero_Venomancer.VenomousGale")
	sound:ForceKill(false)
	local distance = self:GetSpecialValueFor("distance") + caster:GetCastRangeBonus()
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf",
		vSpawnOrigin = pos0,
		fDistance = distance,
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
		vVelocity = (pos - pos0):Normalized() * self:GetSpecialValueFor("speed"),
		bProvidesVision = false,
		--ExtraData = {}
	}
	ProjectileManager:CreateLinearProjectile(info)
	if not vOrigin then
		local wards = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("ward_radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, ward in pairs(wards) do 
			if ward:GetOwnerEntity() == caster and ward:GetUnitName() == "npc_imba_venomancer_scourge_ward" then
				self:OnSpellStart(ward:GetAbsOrigin())
				ward:SetForwardVector((pos - pos0):Normalized())
			end
		end
	end
end

function imba_venomancer_venomous_gale:OnProjectileHit(target, location)
	if not target then
		return
	end
	target:EmitSound("Hero_Venomancer.VenomousGaleImpact")
	local dmg = math.max(self:GetSpecialValueFor("initial_damage"), target:GetMaxHealth() * (self:GetSpecialValueFor("initial_damage_pct") / 100))
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, target, dmg, nil)
	ApplyDamage({victim = target, attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self})
	target:AddNewModifier(self:GetCaster(), self, "modifier_imba_venomous_gale_slow", {duration = self:GetSpecialValueFor("duration")})
	if self:GetCaster():HasTalent("special_bonus_imba_venomancer_1") and self:GetCaster():HasAbility("imba_venomancer_plague_ward") and target:IsHero() then
		self:GetCaster():SetCursorPosition(location)
		self:GetCaster():FindAbilityByName("imba_venomancer_plague_ward"):OnSpellStart(true)
	end
end

modifier_imba_venomous_gale_slow = class({})

function modifier_imba_venomous_gale_slow:IsDebuff()			return true end
function modifier_imba_venomous_gale_slow:IsHidden() 			return false end
function modifier_imba_venomous_gale_slow:IsPurgable() 			return false end
function modifier_imba_venomous_gale_slow:IsPurgeException() 	return false end
function modifier_imba_venomous_gale_slow:GetEffectName() return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf" end
function modifier_imba_venomous_gale_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_venomous_gale_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_venomous_gale_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("initial_slow") * (self:GetRemainingTime() / self:GetDuration())) end
function modifier_imba_venomous_gale_slow:CheckState()
	if self:GetParent():GetHealthPercent() <= 25 then
		return {[MODIFIER_STATE_SPECIALLY_DENIABLE] = true}
	else
		return nil
	end
end

function modifier_imba_venomous_gale_slow:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_interval"))
	end
end

function modifier_imba_venomous_gale_slow:OnIntervalThink()
	local dmg = math.max(self:GetAbility():GetSpecialValueFor("tick_damage"), self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("tick_damage_pct") / 100))
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self:GetParent(), dmg, nil)
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NONE, ability = self:GetAbility()})
end

imba_venomancer_poison_sting = class({})

LinkLuaModifier("modifier_imba_poison_sting_passive", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_poison_sting", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)

function imba_venomancer_poison_sting:GetIntrinsicModifierName() return "modifier_imba_poison_sting_passive" end
function imba_venomancer_poison_sting:IsHiddenWhenStolen() return true end
function imba_venomancer_poison_sting:GetAssociatedPrimaryAbilities() return "imba_venomancer_plague_ward" end

modifier_imba_poison_sting_passive = class({})

function modifier_imba_poison_sting_passive:IsDebuff()			return false end
function modifier_imba_poison_sting_passive:IsHidden() 			return true end
function modifier_imba_poison_sting_passive:IsPurgable() 		return false end
function modifier_imba_poison_sting_passive:IsPurgeException() 	return false end
function modifier_imba_poison_sting_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_poison_sting_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():PassivesDisabled() or keys.attacker ~= self:GetParent() or keys.target:IsOther() or keys.target:IsBuilding() or keys.target:IsCourier() or self:GetAbility():IsStolen() then
		return
	end
	local stacks = keys.target:HasModifier("modifier_imba_poison_sting") and self:GetAbility():GetSpecialValueFor("caster_stacks") or self:GetAbility():GetSpecialValueFor("initial_stacks")
	local buff = keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_poison_sting", {})
	buff:SetStackCount(buff:GetStackCount() + stacks)
end

modifier_imba_poison_sting = class({})

function modifier_imba_poison_sting:IsDebuff()			return true end
function modifier_imba_poison_sting:IsHidden() 			return false end
function modifier_imba_poison_sting:IsPurgable() 		return false end
function modifier_imba_poison_sting:IsPurgeException() 	return false end
function modifier_imba_poison_sting:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_poison_sting:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("slow_per_stack")) end

function modifier_imba_poison_sting:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_poison_sting:OnIntervalThink()
	local dmg = self:GetStackCount() * self:GetAbility():GetSpecialValueFor("dmg_per_stack")
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self:GetParent(), dmg, nil)
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, ability = self:GetAbility()})
	self:SetStackCount(math.max(self:GetStackCount() - math.max(math.floor(self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("stack_decay") / 100)), self:GetAbility():GetSpecialValueFor("stack_decay_min")), 0))
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
	if self:GetCaster():HasModifier("modifier_imba_skadi_passive") then
		local buff = self:GetCaster():FindModifierByName("modifier_imba_skadi_passive")
		buff:OnTakeDamage({attacker = self:GetCaster(), unit = self:GetParent()})
	end
	if self:GetCaster():HasModifier("modifier_imba_toxicity_passive") then
		local buff = self:GetCaster():FindModifierByName("modifier_imba_toxicity_passive")
		buff:OnTakeDamage({attacker = self:GetCaster(), unit = self:GetParent(), inflictor = self:GetAbility()})
	end
	if self:GetParent():HasModifier("modifier_imba_centaur_return") then
		local buff = self:GetParent():FindModifierByName("modifier_imba_centaur_return")
		buff:OnTakeDamage({attacker = self:GetCaster(), unit = self:GetParent(), inflictor = self:GetAbility()})
	end
end

imba_venomancer_plague_ward = class({})

LinkLuaModifier("modifier_imba_plague_ward_think", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)

function imba_venomancer_plague_ward:IsHiddenWhenStolen() 	return false end
function imba_venomancer_plague_ward:IsRefreshable() 		return true end
function imba_venomancer_plague_ward:IsStealable() 			return true end
function imba_venomancer_plague_ward:IsNetherWardStealable()return false end
function imba_venomancer_plague_ward:GetAssociatedSecondaryAbilities() return "imba_venomancer_poison_sting" end

function imba_venomancer_plague_ward:OnSpellStart(bNomain)
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local ability = caster:FindAbilityByName("imba_venomancer_poison_sting")
	local theward = {}
	if not bNomain then
		local ward_main = CreateUnitByName("npc_imba_venomancer_scourge_ward", pos, true, caster, caster, caster:GetTeamNumber())
		ward_main:SetBaseDamageMax(self:GetSpecialValueFor("scourge_damage"))
		ward_main:SetBaseDamageMin(self:GetSpecialValueFor("scourge_damage"))
		ward_main:SetControllableByPlayer(caster:GetPlayerID(), true)
		table.insert(theward, ward_main)
		ward_main:EmitSound("Hero_Venomancer.Plague_Ward")
		SetCreatureHealth(ward_main, self:GetSpecialValueFor("scourge_creep_health"), true)
	end

	local wards = self:GetSpecialValueFor("plague_amount")
	for i=1, wards do
		local spawn_point = RotatePosition(pos, QAngle(0, i * 360 / wards, 0), pos + caster:GetForwardVector() * 125 )
		local ward_min = CreateUnitByName("npc_imba_venomancer_plague_ward", spawn_point, true, caster, caster, caster:GetTeamNumber())
		ward_min:SetControllableByPlayer(caster:GetPlayerID(), true)
		ward_min:SetBaseDamageMax(self:GetSpecialValueFor("plague_damage"))
		ward_min:SetBaseDamageMin(self:GetSpecialValueFor("plague_damage"))
		ward_min:EmitSound("Hero_Venomancer.Plague_Ward")
		table.insert(theward, ward_min)
		SetCreatureHealth(ward_min, self:GetSpecialValueFor("plague_creep_health"), true)
	end
	local pfx_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_ward_cast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	for i=0, 1 do
		ParticleManager:SetParticleControlEnt(pfx_cast, i, caster, PATTACH_POINT_FOLLOW, "attach_attack"..(i + 1), caster:GetAbsOrigin(), true)
	end
	ParticleManager:ReleaseParticleIndex(pfx_cast)
	for _, ward in pairs(theward) do
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_ward_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, ward)
		ParticleManager:ReleaseParticleIndex(pfx)
		ward:AddNewModifier(caster, self, "modifier_imba_plague_ward_think", {duration = self:GetSpecialValueFor("duration")})
		ward:AddNewModifier(caster, self, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	end
	Timers:CreateTimer(FrameTime(), function()
		for _, ward in pairs(theward) do
			FindClearSpaceForUnit(ward, ward:GetAbsOrigin(), true)
		end
		return nil
	end
	)
end

modifier_imba_plague_ward_think = class({})

function modifier_imba_plague_ward_think:IsDebuff()			return false end
function modifier_imba_plague_ward_think:IsHidden() 		return true end
function modifier_imba_plague_ward_think:IsPurgable() 		return false end
function modifier_imba_plague_ward_think:IsPurgeException() return false end
function modifier_imba_plague_ward_think:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end
function modifier_imba_plague_ward_think:GetModifierIncomingDamage_Percentage() return -100000 end
function modifier_imba_plague_ward_think:CheckState()
	if self:GetParent():GetUnitName() == "npc_imba_venomancer_scourge_ward" then
		return {[MODIFIER_STATE_DISARMED] = true}
	else
		return nil
	end
end

function modifier_imba_plague_ward_think:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not  keys.target:IsBuilding() and not  keys.target:IsOther() and not keys.target:IsCourier() then
		local ability = self:GetCaster():FindAbilityByName("imba_venomancer_poison_sting")
		if ability and ability:GetLevel() > 0 then
			local buff = keys.target:AddNewModifier(self:GetCaster(), ability, "modifier_imba_poison_sting", {})
			buff:SetStackCount(buff:GetStackCount() + 1)
		end
	end
	if keys.target == self:GetParent() then
		local dmg = 1
		if keys.attacker:IsBuilding() or keys.attacker:IsRealHero() then
			dmg = 2
		end
		if self:GetParent():GetHealth() <= dmg then
			self:GetParent():Kill(self:GetAbility(), keys.attacker)
		else
			self:GetParent():SetHealth(self:GetParent():GetHealth() - dmg)
		end
	end
end

function modifier_imba_plague_ward_think:OnCreated()
	if IsServer() and self:GetParent():GetUnitName() == "npc_imba_venomancer_scourge_ward" then
		self:OnIntervalThink()
		self:StartIntervalThink(self:GetParent():GetBaseAttackTime())
	end
end

function modifier_imba_plague_ward_think:OnIntervalThink()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	for i, enemy in pairs(enemies) do
		self:GetParent():PerformAttack(enemy, true, true, true, false, true, false, false)
		if i == 1 then
			self:GetParent():SetForwardVector((enemy:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized())
		end
	end
	self:GetParent():StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2.0)
end


imba_venomancer_toxicity = class({})

LinkLuaModifier("modifier_imba_toxicity_passive", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_toxicity", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)

function imba_venomancer_toxicity:IsTalentAbility() return true end
function imba_venomancer_toxicity:GetIntrinsicModifierName() return "modifier_imba_toxicity_passive" end

modifier_imba_toxicity_passive = class({})

function modifier_imba_toxicity_passive:IsDebuff()			return false end
function modifier_imba_toxicity_passive:IsHidden() 			return true end
function modifier_imba_toxicity_passive:IsPurgable() 		return false end
function modifier_imba_toxicity_passive:IsPurgeException() 	return false end
function modifier_imba_toxicity_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_toxicity_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.inflictor and (keys.inflictor:GetName() == "imba_venomancer_venomous_gale" or keys.inflictor:GetName() == "imba_venomancer_poison_sting" or keys.inflictor:GetName() == "imba_venomancer_poison_nova") and IsEnemy(keys.unit, self:GetParent()) then
		local buff = keys.unit:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_toxicity", {})
		buff.time = GameRules:GetGameTime()
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
end

modifier_imba_toxicity = class({})

function modifier_imba_toxicity:IsDebuff()			return true end
function modifier_imba_toxicity:IsHidden() 			return false end
function modifier_imba_toxicity:IsPurgable() 		return false end
function modifier_imba_toxicity:IsPurgeException() 	return false end
function modifier_imba_toxicity:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_imba_toxicity:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("move_slow")) end
function modifier_imba_toxicity:GetModifierMagicalResistanceBonus() return (0 - self:GetStackCount() * self:GetAbility():GetSpecialValueFor("magic_amp")) end

function modifier_imba_toxicity:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_toxicity:OnIntervalThink()
	if GameRules:GetGameTime() - self:GetAbility():GetSpecialValueFor("decay_sec") < self.time then
		return
	end
	self:SetStackCount(math.max(self:GetStackCount() - math.max(math.floor(self:GetStackCount() * (self:GetAbility():GetSpecialValueFor("stack_decay") / 100)), self:GetAbility():GetSpecialValueFor("stack_decay_min")), 0))
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end


imba_venomancer_poison_nova = class({})

LinkLuaModifier("modifier_imba_poison_nova", "hero/hero_venomancer", LUA_MODIFIER_MOTION_NONE)

function imba_venomancer_poison_nova:IsHiddenWhenStolen() 	return false end
function imba_venomancer_poison_nova:IsRefreshable() 		return true end
function imba_venomancer_poison_nova:IsStealable() 			return true end
function imba_venomancer_poison_nova:IsNetherWardStealable()return true end
function imba_venomancer_poison_nova:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end

function imba_venomancer_poison_nova:OnSpellStart()
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	caster:EmitSound("Hero_Venomancer.PoisonNova")
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(pfx2, 1, Vector(self:GetSpecialValueFor("radius"), 1, self:GetSpecialValueFor("radius")))
	ParticleManager:ReleaseParticleIndex(pfx)
	local pfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(pfx3, 1, Vector(self:GetSpecialValueFor("radius"), 1, 0))
	ParticleManager:ReleaseParticleIndex(pfx)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_imba_poison_nova", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_imba_poison_nova = class({})

function modifier_imba_poison_nova:IsDebuff()			return true end
function modifier_imba_poison_nova:IsHidden() 			return false end
function modifier_imba_poison_nova:IsPurgable() 		return false end
function modifier_imba_poison_nova:IsPurgeException() 	return false end
function modifier_imba_poison_nova:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_poison_nova:GetEffectName() return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf" end
function modifier_imba_poison_nova:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_poison_nova:GetStatusEffectName() return "particles/status_fx/status_effect_poison_venomancer.vpcf" end
function modifier_imba_poison_nova:StatusEffectPriority() return 15 end

function modifier_imba_poison_nova:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Venomancer.PoisonNovaImpact")
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_poison_nova:OnIntervalThink()
	local dmg_min = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("damage_min_scepter") or self:GetAbility():GetSpecialValueFor("damage_min")
	local dmg = math.max(dmg_min, self:GetParent():GetHealth() * (self:GetAbility():GetSpecialValueFor("damage_pct") / 100))
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, self:GetParent(), dmg, nil)
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), damage = dmg, damage_type = self:GetAbility():GetAbilityDamageType(), damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL, ability = self:GetAbility()})
	if self:GetCaster():HasScepter() then
		local allies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("contagion_radius_scepter"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, ally in pairs(allies) do
			if ally ~= self:GetParent() then
				if not ally:HasModifier("modifier_imba_poison_nova") then
					ally:EmitSound("Hero_Venomancer.PoisonNovaImpact")
					ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_poison_nova", {duration = self:GetRemainingTime() + self:GetAbility():GetSpecialValueFor("contagion_extra_duration")})
				end
			end
		end
	end
end