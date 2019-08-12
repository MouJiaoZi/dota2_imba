CreateEmptyTalents("tusk")

imba_tusk_walrus_kick = class({})

LinkLuaModifier("modifier_imba_walrus_kick_scepter", "hero/hero_tusk.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_walrus_kick_motion", "hero/hero_tusk.lua", LUA_MODIFIER_MOTION_NONE)

function imba_tusk_walrus_kick:IsHiddenWhenStolen() 	return false end
function imba_tusk_walrus_kick:IsRefreshable() 			return true end
function imba_tusk_walrus_kick:IsStealable() 			return false end
function imba_tusk_walrus_kick:IsNetherWardStealable()	return false end
function imba_tusk_walrus_kick:IsTalentAbility() return true end
function imba_tusk_walrus_kick:GetIntrinsicModifierName() return "modifier_imba_walrus_kick_scepter" end

function imba_tusk_walrus_kick:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Tusk.WalrusPunch.Cast")
	return true
end

function imba_tusk_walrus_kick:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound("Hero_Tusk.WalrusPunch.Cast")
end

function imba_tusk_walrus_kick:OnSpellStart()
	local caster = self:GetCaster()
	caster:StopSound("Hero_Tusk.WalrusPunch.Cast")
	caster:EmitSound("Hero_Tusk.WalrusPunch.Damage")
	local pos = self:GetCursorPosition()
	local duration = (pos - caster:GetAbsOrigin()):Length2D() / self:GetSpecialValueFor("kick_speed")
	caster:AddNewModifier(caster, self, "modifier_imba_walrus_kick_motion", {duration = duration, pos = pos})
end

modifier_imba_walrus_kick_scepter = class({})

function modifier_imba_walrus_kick_scepter:IsDebuff()			return false end
function modifier_imba_walrus_kick_scepter:IsHidden() 			return true end
function modifier_imba_walrus_kick_scepter:IsPurgable() 		return false end
function modifier_imba_walrus_kick_scepter:IsPurgeException() 	return false end

function modifier_imba_walrus_kick_scepter:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_walrus_kick_scepter:OnIntervalThink() self:GetAbility():SetHidden(not self:GetParent():HasScepter()) end

modifier_imba_walrus_kick_motion = class({})

function modifier_imba_walrus_kick_motion:IsDebuff()			return false end
function modifier_imba_walrus_kick_motion:IsHidden() 			return true end
function modifier_imba_walrus_kick_motion:IsPurgable() 			return false end
function modifier_imba_walrus_kick_motion:IsPurgeException() 	return false end
function modifier_imba_walrus_kick_motion:IsMotionController()	return true end
function modifier_imba_walrus_kick_motion:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_walrus_kick_motion:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH end
function modifier_imba_walrus_kick_motion:GetEffectName() return "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf" end
function modifier_imba_walrus_kick_motion:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_walrus_kick_motion:OnCreated(keys)
	if IsServer() then
		if self:CheckMotionControllers() then
			self.hitted = {}
			self.pos = StringToVector(keys.pos)
			self.direction = GetDirection2D(self.pos, self:GetParent():GetAbsOrigin())
			self.parent = self:GetParent()
			self.ability = self:GetAbility()
			self.distance = self.ability:GetSpecialValueFor("kick_speed") / (1.0 / FrameTime())
			self.height = 0
			self.punch = self.parent:FindAbilityByName("tusk_walrus_punch")
			if not self.punch or self.punch:GetLevel() <= 0 then
				self.punch = nil
			end
			self:StartIntervalThink(FrameTime())
		end
	end
end

function modifier_imba_walrus_kick_motion:OnIntervalThink()
	if self.punch then
		local enemy = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
		for i=1, #enemy do
			if not self.hitted[enemy[i]:entindex()] then
				self.hitted[enemy[i]:entindex()] = true
				local cd = self.punch:GetCooldownTimeRemaining()
				local atc = self.punch:GetAutoCastState()
				self.punch:EndCooldown()
				if not atc then
					self.punch:ToggleAutoCast()
				end
				self.parent:PerformAttack(enemy[i], true, true, true, false, false, false, true)
				self.punch:RefundManaCost()
				self.punch:EndCooldown()
				if cd > 0 then
					self.punch:StartCooldown(cd)
				end
				if not atc then
					self.punch:ToggleAutoCast()
				end
			end
		end
	end
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local next_pos = GetGroundPosition(self.parent:GetAbsOrigin() + self.direction * self.distance, self.parent)
	next_pos.z = next_pos.z - 4 * self.height * motion_progress ^ 2 + 4 * self.height * motion_progress
	self.parent:SetOrigin(next_pos)
end

function modifier_imba_walrus_kick_motion:OnDestroy()
	if IsServer() then
		self.hitted = nil
		self.pos = nil
		self.direction = nil
		self.parent = nil
		self.ability = nil
		self.distance = nil
		self.height = nil
		self.punch = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end