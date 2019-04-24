CreateEmptyTalents("puck")

imba_puck_dream_coil = class({})

LinkLuaModifier("modifier_imba_dream_coil_thinker", "hero/hero_puck.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_dream_coil_range", "hero/hero_puck.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_dream_coil_enemy", "hero/hero_puck.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_dream_coil_caster", "hero/hero_puck.lua", LUA_MODIFIER_MOTION_NONE)

function imba_puck_dream_coil:IsHiddenWhenStolen() 		return false end
function imba_puck_dream_coil:IsRefreshable() 			return true end
function imba_puck_dream_coil:IsStealable() 			return true end
function imba_puck_dream_coil:IsNetherWardStealable()	return true end
function imba_puck_dream_coil:GetAOERadius()			return self:GetSpecialValueFor("radius") end

function imba_puck_dream_coil:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local duration = caster:HasScepter() and self:GetSpecialValueFor("coil_duration_scepter") or self:GetSpecialValueFor("coil_duration")
	local thinker = CreateModifierThinker(caster, self, "modifier_imba_dream_coil_thinker", {duration = duration}, pos, caster:GetTeamNumber(), false)
	caster:AddNewModifier(thinker, self, "modifier_imba_dream_coil_caster", {duration = duration})
end

modifier_imba_dream_coil_thinker = class({})

function modifier_imba_dream_coil_thinker:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Puck.Dream_Coil")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(pfx, false, false, 15, false, false)
		local direction = self:GetParent():GetForwardVector()
		direction.z = 0
		local pos = self:GetParent():GetAbsOrigin() + direction * self:GetAbility():GetSpecialValueFor("radius")
		self.range = {}
		for i=1, 4 do
			local range_pos = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, 90 * i, 0), pos)
			self.range[i] = CreateModifierThinker(nil, self:GetAbility(), "modifier_imba_dream_coil_range", {}, range_pos, self:GetCaster():GetTeamNumber(), false)
			self.range[i]:GiveVisionForBothTeam()
		end
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_dream_coil_thinker:OnIntervalThink()
	local direction = self:GetParent():GetForwardVector()
	direction.z = 0
	local pos = self:GetParent():GetAbsOrigin() + direction * self:GetAbility():GetSpecialValueFor("radius")
	local new_pos = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, 5, 0), pos)
	local new_direction = (new_pos - self:GetParent():GetAbsOrigin()):Normalized()
	new_direction.z = 0
	for i=1, 4 do
		local range_pos = RotatePosition(self:GetParent():GetAbsOrigin(), QAngle(0, 90 * i, 0), new_pos)
		range_pos = GetGroundPosition(range_pos, nil)
		range_pos.z = range_pos.z + 128
		self.range[i]:SetAbsOrigin(range_pos)
	end
	self:GetParent():SetForwardVector(new_direction)
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		if not enemy[i]:FindModifierByNameAndCaster("modifier_imba_dream_coil_enemy", self:GetParent()) and self:GetParent():IsAlive() then
			enemy[i]:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = ability:GetSpecialValueFor("stun_duration")})
			enemy[i]:AddNewModifier(self:GetParent(), ability, "modifier_imba_dream_coil_enemy", {duration = self:GetRemainingTime()})
		end
	end
end

function modifier_imba_dream_coil_thinker:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Puck.Dream_Coil")
		for i=1, 4 do
			self.range[i]:ForceKill(false)
		end
		self.range = nil
	end
end

modifier_imba_dream_coil_range = class({})

function modifier_imba_dream_coil_range:OnCreated()
	if IsServer() then
		--self:StartIntervalThink(FrameTime())
		local pfx = ParticleManager:CreateParticle("particles/hero/puck/puck_dreamcoil_range.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_dream_coil_range:OnIntervalThink()
	DebugDrawCircle(self:GetParent():GetAbsOrigin(), Vector(255, 0, 0), 100, 50, true, FrameTime())
end

modifier_imba_dream_coil_enemy = class({})

function modifier_imba_dream_coil_enemy:IsDebuff()			return false end
function modifier_imba_dream_coil_enemy:IsHidden() 			return true end
function modifier_imba_dream_coil_enemy:IsPurgable() 		return false end
function modifier_imba_dream_coil_enemy:IsPurgeException() 	return false end
function modifier_imba_dream_coil_enemy:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_dream_coil_enemy:CheckState() return {[MODIFIER_STATE_TETHERED] = true} end

function modifier_imba_dream_coil_enemy:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_puck/puck_dreamcoil_tether.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetCaster():GetAbsOrigin())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_dream_coil_enemy:OnIntervalThink()
	if not self:GetCaster() then
		return
	end
	local ability = self:GetAbility()
	local caster = ability:GetCaster()
	local distance = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Length2D()
	if distance > ability:GetSpecialValueFor("radius") + 50 and not (self:GetParent():IsMagicImmune() and not caster:HasScepter()) then
		self:SetStackCount(1)
		self:Destroy()
	end
end

function modifier_imba_dream_coil_enemy:OnDestroy()
	if IsServer() then
		self:GetParent():EmitSound("Hero_Puck.Dream_Coil_Snap")
		if self:GetStackCount() == 1 then
			local ability = self:GetAbility()
			local caster = ability:GetCaster()
			local target = self:GetParent()
			ApplyDamage({attacker = caster, victim = target, damage = (caster:HasScepter() and ability:GetSpecialValueFor("coil_break_damage_scepter") or ability:GetSpecialValueFor("coil_break_damage")), ability = ability, damage_type = ability:GetAbilityDamageType()})
			target:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = (caster:HasScepter() and ability:GetSpecialValueFor("coil_stun_duration_scepter") or ability:GetSpecialValueFor("coil_stun_duration"))})
		end
	end
end

modifier_imba_dream_coil_caster = class({})

function modifier_imba_dream_coil_caster:IsDebuff()			return false end
function modifier_imba_dream_coil_caster:IsHidden() 		return true end
function modifier_imba_dream_coil_caster:IsPurgable() 		return false end
function modifier_imba_dream_coil_caster:IsPurgeException() return false end
function modifier_imba_dream_coil_caster:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_dream_coil_caster:RemoveOnDeath() return false end
function modifier_imba_dream_coil_caster:AllowIllusionDuplicate() return false end

function modifier_imba_dream_coil_caster:OnCreated(keys)
	if IsServer() then
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("attack_interval"))
	end
end

function modifier_imba_dream_coil_caster:OnIntervalThink()
	local thinker = self:GetCaster()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	if not ability:GetAutoCastState() then
		local enemy = FindUnitsInRadius(caster:GetTeamNumber(), thinker:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for i=1, #enemy do
			if enemy[i]:FindModifierByNameAndCaster("modifier_imba_dream_coil_enemy", thinker) then
				caster:PerformAttack(enemy[i], false, true, true, false, true, false, true)
			end
		end
	end
end