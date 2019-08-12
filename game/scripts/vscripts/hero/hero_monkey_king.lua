CreateEmptyTalents("monkey_king")

imba_monkey_king_wukongs_command = class({})

LinkLuaModifier("modifier_imba_wukongs_command_mk_spawn_first", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_spawn_second", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_spawn_third", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_hidden", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_skin", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_status", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_move", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_active", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_lifetime", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_wukongs_command_mk_disarm", "hero/hero_monkey_king.lua", LUA_MODIFIER_MOTION_NONE)

function imba_monkey_king_wukongs_command:IsHiddenWhenStolen() 		return false end
function imba_monkey_king_wukongs_command:IsRefreshable() 			return true end
function imba_monkey_king_wukongs_command:IsStealable() 			return true end
function imba_monkey_king_wukongs_command:IsNetherWardStealable()	return false end
function imba_monkey_king_wukongs_command:GetAOERadius() return self:GetCaster():HasTalent("special_bonus_imba_monkey_king_1") and self:GetSpecialValueFor("third_radius") or self:GetSpecialValueFor("second_radius") end
function imba_monkey_king_wukongs_command:GetCastRange() return self:GetCaster():HasTalent("special_bonus_imba_monkey_king_1") and self:GetSpecialValueFor("cast_range_talent") or self:GetSpecialValueFor("cast_range") end

local mk_first_pos = {}
mk_first_pos[1] = Vector(0.000000, 300.000000, 0.000000)
mk_first_pos[2] = Vector(-285.316956, 92.705093, 0.000000)
mk_first_pos[3] = Vector(-176.335556, -242.705124, 0.000000)
mk_first_pos[4] = Vector(176.335541, -242.705124, 0.000000)
mk_first_pos[5] = Vector(285.316956, 92.705139, 0.000000)
local mk_second_pos = {}
mk_second_pos[1] = Vector(0.000000, 750.000000, 0.000000)
mk_second_pos[2] = Vector(-482.090668, 574.533325, 0.000000)
mk_second_pos[3] = Vector(-738.605774, 130.236160, 0.000000)
mk_second_pos[4] = Vector(-649.519043, -375.000031, 0.000000)
mk_second_pos[5] = Vector(-256.515167, -704.769470, 0.000000)
mk_second_pos[6] = Vector(256.515106, -704.769470, 0.000000)
mk_second_pos[7] = Vector(649.519104, -374.999939, 0.000000)
mk_second_pos[8] = Vector(738.605774, 130.236115, 0.000000)
mk_second_pos[9] = Vector(482.090820, 574.533264, 0.000000)
local mk_third_pos = {}
mk_third_pos[1] = Vector(0.000000, 1100.000000, 0.000000)
mk_third_pos[2] = Vector(-860.014587, 685.838867, 0.000000)
mk_third_pos[3] = Vector(-1072.420776, -244.772919, 0.000000)
mk_third_pos[4] = Vector(-477.271973, -991.065796, 0.000000)
mk_third_pos[5] = Vector(477.271912, -991.065857, 0.000000)
mk_third_pos[6] = Vector(1072.420654, -244.773102, 0.000000)
mk_third_pos[7] = Vector(860.014465, 685.839050, 0.000000)

function imba_monkey_king_wukongs_command:OnHeroLevelUp()
	if not self:GetCaster():IsRealHero() then
		return
	end
	local caster = self:GetCaster()
	if not self.mk_first then
		self.mk_first = {}
		for i=1, 5 do
			CreateModifierThinker(caster, self, "modifier_imba_wukongs_command_mk_spawn_first", {duration = RandomFloat(0.1, 2.1) * i, i = i}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
		end
	end
	if not self.mk_second then
		self.mk_second = {}
		for i=1, 9 do
			CreateModifierThinker(caster, self, "modifier_imba_wukongs_command_mk_spawn_second", {duration = RandomFloat(0.1, 2.1) * i, i = i}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
		end
	end
	if not self.mk_third then
		self.mk_third = {}
		for i=1, 7 do
			CreateModifierThinker(caster, self, "modifier_imba_wukongs_command_mk_spawn_third", {duration = RandomFloat(0.1, 2.1) * i, i = i}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
		end
	end
end

function imba_monkey_king_wukongs_command:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_MonkeyKing.FurArmy.Channel")
	local direction = GetDirection2D(self:GetCursorPosition(), caster:GetAbsOrigin())
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_monkey_king/monkey_king_fur_army_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlForward(self.pfx, 0, direction)
	return true
end

function imba_monkey_king_wukongs_command:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:StopSound("Hero_MonkeyKing.FurArmy.Channel")
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function imba_monkey_king_wukongs_command:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	caster:StopSound("Hero_MonkeyKing.FurArmy.Channel")
	for i=1, 5 do
		if self.mk_first and self.mk_first[i] then
			self.mk_first[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_hidden", {})
			self.mk_first[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_hidden")
			self.mk_first[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_lifetime")
			self.mk_first[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_move")
			self.mk_first[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_active")
			self.mk_first[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_skin")
			self.mk_first[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_lifetime", {duration = self:GetSpecialValueFor("duration")})
			self.mk_first[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_move", {pos = pos + mk_first_pos[i], duration = 3.0})
			self.mk_first[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_skin", {})
		end
	end
	for i=1, 9 do
		if self.mk_second and self.mk_second[i] then
			self.mk_second[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_hidden", {})
			self.mk_second[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_hidden")
			self.mk_second[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_lifetime")
			self.mk_second[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_move")
			self.mk_second[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_active")
			self.mk_second[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_skin")
			self.mk_second[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_lifetime", {duration = self:GetSpecialValueFor("duration")})
			self.mk_second[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_move", {pos = pos + mk_second_pos[i], duration = 3.0})
			self.mk_second[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_skin", {})
		end
	end
	if caster:HasTalent("special_bonus_imba_monkey_king_1") then
		for i=1, 7 do
			if self.mk_third and self.mk_third[i] then
				self.mk_third[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_hidden", {})
				self.mk_third[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_hidden")
				self.mk_third[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_lifetime")
				self.mk_third[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_move")
				self.mk_third[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_active")
				self.mk_third[i]:RemoveModifierByName("modifier_imba_wukongs_command_mk_skin")
				self.mk_third[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_lifetime", {duration = self:GetSpecialValueFor("duration")})
				self.mk_third[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_move", {pos = pos + mk_third_pos[i], duration = 3.0})
				self.mk_third[i]:AddNewModifier(caster, self, "modifier_imba_wukongs_command_mk_skin", {})
			end
		end
	end
end

-----------------------------------
-----------------------------------
-----------------------------------
-----------------------------------

modifier_imba_wukongs_command_mk_spawn_first = class({})
function modifier_imba_wukongs_command_mk_spawn_first:OnCreated(keys) if IsServer() then self:SetStackCount(keys.i) end end
function modifier_imba_wukongs_command_mk_spawn_first:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability.mk_first[self:GetStackCount()] then
			ability.mk_first[self:GetStackCount()] = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
			ability.mk_first[self:GetStackCount()]:AddNewModifier(caster, ability, "modifier_imba_wukongs_command_mk_hidden", {})
		end
	end
end
modifier_imba_wukongs_command_mk_spawn_second = class({})
function modifier_imba_wukongs_command_mk_spawn_second:OnCreated(keys) if IsServer() then self:SetStackCount(keys.i) end end
function modifier_imba_wukongs_command_mk_spawn_second:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability.mk_second[self:GetStackCount()] then
			ability.mk_second[self:GetStackCount()] = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
			ability.mk_second[self:GetStackCount()]:AddNewModifier(caster, ability, "modifier_imba_wukongs_command_mk_hidden", {})
		end
	end
end
modifier_imba_wukongs_command_mk_spawn_third = class({})
function modifier_imba_wukongs_command_mk_spawn_third:OnCreated(keys) if IsServer() then self:SetStackCount(keys.i) end end
function modifier_imba_wukongs_command_mk_spawn_third:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		if not ability.mk_third[self:GetStackCount()] then
			ability.mk_third[self:GetStackCount()] = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
			ability.mk_third[self:GetStackCount()]:AddNewModifier(caster, ability, "modifier_imba_wukongs_command_mk_hidden", {})
		end
	end
end


modifier_imba_wukongs_command_mk_hidden = class({})

function modifier_imba_wukongs_command_mk_hidden:IsDebuff()			return false end
function modifier_imba_wukongs_command_mk_hidden:IsHidden() 		return true end
function modifier_imba_wukongs_command_mk_hidden:IsPurgable() 		return false end
function modifier_imba_wukongs_command_mk_hidden:IsPurgeException() return false end
function modifier_imba_wukongs_command_mk_hidden:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_wukongs_command_mk_hidden:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE} end
function modifier_imba_wukongs_command_mk_hidden:GetAbsoluteNoDamageMagical() return 1 end
function modifier_imba_wukongs_command_mk_hidden:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_imba_wukongs_command_mk_hidden:GetAbsoluteNoDamagePure() return 1 end

function modifier_imba_wukongs_command_mk_hidden:OnCreated()
	if IsServer() then
		local mk = self:GetParent()
		mk:SetAbsOrigin(Vector(30000, 0, 0))
		mk:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_wukongs_command_mk_status", {})
		for i=0,23 do
			local ability = mk:GetAbilityByIndex(i)
			if ability then
				mk:RemoveAbility(ability:GetAbilityName())
			end
		end
	end
end

function modifier_imba_wukongs_command_mk_hidden:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetCaster():GetAbsOrigin(), true)
		self:GetParent():RemoveNoDraw()
	end
end

modifier_imba_wukongs_command_mk_skin = class({})

function modifier_imba_wukongs_command_mk_skin:IsDebuff()			return false end
function modifier_imba_wukongs_command_mk_skin:IsHidden() 			return true end
function modifier_imba_wukongs_command_mk_skin:IsPurgable() 		return false end
function modifier_imba_wukongs_command_mk_skin:IsPurgeException()	return false end
function modifier_imba_wukongs_command_mk_skin:GetStatusEffectName() return "particles/status_fx/status_effect_monkey_king_fur_army.vpcf" end
function modifier_imba_wukongs_command_mk_skin:StatusEffectPriority() return 100 end

modifier_imba_wukongs_command_mk_status = class({})

function modifier_imba_wukongs_command_mk_status:IsDebuff()			return false end
function modifier_imba_wukongs_command_mk_status:IsHidden() 		return true end
function modifier_imba_wukongs_command_mk_status:IsPurgable() 		return false end
function modifier_imba_wukongs_command_mk_status:IsPurgeException() return false end
function modifier_imba_wukongs_command_mk_status:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_wukongs_command_mk_status:DeclareFunctions() return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE} end
function modifier_imba_wukongs_command_mk_status:GetAbsoluteNoDamageMagical() return 1 end
function modifier_imba_wukongs_command_mk_status:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_imba_wukongs_command_mk_status:GetAbsoluteNoDamagePure() return 1 end

modifier_imba_wukongs_command_mk_move = class({})

function modifier_imba_wukongs_command_mk_move:IsDebuff()			return false end
function modifier_imba_wukongs_command_mk_move:IsHidden() 			return true end
function modifier_imba_wukongs_command_mk_move:IsPurgable() 		return false end
function modifier_imba_wukongs_command_mk_move:IsPurgeException()	return false end
function modifier_imba_wukongs_command_mk_move:CheckState() return {[MODIFIER_STATE_DISARMED] = true} end
function modifier_imba_wukongs_command_mk_move:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX} end
function modifier_imba_wukongs_command_mk_move:GetModifierMoveSpeed_AbsoluteMax() return self:GetAbility():GetSpecialValueFor("move_speed") end

function modifier_imba_wukongs_command_mk_move:OnCreated(keys)
	if IsServer() then
		self.pos = StringToVector(keys.pos)
		self:GetParent():MoveToPosition(self.pos)
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_wukongs_command_mk_move:OnIntervalThink()
	if (self:GetParent():GetAbsOrigin() - self.pos):Length2D() <= 10 then
		self:Destroy()
	end
end

function modifier_imba_wukongs_command_mk_move:OnDestroy()
	if IsServer() then
		self:GetParent():SetAbsOrigin(GetGroundPosition(self.pos, self:GetParent()))
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_wukongs_command_mk_active", {})
		self.pos = nil
	end
end

modifier_imba_wukongs_command_mk_active = class({})

function modifier_imba_wukongs_command_mk_active:IsDebuff()			return false end
function modifier_imba_wukongs_command_mk_active:IsHidden() 		return true end
function modifier_imba_wukongs_command_mk_active:IsPurgable() 		return false end
function modifier_imba_wukongs_command_mk_active:IsPurgeException()	return false end
function modifier_imba_wukongs_command_mk_active:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end
function modifier_imba_wukongs_command_mk_active:DeclareFunctions() return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_ATTACK_FAIL, MODIFIER_EVENT_ON_ATTACK_RECORD} end
function modifier_imba_wukongs_command_mk_active:GetActivityTranslationModifiers() return "fur_army_soldier" end
function modifier_imba_wukongs_command_mk_active:GetModifierAttackSpeedBonus_Constant() return 200 end

function modifier_imba_wukongs_command_mk_active:OnAttackRecord(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not keys.target:IsHero() then
		self:GetParent():Stop()
	end
end

function modifier_imba_wukongs_command_mk_active:OnAttackLanded(keys)
	if IsServer() and keys.attacker == self:GetParent() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_wukongs_command_mk_disarm", {duration = self:GetAbility():GetSpecialValueFor("attack_speed")})
	end
end

function modifier_imba_wukongs_command_mk_active:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

modifier_imba_wukongs_command_mk_lifetime = class({})

function modifier_imba_wukongs_command_mk_lifetime:IsDebuff()			return false end
function modifier_imba_wukongs_command_mk_lifetime:IsHidden() 			return true end
function modifier_imba_wukongs_command_mk_lifetime:IsPurgable() 		return false end
function modifier_imba_wukongs_command_mk_lifetime:IsPurgeException()	return false end

function modifier_imba_wukongs_command_mk_lifetime:OnCreated()
	if IsServer() then
		self:SetDuration(self:GetAbility():GetSpecialValueFor("duration"), true)
	end
end

function modifier_imba_wukongs_command_mk_lifetime:OnDestroy()
	if IsServer() then
		local mk = self:GetParent()
		mk:AddNoDraw()
		mk:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_wukongs_command_mk_hidden", {})
	end
end

modifier_imba_wukongs_command_mk_disarm = class({})

function modifier_imba_wukongs_command_mk_disarm:IsDebuff()			return false end
function modifier_imba_wukongs_command_mk_disarm:IsHidden() 		return true end
function modifier_imba_wukongs_command_mk_disarm:IsPurgable() 		return false end
function modifier_imba_wukongs_command_mk_disarm:IsPurgeException()	return false end
--function modifier_imba_wukongs_command_mk_disarm:CheckState() return {[MODIFIER_STATE_DISARMED] = true} end