CreateEmptyTalents("antimage")

imba_antimage_mana_break = class({})

LinkLuaModifier("modifier_imba_antimage_mana_break", "hero/hero_antimage", LUA_MODIFIER_MOTION_NONE)

function imba_antimage_mana_break:GetIntrinsicModifierName() return "modifier_imba_antimage_mana_break" end

modifier_imba_antimage_mana_break = class({})

function modifier_imba_antimage_mana_break:IsDebuff()			return false end
function modifier_imba_antimage_mana_break:IsHidden() 			return true end
function modifier_imba_antimage_mana_break:IsPurgable() 		return false end
function modifier_imba_antimage_mana_break:IsPurgeException() 	return false end

function modifier_imba_antimage_mana_break:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED,}
	return funcs
end

function modifier_imba_antimage_mana_break:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetCaster() then
		return
	end
	if keys.target:IsBuilding() or keys.target:GetMaxMana() <= 0 or keys.target:IsMagicImmune() or self:GetCaster():PassivesDisabled() then
		return 
	end
	local mana_burn = self:GetAbility():GetSpecialValueFor("base_mana_burn") + keys.target:GetMaxMana() * (self:GetAbility():GetSpecialValueFor("bonus_mana_burn") / 100)
	if keys.attacker:IsIllusion() then
		mana_burn = mana_burn * self:GetAbility():GetSpecialValueFor("illusion_factor")
	end
	keys.target:SetMana(math.max(0, keys.target:GetMana() - mana_burn))
	local total_manaloss = keys.target:GetMaxMana() - keys.target:GetMana()
	local dmg = total_manaloss * self:GetAbility():GetSpecialValueFor("damage_per_burn")
	if keys.attacker:IsIllusion() then
		dmg = dmg * self:GetAbility():GetSpecialValueFor("illusion_factor")
	end
	local manaburn_pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.target)
	ParticleManager:SetParticleControl(manaburn_pfx, 0, keys.target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(manaburn_pfx)
	local damageTable = {
						victim = keys.target,
						attacker = keys.attacker,
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						ability = self:GetAbility(),
						}
	ApplyDamage(damageTable)
	EmitSoundOnLocationWithCaster(keys.target:GetAbsOrigin(), "Hero_Antimage.ManaBreak", keys.target)
end

imba_antimage_blink = class({})

LinkLuaModifier("modifier_imba_antimage_passive_range", "hero/hero_antimage", LUA_MODIFIER_MOTION_NONE)

function imba_antimage_blink:IsHiddenWhenStolen() 		return false end
function imba_antimage_blink:IsRefreshable() 			return true end
function imba_antimage_blink:IsStealable() 				return true end
function imba_antimage_blink:IsNetherWardStealable() 	return true end

function imba_antimage_blink:OnSpellStart()
	local caster = self:GetCaster()
	ProjectileManager:ProjectileDodge(caster)
	local pos = self:GetCursorPosition()
	local max_dis = self:GetSpecialValueFor("blink_range")
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Antimage.Blink_out", caster)
	local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(pfx1, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlForward(pfx1, 0, (pos - caster:GetAbsOrigin()):Normalized())
	local distance = (pos - caster:GetAbsOrigin()):Length2D()
	if distance <= max_dis then
		FindClearSpaceForUnit(caster, pos, false)
	else
		pos = caster:GetAbsOrigin() + (pos - caster:GetAbsOrigin()):Normalized() * max_dis
		FindClearSpaceForUnit(caster, pos, false)
	end
	ProjectileManager:ProjectileDodge(caster)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Antimage.Blink_in", caster)
	ParticleManager:ReleaseParticleIndex(pfx1)
	ParticleManager:ReleaseParticleIndex(pfx2)
	caster:AddNewModifier(caster, self, "modifier_imba_antimage_passive_range", {duration = self:GetSpecialValueFor("buff_duration") + caster:GetTalentValue("special_bonus_imba_antimage_2")})
end

modifier_imba_antimage_passive_range = class({})

function modifier_imba_antimage_passive_range:IsDebuff()			return false end
function modifier_imba_antimage_passive_range:IsHidden() 			return false end
function modifier_imba_antimage_passive_range:IsPurgable() 			return false end
function modifier_imba_antimage_passive_range:IsPurgeException() 	return false end
function modifier_imba_antimage_passive_range:GetTexture() 			return "custom/imba_antimage_magehunter" end

function modifier_special_bonus_imba_antimage_1:OnCreated()
	if IsServer() then
		local ability = self:GetParent():FindAbilityByName("imba_antimage_blink")
		if ability then
			AbilityChargeController:AbilityChargeInitialize(ability, ability:GetCooldown(4), self:GetParent():GetTalentValue("special_bonus_imba_antimage_1"), 1, true, true)
		end
	end
end


imba_antimage_spell_shield = class({})

LinkLuaModifier("modifier_imba_antimage_spell_shield_passive", "hero/hero_antimage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_antimage_spell_shield_active", "hero/hero_antimage", LUA_MODIFIER_MOTION_NONE)

function imba_antimage_spell_shield:IsHiddenWhenStolen() 		return false end
function imba_antimage_spell_shield:IsRefreshable() 			return true end
function imba_antimage_spell_shield:IsStealable() 				return true end
function imba_antimage_spell_shield:IsNetherWardStealable() 	return true end

function imba_antimage_spell_shield:GetIntrinsicModifierName() return "modifier_imba_antimage_spell_shield_passive" end

function imba_antimage_spell_shield:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_imba_antimage_spell_shield_active", {duration = self:GetSpecialValueFor("active_duration")})
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_end_glow.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx2)
	self:GetCaster():EmitSound("Hero_Antimage.Counterspell.Cast")
end

modifier_imba_antimage_spell_shield_passive = class({})
modifier_imba_antimage_spell_shield_active = class({})

function modifier_imba_antimage_spell_shield_passive:IsDebuff()					return false end
function modifier_imba_antimage_spell_shield_passive:IsHidden() 				return true end
function modifier_imba_antimage_spell_shield_passive:IsPurgable() 				return false end
function modifier_imba_antimage_spell_shield_passive:IsPurgeException() 		return false end

function modifier_imba_antimage_spell_shield_passive:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,}
	return funcs
end

function modifier_imba_antimage_spell_shield_passive:GetModifierMagicalResistanceBonus()
	if self:GetCaster():PassivesDisabled() or self:GetCaster():IsIllusion() then
		return 0
	end
	if self:GetCaster():HasModifier("modifier_imba_antimage_spell_shield_active") then
		return (self:GetAbility():GetSpecialValueFor("magic_resistance") * 2)
	end
	return self:GetAbility():GetSpecialValueFor("magic_resistance")
end

function modifier_imba_antimage_spell_shield_active:IsDebuff()					return false end
function modifier_imba_antimage_spell_shield_active:IsHidden() 					return false end
function modifier_imba_antimage_spell_shield_active:IsPurgable() 				return true end
function modifier_imba_antimage_spell_shield_active:IsPurgeException() 			return true end
function modifier_imba_antimage_spell_shield_active:DeclareFunctions() return {MODIFIER_PROPERTY_ABSORB_SPELL} end

function modifier_imba_antimage_spell_shield_active:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_counter.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 1, Vector(100*self:GetParent():GetModelScale(), 1, 1))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_antimage_spell_shield_active:GetAbsorbSpell(keys)
	if not IsServer() then
		return
	end
	if not IsEnemy(keys.ability:GetCaster(), self:GetParent()) then
		return 0
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_counter_glint.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
	ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
	self:GetParent():EmitSound("Hero_Antimage.Counterspell.Target")
	return 1
end


imba_antimage_magehunter = class({})

LinkLuaModifier("modifier_imba_antimage_magehunter", "hero/hero_antimage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_antimage_magehunter_counter", "hero/hero_antimage", LUA_MODIFIER_MOTION_NONE)

function imba_antimage_magehunter:GetIntrinsicModifierName() return "modifier_imba_antimage_magehunter" end
function imba_antimage_magehunter:IsTalentAbility() return true end

modifier_imba_antimage_magehunter = class({})
modifier_imba_antimage_magehunter_counter = class({})

function modifier_imba_antimage_magehunter:IsDebuff()					return false end
function modifier_imba_antimage_magehunter:IsPurgable() 				return false end
function modifier_imba_antimage_magehunter:IsPurgeException() 			return false end
function modifier_imba_antimage_magehunter:IsHidden()
	if self:GetStackCount() > 0 then
		return false
	end
	return true
end

function modifier_imba_antimage_magehunter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_antimage_magehunter:OnIntervalThink()
	local buffs = self:GetCaster():FindAllModifiersByName("modifier_imba_antimage_magehunter_counter")
	local stack = 0
	for _, buff in pairs(buffs) do
		stack = stack + buff:GetStackCount()
	end
	self:SetStackCount(stack)
end

function modifier_imba_antimage_magehunter:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_SPENT_MANA,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING}
	return funcs
end

function modifier_imba_antimage_magehunter:GetModifierPercentageManacostStacking() return 100 end

function modifier_imba_antimage_magehunter:GetModifierPreAttack_BonusDamage()
	if self:GetCaster():PassivesDisabled() or self:GetCaster():IsIllusion() then
		return 0
	end
	return self:GetStackCount()
end

function modifier_imba_antimage_magehunter:OnSpentMana(keys)
	if keys.unit:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return
	end
	if self:GetCaster():HasModifier("modifier_imba_antimage_passive_range") then
		local buff = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_antimage_magehunter_counter", {duration = self:GetAbility():GetSpecialValueFor("stack_duration")})
		buff:SetStackCount(keys.cost * self:GetAbility():GetSpecialValueFor("mana_to_atk"))
	elseif (self:GetCaster():GetAbsOrigin() - keys.unit:GetAbsOrigin()):Length2D() <= self:GetAbility():GetCastRange(self:GetCaster():GetAbsOrigin(), self:GetCaster()) then
		local buff = self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_antimage_magehunter_counter", {duration = self:GetAbility():GetSpecialValueFor("stack_duration")})
		buff:SetStackCount(keys.cost * self:GetAbility():GetSpecialValueFor("mana_to_atk"))
	end
end

function modifier_imba_antimage_magehunter_counter:IsDebuff()				return false end
function modifier_imba_antimage_magehunter_counter:IsHidden() 				return true end
function modifier_imba_antimage_magehunter_counter:IsPurgable() 			return false end
function modifier_imba_antimage_magehunter_counter:IsPurgeException() 		return false end
function modifier_imba_antimage_magehunter_counter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

imba_antimage_mana_void = class({})

function imba_antimage_mana_void:IsHiddenWhenStolen() 		return false end
function imba_antimage_mana_void:IsRefreshable() 			return true end
function imba_antimage_mana_void:IsStealable() 				return true end
function imba_antimage_mana_void:IsNetherWardStealable() 	return true end

function imba_antimage_mana_void:GetAOERadius()	return self:GetSpecialValueFor("mana_void_aoe_radius") end
function imba_antimage_mana_void:GetCooldown(i) return self:GetSpecialValueFor("cd") + self:GetCaster():GetTalentValue("special_bonus_imba_antimage_3") end

function imba_antimage_mana_void:OnAbilityPhaseStart()
	EmitSoundOnLocationWithCaster(self:GetCaster():GetAbsOrigin(), "Hero_Antimage.ManaVoidCast", self:GetCaster())
	return true
end

function imba_antimage_mana_void:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("mana_void_ministun")})
	local dmg = 0
	target:SetMana(math.max(0, (target:GetMana() - target:GetMaxMana() * (self:GetSpecialValueFor("mana_void_mana_burn_pct") / 100))))
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
									target:GetAbsOrigin(),
									nil,
									self:GetSpecialValueFor("mana_void_aoe_radius"),
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
									FIND_ANY_ORDER,
									false)
	if not caster:HasScepter() then
		dmg = (target:GetMaxMana() - target:GetMana()) * self:GetSpecialValueFor("mana_void_damage_per_mana")
	else
		for _, enemy in pairs(enemies) do
			dmg = dmg + (enemy:GetMaxMana() - enemy:GetMana()) * self:GetSpecialValueFor("mana_void_damage_per_mana")
		end
	end
	for _, enemy in pairs(enemies) do
		local damageTable = {
							victim = enemy,
							attacker = caster,
							damage = dmg,
							damage_type = self:GetAbilityDamageType(),
							ability = self,
							}
		ApplyDamage(damageTable)
	end
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_Antimage.ManaVoid", target)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, target:GetAttachmentOrigin(target:ScriptLookupAttachment("attach_hitloc")))
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("mana_void_aoe_radius"), 0, 0))
end