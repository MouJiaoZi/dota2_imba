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
	if self:GetParent():HasModifier("modifier_imba_fervor_passive") or self:GetParent():HasModifier("modifier_imba_darkness_caster") or self:GetParent():HasModifier("modifier_imba_faceless_void_timelord_thinker") or self:GetParent():HasModifier("modifier_imba_take_aim_near") then
		return
	end
	if keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():IsIllusion() and not self:GetParent():HasModifier("modifier_imba_abyssal_blade_unique") and self.ability:IsCooldownReady() and keys.target:IsAlive() then
		local pct = self:GetParent():IsRangedAttacker() and self.ability:GetSpecialValueFor("bash_chance_ranged") or self.ability:GetSpecialValueFor("bash_chance_melee")
		if RollPercentage(pct) then
			keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_bashed", {duration = self.ability:GetSpecialValueFor("bash_duration")})
			if keys.target:HasModifier("modifier_imba_basher_break_count") then
				keys.target:RemoveModifierByName("modifier_imba_basher_break_count")
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break", {duration = self.ability:GetSpecialValueFor("break_duration")})
			else
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break_count", {duration = self.ability:GetSpecialValueFor("break_need_duration")})
			end
			ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self.ability, damage = self.ability:GetSpecialValueFor("bonus_chance_damage"), damage_type =DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, self.ability:GetSpecialValueFor("bonus_chance_damage"), nil)
			keys.target:EmitSound("DOTA_Item.MKB.Minibash")
			self.ability:UseResources(true, true, true)
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
	if self:GetParent():HasModifier("modifier_imba_fervor_passive") or self:GetParent():HasModifier("modifier_imba_darkness_caster") or self:GetParent():HasModifier("modifier_imba_faceless_void_timelord_thinker") or self:GetParent():HasModifier("modifier_imba_take_aim_near") then
		return
	end
	if keys.attacker == self:GetParent() and not keys.target:IsBuilding() and not keys.target:IsOther() and not self:GetParent():IsIllusion() and not self:GetParent():HasModifier("modifier_imba_abyssal_blade_cooldown") and keys.target:IsAlive() then
		local pct = self:GetParent():IsRangedAttacker() and self.ability:GetSpecialValueFor("bash_chance_ranged") or self.ability:GetSpecialValueFor("bash_chance_melee")
		if RollPercentage(pct) then
			keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_bashed", {duration = self.ability:GetSpecialValueFor("bash_duration")})
			self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_imba_abyssal_blade_cooldown", {duration = self.ability:GetSpecialValueFor("bash_cooldown")})
			if keys.target:HasModifier("modifier_imba_basher_break_count") then
				keys.target:RemoveModifierByName("modifier_imba_basher_break_count")
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break", {duration = self.ability:GetSpecialValueFor("break_duration")})
			else
				keys.target:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_basher_break_count", {duration = self.ability:GetSpecialValueFor("break_need_duration")})
			end
			ApplyDamage({victim = keys.target, attacker = self:GetParent(), ability = self.ability, damage = self.ability:GetSpecialValueFor("bonus_chance_damage"), damage_type =DAMAGE_TYPE_MAGICAL})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.target, self.ability:GetSpecialValueFor("bonus_chance_damage"), nil)
			keys.target:EmitSound("DOTA_Item.MKB.Minibash")
		end
	end
end

modifier_imba_abyssal_blade_cooldown = class({})

function modifier_imba_abyssal_blade_cooldown:IsDebuff()			return false end
function modifier_imba_abyssal_blade_cooldown:IsHidden() 			return true end
function modifier_imba_abyssal_blade_cooldown:IsPurgable() 			return false end
function modifier_imba_abyssal_blade_cooldown:IsPurgeException() 	return false end