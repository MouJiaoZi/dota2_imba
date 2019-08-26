CreateEmptyTalents("dark_seer")

function modifier_special_bonus_imba_dark_seer_1:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_special_bonus_imba_dark_seer_1:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and keys.inflictor and keys.inflictor:GetName() == "dark_seer_vacuum" then
		local ability = self:GetParent():FindAbilityByName("dark_seer_ion_shell")
		if ability then
			self:GetParent():SetCursorCastTarget(keys.unit)
			ability:OnSpellStart()
		end
	end
end

imba_dark_seer_wall_of_replica = class({})

LinkLuaModifier("modifier_imba_wall_of_scan_start", "hero/hero_dark_seer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wall_of_scan_end", "hero/hero_dark_seer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wall_of_scan_debuff", "hero/hero_dark_seer", LUA_MODIFIER_MOTION_NONE)

function imba_dark_seer_wall_of_replica:IsHiddenWhenStolen() 	return false end
function imba_dark_seer_wall_of_replica:IsRefreshable() 		return true end
function imba_dark_seer_wall_of_replica:IsStealable() 			return true end
function imba_dark_seer_wall_of_replica:IsNetherWardStealable()	return true end
function imba_dark_seer_wall_of_replica:GetAOERadius()	return self:GetSpecialValueFor("scan_radius") end

function imba_dark_seer_wall_of_replica:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local point_1 = pos + direction * self:GetSpecialValueFor("scan_radius")
	point_1 = RotatePosition(pos, QAngle(0,-90,0), point_1)
	local point_2 = pos - direction * 1
	local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 2.0}, pos, caster:GetTeamNumber(), false)
	sound:EmitSound("Hero_Dark_Seer.Wall_of_Replica_Start")
	-----------------
	local wall_start = CreateModifierThinker(nil, self, "modifier_imba_wall_of_scan_start", {duration = self:GetSpecialValueFor("duration"), center_x = pos.x, center_y = pos.y}, point_1, caster:GetTeamNumber(), false)
	local wall_end = CreateModifierThinker(nil, self, "modifier_imba_wall_of_scan_end", {duration = self:GetSpecialValueFor("duration"), center_x = pos.x, center_y = pos.y, start = wall_start:entindex()}, point_2, caster:GetTeamNumber(), false)
	wall_start:EmitSound("Hero_Dark_Seer.Wall_of_Replica_Start")
end

modifier_imba_wall_of_scan_start = class({})

function modifier_imba_wall_of_scan_start:OnCreated(keys)
	if IsServer() then
		self:GetParent():GiveVisionForBothTeam()
		self.center = Vector(keys.center_x, keys.center_y, 0)
		self.center = GetGroundPosition(self.center, nil)
		self:StartIntervalThink(FrameTime())
		self:GetParent():EmitSound("Hero_Dark_Seer.Wall_of_Replica_lp")
	end
end

function modifier_imba_wall_of_scan_start:OnIntervalThink()
	local pos = self:GetParent():GetAbsOrigin()
	pos.z = self.center.z
	local rorate_speed = self:GetAbility():GetSpecialValueFor("rotate_speed") / (1.0 / FrameTime())
	local new_pos = RotatePosition(self.center, QAngle(0, rorate_speed, 0), pos)
	self:GetParent():SetOrigin(new_pos)
end

function modifier_imba_wall_of_scan_start:OnDestroy()
	if IsServer() then
		self:GetParent():StopSound("Hero_Dark_Seer.Wall_of_Replica_lp")
	end
end

modifier_imba_wall_of_scan_end = class({})

function modifier_imba_wall_of_scan_end:OnCreated(keys)
	if IsServer() then
		self:GetParent():GiveVisionForBothTeam()
		self.ability = self:GetAbility():GetCaster():FindAbilityByName("dark_seer_ion_shell")
		self.caster = self:GetAbility():GetCaster()
		self.head = EntIndexToHScript(keys.start)
		self.center = Vector(keys.center_x, keys.center_y, 0)
		self.center = GetGroundPosition(self.center, nil)
		self.parent = self:GetParent()
		self.pfx = ParticleManager:CreateParticle("particles/hero/dark_seer/dark_seer_wall_of_replica.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(self.pfx, 0, self.head:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.pfx, 1, self.parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(self.pfx, 2, Vector(0.5, 0.5, 0))
		self:AddParticle(self.pfx, false, false, 15, false, false)
		self:StartIntervalThink(FrameTime())
		self:GetParent():EmitSound("Hero_Dark_Seer.Wall_of_Replica_lp")
	end
end

function modifier_imba_wall_of_scan_end:OnIntervalThink()
	if not self.head or self.head:IsNull() then
		return
	end
	local pos = self:GetParent():GetAbsOrigin()
	pos.z = self.center.z
	local rorate_speed = self:GetAbility():GetSpecialValueFor("rotate_speed") / (1.0 / FrameTime())
	local new_pos = RotatePosition(self.center, QAngle(0, rorate_speed, 0), pos)
	local caster = self.caster
	self:GetParent():SetOrigin(new_pos)
	local length = (self.head:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
	local direction = (self.head:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local enemy = FindUnitsInLine(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), self.head:GetAbsOrigin(), nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS)
	for i=1, #enemy do
		if not IsNearEnemyFountain(enemy[i]:GetAbsOrigin(), caster:GetTeamNumber(), 1600) then
			enemy[i]:AddNewModifier(caster, self:GetAbility(), "modifier_imba_wall_of_scan_debuff", {duration = self:GetAbility():GetSpecialValueFor("scan_duration")})
			AddFOWViewer(caster:GetTeamNumber(), enemy[i]:GetAbsOrigin(), self:GetAbility():GetSpecialValueFor("fow_range"), FrameTime() * 2, false)
			if caster:HasScepter() then
				local ability = self.ability
				if ability and ability:GetLevel() > 0 then
					if not enemy[i]:FindModifierByNameAndCaster("modifier_dark_seer_ion_shell", caster) then
						enemy[i]:AddNewModifier(caster, ability, "modifier_dark_seer_ion_shell", {duration = self:GetAbility():GetSpecialValueFor("ion_duration_scepter")})
					else
						if enemy[i]:HasModifier("modifier_dark_seer_ion_shell") then
							local buff = enemy[i]:FindModifierByName("modifier_dark_seer_ion_shell")
							if buff:GetRemainingTime() < self:GetAbility():GetSpecialValueFor("ion_duration_scepter") then
								buff:SetDuration(self:GetAbility():GetSpecialValueFor("ion_duration_scepter"), true)
							end
						end
					end
				end
			end
		end
	end
	AddFOWViewer(caster:GetTeamNumber(), self:GetParent():GetAbsOrigin(), 10, FrameTime() * 2, true)
	ParticleManager:SetParticleControl(self.pfx, 0, self.head:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.pfx, 1, self.parent:GetAbsOrigin())
	--DebugDrawLine(self.head:GetAbsOrigin(), self:GetParent():GetAbsOrigin(), 0, 33, 255, true, FrameTime())
end

function modifier_imba_wall_of_scan_end:OnDestroy()
	if IsServer() then
		self.head = nil
		self.center = nil
		self.ability = nil
		self.caster = nil
		self.parent = nil
		self.pfx = nil
		self:GetParent():StopSound("Hero_Dark_Seer.Wall_of_Replica_lp")
	end
end

modifier_imba_wall_of_scan_debuff = class({})

function modifier_imba_wall_of_scan_debuff:IsDebuff()			return true end
function modifier_imba_wall_of_scan_debuff:IsHidden() 			return false end
function modifier_imba_wall_of_scan_debuff:IsPurgable() 		return true end
function modifier_imba_wall_of_scan_debuff:IsPurgeException() 	return true end
function modifier_imba_wall_of_scan_debuff:DeclareFunctions()	return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_imba_wall_of_scan_debuff:GetModifierProvidesFOWVision() return 1 end
function modifier_imba_wall_of_scan_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_dark_seer_illusion.vpcf" end
function modifier_imba_wall_of_scan_debuff:StatusEffectPriority() return 15 end
function modifier_imba_wall_of_scan_debuff:GetModifierMoveSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("ms_slow")) end