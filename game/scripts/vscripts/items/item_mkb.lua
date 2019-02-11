
item_imba_monkey_king_bar = class({})

LinkLuaModifier("modifier_imba_mkb_passive", "items/item_mkb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_mkb_unique", "items/item_mkb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_imba_mkb_charge", "items/item_mkb", LUA_MODIFIER_MOTION_NONE)

function item_imba_monkey_king_bar:GetIntrinsicModifierName() return "modifier_imba_mkb_passive" end

modifier_imba_mkb_passive = class({})

function modifier_imba_mkb_passive:IsDebuff()			return false end
function modifier_imba_mkb_passive:IsHidden() 			return true end
function modifier_imba_mkb_passive:IsPurgable() 		return false end
function modifier_imba_mkb_passive:IsPurgeException() 	return false end
function modifier_imba_mkb_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_mkb_passive:DeclareFunctions()	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end
function modifier_imba_mkb_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_mkb_passive:GetModifierBonusStats_Strength() return self:GetAbility():GetSpecialValueFor("bonus_str") end
function modifier_imba_mkb_passive:GetModifierBonusStats_Agility() return self:GetAbility():GetSpecialValueFor("bonus_agi") end

function modifier_imba_mkb_passive:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_mkb_unique", {})
	end
end

function modifier_imba_mkb_passive:OnDestroy()
	if IsServer() and not self:GetParent():HasModifier("modifier_imba_mkb_passive") then
		self:GetParent():RemoveModifierByName("modifier_imba_mkb_unique")
	end
end

modifier_imba_mkb_unique = class({})

function modifier_imba_mkb_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_mkb_unique:OnDestroy() self.ability = nil end
function modifier_imba_mkb_unique:IsDebuff()			return false end
function modifier_imba_mkb_unique:IsHidden() 			return true end
function modifier_imba_mkb_unique:IsPurgable() 			return false end
function modifier_imba_mkb_unique:IsPurgeException() 	return false end
function modifier_imba_mkb_unique:CheckState() return {[MODIFIER_STATE_CANNOT_MISS] = true} end
function modifier_imba_mkb_unique:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_mkb_unique:GetModifierAttackRangeBonus() return self.ability:GetSpecialValueFor("bonus_range") end

function modifier_imba_mkb_unique:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:IsBuilding() or keys.target:IsOther() or self:GetParent():IsIllusion() or not self:GetParent().splitattack or not keys.target:IsAlive() then
		return
	end
	local buff = self:GetParent():AddNewModifier(self:GetParent(), self.ability, "modifier_item_imba_mkb_charge", {duration = self.ability:GetSpecialValueFor("proc_duration")})
	buff:SetStackCount(buff:GetStackCount() + 1)
	if buff:GetStackCount() >= self.ability:GetSpecialValueFor("pulverize_count") then
		buff:Destroy()
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self.ability:GetSpecialValueFor("pulverize_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy == keys.target or not enemy:IsMagicImmune() then
				enemy:AddNewModifier(self:GetParent(), self.ability, "modifier_imba_bashed", {duration = self.ability:GetSpecialValueFor("pulverize_stun")})
				ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = self.ability:GetSpecialValueFor("pulverize_damage"), damage_type = DAMAGE_TYPE_MAGICAL, ability = self.ability})
				enemy:EmitSound("DOTA_Item.MKB.Minibash")
				local pfx = ParticleManager:CreateParticle("particles/item/jingu_bang/jingu_bang_pulverize.vpcf", PATTACH_ABSORIGIN, enemy)
				ParticleManager:SetParticleControl(pfx, 1, Vector(100,0,0))
				ParticleManager:ReleaseParticleIndex(pfx)
			end
		end
		keys.target:EmitSound("Hero_Brewmaster.ThunderClap")
	end
end

modifier_item_imba_mkb_charge = class({})

function modifier_item_imba_mkb_charge:IsDebuff()			return false end
function modifier_item_imba_mkb_charge:IsHidden() 			return false end
function modifier_item_imba_mkb_charge:IsPurgable() 		return true end
function modifier_item_imba_mkb_charge:IsPurgeException() 	return true end