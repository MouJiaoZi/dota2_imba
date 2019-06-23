--custom/imba_aegis

modifier_imba_aegis = class({})

function modifier_imba_aegis:IsDebuff()			return false end
function modifier_imba_aegis:IsHidden() 		return false end
function modifier_imba_aegis:IsPurgable() 		return false end
function modifier_imba_aegis:IsPurgeException() return false end
function modifier_imba_aegis:RemoveOnDeath() 	return false end
function modifier_imba_aegis:AllowIllusionDuplicate() return false end
function modifier_imba_aegis:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_imba_aegis:GetTexture() return "imba_aegis" end
function modifier_imba_aegis:DeclareFunctions() return {MODIFIER_PROPERTY_REINCARNATION, MODIFIER_EVENT_ON_DEATH} end
function modifier_imba_aegis:ReincarnateTime() return 3.0 end

function modifier_imba_aegis:OnCreated()
	if IsServer() then
		Notifications:BottomToAll({hero=self:GetParent():GetUnitName(), duration=5.0, class="NotificationMessage"})
		Notifications:BottomToAll({text="#"..self:GetParent():GetUnitName(), continue=true})
		Notifications:BottomToAll({text="imba_player_aegis_message", continue=true})
	end
end

function modifier_imba_aegis:OnRefresh() self:OnCreated() end

function modifier_imba_aegis:OnDeath(keys)
	if not IsServer() or self:GetParent():IsIllusion() or keys.unit ~= self:GetParent() then
		return
	end
	self:Destroy()
	local caster = self:GetParent()
	local pfx = ParticleManager:CreateParticle("particles/items_fx/aegis_timer.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(3, 3, 3))
	ParticleManager:ReleaseParticleIndex(pfx)
	Timers:CreateTimer(3.1, function()
		local pfx2 = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(pfx2, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx2, 1, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx2)
	end
	)
end

function modifier_imba_aegis:OnDestroy()
	if IsServer() then
		for i=0, 23 do
			local ability = self:GetParent():GetAbilityByIndex(i)
			if ability then
				ability:EndCooldown()
			end
		end
		if self:GetParent():IsAlive() then
			local pfx2 = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(pfx2, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx2, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx2)
			self:GetParent():SetHealth(self:GetParent():GetMaxHealth())
			self:GetParent():SetMana(self:GetParent():GetMaxMana())
			self:GetParent():EmitSound("Aegis.Expire")
			Notifications:BottomToTeam(self:GetParent():GetTeamNumber(), {hero=self:GetParent():GetUnitName(), duration=5.0, class="NotificationMessage"})
			Notifications:BottomToTeam(self:GetParent():GetTeamNumber(), {text="#"..self:GetParent():GetUnitName(), continue=true})
			Notifications:BottomToTeam(self:GetParent():GetTeamNumber(), {text="DOTA_IMBA_AEGIS_EXPIRE", continue=true})
		end
	end
end


modifier_imba_roshan_upgrade = class({})

function modifier_imba_roshan_upgrade:IsDebuff()			return false end
function modifier_imba_roshan_upgrade:IsHidden() 			return true end
function modifier_imba_roshan_upgrade:IsPurgable() 			return false end
function modifier_imba_roshan_upgrade:IsPurgeException() 	return false end
function modifier_imba_roshan_upgrade:RemoveOnDeath() return true end
function modifier_imba_roshan_upgrade:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_ATTACK_RANGE_BONUS} end
function modifier_imba_roshan_upgrade:GetModifierAttackSpeedBonus_Constant() return (self:GetStackCount() * 50) end
function modifier_imba_roshan_upgrade:GetModifierPreAttack_BonusDamage() return (self:GetStackCount() * 80) end
function modifier_imba_roshan_upgrade:GetModifierPhysicalArmorBonus() return (self:GetStackCount() * 2) end
function modifier_imba_roshan_upgrade:GetModifierSpellAmplify_Percentage() return (self:GetStackCount() * 30) end
function modifier_imba_roshan_upgrade:GetModifierAttackRangeBonus() return (self:GetStackCount() < 3 and 0 or 180) end
function modifier_imba_roshan_upgrade:GetPriority() return (self:GetStackCount() < 4 and MODIFIER_PRIORITY_ULTRA or 100) end
function modifier_imba_roshan_upgrade:CheckState()
	if self:GetStackCount() < 8 then
		return {[MODIFIER_STATE_STUNNED] = false, [MODIFIER_STATE_UNSLOWABLE] = true, [MODIFIER_STATE_PASSIVES_DISABLED] = false, [MODIFIER_STATE_SILENCED] = false}
	else
		return {[MODIFIER_STATE_STUNNED] = false, [MODIFIER_STATE_CANNOT_MISS] = true, [MODIFIER_STATE_DISARMED] = false, [MODIFIER_STATE_SILENCED] = false, [MODIFIER_STATE_ROOTED] = false, [MODIFIER_STATE_UNSLOWABLE] = true, [MODIFIER_STATE_PASSIVES_DISABLED] = false} 
	end
end


function modifier_imba_roshan_upgrade:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() then
		self.damage = GameRules:GetGameTime()
		keys.attacker:RemoveModifierByName("modifier_dark_willow_shadow_realm_buff")
	end
end

function modifier_imba_roshan_upgrade:OnCreated()
	if IsServer() then
		self.damage = 0
		self:StartIntervalThink(0.2)
	end
end

function modifier_imba_roshan_upgrade:OnIntervalThink()
	local boss = self:GetParent()
	if self:IsNull() or boss:IsNull() or not boss:IsAlive() then
		self:Destroy()
		return
	end
	if boss:GetAttackTarget() and boss:GetAttackTarget():IsCourier() then
		boss:Stop()
	end
	----back to your house
	if #Entities:FindAllByClassnameWithin("trigger_boss_attackable", boss:GetAbsOrigin(), 300) == 0 then
		FindClearSpaceForUnit(boss, roshan_pos, true)
		boss:Stop()
	end
	----regen health
	if GameRules:GetGameTime() - self.damage > 5.0 and boss:GetHealth() < boss:GetMaxHealth() then
		boss:Heal(boss:GetMaxHealth() * 0.1, nil)
		FindClearSpaceForUnit(boss, roshan_pos, true)
	end
	----ability
	if boss:HasAbility("imba_roshan_slam") then
		local ability = boss:FindAbilityByName("imba_roshan_slam")
		if ability:IsCooldownReady() and boss:GetAttackTarget() then
			boss:CastAbilityNoTarget(ability, -1)
		end
	end
end


imba_roshan_slam = class({})

LinkLuaModifier("modifier_imba_roshan_slam_slow", "modifier/modifier_imba_aegis", LUA_MODIFIER_MOTION_NONE)

function imba_roshan_slam:IsHiddenWhenStolen() 		return false end
function imba_roshan_slam:IsRefreshable() 			return false end
function imba_roshan_slam:IsStealable() 			return false end
function imba_roshan_slam:IsNetherWardStealable()	return false end

function imba_roshan_slam:OnSpellStart()
	local caster = self:GetCaster()
	caster:EmitSound("Roshan.Slam")
	local pfx = ParticleManager:CreateParticle("particles/neutral_fx/roshan_slam.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetSpecialValueFor("radius"), 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local cd = self:GetCooldown(-1)
	cd = math.max(0.1, (cd - #enemy) * self:GetSpecialValueFor("cdr_per_hit"))
	self:EndCooldown()
	self:StartCooldown(cd)
	for i=1, #enemy do
		ApplyDamage({victim = enemy[i], attacker = caster, damage = self:GetSpecialValueFor("damage"), ability = self, damage_type = self:GetAbilityDamageType()})
		enemy[i]:AddNewModifier(caster, self, "modifier_imba_roshan_slam_slow", {duration = self:GetSpecialValueFor("slow_duration")})
		local buff = enemy[i]:FindModifierByName("modifier_wisp_tether_haste")
		if buff then
			local ca = buff:GetCaster()
			ca:RemoveModifierByName("modifier_wisp_tether")
			buff:GetAbility():EndCooldown()
			buff:GetAbility():StartCooldown(cd * 2)
			enemy[i]:RemoveModifierByName("modifier_wisp_tether_haste")
		end
		local buff2 = enemy[i]:FindModifierByName("modifier_imba_gravekeepers_cloak")
		if buff2 then
			buff2:GetCaster():FindModifierByName("modifier_imba_gravekeepers_cloak"):SetStackCount(0)
			buff2:GetCaster():AddNewModifierWhenPossible(buff2:GetCaster(), buff2:GetAbility(), "modifier_imba_gravekeepers_cloak_recover_timer", {duration = 10})
		end
	end
end

modifier_imba_roshan_slam_slow = class({})

function modifier_imba_roshan_slam_slow:IsDebuff()			return true end
function modifier_imba_roshan_slam_slow:IsHidden() 			return false end
function modifier_imba_roshan_slam_slow:IsPurgable() 		return false end
function modifier_imba_roshan_slam_slow:IsPurgeException() 	return false end
function modifier_imba_roshan_slam_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_roshan_slam_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("slow_amount")) end