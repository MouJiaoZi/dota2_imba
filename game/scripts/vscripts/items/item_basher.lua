item_imba_basher = class({})

LinkLuaModifier("modifier_imba_basher_passive", "items/item_basher", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_basher_unique", "items/item_basher", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_basher_break_count", "items/item_basher", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_basher_break", "items/item_basher", LUA_MODIFIER_MOTION_NONE)

function item_imba_basher:GetIntrinsicModifierName() return "modifier_imba_basher_passive" end

modifier_imba_basher_passive = class({})

function modifier_imba_basher_passive:IsDebuff()			return false end
function modifier_imba_basher_passive:IsHidden() 			return true end
function modifier_imba_basher_passive:IsPurgable() 			return false end
function modifier_imba_basher_passive:IsPurgeException() 	return false end
function modifier_imba_basher_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_basher_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_basher_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_basher_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end

function modifier_imba_basher_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_basher_unique", {})
		if HeroItems:UnitHasItem(self:GetParent(), "skullbasher.vmdl") then
			local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_ambient_skullbasher.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h1", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx, true, false, 15, false, false)
			if HeroItems:UnitHasItem(self:GetParent(), "skullbasher_offhand.vmdl") then
				local pfx2 = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_ambient_skullbasher_offhand.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h2", self:GetParent():GetAbsOrigin(), true)
				self:AddParticle(pfx2, true, false, 15, false, false)
			end
		elseif HeroItems:UnitHasItem(self:GetParent(), "skullbasher_gold.vmdl") then
			local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_ambient_skullbasher_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h1", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx, true, false, 15, false, false)
			if HeroItems:UnitHasItem(self:GetParent(), "skullbasher_gold_offhand.vmdl") then
				local pfx2 = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_ambient_skullbasher_offhand_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h2", self:GetParent():GetAbsOrigin(), true)
				self:AddParticle(pfx2, true, false, 15, false, false)
			end
		end
	end
end

function modifier_imba_basher_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_basher_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_basher_unique")
	end
end

modifier_imba_basher_unique = class({})

function modifier_imba_basher_unique:IsDebuff()			return false end
function modifier_imba_basher_unique:IsHidden() 		return true end
function modifier_imba_basher_unique:IsPurgable() 		return false end
function modifier_imba_basher_unique:IsPurgeException() return false end
function modifier_imba_basher_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_basher_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_basher_unique:OnDestroy() self.ability = nil end

function modifier_imba_basher_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():HasAbility("slardar_bash") or self:GetParent():HasAbility("spirit_breaker_greater_bash") or self:GetParent():HasAbility("imba_faceless_void_time_lock") or self:GetParent():HasAbility("imba_troll_warlord_berserkers_rage") then
		return
	end
	if keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():IsIllusion() and not self:GetParent():HasModifier("modifier_imba_abyssal_blade_unique") and self.ability:IsCooldownReady() and keys.target:IsAlive() then
		local pct = self:GetParent():IsRangedAttacker() and self.ability:GetSpecialValueFor("bash_chance_ranged") or self.ability:GetSpecialValueFor("bash_chance_melee")
		local bat_pct = ((self:GetParent():GetDefaultBAT() - self:GetParent():GetBaseAttackTime()) / self:GetParent():GetDefaultBAT())
		if bat_pct > 0 then
			pct = pct - (pct * bat_pct)
		end
		if PseudoRandom:RollPseudoRandom(self.ability, pct) then
			local bash_duration = self.ability:GetSpecialValueFor("bash_duration")
			if bat_pct > 0 then
				bash_duration = bash_duration - (bash_duration * bat_pct)
			end
			keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_bashed", {duration = bash_duration})
			if keys.target:HasModifier("modifier_imba_basher_break_count") then
				keys.target:RemoveModifierByName("modifier_imba_basher_break_count")
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break", {duration = self.ability:GetSpecialValueFor("break_duration")})
			else
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break_count", {duration = self.ability:GetSpecialValueFor("break_need_duration")})
			end
			ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self.ability, damage = self.ability:GetSpecialValueFor("bonus_chance_damage"), damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, self.ability:GetSpecialValueFor("bonus_chance_damage"), nil)
			keys.target:EmitSound("DOTA_Item.MKB.Minibash")
			self.ability:UseResources(true, true, true)
			if HeroItems:UnitHasItem(self:GetParent(), "skullbasher.vmdl") then
				local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_basher.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControlForward(pfx, 0, keys.target:GetForwardVector())
				ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 3, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(pfx)
			elseif HeroItems:UnitHasItem(self:GetParent(), "skullbasher_gold.vmdl") then
				local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_gold.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControlForward(pfx, 0, keys.target:GetForwardVector())
				ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 3, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(pfx)
			end
		end
	end
end

modifier_imba_basher_break_count = class({})

function modifier_imba_basher_break_count:IsDebuff()			return true end
function modifier_imba_basher_break_count:IsHidden() 			return false end
function modifier_imba_basher_break_count:IsPurgable() 			return false end
function modifier_imba_basher_break_count:IsPurgeException()	return false end

modifier_imba_basher_break = class({})

function modifier_imba_basher_break:IsDebuff()			return true end
function modifier_imba_basher_break:IsHidden() 			return false end
function modifier_imba_basher_break:IsPurgable() 		return false end
function modifier_imba_basher_break:IsPurgeException()	return false end
function modifier_imba_basher_break:CheckState() return {[MODIFIER_STATE_PASSIVES_DISABLED] = true} end
function modifier_imba_basher_break:GetEffectName() return "particles/items3_fx/silver_edge.vpcf" end


item_imba_abyssal_blade = class({})

LinkLuaModifier("modifier_imba_abyssal_blade_passive", "items/item_basher", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_abyssal_blade_unique", "items/item_basher", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_abyssal_blade_cooldown", "items/item_basher", LUA_MODIFIER_MOTION_NONE)

function item_imba_abyssal_blade:GetIntrinsicModifierName() return "modifier_imba_abyssal_blade_passive" end
function item_imba_abyssal_blade:GetCastRange(pos, tar)
	if not self:GetCaster():IsRangedAttacker() then
		return (self:GetCaster():Script_GetAttackRange() + 50)
	else
		return self:GetSpecialValueFor("cast_range")
	end
end

function item_imba_abyssal_blade:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("DOTA_Item.AbyssalBlade.Activate")
	local pfx = ParticleManager:CreateParticle("particles/items_fx/abyssal_blade.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(pfx)
	target:AddNewModifier(caster, self, "modifier_imba_basher_break", {duration = self:GetSpecialValueFor("stun_duration")})
	target:AddNewModifier(caster, self, "modifier_imba_bashed", {duration = self:GetSpecialValueFor("stun_duration")})
end

modifier_imba_abyssal_blade_passive = class({})

function modifier_imba_abyssal_blade_passive:IsDebuff()				return false end
function modifier_imba_abyssal_blade_passive:IsHidden() 			return true end
function modifier_imba_abyssal_blade_passive:IsPurgable() 			return false end
function modifier_imba_abyssal_blade_passive:IsPurgeException() 	return false end
function modifier_imba_abyssal_blade_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_abyssal_blade_passive:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end
function modifier_imba_abyssal_blade_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_abyssal_blade_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_strength") end

function modifier_imba_abyssal_blade_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_abyssal_blade_unique", {})
		if HeroItems:UnitHasItem(self:GetParent(), "skullbasher.vmdl") then
			local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_ambient_skullbasher.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h1", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx, true, false, 15, false, false)
			if HeroItems:UnitHasItem(self:GetParent(), "skullbasher_offhand.vmdl") then
				local pfx2 = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/antimage_ambient_skullbasher_offhand.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h2", self:GetParent():GetAbsOrigin(), true)
				self:AddParticle(pfx2, true, false, 15, false, false)
			end
		elseif HeroItems:UnitHasItem(self:GetParent(), "skullbasher_gold.vmdl") then
			local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_ambient_skullbasher_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h1", self:GetParent():GetAbsOrigin(), true)
			self:AddParticle(pfx, true, false, 15, false, false)
			if HeroItems:UnitHasItem(self:GetParent(), "skullbasher_gold_offhand.vmdl") then
				local pfx2 = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/antimage_ambient_skullbasher_offhand_gold.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
				ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_h2", self:GetParent():GetAbsOrigin(), true)
				self:AddParticle(pfx2, true, false, 15, false, false)
			end
		end
	end
end

function modifier_imba_abyssal_blade_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_abyssal_blade_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_abyssal_blade_unique")
	end
end

modifier_imba_abyssal_blade_unique = class({})

function modifier_imba_abyssal_blade_unique:IsDebuff()			return false end
function modifier_imba_abyssal_blade_unique:IsHidden() 			return true end
function modifier_imba_abyssal_blade_unique:IsPurgable() 		return false end
function modifier_imba_abyssal_blade_unique:IsPurgeException() 	return false end
function modifier_imba_abyssal_blade_unique:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_abyssal_blade_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_abyssal_blade_unique:OnDestroy() self.ability = nil end

function modifier_imba_abyssal_blade_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if self:GetParent():HasAbility("slardar_bash") or self:GetParent():HasAbility("spirit_breaker_greater_bash") or self:GetParent():HasAbility("imba_faceless_void_time_lock") or self:GetParent():HasAbility("imba_troll_warlord_berserkers_rage") then
		return
	end
	if keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():IsIllusion() and not self:GetParent():HasModifier("modifier_imba_abyssal_blade_cooldown") and keys.target:IsAlive() then
		local pct = self:GetParent():IsRangedAttacker() and self.ability:GetSpecialValueFor("bash_chance_ranged") or self.ability:GetSpecialValueFor("bash_chance_melee")
		local bat_pct = ((self:GetParent():GetDefaultBAT() - self:GetParent():GetBaseAttackTime()) / self:GetParent():GetDefaultBAT())
		if bat_pct > 0 then
			pct = pct - (pct * bat_pct)
		end
		if PseudoRandom:RollPseudoRandom(self.ability, pct) then
			local bash_duration = self.ability:GetSpecialValueFor("bash_duration")
			if bat_pct > 0 then
				bash_duration = bash_duration - (bash_duration * bat_pct)
			end
			keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_bashed", {duration = bash_duration})
			self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_imba_abyssal_blade_cooldown", {duration = self.ability:GetSpecialValueFor("bash_cooldown")})
			if keys.target:HasModifier("modifier_imba_basher_break_count") then
				keys.target:RemoveModifierByName("modifier_imba_basher_break_count")
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break", {duration = self.ability:GetSpecialValueFor("break_duration")})
			else
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break_count", {duration = self.ability:GetSpecialValueFor("break_need_duration")})
			end
			ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self.ability, damage = self.ability:GetSpecialValueFor("bonus_chance_damage"), damage_type = DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, self.ability:GetSpecialValueFor("bonus_chance_damage"), nil)
			keys.target:EmitSound("DOTA_Item.MKB.Minibash")
			if HeroItems:UnitHasItem(self:GetParent(), "skullbasher.vmdl") then
				local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5/am_basher.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControlForward(pfx, 0, keys.target:GetForwardVector())
				ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 3, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(pfx)
			elseif HeroItems:UnitHasItem(self:GetParent(), "skullbasher_gold.vmdl") then
				local pfx = ParticleManager:CreateParticle("particles/econ/items/antimage/antimage_weapon_basher_ti5_gold/am_basher_gold.vpcf", PATTACH_CUSTOMORIGIN, nil)
				ParticleManager:SetParticleControlForward(pfx, 0, keys.target:GetForwardVector())
				ParticleManager:SetParticleControlEnt(pfx, 0, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 3, keys.target, PATTACH_POINT, "attach_hitloc", keys.target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(pfx)
			end
		end
	end
end

modifier_imba_abyssal_blade_cooldown = class({})

function modifier_imba_abyssal_blade_cooldown:IsDebuff()			return false end
function modifier_imba_abyssal_blade_cooldown:IsHidden() 			return true end
function modifier_imba_abyssal_blade_cooldown:IsPurgable() 			return false end
function modifier_imba_abyssal_blade_cooldown:IsPurgeException() 	return false end