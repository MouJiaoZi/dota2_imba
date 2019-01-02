CreateEmptyTalents("furion")

--hero_furion.lua

imba_furion_force_of_nature = class({})

LinkLuaModifier("modifier_imba_force_of_nature_effect", "hero/hero_furion", LUA_MODIFIER_MOTION_NONE)

function imba_furion_force_of_nature:IsHiddenWhenStolen() 		return false end
function imba_furion_force_of_nature:IsRefreshable() 			return true  end
function imba_furion_force_of_nature:IsStealable() 				return true  end
function imba_furion_force_of_nature:IsNetherWardStealable()	return false end
function imba_furion_force_of_nature:GetAOERadius() return self:GetSpecialValueFor("area_of_effect") end

function imba_furion_force_of_nature:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 1.0}, pos, caster:GetTeamNumber(), false)
	sound:EmitSound("Hero_Furion.TreantSpawn")
	local trees = GridNav:GetAllTreesAroundPoint(pos, self:GetSpecialValueFor("area_of_effect"), false)
	local count = 0
	for _, tree in pairs(trees) do
		if not tree.IsStanding or tree:IsStanding() then
			count = count + 1
			if tree.IsStanding then
				tree:CutDown(caster:GetTeamNumber())
			else
				GridNav:DestroyTreesAroundPoint(tree:GetAbsOrigin(), 30, false)
			end
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_furion/furion_force_of_nature_cast.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx, 0, pos)
			ParticleManager:SetParticleControl(pfx, 1, pos)
			ParticleManager:SetParticleControl(pfx, 2, Vector(225,0,0))
			ParticleManager:ReleaseParticleIndex(pfx)
		end
	end
	caster:AddModifierStacks(caster, self, "modifier_imba_force_of_nature_effect", {duration = self:GetSpecialValueFor("duration")}, count, false, true)
end

modifier_imba_force_of_nature_effect = class({})

function modifier_imba_force_of_nature_effect:IsDebuff()			return false end
function modifier_imba_force_of_nature_effect:IsHidden() 			return false end
function modifier_imba_force_of_nature_effect:IsPurgable() 			return true end
function modifier_imba_force_of_nature_effect:IsPurgeException() 	return true end
function modifier_imba_force_of_nature_effect:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_force_of_nature_effect:GetModifierPreAttack_BonusDamage() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("atk_per_tree")) end