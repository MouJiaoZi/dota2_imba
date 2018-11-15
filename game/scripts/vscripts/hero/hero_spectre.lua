CreateEmptyTalents("spectre")


imba_spectre_spectral_dagger = class({})

LinkLuaModifier("modifier_imba_spectral_dagger_ms", "hero/hero_spectre", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spectral_dagger_illusion", "hero/hero_spectre", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spectral_dagger_thinker", "hero/hero_spectre", LUA_MODIFIER_MOTION_NONE)

function imba_spectre_spectral_dagger:IsHiddenWhenStolen() 		return false end
function imba_spectre_spectral_dagger:IsRefreshable() 			return true end
function imba_spectre_spectral_dagger:IsStealable() 			return true end
function imba_spectre_spectral_dagger:IsNetherWardStealable()	return false end
function imba_spectre_spectral_dagger:GetCooldown(i) return (self:GetSpecialValueFor("cd") + self:GetCaster():GetTalentValue("special_bonus_imba_spectre_1")) end

function imba_spectre_spectral_dagger:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin() + (self:GetCursorPosition() - caster:GetAbsOrigin()):Normalized() * (self:GetCastRange(Vector(0,0,0), caster) + caster:GetCastRangeBonus())
	local illusion = IllusionManager:CreateIllusion(caster, caster:GetAbsOrigin() + caster:GetForwardVector() * 100, nil, 0, 0, 0, self:GetSpecialValueFor("dagger_path_duration"), caster, nil)
	local target = self:GetCursorTarget()
	local table = {}
	if target then
		table = {move = target:entindex()}
	end
	illusion:EmitSound("Hero_Spectre.DaggerCast")
	illusion:AddNewModifier(caster, self, "modifier_imba_spectral_dagger_illusion", table)
	illusion:SetHullRadius(1.0)
	local newOrder = {
 		UnitIndex = illusion:entindex(), 
 		OrderType = (target and DOTA_UNIT_ORDER_MOVE_TO_TARGET or DOTA_UNIT_ORDER_MOVE_TO_POSITION),
 		TargetIndex = (target and target:entindex() or nil),
 		Position = (not target and pos or nil),
 	}
 	Timers:CreateTimer(FrameTime()*2, function()
		ExecuteOrderFromTable(newOrder)
		return nil
	end
	)
end

modifier_imba_spectral_dagger_illusion = class({})

function modifier_imba_spectral_dagger_illusion:IsDebuff()			return false end
function modifier_imba_spectral_dagger_illusion:IsHidden() 			return true end
function modifier_imba_spectral_dagger_illusion:IsPurgable() 		return false end
function modifier_imba_spectral_dagger_illusion:IsPurgeException() 	return false end
function modifier_imba_spectral_dagger_illusion:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_spectral_dagger_illusion:DeclareFunctions() return {MODIFIER_PROPERTY_FIXED_DAY_VISION, MODIFIER_PROPERTY_FIXED_NIGHT_VISION, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE, MODIFIER_PROPERTY_MOVESPEED_MAX, MODIFIER_EVENT_ON_ORDER} end
function modifier_imba_spectral_dagger_illusion:GetFixedDayVision() return self:GetAbility():GetSpecialValueFor("vision_radius") end
function modifier_imba_spectral_dagger_illusion:GetFixedNightVision() return self:GetAbility():GetSpecialValueFor("vision_radius") end
function modifier_imba_spectral_dagger_illusion:GetModifierMoveSpeed_Absolute() return self:GetAbility():GetSpecialValueFor("speed") end
function modifier_imba_spectral_dagger_illusion:GetModifierMoveSpeed_Max() return self:GetAbility():GetSpecialValueFor("speed") end

function modifier_imba_spectral_dagger_illusion:OnOrder(keys)
	if not IsServer() or keys.unit ~= self:GetParent() then
		return
	end
	if keys.target and keys.target == self.move then
		--nothing
	else
		self.move = nil
	end
end

function modifier_imba_spectral_dagger_illusion:OnCreated(keys)
	if IsServer() then
		self.move = (keys.move and EntIndexToHScript(keys.move) or nil)
		self.pfx = ParticleManager:CreateParticle("particles/hero/spectre/spectre_shadow_path.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("dagger_path_duration"),0,0))
		self:StartIntervalThink(0.1)
		self.hitted = {}
		CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_spectral_dagger_thinker", {duration = self:GetAbility():GetSpecialValueFor("dagger_path_duration")}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
	end
end

function modifier_imba_spectral_dagger_illusion:OnIntervalThink()
	ParticleManager:SetParticleControl(self.pfx, 0, GetRandomPosition2D(self:GetParent():GetAbsOrigin(), 3.0))
	CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_spectral_dagger_thinker", {duration = self:GetAbility():GetSpecialValueFor("dagger_path_duration")}, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("dagger_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not IsInTable(enemy, self.hitted) then
			if enemy == self.move then
				self.move = nil
			end
			table.insert(self.hitted, enemy)
			enemy:EmitSound("Hero_Spectre.DaggerImpact")
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = self:GetAbility():GetAbilityDamageType()})
		end
	end
	if self.move then
		AddFOWViewer(self:GetCaster():GetTeamNumber(), self.move:GetAbsOrigin(), self:GetAbility():GetSpecialValueFor('vision_radius'), FrameTime(), false)
	end
end

function modifier_imba_spectral_dagger_illusion:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.move = nil
		self.pfx = nil
		self.hitted = nil
	end
end

modifier_imba_spectral_dagger_thinker = class({})

function modifier_imba_spectral_dagger_thinker:IsAura() return true end
function modifier_imba_spectral_dagger_thinker:GetAuraDuration() return self:GetAbility():GetSpecialValueFor("buff_persistence") end
function modifier_imba_spectral_dagger_thinker:GetModifierAura() return "modifier_imba_spectral_dagger_ms" end
function modifier_imba_spectral_dagger_thinker:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("dagger_radius") end
function modifier_imba_spectral_dagger_thinker:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES end
function modifier_imba_spectral_dagger_thinker:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY + DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_spectral_dagger_thinker:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_spectral_dagger_thinker:GetAuraEntityReject(unit)
	if unit ~= self:GetCaster() and not IsEnemy(unit, self:GetCaster()) then
		return true
	end
	return false
end

modifier_imba_spectral_dagger_ms = class({})

function modifier_imba_spectral_dagger_ms:IsDebuff()			return IsEnemy(self:GetCaster(), self:GetParent()) end
function modifier_imba_spectral_dagger_ms:IsHidden() 			return false end
function modifier_imba_spectral_dagger_ms:IsPurgable() 			return false end
function modifier_imba_spectral_dagger_ms:IsPurgeException() 	return false end
function modifier_imba_spectral_dagger_ms:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_spectral_dagger_ms:GetModifierMoveSpeedBonus_Percentage()
	if self:IsDebuff() then
		return (0 - self:GetAbility():GetSpecialValueFor("bonus_movespeed") - self:GetCaster():GetTalentValue("special_bonus_imba_spectre_2"))
	else
		return (0 + self:GetAbility():GetSpecialValueFor("bonus_movespeed") + self:GetCaster():GetTalentValue("special_bonus_imba_spectre_2"))
	end
end
function modifier_imba_spectral_dagger_ms:CheckState()
	if self:GetCaster() == self:GetParent() then
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
end

function modifier_imba_spectral_dagger_thinker:OnCreated()
	self:SetDuration(self:GetDuration(), true)
	if IsServer() then
		
	end
end