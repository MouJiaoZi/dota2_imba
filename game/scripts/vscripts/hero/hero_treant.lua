CreateEmptyTalents("treant")

imba_treant_eye_duration = class({})

LinkLuaModifier("modifier_imba_eye_of_the_forest_lifetime", "hero/hero_treant.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_eye_of_the_forest_cut", "hero/hero_treant.lua", LUA_MODIFIER_MOTION_NONE)

function imba_treant_eye_duration:GetIntrinsicModifierName() return "modifier_imba_eye_of_the_forest_lifetime" end
function imba_treant_eye_duration:IsTalentAbility() return true end

modifier_imba_eye_of_the_forest_lifetime = class({})

function modifier_imba_eye_of_the_forest_lifetime:IsDebuff()			return false end
function modifier_imba_eye_of_the_forest_lifetime:IsHidden() 			return true end
function modifier_imba_eye_of_the_forest_lifetime:IsPurgable() 			return false end
function modifier_imba_eye_of_the_forest_lifetime:IsPurgeException() 	return false end
function modifier_imba_eye_of_the_forest_lifetime:AllowIllusionDuplicate() return false end
function modifier_imba_eye_of_the_forest_lifetime:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end

function modifier_imba_eye_of_the_forest_lifetime:OnAbilityFullyCast(keys)
	if not IsServer() or keys.ability:GetAbilityName() ~= "treant_eyes_in_the_forest" or keys.unit ~= self:GetCaster() then
		return
	end
	if not keys.target.IsStanding then
		return
	end
	CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_eye_of_the_forest_cut", {duration = 300.0, id = keys.target:entindex()}, self:GetCaster():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end

modifier_imba_eye_of_the_forest_cut = class({})

function modifier_imba_eye_of_the_forest_cut:OnCreated(keys)
	if IsServer() then
		self.tree = EntIndexToHScript(keys.id)
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_eye_of_the_forest_cut:OnIntervalThink()
	if not self.tree:IsStanding() then
		self:Destroy()
	end
end

function modifier_imba_eye_of_the_forest_cut:OnDestroy()
	if IsServer() then
		if self.tree:IsStanding() then
			self.tree:CutDown(-1)
		end
	end
end