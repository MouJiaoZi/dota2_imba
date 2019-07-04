imba_force_load = class({})

CreateEmptyTalents("chaos_knight")
CreateEmptyTalents("dark_seer")

LinkLuaModifier("modifier_imba_silencer_int_steal", "hero/hero_force_load", LUA_MODIFIER_MOTION_NONE)

modifier_imba_silencer_int_steal = class({})

function modifier_imba_silencer_int_steal:IsDebuff()			return false end
function modifier_imba_silencer_int_steal:IsHidden() 			return false end
function modifier_imba_silencer_int_steal:IsPurgable() 			return false end
function modifier_imba_silencer_int_steal:IsPurgeException() 	return false end
function modifier_imba_silencer_int_steal:RemoveOnDeath() return self:GetParent():IsIllusion() end
function modifier_imba_silencer_int_steal:GetTexture() return "silencer_glaives_of_wisdom" end
function modifier_imba_silencer_int_steal:DestroyOnExpire() return false end
function modifier_imba_silencer_int_steal:DeclareFunctions() return {MODIFIER_EVENT_ON_DEATH} end

function modifier_imba_silencer_int_steal:OnCreated()
	if IsServer() then
		if self:GetParent():GetUnitName() ~= "npc_dota_hero_silencer" then
			self:Destroy()
			return
		end
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_silencer_int_steal:OnIntervalThink()
	self:GetParent():RemoveModifierByName("modifier_silencer_int_steal")
end

function modifier_imba_silencer_int_steal:OnDeath(keys)
	if not IsServer() then
		return
	end
	if not IsEnemy(self:GetParent(), keys.unit) or not keys.unit:IsTrueHero() or not self:GetParent():IsAlive() or (self:GetParent():GetAbsOrigin() - keys.unit:GetAbsOrigin()):Length2D() > 925 or keys.unit:IsReincarnating() or self:GetParent():IsIllusion() then
		return
	end
	if self:GetRemainingTime() <= 0 then
		return
	end
	self:SetStackCount(self:GetStackCount() + 2)
	self:GetParent():SetBaseIntellect(self:GetParent():GetBaseIntellect() + 2)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_silencer/silencer_last_word_steal_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(pfx, 1, Vector(12,0,0))
	ParticleManager:ReleaseParticleIndex(pfx)
end