--hero_grimstroke.lua

CreateEmptyTalents("grimstroke")


imba_grimstroke_dark_artistry = class({})

LinkLuaModifier("modifier_imba_dark_artistry_debuff", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)

function imba_grimstroke_dark_artistry:IsHiddenWhenStolen() 	return false end
function imba_grimstroke_dark_artistry:IsRefreshable() 			return true end
function imba_grimstroke_dark_artistry:IsStealable() 			return true end
function imba_grimstroke_dark_artistry:IsNetherWardStealable() 	return true end
function imba_grimstroke_dark_artistry:GetCastRange(vLocation, hTarget) return self.BaseClass.GetCastRange(self, vLocation, hTarget) + self:GetCaster():GetTalentValue("special_bonus_imba_grimstroke_1") end

function imba_grimstroke_dark_artistry:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Grimstroke.DarkArtistry.PreCastPoint")
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(self.pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	return true
end

function imba_grimstroke_dark_artistry:OnAbilityPhaseInterrupted()
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
		self.pfx = nil
	end
	self:GetCaster():StopSound("Hero_Grimstroke.DarkArtistry.PreCastPoint")
end

function imba_grimstroke_dark_artistry:OnSpellStart(bNoSoulbind)
	self.hit_info = self.hit_info or {}
	self.soulbind_info = self.soulbind_info or {}
	local caster = self:GetCaster()
	caster:EmitSound("Hero_Grimstroke.DarkArtistry.Cast")
	self.hit_pfx_name = "particles/units/heroes/hero_grimstroke/grimstroke_darkartistry_dmg.vpcf"
	if HeroItems:UnitHasItem(caster, "grimstroke_ti9_immortal_weapon") then
		self.hit_pfx_name = "particles/econ/items/grimstroke/ti9_immortal/gs_ti9_artistry_dmg.vpcf"
	end
	local pos = self:GetCursorPosition()
	local start_pos = GetGroundPosition((caster:GetAbsOrigin() + caster:GetRightVector() * -150), nil)
	local direction = GetDirection2D(pos, start_pos)
	local sound = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = 10.0}, start_pos, caster:GetTeamNumber(), false)
	sound:EmitSound("Hero_Grimstroke.DarkArtistry.Projectile")
	local info = 
	{
		Ability = self,
		EffectName = "particles/units/heroes/hero_grimstroke/grimstroke_darkartistry_proj.vpcf",
		vSpawnOrigin = start_pos,
		fDistance = self:GetCastRange(pos, caster) + caster:GetCastRangeBonus(),
		fStartRadius = self:GetSpecialValueFor("start_radius"),
		fEndRadius = self:GetSpecialValueFor("end_radius"),
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = false,
		vVelocity = direction * (self:GetSpecialValueFor("projectile_speed") + caster:GetTalentValue("special_bonus_imba_grimstroke_1")),
		bProvidesVision = false,
		ExtraData = {sound = sound:entindex()}
	}
	local i = ProjectileManager:CreateLinearProjectile(info)
	self.hit_info[i] = 0
	self.soulbind_info[i] = bNoSoulbind
end

function imba_grimstroke_dark_artistry:OnProjectileThink_ExtraData(pos, keys)
	if keys.sound and not EntIndexToHScript(keys.sound):IsNull() then
		EntIndexToHScript(keys.sound):SetAbsOrigin(pos)
	end
	AddFOWViewer(self:GetCaster():GetTeamNumber(), pos, self:GetSpecialValueFor("end_radius"), self:GetSpecialValueFor("vision_duration"), false)
end

function imba_grimstroke_dark_artistry:OnProjectileHitHandle(target, pos, i)
	if target then
		local dmg = self:GetSpecialValueFor("damage") + self.hit_info[i] * self:GetSpecialValueFor("bonus_damage_per_target")
		local duration = self:GetSpecialValueFor("slow_duration") + self.hit_info[i] * self:GetSpecialValueFor("bonus_duration_per_target")
		self.hit_info[i] = self.hit_info[i] + 1
		ApplyDamage({victim = target, attacker = self:GetCaster(), ability = self, damage = dmg, damage_type = self:GetAbilityDamageType()})
		target:AddNewModifier(self:GetCaster(), self, "modifier_imba_dark_artistry_debuff", {duration = duration})
		if self:GetCaster():HasTalent("special_bonus_imba_grimstroke_2") then
			target:AddNewModifier(self:GetCaster(), self, "modifier_imba_stunned", {duration = self:GetCaster():GetTalentValue("special_bonus_imba_grimstroke_2")})
		end
		if target:IsHero() then
			target:EmitSound("Hero_Grimstroke.DarkArtistry.Damage")
		else
			target:EmitSound("Hero_Grimstroke.DarkArtistry.Damage.Creep")
		end
		local pfx = ParticleManager:CreateParticle(self.hit_pfx_name, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(pfx)
		local buff = target:FindModifierByName("modifier_imba_soul_chain")
		if buff and not self.soulbind_info[i] and buff.latch then
			buff:GetAbsorbSpell({ability = self})
			local pfx_aoe = ParticleManager:CreateParticle("particles/hero/grimstroke/grimstroke_dark_artistry_trigger.vpcf", PATTACH_CUSTOMORIGIN, nil)
			ParticleManager:SetParticleControl(pfx_aoe, 0, target:GetAbsOrigin())
			ParticleManager:SetParticleControl(pfx_aoe, 2, Vector(200, 200, 200))
			ParticleManager:ReleaseParticleIndex(pfx_aoe)
		end
		return false
	else
		self.hit_info[i] = nil
		return true
	end
end

modifier_imba_dark_artistry_debuff = class({})

function modifier_imba_dark_artistry_debuff:IsDebuff()			return true end
function modifier_imba_dark_artistry_debuff:IsHidden() 			return false end
function modifier_imba_dark_artistry_debuff:IsPurgable() 		return true end
function modifier_imba_dark_artistry_debuff:IsPurgeException() 	return true end
function modifier_imba_dark_artistry_debuff:DeclareFunctions()  return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_dark_artistry_debuff:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("movement_slow_pct")) end
function modifier_imba_dark_artistry_debuff:GetEffectName() return "particles/units/heroes/hero_grimstroke/grimstroke_dark_artistry_debuff.vpcf" end
function modifier_imba_dark_artistry_debuff:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_imba_dark_artistry_debuff:GetStatusEffectName() return "particles/status_fx/status_effect_grimstroke_dark_artistry.vpcf" end
function modifier_imba_dark_artistry_debuff:StatusEffectPriority() return 15 end




imba_grimstroke_ink_creature = class({})

LinkLuaModifier("modifier_imba_ink_creature_movecontroller", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_ink_creature_debuff", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)

function imba_grimstroke_ink_creature:IsHiddenWhenStolen() 		return false end
function imba_grimstroke_ink_creature:IsRefreshable() 			return true end
function imba_grimstroke_ink_creature:IsStealable() 			return true end
function imba_grimstroke_ink_creature:IsNetherWardStealable() 	return false end

function imba_grimstroke_ink_creature:OnAbilityPhaseStart()
	self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_cast_phantom.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	return true 
end

function imba_grimstroke_ink_creature:OnAbilityPhaseInterrupted()
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, true)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end

function imba_grimstroke_ink_creature:OnSpellStart()
	if self.pfx then
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	caster:EmitSound("Hero_Grimstroke.InkCreature.Cast")
	local npc = CreateUnitByName("npc_dota_grimstroke_ink_creature", caster:GetAbsOrigin() + caster:GetForwardVector() * 130, false, caster, caster, caster:GetTeamNumber())
	npc:AddNewModifier(caster, self, "modifier_imba_ink_creature_movecontroller", {target = target:entindex()})
	npc:EmitSound("Hero_Grimstroke.InkCreature.Spawn")
	SetCreatureHealth(npc, self:GetSpecialValueFor("destroy_attacks") * 2, true)
end

function imba_grimstroke_ink_creature:CreatureFinish(hSource)
	local info = 
	{
		Target = self:GetCaster(),
		Source = hSource,
		Ability = self,	
		EffectName = "particles/units/heroes/hero_grimstroke/grimstroke_phantom_return.vpcf",
		iMoveSpeed = self:GetSpecialValueFor("return_projectile_speed"),
		vSourceLoc = hSource:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		flExpireTime = GameRules:GetGameTime() + 60,
		bProvidesVision = false,	
	}
	ProjectileManager:CreateTrackingProjectile(info)
end

function imba_grimstroke_ink_creature:OnProjectileHit(hTarget, vLocation) self:EndCooldown() end

modifier_imba_ink_creature_movecontroller = class({})

function modifier_imba_ink_creature_movecontroller:IsDebuff()			return false end
function modifier_imba_ink_creature_movecontroller:IsHidden() 			return true end
function modifier_imba_ink_creature_movecontroller:IsPurgable() 		return false end
function modifier_imba_ink_creature_movecontroller:IsPurgeException() 	return false end
function modifier_imba_ink_creature_movecontroller:CheckState() return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true, [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true} end
function modifier_imba_ink_creature_movecontroller:DeclareFunctions() return {MODIFIER_EVENT_ON_ATTACK_LANDED, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE, MODIFIER_PROPERTY_DISABLE_HEALING, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX} end
function modifier_imba_ink_creature_movecontroller:GetAbsoluteNoDamageMagical() return 1 end
function modifier_imba_ink_creature_movecontroller:GetAbsoluteNoDamagePhysical() return 1 end
function modifier_imba_ink_creature_movecontroller:GetAbsoluteNoDamagePure() return 1 end
function modifier_imba_ink_creature_movecontroller:GetModifierMoveSpeed_AbsoluteMin() return self:GetAbility():GetSpecialValueFor("speed") end
function modifier_imba_ink_creature_movecontroller:GetModifierMoveSpeed_AbsoluteMax() return self:GetAbility():GetSpecialValueFor("speed") end

function modifier_imba_ink_creature_movecontroller:OnAttackLanded(keys)
	if not IsServer() or keys.target ~= self:GetParent() or keys.attacker == self.target then
		return
	end
	local dmg = (keys.attacker:IsHero() or keys.attacker:IsTower()) and 2 or 1
	if dmg > self.parent:GetHealth() then
		self.parent:Kill(self:GetAbility(), keys.attacker)
		self.parent:EmitSound("Hero_Grimstroke.InkCreature.Death")
		return
	end
	self.parent:EmitSound("Hero_Grimstroke.InkCreature.Damage")
	self.parent:SetHealth(self.parent:GetHealth() - dmg)
end

function modifier_imba_ink_creature_movecontroller:OnCreated(keys)
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_phantom_ambient.vpcf", PATTACH_CUSTOMORIGIN, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 6, Vector(1,0,0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self.parent = self:GetParent()
		self.target = EntIndexToHScript(keys.target)
		self.distance = self:GetAbility():GetSpecialValueFor("latched_unit_offset")
		self.phase = "go"
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end
end

function modifier_imba_ink_creature_movecontroller:OnIntervalThink()
	AddFOWViewer(self.parent:GetTeamNumber(), self.target:GetAbsOrigin(), 200, 0.2, false)
	if self.target:IsInvisible() or self.target:IsMagicImmune() or not self.target:IsAlive() then
		if not self.target:IsAlive() then
			self:GetAbility():CreatureFinish(self.parent)
		end
		self.parent:ForceKill(false)
		self:Destroy()
		return
	end
	if self.phase == "go" then
		self.parent:MoveToNPC(self.target)
		if (self.parent:GetAbsOrigin() - self.target:GetAbsOrigin()):Length2D() <= 100 then
			self.parent:Stop()
			self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAPTURE, 2)
			self.phase = "attack"
			self.target:EmitSound("Hero_Grimstroke.InkCreature.Attach")
			self.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_imba_ink_creature_debuff", {npc = self.parent:entindex()})
		end
	elseif self.phase == "attack" then
		self.parent:Stop()
		self.parent:SetAbsOrigin(self.target:GetAbsOrigin() + self.target:GetForwardVector() * self.distance)
		if math.abs(VectorToAngles(self.target:GetForwardVector() * -1)[2] - VectorToAngles(self.parent:GetForwardVector())[2]) > 20 then
			self.parent:SetForwardVector(self.target:GetForwardVector() * -1)
		end
	end
end

function modifier_imba_ink_creature_movecontroller:OnDestroy()
	if IsServer() then
		self.parent = nil
		self.target = nil
		self.distance = nil
		self.phase = nil
	end
end

modifier_imba_ink_creature_debuff = class({})

function modifier_imba_ink_creature_debuff:IsDebuff()			return true end
function modifier_imba_ink_creature_debuff:IsHidden() 			return false end
function modifier_imba_ink_creature_debuff:IsPurgable() 		return true end
function modifier_imba_ink_creature_debuff:IsPurgeException() 	return true end
function modifier_imba_ink_creature_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_ink_creature_debuff:CheckState() return {[MODIFIER_STATE_SILENCED] = true} end

function modifier_imba_ink_creature_debuff:OnCreated(keys)
	if IsServer() then
		self.npc = EntIndexToHScript(keys.npc)
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_ink_creature_debuff:OnIntervalThink()
	if not self.npc or self.npc:IsNull() then
		self:Destroy()
		return
	end
	ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("damage_per_sec") / (1.0 / 0.5), damage_type = self:GetAbility():GetAbilityDamageType()})
	self:GetParent():EmitSound("Hero_Grimstroke.InkCreature.Attack")
	if self:GetElapsedTime() >= self:GetAbility():GetSpecialValueFor("latch_duration") or (self.npc and not self.npc:IsNull() and not self.npc:IsAlive()) then
		self:Destroy()
	end
end

function modifier_imba_ink_creature_debuff:OnDestroy()
	if IsServer() then
		if self:GetElapsedTime() >= self:GetAbility():GetSpecialValueFor("latch_duration") or not self:GetParent():IsAlive() then
			self:GetParent():EmitSound("Hero_Grimstroke.InkCreature.Returned")
			self:GetAbility():CreatureFinish(self.npc)
			local enemy = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetAbility():GetSpecialValueFor("bounce_range"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER, false)
			local found = false
			for i=1, #enemy do
				if enemy[i] ~= self:GetParent() then
					local buff = self.npc:FindModifierByName("modifier_imba_ink_creature_movecontroller")
					if buff then
						buff.phase = "go"
						buff.target = enemy[i]
						found = true
						break
					end
				end
			end
			if not found then
				self.npc:RemoveModifierByName("modifier_imba_ink_creature_movecontroller")
				UTIL_Remove(self.npc)
			end
			ApplyDamage({victim = self:GetParent(), attacker = self:GetCaster(), ability = self:GetAbility(), damage = self:GetAbility():GetSpecialValueFor("pop_damage"), damage_type = self:GetAbility():GetAbilityDamageType()})
		else
			self.npc:RemoveModifierByName("modifier_imba_ink_creature_movecontroller")
			self.npc:EmitSound("Hero_Grimstroke.InkCreature.Death")
			self.npc:ForceKill(false)
		end
		self.npc = nil
	end
end

imba_grimstroke_spirit_walk = class({})

LinkLuaModifier("modifier_imba_spirit_walk_buff", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)

function imba_grimstroke_spirit_walk:IsHiddenWhenStolen() 		return false end
function imba_grimstroke_spirit_walk:IsRefreshable() 			return true end
function imba_grimstroke_spirit_walk:IsStealable() 				return true end
function imba_grimstroke_spirit_walk:IsNetherWardStealable() 	return true end
function imba_grimstroke_spirit_walk:GetAOERadius() return self:GetSpecialValueFor("radius") + self:GetCaster():GetTalentValue("special_bonus_imba_grimstroke_3") end
function imba_grimstroke_spirit_walk:GetCastRange() return self:GetSpecialValueFor("cast_range") end

function imba_grimstroke_spirit_walk:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if caster ~= target then
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_cast_ink_swell.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end
	if IsEnemy(caster, target) and target:TriggerStandardTargetSpell(self) then
		return
	end
	target:AddNewModifier(caster, self, "modifier_imba_spirit_walk_buff", {duration = self:GetSpecialValueFor("buff_duration")})
	target:EmitSound("Hero_Grimstroke.InkSwell.Cast")
	caster:EmitSound("Hero_Grimstroke.InkSwell.Targe")
end

modifier_imba_spirit_walk_buff = class({})

function modifier_imba_spirit_walk_buff:IsDebuff()			return IsEnemy(self:GetCaster(), self:GetParent()) end
function modifier_imba_spirit_walk_buff:IsHidden() 			return false end
function modifier_imba_spirit_walk_buff:IsPurgable() 		return true end
function modifier_imba_spirit_walk_buff:IsPurgeException() 	return true end
function modifier_imba_spirit_walk_buff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
function modifier_imba_spirit_walk_buff:DeclareFunctions() return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_spirit_walk_buff:GetModifierMoveSpeedBonus_Percentage() return self:GetAbility():GetSpecialValueFor("movespeed_bonus_pct") end
function modifier_imba_spirit_walk_buff:GetStatusEffectName() return "particles/status_fx/status_effect_grimstroke_ink_swell.vpcf" end
function modifier_imba_spirit_walk_buff:StatusEffectPriority() return 15 end

function modifier_imba_spirit_walk_buff:OnCreated()
	if IsServer() then
		self.damage_duration = 0
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_buff.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 2, Vector(self:GetAbility():GetAOERadius(), 0, 0))
		ParticleManager:SetParticleControlEnt(pfx, 3, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(pfx, 6, Vector(self:GetAbility():GetAOERadius(), 0, 0))
		self:AddParticle(pfx, false, false, 15, false, false)
		self:StartIntervalThink(self:GetAbility():GetSpecialValueFor("tick_rate"))
	end
end

function modifier_imba_spirit_walk_buff:OnIntervalThink()
	local caster = self:GetCaster()
	local parent = self:GetParent()
	local ability = self:GetAbility()
	local radius = ability:GetAOERadius()
	local unit = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	local hero = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	self.damage_duration = #hero > 0 and self.damage_duration + ability:GetSpecialValueFor("tick_rate") or self.damage_duration
	for i=1, #unit do
		hero[#hero + 1] = unit[i]
	end
	for i=1, #hero do
		ApplyDamage({victim = hero[i], attacker = caster, damage = ability:GetSpecialValueFor("damage_per_sec") / (1.0 / ability:GetSpecialValueFor("tick_rate")), ability = ability, damage_type = ability:GetAbilityDamageType()})
	end
	if #hero > 0 then
		parent:EmitSound("Hero_Grimstroke.InkSwell.Damage")
	end
end

function modifier_imba_spirit_walk_buff:OnDestroy()
	if IsServer() then
		local caster = self:GetCaster()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		parent:EmitSound("Hero_Grimstroke.InkSwell.Stun")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", PATTACH_CUSTOMORIGIN, nil)
		local radius = ability:GetAOERadius()
		ParticleManager:SetParticleControl(pfx, 0, parent:GetAbsOrigin())
		ParticleManager:SetParticleControl(pfx, 2, Vector(radius, radius, radius))
		ParticleManager:SetParticleControl(pfx, 4, parent:GetAbsOrigin())
		local enemy = FindUnitsInRadius(caster:GetTeamNumber(), parent:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		local stun_duration = (self.damage_duration / self:GetElapsedTime()) * ability:GetSpecialValueFor("max_stun")
		local dmg = (self.damage_duration / self:GetElapsedTime()) * ability:GetSpecialValueFor("max_damage")
		for i=1, #enemy do
			if enemy[i]:HasModifier("modifier_imba_dark_artistry_debuff") or enemy[i] ~= parent then
				ApplyDamage({victim = enemy[i], attacker = caster, damage = dmg, ability = ability, damage_type = ability:GetAbilityDamageType()})
				enemy[i]:AddNewModifier(caster, ability, "modifier_imba_stunned", {duration = stun_duration})
				enemy[i]:EmitSound("Hero_Grimstroke.InkSwell.Stun")
			end
		end
	end
end



imba_grimstroke_soul_chain = class({})

LinkLuaModifier("modifier_imba_soul_chain_scepter", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_soul_chain", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_soul_chain_cast", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_soul_chain_slow", "hero/hero_grimstroke.lua", LUA_MODIFIER_MOTION_NONE)

function imba_grimstroke_soul_chain:IsHiddenWhenStolen() 	return false end
function imba_grimstroke_soul_chain:IsRefreshable() 		return true end
function imba_grimstroke_soul_chain:IsStealable() 			return true end
function imba_grimstroke_soul_chain:IsNetherWardStealable() return true end
function imba_grimstroke_soul_chain:GetAOERadius() return self:GetSpecialValueFor("chain_latch_radius") end
function imba_grimstroke_soul_chain:GetCastRange() return self:GetSpecialValueFor("cast_range") end
function imba_grimstroke_soul_chain:GetIntrinsicModifierName() return "modifier_imba_soul_chain_scepter" end

function imba_grimstroke_soul_chain:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if target:TriggerStandardTargetSpell(self) then
		return
	end
	local cast_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_cast_soulchain.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControlEnt(cast_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(cast_pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(cast_pfx)
	caster:EmitSound("Hero_Grimstroke.SoulChain.Cast")
	target:EmitSound("Hero_Grimstroke.SoulChain.Target")
	if not target:HasModifier("modifier_imba_soul_chain") then
		target:AddNewModifier(caster, self, "modifier_imba_soul_chain", {duration = self:GetSpecialValueFor("chain_duration") + caster:GetTalentValue("special_bonus_imba_grimstroke_4"), is_primary = 1})
	else
		local buff = target:FindModifierByName("modifier_imba_soul_chain")
		buff:SetDuration(self:GetSpecialValueFor("chain_duration") + caster:GetTalentValue("special_bonus_imba_grimstroke_4"), true)
		if buff.latch then
			buff.latch:FindModifierByName("modifier_imba_soul_chain"):SetDuration(self:GetSpecialValueFor("chain_duration") + caster:GetTalentValue("special_bonus_imba_grimstroke_4"), true)
		end
	end
end

modifier_imba_soul_chain_scepter = class({})

function modifier_imba_soul_chain_scepter:IsDebuff()			return false end
function modifier_imba_soul_chain_scepter:IsHidden() 			return true end
function modifier_imba_soul_chain_scepter:IsPurgable() 			return false end
function modifier_imba_soul_chain_scepter:IsPurgeException() 	return false end

function modifier_imba_soul_chain_scepter:OnCreated()
	if IsServer() then
		self:StartIntervalThink(0.5)
	end
end

function modifier_imba_soul_chain_scepter:OnIntervalThink()
	if self:GetParent():HasScepter() and self:GetParent():FindAbilityByName("grimstroke_scepter") then
		self:GetParent():FindAbilityByName("grimstroke_scepter"):SetLevel(1)
		self:GetParent():FindAbilityByName("grimstroke_scepter"):SetHidden(false)
	elseif self:GetParent():FindAbilityByName("grimstroke_scepter") then
		self:GetParent():FindAbilityByName("grimstroke_scepter"):SetHidden(true)
	end
end

modifier_imba_soul_chain = class({})

function modifier_imba_soul_chain:IsDebuff()			return true end
function modifier_imba_soul_chain:IsHidden() 			return false end
function modifier_imba_soul_chain:IsPurgable() 			return false end
function modifier_imba_soul_chain:IsPurgeException() 	return false end
function modifier_imba_soul_chain:GetEffectName() return "particles/units/heroes/hero_grimstroke/grimstroke_soulchain_marker.vpcf" end
function modifier_imba_soul_chain:GetEffectAttachType() return PATTACH_OVERHEAD_FOLLOW end
function modifier_imba_soul_chain:ShouldUseOverheadOffset() return true end
function modifier_imba_soul_chain:CheckState() return {[MODIFIER_STATE_TETHERED] = true, [MODIFIER_STATE_PROVIDES_VISION] = true} end

function modifier_imba_soul_chain:OnCreated(keys)
	if IsServer() then
		self.proc_ability = self.proc_ability or {}
		self.caster = self:GetCaster()
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.latch_radius = self.ability:GetSpecialValueFor("chain_latch_radius")
		self.break_radiius = self.ability:GetSpecialValueFor("chain_break_distance")
		self.latch = nil
		if keys.is_primary == 1 then
			self.primary = true
			self:StartIntervalThink(FrameTime())
			self:OnIntervalThink()
			if self.main_pfx then
				ParticleManager:DestroyParticle(self.main_pfx, true)
				ParticleManager:ReleaseParticleIndex(self.main_pfx)
				self.main_pfx = nil
			end
			if self.sec_pfx then
				ParticleManager:DestroyParticle(self.sec_pfx, true)
				ParticleManager:ReleaseParticleIndex(self.sec_pfx)
				self.sec_pfx = nil
			end
			if not self.main_pfx then
				self.main_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_soulchain_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(self.main_pfx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.main_pfx, 2, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
			end
		elseif keys.is_primary == 0 then
			self.primary = false
			self.latch = EntIndexToHScript(keys.source)
			self:StartIntervalThink(FrameTime())
			self:OnIntervalThink()
			if self.main_pfx then
				ParticleManager:DestroyParticle(self.main_pfx, true)
				ParticleManager:ReleaseParticleIndex(self.main_pfx)
				self.main_pfx = nil
			end
			if self.sec_pfx then
				ParticleManager:DestroyParticle(self.sec_pfx, true)
				ParticleManager:ReleaseParticleIndex(self.sec_pfx)
				self.sec_pfx = nil
			end
			if not self.sec_pfx then
				self.sec_pfx = ParticleManager:CreateParticle("particles/hero/grimstroke/grimstroke_soulchain_debuff_second.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
				ParticleManager:SetParticleControlEnt(self.sec_pfx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(self.sec_pfx, 2, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, self.parent:GetAbsOrigin(), true)
			end
		end
	end
end

function modifier_imba_soul_chain:OnRefresh(keys) self:OnCreated(keys) end

function modifier_imba_soul_chain:OnIntervalThink()
	if self.primary then
		if not self.latch then
			local unit = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.latch_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			if #unit > 1 then
				for i=2, #unit do
					if not unit[i]:HasModifier("modifier_imba_soul_chain") or (unit[i]:FindModifierByName("modifier_imba_soul_chain") and unit[i]:FindModifierByName("modifier_imba_soul_chain").primary and not unit[i]:FindModifierByName("modifier_imba_soul_chain").latch) then
						self.latch = unit[i]
						self.latch:EmitSound("Hero_Grimstroke.SoulChain.Partner")
						self.parent:EmitSound("Hero_Grimstroke.SoulChain.Leash")
						if not self.latch:HasModifier("modifier_imba_soul_chain") then
							self.latch:EmitSound("Hero_Grimstroke.SoulChain.Leash")
						end
						if self.latch_pfx then
							ParticleManager:DestroyParticle(self.latch_pfx, false)
							ParticleManager:ReleaseParticleIndex(self.latch_pfx)
							self.latch_pfx = nil
						end
						self.latch:AddNewModifier(self.caster, self.ability, "modifier_imba_soul_chain", {duration = self:GetRemainingTime() - FrameTime(), is_primary = 0, source = self.parent:entindex()})
						self.latch_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_soulchain.vpcf", PATTACH_CUSTOMORIGIN, nil)
						ParticleManager:SetParticleControlEnt(self.latch_pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
						ParticleManager:SetParticleControlEnt(self.latch_pfx, 1, self.latch, PATTACH_POINT_FOLLOW, "attach_hitloc", self.latch:GetAbsOrigin(), true)
						break
					end
				end
			end
		else
			local distance = (self.parent:GetAbsOrigin() - self.latch:GetAbsOrigin()):Length2D()
			if distance > self.break_radiius or not self.latch:IsAlive() then
				local buff = self.latch:FindModifierByName("modifier_imba_soul_chain")
				if buff then
					self.latch:AddNewModifier(self.caster, self.ability, "modifier_imba_soul_chain", {duration = self:GetRemainingTime() - FrameTime(), is_primary = 1})
				end
				self:SetDuration(self:GetRemainingTime(), true)
				self.parent:StopSound("Hero_Grimstroke.SoulChain.Leash")
				self.latch:StopSound("Hero_Grimstroke.SoulChain.Leash")
				local latch = self.latch
				self.latch = nil
				local phantom = self.caster:FindAbilityByName("imba_grimstroke_ink_creature")
				if phantom and phantom:GetLevel() > 0 then
					self.caster:SetCursorCastTarget(self.parent)
					phantom:OnSpellStart()
					self.caster:SetCursorCastTarget(latch)
					phantom:OnSpellStart()
				end
				if self.latch_pfx then
					ParticleManager:DestroyParticle(self.latch_pfx, false)
					ParticleManager:ReleaseParticleIndex(self.latch_pfx)
					self.latch_pfx = nil
				end
			end
		end
	else
		if self.latch_pfx then
			ParticleManager:DestroyParticle(self.latch_pfx, false)
			ParticleManager:ReleaseParticleIndex(self.latch_pfx)
			self.latch_pfx = nil
		end
		if self.latch and not self.latch:IsAlive() then
			--local distance = (self.parent:GetAbsOrigin() - self.latch:GetAbsOrigin()):Length2D()
			--if distance > self.break_radiius or not self.latch:IsAlive() or not self.latch:HasModifier("modifier_imba_soul_chain") then
				--local buff = self.latch:FindModifierByName("modifier_imba_soul_chain")
				--if buff then
				--	buff:SetDuration(self:GetRemainingTime() - FrameTime(), true)
				--end
				self.parent:StopSound("Hero_Grimstroke.SoulChain.Leash")
				self.latch:StopSound("Hero_Grimstroke.SoulChain.Leash")
				self.latch = nil
				local phantom = self.caster:FindAbilityByName("imba_grimstroke_ink_creature")
				if phantom and phantom:GetLevel() > 0 then
					self.caster:SetCursorCastTarget(self.parent)
				end
				self.parent:AddNewModifier(self.caster, self.ability, "modifier_imba_soul_chain", {duration = self:GetRemainingTime() - FrameTime(), is_primary = 1})
			--end
		end
	end
	if not self.latch then
		self.parent:AddNewModifier(self.caster, self.ability, "modifier_imba_soul_chain_slow", {duration = 0.1})
	end
end

function modifier_imba_soul_chain:DeclareFunctions() return {MODIFIER_PROPERTY_ABSORB_SPELL} end

local no_soul_chain_abilities = {}
no_soul_chain_abilities["morphling_replicate"] = true
no_soul_chain_abilities["imba_morphling_replicate"] = true
no_soul_chain_abilities["grimstroke_soul_chain"] = true
no_soul_chain_abilities["imba_grimstroke_soul_chain"] = true
no_soul_chain_abilities["terrorblade_sunder"] = true
no_soul_chain_abilities["imba_terrorblade_sunder"] = true
no_soul_chain_abilities["vengefulspirit_nether_swap"] = true
no_soul_chain_abilities["imba_vengeful_nether_swap"] = true

function modifier_imba_soul_chain:GetAbsorbSpell(keys)
	if not IsServer() then
		return 0
	end
	local ability_caster = keys.ability:GetCaster()
	local ability = keys.ability
	if no_soul_chain_abilities[ability:GetAbilityName()] or bit.band(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_CHANNELLED) == DOTA_ABILITY_BEHAVIOR_CHANNELLED then
		return 0
	end
	if not IsEnemy(ability_caster, self.parent) or not self.latch or (self.proc_ability[ability_caster:entindex()] and self.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] and self.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] > 0) then
		if self.proc_ability[ability_caster:entindex()] and self.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] and self.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] > 0 then
			self.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] = self.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] - 1
		end
		return 0
	end
	local buff = self.latch:FindModifierByName("modifier_imba_soul_chain")
	if buff then
		if ability:GetAbilityName() ~= "imba_grimstroke_dark_artistry" then
			if buff.proc_ability[ability_caster:entindex()] and buff.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] then
				buff.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] = buff.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] + 1
			else
				buff.proc_ability[ability_caster:entindex()] = {}
				buff.proc_ability[ability_caster:entindex()][ability:GetAbilityName()] = 1
			end
		end
		CreateModifierThinker(self.latch, ability, "modifier_imba_soul_chain_cast", {duration = 0}, ability_caster:GetAbsOrigin(), ability_caster:GetTeamNumber(), false)
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_grimstroke/grimstroke_soulchain_proc.vpcf", PATTACH_CUSTOMORIGIN, nil)
		ParticleManager:SetParticleControlEnt(pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(pfx, 1, self.latch, PATTACH_POINT_FOLLOW, "attach_hitloc", self.latch:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(pfx)
	end
	return 0
end

function modifier_imba_soul_chain:OnDestroy()
	if IsServer() then
		if self.latch_pfx then
			ParticleManager:DestroyParticle(self.latch_pfx, false)
			ParticleManager:ReleaseParticleIndex(self.latch_pfx)
			self.latch_pfx = nil
		end
		self.parent:StopSound("Hero_Grimstroke.SoulChain.Leash")
		self.parent:StopSound("Hero_Grimstroke.SoulChain.Target")
		self.parent:StopSound("Hero_Grimstroke.SoulChain.Partner")
		if self.latch then
			self.latch:StopSound("Hero_Grimstroke.SoulChain.Leash")
			self.latch:StopSound("Hero_Grimstroke.SoulChain.Target")
			self.latch:StopSound("Hero_Grimstroke.SoulChain.Partner")
		end
		if self.sec_pfx then
			ParticleManager:DestroyParticle(self.sec_pfx, false)
			ParticleManager:ReleaseParticleIndex(self.sec_pfx)
			self.sec_pfx = nil
		end
		if self.main_pfx then
			ParticleManager:DestroyParticle(self.main_pfx, false)
			ParticleManager:ReleaseParticleIndex(self.main_pfx)
			self.main_pfx = nil
		end

		self.proc_ability = nil
		self.caster = nil
		self.parent = nil
		self.ability = nil
		self.latch_radius = nil
		self.break_radiius = nil
		self.latch = nil
		self.primary = nil
		self.main_pfx = nil
		self.sec_pfx = nil
		self.latch_pfx = nil
	end
end

modifier_imba_soul_chain_cast = class({})

function modifier_imba_soul_chain_cast:OnDestroy()
	if IsServer() then
		self:GetAbility():GetCaster():SetCursorCastTarget(self:GetCaster())
		if self:GetAbility():GetAbilityName() == "imba_grimstroke_dark_artistry" then
			self:GetAbility():OnSpellStart(true)
		else
			self:GetAbility():OnSpellStart()
		end
	end
end

modifier_imba_soul_chain_slow = class({})

function modifier_imba_soul_chain_slow:IsDebuff()			return true end
function modifier_imba_soul_chain_slow:IsHidden() 			return false end
function modifier_imba_soul_chain_slow:IsPurgable() 		return false end
function modifier_imba_soul_chain_slow:IsPurgeException() 	return false end
function modifier_imba_soul_chain_slow:DeclareFunctions()   return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE} end
function modifier_imba_soul_chain_slow:GetModifierMoveSpeedBonus_Percentage() return (0 - self:GetAbility():GetSpecialValueFor("no_sec_slow")) end

function modifier_imba_soul_chain_slow:OnCreated()
	if IsClient() then
		self:SetDuration(-1, true)
	end
end

function modifier_imba_soul_chain_slow:OnRefresh() self:OnCreated() end