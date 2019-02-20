
item_imba_bfury = class({})

LinkLuaModifier("modifier_imba_bfury_passive", "items/item_bfury", LUA_MODIFIER_MOTION_NONE)

function item_imba_bfury:GetIntrinsicModifierName() return "modifier_imba_bfury_passive" end

function item_imba_bfury:GetAOERadius() return self:GetSpecialValueFor("chop_radius") end

function item_imba_bfury:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	GridNav:DestroyTreesAroundPoint(pos, self:GetSpecialValueFor("chop_radius"), true)
	local wards = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("chop_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_OTHER, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	for _, ward in pairs(wards) do
		if string.find(ward:GetUnitName(), "observer_wards") or string.find(ward:GetUnitName(), "sentry_wards") or string.find(ward:GetName(), "npc_dota_techies_mines") then
			ward:Kill(self, caster)
		end
	end
end

modifier_imba_bfury_passive = class({})

function modifier_imba_bfury_passive:IsDebuff()			return false end
function modifier_imba_bfury_passive:IsHidden() 		return true end
function modifier_imba_bfury_passive:IsPurgable() 		return false end
function modifier_imba_bfury_passive:IsPurgeException() return false end
function modifier_imba_bfury_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_bfury_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_bfury_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_bfury_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_imba_bfury_passive:GetModifierConstantManaRegen() return self:GetAbility():GetSpecialValueFor("bonus_mana_regen") end

function modifier_imba_bfury_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or not keys.target:IsAlive() then
		return
	end
	local cleave_pct = self:GetParent():IsRangedAttacker() and self:GetAbility():GetSpecialValueFor("ranged_cleave_damage") or self:GetAbility():GetSpecialValueFor("melee_cleave_damage")
	local cleave_damage = keys.damage * (cleave_pct / 100)
	if self:GetParent():IsIllusion() then
		cleave_damage = 0
	end
	local target = keys.target
	local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("cleave_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= target then
			local damageTable = {
								victim = enemy,
								attacker = self:GetParent(),
								damage = cleave_damage,
								damage_type = DAMAGE_TYPE_PURE,
								damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, --Optional.
								ability = nil, --Optional.
								}
			ApplyDamage(damageTable)
		end
	end
	local pfx = ParticleManager:CreateParticle("particles/item/bfury/bfury_cleave.vpcf", PATTACH_ABSORIGIN, keys.target)
	ParticleManager:ReleaseParticleIndex(pfx)
end

function modifier_imba_bfury_passive:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() and not keys.inflictor and keys.unit:IsCreep() and not keys.unit:IsConsideredHero() then
		local damageTable = {
							victim = keys.unit,
							attacker = self:GetParent(),
							damage = keys.damage * (self:GetAbility():GetSpecialValueFor("quelling_bonus") / 100),
							damage_type = DAMAGE_TYPE_PHYSICAL,
							damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
	end
end