
item_imba_super_ward = class({})

LinkLuaModifier("modifier_imba_super_ward_radiant", "items/item_super_ward", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_super_ward_dire", "items/item_super_ward", LUA_MODIFIER_MOTION_NONE)

--[[
	-6855 -6425 512
	6922 6180 512
]]

function item_imba_super_ward:CastFilterResultLocation(location)
	if IsNearEnemyFountain(location, self:GetCaster():GetTeamNumber(), 9000) then
		return UF_FAIL_CUSTOM
	end
end

function item_imba_super_ward:GetCustomCastErrorLocation(location)
	return "#dota_hud_error_no_wards_here"
end

function item_imba_super_ward:OnSpellStart()
	local caster = self:GetCaster()
	local ward = CreateUnitByName("npc_dota_observer_wards", self:GetCursorPosition(), true, caster:GetPlayerOwner(), caster:GetPlayerOwner(), caster:GetTeamNumber())
	ward:AddNewModifier(caster, nil, "modifier_invulnerable", {duration = self:GetSpecialValueFor("duration")})
	ward:AddNewModifier(caster, nil, "modifier_kill", {duration = self:GetSpecialValueFor("duration")})
	if caster:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
		ward:AddNewModifier(ward, nil, "modifier_imba_super_ward_radiant", {duration = self:GetSpecialValueFor("duration")})
	else
		ward:AddNewModifier(ward, nil, "modifier_imba_super_ward_dire", {duration = self:GetSpecialValueFor("duration")})
	end
end

modifier_imba_super_ward_radiant = class({})

function modifier_imba_super_ward_radiant:IsHidden() return true end
function modifier_imba_super_ward_radiant:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE} end
function modifier_imba_super_ward_radiant:GetModifierModelChange() return "models/props_teams/banner_radiant.vmdl" end
function modifier_imba_super_ward_radiant:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_super_ward_radiant:GetEffectName() return "particles/econ/courier/courier_huntling_gold/courier_huntling_gold_ambient.vpcf" end
function modifier_imba_super_ward_radiant:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

modifier_imba_super_ward_dire = class({})

function modifier_imba_super_ward_dire:IsHidden() return true end
function modifier_imba_super_ward_dire:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE} end
function modifier_imba_super_ward_dire:GetModifierModelChange() return "models/props_teams/banner_dire_small.vmdl" end
function modifier_imba_super_ward_dire:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_super_ward_dire:GetEffectName() return "particles/econ/courier/courier_huntling_gold/courier_huntling_gold_ambient.vpcf" end
function modifier_imba_super_ward_dire:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end