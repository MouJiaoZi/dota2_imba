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

function C_DOTABaseAbility:GetAbilityCurrentKV()
	local name = self:GetName()
	local kv_to_return = {}
	local level = self:GetLevel()
	if level <= 0 then
		return nil
	end
	local kv = AbilityKV[name]["AbilitySpecial"] or ItemKV[name]["AbilitySpecial"]
	for k, v in pairs(kv) do
		for a, b in pairs(v) do
			for str in string.gmatch(b, "%S+") do
				if tonumber(str) then
					local lv = 0
					for s in string.gmatch(b, "%S+") do
						lv = lv + 1
						if lv <= level then
							kv_to_return[a] = tonumber(s)
						else
							break
						end
					end
					break
				end
			end
		end
	end
	return kv_to_return
end

function C_DOTA_Modifier_Lua:SetAbilityKV()
	self.kv = self:GetAbility():GetAbilityCurrentKV()
	return self.kv
end

function C_DOTA_Modifier_Lua:GetAbilityKV(sKeyname)
	return self.kv and (self.kv[sKeyname] or 0) or 0
end