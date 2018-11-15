
item_imba_arcane_boots = class({})

LinkLuaModifier("modifier_imba_arcane_boots", "items/item_arcane_boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_arcane_boots_replenish", "items/item_arcane_boots", LUA_MODIFIER_MOTION_NONE)

function item_imba_arcane_boots:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("replenish_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_arcane_boots:GetIntrinsicModifierName() return "modifier_imba_arcane_boots" end

function item_imba_arcane_boots:OnSpellStart()
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("replenish_radius")
	caster:EmitSound("DOTA_Item.ArcaneBoots.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:ReleaseParticleIndex(pfx)
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		ally:GiveMana(self:GetSpecialValueFor("replenish_amount"))
		ally:AddNewModifier(caster, self, "modifier_item_imba_arcane_boots_replenish", {duration = self:GetSpecialValueFor("replenish_duration")})
		ParticleManager:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
	end
end

modifier_imba_arcane_boots = class({})

function modifier_imba_arcane_boots:IsDebuff()			return false end
function modifier_imba_arcane_boots:IsHidden() 			return true end
function modifier_imba_arcane_boots:IsPurgable() 		return false end
function modifier_imba_arcane_boots:IsPurgeException() 	return false end
function modifier_imba_arcane_boots:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_arcane_boots:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE} end
function modifier_imba_arcane_boots:GetModifierManaBonus() return self:GetAbility():GetSpecialValueFor("bonus_mana") end
function modifier_imba_arcane_boots:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("bonus_movement") end

modifier_item_imba_arcane_boots_replenish = class({})

function modifier_item_imba_arcane_boots_replenish:IsDebuff()			return false end
function modifier_item_imba_arcane_boots_replenish:IsHidden() 			return false end
function modifier_item_imba_arcane_boots_replenish:IsPurgable() 		return true end
function modifier_item_imba_arcane_boots_replenish:IsPurgeException() 	return true end
function modifier_item_imba_arcane_boots_replenish:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE} end
function modifier_item_imba_arcane_boots_replenish:GetModifierTotalPercentageManaRegen() return self:GetAbility():GetSpecialValueFor("replenish_percent") end