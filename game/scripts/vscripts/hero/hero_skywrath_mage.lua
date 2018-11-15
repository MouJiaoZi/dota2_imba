

CreateEmptyTalents("skywrath_mage")



imba_skywrath_mage_arcane_bolt = class({})

LinkLuaModifier("modifier_imba_arcane_int_stack", "hero/hero_skywrath_mage", LUA_MODIFIER_MOTION_NONE)

function imba_skywrath_mage_arcane_bolt:IsHiddenWhenStolen() 	return false end
function imba_skywrath_mage_arcane_bolt:IsRefreshable() 		return true end
function imba_skywrath_mage_arcane_bolt:IsStealable() 			return true end
function imba_skywrath_mage_arcane_bolt:IsNetherWardStealable()	return true end

function imba_skywrath_mage_arcane_bolt:OnSpellStart(scepter)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:EmitSound("Hero_SkywrathMage.ArcaneBolt.Cast")
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_arcane_bolt.vpcf" ,
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
		bDrawsOnMinimap = false,
		bDodgeable = false,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
	if caster:HasScepter() and not scepter then
		local radius = self:GetCastRange(caster:GetAbsOrigin(), caster) + caster:GetCastRangeBonus()
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, hero in pairs(heroes) do
			if hero ~= target then
				caster:SetCursorCastTarget(hero)
				self:OnSpellStart(true)
				return
			end
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, unit in pairs(units) do
			if unit ~= target then
				caster:SetCursorCastTarget(unit)
				self:OnSpellStart(true)
				return
			end
		end
	end
end

function imba_skywrath_mage_arcane_bolt:OnProjectileThink(location) AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("vision_radius"), FrameTime(), false) end

function imba_skywrath_mage_arcane_bolt:OnProjectileHit(target, location)
	if not target then
		return
	end
	if target:IsMagicImmune() or target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("Hero_SkywrathMage.ArcaneBolt.Impact")
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("vision_radius"), self:GetSpecialValueFor("vision_duration"), false)
	local caster = self:GetCaster()
	local buff = caster:AddNewModifier(caster, self, "modifier_imba_arcane_int_stack", {duration = self:GetSpecialValueFor("stack_duration")})
	buff:SetStackCount(buff:GetStackCount() + 1)
	caster:CalculateStatBonus()
	local int_multiplier = self:GetSpecialValueFor("int_multiplier") + caster:GetModifierStackCount("modifier_imba_arcane_int_stack", caster) * self:GetSpecialValueFor("stack_int_multi_bonus")
	local dmg = self:GetSpecialValueFor("base_damage") + caster:GetIntellect() * int_multiplier
	local damageTable = {
						victim = target,
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self, --Optional.
						}
	ApplyDamage(damageTable)
end

modifier_imba_arcane_int_stack = class({})

function modifier_imba_arcane_int_stack:IsDebuff()			return false end
function modifier_imba_arcane_int_stack:IsHidden() 			return false end
function modifier_imba_arcane_int_stack:IsPurgable() 		return true end
function modifier_imba_arcane_int_stack:IsPurgeException() 	return true end
function modifier_imba_arcane_int_stack:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_arcane_int_stack:GetModifierBonusStats_Intellect() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("stack_int_bonus")) end


imba_skywrath_mage_concussive_shot = class({})

LinkLuaModifier("modifier_imba_concussive_shot_thinker", "hero/hero_skywrath_mage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_concussive_shot_slow", "hero/hero_skywrath_mage", LUA_MODIFIER_MOTION_NONE)

function imba_skywrath_mage_concussive_shot:IsHiddenWhenStolen() 	return false end
function imba_skywrath_mage_concussive_shot:IsRefreshable() 		return true end
function imba_skywrath_mage_concussive_shot:IsStealable() 			return true end
function imba_skywrath_mage_concussive_shot:IsNetherWardStealable()	return true end
function imba_skywrath_mage_concussive_shot:GetCastRange() return self:GetSpecialValueFor("search_range") - self:GetCaster():GetCastRangeBonus() end

function imba_skywrath_mage_concussive_shot:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
	local main = 1
	local target
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("search_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
	for _, hero in pairs(heroes) do
		target = hero
		self:ConcussiveShotLaunch(hero, self:GetSpecialValueFor("damage"), main)
		break
	end
	if caster:HasScepter() and target then
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("search_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)
		for _, hero in pairs(heroes) do
			if hero ~= target then
				self:ConcussiveShotLaunch(hero, self:GetSpecialValueFor("damage"), main)
				break
			end
		end
	end
end

function imba_skywrath_mage_concussive_shot:ConcussiveShotLaunch(target, damage, main, source)
	local info = 
	{
		Target = target,
		Source = source or self:GetCaster(),
		Ability = self,	
		EffectName = "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,	
		ExtraData = {damage = damage, main = main}
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_skywrath_mage_concussive_shot:OnProjectileThink(location) AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("vision_radius"), FrameTime(), false) end

function imba_skywrath_mage_concussive_shot:OnProjectileHit_ExtraData(target, location, keys)
	if not target then
		return
	end
	local caster = self:GetCaster()
	target:EmitSound("Hero_SkywrathMage.ConcussiveShot.Target")
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, self:GetSpecialValueFor("vision_radius"), self:GetSpecialValueFor("vision_duration"), false)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), location, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = self:GetCaster(),
							damage = keys.damage,
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		enemy:AddNewModifier(caster, self, "modifier_imba_concussive_shot_slow", {duration = self:GetSpecialValueFor("slow_duration")})
	end
	if not target:IsMagicImmune() and keys.main == 1 then
		CreateModifierThinker(caster, self, "modifier_imba_concussive_shot_thinker", {duration = self:GetSpecialValueFor("slow_duration")}, location, caster:GetTeamNumber(), false)
	end
end

modifier_imba_concussive_shot_slow = class({})

function modifier_imba_concussive_shot_slow:IsDebuff()			return true end
function modifier_imba_concussive_shot_slow:IsHidden() 			return false end
function modifier_imba_concussive_shot_slow:IsPurgable() 		return true end
function modifier_imba_concussive_shot_slow:IsPurgeException() 	return true end
function modifier_imba_concussive_shot_slow:GetEffectName() return "particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_shot_slow_debuff.vpcf" end
function modifier_imba_concussive_shot_slow:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_concussive_shot_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_concussive_shot_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_amount")) end

modifier_imba_concussive_shot_thinker = class({})

function modifier_imba_concussive_shot_thinker:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/hero/skywrath_mage/skywrath_mage_ghastly_eerie.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("ghastly_pulse_intervals"))
	end
end

function modifier_imba_concussive_shot_thinker:OnIntervalThink()
	local caster = self:GetCaster()
	local thinker = self:GetParent()
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), thinker:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), enemy:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("search_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, hero in pairs(heroes) do
			if hero ~= enemy then
				self:GetAbility():ConcussiveShotLaunch(hero, self:GetAbility():GetSpecialValueFor("damage_ghastly"), 0, enemy)
				enemy:SpendMana(self:GetAbility():GetSpecialValueFor("mana_force_spend"), self:GetAbility())
				break
			end
		end
	end
end

imba_skywrath_mage_ancient_seal = class({})

LinkLuaModifier("modifier_imba_ancient_seal_silence", "hero/hero_skywrath_mage", LUA_MODIFIER_MOTION_NONE)

function imba_skywrath_mage_ancient_seal:IsHiddenWhenStolen() 		return false end
function imba_skywrath_mage_ancient_seal:IsRefreshable() 			return true end
function imba_skywrath_mage_ancient_seal:IsStealable() 				return true end
function imba_skywrath_mage_ancient_seal:IsNetherWardStealable()	return true end

function imba_skywrath_mage_ancient_seal:OnSpellStart(scepter)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("Hero_SkywrathMage.AncientSeal.Target")
	target:AddNewModifier(caster, self, "modifier_imba_ancient_seal_silence", {duration = self:GetSpecialValueFor("duration")})
	if caster:HasScepter() and not scepter then
		local radius = self:GetCastRange(caster:GetAbsOrigin(), caster) + caster:GetCastRangeBonus()
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, hero in pairs(heroes) do
			if hero ~= target then
				caster:SetCursorCastTarget(hero)
				self:OnSpellStart(true)
				return
			end
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, unit in pairs(units) do
			if unit ~= target then
				caster:SetCursorCastTarget(unit)
				self:OnSpellStart(true)
				return
			end
		end
	end
end

modifier_imba_ancient_seal_silence = class({})

function modifier_imba_ancient_seal_silence:IsDebuff()			return true end
function modifier_imba_ancient_seal_silence:IsHidden() 			return false end
function modifier_imba_ancient_seal_silence:IsPurgable() 		return true end
function modifier_imba_ancient_seal_silence:IsPurgeException() 	return true end
function modifier_imba_ancient_seal_silence:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end
function modifier_imba_ancient_seal_silence:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_ancient_seal_silence:GetModifierMagicalResistanceBonus() return (0 - self:GetAbility():GetSpecialValueFor("magic_reduction")) end

function modifier_imba_ancient_seal_silence:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_ancient_seal_silence:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and keys.inflictor and (keys.inflictor:GetName() == "imba_skywrath_mage_arcane_bolt" or keys.inflictor:GetName() == "imba_skywrath_mage_concussive_shot" or keys.inflictor:GetName() == "imba_skywrath_mage_mystic_flare") then
		if keys.inflictor:GetName() == "imba_skywrath_mage_arcane_bolt" or keys.inflictor:GetName() == "imba_skywrath_mage_concussive_shot" then
			self:SetDuration(self:GetRemainingTime() + self:GetAbility():GetSpecialValueFor("bolt_duration"), true)
		else
			self:SetDuration(self:GetRemainingTime() + self:GetAbility():GetSpecialValueFor("mystic_duration"), true)
		end
	end
end


imba_skywrath_mage_mystic_flare = class({})

LinkLuaModifier("modifier_imba_mystic_flare_thinker", "hero/hero_skywrath_mage", LUA_MODIFIER_MOTION_NONE)

function imba_skywrath_mage_mystic_flare:IsHiddenWhenStolen() 		return false end
function imba_skywrath_mage_mystic_flare:IsRefreshable() 			return true end
function imba_skywrath_mage_mystic_flare:IsStealable() 				return true end
function imba_skywrath_mage_mystic_flare:IsNetherWardStealable()	return true end
function imba_skywrath_mage_mystic_flare:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_skywrath_mage_mystic_flare:OnSpellStart(scepter)
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	caster:EmitSound("Hero_SkywrathMage.MysticFlare.Cast")
	CreateModifierThinker(caster, self, "modifier_imba_mystic_flare_thinker", {duration = self:GetSpecialValueFor("duration")}, pos, caster:GetTeamNumber(), false)
	if caster:HasScepter() and not scepter then
		local radius = self:GetCastRange(caster:GetAbsOrigin(), caster) + caster:GetCastRangeBonus()
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, hero in pairs(heroes) do
			if (hero:GetAbsOrigin() - pos):Length2D() > self:GetSpecialValueFor("radius") then
				caster:SetCursorPosition(hero:GetAbsOrigin())
				self:OnSpellStart(true)
				return
			end
		end
		local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
		for _, unit in pairs(units) do
			if (unit:GetAbsOrigin() - pos):Length2D() > self:GetSpecialValueFor("radius") then
				caster:SetCursorPosition(unit:GetAbsOrigin())
				self:OnSpellStart(true)
				return
			end
		end
	end
end

modifier_imba_mystic_flare_thinker = class({})

function modifier_imba_mystic_flare_thinker:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_SkywrathMage.MysticFlare")
		self:StartIntervalThink(0.1)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"), self:GetAbility():GetSpecialValueFor("radius"), 1))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_mystic_flare_thinker:OnIntervalThink()
	local pos = GetRandomPosition2D(self:GetParent():GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("radius") * 0.8)
	local dmg = self:GetAbility():GetSpecialValueFor("damage") / (self:GetDuration() / 0.1)
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	if #enemies ~= 0 then
		pos = RandomFromTable(enemies):GetAbsOrigin()
		dmg = dmg / #enemies
		for _, enemy in pairs(enemies) do
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = dmg,
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
		end
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_mystic_flare_ambient_hit.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:ReleaseParticleIndex(pfx)
end

function modifier_imba_mystic_flare_thinker:OnDestroy()
	if IsServer() then
		local dmg = self:GetAbility():GetSpecialValueFor("explosion_damage") + self:GetCaster():GetModifierStackCount("modifier_imba_arcane_int_stack", self:GetCaster()) * self:GetAbility():GetSpecialValueFor("explosion_damage_increase")
		local radius = self:GetAbility():GetSpecialValueFor("explosion_radius") + self:GetCaster():GetModifierStackCount("modifier_imba_arcane_int_stack", self:GetCaster()) * self:GetAbility():GetSpecialValueFor("explosion_radius_increase")
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = dmg,
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
		end
		local pfx = ParticleManager:CreateParticle("particles/hero/skywrath_mage/skywrath_mage_mystic_flare_explosion.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(radius, radius, 1))
		Timers:CreateTimer(0.8, function()
			ParticleManager:DestroyParticle(pfx, false)
			ParticleManager:ReleaseParticleIndex(pfx)
			return nil
		end
		)
	end
end