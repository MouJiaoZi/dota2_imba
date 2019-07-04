


CreateEmptyTalents("nevermore")


imba_nevermore_shadowraze = class({})

LinkLuaModifier("modifier_imba_shadowraze_combo", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)

function imba_nevermore_shadowraze:IsHiddenWhenStolen() 	return false end
function imba_nevermore_shadowraze:IsRefreshable() 			return true end
function imba_nevermore_shadowraze:IsStealable() 			return true end
function imba_nevermore_shadowraze:IsNetherWardStealable()	return true end
function imba_nevermore_shadowraze:GetCooldown(i) return self:GetSpecialValueFor("charge_time") end
function imba_nevermore_shadowraze:GetCastRange() return self:GetSpecialValueFor("length") end
function imba_nevermore_shadowraze:OnUpgrade()
	if not AbilityChargeController:IsChargeTypeAbility(self) then
		AbilityChargeController:AbilityChargeInitialize(self, self:GetSpecialValueFor("charge_time"), self:GetSpecialValueFor("max_charges"), 1, true, true)
	else
		AbilityChargeController:ChangeChargeAbilityConfig(self, self:GetSpecialValueFor("charge_time"), self:GetSpecialValueFor("max_charges"), 1, true, true)
	end
end

function imba_nevermore_shadowraze:OnSpellStart()
	local caster = self:GetCaster()
	local direction = caster:GetForwardVector():Normalized()
	local length = self:GetSpecialValueFor("length") + caster:GetCastRangeBonus()
	local pfx_number = math.floor(length / self:GetSpecialValueFor("radius")) + 1
	local pfx_name = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
	local sound_name = "Hero_Nevermore.Shadowraze"
	if HeroItems:UnitHasItem(caster, "shadow_fiend/head_arcana") then
		pfx_name = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf"
		sound_name = "Hero_Nevermore.Shadowraze.Arcana"
	end
	for i=1, pfx_number do
		local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
		local pos = GetGroundPosition(caster:GetAbsOrigin() + direction * ((i - 1) * self:GetSpecialValueFor("radius")), nil)
		ParticleManager:SetParticleControl(pfx, 0, pos)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
	local enemies = FindUnitsInLine(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster:GetAbsOrigin() + direction * length, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
	for _, enemy in pairs(enemies) do
		local buff = enemy:AddNewModifier(caster, self, "modifier_imba_shadowraze_combo", {duration = self:GetSpecialValueFor("combo_modifier_duration")})
		buff:SetStackCount(buff:GetStackCount() + 1)
		local dmg = self:GetSpecialValueFor("raze_damage") + math.min(enemy:GetModifierStackCount("modifier_imba_shadowraze_combo", caster) - 1, 0) * self:GetSpecialValueFor("combo_dmg_bonus")
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = dmg,
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
	end
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), sound_name, caster)
end

modifier_imba_shadowraze_combo = class({})

function modifier_imba_shadowraze_combo:IsDebuff()			return true end
function modifier_imba_shadowraze_combo:IsHidden() 			return false end
function modifier_imba_shadowraze_combo:IsPurgable() 		return false end
function modifier_imba_shadowraze_combo:IsPurgeException() 	return false end

imba_nevermore_necromastery = class({})

LinkLuaModifier("modifier_imba_necromastery_counter", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_necromastery_perm", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_necromastery_temp", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)

function imba_nevermore_necromastery:GetIntrinsicModifierName() return "modifier_imba_necromastery_counter" end

function imba_nevermore_necromastery:CreateSoulPfx(caster, target)
	local info = 
	{
		Target = caster,
		Source = target,
		Ability = self,	
		EffectName = "particles/hero/nevermore/nevermore_soul_projectile.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("soul_projectile_speed"),
		vSourceLoc = target:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = false,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

modifier_imba_necromastery_counter = class({})

function modifier_imba_necromastery_counter:IsDebuff()			return false end
function modifier_imba_necromastery_counter:IsHidden() 			return false end
function modifier_imba_necromastery_counter:IsPurgable() 		return false end
function modifier_imba_necromastery_counter:IsPurgeException() 	return false end
function modifier_imba_necromastery_counter:DestroyOnExpire()	return false end

function modifier_imba_necromastery_counter:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_necromastery_counter:GetModifierPreAttack_BonusDamage() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_soul")) end

function modifier_imba_necromastery_counter:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or keys.target:GetTeamNumber() == self:GetParent():GetTeamNumber() or not keys.target:IsHero() or not keys.target:IsAlive() or self:GetParent():IsIllusion() then
		return 
	end
	for i=1, self:GetAbility():GetSpecialValueFor("hero_attack_souls") + math.floor(self:GetParent():GetLevel() / self:GetAbility():GetSpecialValueFor("harvest_levels_per_soul")) do
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_necromastery_temp", {duration = self:GetAbility():GetSpecialValueFor("temp_soul_duration")})
	end
	local dummy = CreateModifierThinker(self:GetParent(), nil, "modifier_dummy_thinker", {duration = 3.0}, keys.target:GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
	self:GetAbility():CreateSoulPfx(self:GetParent(), dummy)
end

function modifier_imba_necromastery_counter:OnTakeDamage(keys)
	if not IsServer() then
		return
	end 
	if not keys.inflictor or keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or keys.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() or not (self:GetParent():FindAbilityByName("imba_nevermore_shadowraze") and keys.inflictor == self:GetParent():FindAbilityByName("imba_nevermore_shadowraze")) or not keys.unit:IsHero() then
		return 
	end
	for i=1, self:GetAbility():GetSpecialValueFor("hero_attack_souls") + math.floor(self:GetParent():GetLevel() / self:GetAbility():GetSpecialValueFor("harvest_levels_per_soul")) do
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_necromastery_temp", {duration = self:GetAbility():GetSpecialValueFor("temp_soul_duration")})
	end
	local dummy = CreateModifierThinker(self:GetParent(), nil, "modifier_dummy_thinker", {duration = 3.0}, keys.unit:GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
	self:GetAbility():CreateSoulPfx(self:GetParent(), dummy)
end

function modifier_imba_necromastery_counter:OnDeath(keys)
	if not IsServer() or self:GetParent():IsIllusion() then
		return
	end
	if keys.unit == self:GetParent() then
		if not self:GetParent():HasScepter() then
			local lose = math.floor(self:GetStackCount() / 2)
			if lose == 0 then
				return
			end
			for i=1,lose do
				local buff = self:GetParent():FindModifierByName("modifier_imba_necromastery_temp") or self:GetParent():FindModifierByName("modifier_imba_necromastery_perm")
				if buff then
					buff:Destroy()
				end
			end
		else
			local temp = self:GetParent():FindAllModifiersByName("modifier_imba_necromastery_temp")
			for _, buff in pairs(temp) do
				buff:Destroy()
			end
		end
		local ability = self:GetParent():FindAbilityByName("imba_nevermore_requiem")
		if ability and ability:GetLevel() > 0 and not self:GetParent():IsIllusion() then
			self:GetParent():SetCursorPosition(self:GetParent():GetAbsOrigin())
			ability:OnSpellStart()
		end
		return 
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():PassivesDisabled() or keys.unit:GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return 
	end
	local souls = keys.unit:IsTrueHero() and self:GetAbility():GetSpecialValueFor("hero_kill_souls") or 1
	local max_soul = self:GetAbility():GetSpecialValueFor("max_souls")
	for i=1, souls do
		if #self:GetParent():FindAllModifiersByName("modifier_imba_necromastery_perm") < max_soul then
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_necromastery_perm", {})
		else
			self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_necromastery_temp", {duration = self:GetAbility():GetSpecialValueFor("temp_soul_duration")})
		end
	end
	local dummy = CreateModifierThinker(self:GetParent(), nil, "modifier_dummy_thinker", {duration = 3.0}, keys.unit:GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
	self:GetAbility():CreateSoulPfx(self:GetParent(), dummy)
end

modifier_imba_necromastery_perm = class({})
function modifier_imba_necromastery_perm:IsHidden() return true end
function modifier_imba_necromastery_perm:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_necromastery_perm:AllowIllusionDuplicate() return false end
function modifier_imba_necromastery_perm:IsPurgable() return false end
function modifier_imba_necromastery_perm:IsPurgeException() return false end
function modifier_imba_necromastery_perm:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_necromastery_perm:OnCreated()
	if IsServer() then
		local buff = self:GetParent():FindModifierByName("modifier_imba_necromastery_counter")
		buff:SetStackCount(buff:GetStackCount() + 1)
	end
end
function modifier_imba_necromastery_perm:OnDestroy()
	if IsServer() then
		local buff = self:GetParent():FindModifierByName("modifier_imba_necromastery_counter")
		buff:SetStackCount(buff:GetStackCount() - 1)
	end
end
modifier_imba_necromastery_temp = class({})
function modifier_imba_necromastery_temp:IsHidden() return true end
function modifier_imba_necromastery_temp:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_necromastery_temp:AllowIllusionDuplicate() return false end
function modifier_imba_necromastery_temp:IsPurgable() return false end
function modifier_imba_necromastery_temp:IsPurgeException() return false end
function modifier_imba_necromastery_temp:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_necromastery_temp:OnCreated()
	if IsServer() then
		local buff = self:GetParent():FindModifierByName("modifier_imba_necromastery_counter")
		buff:SetStackCount(buff:GetStackCount() + 1)
		if #self:GetParent():FindAllModifiersByName("modifier_imba_necromastery_temp") > self:GetAbility():GetSpecialValueFor("max_temp_soul") then
			self:Destroy()
		end
	end
end
function modifier_imba_necromastery_temp:OnDestroy()
	if IsServer() then
		local buff = self:GetParent():FindModifierByName("modifier_imba_necromastery_counter")
		buff:SetStackCount(buff:GetStackCount() - 1)
	end
end

imba_nevermore_dark_lord = class({})

LinkLuaModifier("modifier_imba_dark_lord_aura", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_dark_lord_debuff", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)

function imba_nevermore_dark_lord:GetCastRange() return self:GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_nevermore_2") - self:GetCaster():GetCastRangeBonus() end
function imba_nevermore_dark_lord:GetIntrinsicModifierName() return "modifier_imba_dark_lord_aura" end

modifier_imba_dark_lord_aura = class({})

function modifier_imba_dark_lord_aura:IsDebuff()			return false end
function modifier_imba_dark_lord_aura:IsHidden() 			return true end
function modifier_imba_dark_lord_aura:IsPurgable() 			return false end
function modifier_imba_dark_lord_aura:IsPurgeException() 	return false end
function modifier_imba_dark_lord_aura:IsAura() return true end
function modifier_imba_dark_lord_aura:GetAuraDuration() return 0.5 end
function modifier_imba_dark_lord_aura:GetModifierAura() return "modifier_imba_dark_lord_debuff" end
function modifier_imba_dark_lord_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_nevermore_2") end
function modifier_imba_dark_lord_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_dark_lord_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_dark_lord_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_imba_dark_lord_debuff = class({})

function modifier_imba_dark_lord_debuff:IsDebuff()			return true end
function modifier_imba_dark_lord_debuff:IsHidden() 			return true end
function modifier_imba_dark_lord_debuff:IsPurgable() 		return false end
function modifier_imba_dark_lord_debuff:IsPurgeException() 	return false end

function modifier_imba_dark_lord_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_dark_lord_debuff:GetModifierPhysicalArmorBonus()
	if self:GetCaster():PassivesDisabled() then
		return nil
	end
	if not IsServer() then
		return nil
	else
		return (0 - self:GetAbility():GetSpecialValueFor("armor_reduction"))
	end
end

function modifier_imba_dark_lord_debuff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("soul_tick_time"))
	end
end

function modifier_imba_dark_lord_debuff:OnIntervalThink()
	local ability = self:GetCaster():FindAbilityByName("imba_nevermore_necromastery")
	if ability and ability:GetLevel() > 0 and self:GetParent():IsHero() and not self:GetCaster():PassivesDisabled() then
		for i=1, self:GetAbility():GetSpecialValueFor("souls_per_tick") do
			self:GetCaster():AddNewModifier(self:GetCaster(), ability, "modifier_imba_necromastery_temp", {duration = ability:GetSpecialValueFor("temp_soul_duration")})
		end
	end
end

imba_nevermore_requiem = class({})

LinkLuaModifier("modifier_imba_requiem_enemy_debuff", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_requiem_caster_scepter", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_requiem_thinker", "hero/hero_nevermore", LUA_MODIFIER_MOTION_NONE)

function imba_nevermore_requiem:IsHiddenWhenStolen() 	return false end
function imba_nevermore_requiem:IsRefreshable() 		return true end
function imba_nevermore_requiem:IsStealable() 			return true end
function imba_nevermore_requiem:IsNetherWardStealable()	return true end
function imba_nevermore_requiem:GetAOERadius() return self:GetSpecialValueFor("radius") end
function imba_nevermore_requiem:GetCastRange()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("radius")
	else
		return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus()
	end
end

function imba_nevermore_requiem:GetBehavior()
	if not self:GetCaster():HasTalent("special_bonus_imba_nevermore_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET 
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
end

function imba_nevermore_requiem:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local cast_pos = caster:GetAbsOrigin()
	if not self:GetCursorTargetingNothing() then
		cast_pos = self:GetCursorPosition()
	end
	self.fx = CreateModifierThinker(self:GetCaster(), self, "modifier_imba_requiem_thinker", {duration = 10.0}, cast_pos, caster:GetTeamNumber(), false)
	local sound_name = "Hero_Nevermore.RequiemOfSoulsCast"
	local pfx_name_2 = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	if HeroItems:UnitHasItem(caster, "shadow_fiend/head_arcana") then
		pfx_name_2 = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls.vpcf"
		sound_name = "Hero_Nevermore.ROS.Arcana.Cast"
	end
	self.fx:EmitSound(sound_name)
	local pfx = ParticleManager:CreateParticle(pfx_name_2, PATTACH_ABSORIGIN_FOLLOW, self.fx)
	ParticleManager:SetParticleControl(pfx, 1, self.fx:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
	return true
end

function imba_nevermore_requiem:OnAbilityPhaseInterrupted()
	StopSoundOn("Hero_Nevermore.RequiemOfSoulsCast", self.fx)
	self.fx:ForceKill(false)
	self.fx = nil
end

function imba_nevermore_requiem:OnSpellStart()
	local caster = self:GetCaster()
	local cast_pos = caster:GetAbsOrigin()
	if not self:GetCursorTargetingNothing() then
		cast_pos = self:GetCursorPosition()
	end
	local buff = caster:FindModifierByName("modifier_imba_necromastery_counter")
	local souls = buff and buff:GetStackCount() or (self:IsStolen() and 46 or 0)
	local lines = IsInToolsMode() and 102 or math.floor(souls / self:GetSpecialValueFor("soul_conversion"))
	local length = self:GetSpecialValueFor("radius")
	local end_pos = cast_pos + caster:GetForwardVector():Normalized() * length
	local speed = self:GetSpecialValueFor("line_speed")
	local arcana = 0
	local pfx_name = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf"
	local pfx_name_2 = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"
	local sound_name = "Hero_Nevermore.RequiemOfSouls"
	if HeroItems:UnitHasItem(caster, "head_arcana") then
		arcana = 1
		pfx_name = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls_line.vpcf"
		pfx_name_2 = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls.vpcf"
		sound_name = "Hero_Nevermore.ROS.Arcana"
	end
	local thinker_sce = CreateModifierThinker(caster, self, "modifier_imba_requiem_thinker", {duration = 5.0}, Vector(0, 0, -1000), caster:GetTeamNumber(), false):entindex()
	EntIndexToHScript(thinker_sce).dmg = 0
	EntIndexToHScript(thinker_sce).steal = {}
	for i=0, lines-1 do
		local pos = GetGroundPosition(RotatePosition(cast_pos, QAngle(0,i * (360 / lines),0), end_pos), nil)
		local direction = (pos - cast_pos):Normalized()
		direction.z = 0
		local duration = length / speed
		local velocity = direction * speed
		local thinker = CreateModifierThinker(caster, self, "modifier_imba_requiem_thinker", {duration = 5.0}, cast_pos, caster:GetTeamNumber(), false):entindex()
		EntIndexToHScript(thinker):SetModel("models/heroes/shadow_fiend/fx_shadow_fiend_arcana_hand.vmdl")
		EntIndexToHScript(thinker).hitted = {}
		if math.floor(i/10) == i/10 then
			EntIndexToHScript(thinker):EmitSound(sound_name)
		end
		local info = 
		{
			Ability = self,
			EffectName = nil,
			vSpawnOrigin = cast_pos,
			fDistance = length,
			fStartRadius = self:GetSpecialValueFor("line_width_start"),
			fEndRadius = self:GetSpecialValueFor("line_width_end"),
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
			iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = true,
			vVelocity = direction * speed,
			bProvidesVision = false,
			ExtraData = {thinker = thinker, go = 1, pos_x = cast_pos.x, pos_y = cast_pos.y, pos_z = cast_pos.z, thinker_sce = thinker_sce, lines = i, total = lines, pfx = arcana}
		}
		ProjectileManager:CreateLinearProjectile(info)
		local particle = true
		if particle then
			local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_WORLDORIGIN, EntIndexToHScript(thinker))
			ParticleManager:SetParticleControl(pfx, 0, cast_pos)
			ParticleManager:SetParticleControl(pfx, 1, velocity)
			ParticleManager:SetParticleControl(pfx, 2, Vector(0,duration,0))
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
	local pfx = ParticleManager:CreateParticle(pfx_name_2, PATTACH_ABSORIGIN_FOLLOW, self.fx)
	ParticleManager:SetParticleControl(pfx, 1, self.fx:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
end

function imba_nevermore_requiem:OnProjectileThink_ExtraData(location, keys)
	if EntIndexToHScript(keys.thinker) then
		local pos = location
		pos.z = pos.z - 1000
		EntIndexToHScript(keys.thinker):SetAbsOrigin(pos)
	end
end

function imba_nevermore_requiem:OnProjectileHit_ExtraData(target, location, keys)
	if keys.go == 1 then
		if not target then
			if self:GetCaster():HasScepter() and keys.thinker_sce and keys.lines == 0 then
				local buff = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_requiem_caster_scepter", {duration = self:GetSpecialValueFor("atk_duration")})
				buff:SetStackCount(EntIndexToHScript(keys.thinker_sce).dmg)
				EntIndexToHScript(keys.thinker_sce).steal = nil
				EntIndexToHScript(keys.thinker_sce):ForceKill(false)
			end
			-------------BACK
			local caster = self:GetCaster()
			local cast_pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
			local length = self:GetSpecialValueFor("radius")
			local speed = self:GetSpecialValueFor("line_speed")
			local direction = (cast_pos - location):Normalized()
			local duration = length / speed
			direction.z = 0
			local velocity = direction * speed
			local i = keys.lines
			local thinker = CreateModifierThinker(caster, self, "modifier_imba_requiem_thinker", {duration = 5.0}, cast_pos, caster:GetTeamNumber(), false):entindex()
			EntIndexToHScript(thinker):SetModel("models/heroes/shadow_fiend/fx_shadow_fiend_arcana_hand.vmdl")
			local pfx_name = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf"
			local sound_name = "Hero_Nevermore.RequiemOfSouls"
			if keys.pfx == 1 then
				pfx_name = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_requiemofsouls_line.vpcf"
				sound_name = "Hero_Nevermore.ROS.Arcana"
			end
			EntIndexToHScript(thinker).hitted = {}
			if math.floor(i/10) == i/10 then
				EntIndexToHScript(thinker):EmitSound(sound_name)
			end
			local info = 
			{
				Ability = self,
				EffectName = nil,
				vSpawnOrigin = location,
				fDistance = length,
				fStartRadius = self:GetSpecialValueFor("line_width_end"),
				fEndRadius = self:GetSpecialValueFor("line_width_start"),
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				fExpireTime = GameRules:GetGameTime() + 10.0,
				bDeleteOnHit = true,
				vVelocity = direction * speed,
				bProvidesVision = false,
				ExtraData = {thinker = thinker, go = 0, lines = i}
			}
			ProjectileManager:CreateLinearProjectile(info)
			local particle = true
			if particle then
				local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_WORLDORIGIN, EntIndexToHScript(thinker))
				ParticleManager:SetParticleControl(pfx, 0, location)
				ParticleManager:SetParticleControl(pfx, 1, velocity)
				ParticleManager:SetParticleControl(pfx, 2, Vector(0,duration,0))
				ParticleManager:ReleaseParticleIndex(pfx)
			end

			-----------
			EntIndexToHScript(keys.thinker).hitted = nil
			EntIndexToHScript(keys.thinker):ForceKill(false)
			return true
		end
		local thinker = EntIndexToHScript(keys.thinker)
		local thinker_ent = keys.thinker
		if IsInTable(target, thinker.hitted) then
			return false
		end
		thinker.hitted[#thinker.hitted+1] = target
		if target:IsTrueHero() and not IsInTable(target, EntIndexToHScript(keys.thinker_sce).steal) then
			EntIndexToHScript(keys.thinker_sce).steal[#EntIndexToHScript(keys.thinker_sce).steal+1] = target
			local cast_pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
			local distance = (cast_pos - target:GetAbsOrigin()):Length2D()
			local dmg = (target:GetBaseDamageMax() + target:GetBaseDamageMin()) / 2
			local dmg_lost = dmg * (self:GetSpecialValueFor("reduction_damage") / 100)
			local dmg_steal_pct = math.min(distance / self:GetSpecialValueFor("radius"), 1.0) * ((self:GetSpecialValueFor("max_atk_gain") / 100) - (self:GetSpecialValueFor("min_atk_gain") / 100)) + (self:GetSpecialValueFor("min_atk_gain") / 100)
			EntIndexToHScript(keys.thinker_sce).dmg = EntIndexToHScript(keys.thinker_sce).dmg + dmg_steal_pct * dmg_lost
			local pfx_screen = ParticleManager:CreateParticleForPlayer("particles/hero/nevermore/screen_requiem_indicator.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, PlayerResource:GetPlayer(target:GetPlayerID()))
			ParticleManager:ReleaseParticleIndex(pfx_screen)
		end
		target:AddNewModifier(self:GetCaster(), self, "modifier_imba_requiem_enemy_debuff", {duration = self:GetSpecialValueFor("slow_duration")})
		local damageTable = {
							victim = target,
							attacker = self:GetCaster(),
							damage = self:GetSpecialValueFor("line_damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
	end
	if keys.go == 0 then
		if not target then
			EntIndexToHScript(keys.thinker).hitted = nil
			EntIndexToHScript(keys.thinker):ForceKill(false)
			return true
		end
		local thinker = EntIndexToHScript(keys.thinker)
		local thinker_ent = keys.thinker
		if IsInTable(target, thinker.hitted) then
			return false
		end
		thinker.hitted[#thinker.hitted + 1] = target
		target:AddNewModifier(self:GetCaster(), self, "modifier_imba_requiem_enemy_debuff", {duration = self:GetSpecialValueFor("slow_duration")})
		local damageTable = {
							victim = target,
							attacker = self:GetCaster(),
							damage = self:GetSpecialValueFor("line_damage"),
							damage_type = self:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
							ability = self, --Optional.
							}
		ApplyDamage(damageTable)
		self:GetCaster():Heal(self:GetSpecialValueFor("line_damage"), self)
	end
end

modifier_imba_requiem_thinker = class({})

modifier_imba_requiem_caster_scepter = class({})

function modifier_imba_requiem_caster_scepter:IsDebuff()			return false end
function modifier_imba_requiem_caster_scepter:IsHidden() 			return false end
function modifier_imba_requiem_caster_scepter:IsPurgable() 			return true end
function modifier_imba_requiem_caster_scepter:IsPurgeException() 	return true end
function modifier_imba_requiem_caster_scepter:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_requiem_caster_scepter:GetModifierPreAttack_BonusDamage() return self:GetStackCount() end

modifier_imba_requiem_enemy_debuff = class({})

function modifier_imba_requiem_enemy_debuff:IsDebuff()			return true end
function modifier_imba_requiem_enemy_debuff:IsHidden() 			return false end
function modifier_imba_requiem_enemy_debuff:IsPurgable() 		return true end
function modifier_imba_requiem_enemy_debuff:IsPurgeException() 	return true end
function modifier_imba_requiem_enemy_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_requiem_enemy_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("reduction_ms")) end
function modifier_imba_requiem_enemy_debuff:GetModifierBaseDamageOutgoing_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("reduction_damage")) end