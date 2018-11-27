if IsClient() then
	print("Client UTIL Loaded")
end


function C_DOTA_BaseNPC:HasTalent(sTalentName)
	if self:HasModifier("modifier_"..sTalentName) then
		return true 
	end

	return false
end

function C_DOTA_BaseNPC:GetTalentValue(sTalentName, key)
	if self:HasModifier("modifier_"..sTalentName) then  
		local value_name = key or "value"
		local specialVal = AbilityKV[sTalentName]["AbilitySpecial"]
		for k,v in pairs(specialVal) do
			if v[value_name] then
				return v[value_name]
			end
		end
	end    
	return 0
end

function CreateEmptyTalents(hero)
	for i=1,8 do
		LinkLuaModifier("modifier_special_bonus_imba_"..hero.."_"..i, "hero/hero_"..hero, LUA_MODIFIER_MOTION_NONE)  
		local class = "modifier_special_bonus_imba_"..hero.."_"..i.." = class({IsHidden = function(self) return true end, RemoveOnDeath = function(self) return self:GetParent():IsIllusion() end, AllowIllusionDuplicate = function(self) return true end, GetTexture = function(self) return 'naga_siren_mirror_image' end})"  
		load(class)()
	end
end


function C_DOTABaseAbility:HasFireSoulActive()
	return self:GetCaster():HasModifier("modifier_imba_fiery_soul_active")
end

function IsInTable(value, table)
	for _, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

function IsNearEnemyFountain(location, team, distance)

	local fountain_loc
	if team == DOTA_TEAM_GOODGUYS then
		fountain_loc = Vector(7472, 6912, 512)
	else
		fountain_loc = Vector(-7456, -6938, 528)
	end

	local dis = math.sqrt((fountain_loc.x - location.x) ^ 2 + (fountain_loc.y - location.y) ^ 2)

	if dis <= distance then
		return true
	end

	return false
end

function IsEnemy(unit1, unit2)
	if unit1:GetTeamNumber() == unit2:GetTeamNumber() then
		return false
	else
		return true
	end
end

function C_DOTA_BaseNPC:GetCastRangeBonus()
	local range = self:GetModifierStackCount("modifier_imba_talent_modifier_adder", nil)
	return range
end
