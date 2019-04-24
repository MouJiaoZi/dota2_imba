
CreateEmptyTalents("obsidian_destroyer")

----------------------------------------------------------
-------- DataDriven Unique Attack Modifier
----------------------------------------------------------

LinkLuaModifier("modifier_imba_obsidian_destroyer_int_gain", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_obsidian_destroyer_int_lose", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_obsidian_destroyer_int_gain_counter", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_obsidian_destroyer_int_lose_counter", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)

function ArcaneOrb_AttackStart(keys)
	local caster = keys.attacker
	local target = keys.target
	local ability = keys.ability
	ability:UseResources(true, true, true)
	caster:EmitSound("Hero_ObsidianDestroyer.ArcaneOrb")
	local buff = caster:FindModifierByName("modifier_imba_essence_aura_buff")
	if buff then
		local keys = {unit = caster, ability = ability}
		buff:OnAbilityFullyCast(keys)
	end
end

function ArcaneOrb_AttackLanded(keys)
	local caster = keys.attacker
	if caster:IsIllusion() then
		return
	end
	local target = keys.target
	local ability = keys.ability
	if target:IsIllusion() or target:IsCreature() then
		target:EmitSound("Hero_ObsidianDestroyer.ArcaneOrb.Impact")
		target:Kill(ability, caster)
		return
	end
	if not keys.nodmg then
		target:EmitSound("Hero_ObsidianDestroyer.ArcaneOrb.Impact")
		local dmg = caster:GetMaxMana() * (ability:GetSpecialValueFor("mana_pool_damage_pct") / 100)
		local damageTable = {
							victim = target,
							attacker = caster,
							damage = dmg,
							damage_type = ability:GetAbilityDamageType(),
							damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, --Optional.
							ability = ability, --Optional.
							}
		local dmg_done = ApplyDamage(damageTable)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, dmg_done, nil)
	end
	if (target:IsRealHero() or target:IsTempestDouble()) and not target:IsClone() then
		for i=1, ability:GetSpecialValueFor("int_gain") do
			caster:AddNewModifier(caster, ability, "modifier_imba_obsidian_destroyer_int_gain_counter", {duration = ability:GetSpecialValueFor("int_buff_duration")})
			target:AddNewModifier(caster, ability, "modifier_imba_obsidian_destroyer_int_lose_counter", {duration = ability:GetSpecialValueFor("int_debuff_duration")})
		end
		caster:AddNewModifier(caster, ability, "modifier_imba_obsidian_destroyer_int_gain", {})
		target:AddNewModifier(caster, ability, "modifier_imba_obsidian_destroyer_int_lose", {})
	end
end

modifier_imba_obsidian_destroyer_int_gain = class({})

function modifier_imba_obsidian_destroyer_int_gain:GetTexture() return "obsidian_destroyer_int_gain" end
function modifier_imba_obsidian_destroyer_int_gain:IsDebuff()			return false end
function modifier_imba_obsidian_destroyer_int_gain:IsHidden() 			return false end
function modifier_imba_obsidian_destroyer_int_gain:IsPurgable() 		return false end
function modifier_imba_obsidian_destroyer_int_gain:IsPurgeException() 	return false end
function modifier_imba_obsidian_destroyer_int_gain:RemoveOnDeath() 		return false end
function modifier_imba_obsidian_destroyer_int_gain:DestroyOnExpire()    return false end
function modifier_imba_obsidian_destroyer_int_gain:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_obsidian_destroyer_int_gain:GetModifierBonusStats_Intellect() return self:GetStackCount() end
function modifier_imba_obsidian_destroyer_int_gain:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
function modifier_imba_obsidian_destroyer_int_gain:OnIntervalThink()
	local buffs = self:GetParent():FindAllModifiersByName("modifier_imba_obsidian_destroyer_int_gain_counter")
	self:SetStackCount(#buffs)
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end

modifier_imba_obsidian_destroyer_int_lose = class({})

function modifier_imba_obsidian_destroyer_int_lose:GetTexture() return "obsidian_destroyer_int_steal" end
function modifier_imba_obsidian_destroyer_int_lose:IsDebuff()			return true end
function modifier_imba_obsidian_destroyer_int_lose:IsHidden() 			return false end
function modifier_imba_obsidian_destroyer_int_lose:IsPurgable() 		return false end
function modifier_imba_obsidian_destroyer_int_lose:IsPurgeException() 	return false end
function modifier_imba_obsidian_destroyer_int_lose:RemoveOnDeath() 		return false end
function modifier_imba_obsidian_destroyer_int_lose:DestroyOnExpire()    return false end
function modifier_imba_obsidian_destroyer_int_lose:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_obsidian_destroyer_int_lose:GetModifierBonusStats_Intellect() return (0 - self:GetStackCount()) end
function modifier_imba_obsidian_destroyer_int_lose:GetAttributes() return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end
function modifier_imba_obsidian_destroyer_int_lose:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
function modifier_imba_obsidian_destroyer_int_lose:OnIntervalThink()
	local buffs = self:GetParent():FindAllModifiersByName("modifier_imba_obsidian_destroyer_int_lose_counter")
	self:SetStackCount(#buffs)
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end

modifier_imba_obsidian_destroyer_int_gain_counter = class({})
function modifier_imba_obsidian_destroyer_int_gain_counter:IsHidden() return true end
function modifier_imba_obsidian_destroyer_int_gain_counter:IsPurgable() return false end
function modifier_imba_obsidian_destroyer_int_gain_counter:IsPurgeException() return false end
function modifier_imba_obsidian_destroyer_int_gain_counter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
modifier_imba_obsidian_destroyer_int_lose_counter = class({})
function modifier_imba_obsidian_destroyer_int_lose_counter:IsHidden() return true end
function modifier_imba_obsidian_destroyer_int_lose_counter:IsPurgable() return false end
function modifier_imba_obsidian_destroyer_int_lose_counter:IsPurgeException() return false end
function modifier_imba_obsidian_destroyer_int_lose_counter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end


imba_obsidian_destroyer_astral_imprisonment = class({})

LinkLuaModifier("modifier_imba_astral_imprisonment", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_astral_imprisonment_thinker", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)

function imba_obsidian_destroyer_astral_imprisonment:IsHiddenWhenStolen() 		return false end
function imba_obsidian_destroyer_astral_imprisonment:IsRefreshable() 			return true end
function imba_obsidian_destroyer_astral_imprisonment:IsStealable() 				return true end
function imba_obsidian_destroyer_astral_imprisonment:IsNetherWardStealable()	return true end

function imba_obsidian_destroyer_astral_imprisonment:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	if not IsEnemy(caster, target) and PlayerResource:IsDisableHelpSetForPlayerID(target:GetPlayerOwnerID(), caster:GetPlayerOwnerID()) then
		target = caster
	end
	caster:EmitSound("Hero_ObsidianDestroyer.AstralImprisonment.Cast")
	if self:GetCaster():HasAbility("imba_obsidian_destroyer_arcane_orb") and target:GetTeamNumber() ~= self:GetCaster():GetTeamNumber() and (target:IsRealHero() or target:IsTempestDouble()) and not target:IsClone() then
		local ability = self:GetCaster():FindAbilityByName("imba_obsidian_destroyer_arcane_orb")
		for i=1, self:GetSpecialValueFor("orb_stacks") do
			local keys = {attacker = self:GetCaster(), target = target, ability = ability, nodmg = true}
			ArcaneOrb_AttackLanded(keys)
		end
	end
	if IsEnemy(target, caster) then
		target:AddNewModifier(caster, self, "modifier_imba_astral_imprisonment", {duration = self:GetSpecialValueFor("prison_duration")})
	else
		target:AddNewModifier(caster, self, "modifier_imba_astral_imprisonment", {duration = self:GetSpecialValueFor("prison_duration")})
	end
end

modifier_imba_astral_imprisonment = class({})

function modifier_imba_astral_imprisonment:IsDebuff()			return true end
function modifier_imba_astral_imprisonment:IsHidden() 			return false end
function modifier_imba_astral_imprisonment:IsPurgable() 		return false end
function modifier_imba_astral_imprisonment:IsPurgeException() 	return false end
function modifier_imba_astral_imprisonment:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_OUT_OF_GAME] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_INVULNERABLE] = true} end

function modifier_imba_astral_imprisonment:OnCreated()
	if IsServer() then
		self:GetParent():EmitSound("Hero_ObsidianDestroyer.AstralImprisonment")
		self:GetParent():AddNoDraw()
		local thinker = CreateModifierThinker(self:GetCaster(), self:GetAbility(), "modifier_imba_astral_imprisonment_thinker", {duration = self:GetDuration() + FrameTime()}, self:GetParent():GetAbsOrigin(), self:GetParent():GetTeamNumber(), false)
		local buff = thinker:FindModifierByName("modifier_imba_astral_imprisonment_thinker")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_prison.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		buff:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_astral_imprisonment:OnRefresh() self:OnCreated() end

function modifier_imba_astral_imprisonment:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveNoDraw()
		self:GetParent():EmitSound(	"Hero_ObsidianDestroyer.AstralImprisonment.End")
	end
end

modifier_imba_astral_imprisonment_thinker = class({})

function modifier_imba_astral_imprisonment_thinker:OnDestroy()
	if IsServer() then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("damage_aoe"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = self:GetAbility():GetSpecialValueFor("damage"),
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			local dmg_done = ApplyDamage(damageTable)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, dmg_done, nil)
		end
	end
end


imba_obsidian_destroyer_essence_aura = class({})

LinkLuaModifier("modifier_imba_essence_aura_caster", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_essence_aura_buff", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_essence_aura_int_gain", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_essence_aura_int_gain_counter", "hero/hero_obsidian_destroyer", LUA_MODIFIER_MOTION_NONE)

function imba_obsidian_destroyer_essence_aura:GetIntrinsicModifierName() return "modifier_imba_essence_aura_caster" end

modifier_imba_essence_aura_caster = class({})

function modifier_imba_essence_aura_caster:IsDebuff()			return false end
function modifier_imba_essence_aura_caster:IsHidden() 			return true end
function modifier_imba_essence_aura_caster:IsPurgable() 		return false end
function modifier_imba_essence_aura_caster:IsPurgeException() 	return false end
function modifier_imba_essence_aura_caster:DeclareFunctions() return {MODIFIER_PROPERTY_MANA_BONUS} end
function modifier_imba_essence_aura_caster:GetModifierManaBonus() return (self:GetStackCount() * self:GetAbility():GetSpecialValueFor("bonus_mana")) end
function modifier_imba_essence_aura_caster:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end
function modifier_imba_essence_aura_caster:OnIntervalThink() self:SetStackCount(self:GetParent():GetIntellect()) end

function modifier_imba_essence_aura_caster:IsAura() return true end
function modifier_imba_essence_aura_caster:GetAuraDuration() return 0.5 end
function modifier_imba_essence_aura_caster:GetModifierAura() return "modifier_imba_essence_aura_buff" end
function modifier_imba_essence_aura_caster:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("radius") end
function modifier_imba_essence_aura_caster:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_essence_aura_caster:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_essence_aura_caster:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end

modifier_imba_essence_aura_buff = class({})

function modifier_imba_essence_aura_buff:IsDebuff()			return false end
function modifier_imba_essence_aura_buff:IsHidden() 		return false end
function modifier_imba_essence_aura_buff:IsPurgable() 		return false end
function modifier_imba_essence_aura_buff:IsPurgeException() return false end
function modifier_imba_essence_aura_buff:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST} end
function modifier_imba_essence_aura_buff:OnAbilityFullyCast(keys)
	if not IsServer() then
		return
	end
	if keys.unit ~= self:GetParent() or self:GetCaster():PassivesDisabled() or ((keys.ability:GetCooldown(keys.ability:GetLevel() - 1) == 0 or keys.ability:GetManaCost(keys.ability:GetLevel() - 1) == 0) and not keys.ability:GetName() == "imba_obsidian_destroyer_arcane_orb") or keys.ability:IsItem() then
		return
	end
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:ReleaseParticleIndex(pfx)
	self:GetParent():SetMana(math.min(self:GetParent():GetMaxMana(), self:GetParent():GetMana() + self:GetParent():GetMaxMana() * (self:GetAbility():GetSpecialValueFor("restore_amount") / 100)))
	if self:GetParent() == self:GetCaster() then
		return
	end
	local int = keys.cost * (self:GetAbility():GetSpecialValueFor("mana_absorb") / 100)
	for i=1, int do
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_essence_aura_int_gain_counter", {duration = self:GetAbility():GetSpecialValueFor("int_duration")})
	end
	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_essence_aura_int_gain", {})
	self:GetParent():EmitSound("Hero_ObsidianDestroyer.EssenceAura")
end

modifier_imba_essence_aura_int_gain = class({})

function modifier_imba_essence_aura_int_gain:IsDebuff()			return false end
function modifier_imba_essence_aura_int_gain:IsHidden() 		return false end
function modifier_imba_essence_aura_int_gain:IsPurgable() 		return false end
function modifier_imba_essence_aura_int_gain:IsPurgeException() return false end
function modifier_imba_essence_aura_int_gain:RemoveOnDeath() 	return false end
function modifier_imba_essence_aura_int_gain:DestroyOnExpire()  return false end
function modifier_imba_essence_aura_int_gain:DeclareFunctions() return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end
function modifier_imba_essence_aura_int_gain:GetModifierBonusStats_Intellect() return self:GetStackCount() end
function modifier_imba_essence_aura_int_gain:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end
function modifier_imba_essence_aura_int_gain:OnIntervalThink()
	local buffs = self:GetParent():FindAllModifiersByName("modifier_imba_essence_aura_int_gain_counter")
	local stack = math.min(#buffs, self:GetParent():GetBaseIntellect() * (self:GetAbility():GetSpecialValueFor("max_int_pct") / 100))
	self:SetStackCount(stack)
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end


modifier_imba_essence_aura_int_gain_counter = class({})
function modifier_imba_essence_aura_int_gain_counter:IsHidden() return true end
function modifier_imba_essence_aura_int_gain_counter:IsPurgable() return false end
function modifier_imba_essence_aura_int_gain_counter:IsPurgeException() return false end
function modifier_imba_essence_aura_int_gain_counter:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end


imba_obsidian_destroyer_sanity_eclipse = class({})

function imba_obsidian_destroyer_sanity_eclipse:IsHiddenWhenStolen() 		return false end
function imba_obsidian_destroyer_sanity_eclipse:IsRefreshable() 			return true end
function imba_obsidian_destroyer_sanity_eclipse:IsStealable() 				return true end
function imba_obsidian_destroyer_sanity_eclipse:IsNetherWardStealable()		return true end
function imba_obsidian_destroyer_sanity_eclipse:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_obsidian_destroyer_sanity_eclipse:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_ObsidianDestroyer.SanityEclipse.Cast")
	local pos = self:GetCursorPosition()
	local radius = self:GetSpecialValueFor("radius")
	local pfx_name = "particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_sanity_eclipse_area.vpcf"
	local sound_name = "Hero_ObsidianDestroyer.SanityEclipse"
	if HeroItems:UnitHasItem(caster, "od_ti8_immortal_wings") then
		pfx_name = "particles/econ/items/outworld_devourer/od_ti8/od_ti8_santies_eclipse_area.vpcf"
		sound_name = "Hero_ObsidianDestroyer.SanityEclipse.TI8"
	end
	local pfx1 = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx1, 0, pos)
	ParticleManager:SetParticleControl(pfx1, 1, Vector(radius, radius, 0))
	ParticleManager:SetParticleControl(pfx1, 2, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(pfx1)
	local sound = CreateModifierThinker(caster, self, "modifier_imba_obsidian_destroyer_int_gain_counter", {duration = 1.0}, pos, caster:GetTeamNumber(), false)
	sound:EmitSound(sound_name)
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if enemy:IsIllusion() then
			enemy:Kill(self, caster)
		else
			local ability = caster:FindAbilityByName("imba_obsidian_destroyer_astral_imprisonment")
			if ability and caster:HasScepter() and ability:GetLevel() > 0 then
				if (not enemy:IsOutOfGame() or (enemy:IsOutOfGame() and enemy:HasModifier("modifier_imba_astral_imprisonment"))) and not enemy:HasModifier("modifier_imba_tricks_of_the_trade_caster") then
					caster:SetCursorCastTarget(enemy)
					ability:OnSpellStart()
				end
			end
			enemy:SetMana(math.max(0, enemy:GetMana() - enemy:GetMaxMana() * (self:GetSpecialValueFor("mana_burn_pct") / 100)))
			local dmg = math.max((caster:GetIntellect() - enemy:GetIntellect()) * self:GetSpecialValueFor("damage_multiplier"), 0)
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = dmg,
								damage_type = self:GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY, --Optional.
								ability = self, --Optional.
								}
			if not enemy:IsOutOfGame() or (enemy:IsOutOfGame() and enemy:HasModifier("modifier_imba_astral_imprisonment")) then
				ApplyDamage(damageTable)
			end
		end
	end
end