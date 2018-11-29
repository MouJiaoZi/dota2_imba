--custom/imba_aegis

modifier_imba_aegis = class({})

function modifier_imba_aegis:IsDebuff()			return false end
function modifier_imba_aegis:IsHidden() 		return false end
function modifier_imba_aegis:IsPurgable() 		return false end
function modifier_imba_aegis:IsPurgeException() return false end
function modifier_imba_aegis:AllowIllusionDuplicate() return false end
function modifier_imba_aegis:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end
function modifier_imba_aegis:GetTexture() return "custom/imba_aegis" end
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
function modifier_imba_roshan_upgrade:DeclareFunctions() return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_EVENT_ON_TAKEDAMAGE} end
function modifier_imba_roshan_upgrade:GetModifierAttackSpeedBonus_Constant() return (self:GetStackCount() * 50) end
function modifier_imba_roshan_upgrade:GetModifierPreAttack_BonusDamage() return (self:GetStackCount() * 80) end
function modifier_imba_roshan_upgrade:GetModifierPhysicalArmorBonus() return (self:GetStackCount() * 2) end
function modifier_imba_roshan_upgrade:GetPriority() return MODIFIER_PRIORITY_HIGH end
function modifier_imba_roshan_upgrade:CheckState()
	if self:GetStackCount() < 8 then
		return {[MODIFIER_STATE_STUNNED] = false}
	else
		return {[MODIFIER_STATE_STUNNED] = false, [MODIFIER_STATE_CANNOT_MISS] = true, [MODIFIER_STATE_DISARMED] = false, [MODIFIER_STATE_ROOTED] = false} 
	end
end


function modifier_imba_roshan_upgrade:OnTakeDamage(keys)
	if not IsServer() then
		return
	end
	if keys.unit == self:GetParent() then
		self.damage = GameRules:GetGameTime()
	end
end

function modifier_imba_roshan_upgrade:OnCreated()
	if IsServer() then
		self.damage = 0
		self:StartIntervalThink(0.1)
	end
end

function modifier_imba_roshan_upgrade:OnIntervalThink()
	if not self:GetParent():IsAlive() then
		self:Destroy()
		return
	end
	----back to your house
	if (self:GetParent():GetAbsOrigin() - roshan_pos):Length2D() > 1200 then
		FindClearSpaceForUnit(self:GetParent(), roshan_pos, true)
		self:GetParent():Stop()
	end
	----regen health
	if GameRules:GetGameTime() - self.damage > 5.0 then
		self:GetParent():Heal(self:GetParent():GetMaxHealth() * 0.05, nil)
		FindClearSpaceForUnit(self:GetParent(), roshan_pos, true)
		self:GetParent():Stop()
	end
end
