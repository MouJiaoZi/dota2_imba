CreateEmptyTalents("oracle")

imba_oracle_fortunes_end = class({})

LinkLuaModifier("modifier_fortunes_end_cast_timer", "hero/hero_oracle.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fortunes_end_debuff", "hero/hero_oracle.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_fortunes_end_buff", "hero/hero_oracle.lua", LUA_MODIFIER_MOTION_NONE)

function imba_oracle_fortunes_end:IsHiddenWhenStolen() 		return false end
function imba_oracle_fortunes_end:IsRefreshable() 			return true end
function imba_oracle_fortunes_end:IsStealable() 			return true end
function imba_oracle_fortunes_end:IsNetherWardStealable()	return true end
function imba_oracle_fortunes_end:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_oracle_fortunes_end:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:EmitSound("Hero_Oracle.FortunesEnd.Channel")
	caster:RemoveModifierByName("modifier_fortunes_end_cast_timer")
	caster:AddNewModifier(caster, self, "modifier_fortunes_end_cast_timer", {})
	self.channeltime = self:GetChannelTime()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_cast_tgt.vpcf", PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_ABSORIGIN, nil, target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)
end

function imba_oracle_fortunes_end:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	caster:StopSound("Hero_Oracle.FortunesEnd.Channel")
	local buff = caster:FindModifierByName("modifier_fortunes_end_cast_timer")
	if not buff then
		return
	end
	local time = buff:GetElapsedTime() / self.channeltime
	caster:RemoveModifierByName("modifier_fortunes_end_cast_timer")
	local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 2.0}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
	sound:EmitSound("Hero_Oracle.FortunesEnd.Attack")
	sound = sound:entindex()
	local info = 
	{
		Target = target,
		Source = caster,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_oracle/oracle_fortune_prj.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("bolt_speed"),
		iSourceAttach = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 10,
		bProvidesVision = false,
		ExtraData = {time = time, sound = sound},	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_oracle_fortunes_end:OnProjectileThink_ExtraData(pos, keys)
	EntIndexToHScript(keys.sound):SetAbsOrigin(pos)
end

function imba_oracle_fortunes_end:OnProjectileHit_ExtraData(target, pos, keys)
	if not target or (target and target:TriggerStandardTargetSpell(self)) then
		return
	end
	target:EmitSound("Hero_Oracle.FortunesEnd.Target")
	local duration = math.max(self:GetSpecialValueFor("minimum_purge_duration"), keys.time * self:GetSpecialValueFor("maximum_purge_duration"))
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	local pfx_aoe = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_aoe.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx_aoe, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(pfx_aoe, 2, Vector(radius, radius, radius))
	ParticleManager:ReleaseParticleIndex(pfx_aoe)
	local unit = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for i=1, #unit do
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_dmg.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, unit[i]:GetAttachmentOrigin(unit[i]:ScriptLookupAttachment("attach_hitloc")))
		ParticleManager:SetParticleControl(pfx, 1, target:GetAttachmentOrigin(target:ScriptLookupAttachment("attach_hitloc")))
		ParticleManager:SetParticleControl(pfx, 3, unit[i]:GetAttachmentOrigin(unit[i]:ScriptLookupAttachment("attach_hitloc")))
		ParticleManager:ReleaseParticleIndex(pfx)
		if IsEnemy(caster, unit[i]) then
			unit[i]:AddNewModifier(caster, self, "modifier_fortunes_end_debuff", {duration = duration})
			unit[i]:Purge(true, false, false, false, false)
			ApplyDamage({victim = unit[i], attacker = caster, ability = self, damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType()})
		else
			unit[i]:AddNewModifier(caster, self, "modifier_fortunes_end_buff", {duration = self:GetSpecialValueFor("ally_duration")})
			unit[i]:Purge(false, true, false, false, false)
		end
	end
end

modifier_fortunes_end_cast_timer = class({})

function modifier_fortunes_end_cast_timer:IsDebuff()			return false end
function modifier_fortunes_end_cast_timer:IsHidden() 			return not IsInToolsMode() end
function modifier_fortunes_end_cast_timer:IsPurgable() 			return false end
function modifier_fortunes_end_cast_timer:IsPurgeException() 	return false end
function modifier_fortunes_end_cast_timer:RemoveOnDeath() 		return false end
function modifier_fortunes_end_cast_timer:AllowIllusionDuplicate() return false end

function modifier_fortunes_end_cast_timer:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_oracle/oracle_fortune_channel.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

modifier_fortunes_end_debuff = class({})

function modifier_fortunes_end_debuff:IsDebuff()			return true end
function modifier_fortunes_end_debuff:IsHidden() 			return false end
function modifier_fortunes_end_debuff:IsPurgable() 			return true end
function modifier_fortunes_end_debuff:IsPurgeException() 	return true end
function modifier_fortunes_end_debuff:GetEffectName() return "particles/units/heroes/hero_oracle/oracle_fortune_purge.vpcf" end
function modifier_fortunes_end_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_fortunes_end_debuff:CheckState() return {[MODIFIER_STATE_ROOTED] = true} end

function modifier_fortunes_end_debuff:OnCreated()
	if IsServer() then
		self:GetParent():RemoveAllModifiersByName("modifier_oracle_purifying_flames")
		self:StartIntervalThink(0.1)
	end
end

function modifier_fortunes_end_debuff:OnIntervalThink() self:GetParent():RemoveAllModifiersByName("modifier_oracle_purifying_flames") end

modifier_fortunes_end_buff = class({})

function modifier_fortunes_end_buff:IsDebuff()			return false end
function modifier_fortunes_end_buff:IsHidden() 			return false end
function modifier_fortunes_end_buff:IsPurgable() 		return true end
function modifier_fortunes_end_buff:IsPurgeException() 	return true end
function modifier_fortunes_end_buff:GetEffectName() return "particles/units/heroes/hero_oracle/oracle_fortune_channel.vpcf" end
function modifier_fortunes_end_buff:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_fortunes_end_buff:ShouldUseOverheadOffset() return true end

function modifier_fortunes_end_buff:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_fortunes_end_buff:OnIntervalThink()
	local buff = self:GetParent():FindAllModifiersByName("modifier_oracle_purifying_flames")
	for i=1, #buff do
		buff[i]:SetDuration(buff[i]:GetRemainingTime() + 0.1, true)
	end
end