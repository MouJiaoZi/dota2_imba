item_imba_veil_of_discord = class({})

LinkLuaModifier("modifier_imba_veil_of_discord_passive", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_veil_of_discord_aura_debuff", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_veil_of_discord_target_debuff", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)

function item_imba_veil_of_discord:GetIntrinsicModifierName() return "modifier_imba_veil_of_discord_passive" end

function item_imba_veil_of_discord:OnSpellStart()
	local caster = self:GetCaster()
	local target =self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("DOTA_Item.VeilofDiscord.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(pfx, 1, Vector(128 * target:GetModelScale(), 128 * target:GetModelScale(), 128 * target:GetModelScale()))
	ParticleManager:ReleaseParticleIndex(pfx)
	ApplyDamage({victim = target, attacker = caster, ability = self, damage = self:GetSpecialValueFor("target_damage"), damage_type = DAMAGE_TYPE_MAGICAL})
	target:AddNewModifier(caster, self, "modifier_item_imba_veil_of_discord_target_debuff", {duration = self:GetSpecialValueFor("debuff_duration")})
end

modifier_imba_veil_of_discord_passive = class({})

function modifier_imba_veil_of_discord_passive:IsDebuff()			return false end
function modifier_imba_veil_of_discord_passive:IsHidden() 			return true end
function modifier_imba_veil_of_discord_passive:IsPurgable() 		return false end
function modifier_imba_veil_of_discord_passive:IsPurgeException() 	return false end
function modifier_imba_veil_of_discord_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_veil_of_discord_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_veil_of_discord_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_veil_of_discord_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_imba_veil_of_discord_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_imba_veil_of_discord_passive:GetModifierPercentageManacost() return self:GetAbility():GetSpecialValueFor("mana_reduce") end
function modifier_imba_veil_of_discord_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end

function modifier_imba_veil_of_discord_passive:IsAura() return true end
function modifier_imba_veil_of_discord_passive:GetAuraDuration() return 0.1 end
function modifier_imba_veil_of_discord_passive:GetModifierAura() return "modifier_item_imba_veil_of_discord_aura_debuff" end
function modifier_imba_veil_of_discord_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_veil_of_discord_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_veil_of_discord_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_veil_of_discord_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_veil_of_discord_passive:GetAuraEntityReject(unit) return unit:HasModifier("modifier_item_imba_shivas_2_aura_debuff") end

modifier_item_imba_veil_of_discord_aura_debuff = class({})

function modifier_item_imba_veil_of_discord_aura_debuff:IsDebuff()			return true end
function modifier_item_imba_veil_of_discord_aura_debuff:IsHidden() 			return false end
function modifier_item_imba_veil_of_discord_aura_debuff:IsPurgable() 		return false end
function modifier_item_imba_veil_of_discord_aura_debuff:IsPurgeException() 	return false end
function modifier_item_imba_veil_of_discord_aura_debuff:GetTexture() return "imba_veil_of_discord" end
function modifier_item_imba_veil_of_discord_aura_debuff:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_veil_of_discord_aura_debuff:OnDestroy() self.ability = nil end
function modifier_item_imba_veil_of_discord_aura_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_item_imba_veil_of_discord_aura_debuff:GetModifierMagicalResistanceBonus()
	if self:GetParent():HasModifier("modifier_item_imba_veil_of_discord_target_debuff") then
		return (0 - 2 * self.ability:GetSpecialValueFor("aura_resist"))
	else
		return (0 - self.ability:GetSpecialValueFor("aura_resist"))
	end
end

modifier_item_imba_veil_of_discord_target_debuff = class({})

function modifier_item_imba_veil_of_discord_target_debuff:IsDebuff()			return true end
function modifier_item_imba_veil_of_discord_target_debuff:IsHidden() 			return false end
function modifier_item_imba_veil_of_discord_target_debuff:IsPurgable() 			return true end
function modifier_item_imba_veil_of_discord_target_debuff:IsPurgeException() 	return true end
function modifier_item_imba_veil_of_discord_target_debuff:GetEffectName() return "particles/items2_fx/veil_of_discord_debuff.vpcf" end
function modifier_item_imba_veil_of_discord_target_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end



item_imba_shivas_guard = class({})

LinkLuaModifier("modifier_imba_shiva_passive", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_shivas_aura_debuff", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shiva_active_thinker", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_shivas_active_debuff", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)

function item_imba_shivas_guard:GetIntrinsicModifierName() return "modifier_imba_shiva_passive" end

function item_imba_shivas_guard:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("blast_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_shivas_guard:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.ShivasGuard.Activate")
	caster:AddNewModifier(caster, self, "modifier_imba_shiva_active_thinker", {duration = (self:GetSpecialValueFor("blast_radius") / self:GetSpecialValueFor("blast_speed"))})
end

modifier_imba_shiva_passive = class({})

function modifier_imba_shiva_passive:IsDebuff()			return false end
function modifier_imba_shiva_passive:IsHidden() 		return true end
function modifier_imba_shiva_passive:IsPurgable() 		return false end
function modifier_imba_shiva_passive:IsPurgeException() return false end
function modifier_imba_shiva_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_shiva_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_shiva_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_imba_shiva_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

function modifier_imba_shiva_passive:IsAura() return true end
function modifier_imba_shiva_passive:GetAuraDuration() return 1.0 end
function modifier_imba_shiva_passive:GetModifierAura() return "modifier_item_imba_shivas_aura_debuff" end
function modifier_imba_shiva_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_shiva_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_shiva_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_shiva_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_imba_shiva_passive:GetAuraEntityReject(unit) return unit:HasModifier("modifier_item_imba_shivas_2_aura_debuff") end

modifier_item_imba_shivas_aura_debuff = class({})

function modifier_item_imba_shivas_aura_debuff:IsDebuff()			return true end
function modifier_item_imba_shivas_aura_debuff:IsHidden() 			return false end
function modifier_item_imba_shivas_aura_debuff:IsPurgable() 		return false end
function modifier_item_imba_shivas_aura_debuff:IsPurgeException() 	return false end
function modifier_item_imba_shivas_aura_debuff:GetTexture() return "imba_shivas_guard" end
function modifier_item_imba_shivas_aura_debuff:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_shivas_aura_debuff:OnDestroy() self.ability = nil end
function modifier_item_imba_shivas_aura_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_shivas_aura_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self.ability:GetSpecialValueFor("aura_as_reduction")) end

modifier_imba_shiva_active_thinker = class({})

function modifier_imba_shiva_active_thinker:IsDebuff()			return false end
function modifier_imba_shiva_active_thinker:IsHidden() 			return true end
function modifier_imba_shiva_active_thinker:IsPurgable() 		return false end
function modifier_imba_shiva_active_thinker:IsPurgeException() 	return false end
function modifier_imba_shiva_active_thinker:RemoveOnDeath() 	return false end
function modifier_imba_shiva_active_thinker:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_shiva_active_thinker:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self.ability:GetSpecialValueFor("blast_radius"), self:GetDuration() * 1.33, self.ability:GetSpecialValueFor("blast_speed")))
		self:AddParticle(pfx, false, false, 15, false, false)
		self.hitted = {}
	end
end

function modifier_imba_shiva_active_thinker:OnIntervalThink()
	local radius_increase = (self.ability:GetSpecialValueFor("blast_speed") / (1.0 / FrameTime())) * 100
	self:SetStackCount(self:GetStackCount() + radius_increase)
	local radius = self:GetStackCount() / 100
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), radius, FrameTime(), false)
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not self.hitted[enemy:entindex()] then
			self.hitted[enemy:entindex()] = true
			local pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControl(pfx, 1, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(pfx)
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability})
			enemy:AddNewModifier(self:GetCaster(), self.ability, "modifier_item_imba_shivas_active_debuff", {duration = self.ability:GetSpecialValueFor("slow_duration_tooltip")})
		end
	end
end

function modifier_imba_shiva_active_thinker:OnDestroy()
	if IsServer() then
		local radius = self:GetStackCount() / 100
		AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), radius, self.ability:GetSpecialValueFor("slow_duration_tooltip"), false)
		self.hitted = nil
	end
	self.ability = nil
end

modifier_item_imba_shivas_active_debuff = class({})

function modifier_item_imba_shivas_active_debuff:IsDebuff()			return true end
function modifier_item_imba_shivas_active_debuff:IsHidden() 		return false end
function modifier_item_imba_shivas_active_debuff:IsPurgable() 		return true end
function modifier_item_imba_shivas_active_debuff:IsPurgeException() return true end
function modifier_item_imba_shivas_active_debuff:GetTexture() return "imba_shivas_guard" end
function modifier_item_imba_shivas_active_debuff:OnDestroy() self.ability = nil end
function modifier_item_imba_shivas_active_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_shivas_active_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self.ability:GetSpecialValueFor("initial_slow_tooltip")) end
function modifier_item_imba_shivas_active_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetStackCount()) end
function modifier_item_imba_shivas_active_debuff:GetEffectName() return "particles/generic_gameplay/generic_slowed_cold.vpcf" end
function modifier_item_imba_shivas_active_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_imba_shivas_active_debuff:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:SetStackCount((self:GetParent():GetAttacksPerSecond() * self:GetParent():GetBaseAttackTime() * 100) * (self.ability:GetSpecialValueFor("initial_slow_tooltip") / 100))
	end
end

item_imba_shivas_guard_2 = class({})

LinkLuaModifier("modifier_imba_shiva_2_passive", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_shivas_2_aura_debuff", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_shiva_2_active_thinker", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_shivas_2_active_debuff", "items/item_shiva", LUA_MODIFIER_MOTION_NONE)

function item_imba_shivas_guard_2:GetIntrinsicModifierName() return "modifier_imba_shiva_2_passive" end

function item_imba_shivas_guard_2:GetCastRange()
	if not IsServer() then
		return (self:GetSpecialValueFor("blast_radius") - self:GetCaster():GetCastRangeBonus())
	end
end

function item_imba_shivas_guard_2:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("DOTA_Item.ShivasGuard.Activate")
	caster:AddNewModifier(caster, self, "modifier_imba_shiva_2_active_thinker", {duration = (self:GetSpecialValueFor("blast_radius") / self:GetSpecialValueFor("blast_speed"))})
end

modifier_imba_shiva_2_passive = class({})

function modifier_imba_shiva_2_passive:IsDebuff()			return false end
function modifier_imba_shiva_2_passive:IsHidden() 		return true end
function modifier_imba_shiva_2_passive:IsPurgable() 		return false end
function modifier_imba_shiva_2_passive:IsPurgeException() return false end
function modifier_imba_shiva_2_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_shiva_2_passive:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE} end
function modifier_imba_shiva_2_passive:GetModifierBonusStats_Intellect() return self:GetAbility():GetSpecialValueFor("bonus_int") end
function modifier_imba_shiva_2_passive:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_shiva_2_passive:GetModifierConstantHealthRegen() return self:GetAbility():GetSpecialValueFor("bonus_health_regen") end
function modifier_imba_shiva_2_passive:GetModifierPercentageManacost() return self:GetAbility():GetSpecialValueFor("mana_reduce") end
function modifier_imba_shiva_2_passive:GetModifierSpellAmplify_Percentage() return self:GetAbility():GetSpecialValueFor("spell_power") end

function modifier_imba_shiva_2_passive:IsAura() return true end
function modifier_imba_shiva_2_passive:GetAuraDuration() return 1.0 end
function modifier_imba_shiva_2_passive:GetModifierAura() return "modifier_item_imba_shivas_2_aura_debuff" end
function modifier_imba_shiva_2_passive:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_imba_shiva_2_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_shiva_2_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_imba_shiva_2_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end

modifier_item_imba_shivas_2_aura_debuff = class({})

function modifier_item_imba_shivas_2_aura_debuff:IsDebuff()			return true end
function modifier_item_imba_shivas_2_aura_debuff:IsHidden() 		return false end
function modifier_item_imba_shivas_2_aura_debuff:IsPurgable() 		return false end
function modifier_item_imba_shivas_2_aura_debuff:IsPurgeException() return false end
function modifier_item_imba_shivas_2_aura_debuff:GetTexture() return "imba_shiva_2" end
function modifier_item_imba_shivas_2_aura_debuff:OnCreated() self.ability = self:GetAbility() end
function modifier_item_imba_shivas_2_aura_debuff:OnDestroy() self.ability = nil end
function modifier_item_imba_shivas_2_aura_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end
function modifier_item_imba_shivas_2_aura_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self.ability:GetSpecialValueFor("aura_as_reduction")) end
function modifier_item_imba_shivas_2_aura_debuff:GetModifierMagicalResistanceBonus()
	if self:GetParent():HasModifier("modifier_item_imba_shivas_2_active_debuff") then
		return (0 - 2 * self.ability:GetSpecialValueFor("aura_resist"))
	else
		return (0 - self.ability:GetSpecialValueFor("aura_resist"))
	end
end

modifier_imba_shiva_2_active_thinker = class({})

function modifier_imba_shiva_2_active_thinker:IsDebuff()			return false end
function modifier_imba_shiva_2_active_thinker:IsHidden() 			return true end
function modifier_imba_shiva_2_active_thinker:IsPurgable() 			return false end
function modifier_imba_shiva_2_active_thinker:IsPurgeException() 	return false end
function modifier_imba_shiva_2_active_thinker:RemoveOnDeath() 		return false end
function modifier_imba_shiva_2_active_thinker:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

function modifier_imba_shiva_2_active_thinker:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:StartIntervalThink(FrameTime())
		local pfx = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_active_nian2015.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self.ability:GetSpecialValueFor("blast_radius"), self:GetDuration() * 1.33, self.ability:GetSpecialValueFor("blast_speed")))
		self:AddParticle(pfx, false, false, 15, false, false)
		self.hitted = {}
	end
end

function modifier_imba_shiva_2_active_thinker:OnIntervalThink()
	local radius_increase = (self.ability:GetSpecialValueFor("blast_speed") / (1.0 / FrameTime())) * 100
	self:SetStackCount(self:GetStackCount() + radius_increase)
	local radius = self:GetStackCount() / 100
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), radius, FrameTime(), false)
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if not self.hitted[enemy:entindex()] then
			self.hitted[enemy:entindex()] = true
			local pfx = ParticleManager:CreateParticle("particles/econ/events/newbloom_2015/shivas_guard_impact_nian2015.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControl(pfx, 1, self:GetParent():GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(pfx)
			ApplyDamage({victim = enemy, attacker = self:GetCaster(), damage = self:GetAbility():GetSpecialValueFor("damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability})
			enemy:AddNewModifier(self:GetCaster(), self.ability, "modifier_item_imba_shivas_2_active_debuff", {duration = self.ability:GetSpecialValueFor("slow_duration_tooltip")})
		end
	end
end

function modifier_imba_shiva_2_active_thinker:OnDestroy()
	if IsServer() then
		local radius = self:GetStackCount() / 100
		AddFOWViewer(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), radius, self.ability:GetSpecialValueFor("slow_duration_tooltip"), false)
		self.hitted = nil
	end
	self.ability = nil
end

modifier_item_imba_shivas_2_active_debuff = class({})

function modifier_item_imba_shivas_2_active_debuff:IsDebuff()			return true end
function modifier_item_imba_shivas_2_active_debuff:IsHidden() 		return false end
function modifier_item_imba_shivas_2_active_debuff:IsPurgable() 		return true end
function modifier_item_imba_shivas_2_active_debuff:IsPurgeException() return true end
function modifier_item_imba_shivas_2_active_debuff:GetTexture() return "imba_shiva_2" end
function modifier_item_imba_shivas_2_active_debuff:OnDestroy() self.ability = nil end
function modifier_item_imba_shivas_2_active_debuff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT} end
function modifier_item_imba_shivas_2_active_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self.ability:GetSpecialValueFor("initial_slow_tooltip")) end
function modifier_item_imba_shivas_2_active_debuff:GetModifierAttackSpeedBonus_Constant() return (0 - self:GetStackCount()) end
function modifier_item_imba_shivas_2_active_debuff:GetEffectName() return "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail_fire.vpcf" end
function modifier_item_imba_shivas_2_active_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_item_imba_shivas_2_active_debuff:OnCreated()
	self.ability = self:GetAbility()
	if IsServer() then
		self:SetStackCount((self:GetParent():GetAttacksPerSecond() * self:GetParent():GetBaseAttackTime() * 100) * (self.ability:GetSpecialValueFor("initial_slow_tooltip") / 100))
	end
end
