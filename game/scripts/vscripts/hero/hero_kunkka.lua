CreateEmptyTalents("kunkka")

KUNKKA_TIDEBRINGER_HIGH_TIDE = 1
KUNKKA_TIDEBRINGER_WAVE_BREAK = 2
KUNKKA_TIDEBRINGER_TSUNAMI = 4

TIDE_TYPE = {
	{"modifier_imba_tidebringer_high_tide", KUNKKA_TIDEBRINGER_HIGH_TIDE},
	{"modifier_imba_tidebringer_wave_break", KUNKKA_TIDEBRINGER_WAVE_BREAK},
	{"modifier_imba_tidebringer_tsunami", KUNKKA_TIDEBRINGER_TSUNAMI}
}

function GetTideEffect(caster, bRemove)
	local tide = 0
	for _, buff in pairs(TIDE_TYPE) do
		if caster:HasModifier(buff[1]) then
			tide = tide + buff[2]
			if bRemove then
				caster:RemoveModifierByName(buff[1])
			end
		end
	end
	return tide
end


imba_kunkka_torrent = class({})

LinkLuaModifier("modifier_imba_torrent_delay", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_torrent_slow", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_torrent_stun", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)

function imba_kunkka_torrent:IsHiddenWhenStolen() 		return false end
function imba_kunkka_torrent:IsRefreshable() 			return true  end
function imba_kunkka_torrent:IsStealable() 				return true  end
function imba_kunkka_torrent:IsNetherWardStealable() 	return true end

function imba_kunkka_torrent:GetAOERadius() return self:GetSpecialValueFor("radius") end

function imba_kunkka_torrent:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local tide = GetTideEffect(caster, true)
	local delay = self:GetSpecialValueFor("delay")
	if bit.band(tide, KUNKKA_TIDEBRINGER_HIGH_TIDE) == KUNKKA_TIDEBRINGER_HIGH_TIDE then
		delay = 0.03
	else
		EmitSoundOnLocationForAllies(pos, "Ability.pre.Torrent", caster)
	end
	AddFOWViewer(caster:GetTeam(), pos, self:GetSpecialValueFor("radius") * 1.55, self:GetSpecialValueFor("vision_duration"), true)
	CreateModifierThinker(caster, self, "modifier_imba_torrent_delay", {duration = delay, tide = tide}, pos, caster:GetTeamNumber(), false)
end

modifier_imba_torrent_delay = class({})

function modifier_imba_torrent_delay:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true} end
function modifier_imba_torrent_delay:OnCreated(keys)
	if IsServer() then
		self.tide = keys.tide
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_bubbles.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_torrent_delay:OnDestroy()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_torrent_splash.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local pos = self:GetParent():GetAbsOrigin()
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_torrent_stun", {duration = self:GetAbility():GetSpecialValueFor("stun_duration"), pos_x = pos.x, pos_y = pos.y, pos_z = pos.z, tide = self.tide})
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_torrent_slow", {duration = self:GetAbility():GetSpecialValueFor("slow_duration"), pos_x = pos.x, pos_y = pos.y, pos_z = pos.z, tide = self.tide})
		end
		self.tide = nil
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Ability.Torrent", nil)
	end
end

modifier_imba_torrent_stun = class({})

function modifier_imba_torrent_stun:IsMotionController()	return true end
function modifier_imba_torrent_stun:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_imba_torrent_stun:IsStunDebuff() 		return true end
function modifier_imba_torrent_stun:IsDebuff()			return true end
function modifier_imba_torrent_stun:IsHidden() 			return false end
function modifier_imba_torrent_stun:IsPurgable() 		return false end
function modifier_imba_torrent_stun:IsPurgeException() 	return true end
function modifier_imba_torrent_stun:CheckState() return {[MODIFIER_STATE_STUNNED] = true, [MODIFIER_STATE_NO_UNIT_COLLISION] = true} end
function modifier_imba_torrent_stun:DeclareFunctions() return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION} end
function modifier_imba_torrent_stun:GetOverrideAnimation() return ACT_DOTA_FLAIL end
function modifier_imba_torrent_stun:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.pos = Vector(keys.pos_x, keys.pos_y, keys.pos_z)
		self.tide = keys.tide
		if bit.band(keys.tide, KUNKKA_TIDEBRINGER_TSUNAMI) == KUNKKA_TIDEBRINGER_TSUNAMI then
			self.distance = (self:GetParent():GetAbsOrigin() - self.pos):Length2D()
		end
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_torrent_stun:OnIntervalThink()
	local motion_progress = math.min(self:GetElapsedTime() / self:GetDuration(), 1.0)
	local height = self:GetAbility():GetSpecialValueFor("torrent_height")
	local next_pos = GetGroundPosition(self:GetParent():GetAbsOrigin(), nil) 
	if self.distance then
		next_pos = GetGroundPosition(self.pos + (self:GetParent():GetAbsOrigin() - self.pos):Normalized() * (self.distance * (1 - motion_progress)), nil)
	end
	next_pos.z = next_pos.z - 4 * height * motion_progress ^ 2 + 4 * height * motion_progress
	self:GetParent():SetAbsOrigin(next_pos)
	local dmg = self:GetAbility():GetSpecialValueFor("damage") + (bit.band(self.tide, KUNKKA_TIDEBRINGER_TSUNAMI) == KUNKKA_TIDEBRINGER_TSUNAMI and self:GetAbility():GetSpecialValueFor("tsunami_damage") or 0)
	dmg = dmg / (self:GetDuration() / FrameTime())
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetCaster(),
						damage = dmg,
						damage_type = self:GetAbility():GetAbilityDamageType(),
						damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end

function modifier_imba_torrent_stun:OnDestroy()
	if IsServer() then
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
		self.pos = nil
		self.tide = nil
		if self.distance then
			self.distance = nil
		end
	end
end

modifier_imba_torrent_slow = class({})

function modifier_imba_torrent_slow:IsDebuff()			return true end
function modifier_imba_torrent_slow:IsHidden() 			return false end
function modifier_imba_torrent_slow:IsPurgable() 		return true end
function modifier_imba_torrent_slow:IsPurgeException() 	return true end
function modifier_imba_torrent_slow:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_torrent_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetStackCount()) end
function modifier_imba_torrent_slow:OnCreated(keys)
	if IsServer() then
		if bit.band(keys.tide, KUNKKA_TIDEBRINGER_HIGH_TIDE) == KUNKKA_TIDEBRINGER_HIGH_TIDE then
			self:SetStackCount(self:GetAbility():GetSpecialValueFor("high_tide_slow"))
		else
			self:SetStackCount(self:GetAbility():GetSpecialValueFor("movespeed_bonus"))
		end
	end
end


imba_kunkka_tidebringer = class({})

LinkLuaModifier("modifier_imba_tidebringer", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_tidebringer_high_tide", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_tidebringer_wave_break", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_tidebringer_tsunami", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)

function imba_kunkka_tidebringer:IsHiddenWhenStolen() 		return false end
function imba_kunkka_tidebringer:IsRefreshable() 			return true  end
function imba_kunkka_tidebringer:IsStealable() 				return false  end
function imba_kunkka_tidebringer:IsNetherWardStealable() 	return false end

function imba_kunkka_tidebringer:OnUpgrade()
	if not self.first then
		self:ToggleAutoCast()
		self.first = true
	end
end

function imba_kunkka_tidebringer:OnSpellStart() self:EndCooldown() end

function imba_kunkka_tidebringer:GetIntrinsicModifierName() return "modifier_imba_tidebringer" end

modifier_imba_tidebringer = class({})

function modifier_imba_tidebringer:IsDebuff()			return false end
function modifier_imba_tidebringer:IsPurgable() 		return false end
function modifier_imba_tidebringer:IsPurgeException() 	return false end
function modifier_imba_tidebringer:IsHidden()
	if self:GetStackCount() ~= 0 then
		return true
	else
		return false
	end
end

function modifier_imba_tidebringer:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_tidebringer:OnIntervalThink()
	if self:GetAbility():GetAutoCastState() and self:GetAbility():IsCooldownReady() then
		self:SetStackCount(0)
		if not self.pfx then
			self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_weapon_tidebringer.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt(self.pfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_sword", self:GetParent():GetAbsOrigin(), true)
			EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Kunkaa.Tidebringer", self:GetParent())
		end
	else
		self:SetStackCount(1)
		if self.pfx then
			ParticleManager:DestroyParticle(self.pfx, false)
			ParticleManager:ReleaseParticleIndex(self.pfx)
			self.pfx = nil
		end
	end
end

function modifier_imba_tidebringer:DeclareFunctions() return {MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE, MODIFIER_EVENT_ON_ATTACK, MODIFIER_EVENT_ON_ATTACK_LANDED} end
function modifier_imba_tidebringer:GetModifierBaseDamageOutgoing_Percentage()
	local tide = GetTideEffect(self:GetParent(), false)
	if bit.band(tide, KUNKKA_TIDEBRINGER_HIGH_TIDE) == KUNKKA_TIDEBRINGER_HIGH_TIDE then
		return (self:GetAbility():GetSpecialValueFor("damage_bonus") * 2)
	elseif not self:IsHidden() then
		return self:GetAbility():GetSpecialValueFor("damage_bonus")
	else
		return 0
	end
end

function modifier_imba_tidebringer:OnAttack(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() then
		return
	end
	if not self:IsHidden() then
		EmitSoundOnLocationWithCaster(self:GetParent():GetAbsOrigin(), "Hero_Kunkka.Tidebringer.Attack", self:GetParent())
	end
end

function modifier_imba_tidebringer:OnAttackLanded(keys)
	if not IsServer() then
		return
	end
	if keys.attacker ~= self:GetParent() or keys.target:GetTeamNumber() == self:GetParent():GetTeamNumber() or keys.target:IsOther() or self:IsHidden() then
		return
	end
	local pfx_name = "particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf"
	local target = keys.target
	local attacker = self:GetParent()
	DoCleaveAttack(attacker, target, self:GetAbility(), keys.damage, self:GetAbility():GetSpecialValueFor("cleave_starting_width"), self:GetAbility():GetSpecialValueFor("cleave_ending_width"), self:GetAbility():GetSpecialValueFor("cleave_distance"), pfx_name)
	local tide = GetTideEffect(attacker, true)
	if bit.band(tide, KUNKKA_TIDEBRINGER_WAVE_BREAK) == KUNKKA_TIDEBRINGER_WAVE_BREAK then
		--do nothing
	else
		self:GetAbility():UseResources(true, true, true)
	end
	if bit.band(tide, KUNKKA_TIDEBRINGER_TSUNAMI) == KUNKKA_TIDEBRINGER_TSUNAMI and attacker:HasAbility("imba_kunkka_torrent") and attacker:FindAbilityByName("imba_kunkka_torrent"):GetLevel() > 0 then
		local ability = attacker:FindAbilityByName("imba_kunkka_torrent")
		local pos = keys.target:GetAbsOrigin() + (keys.target:GetAbsOrigin() - attacker:GetAbsOrigin()):Normalized() * (ability:GetSpecialValueFor("radius") * 0.75)
		CreateModifierThinker(attacker, ability, "modifier_imba_torrent_delay", {duration = 0.03, tide = 0}, pos, attacker:GetTeamNumber(), false)
	end
	for i=1,3 do
		if math.random(1,100) <= self:GetAbility():GetSpecialValueFor("proc_chance") then
			attacker:AddNewModifier(attacker, self:GetAbility(), TIDE_TYPE[i][1], {})
		end
	end
end

modifier_imba_tidebringer_high_tide = class({})
modifier_imba_tidebringer_wave_break = class({})
modifier_imba_tidebringer_tsunami = class({})
function modifier_imba_tidebringer_high_tide:IsDebuff() return false end
function modifier_imba_tidebringer_high_tide:RemoveOnDeath() return false end
function modifier_imba_tidebringer_high_tide:GetTexture() return "custom/kunkka_tidebringer_high_tide" end
function modifier_imba_tidebringer_high_tide:IsPurgable() return false end
function modifier_imba_tidebringer_wave_break:IsDebuff() return false end
function modifier_imba_tidebringer_wave_break:RemoveOnDeath() return false end
function modifier_imba_tidebringer_wave_break:GetTexture() return "custom/kunkka_tidebringer_wave_break" end
function modifier_imba_tidebringer_wave_break:IsPurgable() return false end
function modifier_imba_tidebringer_tsunami:IsDebuff() return false end
function modifier_imba_tidebringer_tsunami:RemoveOnDeath() return false end
function modifier_imba_tidebringer_tsunami:GetTexture() return "custom/kunkka_tidebringer_tsunami" end
function modifier_imba_tidebringer_tsunami:IsPurgable() return false end


imba_kunkka_x_marks_the_spot = class({})

LinkLuaModifier("modifier_imba_kunkka_x_marks_the_spot_target", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_kunkka_x_marks_the_spot_cooldown", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)

function imba_kunkka_x_marks_the_spot:IsHiddenWhenStolen() 		return false end
function imba_kunkka_x_marks_the_spot:IsRefreshable() 			return true end
function imba_kunkka_x_marks_the_spot:IsStealable() 			return true end
function imba_kunkka_x_marks_the_spot:IsNetherWardStealable() 	return true end
function imba_kunkka_x_marks_the_spot:GetAssociatedSecondaryAbilities() return "imba_kunkka_return" end
function imba_kunkka_x_marks_the_spot:OnUpgrade() local a = self:GetCaster():FindAbilityByName("imba_kunkka_return") and self:GetCaster():FindAbilityByName("imba_kunkka_return"):SetLevel(1) or 1 end

function imba_kunkka_x_marks_the_spot:GetCastRange(vLocation, hTarget) return self:GetSpecialValueFor("tooltip_range") end

function imba_kunkka_x_marks_the_spot:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local duration = target:GetTeamNumber() == caster:GetTeamNumber() and self:GetSpecialValueFor("allied_duration") or self:GetSpecialValueFor("duration")
	target:AddNewModifier(caster, self, "modifier_imba_kunkka_x_marks_the_spot_target", {duration = duration})
	if not caster:HasModifier("modifier_imba_kunkka_x_marks_the_spot_cooldown") then
		caster:AddNewModifier(caster, self, "modifier_imba_kunkka_x_marks_the_spot_cooldown", {duration = self:GetSpecialValueFor("grace_period")})
	end
	self:EndCooldown()
	AddFOWViewer(caster:GetTeamNumber(), target:GetAbsOrigin(), self:GetSpecialValueFor("fow_range"), self:GetSpecialValueFor("fow_duration"), true)
end

modifier_imba_kunkka_x_marks_the_spot_target = class({})

function modifier_imba_kunkka_x_marks_the_spot_target:IsDebuff()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return false
	else
		return true
	end
end
function modifier_imba_kunkka_x_marks_the_spot_target:IsHidden() 			return false end
function modifier_imba_kunkka_x_marks_the_spot_target:IsPurgable() 			return false end
function modifier_imba_kunkka_x_marks_the_spot_target:IsPurgeException() 	return false end
function modifier_imba_kunkka_x_marks_the_spot_target:GetEffectName() return "particles/units/heroes/hero_kunkka/kunkka_spell_x_spot.vpcf" end
function modifier_imba_kunkka_x_marks_the_spot_target:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end

function modifier_imba_kunkka_x_marks_the_spot_target:OnCreated()
	if IsServer() then
		self.pos = self:GetParent():GetAbsOrigin()
		self:GetParent():EmitSound("Ability.XMarksTheSpot.Target")
		self:GetParent():EmitSound("Ability.XMark.Target_Movement")
	end
end

function modifier_imba_kunkka_x_marks_the_spot_target:OnDestroy()
	if IsServer() then
		if self:GetParent():IsInvulnerable() or not self:GetParent():IsAlive() then
			return
		end
		if self:IsDebuff() and self:GetParent():IsMagicImmune() then
			return
		end
		self:GetParent():EmitSound("Ability.XMarksTheSpot.Return")
		self:GetParent():StopSound("Ability.XMark.Target_Movement")
		FindClearSpaceForUnit(self:GetParent(), self.pos, true)
		self.pos = nil
	end
end

modifier_imba_kunkka_x_marks_the_spot_cooldown = class({})

function modifier_imba_kunkka_x_marks_the_spot_cooldown:IsDebuff()			return false end
function modifier_imba_kunkka_x_marks_the_spot_cooldown:IsHidden() 			return false end
function modifier_imba_kunkka_x_marks_the_spot_cooldown:IsPurgable() 		return false end
function modifier_imba_kunkka_x_marks_the_spot_cooldown:IsPurgeException()	return false end

function modifier_imba_kunkka_x_marks_the_spot_cooldown:OnDestroy()
	if IsServer() then
		self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(self:GetAbility():GetLevel()-1) - self:GetElapsedTime())
	end
end

imba_kunkka_return = class({})

function imba_kunkka_return:IsHiddenWhenStolen() 		return false end
function imba_kunkka_return:IsRefreshable() 			return true end
function imba_kunkka_return:IsStealable() 				return true end
function imba_kunkka_return:IsNetherWardStealable() 	return false end
function imba_kunkka_return:GetAssociatedPrimaryAbilities() return "imba_kunkka_x_marks_the_spot" end

function imba_kunkka_return:OnSpellStart()
	local units = FindUnitsInRadius(1, Vector(0,0,0), nil, 100000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_UNITS_EVERYWHERE, false)
	for _, unit in pairs(units) do
		local buff = unit:FindModifierByNameAndCaster("modifier_imba_kunkka_x_marks_the_spot_target", self:GetCaster())
		if buff then
			buff:Destroy()
		end
	end
end

imba_kunkka_ghostship = class({})

LinkLuaModifier("modifier_imba_ghostship_debuff", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ghostship_rum", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ghostship_rum_damage", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ghostship_mark", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ghostship_ship", "hero/hero_kunkka", LUA_MODIFIER_MOTION_NONE)

function imba_kunkka_ghostship:IsHiddenWhenStolen() 	return false end
function imba_kunkka_ghostship:IsRefreshable() 			return true end
function imba_kunkka_ghostship:IsStealable() 			return true end
function imba_kunkka_ghostship:IsNetherWardStealable() 	return true end
function imba_kunkka_ghostship:GetCastRange(vLocation, hTarget) return self:GetCaster():HasScepter() and self:GetSpecialValueFor("spawn_distance_scepter") or self:GetSpecialValueFor("spawn_distance") end

function imba_kunkka_ghostship:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local distance = caster:HasScepter() and self:GetSpecialValueFor("spawn_distance_scepter") or self:GetSpecialValueFor("spawn_distance")
	local spawn_pos = pos + (caster:GetAbsOrigin() - pos):Normalized() * distance
	local dircetion = (pos - spawn_pos):Normalized()
	local speed = caster:HasScepter() and self:GetSpecialValueFor("ghostship_speed_scepter") or self:GetSpecialValueFor("ghostship_speed")
	local mark = CreateModifierThinker(caster, self, "modifier_imba_ghostship_mark", {}, pos, caster:GetTeamNumber(), false):entindex()
	local ship = CreateModifierThinker(caster, self, "modifier_imba_ghostship_ship", {mark = mark, speed = speed}, spawn_pos, caster:GetTeamNumber(), false)
	ship:EmitSound("Ability.Ghostship")
	ship = ship:entindex()
	EmitSoundOnLocationWithCaster(pos, "Ability.Ghostship.bell", nil)
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
		vSpawnOrigin = spawn_pos,
		fDistance = distance,
		fStartRadius = 0,
		fEndRadius = 0,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = dircetion * speed,
		bProvidesVision = false,
		ExtraData = {mark = mark, ship = ship}
	}
	ProjectileManager:CreateLinearProjectile(info)
	if caster:HasTalent("special_bonus_imba_kunkka_1") then
		for i=-1,1 do
			if i ~= 0 then
				local angle = caster:HasScepter() and 10 or 20
				local new_pos = RotatePosition(spawn_pos, QAngle(0,angle * i,0), pos)
				local new_spawn_pos = new_pos + (spawn_pos - pos):Normalized() * (distance + 300)
				local new_mark = CreateModifierThinker(caster, self, "modifier_imba_ghostship_mark", {}, pos, caster:GetTeamNumber(), false):entindex()
				local new_ship = CreateModifierThinker(caster, self, "modifier_imba_ghostship_ship", {mark = mark, speed = speed}, spawn_pos, caster:GetTeamNumber(), false)
				new_ship:EmitSound("Ability.Ghostship")
				new_ship = new_ship:entindex()
				EmitSoundOnLocationWithCaster(pos, "Ability.Ghostship.bell", nil)
				local info = 
				{
					Ability = self,
					EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
					vSpawnOrigin = new_spawn_pos,
					fDistance = distance,
					fStartRadius = 0,
					fEndRadius = 0,
					Source = caster,
					bHasFrontalCone = false,
					bReplaceExisting = false,
					iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
					iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
					iUnitTargetType = DOTA_UNIT_TARGET_HERO,
					fExpireTime = GameRules:GetGameTime() + 10.0,
					bDeleteOnHit = true,
					vVelocity = dircetion * speed,
					bProvidesVision = false,
					ExtraData = {mark = new_mark, ship = new_ship}
				}
				ProjectileManager:CreateLinearProjectile(info)
			end
		end
	end
end

function imba_kunkka_ghostship:OnProjectileThink_ExtraData(location, data)
	local target_pos = EntIndexToHScript(data.mark):GetAbsOrigin()
	EntIndexToHScript(data.ship):SetAbsOrigin(location)
	AddFOWViewer(self:GetCaster():GetTeamNumber(), location, 300, FrameTime(), false)
end

function imba_kunkka_ghostship:OnProjectileHit_ExtraData(target, location, data)
	if target then
		return false
	end
	EntIndexToHScript(data.mark):ForceKill(false)
	EntIndexToHScript(data.ship):StopSound("Ability.Ghostship")
	EntIndexToHScript(data.ship):EmitSound("Ability.Ghostship.crash")
	EntIndexToHScript(data.ship):ForceKill(false)
end


modifier_imba_ghostship_debuff = class({})

function modifier_imba_ghostship_debuff:IsMotionController()		return true end
function modifier_imba_ghostship_debuff:IsDebuff()					return true end
function modifier_imba_ghostship_debuff:IsHidden() 					return false end
function modifier_imba_ghostship_debuff:IsPurgable() 				return true end
function modifier_imba_ghostship_debuff:IsPurgeException() 			return true end
function modifier_imba_ghostship_debuff:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end

function modifier_imba_ghostship_debuff:OnCreated(keys)
	if IsServer() then
		self:CheckMotionControllers()
		self.mark = EntIndexToHScript(keys.mark)
		self.speed = keys.speed
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_ghostship_debuff:OnIntervalThink()
	if not self.mark or self.mark:IsNull() then
		self:Destroy()
		return
	end
	local target_pos = self.mark:GetAbsOrigin()
	local distance = self.speed * FrameTime()
	local next_pos= self:GetParent():GetAbsOrigin() + (target_pos - self:GetParent():GetAbsOrigin()):Normalized() * distance
	self:GetParent():SetAbsOrigin(next_pos)
end

function modifier_imba_ghostship_debuff:OnDestroy()
	if IsServer() then
		self.mark = nil
		self.speed = nil
		FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	end
end

modifier_imba_ghostship_mark = class({})
function modifier_imba_ghostship_mark:CheckState() return {[MODIFIER_STATE_INVISIBLE] = true} end
function modifier_imba_ghostship_mark:OnCreated()
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 1, Vector(self:GetAbility():GetSpecialValueFor("ghostship_width"), self:GetAbility():GetSpecialValueFor("ghostship_width"), self:GetAbility():GetSpecialValueFor("ghostship_width")))
		self:AddParticle(pfx, false, false, 15, false, false)
	end
end

function modifier_imba_ghostship_mark:OnDestroy()
	if IsServer() then
		local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("ghostship_width"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_stunned", {duration = self:GetAbility():GetSpecialValueFor("stun_duration")})
			local damageTable = {
								victim = enemy,
								attacker = self:GetCaster(),
								damage = self:GetAbility():GetSpecialValueFor("tooltip_damage"),
								damage_type = self:GetAbility():GetAbilityDamageType(),
								damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
								ability = self:GetAbility(), --Optional.
								}
			ApplyDamage(damageTable)
		end
	end
end

modifier_imba_ghostship_ship = class({})

function modifier_imba_ghostship_ship:OnCreated(keys)
	if IsServer() then
		self.mark = EntIndexToHScript(keys.mark)
		self.speed = keys.speed
		self:OnIntervalThink()
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_ghostship_ship:OnIntervalThink()
	if self.mark:IsNull() then
		return
	end
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("ghostship_width"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_ghostship_debuff", {mark = self.mark:entindex(), speed = self.speed})
	end
	local allies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("ghostship_width"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, ally in pairs(allies) do
		ally:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_ghostship_rum", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
	end

end

function modifier_imba_ghostship_ship:OnDestroy()
	if IsServer() then
		self.mark = nil
		self.speed = nil
	end
end

modifier_imba_ghostship_rum = class({})

function modifier_imba_ghostship_rum:IsDebuff()			return false end
function modifier_imba_ghostship_rum:IsHidden() 		return false end
function modifier_imba_ghostship_rum:IsPurgable() 		return false end
function modifier_imba_ghostship_rum:IsPurgeException() return false end
function modifier_imba_ghostship_rum:GetStatusEffectName() return "particles/status_fx/status_effect_rum.vpcf" end
function modifier_imba_ghostship_rum:StatusEffectPriority() return 15 end

function modifier_imba_ghostship_rum:DeclareFunctions() return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE} end

function modifier_imba_ghostship_rum:GetModifierIncomingDamage_Percentage(keys)
	if IsServer() then
		local pct = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("rum_reduce_pct_scepter") or self:GetAbility():GetSpecialValueFor("rum_reduce_pct")
		self:SetStackCount(keys.damage * (pct / 100) + self:GetStackCount())
		return pct
	end
end

function modifier_imba_ghostship_rum:OnDestroy()
	if IsServer() then
		if not self:GetCaster():HasTalent("special_bonus_imba_kunkka_2") and self:GetParent():IsAlive() then
			local buff = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_ghostship_rum_damage", {duration = self:GetAbility():GetSpecialValueFor("buff_duration")})
			buff:SetStackCount(self:GetStackCount())
		end
	end
end

modifier_imba_ghostship_rum_damage = class({})

function modifier_imba_ghostship_rum_damage:IsDebuff()			return true end
function modifier_imba_ghostship_rum_damage:IsHidden() 			return false end
function modifier_imba_ghostship_rum_damage:IsPurgable() 		return false end
function modifier_imba_ghostship_rum_damage:IsPurgeException() 	return false end

function modifier_imba_ghostship_rum_damage:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_imba_ghostship_rum_damage:OnIntervalThink()
	local dmg = self:GetStackCount() / self:GetDuration()
	local damageTable = {
						victim = self:GetParent(),
						attacker = self:GetParent(),
						damage = dmg,
						damage_type = DAMAGE_TYPE_PURE,
						damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NON_LETHAL, --Optional.
						ability = self:GetAbility(), --Optional.
						}
	ApplyDamage(damageTable)
end