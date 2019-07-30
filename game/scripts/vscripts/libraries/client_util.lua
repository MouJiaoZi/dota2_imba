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
	if level <= 0 or (not AbilityKV[name] and ItemKV[name]) then
		return nil
	end
	local kv = AbilityKV[name] and AbilityKV[name]["AbilitySpecial"] or ItemKV[name]["AbilitySpecial"]
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

function C_DOTA_BaseNPC:IsUnit()
	return self:IsHero() or self:IsCreep() or self:IsBoss()
end

function C_DOTA_BaseNPC:IsTrueHero()
	return (not self:HasModifier("modifier_arc_warden_tempest_double") and self:IsRealHero() and not self:HasModifier("modifier_imba_meepo_clone_controller"))
end

function C_DOTA_Ability_Lua:SetAbilityIcon()
	--print(self:entindex())
	local info = CustomNetTables:GetTableValue("imba_ability_icon", tostring(self:entindex()))
	for k,v in pairs(info) do
		if self.GetAbilityTextureName ~= self.BaseClass.GetAbilityTextureName then
			return
		end
		self.imba_ability_icon = v
		self.GetAbilityTextureName = function() return self.imba_ability_icon end
		break
	end
end

function SplitString(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
		if not nFindLastIndex then  
			nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
			break  
		end  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
		nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end

function HEXConvertToRGB(hex)
    hex = hex:gsub("#","")
    return {tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))}
end

function RGBConvertToHSV(colorRGB)
	local r,g,b = colorRGB[1], colorRGB[2], colorRGB[3]
	local h,s,v = 0,0,0

	local max1 = math.max(r, math.max(g,b))
	local min1 = math.min(r, math.min(g,b))

	if max1 == min1 then
		h=0;
	else
		if r == max1 then
			if g >= b then
				h = 60 * (g-b) / (max1-min1)
			else
				h = 60 * (g-b) / (max1-min1) + 360
			end
		end
		if g == max1 then
			h = 60 * (b-r)/(max1-min1) + 120
		end
		if b == max1 then
			h = 60 * (r-g)/(max1-min1) + 240;
		end
	end    
	
	if max1 == 0 then
		s = 0
	else
		s = (1- min1 / max1) * 255
	end
	
	v = max1
	
	return {h, s, v}
end


function StringToVector(sString)
	--Input: "123 123 123"
	local temp = {}
	for str in string.gmatch(sString, "%S+") do
		if tonumber(str) then
			temp[#temp + 1] = tonumber(str)
		else
			return nil
		end
	end
	return Vector(temp[1], temp[2], temp[3])
end

function C_DOTA_Modifier_Lua:SetMaelStromParticle()
		local info = CustomNetTables:GetTableValue("imba_level_rewards", "player_state_"..tostring(self:GetCaster():GetPlayerOwnerID()))
		if info then
			local pfx_id = info['maelstrom_pfx']
			self.chain_pfx = Hero_Items_KV['mael_storm_particles'][tostring(pfx_id)]['chain']
			self.shield_pfx = Hero_Items_KV['mael_storm_particles'][tostring(pfx_id)]['shield']
			local color_info = CustomNetTables:GetTableValue("imba_item_color", "maelstrom_color"..tostring(self:GetCaster():GetPlayerOwnerID()))
			if color_info and not color_info['default'] then
				self.color = Vector(color_info['r'], color_info['g'], color_info['b'])
			else
				self.color = StringToVector(Hero_Items_KV['mael_storm_particles'][tostring(pfx_id)]['default_color'])
			end
		else
			self.chain_pfx = "particles/items_fx/chain_lightning.vpcf"
			self.shield_pfx = "particles/items2_fx/mjollnir_shield.vpcf"
			self.color = Vector(90, 110, 221)
		end
	end