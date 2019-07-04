CreateEmptyTalents("arc_warden")

imba_arc_warden_mold_rune = class({})

LinkLuaModifier("modifier_imba_arc_warden_scepter_controller", "hero/hero_arc_warden.lua", LUA_MODIFIER_MOTION_NONE)

function imba_arc_warden_mold_rune:IsHiddenWhenStolen() 	return false end
function imba_arc_warden_mold_rune:IsRefreshable() 			return true end
function imba_arc_warden_mold_rune:IsStealable() 			return true end
function imba_arc_warden_mold_rune:IsNetherWardStealable()	return true end
function imba_arc_warden_mold_rune:GetIntrinsicModifierName() return "modifier_imba_arc_warden_scepter_controller" end
function imba_arc_warden_mold_rune:IsTalentAbility() return true end

function imba_arc_warden_mold_rune:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local random_buff = {"modifier_rune_regen", "modifier_rune_haste", "modifier_rune_invis", "modifier_rune_doubledamage", "modifier_rune_arcane"}
	target:AddNewModifier(caster, self, RandomFromTable(random_buff), {duration = 1.0})
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_arc_warden/arc_warden_flux_cast.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 2, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	caster:EmitSound("Hero_ArcWarden.Flux.Cast")
	target:EmitSound("Hero_ArcWarden.Flux.Target")
	self:EndCooldown()
	self:StartCooldown(self:GetSpecialValueFor("cooldown"))
end

modifier_imba_arc_warden_scepter_controller = class({})

function modifier_imba_arc_warden_scepter_controller:IsDebuff()			return false end
function modifier_imba_arc_warden_scepter_controller:IsHidden() 		return true end
function modifier_imba_arc_warden_scepter_controller:IsPurgable() 		return false end
function modifier_imba_arc_warden_scepter_controller:IsPurgeException() return false end

function modifier_imba_arc_warden_scepter_controller:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_arc_warden_scepter_controller:OnIntervalThink()
	self:GetAbility():SetHidden(not self:GetParent():HasScepter())
end