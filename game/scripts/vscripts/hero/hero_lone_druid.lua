CreateEmptyTalents("lone_druid")

imba_lone_druid_spirit_bear = class({})

LinkLuaModifier("modifier_imba_spirit_bear_base", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spirit_bear_clone", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_spirit_bear:IsHiddenWhenStolen() 		return false end
function imba_lone_druid_spirit_bear:IsRefreshable() 			return true end
function imba_lone_druid_spirit_bear:IsStealable() 				return false end
function imba_lone_druid_spirit_bear:IsNetherWardStealable()	return false end

function imba_lone_druid_spirit_bear:OnUpgrade()
	if IsServer() and self:GetCaster():IsRealHero() and not self:GetCaster():IsTempestDouble() then
		local caster = self:GetCaster()
		if not self.base_bear then
			self.base_bear = CreateUnitByName("npc_dota_lone_druid_bear1", Vector(30000, 30000, 0), false, caster, caster, caster:GetTeamNumber())
			self.base_bear:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
			self.base_bear:AddNewModifier(caster, self, "modifier_imba_spirit_bear_base", {})
			self.base_bear:ForceKill(false)
		end
		if not self.clone_bear then
			self.clone_bear = CreateUnitByName("npc_dota_lone_druid_bear1", Vector(30000, 30000, 0), false, caster, caster, caster:GetTeamNumber())
			self.clone_bear:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
			self.clone_bear:AddNewModifier(caster, self, "modifier_imba_spirit_bear_clone", {})
			self.clone_bear:SetCanSellItems(false)
			self.clone_bear:ForceKill(false)
		end
		if self.base_bear then
			for i=0, 23 do
				local ability = self.base_bear:GetAbilityByIndex(i)
				if ability then
					ability:SetLevel(self:GetLevel())
				end
			end
			SetCreatureHealth(self.base_bear, self:GetSpecialValueFor("bear_hp"), self.base_bear:IsAlive())
			self.base_bear:SetBaseHealthRegen(self:GetSpecialValueFor("bear_regen"))
			self.base_bear:SetPhysicalArmorBaseValue(self:GetSpecialValueFor("bear_armor"))
			self.base_bear:SetBaseDamageMax(self:GetSpecialValueFor("bear_damage"))
			self.base_bear:SetBaseDamageMin(self:GetSpecialValueFor("bear_damage"))
		end
		if self.clone_bear then
			for i=0, 23 do
				local ability = self.clone_bear:GetAbilityByIndex(i)
				if ability then
					ability:SetLevel(self:GetLevel())
				end
			end
			SetCreatureHealth(self.clone_bear, self:GetSpecialValueFor("bear_hp"), self.clone_bear:IsAlive())
			self.clone_bear:SetBaseHealthRegen(self:GetSpecialValueFor("bear_regen"))
			self.clone_bear:SetPhysicalArmorBaseValue(self:GetSpecialValueFor("bear_armor"))
			self.clone_bear:SetBaseDamageMax(self:GetSpecialValueFor("bear_damage"))
			self.clone_bear:SetBaseDamageMin(self:GetSpecialValueFor("bear_damage"))
		end
	end
end

local forbidden_items = {}
forbidden_items['item_smoke_of_deceit'] = true
forbidden_items['item_tango_single'] = true
forbidden_items['item_clarity'] = true
forbidden_items['item_faerie_fire'] = true
forbidden_items['item_ward_observer'] = true
forbidden_items['item_ward_sentry'] = true
forbidden_items['item_ward_dispenser'] = true
forbidden_items['item_imba_mango'] = true
forbidden_items['item_flask'] = true
forbidden_items['item_tango'] = true
forbidden_items['item_tome_of_knowledge'] = true
forbidden_items['item_dust'] = true
forbidden_items['item_bottle'] = true
forbidden_items['item_imba_soul_of_truth'] = true
forbidden_items['item_imba_moon_shard'] = true
forbidden_items['item_imba_rapier_cursed'] = true
forbidden_items['item_imba_rapier_magic_2'] = true
forbidden_items['item_imba_rapier_magic'] = true
forbidden_items['item_imba_rapier_2'] = true
forbidden_items['item_imba_rapier'] = true
forbidden_items['item_imba_cheese'] = true
forbidden_items['item_gem'] = true
forbidden_items['item_imba_ultimate_scepter_synth'] = true
forbidden_items['item_branches'] = true

function imba_lone_druid_spirit_bear:OnInventoryContentsChanged()
	if not self.clone_bear then
		return
	end
	local caster = self:GetCaster()
	Timers:CreateTimer(0.1, function()
			self.clone_bear:SetHasInventory(true)
			for i=0, 8 do
				local item = self.clone_bear:GetItemInSlot(i)
				if item then
					UTIL_Remove(item)
				end
			end
			for i=0, 8 do
				local item = caster:GetItemInSlot(i)
				if item and not forbidden_items[item:GetAbilityName()] and i <= 2 then
					self.clone_bear:AddItemByName(item:GetAbilityName())
				else
					self.clone_bear:AddItemByName("item_imba_dummy")
				end
			end
			for i=0, 8 do
				local item = self.clone_bear:GetItemInSlot(i)
				if item and item:GetAbilityName() == "item_imba_dummy" then
					UTIL_Remove(item)
				end
			end
			self.clone_bear:SetHasInventory(false)
			return nil
		end
	)
end

function imba_lone_druid_spirit_bear:OnSpellStart()
	local caster = self:GetCaster()
	if self:GetAutoCastState() then
		self.base_bear:ForceKill(false)
		self.clone_bear:RespawnUnit()
		FindClearSpaceForUnit(self.clone_bear, caster:GetAbsOrigin(), true)
		self.clone_bear:SetHealth(self.clone_bear:GetMaxHealth())
		self.clone_bear:SetMana(self.clone_bear:GetMaxMana())
		self.clone_bear:EmitSound("Hero_LoneDruid.SpiritBear.Cast")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.clone_bear)
		ParticleManager:ReleaseParticleIndex(pfx)
	else
		self.clone_bear:ForceKill(false)
		self.base_bear:RespawnUnit()
		FindClearSpaceForUnit(self.base_bear, caster:GetAbsOrigin(), true)
		self.base_bear:SetHealth(self.base_bear:GetMaxHealth())
		self.base_bear:SetMana(self.base_bear:GetMaxMana())
		self.base_bear:EmitSound("Hero_LoneDruid.SpiritBear.Cast")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.base_bear)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

modifier_imba_spirit_bear_base = class({})

function modifier_imba_spirit_bear_base:IsDebuff()			return false end
function modifier_imba_spirit_bear_base:IsHidden() 			return true end
function modifier_imba_spirit_bear_base:IsPurgable() 		return false end
function modifier_imba_spirit_bear_base:IsPurgeException() 	return false end
function modifier_imba_spirit_bear_base:RemoveOnDeath()     return false end
function modifier_imba_spirit_bear_base:IsPermanent() 		return true end
function modifier_imba_spirit_bear_base:DeclareFunctions() return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT} end
function modifier_imba_spirit_bear_base:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("bear_bat") + self:GetCaster():GetTalentValue("special_bonus_imba_lone_druid_1") end

modifier_imba_spirit_bear_clone = class({})

function modifier_imba_spirit_bear_clone:IsDebuff()			return false end
function modifier_imba_spirit_bear_clone:IsHidden() 		return true end
function modifier_imba_spirit_bear_clone:IsPurgable() 		return false end
function modifier_imba_spirit_bear_clone:IsPurgeException() return false end
function modifier_imba_spirit_bear_clone:RemoveOnDeath()    return false end
function modifier_imba_spirit_bear_clone:IsPermanent() 		return true end
function modifier_imba_spirit_bear_clone:DeclareFunctions() return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT} end
function modifier_imba_spirit_bear_clone:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("bear_bat") + self:GetCaster():GetTalentValue("special_bonus_imba_lone_druid_1") end

function modifier_imba_spirit_bear_clone:OnCreated()
	if IsServer() then
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_spirit_bear_clone:OnIntervalThink()
	for i=0, 8 do
		local item = self.parent:GetItemInSlot(i)
		if item then
			item:SetDroppable(false)
			if forbidden_items[item:GetAbilityName()] then
				UTIL_Remove(item)
				return
			end
		end
		local hero_item = self.caster:GetItemInSlot(i)
		if hero_item and item then
			if item:IsCooldownReady() and not hero_item:IsCooldownReady() then
				item:EndCooldown()
				item:StartCooldown(hero_item:GetCooldownTimeRemaining())
			elseif not item:IsCooldownReady() and hero_item:IsCooldownReady() then
				hero_item:EndCooldown()
				hero_item:StartCooldown(item:GetCooldownTimeRemaining())
			end
		end
	end
end

imba_lone_druid_spirit_bear_return = class({})

LinkLuaModifier("modifier_imba_spirit_bear_return_passive", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spirit_bear_return_damage", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_spirit_bear_return:IsHiddenWhenStolen() 	return false end
function imba_lone_druid_spirit_bear_return:IsRefreshable() 		return true end
function imba_lone_druid_spirit_bear_return:IsStealable() 			return false end
function imba_lone_druid_spirit_bear_return:IsNetherWardStealable()	return false end
function imba_lone_druid_spirit_bear_return:GetIntrinsicModifierName() return "modifier_imba_spirit_bear_return_passive" end
function imba_lone_druid_spirit_bear_return:GetCastPoint() return (self:GetCaster():HasModifier("modifier_imba_spirit_bear_return_damage") and self:GetSpecialValueFor("damage_bonus_castpoint") or 0) end

function imba_lone_druid_spirit_bear_return:OnSpellStart()
	local bear = self:GetCaster()
	bear:EmitSound("LoneDruid_SpiritBear.Return")
	local caster = bear:GetOwnerEntity()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_start.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, bear:GetAbsOrigin())
	FindClearSpaceForUnit(bear, caster:GetAbsOrigin(), true)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_blink_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, bear)
	ParticleManager:ReleaseParticleIndex(pfx)
	ParticleManager:ReleaseParticleIndex(pfx2)
end

modifier_imba_spirit_bear_return_passive = class({})

function modifier_imba_spirit_bear_return_passive:IsDebuff()			return false end
function modifier_imba_spirit_bear_return_passive:IsHidden() 			return true end
function modifier_imba_spirit_bear_return_passive:IsPurgable() 			return false end
function modifier_imba_spirit_bear_return_passive:IsPurgeException() 	return false end
function modifier_imba_spirit_bear_return_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_TAKEDAMAGE} end

function modifier_imba_spirit_bear_return_passive:OnTakeDamage(keys)
	if not IsServer() then
		return 
	end
	if keys.unit == self:GetParent() and (keys.attacker:IsRealHero() or keys.attacker:IsTower()) and self:GetParent():IsAlive() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_spirit_bear_return_damage", {duration = self:GetAbility():GetSpecialValueFor("damage_duration")})
	end
end

modifier_imba_spirit_bear_return_damage = class({})

function modifier_imba_spirit_bear_return_damage:IsDebuff()			return true end
function modifier_imba_spirit_bear_return_damage:IsHidden() 		return false end
function modifier_imba_spirit_bear_return_damage:IsPurgable() 		return false end
function modifier_imba_spirit_bear_return_damage:IsPurgeException() return false end
function modifier_imba_spirit_bear_return_damage:RemoveOnDeath() return false end

imba_lone_druid_spirit_bear_entangle = class({})

LinkLuaModifier("modifier_imba_spirit_bear_entangle_passive", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spirit_bear_entangle_debuff", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_spirit_bear_entangle:GetIntrinsicModifierName() return "modifier_imba_spirit_bear_entangle_passive" end

modifier_imba_spirit_bear_entangle_passive = class({})

function modifier_imba_spirit_bear_entangle_passive:IsDebuff()			return false end
function modifier_imba_spirit_bear_entangle_passive:IsHidden() 			return true end
function modifier_imba_spirit_bear_entangle_passive:IsPurgable() 		return false end
function modifier_imba_spirit_bear_entangle_passive:IsPurgeException() 	return false end
function modifier_imba_spirit_bear_entangle_passive:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_spirit_bear_entangle_passive:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.target:IsAlive() and keys.attacker == self:GetParent() and not self:GetParent():PassivesDisabled() and keys.target:IsUnit() and not keys.target:IsBoss() and not keys.target:IsMagicImmune() and self:GetAbility():IsCooldownReady() then
		if PseudoRandom:RollPseudoRandom(self:GetAbility(), self:GetAbility():GetSpecialValueFor("entangle_chance")) then
			if keys.target:IsHero() then
				keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_spirit_bear_entangle_debuff", {duration = self:GetAbility():GetSpecialValueFor("hero_duration")})
			else
				keys.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_spirit_bear_entangle_debuff", {duration = self:GetAbility():GetSpecialValueFor("creep_duration")})
			end
			keys.target:InterruptChannel()
			keys.target:EmitSound("LoneDruid_SpiritBear.Entangle")
			self:GetAbility():UseResources(true, true, true)
		end
	end
end

modifier_imba_spirit_bear_entangle_debuff = class({})

function modifier_imba_spirit_bear_entangle_debuff:IsDebuff()			return true end
function modifier_imba_spirit_bear_entangle_debuff:IsHidden() 			return false end
function modifier_imba_spirit_bear_entangle_debuff:IsPurgable() 		return true end
function modifier_imba_spirit_bear_entangle_debuff:IsPurgeException() 	return true end
function modifier_imba_spirit_bear_entangle_debuff:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_imba_spirit_bear_entangle_debuff:CheckState() return {[MODIFIER_STATE_ROOTED] = true, [MODIFIER_STATE_DISARMED] = true, [MODIFIER_STATE_INVISIBLE] = false} end
function modifier_imba_spirit_bear_entangle_debuff:GetEffectName() return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf" end
function modifier_imba_spirit_bear_entangle_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_spirit_bear_entangle_debuff:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_spirit_bear_entangle_debuff:OnIntervalThink()
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("damage_per_sec"), damage_type = self:GetAbility():GetAbilityDamageType()})
end

imba_lone_druid_spirit_bear_demolish = class({})

LinkLuaModifier("modifier_imba_spirit_bear_demolish_passive", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_spirit_bear_demolish:GetIntrinsicModifierName() return "modifier_imba_spirit_bear_demolish_passive" end

modifier_imba_spirit_bear_demolish_passive = class({})

function modifier_imba_spirit_bear_demolish_passive:IsDebuff()			return false end
function modifier_imba_spirit_bear_demolish_passive:IsHidden() 			return true end
function modifier_imba_spirit_bear_demolish_passive:IsPurgable() 		return false end
function modifier_imba_spirit_bear_demolish_passive:IsPurgeException() 	return false end
function modifier_imba_spirit_bear_demolish_passive:DeclareFunctions() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE} end
function modifier_imba_spirit_bear_demolish_passive:GetModifierMagicalResistanceBonus() return self:GetAbility():GetSpecialValueFor("spell_resistance") end

function modifier_imba_spirit_bear_demolish_passive:GetModifierTotalDamageOutgoing_Percentage(keys)
	if not IsServer() then
		return
	end
	if not self:GetParent():PassivesDisabled() and keys.target:IsBuilding() then
		return self:GetAbility():GetSpecialValueFor("bonus_building_damage")
	end
end

imba_lone_druid_spirit_link = class({})

LinkLuaModifier("modifier_imba_spirit_link_passive", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spirit_link", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_spirit_link_active", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_spirit_link:IsHiddenWhenStolen() 		return false end
function imba_lone_druid_spirit_link:IsRefreshable() 			return true end
function imba_lone_druid_spirit_link:IsStealable() 				return true end
function imba_lone_druid_spirit_link:IsNetherWardStealable()	return true end
function imba_lone_druid_spirit_link:GetIntrinsicModifierName() return "modifier_imba_spirit_link_passive" end

function imba_lone_druid_spirit_link:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_LoneDruid.SpiritLink.Cast")
	local ability = caster:FindAbilityByName("imba_lone_druid_spirit_bear")
	local target = caster
	if ability and ability:GetLevel() > 0 then
		if ability.clone_bear:IsAlive() then
			target = ability.clone_bear
		elseif ability.base_bear:IsAlive() then
			target = ability.base_bear
		end
	end
	target:EmitSound("Hero_LoneDruid.SpiritLink.Bear")
	local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx1, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx1, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx1)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_cast_ld.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx2, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx2, 2, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx2, 3, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx2)
	local pfx3 = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_cast_ld.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(pfx3, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx3, 2, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx3, 3, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx3)
	caster:AddNewModifier(caster, self, "modifier_imba_spirit_link_active", {duration = self:GetSpecialValueFor("duration")})
	target:AddNewModifier(caster, self, "modifier_imba_spirit_link_active", {duration = self:GetSpecialValueFor("duration")})
end

modifier_imba_spirit_link_passive = class({})

function modifier_imba_spirit_link_passive:IsDebuff()			return false end
function modifier_imba_spirit_link_passive:IsHidden() 			return true end
function modifier_imba_spirit_link_passive:IsPurgable() 		return false end
function modifier_imba_spirit_link_passive:IsPurgeException() 	return false end
function modifier_imba_spirit_link_passive:IsAura() return ((not self:GetCaster():PassivesDisabled() and self:GetCaster():IsRealHero()) or self:GetCaster():HasModifier("modifier_imba_spirit_link_active")) end
function modifier_imba_spirit_link_passive:GetAuraDuration() return 0.1 end
function modifier_imba_spirit_link_passive:GetModifierAura() return "modifier_imba_spirit_link" end
function modifier_imba_spirit_link_passive:GetAuraRadius() return 50000 end
function modifier_imba_spirit_link_passive:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS end
function modifier_imba_spirit_link_passive:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_spirit_link_passive:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_spirit_link_passive:GetAuraEntityReject(unit)
	if unit == self:GetCaster() or (unit:GetUnitName() == "npc_dota_lone_druid_bear1" and unit:GetPlayerOwnerID() == self:GetCaster():GetPlayerOwnerID()) then
		return false
	end
	return true
end

modifier_imba_spirit_link = class({})

function modifier_imba_spirit_link:IsDebuff()			return false end
function modifier_imba_spirit_link:IsHidden() 			return true end
function modifier_imba_spirit_link:IsPurgable() 		return false end
function modifier_imba_spirit_link:IsPurgeException() 	return false end
function modifier_imba_spirit_link:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_spirit_link:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.target:IsAlive() and keys.attacker == self:GetParent() and keys.target:IsUnit() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local target = nil
		if parent == caster then
			if caster:HasAbility("imba_lone_druid_spirit_bear") and (not self.bear or not self.bear:IsAlive()) then
				local bear = caster:FindAbilityByName("imba_lone_druid_spirit_bear")
				self.bear = bear:GetLevel() > 0 and (bear.clone_bear:IsAlive() and bear.clone_bear or (bear.base_bear:IsAlive() and bear.base_bear or nil)) or nil
			end
			if self.bear then
				target = self.bear
			else
				return
			end
		else
			target = caster
		end
		target:Heal(keys.damage * (ability:GetSpecialValueFor("lifesteal_percent") / 100), ability)
		local pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

modifier_imba_spirit_link_active = class({})

function modifier_imba_spirit_link_active:IsDebuff()			return false end
function modifier_imba_spirit_link_active:IsHidden() 			return false end
function modifier_imba_spirit_link_active:IsPurgable() 			return true end
function modifier_imba_spirit_link_active:IsPurgeException() 	return true end
function modifier_imba_spirit_link_active:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS} end
function modifier_imba_spirit_link_active:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("bonus_attack_speed") end
function modifier_imba_spirit_link_active:GetModifierProjectileSpeedBonus() return self:GetAbility():GetSpecialValueFor("bonus_projectile_speed") end
function modifier_imba_spirit_link_active:CheckState() return {[MODIFIER_STATE_UNSLOWABLE] = self:GetCaster() ~= self:GetParent(), [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_spirit_link_active:GetEffectName() return "particles/units/heroes/hero_lone_druid/lone_druid_spiritlink_buff.vpcf" end
function modifier_imba_spirit_link_active:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

imba_lone_druid_savage_roar = class({})

LinkLuaModifier("modifier_imba_savage_roar", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_savage_roar:IsHiddenWhenStolen() 		return false end
function imba_lone_druid_savage_roar:IsRefreshable() 			return true end
function imba_lone_druid_savage_roar:IsStealable() 				return true end
function imba_lone_druid_savage_roar:IsNetherWardStealable()	return true end
function imba_lone_druid_savage_roar:GetCastRange() return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus() end
function imba_lone_druid_savage_roar:GetCooldown(i) return (self.BaseClass.GetCooldown(self, i) + self:GetCaster():GetTalentValue("special_bonus_imba_lone_druid_2")) end

function imba_lone_druid_savage_roar:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_LoneDruid.SavageRoar.Cast")
	local pos = caster:GetAbsOrigin()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT, "attach_mouth", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlForward(pfx, 1, caster:GetForwardVector())
	ParticleManager:ReleaseParticleIndex(pfx)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		if enemy[i]:GetTeamNumber() == DOTA_TEAM_GOODGUYS or enemy[i]:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			enemy[i]:RemoveModifierByName("modifier_imba_savage_roar")
			enemy[i]:Purge(true, false, false, false, false)
			enemy[i]:Stop()
			enemy[i]:AddNewModifier(caster, self, "modifier_imba_savage_roar", {duration = self:GetSpecialValueFor("duration")})
			enemy[i]:InterruptChannel()
		end
	end
end

modifier_imba_savage_roar = class({})

function modifier_imba_savage_roar:IsDebuff()			return true end
function modifier_imba_savage_roar:IsHidden() 			return false end
function modifier_imba_savage_roar:IsPurgable() 		return true end
function modifier_imba_savage_roar:IsPurgeException() 	return true end
function modifier_imba_savage_roar:CheckState() return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true, [MODIFIER_STATE_DISARMED] = true} end
function modifier_imba_savage_roar:GetEffectName() return "particles/basic_ambient/generic_scared.vpcf" end
function modifier_imba_savage_roar:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_savage_roar:ShouldUseOverheadOffset() return true end
function modifier_imba_savage_roar:GetStatusEffectName() return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf" end
function modifier_imba_savage_roar:StatusEffectPriority() return 15 end

function modifier_imba_savage_roar:OnCreated()
	if IsServer() then
		self:GetParent():Stop()
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, 15, false, false)
		local target = CDOTAGamerules.IMBA_FORT[self:GetParent():GetTeamNumber()]
		if target and self:GetParent():GetMaxHealth() >= self:GetCaster():GetMaxHealth() then
			self:GetParent():MoveToNPC(target)
		end
	end
end

imba_lone_druid_true_form_battle_cry = class({})

LinkLuaModifier("modifier_imba_true_form_battle_cry", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_true_form_battle_cry_magic_immune", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_true_form_battle_cry:IsHiddenWhenStolen() 		return false end
function imba_lone_druid_true_form_battle_cry:IsRefreshable() 			return true end
function imba_lone_druid_true_form_battle_cry:IsStealable() 			return true end
function imba_lone_druid_true_form_battle_cry:IsNetherWardStealable()	return true end
function imba_lone_druid_true_form_battle_cry:GetAssociatedPrimaryAbilities() return "imba_lone_druid_true_form" end
function imba_lone_druid_true_form_battle_cry:GetCastPoint() return self:GetCaster():HasModifier("modifier_imba_true_form") and 0 or self:GetSpecialValueFor("cast_point") end
function imba_lone_druid_true_form_battle_cry:GetCooldown(i) return (self.BaseClass.GetCooldown(self, i) + self:GetCaster():GetTalentValue("special_bonus_imba_lone_druid_3")) end

function imba_lone_druid_true_form_battle_cry:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_LoneDruid.BattleCry")
	local unit = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, 50000, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #unit do
		if unit[i]:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then
			unit[i]:AddNewModifier(caster, self, "modifier_imba_true_form_battle_cry", {duration = self:GetSpecialValueFor("cry_duration")})
			unit[i]:AddNewModifier(caster, self, "modifier_imba_true_form_battle_cry_magic_immune", {duration = self:GetSpecialValueFor("magic_immune_duration") + caster:GetTalentValue("special_bonus_imba_lone_druid_4")})
			unit[i]:Purge(false, true, false, false, false)
			unit[i]:EmitSound("Hero_LoneDruid.BattleCry.Bear")
		end
	end
end

modifier_imba_true_form_battle_cry = class({})

function modifier_imba_true_form_battle_cry:IsDebuff()			return false end
function modifier_imba_true_form_battle_cry:IsHidden() 			return false end
function modifier_imba_true_form_battle_cry:IsPurgable() 		return true end
function modifier_imba_true_form_battle_cry:IsPurgeException() 	return true end
function modifier_imba_true_form_battle_cry:GetEffectName() return "particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_overhead.vpcf" end
function modifier_imba_true_form_battle_cry:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_true_form_battle_cry:ShouldUseOverheadOffset() return true end
function modifier_imba_true_form_battle_cry:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end
function modifier_imba_true_form_battle_cry:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_true_form_battle_cry:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end

function modifier_imba_true_form_battle_cry:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_imba_true_form_battle_cry_magic_immune = class({})

function modifier_imba_true_form_battle_cry_magic_immune:IsDebuff()			return false end
function modifier_imba_true_form_battle_cry_magic_immune:IsHidden() 		return false end
function modifier_imba_true_form_battle_cry_magic_immune:IsPurgable() 		return false end
function modifier_imba_true_form_battle_cry_magic_immune:IsPurgeException() return false end
function modifier_imba_true_form_battle_cry_magic_immune:CheckState() return {[MODIFIER_STATE_MAGIC_IMMUNE] = true} end
function modifier_imba_true_form_battle_cry_magic_immune:GetEffectName() return "particles/items_fx/black_king_bar_avatar.vpcf" end
function modifier_imba_true_form_battle_cry_magic_immune:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

imba_lone_druid_true_form = class({})

LinkLuaModifier("modifier_imba_true_form_trans", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_true_form_untrans", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_true_form", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_true_form_attack_range", "hero/hero_lone_druid.lua", LUA_MODIFIER_MOTION_NONE)

function imba_lone_druid_true_form:IsHiddenWhenStolen() 	return false end
function imba_lone_druid_true_form:IsRefreshable() 			return true end
function imba_lone_druid_true_form:IsStealable() 			return true end
function imba_lone_druid_true_form:IsNetherWardStealable()	return false end
function imba_lone_druid_true_form:GetAssociatedSecondaryAbilities() return "imba_lone_druid_true_form_battle_cry" end
function imba_lone_druid_true_form:OnUnStolen() self:GetCaster():RemoveModifierByName("modifier_imba_true_form") end
function imba_lone_druid_true_form:OnUpgrade()
	if IsServer() and self:GetCaster():HasAbility("imba_lone_druid_true_form_battle_cry") then
		self:GetCaster():FindAbilityByName("imba_lone_druid_true_form_battle_cry"):SetLevel(self:GetLevel())
	end
end

function imba_lone_druid_true_form:OnToggle()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	if self:GetToggleState() then
		caster:AddNewModifier(caster, self, "modifier_imba_true_form_trans", {duration = self:GetSpecialValueFor("transformation_time")})
		caster:EmitSound("Hero_LoneDruid.TrueForm.Cast")
	else
		caster:AddNewModifier(caster, self, "modifier_imba_true_form_untrans", {duration = self:GetSpecialValueFor("transformation_time")})
		caster:EmitSound("Hero_LoneDruid.TrueForm.Recast")
	end
	self:StartCooldown(self:GetSpecialValueFor("transformation_time"))
end

modifier_imba_true_form_trans = class({})

function modifier_imba_true_form_trans:IsDebuff()			return false end
function modifier_imba_true_form_trans:IsHidden() 			return false end
function modifier_imba_true_form_trans:IsPurgable() 		return false end
function modifier_imba_true_form_trans:IsPurgeException() 	return false end
function modifier_imba_true_form_trans:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_true_form_trans:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_true_form_trans:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_3 end

function modifier_imba_true_form_trans:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_true_form.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward(pfx, 3, self:GetParent():GetForwardVector())
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_true_form_trans:OnDestroy()
	if IsServer() and self:GetElapsedTime() >= self:GetDuration() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_true_form", {})
	end
end

modifier_imba_true_form = class({})

function modifier_imba_true_form:IsDebuff()			return false end
function modifier_imba_true_form:IsHidden() 		return false end
function modifier_imba_true_form:IsPurgable() 		return false end
function modifier_imba_true_form:IsPurgeException() return false end
function modifier_imba_true_form:CheckState() return {[MODIFIER_STATE_UNSLOWABLE] = true} end
function modifier_imba_true_form:DeclareFunctions() return {MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_HEALTH_BONUS} end
function modifier_imba_true_form:GetModifierModelChange() return "models/heroes/lone_druid/true_form.vmdl" end
function modifier_imba_true_form:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("base_attack_time") end
function modifier_imba_true_form:GetModifierPhysicalArmorBonus() return self:GetAbility():GetSpecialValueFor("bonus_armor") end
function modifier_imba_true_form:GetModifierHealthBonus() return self:GetAbility():GetSpecialValueFor("bonus_hp") end

function modifier_imba_true_form:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_true_form_attack_range", {})
	end
end

function modifier_imba_true_form:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_imba_true_form_attack_range")
	end
end

modifier_imba_true_form_attack_range = class({})

function modifier_imba_true_form_attack_range:IsDebuff()			return false end
function modifier_imba_true_form_attack_range:IsHidden() 			return true end
function modifier_imba_true_form_attack_range:IsPurgable() 			return false end
function modifier_imba_true_form_attack_range:IsPurgeException() 	return false end
function modifier_imba_true_form_attack_range:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_imba_true_form_attack_range:GetModifierAttackRangeBonus() return (0 - self:GetStackCount()) end

function modifier_imba_true_form_attack_range:OnCreated()
	if IsServer() then
		self:SetStackCount(self:GetParent():GetBaseAttackRange() - 150)
		self.attack_cap = self:GetParent():GetAttackCapability()
		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_MELEE_ATTACK)
	end
end

function modifier_imba_true_form_attack_range:OnDestroy()
	if IsServer() then
		self:GetParent():SetAttackCapability(self.attack_cap)
		self.attack_cap = nil
	end
end

modifier_imba_true_form_untrans = class({})

function modifier_imba_true_form_untrans:IsDebuff()			return false end
function modifier_imba_true_form_untrans:IsHidden() 		return false end
function modifier_imba_true_form_untrans:IsPurgable() 		return false end
function modifier_imba_true_form_untrans:IsPurgeException() return false end
function modifier_imba_true_form_untrans:CheckState() return {[MODIFIER_STATE_STUNNED] = true} end
function modifier_imba_true_form_untrans:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_true_form_untrans:GetOverrideAnimation() return ACT_DOTA_OVERRIDE_ABILITY_4 end

function modifier_imba_true_form_untrans:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/true_form_lone_druid.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlForward(pfx, 3, self:GetParent():GetForwardVector())
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_true_form_untrans:OnDestroy()
	if IsServer() then
		self:GetParent():EmitSound("Hero_LoneDruid.TrueForm.RecastComplete")
		self:GetParent():RemoveModifierByName("modifier_imba_true_form")
	end
end
