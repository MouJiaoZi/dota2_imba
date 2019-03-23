
item_imba_pipe = class({})

LinkLuaModifier("modifier_imba_pipe_passive", "items/item_pipe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_pipe_aura", "items/item_pipe", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_pipe_block", "items/item_pipe", LUA_MODIFIER_MOTION_NONE)

function item_imba_pipe:GetIntrinsicModifierName() return "modifier_imba_pipe_passive" end

function item_imba_pipe:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("aura_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_pipe:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("aura_radius")
	caster:EmitSound("DOTA_Item.Pipe.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/pipe_of_insight_launch.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 2, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "modifier_item_imba_pipe_block", {duration = self:GetSpecialValueFor("barrier_duration")})
	end
end

modifier_imba_pipe_passive = class({})

function modifier_imba_pipe_passive:IsDebuff()			return false end
function modifier_imba_pipe_passive:IsHidden() 			return true end
function modifier_imba_pipe_passive:IsPurgable() 		return false end
function modifier_imba_pipe_passive:IsPurgeException() 	return false end
function modifier_imba_pipe_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_pipe_passive:IsAura() return true end
function modifier_imba_pipe_passive:GetAuraDuration() return 0.1 end
function modifier_imba_pipe_passive:GetModifierAura() return "modifier_item_imba_pipe_aura" end
function modifier_imba_pipe_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_pipe_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_pipe_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_pipe_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_pipe_passive:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_imba_pipe_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("health_regen") end
function modifier_imba_pipe_passive:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("magic_resistance") end

modifier_item_imba_pipe_aura = class({})

function modifier_item_imba_pipe_aura:IsDebuff()			return false end
function modifier_item_imba_pipe_aura:IsHidden() 			return false end
function modifier_item_imba_pipe_aura:IsPurgable() 			return false end
function modifier_item_imba_pipe_aura:IsPurgeException() 	return false end
function modifier_item_imba_pipe_aura:GetTexture() return "imba_pipe" end
function modifier_item_imba_pipe_aura:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_item_imba_pipe_aura:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_pipe_aura:OnDestroy() self.ability = nil end
function modifier_item_imba_pipe_aura:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("aura_health_regen") end
function modifier_item_imba_pipe_aura:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("aura_magic_resist") end

modifier_item_imba_pipe_block = class({})

function modifier_item_imba_pipe_block:IsDebuff()			return false end
function modifier_item_imba_pipe_block:IsHidden() 			return false end
function modifier_item_imba_pipe_block:IsPurgable() 		return true end
function modifier_item_imba_pipe_block:IsPurgeException() 	return true end
function modifier_item_imba_pipe_block:GetTexture() return "imba_pipe" end
function modifier_item_imba_pipe_block:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_item_imba_pipe_block:GetModifierMagicalResistanceBonus() return self.ability:GetSpecialValueFor("barrier_resist") end

function modifier_item_imba_pipe_block:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/item/pipe_of_insight/pipe_of_insight.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetParent():GetModelRadius() * 1.1,0,0))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_item_imba_pipe_block:OnDestroy() self.ability = nil end