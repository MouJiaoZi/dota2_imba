--[[
        By: MouJiaoZi
        Date: 17.08.2017
        Updated:  17.08.2017	FindTalentValue("special_bonus_imba_pudge_1","damage")
        						FindTalentValue("special_bonus_imba_pudge_8")  
    ]]


CreateEmptyTalents("invoker")

imba_invoker_i_am_injoker = imba_invoker_i_am_injoker or class({})

LinkLuaModifier("modifier_imba_invoker_i_am_injoker_buff", "hero/hero_invoker", LUA_MODIFIER_MOTION_NONE)

function imba_invoker_i_am_injoker:IsHiddenWhenStolen() 	return true end
function imba_invoker_i_am_injoker:IsRefreshable() 			return false end
function imba_invoker_i_am_injoker:IsStealable() 			return false end
function imba_invoker_i_am_injoker:IsNetherWardStealable() 	return false end
function imba_invoker_i_am_injoker:IsTalentAbility() return true end
function imba_invoker_i_am_injoker:GetIntrinsicModifierName()	return "modifier_imba_invoker_i_am_injoker_buff" end

modifier_imba_invoker_i_am_injoker_buff = modifier_imba_invoker_i_am_injoker_buff or class({})

function modifier_imba_invoker_i_am_injoker_buff:IsDebuff()					return false end
function modifier_imba_invoker_i_am_injoker_buff:IsHidden()					return false end
function modifier_imba_invoker_i_am_injoker_buff:IsPurgable() 				return false end
function modifier_imba_invoker_i_am_injoker_buff:IsPurgeException() 		return false end
function modifier_imba_invoker_i_am_injoker_buff:IsStunDebuff() 			return false end
function modifier_imba_invoker_i_am_injoker_buff:RemoveOnDeath()			return self:GetParent():IsIllusion() end
function modifier_imba_invoker_i_am_injoker_buff:AllowIllusionDuplicate() 	return true end

function modifier_imba_invoker_i_am_injoker_buff:OnCreated()
	if not IsServer() then
		return
	end
	local caster = self:GetCaster()
	--caster:AddAbility("invoker_quas")
	--caster:AddAbility("invoker_wex")
	--caster:AddAbility("invoker_exort")				-- Use these 3 orbs to control other spells level
	--[[caster:AddAbility("invoker_cold_snap") 			--极冻=3
	caster:AddAbility("invoker_ghost_walk") 		--鬼步=10
	caster:AddAbility("invoker_tornado") 			--吹风=17
	caster:AddAbility("invoker_deafening_blast") 	--推波=25
	caster:AddAbility("invoker_emp") 				--磁暴=24
	--caster:AddAbility("invoker_alacrity") 			--灵动迅捷=32
	caster:AddAbility("invoker_chaos_meteor") 		--陨石=40
	caster:AddAbility("invoker_sun_strike") 		--天火=48
	caster:AddAbility("invoker_ice_wall") 			--冰墙=18
	caster:AddAbility("invoker_forge_spirit") 		--火人=33]]

	self.orb_attach = {}
	self.orb_attach[1] = "attach_orb1"
	self.orb_attach[2] = "attach_orb2"
	self.orb_attach[3] = "attach_orb3"

	self.orb_pfx = {}
	self.orb_pfx[1] = nil
	self.orb_pfx[2] = nil
	self.orb_pfx[3] = nil

	self.orb_modifier = {}
	self.orb_modifier[1] = nil
	self.orb_modifier[2] = nil
	self.orb_modifier[3] = nil

	self.orb_order = 1

	self.abi_solt = {}
	self.abi_solt[1] = self:GetCaster():FindAbilityByName("invoker_empty1")
	self.abi_solt[2] = self:GetCaster():FindAbilityByName("invoker_empty2")
	self.abi_order = 1

end

function imba_invoker_call_for_orb(orb)
	local caster = orb:GetCaster()
	local ability = orb
	local control_modifier = caster:FindModifierByNameAndCaster("modifier_imba_invoker_i_am_injoker_buff", caster)
	local spell_Q = caster:FindAbilityByName("invoker_quas")
	local spell_W = caster:FindAbilityByName("invoker_wex")
	local spell_E = caster:FindAbilityByName("invoker_exort")
	local pfx_Q = "particles/units/heroes/hero_invoker/invoker_quas_orb.vpcf"
	local pfx_W = "particles/units/heroes/hero_invoker/invoker_wex_orb.vpcf"
	local pfx_E = "particles/units/heroes/hero_invoker/invoker_exort_orb.vpcf"
	if caster:HasScepter() then
		pfx_Q = "particles/econ/items/invoker/invoker_ti6/invoker_ti6_quas_orb.vpcf"
		pfx_W = "particles/econ/items/invoker/invoker_ti6/invoker_ti6_wex_orb.vpcf"
		pfx_E = "particles/econ/items/invoker/invoker_ti6/invoker_ti6_exort_orb.vpcf"
	end

	if control_modifier.orb_pfx[control_modifier.orb_order] then
		ParticleManager:DestroyParticle(control_modifier.orb_pfx[control_modifier.orb_order], false)
		ParticleManager:ReleaseParticleIndex(control_modifier.orb_pfx[control_modifier.orb_order])
	end

	local act = math.random(1,2)

	if act == 1 then
		caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	else
		caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	end

	if control_modifier.orb_modifier[control_modifier.orb_order] then
		control_modifier.orb_modifier[control_modifier.orb_order]:Destroy()
	end

	if ability == spell_Q then
		control_modifier.orb_pfx[control_modifier.orb_order] = ParticleManager:CreateParticle(pfx_Q, PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(control_modifier.orb_pfx[control_modifier.orb_order], 0, caster, PATTACH_POINT_FOLLOW, "attach_attack"..act, caster:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(control_modifier.orb_pfx[control_modifier.orb_order], 1, caster, PATTACH_POINT_FOLLOW, control_modifier.orb_attach[control_modifier.orb_order], caster:GetAbsOrigin(), false)
		control_modifier.orb_modifier[control_modifier.orb_order] = caster:AddNewModifier(caster, ability, "modifier_imba_invoker_Q_buff", {})
	elseif ability == spell_W then
		control_modifier.orb_pfx[control_modifier.orb_order] = ParticleManager:CreateParticle(pfx_W, PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(control_modifier.orb_pfx[control_modifier.orb_order], 0, caster, PATTACH_POINT_FOLLOW, "attach_attack"..act, caster:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(control_modifier.orb_pfx[control_modifier.orb_order], 1, caster, PATTACH_POINT_FOLLOW, control_modifier.orb_attach[control_modifier.orb_order], caster:GetAbsOrigin(), false)
		control_modifier.orb_modifier[control_modifier.orb_order] = caster:AddNewModifier(caster, ability, "modifier_imba_invoker_W_buff", {})
	elseif ability == spell_E then
		control_modifier.orb_pfx[control_modifier.orb_order] = ParticleManager:CreateParticle(pfx_E, PATTACH_POINT_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(control_modifier.orb_pfx[control_modifier.orb_order], 0, caster, PATTACH_POINT_FOLLOW, "attach_attack"..act, caster:GetAbsOrigin(), false)
		ParticleManager:SetParticleControlEnt(control_modifier.orb_pfx[control_modifier.orb_order], 1, caster, PATTACH_POINT_FOLLOW, control_modifier.orb_attach[control_modifier.orb_order], caster:GetAbsOrigin(), false)
		control_modifier.orb_modifier[control_modifier.orb_order] = caster:AddNewModifier(caster, ability, "modifier_imba_invoker_E_buff", {})
	end

	if control_modifier.orb_order < 3 then
		control_modifier.orb_order = control_modifier.orb_order + 1
	else
		control_modifier.orb_order = 1
	end
end

function imba_invoker_injoker_spell(ability)
	local spell_I_want = 0
	local caster = ability:GetCaster()
	local buff = caster:FindModifierByNameAndCaster("modifier_imba_invoker_i_am_injoker_buff", caster)
	local order = buff.abi_order
	if buff.orb_modifier[1] == nil or buff.orb_modifier[2] == nil or buff.orb_modifier[3] == nil then
		ability:RefundManaCost()
		ability:EndCooldown()
		return
	end
	for i = 1, 3 do
		if buff.orb_modifier[i]:GetName() == "modifier_imba_invoker_Q_buff" then
			spell_I_want = spell_I_want + 1
		elseif buff.orb_modifier[i]:GetName() == "modifier_imba_invoker_W_buff" then
			spell_I_want = spell_I_want + 8
		elseif buff.orb_modifier[i]:GetName() == "modifier_imba_invoker_E_buff" then
			spell_I_want = spell_I_want + 16
		end
	end
	local beg_spell = imba_invoker_get_spell(ability, spell_I_want)
	local exist_spell = buff.abi_solt[order]
	if beg_spell == buff.abi_solt[1] or beg_spell == buff.abi_solt[2] then
		ability:RefundManaCost()
		ability:EndCooldown()
	end
	if beg_spell ~= buff.abi_solt[1] then
		caster:SwapAbilities( buff.abi_solt[1]:GetAbilityName(), buff.abi_solt[2]:GetAbilityName(), true, true )
		local tmp = buff.abi_solt[2]
		buff.abi_solt[2] = buff.abi_solt[1]
		buff.abi_solt[1] = tmp
		caster:SwapAbilities( buff.abi_solt[1]:GetAbilityName(), beg_spell:GetAbilityName(), false, true )
	end
	buff.abi_solt[1] = beg_spell
	if buff.abi_order < 2 then
		buff.abi_order = buff.abi_order + 1
	else
		buff.abi_order = 1
	end

	--Play the particle effect with the general color.
	local invoke_particle_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_invoke.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	--The Invoke particle effect changes color depending on which orbs are out.
	local quas_particle_effect_color = Vector(0, 153, 204)
	local wex_particle_effect_color = Vector(204, 0, 153)
	local exort_particle_effect_color = Vector(204, 153, 0)
	local num_quas_orbs = 0
	local num_wex_orbs = 0
	local num_exort_orbs = 0
	for i=1, 3 do
		if buff.orb_modifier[i]:GetName() == "modifier_imba_invoker_Q_buff" then
				num_quas_orbs = num_quas_orbs + 1
		elseif buff.orb_modifier[i]:GetName() == "modifier_imba_invoker_W_buff" then
				num_wex_orbs = num_wex_orbs + 1
		elseif buff.orb_modifier[i]:GetName() == "modifier_imba_invoker_E_buff" then
			num_exort_orbs = num_exort_orbs + 1
		end
	end
	--Set the Invoke particle effect's color depending on which orbs are invoked.
	ParticleManager:SetParticleControl(invoke_particle_effect, 2, ((quas_particle_effect_color * num_quas_orbs) + (wex_particle_effect_color * num_wex_orbs) + (exort_particle_effect_color * num_exort_orbs)) / 3)
	EmitSoundOn("Hero_Invoker.Invoke", caster)

end

function imba_invoker_get_spell(ability, number)
	local caster = ability:GetCaster()
	local QQQ = caster:FindAbilityByName("invoker_cold_snap") 			--极冻=3
	local QQW = caster:FindAbilityByName("invoker_ghost_walk") 			--鬼步=10
	local QWW = caster:FindAbilityByName("invoker_tornado") 			--吹风=17
	local QWE = caster:FindAbilityByName("invoker_deafening_blast") 	--推波=25
	local WWW = caster:FindAbilityByName("invoker_emp") 				--磁暴=24
	local WWE = caster:FindAbilityByName("invoker_alacrity") 		--灵动迅捷=32
	local WEE = caster:FindAbilityByName("invoker_chaos_meteor") 		--陨石=40
	local EEE = caster:FindAbilityByName("invoker_sun_strike") 			--天火=48
	local EQQ = caster:FindAbilityByName("invoker_ice_wall") 			--冰墙=18
	local EEQ = caster:FindAbilityByName("invoker_forge_spirit") 		--火人=33
	local joke_spell = {}
	joke_spell[3] = QQQ
	joke_spell[10] = QQW
	joke_spell[17] = QWW
	joke_spell[25] = QWE
	joke_spell[24] = WWW
	joke_spell[32] = WWE
	joke_spell[40] = WEE
	joke_spell[48] = EEE
	joke_spell[18] = EQQ
	joke_spell[33] = EEQ
	joke_spell[number]:SetLevel(1)
	return joke_spell[number]
end

LinkLuaModifier("modifier_imba_invoker_Q_buff", "hero/hero_invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_invoker_W_buff", "hero/hero_invoker", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_invoker_E_buff", "hero/hero_invoker", LUA_MODIFIER_MOTION_NONE)
modifier_imba_invoker_Q_buff = modifier_imba_invoker_Q_buff or class({})
modifier_imba_invoker_W_buff = modifier_imba_invoker_W_buff or class({})
modifier_imba_invoker_E_buff = modifier_imba_invoker_E_buff or class({})

function modifier_imba_invoker_Q_buff:IsDebuff()				return false end
function modifier_imba_invoker_Q_buff:IsHidden()				return false end
function modifier_imba_invoker_Q_buff:IsPurgable() 				return false end
function modifier_imba_invoker_Q_buff:IsPurgeException() 		return false end
function modifier_imba_invoker_Q_buff:IsStunDebuff() 			return false end
function modifier_imba_invoker_Q_buff:RemoveOnDeath()
	if self:GetCaster():IsTrueHero() then
		return false 
	else
		return true
	end
end
function modifier_imba_invoker_Q_buff:IsPermanent() 			return true end
function modifier_imba_invoker_Q_buff:AllowIllusionDuplicate() 	return true end
function modifier_imba_invoker_Q_buff:GetAttributes()			return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_imba_invoker_Q_buff:DeclareFunctions()return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_CHANGE_ABILITY_VALUE} end
function modifier_imba_invoker_Q_buff:GetModifierConstantHealthRegen()	return self:GetAbility():GetSpecialValueFor("health_regen_per_instance") end
function modifier_imba_invoker_Q_buff:GetModifierChangeAbilityValue() return "quaslevel" end

function modifier_imba_invoker_W_buff:IsDebuff()				return false end
function modifier_imba_invoker_W_buff:IsHidden()				return false end
function modifier_imba_invoker_W_buff:IsPurgable() 				return false end
function modifier_imba_invoker_W_buff:IsPurgeException() 		return false end
function modifier_imba_invoker_W_buff:IsStunDebuff() 			return false end
function modifier_imba_invoker_W_buff:RemoveOnDeath()
	if self:GetCaster():IsTrueHero() then
		return false 
	else
		return true
	end
end
function modifier_imba_invoker_W_buff:IsPermanent() 			return true end
function modifier_imba_invoker_W_buff:AllowIllusionDuplicate() 	return true end
function modifier_imba_invoker_W_buff:GetAttributes()			return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_imba_invoker_W_buff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
					MODIFIER_PROPERTY_CHANGE_ABILITY_VALUE }
	return funcs
end

function modifier_imba_invoker_W_buff:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("move_speed_per_instance") end
function modifier_imba_invoker_W_buff:GetModifierAttackSpeedBonus_Constant() return self:GetAbility():GetSpecialValueFor("attack_speed_per_instance") end
function modifier_imba_invoker_W_buff:GetModifierChangeAbilityValue() return "wexlevel" end

function modifier_imba_invoker_E_buff:IsDebuff()				return false end
function modifier_imba_invoker_E_buff:IsHidden()				return false end
function modifier_imba_invoker_E_buff:IsPurgable() 				return false end
function modifier_imba_invoker_E_buff:IsPurgeException() 		return false end
function modifier_imba_invoker_E_buff:IsStunDebuff() 			return false end
function modifier_imba_invoker_E_buff:RemoveOnDeath()
	if self:GetCaster():IsTrueHero() then
		return false 
	else
		return true
	end
end
function modifier_imba_invoker_E_buff:IsPermanent() 			return true end
function modifier_imba_invoker_E_buff:AllowIllusionDuplicate() 	return true end
function modifier_imba_invoker_E_buff:GetAttributes()			return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE end

function modifier_imba_invoker_E_buff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_CHANGE_ABILITY_VALUE }
	return funcs
end

function modifier_imba_invoker_E_buff:GetModifierPreAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage_per_instance") end
function modifier_imba_invoker_E_buff:GetModifierChangeAbilityValue() return "exortlevel" end

-------------------------------------------
--			  Quas
-------------------------------------------

invoker_quas = class({})

function invoker_quas:IsHiddenWhenStolen() 		return true end
function invoker_quas:IsRefreshable() 			return true end
function invoker_quas:IsStealable() 			return false end
function invoker_quas:IsNetherWardStealable() 	return false end
function invoker_quas:ProcsMagicStick()			return false end

function invoker_quas:OnSpellStart()
	if not IsServer() then
		return
	end
	imba_invoker_call_for_orb(self)
end

function invoker_quas:OnUpgrade()
	if not IsServer() then
		return
	end
	if not self:GetCaster():IsTrueHero() then
		return
	end
	local level = self:GetLevel()
	--local ability = self:GetCaster():FindAbilityByName("invoker_quas")
	--ability:SetLevel(level)
end

-------------------------------------------
--			  Wex
-------------------------------------------

invoker_wex = class({})

function invoker_wex:IsHiddenWhenStolen() 		return true end
function invoker_wex:IsRefreshable() 			return true end
function invoker_wex:IsStealable() 				return false end
function invoker_wex:IsNetherWardStealable() 	return false end
function invoker_wex:ProcsMagicStick()			return false end

function invoker_wex:OnSpellStart()
	if not IsServer() then
		return
	end
	imba_invoker_call_for_orb(self)
end

function invoker_wex:OnUpgrade()
	if not IsServer() then
		return
	end
	if not self:GetCaster():IsTrueHero() then
		return
	end
	local level = self:GetLevel()
	--local ability = self:GetCaster():FindAbilityByName("invoker_wex")
	--ability:SetLevel(level)
end

-------------------------------------------
--			  Exort
-------------------------------------------

invoker_exort = class({})

function invoker_exort:IsHiddenWhenStolen() 	return true end
function invoker_exort:IsRefreshable() 			return true end
function invoker_exort:IsStealable() 			return false end
function invoker_exort:IsNetherWardStealable() 	return false end
function invoker_exort:ProcsMagicStick()		return false end

function invoker_exort:OnSpellStart()
	if not IsServer() then
		return
	end
	imba_invoker_call_for_orb(self)
end

function invoker_exort:OnUpgrade()
	if not IsServer() then
		return
	end
	if not self:GetCaster():IsTrueHero() then
		return
	end
	local level = self:GetLevel()
	--local ability = self:GetCaster():FindAbilityByName("invoker_exort")
	--ability:SetLevel(level)
end

-------------------------------------------
--			  Injoke
-------------------------------------------

imba_invoker_invoke = imba_invoker_invoke or class({})

function imba_invoker_invoke:IsHiddenWhenStolen() 		return true end
function imba_invoker_invoke:IsRefreshable() 			return true  end
function imba_invoker_invoke:IsStealable() 				return false end
function imba_invoker_invoke:IsNetherWardStealable() 	return false end
function imba_invoker_invoke:IsTalentAbility() 			return true end
function imba_invoker_invoke:GetIntrinsicModifierName() return "modifier_imba_invoker_i_am_injoker_buff" end
function imba_invoker_invoke:GetCooldown(level)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("cooldown_scepter")
	else
		return self.BaseClass.GetCooldown(self, level)
	end
end
function imba_invoker_invoke:GetManaCost(level)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("mana_cost_scepter")
	else
		return self.BaseClass.GetManaCost(self, level)
	end
end

function imba_invoker_invoke:OnSpellStart()
	if not IsServer() then
		return
	end
	imba_invoker_injoker_spell(self)
end

-------------------------------------------
--			  Alacrity
-------------------------------------------

imba_invoker_alacrity = imba_invoker_alacrity or class({})

LinkLuaModifier("modifier_imba_invoker_alacrity_buff", "hero/hero_invoker", LUA_MODIFIER_MOTION_NONE)

function imba_invoker_alacrity:IsHiddenWhenStolen() 		return false end
function imba_invoker_alacrity:IsRefreshable() 				return true end
function imba_invoker_alacrity:IsStealable() 				return true end
function imba_invoker_alacrity:IsNetherWardStealable() 		return true end
function imba_invoker_alacrity:IsInnateAbility()			return true end

function imba_invoker_alacrity:OnSpellStart()
	if not IsServer() then
		return
	end
	local ability = self
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local E = self:GetCaster():FindAbilityByName("imba_invoker_exort")
	local W = self:GetCaster():FindAbilityByName("imba_invoker_wex")
	target:AddNewModifier(caster, ability, "modifier_imba_invoker_alacrity_buff", {duration = ability:GetSpecialValueFor("duration")})
end

modifier_imba_invoker_alacrity_buff = modifier_imba_invoker_alacrity_buff or class({})

function modifier_imba_invoker_alacrity_buff:IsDebuff()					return false end
function modifier_imba_invoker_alacrity_buff:IsHidden()					return false end
function modifier_imba_invoker_alacrity_buff:IsPurgable() 				return true end
function modifier_imba_invoker_alacrity_buff:IsPurgeException() 		return true end
function modifier_imba_invoker_alacrity_buff:IsStunDebuff() 			return false end

function modifier_imba_invoker_alacrity_buff:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
					MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, }
	return funcs
end

function modifier_imba_invoker_alacrity_buff:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_imba_invoker_alacrity_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end




















function modifier_special_bonus_imba_invoker_1:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_EXECUTED} end

function modifier_special_bonus_imba_invoker_1:OnAbilityExecuted(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and keys.ability:GetName() == "invoker_chaos_meteor" then
		local ability = self:GetParent():FindAbilityByName("invoker_chaos_meteor")
		local sou_pos = ability:GetCursorPosition()
		local caster_pos = self:GetParent():GetAbsOrigin()
		local interval = 0.8
		local extra_metors = math.floor(self:GetParent():GetLevel() / self:GetParent():GetTalentValue("special_bonus_imba_invoker_1"))
		for i = 1, extra_metors do
			Timers:CreateTimer(i * interval, function()
					local caster = self:GetParent():GetAbsOrigin()
					self:GetParent():SetOrigin(caster_pos)
					self:GetParent():SetCursorPosition(sou_pos)
					ability:OnSpellStart()
					self:GetParent():SetOrigin(caster)
					return nil
				end
			)
		end
		
	end
end

local normal_ability = {"invoker_quas", "invoker_wex", "invoker_exort", "invoker_invoke"}

function modifier_special_bonus_imba_invoker_2:DeclareFunctions() return {MODIFIER_EVENT_ON_ABILITY_EXECUTED} end

function modifier_special_bonus_imba_invoker_2:OnAbilityExecuted(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() and not keys.ability:IsItem() and not IsInTable(keys.ability:GetName(), normal_ability) then
		for i = 0, 23 do
			local ability = self:GetParent():GetAbilityByIndex(i)
			if ability and not ability:IsCooldownReady() then
				local cd = ability:GetCooldownTimeRemaining()
				ability:EndCooldown()
				if cd > self:GetParent():GetTalentValue("special_bonus_imba_invoker_2") then
					ability:StartCooldown(cd - self:GetParent():GetTalentValue("special_bonus_imba_invoker_2"))
				end
			end
		end
	end
end


-- modifier_invoker_quas_instance	modifier_invoker_wex_instance	modifier_invoker_exort_instance

