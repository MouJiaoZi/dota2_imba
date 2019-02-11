CreateEmptyTalents("terrorblade")

imba_terrorblade_demonic_power = class({})

LinkLuaModifier("modifier_imba_demonic_power", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)

function imba_terrorblade_demonic_power:IsTalentAbility() return true end
function imba_terrorblade_demonic_power:GetIntrinsicModifierName() return "modifier_imba_demonic_power" end

--models/items/terrorblade/endless_purgatory_demon/endless_purgatory_demon.vmdl

modifier_imba_demonic_power = class({})

function modifier_imba_demonic_power:IsDebuff()			return false end
function modifier_imba_demonic_power:IsHidden() 		return false end
function modifier_imba_demonic_power:IsPurgable() 		return false end
function modifier_imba_demonic_power:IsPurgeException() return false end
function modifier_imba_demonic_power:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED} end

function modifier_imba_demonic_power:OnCreated()
	if IsServer() then
		self.pfx = ParticleManager:CreateParticle("particles/hero/terrorbalde/demonic_power.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(0,0,0))
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_demonic_power:OnStackCountChanged(stack)
	if IsServer() then
		ParticleManager:SetParticleControl(self.pfx, 1, Vector(stack,0,0))
	end
end

function modifier_imba_demonic_power:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
end

function modifier_imba_demonic_power:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetParent():IsIllusion() or not keys.target:IsAlive() or (not keys.target:IsRealHero() and not keys.target:IsBuilding()) then
		return
	end
	self:SetStackCount(math.min(self:GetStackCount() + self:GetAbility():GetSpecialValueFor("attack_gain"), self:GetAbility():GetSpecialValueFor("max_power")))
	self:GetAbility():EndCooldown()
	self:GetAbility():StartCooldown(self:GetAbility():GetSpecialValueFor("idle_time"))
end

function modifier_imba_demonic_power:OnIntervalThink()
	if self:GetStackCount() > 10 and self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_imba_cmetamorphosis_aura") then
		self:SetStackCount(math.max(self:GetStackCount() - (self:GetAbility():GetSpecialValueFor("idle_lose") / (1.0 / 0.1)), self:GetAbility():GetSpecialValueFor("base_power")))
	end
	if self:GetStackCount() <= 10 and self:GetAbility():IsCooldownReady() and not self:GetParent():HasModifier("modifier_imba_cmetamorphosis_aura") then
		self:SetStackCount(math.min(self:GetStackCount() + (self:GetAbility():GetSpecialValueFor("idle_lose") / (1.0 / 0.1)), self:GetAbility():GetSpecialValueFor("base_power")))
	end
end

function GetDemonicPower(hero)
	return hero:GetModifierStackCount("modifier_imba_demonic_power", nil)
end

function CostDemonicPower(hero, cost)
	if not IsServer() then
		return
	end
	local buff = hero:FindModifierByName("modifier_imba_demonic_power")
	if buff then
		buff:SetStackCount(math.min(math.max(0, buff:GetStackCount() - cost), 100))
		return true
	end
	return false
end

-------------------------

imba_terrorblade_reflection = class({})

LinkLuaModifier("modifier_imba_reflection_illusion", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reflection_slow", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_reflection_slow_stack", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)

function imba_terrorblade_reflection:IsHiddenWhenStolen() 		return false end
function imba_terrorblade_reflection:IsRefreshable() 			return true end
function imba_terrorblade_reflection:IsStealable() 				return true end
function imba_terrorblade_reflection:IsNetherWardStealable()	return false end
function imba_terrorblade_reflection:GetCastRange() return self:GetSpecialValueFor("range") - self:GetCaster():GetCastRangeBonus() end
function imba_terrorblade_reflection:GetAbilityTextureName() return (GetDemonicPower(self:GetCaster()) >= self:GetSpecialValueFor("t1_power") and "terrorblade_reflection_alt1" or "terrorblade_reflection") end
function imba_terrorblade_reflection:GetCooldown(i) return (self.BaseClass.GetCooldown(self, i) + self:GetCaster():GetTalentValue("special_bonus_imba_terrorblade_1")) end

function imba_terrorblade_reflection:OnSpellStart()
	local caster = self:GetCaster()
	local power = GetDemonicPower(caster)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		enemy[i]:EmitSound("Hero_Terrorblade.Reflection")
		local enemy_buff = enemy[i]:AddNewModifier(caster, self, "modifier_imba_reflection_slow", {duration = self:GetSpecialValueFor("illusion_duration")})
		local illusion = IllusionManager:CreateIllusion(enemy[i], enemy[i]:GetAbsOrigin(), enemy[i]:GetForwardVector(), self:GetSpecialValueFor("illusion_outgoing"), 0, 0, self:GetSpecialValueFor("illusion_duration"), caster, nil)
		local buff = illusion:AddNewModifier(caster, self, "modifier_imba_reflection_illusion", {target = enemy[i]:entindex()})
		if power >= self:GetSpecialValueFor("t1_power") then
			buff:SetStackCount(1)
		end
		if power >= self:GetSpecialValueFor("t3_power") then
			buff:SetStackCount(2)
		end
		if power >= self:GetSpecialValueFor("t2_power") then
			enemy_buff:SetStackCount(-1)
		end
	end
	if power >= self:GetSpecialValueFor("t1_power") then
		CostDemonicPower(caster, self:GetSpecialValueFor("power_cost"))
	end
end

modifier_imba_reflection_illusion = class({})

function modifier_imba_reflection_illusion:IsDebuff()			return false end
function modifier_imba_reflection_illusion:IsHidden() 			return false end
function modifier_imba_reflection_illusion:IsPurgable() 		return false end
function modifier_imba_reflection_illusion:IsPurgeException() 	return false end
function modifier_imba_reflection_illusion:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true, [MODIFIER_STATE_UNSELECTABLE] = true, [MODIFIER_STATE_NOT_ON_MINIMAP] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_reflection_illusion:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_reflection_illusion:GetModifierMoveSpeedBonus_Percentage() return 1000 end
function modifier_imba_reflection_illusion:GetStatusEffectName() return "particles/status_fx/status_effect_terrorblade_reflection.vpcf" end
function modifier_imba_reflection_illusion:StatusEffectPriority() return 15 end

function modifier_imba_reflection_illusion:OnCreated(keys)
	if IsServer() then
		local target = EntIndexToHScript(keys.target)
		self:GetParent():SetForceAttackTarget(target)
	end
end

function modifier_imba_reflection_illusion:OnDestroy()
	if IsServer() then
		self:GetParent():SetForceAttackTarget(nil)
	end
end

function modifier_imba_reflection_illusion:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or self:GetStackCount() < 1 then
		return
	end
	keys.target:AddModifierStacks(self:GetCaster(), self:GetAbility(), "modifier_imba_reflection_slow_stack", {duration = self:GetAbility():GetSpecialValueFor("illusion_duration")}, self:GetAbility():GetSpecialValueFor("t1_slow_stack"), false, true)
end

function modifier_imba_reflection_illusion:OnTakeDamage(keys)
	if not IsServer() or self:GetStackCount() < 2 then
		return
	end
	if keys.attacker == self:GetParent() and (keys.unit:IsHero() or keys.unit:IsCreep() or keys.unit:IsBoss()) and IsEnemy(keys.attacker, keys.unit) and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
		local lifesteal = keys.damage
		if keys.unit:IsCreep() and keys.inflictor then
			lifesteal = lifesteal / 5
		end
		self:GetCaster():Heal(lifesteal, self:GetAbility())
		local pfx = ParticleManager:CreateParticle("particles/item/vladmir/vladmir_blood_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

modifier_imba_reflection_slow = class({})

function modifier_imba_reflection_slow:IsDebuff()			return true end
function modifier_imba_reflection_slow:IsHidden() 			return false end
function modifier_imba_reflection_slow:IsPurgable() 		return true end
function modifier_imba_reflection_slow:IsPurgeException() 	return true end
function modifier_imba_reflection_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION} end
function modifier_imba_reflection_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("move_slow")) end
function modifier_imba_reflection_slow:GetModifierProvidesFOWVision() return (self:GetStackCount() ~= 0 and 1 or 0) end

modifier_imba_reflection_slow_stack = class({})

function modifier_imba_reflection_slow_stack:IsDebuff()			return true end
function modifier_imba_reflection_slow_stack:IsHidden() 		return false end
function modifier_imba_reflection_slow_stack:IsPurgable() 		return true end
function modifier_imba_reflection_slow_stack:IsPurgeException() return true end
function modifier_imba_reflection_slow_stack:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_reflection_slow_stack:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetStackCount()) end

imba_terrorblade_conjure_image = class({})

LinkLuaModifier("modifier_imba_conjure_image_statue", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)

function imba_terrorblade_conjure_image:IsHiddenWhenStolen() 		return false end
function imba_terrorblade_conjure_image:IsRefreshable() 			return true end
function imba_terrorblade_conjure_image:IsStealable() 				return true end
function imba_terrorblade_conjure_image:IsNetherWardStealable()		return false end
function imba_terrorblade_conjure_image:GetAbilityTextureName() return (GetDemonicPower(self:GetCaster()) >= self:GetSpecialValueFor("t1_power") and "terrorblade_conjure_image_alt1" or "terrorblade_conjure_image") end

function imba_terrorblade_conjure_image:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	local power = GetDemonicPower(caster)
	local duration = self:GetSpecialValueFor("illusion_duration")
	if power >= self:GetSpecialValueFor("t1_power") then
		duration = duration + power / self:GetSpecialValueFor("t1_duration_denominator")
	end
	local illusion = IllusionManager:CreateIllusion(caster, pos, caster:GetForwardVector(), self:GetSpecialValueFor("illusion_outgoing"), self:GetSpecialValueFor("illusion_incoming"), 0, duration, caster, nil)
	illusion:EmitSound("Hero_Terrorblade.ConjureImage")
	if power < self:GetSpecialValueFor("t2_power") then
		illusion:AddNewModifier(caster, self, "modifier_imba_conjure_image_statue", {})
	end
	if power >= self:GetSpecialValueFor("t3_power") and caster:FindAbilityByName("imba_terrorblade_metamorphosis") and caster:FindAbilityByName("imba_terrorblade_metamorphosis"):GetLevel() > 0 then
		illusion:AddNewModifier(caster, caster:FindAbilityByName("imba_terrorblade_metamorphosis"), "modifier_imba_cmetamorphosis_aura", {})
	end
	if power >= self:GetSpecialValueFor("t1_power") then
		CostDemonicPower(caster, self:GetSpecialValueFor("power_cost"))
	end
end

modifier_imba_conjure_image_statue = class({})

function modifier_imba_conjure_image_statue:IsDebuff()			return false end
function modifier_imba_conjure_image_statue:IsHidden() 			return true end
function modifier_imba_conjure_image_statue:IsPurgable() 		return false end
function modifier_imba_conjure_image_statue:IsPurgeException() 	return false end
function modifier_imba_conjure_image_statue:GetStatusEffectName() return "particles/status_fx/status_effect_dark_seer_illusion.vpcf" end
function modifier_imba_conjure_image_statue:StatusEffectPriority() return 15 end

imba_terrorblade_metamorphosis = class({})

LinkLuaModifier("modifier_imba_cmetamorphosis_aura", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_metamorphosis", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)

function imba_terrorblade_metamorphosis:IsHiddenWhenStolen() 		return false end
function imba_terrorblade_metamorphosis:IsRefreshable() 			return true end
function imba_terrorblade_metamorphosis:IsStealable() 				return false end
function imba_terrorblade_metamorphosis:IsNetherWardStealable()		return false end
function imba_terrorblade_metamorphosis:GetAbilityTextureName() return (GetDemonicPower(self:GetCaster()) >= self:GetSpecialValueFor("t1_power") and "terrorblade_metamorphosis_alt1" or "terrorblade_metamorphosis") end

function imba_terrorblade_metamorphosis:CastFilterResult()
	if self:GetCaster():HasModifier("modifier_imba_cmetamorphosis_aura") or GetDemonicPower(self:GetCaster()) < (self:GetSpecialValueFor("cast_power_need") + self:GetCaster():GetTalentValue("special_bonus_imba_terrorblade_3")) then
		return UF_FAIL_CUSTOM
	end
end

function imba_terrorblade_metamorphosis:GetCustomCastError()
	if self:GetCaster():HasModifier("modifier_imba_cmetamorphosis_aura") then
		return "#IMBA_HUD_ERROR_ALREADY_METAMORPHOSIS"
	end
	if GetDemonicPower(self:GetCaster()) < self:GetSpecialValueFor("cast_power_need") then
		return "#IMBA_HUD_ERROR_NOT_ENOUGH_DEMONIC_POWER"
	end
end

function imba_terrorblade_metamorphosis:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_imba_cmetamorphosis_aura", {})
	CostDemonicPower(caster, (0 - self:GetSpecialValueFor("power_gain")))
end

modifier_imba_cmetamorphosis_aura = class({})

function modifier_imba_cmetamorphosis_aura:IsDebuff()			return false end
function modifier_imba_cmetamorphosis_aura:IsHidden() 			return false end
function modifier_imba_cmetamorphosis_aura:IsPurgable() 		return false end
function modifier_imba_cmetamorphosis_aura:IsPurgeException() 	return false end

function modifier_imba_cmetamorphosis_aura:IsAura() return true end
function modifier_imba_cmetamorphosis_aura:GetAuraDuration() return 0.1 end
function modifier_imba_cmetamorphosis_aura:GetModifierAura() return "modifier_imba_metamorphosis" end
function modifier_imba_cmetamorphosis_aura:GetAuraRadius() return self:GetAbility():GetSpecialValueFor("metamorph_aura_radius") end
function modifier_imba_cmetamorphosis_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_imba_cmetamorphosis_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_imba_cmetamorphosis_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO end
function modifier_imba_cmetamorphosis_aura:GetAuraEntityReject(unit)
	if unit == self:GetParent() or (unit:IsIllusion() and unit:GetPlayerOwnerID() == self:GetParent():GetPlayerOwnerID() and not unit:HasModifier("modifier_imba_reflection_illusion")) then
		return false
	else
		return true
	end
end

function modifier_imba_cmetamorphosis_aura:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_cmetamorphosis_aura:OnIntervalThink()
	if self:GetParent():IsRealHero() then
		CostDemonicPower(self:GetParent(), self:GetAbility():GetSpecialValueFor("power_cost"))
		if GetDemonicPower(self:GetParent()) <= 0 then
			if self:GetParent():HasAbility("imba_terrorblade_demonic_power") then
				self:GetParent():FindAbilityByName("imba_terrorblade_demonic_power"):EndCooldown()
				self:GetParent():FindAbilityByName("imba_terrorblade_demonic_power"):StartCooldown(2.5)
			end
			self:Destroy()
		end
	end
end

local demon = {
	"models/items/terrorblade/endless_purgatory_demon/endless_purgatory_demon.vmdl",
	"models/items/terrorblade/knight_of_foulfell_demon/knight_of_foulfell_demon.vmdl",
	"models/items/terrorblade/marauders_demon/marauders_demon.vmdl",
}

modifier_imba_metamorphosis = class({})

function modifier_imba_metamorphosis:IsDebuff()			return false end
function modifier_imba_metamorphosis:IsHidden() 		return false end
function modifier_imba_metamorphosis:IsPurgable() 		return false end
function modifier_imba_metamorphosis:IsPurgeException() return false end
function modifier_imba_metamorphosis:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS, MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT, MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, MODIFIER_PROPERTY_PROJECTILE_NAME, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_START, MODIFIER_PROPERTY_MODEL_CHANGE, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND} end
function modifier_imba_metamorphosis:GetModifierProjectileName() return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_base_attack.vpcf" end
function modifier_imba_metamorphosis:GetModifierBaseAttack_BonusDamage() return self:GetAbility():GetSpecialValueFor("bonus_damage") end
function modifier_imba_metamorphosis:GetModifierMoveSpeedBonus_Constant() return (0 - self:GetAbility():GetSpecialValueFor("speed_loss")) end
function modifier_imba_metamorphosis:GetModifierModelChange() return demon[RandomInt(1, 3)] end
function modifier_imba_metamorphosis:GetEffectName() return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf" end
function modifier_imba_metamorphosis:GetModifierBaseAttackTimeConstant() return self:GetAbility():GetSpecialValueFor("base_attack_time") end
function modifier_imba_metamorphosis:GetAttackSound() return "Hero_Terrorblade_Morphed.preAttack" end

function modifier_imba_metamorphosis:OnCreated()
	if IsServer() then
		self.attackCap = self:GetParent():GetAttackCapability()
		self:GetParent():SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
		self:GetParent():StartGesture(ACT_DOTA_CAST_ABILITY_3)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
		self:GetParent():EmitSound("Hero_Terrorblade.Metamorphosis")
	end
end

function modifier_imba_metamorphosis:OnDestroy()
	if IsServer() then
		self:GetParent():SetAttackCapability(self.attackCap)
		self.attackCap = nil
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:ReleaseParticleIndex(pfx)
	end
end

function modifier_imba_metamorphosis:GetModifierAttackRangeBonus()
	local bonus = GetDemonicPower(self:GetCaster()) >= self:GetAbility():GetSpecialValueFor("t2_power") and (self:GetAbility():GetSpecialValueFor("t3_multi") * GetDemonicPower(self:GetCaster())) or 0
	return (self:GetAbility():GetSpecialValueFor("bonus_range") + bonus + self:GetCaster():GetTalentValue("special_bonus_imba_terrorblade_2"))
end

function modifier_imba_metamorphosis:OnAttackStart(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() then
		self:GetParent():EmitSound("Hero_Terrorblade_Morphed.preAttack")
	end
end

function modifier_imba_metamorphosis:OnAttack(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() then
		self:GetParent():EmitSound("Hero_Terrorblade_Morphed.Attack")
	end
end

function modifier_imba_metamorphosis:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker == self:GetParent() then
		keys.target:EmitSound("Hero_Terrorblade_Morphed.projectileImpact")
	end
	if keys.attacker == self:GetParent() and self:GetParent():IsRealHero() and GetDemonicPower(self:GetParent()) < self:GetAbility():GetSpecialValueFor("t2_power") then
		local target_type = DOTA_UNIT_TARGET_BASIC
		if GetDemonicPower(self:GetParent()) >= self:GetAbility():GetSpecialValueFor("t1_power") then
			target_type = target_type + DOTA_UNIT_TARGET_HERO
		end
		local enemy = FindUnitsInRadius(self:GetParent():GetTeamNumber(), keys.target:GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("t1_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, target_type, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for i=1, #enemy do
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_transform_end.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy[i])
			ParticleManager:ReleaseParticleIndex(pfx)
			ApplyDamage({victim = enemy[i], attacker = self:GetParent(), ability = self:GetAbility(), damage_type = self:GetAbility():GetAbilityDamageType(), damage = self:GetAbility():GetSpecialValueFor("t1_damage")})
		end
	end
end

function modifier_imba_metamorphosis:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if not self:GetParent():IsRealHero() or keys.attacker ~= self:GetParent() or not keys.unit:IsCreep() or GetDemonicPower(self:GetParent()) > self:GetAbility():GetSpecialValueFor("t1_power") then
		return
	end
	CostDemonicPower(self:GetParent(), (0 - self:GetAbility():GetSpecialValueFor("creep_power_gain")))
end

imba_terrorblade_sunder = class({})

LinkLuaModifier("modifier_imba_sunder", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_sunder_target", "hero/hero_terrorblade", LUA_MODIFIER_MOTION_NONE)

function imba_terrorblade_sunder:IsHiddenWhenStolen() 		return false end
function imba_terrorblade_sunder:IsRefreshable() 			return true end
function imba_terrorblade_sunder:IsStealable() 				return true end
function imba_terrorblade_sunder:IsNetherWardStealable()	return false end
function imba_terrorblade_sunder:GetAbilityTextureName() return (GetDemonicPower(self:GetCaster()) >= self:GetSpecialValueFor("t1_power") and "terrorblade_sunder_alt1" or "terrorblade_sunder") end
function imba_terrorblade_sunder:GetCastPoint() return (GetDemonicPower(self:GetCaster()) >= self:GetSpecialValueFor("t1_power") and 0 or self.BaseClass.GetCastPoint(self)) end

function imba_terrorblade_sunder:CastFilterResultTarget(target)
	if IsEnemy(self:GetCaster(), target) and target:IsMagicImmune() and GetDemonicPower(self:GetCaster()) < self:GetSpecialValueFor("t2_power") then
		return UF_FAIL_MAGIC_IMMUNE_ENEMY
	end
	if target == self:GetCaster() or not target:IsHero() then
		return UF_FAIL_CUSTOM
	end
	if target:IsInvulnerable() then
		return UF_FAIL_INVULNERABLE
	end
end

function imba_terrorblade_sunder:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "#dota_hud_error_cant_cast_on_self"
	elseif not target:IsHero() then
		return "#dota_hud_error_cant_cast_on_creep"
	end
end

function imba_terrorblade_sunder:OnAbilityPhaseStart()
	self:GetCaster():EmitSound("Hero_Terrorblade.Sunder.Cast")
	return true
end

function imba_terrorblade_sunder:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	target:EmitSound("Hero_Terrorblade.Sunder.Target")
	local min_hp = self:GetSpecialValueFor("hit_point_minimum")
	local power = GetDemonicPower(caster)
	local caster_hp_pct = caster:GetHealthPercent()
	local target_hp_pct = target:GetHealthPercent()
	local caster_hp = math.max(min_hp, caster:GetMaxHealth() * (target_hp_pct / 100))
	local target_hp = math.max(min_hp, target:GetMaxHealth() * (caster_hp_pct / 100))
	local caster_color = caster:GetHeroColor()
	local caster_hsv = RGBConvertToHSV(caster_color)
	local target_color = target:GetHeroColor()
	local target_hsv = RGBConvertToHSV(target_color)
	caster:SetHealth(caster_hp)
	target:SetHealth(target_hp)
	local pfx1 = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx1, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx1, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx1, 15, Vector(caster_color[1], caster_color[2], caster_color[3]))
	ParticleManager:SetParticleControl(pfx1, 16, Vector(255, 255, 255))
	ParticleManager:SetParticleControl(pfx1, 60, Vector(-70, 0, 255))
	ParticleManager:SetParticleControl(pfx1, 61, Vector(1,0,0))
	ParticleManager:ReleaseParticleIndex(pfx1)
	local pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(pfx2, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx2, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx2, 15, Vector(target_color[1], target_color[2], target_color[3]))
	ParticleManager:SetParticleControl(pfx2, 16, Vector(255, 255, 255))
	ParticleManager:SetParticleControl(pfx2, 60, Vector(-70, 0, 255))
	ParticleManager:SetParticleControl(pfx2, 61, Vector(1,0,0))
	ParticleManager:ReleaseParticleIndex(pfx2)
	if power >= self:GetSpecialValueFor("t1_power") then
		CostDemonicPower(caster, self:GetSpecialValueFor("power_cost"))
	end
	if power >= self:GetSpecialValueFor("t3_power") then
		caster:AddNewModifier(caster, self, "modifier_imba_sunder", {duration = self:GetSpecialValueFor("t3_duration"), target = target:entindex()})
		target:AddNewModifier(caster, self, "modifier_imba_sunder_target", {duration = self:GetSpecialValueFor("t3_duration")})
	end
end

modifier_imba_sunder = class({})

function modifier_imba_sunder:IsDebuff()			return false end
function modifier_imba_sunder:IsHidden() 			return false end
function modifier_imba_sunder:IsPurgable() 			return false end
function modifier_imba_sunder:IsPurgeException() 	return false end
function modifier_imba_sunder:GetEffectName() return "particles/hero/terrorbalde/terrorblade_sunder_overhead.vpcf" end
function modifier_imba_sunder:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_sunder:ShouldUseOverheadOffset() return true end
function modifier_imba_sunder:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP} end
function modifier_imba_sunder:OnTooltip() return self:GetAbility():GetSpecialValueFor("t3_pct") end

function modifier_imba_sunder:OnCreated(keys)
	if IsServer() then
		self.target = EntIndexToHScript(keys.target)
	end
end

function modifier_imba_sunder:OnDestroy()
	if IsServer() then
		self.target = nil
	end
end

function modifier_imba_sunder:GetModifierIncomingDamage_Percentage(keys)
	if not IsServer() then
		return
	end
	if self.target then
		local dmg = keys.damage * (self:GetAbility():GetSpecialValueFor("t3_pct") / 100)
		local damageTable = {
							victim = self.target,
							attacker = self:GetParent(),
							damage = dmg,
							damage_type = keys.damage_type,
							damage_flags = DOTA_DAMAGE_FLAG_REFLECTION, --Optional.
							ability = self:GetAbility(), --Optional.
							}
		ApplyDamage(damageTable)
	end
	return (0 - self:GetAbility():GetSpecialValueFor("t3_pct"))
end

modifier_imba_sunder_target = class({})

function modifier_imba_sunder_target:IsDebuff()				return true end
function modifier_imba_sunder_target:IsHidden() 			return false end
function modifier_imba_sunder_target:IsPurgable() 			return false end
function modifier_imba_sunder_target:IsPurgeException() 	return false end
function modifier_imba_sunder_target:GetEffectName() return "particles/hero/terrorbalde/terrorblade_sunder_overhead.vpcf" end
function modifier_imba_sunder_target:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_sunder_target:ShouldUseOverheadOffset() return true end