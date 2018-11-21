


item_imba_phase_boots_2 = class({})

LinkLuaModifier("modifier_imba_phase_boots2_passive", "items/item_boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_phase_boots_2_move_speed", "items/item_boots", LUA_MODIFIER_MOTION_NONE)

function item_imba_phase_boots_2:GetIntrinsicModifierName() return "modifier_imba_phase_boots2_passive" end

function item_imba_phase_boots_2:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_imba_phase_boots_2_move_speed", {duration = self:GetSpecialValueFor("phase_duration")})
	self:GetCaster():EmitSound("DOTA_Item.PhaseBoots.Activate")
	local pfx = ParticleManager:CreateParticle("particles/econ/events/ti6/phase_boots_ti6.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(pfx)
end

modifier_imba_phase_boots2_passive = class({})

function modifier_imba_phase_boots2_passive:IsDebuff()			return false end
function modifier_imba_phase_boots2_passive:IsHidden() 			return true end
function modifier_imba_phase_boots2_passive:IsPurgable() 		return false end
function modifier_imba_phase_boots2_passive:IsPurgeException() 	return false end
function modifier_imba_phase_boots2_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_phase_boots2_passive:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE} end
function modifier_imba_phase_boots2_passive:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_as") end
function modifier_imba_phase_boots2_passive:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("bonus_movement_speed") end
function modifier_imba_phase_boots2_passive:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true} end

modifier_item_imba_phase_boots_2_move_speed = class({})

function modifier_item_imba_phase_boots_2_move_speed:IsDebuff()			return false end
function modifier_item_imba_phase_boots_2_move_speed:IsHidden() 		return false end
function modifier_item_imba_phase_boots_2_move_speed:IsPurgable() 		return true end
function modifier_item_imba_phase_boots_2_move_speed:IsPurgeException() return true end
function modifier_item_imba_phase_boots_2_move_speed:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_MAX, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_item_imba_phase_boots_2_move_speed:GetModifierMoveSpeed_Max() return self:GetAbility():GetSpecialValueFor("new_ms_limit") end
function modifier_item_imba_phase_boots_2_move_speed:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("phase_ms") end


item_imba_tranquil_boots_2 = class({})

LinkLuaModifier("modifier_imba_tranquil_boots2_passive", "items/item_boots", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_tranquil_boots_2_stacks", "items/item_boots", LUA_MODIFIER_MOTION_NONE)

function item_imba_tranquil_boots_2:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_tranquil_boots_2:GetIntrinsicModifierName() return "modifier_imba_tranquil_boots2_passive" end

modifier_imba_tranquil_boots2_passive = class({})

function modifier_imba_tranquil_boots2_passive:IsDebuff()			return false end
function modifier_imba_tranquil_boots2_passive:IsHidden() 			return true end
function modifier_imba_tranquil_boots2_passive:IsPurgable() 		return false end
function modifier_imba_tranquil_boots2_passive:IsPurgeException() 	return false end
function modifier_imba_tranquil_boots2_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_tranquil_boots2_passive:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_tranquil_boots2_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("base_health_regen") end
function modifier_imba_tranquil_boots2_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("base_armor") end
function modifier_imba_tranquil_boots2_passive:GetModifierMoveSpeedBonus_Special_Boots() return self:GetAbility():GetSpecialValueFor("base_move_speed") end

function modifier_imba_tranquil_boots2_passive:OnAttackLanded(keys)
	if IsServer() and (keys.target == self:GetParent() or keys.attacker == self:GetParent()) and keys.attacker:IsHero() then
		self:GetAbility():UseResources(true, true, true)
	end
end

function modifier_imba_tranquil_boots2_passive:IsAura() return (self:GetAbility() and self:GetAbility():IsCooldownReady() or false) end
function modifier_imba_tranquil_boots2_passive:GetAuraDuration() return 0.1 end
function modifier_imba_tranquil_boots2_passive:GetModifierAura() return "modifier_item_imba_tranquil_boots_2_stacks" end
function modifier_imba_tranquil_boots2_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_tranquil_boots2_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_tranquil_boots2_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_tranquil_boots2_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_item_imba_tranquil_boots_2_stacks = class({})

function modifier_item_imba_tranquil_boots_2_stacks:IsDebuff()			return false end
function modifier_item_imba_tranquil_boots_2_stacks:IsHidden() 			return false end
function modifier_item_imba_tranquil_boots_2_stacks:IsPurgable() 		return false end
function modifier_item_imba_tranquil_boots_2_stacks:IsPurgeException() 	return false end
function modifier_item_imba_tranquil_boots_2_stacks:GetTexture() return "custom/imba_tranquil_boots_2" end
function modifier_item_imba_tranquil_boots_2_stacks:OnDestroy() self.ability = nil end
function modifier_item_imba_tranquil_boots_2_stacks:DeclareFunctions() return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT} end
function modifier_item_imba_tranquil_boots_2_stacks:GetModifierConstantHealthRegen() return (self:GetStackCount() * self.ability:GetSpecialValueFor("health_regen_per_sec")) end
function modifier_item_imba_tranquil_boots_2_stacks:GetModifierPhysicalArmorBonus() return (self:GetStackCount() * self.ability:GetSpecialValueFor("armor_per_sec")) end
function modifier_item_imba_tranquil_boots_2_stacks:GetModifierMoveSpeedBonus_Constant() return (self:GetStackCount() * self.ability:GetSpecialValueFor("move_speed_per_sec")) end
function modifier_item_imba_tranquil_boots_2_stacks:GetEffectName() return "particles/item/boots/ironleaf_boots_tranquility.vpcf" end
function modifier_item_imba_tranquil_boots_2_stacks:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_imba_tranquil_boots_2_stacks:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_item_imba_tranquil_boots_2_stacks:OnIntervalThink()
	self:SetStackCount(math.min(self.ability:GetSpecialValueFor("max_stacks"), self:GetStackCount() + 1))
end