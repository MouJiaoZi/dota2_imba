CreateEmptyTalents("earthshaker")

imba_earthshaker_fissure = class({})

LinkLuaModifier("modifier_imba_fissure", "hero/hero_earthshaker", LUA_MODIFIER_MOTION_NONE)

function imba_earthshaker_fissure:IsHiddenWhenStolen() 		return false end
function imba_earthshaker_fissure:IsRefreshable() 			return true end
function imba_earthshaker_fissure:IsStealable() 			return true end
function imba_earthshaker_fissure:IsNetherWardStealable()	return true end
function imba_earthshaker_fissure:GetCastRange() return self:GetSpecialValueFor("fissure_range") end
function imba_earthshaker_fissure:GetIntrinsicModifierName() return "modifier_imba_fissure" end
function imba_earthshaker_fissure:GetAssociatedSecondaryAbilities() return "imba_earthshaker_fissure_main" end
function imba_earthshaker_fissure:OnUpgrade()
	local abi1 = self:GetCaster():FindAbilityByName("imba_earthshaker_fissure_main")
	local abi2 = self:GetCaster():FindAbilityByName("imba_earthshaker_fissure_sec")
	if abi1 then
		abi1:SetLevel(self:GetLevel())
	end
	if abi2 then
		abi2:SetLevel(self:GetLevel())
	end
end

function imba_earthshaker_fissure:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	local length = self:GetSpecialValueFor("fissure_range") + caster:GetCastRangeBonus()
	local pos0 = caster:GetAbsOrigin() + direction * 128
	local pos1 = caster:GetAbsOrigin() + direction * length
	local angle = 360 / self:GetSpecialValueFor("number")
	local abi1 = self:GetCaster():FindAbilityByName("imba_earthshaker_fissure_main")
	local abi2 = self:GetCaster():FindAbilityByName("imba_earthshaker_fissure_sec")
	for i=0, (self:GetSpecialValueFor("number") - 1) do
		if i ~= 0 then
			pos = RotatePosition(caster:GetAbsOrigin(), QAngle(0, angle, 0), pos)
		end
		if i == 0 and abi1 then
			caster:SetCursorPosition(pos)
			abi1:OnSpellStart()
		end
		if i ~= 0 and abi2 then
			caster:SetCursorPosition(pos)
			abi2:OnSpellStart()
		end
	end
end

modifier_imba_fissure = class({})

function modifier_imba_fissure:IsDebuff()			return false end
function modifier_imba_fissure:IsHidden() 			return true end
function modifier_imba_fissure:IsPurgable() 		return false end
function modifier_imba_fissure:IsPurgeException() 	return false end

function modifier_imba_fissure:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_fissure:OnIntervalThink()
	local abi1 = self:GetCaster():FindAbilityByName("imba_earthshaker_fissure_main")
	if abi1 then
		abi1:SetActivated(false)
	end
end