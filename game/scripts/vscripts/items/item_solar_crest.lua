item_imba_solar_crest = class({})

LinkLuaModifier("modifier_imba_solar_crest_passive", "items/item_solar_crest.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_solar_crest_buff", "items/item_solar_crest.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_solar_crest_debuff", "items/item_solar_crest.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_solar_crest_mkb_disable", "items/item_solar_crest.lua", LUA_MODIFIER_MOTION_NONE)

function item_imba_solar_crest:GetIntrinsicModifierName() return "modifier_imba_solar_crest_passive" end

function item_imba_solar_crest:CastFilterResultTarget(target)
	if not target:IsHero() and not target:IsCreep() then
		return UF_FAIL_OTHER
	end
	if IsEnemy(target, self:GetCaster()) and target:IsMagicImmune() then
		return UF_FAIL_MAGIC_IMMUNE_ENEMY
	end
	if target:IsInvulnerable() then
		return UF_FAIL_INVULNERABLE
	end
	if target == self:GetCaster() then
		return UF_FAIL_CUSTOM
	end
end

function item_imba_solar_crest:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	end
end

function item_imba_solar_crest:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if not IsEnemy(caster, target) then
		target:EmitSound("Item.StarEmblem.Friendly")
		target:AddNewModifier(caster, self, "modifier_imba_solar_crest_buff", {duration = self:GetSpecialValueFor("duration")})
	else
		if not target:TriggerStandardTargetSpell(self) then
			target:EmitSound("Item.StarEmblem.Enemy")
			target:AddNewModifier(caster, self, "modifier_imba_solar_crest_debuff", {duration = self:GetSpecialValueFor("duration")})
		end
	end
end

modifier_imba_solar_crest_passive = class({})

function modifier_imba_solar_crest_passive:IsDebuff()			return false end
function modifier_imba_solar_crest_passive:IsHidden() 			return true end
function modifier_imba_solar_crest_passive:IsPurgable() 		return false end
function modifier_imba_solar_crest_passive:IsPurgeException() 	return false end
function modifier_imba_solar_crest_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_solar_crest_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT} end
function modifier_imba_solar_crest_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_solar_crest_passive:GetModifierMoveSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("self_movement_speed") end
function modifier_imba_solar_crest_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen_pct") end
function modifier_imba_solar_crest_passive:GetModifierEvasion_Constant() return self:GetAbility():GetSpecialValueFor("bonus_evasion") end

modifier_imba_solar_crest_debuff = class({})

function modifier_imba_solar_crest_debuff:IsDebuff()			return true end
function modifier_imba_solar_crest_debuff:IsHidden() 			return false end
function modifier_imba_solar_crest_debuff:IsPurgable() 			return true end
function modifier_imba_solar_crest_debuff:IsPurgeException() 	return true end
function modifier_imba_solar_crest_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_solar_crest_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("target_movement_speed")) end
function modifier_imba_solar_crest_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("target_attack_speed")) end
function modifier_imba_solar_crest_debuff:GetModifierEvasion_Constant() return (0 - self:GetAbility():GetSpecialValueFor("target_evasion")) end
function modifier_imba_solar_crest_debuff:GetModifierPhysicalArmorBonus() return (0 - self:GetAbility():GetSpecialValueFor("target_armor")) end
function modifier_imba_solar_crest_debuff:CheckState() return {[MODIFIER_STATE_CANNOT_MISS] = false} end
function modifier_imba_solar_crest_debuff:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_imba_solar_crest_debuff:GetEffectName() return "particles/items3_fx/star_emblem_brokenshield.vpcf" end
function modifier_imba_solar_crest_debuff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_solar_crest_debuff:ShouldUseOverheadOffset() return true end

function modifier_imba_solar_crest_debuff:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/item/solar_crest/star_emblem.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		--ParticleManager:SetParticleControl(pfx, 0, Vector(50000, 50000, -2000))
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_imba_solar_crest_buff = class({})

function modifier_imba_solar_crest_buff:IsDebuff()			return false end
function modifier_imba_solar_crest_buff:IsHidden() 			return false end
function modifier_imba_solar_crest_buff:IsPurgable() 		return true end
function modifier_imba_solar_crest_buff:IsPurgeException() 	return true end
function modifier_imba_solar_crest_buff:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_solar_crest_buff:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("target_movement_speed") end
function modifier_imba_solar_crest_buff:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("target_attack_speed") end
function modifier_imba_solar_crest_buff:GetModifierEvasion_Constant() return self:GetAbility():GetSpecialValueFor("target_evasion") end
function modifier_imba_solar_crest_buff:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("target_armor") end
function modifier_imba_solar_crest_buff:GetEffectName() return "particles/items3_fx/star_emblem_friend_shield.vpcf" end
function modifier_imba_solar_crest_buff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_solar_crest_buff:ShouldUseOverheadOffset() return true end

function modifier_imba_solar_crest_buff:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/items3_fx/star_emblem_friend.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, Vector(50000, 50000, -2000))
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 5, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_solar_crest_buff:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if not keys.attacker:IsUnit() or not keys.target:IsAlive() or keys.target ~= self:GetParent() then
		return
	end
	local caster = self:GetCaster()
	local parent = keys.target
	local attacker = keys.attacker
	local ability = self:GetAbility()
	attacker:AddNewModifier(caster, ability, "modifier_imba_solar_crest_mkb_disable", {duration = ability:GetSpecialValueFor("mkb_duration")})
end

modifier_imba_solar_crest_mkb_disable = class({})

function modifier_imba_solar_crest_mkb_disable:IsDebuff()			return true end
function modifier_imba_solar_crest_mkb_disable:IsHidden() 			return false end
function modifier_imba_solar_crest_mkb_disable:IsPurgable() 		return false end
function modifier_imba_solar_crest_mkb_disable:IsPurgeException() 	return false end
function modifier_imba_solar_crest_mkb_disable:CheckState() return {[MODIFIER_STATE_CANNOT_MISS] = false} end
function modifier_imba_solar_crest_mkb_disable:GetPriority() return MODIFIER_PRIORITY_HIGH end