

LinkLuaModifier("modifier_imba_rapier_vision", "items/item_rapier", LUA_MODIFIER_MOTION_NONE)

modifier_imba_rapier_vision = class({})

function modifier_imba_rapier_vision:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_rapier_vision:OnIntervalThink()
	if not self:GetAbility() or self:GetAbility():IsNull() or self:GetAbility():GetPurchaser() then
		self:Destroy()
		return
	end
	for i = 2, 3 do
		AddFOWViewer(i, self:GetAbility():GetAbsOrigin(), 300, 1.0, false)
	end
end

item_imba_rapier = class({})

LinkLuaModifier("modifier_imba_rapier_unique", "items/item_rapier", LUA_MODIFIER_MOTION_NONE)

item_imba_rapier = class({})

function item_imba_rapier:GetIntrinsicModifierName() return "modifier_imba_rapier_unique" end

function item_imba_rapier:OnOwnerDied()
	if (not self:GetCaster():IsTrueHero() and not self:GetCaster():IsIllusion()) or not self:GetCaster():IsReincarnating() then
		self:GetCaster():DropItemAtPositionImmediate(self, self:GetCaster():GetAbsOrigin())
		self:LaunchLoot(false, 250, 0.5, self:GetCaster():GetAbsOrigin() + RandomVector(100))
		Notifications:BottomToAll({hero=self:GetPurchaser():GetUnitName(), duration=5.0, class="NotificationMessage"})
		Notifications:BottomToAll({text="#"..self:GetPurchaser():GetUnitName(), continue=true})
		Notifications:BottomToAll({text="IMBA_RAPIER_DROPPED", continue=true})
		Notifications:BottomToAll({text="#DOTA_Tooltip_ability_"..self:GetName(), continue=true})
		self:SetPurchaser(nil)
		CreateModifierThinker(nil, self, "modifier_imba_rapier_vision", {}, self:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
	end
end

modifier_imba_rapier_unique = class({})

function modifier_imba_rapier_unique:IsDebuff()				return false end
function modifier_imba_rapier_unique:IsHidden() 			return true end
function modifier_imba_rapier_unique:IsPurgable() 			return false end
function modifier_imba_rapier_unique:IsPurgeException() 	return false end
function modifier_imba_rapier_unique:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_rapier_unique:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE} end
function modifier_imba_rapier_unique:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end


item_imba_rapier_2 = class({})

LinkLuaModifier("modifier_imba_rapier_three_unique", "items/item_rapier", LUA_MODIFIER_MOTION_NONE)

item_imba_rapier_2 = class({})

function item_imba_rapier_2:GetIntrinsicModifierName() return "modifier_imba_rapier_three_unique" end

function item_imba_rapier_2:OnOwnerDied()
	if (not self:GetCaster():IsTrueHero() and not self:GetCaster():IsIllusion()) or not self:GetCaster():IsReincarnating() then
		self:GetCaster():DropItemAtPositionImmediate(self, self:GetCaster():GetAbsOrigin())
		local pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100
		pos = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0, RandomInt(0, 360), 0), pos)
		self:LaunchLoot(false, 250, 0.5, pos)
		Notifications:BottomToAll({hero=self:GetPurchaser():GetUnitName(), duration=5.0, class="NotificationMessage"})
		Notifications:BottomToAll({text="#"..self:GetPurchaser():GetUnitName(), continue=true})
		Notifications:BottomToAll({text="IMBA_RAPIER_DROPPED", continue=true})
		Notifications:BottomToAll({text="#DOTA_Tooltip_ability_"..self:GetName(), continue=true})
		self:SetPurchaser(nil)
		CreateModifierThinker(nil, self, "modifier_imba_rapier_vision", {}, self:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
	end
end

modifier_imba_rapier_three_unique = class({})

function modifier_imba_rapier_three_unique:IsDebuff()			return false end
function modifier_imba_rapier_three_unique:IsHidden() 			return true end
function modifier_imba_rapier_three_unique:IsPurgable() 		return false end
function modifier_imba_rapier_three_unique:IsPurgeException() 	return false end
function modifier_imba_rapier_three_unique:GetEffectName() return "particles/item/rapier/rapier_trail_regular.vpcf" end
function modifier_imba_rapier_three_unique:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rapier_three_unique:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_rapier_three_unique:DeclareFunctions() return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_rapier_three_unique:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_rapier_three_unique:GetModifierProvidesFOWVision() return 1 end



item_imba_rapier_magic = class({})

LinkLuaModifier("modifier_imba_rapier_magic_unique", "items/item_rapier", LUA_MODIFIER_MOTION_NONE)

item_imba_rapier_magic = class({})

function item_imba_rapier_magic:GetIntrinsicModifierName() return "modifier_imba_rapier_magic_unique" end

function item_imba_rapier_magic:OnOwnerDied()
	if (not self:GetCaster():IsTrueHero() and not self:GetCaster():IsIllusion()) or not self:GetCaster():IsReincarnating() then
		self:GetCaster():DropItemAtPositionImmediate(self, self:GetCaster():GetAbsOrigin())
		self:LaunchLoot(false, 250, 0.5, self:GetCaster():GetAbsOrigin() + RandomVector(100))
		Notifications:BottomToAll({hero=self:GetPurchaser():GetUnitName(), duration=5.0, class="NotificationMessage"})
		Notifications:BottomToAll({text="#"..self:GetPurchaser():GetUnitName(), continue=true})
		Notifications:BottomToAll({text="IMBA_RAPIER_DROPPED", continue=true})
		Notifications:BottomToAll({text="#DOTA_Tooltip_ability_"..self:GetName(), continue=true})
		self:SetPurchaser(nil)
		CreateModifierThinker(nil, self, "modifier_imba_rapier_vision", {}, self:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
	end
end

modifier_imba_rapier_magic_unique = class({})

function modifier_imba_rapier_magic_unique:IsDebuff()			return false end
function modifier_imba_rapier_magic_unique:IsHidden() 			return true end
function modifier_imba_rapier_magic_unique:IsPurgable() 		return false end
function modifier_imba_rapier_magic_unique:IsPurgeException() 	return false end
function modifier_imba_rapier_magic_unique:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_rapier_magic_unique:DeclareFunctions() return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE} end
function modifier_imba_rapier_magic_unique:GetModifierSpellAmplify_Percentage()
	if IsServer() then
		if self:GetParent():IsIllusion() then
			return 0
		else
			return self:GetAbility():GetSpecialValueFor("spell_power")
		end
	else
		return self:GetAbility():GetSpecialValueFor("spell_power")
	end
end

item_imba_rapier_magic_2 = class({})

LinkLuaModifier("modifier_imba_rapier_magic_three_unique", "items/item_rapier", LUA_MODIFIER_MOTION_NONE)

item_imba_rapier_magic_2 = class({})

function item_imba_rapier_magic_2:GetIntrinsicModifierName() return "modifier_imba_rapier_magic_three_unique" end

function item_imba_rapier_magic_2:OnOwnerDied()
	if (not self:GetCaster():IsTrueHero() and not self:GetCaster():IsIllusion()) or not self:GetCaster():IsReincarnating() then
		self:GetCaster():DropItemAtPositionImmediate(self, self:GetCaster():GetAbsOrigin())
		local pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100
		pos = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0, RandomInt(0, 360), 0), pos)
		self:LaunchLoot(false, 250, 0.5, pos)
		Notifications:BottomToAll({hero=self:GetPurchaser():GetUnitName(), duration=5.0, class="NotificationMessage"})
		Notifications:BottomToAll({text="#"..self:GetPurchaser():GetUnitName(), continue=true})
		Notifications:BottomToAll({text="IMBA_RAPIER_DROPPED", continue=true})
		Notifications:BottomToAll({text="#DOTA_Tooltip_ability_"..self:GetName(), continue=true})
		self:SetPurchaser(nil)
		CreateModifierThinker(nil, self, "modifier_imba_rapier_vision", {}, self:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
	end
end

modifier_imba_rapier_magic_three_unique = class({})

function modifier_imba_rapier_magic_three_unique:IsDebuff()			return false end
function modifier_imba_rapier_magic_three_unique:IsHidden() 		return true end
function modifier_imba_rapier_magic_three_unique:IsPurgable() 		return false end
function modifier_imba_rapier_magic_three_unique:IsPurgeException() return false end
function modifier_imba_rapier_magic_three_unique:GetEffectName() return "particles/item/rapier/rapier_trail_arcane.vpcf" end
function modifier_imba_rapier_magic_three_unique:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rapier_magic_three_unique:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_rapier_magic_three_unique:DeclareFunctions() return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_rapier_magic_three_unique:GetModifierSpellAmplify_Percentage()
	if IsServer() then
		if self:GetParent():IsIllusion() then
			return 0
		else
			return self:GetAbility():GetSpecialValueFor("spell_power")
		end
	else
		return self:GetAbility():GetSpecialValueFor("spell_power")
	end
end
function modifier_imba_rapier_magic_three_unique:GetModifierProvidesFOWVision() return 1 end



item_imba_rapier_cursed = class({})

LinkLuaModifier("modifier_imba_rapier_super_passive", "items/item_rapier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_rapier_super_unique", "items/item_rapier", LUA_MODIFIER_MOTION_NONE)

item_imba_rapier_cursed = class({})

function item_imba_rapier_cursed:GetIntrinsicModifierName() return "modifier_imba_rapier_super_passive" end

function item_imba_rapier_cursed:OnOwnerDied()
	if (not self:GetCaster():IsTrueHero() and not self:GetCaster():IsIllusion()) or not self:GetCaster():IsReincarnating() then
		self:GetCaster():DropItemAtPositionImmediate(self, self:GetCaster():GetAbsOrigin())
		local pos = self:GetCaster():GetAbsOrigin() + self:GetCaster():GetForwardVector() * 100
		pos = RotatePosition(self:GetCaster():GetAbsOrigin(), QAngle(0, RandomInt(0, 360), 0), pos)
		self:LaunchLoot(false, 250, 0.5, pos)
		Notifications:BottomToAll({hero=self:GetPurchaser():GetUnitName(), duration=5.0, class="NotificationMessage"})
		Notifications:BottomToAll({text="#"..self:GetPurchaser():GetUnitName(), continue=true})
		Notifications:BottomToAll({text="IMBA_RAPIER_DROPPED", continue=true})
		Notifications:BottomToAll({text="#DOTA_Tooltip_ability_"..self:GetName(), continue=true})
		self:SetPurchaser(nil)
		CreateModifierThinker(nil, self, "modifier_imba_rapier_vision", {}, self:GetAbsOrigin(), DOTA_TEAM_NEUTRALS, false)
	end
end

modifier_imba_rapier_super_passive = class({})

function modifier_imba_rapier_super_passive:IsDebuff()			return false end
function modifier_imba_rapier_super_passive:IsHidden() 			return true end
function modifier_imba_rapier_super_passive:IsPurgable() 		return false end
function modifier_imba_rapier_super_passive:IsPurgeException() 	return false end
function modifier_imba_rapier_super_passive:GetEffectName() return "particles/item/rapier/item_rapier_cursed.vpcf" end
function modifier_imba_rapier_super_passive:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_rapier_super_passive:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_rapier_super_passive:DeclareFunctions() return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_rapier_super_passive:GetModifierSpellAmplify_Percentage()
	if IsServer() then
		if self:GetParent():IsIllusion() then
			return 0
		else
			return self:GetAbility():GetSpecialValueFor("spell_power")
		end
	else
		return self:GetAbility():GetSpecialValueFor("spell_power")
	end
end
function modifier_imba_rapier_super_passive:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_rapier_super_passive:GetModifierProvidesFOWVision() return 1 end

function modifier_imba_rapier_super_passive:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
		self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_imba_rapier_super_unique", {})
	end
end

function modifier_imba_rapier_super_passive:OnIntervalThink()
	self:SetStackCount(math.floor(self:GetElapsedTime() / self:GetAbility():GetSpecialValueFor("time_to_double")))
	local dmg_pct = self:GetAbility():GetSpecialValueFor("base_corruption") / (1.0 / 0.1)
	dmg_pct = dmg_pct * self:GetStackCount() / 100
	local dmg = self:GetParent():GetMaxHealth() * dmg_pct
	self:GetParent():SetHealth(math.max(1, self:GetParent():GetHealth() - dmg))
end

function modifier_imba_rapier_super_passive:OnDestroy()
	if IsServer() then
		if not self:GetParent():HasModifier("modifier_imba_rapier_super_passive") then
			self:GetParent():RemoveModifierByName("modifier_imba_rapier_super_unique")
		end
	end
end

modifier_imba_rapier_super_unique = class({})

function modifier_imba_rapier_super_unique:OnCreated() self.ability = self:GetAbility() end
function modifier_imba_rapier_super_unique:OnDestroy() self.ability = nil end
function modifier_imba_rapier_super_unique:IsDebuff()			return false end
function modifier_imba_rapier_super_unique:IsHidden() 			return true end
function modifier_imba_rapier_super_unique:IsPurgable() 		return false end
function modifier_imba_rapier_super_unique:IsPurgeException() 	return false end
function modifier_imba_rapier_super_unique:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING} end
function modifier_imba_rapier_super_unique:GetModifierIncomingDamage_Percentage() return (0 - self.ability:GetSpecialValueFor("damage_reduction")) end
function modifier_imba_rapier_super_unique:GetModifierStatusResistanceStacking() return self.ability:GetSpecialValueFor("disable_reduction") end
