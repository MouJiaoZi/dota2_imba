PseudoRandom = class({})

if not PseudoRandom.RandomInstanceTable then
	PseudoRandom.RandomInstanceTable = {}
end

PseudoRandom.RandomC = {}

for i=1, 100 do
	PseudoRandom.RandomC[i] = nil
end

function PseudoRandom:RollPseudoRandom(Instance, pct)
	if not Instance or pct <= 0 or (type(Instance) ~= "number" and not Instance.entindex) then
		return false
	end
	local hInstance = type(Instance) == "number" and Instance or Instance:entindex()
	PseudoRandom.RandomC[pct] = PseudoRandom.RandomC[pct] or PseudoRandom:CFromP(pct / 100) * 100
	local increase = PseudoRandom.RandomC[pct]
	if not PseudoRandom.RandomInstanceTable[hInstance] then
		PseudoRandom.RandomInstanceTable[hInstance] = increase
		return RollPercentage(PseudoRandom.RandomInstanceTable[hInstance])
	else
		PseudoRandom.RandomInstanceTable[hInstance] = PseudoRandom.RandomInstanceTable[hInstance] + increase
		if RollPercentage(PseudoRandom.RandomInstanceTable[hInstance]) then
			PseudoRandom.RandomInstanceTable[hInstance] = 0
			return true
		else
			return false
		end
	end
end

-- main code comes from https://github.com/Perryvw/LuaLibraries/blob/master/PseudoRNG.lua

function PseudoRandom:CFromP(P)
	local Cupper = P
	local Clower = 0
	local Cmid = 0
	
	local p1 = 0
	local p2 = 1
	
	while true do
		Cmid = (Cupper + Clower) / 2;
		p1 = PseudoRandom:PFromC(Cmid)
		if math.abs(p1 - p2) <= 0 then
			break
		end
		
		if p1 > P then
			Cupper = Cmid
		else
			Clower = Cmid
		end
		
		p2 = p1
	end
	
	return Cmid
end

function PseudoRandom:PFromC(C)
	local pOnN = 0
	local pByN = 0
	local sumPByN = 0
	
	local maxFails = math.ceil(1/ C)
	
	for N=1,maxFails do
		pOnN = math.min(1, N * C) * (1 - pByN)
		pByN = pByN + pOnN
		sumPByN = sumPByN + N * pOnN
	end

	return 1/sumPByN
end
