CreateEmptyTalents("earthshaker")

imba_earthshaker_fissure = class({})

function imba_earthshaker_fissure:IsHiddenWhenStolen() 		return false end
function imba_earthshaker_fissure:IsRefreshable() 			return true end
function imba_earthshaker_fissure:IsStealable() 			return true end
function imba_earthshaker_fissure:IsNetherWardStealable()	return true end
function imba_earthshaker_fissure:GetCastRange() return self:GetSpecialValueFor("fissure_range") end

function imba_earthshaker_fissure:OnUpgrade()
	local abi1 = self:GetCaster():FindAbilityByName("imba_earthshaker_fissure_main")
	local abi2 = self:GetCaster():FindAbilityByName("imba_earthshaker_fissure_sec")
	if abi1 then
		abi1:SetLevel(self:GetLevel())
	end
	if abi2 then
		abi2:SetLevel(self:GetLevel())
	end
end

function imba_earthshaker_fissure:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = (pos - caster:GetAbsOrigin()):Normalized()
	direction.z = 0.0
	local length = self:GetSpecialValueFor("fissure_range") + caster:GetCastRangeBonus()
	local pos0 = caster:GetAbsOrigin() + direction * 128
	local pos1 = caster:GetAbsOrigin() + direction * (length + 128)
	local angle = 360 / self:GetSpecialValueFor("number")
	local total = (length / 80)
	for i=0, (self:GetSpecialValueFor("number") - 1) do
		local pos_start = pos0
		local pos_end = pos1
		if i ~= 0 then
			pos_start = RotatePosition(caster:GetAbsOrigin(), QAngle(0, angle * i, 0), pos0)
			pos_end = RotatePosition(caster:GetAbsOrigin(), QAngle(0, angle * i, 0), pos1)
		end
		local direc = (pos_end - pos_start):Normalized()
		direc.z = 0
		local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 2.0}, pos_end, caster:GetTeamNumber(), false)
		sound:EmitSound("Hero_EarthShaker.Fissure")
		if i == 0 then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx, 0, pos_start)
			ParticleManager:SetParticleControl(pfx, 1, pos_end)
			ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("fissure_duration"), 0, 0))
			ParticleManager:ReleaseParticleIndex(pfx)
			for j = 0, total do
				local block = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = self:GetSpecialValueFor("fissure_duration"), destroy_sound = "Hero_EarthShaker.FissureDestroy"}, pos_start + (direc * (length / total)) * j, caster:GetTeamNumber(), true)
				block:SetHullRadius(80)
			end
			local enemy = FindUnitsInLine(caster:GetTeamNumber(), pos_start, pos_end, nil, self:GetSpecialValueFor("fissure_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
			for k = 1, #enemy do
				enemy[k]:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("stun_duration")})
				ApplyDamage({attacker = caster, victim = enemy[k], damage = self:GetSpecialValueFor("damage"), damage_type = self:GetAbilityDamageType(), ability = self})
			end
		end
		if i ~= 0 then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx, 0, pos_start)
			ParticleManager:SetParticleControl(pfx, 1, pos_end)
			ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetSpecialValueFor("secondary_duration"), 0, 0))
			ParticleManager:ReleaseParticleIndex(pfx)
			for j = 0, total do
				local block = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = self:GetSpecialValueFor("secondary_duration"), destroy_sound = "Hero_EarthShaker.FissureDestroy"}, pos_start + (direc * (length / total)) * j, caster:GetTeamNumber(), true)
				block:SetHullRadius(80)
			end
			local enemy = FindUnitsInLine(caster:GetTeamNumber(), pos_start, pos_end, nil, self:GetSpecialValueFor("fissure_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE)
			for k = 1, #enemy do
				enemy[k]:AddNewModifier(caster, self, "modifier_imba_stunned", {duration = self:GetSpecialValueFor("secondary_stun")})
				ApplyDamage({attacker = caster, victim = enemy[k], damage = self:GetSpecialValueFor("secondary_damage"), damage_type = self:GetAbilityDamageType(), ability = self})
			end
		end
	end
	local enemy = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, length * 1.3, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for i=1, #enemy do
		enemy[i]:AddNewModifier(caster, self, "modifier_phased", {duration = FrameTime()*2})
	end
	caster:EmitSound("Hero_EarthShaker.Fissure")
end
