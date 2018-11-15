-- Lua memory leak detector
-- @author XavierCHN
-- @date 2017.06.23
-- @license: DO ANYTHING YOU WANT 

if memory_state == nil then
	local memory_state = {} -- 储存所有的内存调用
end

if current_memory == nil then
	local current_memory = 0 -- 储存总内存状态
end

local function recordAlloc(event, line_no)
	local memory_increased = collectgarbage("count") - current_memory
	if (memory_increased < 1e-6) then return end

	local info = debug.getinfo(2, "S").source
	info = string.format("%s@%s", info, line_no - 1)

	local item = memory_state[info]
	if not item then
		memory_state[info] = {info, 1, memory_increased}
	else
		item[2] = item[2] + 1
		item[3] = item[3] + memory_increased
	end
	current_memory = collectgarbage("count")
end

utilsMemoryLeakDetector = {}

function utilsMemoryLeakDetector:StartRecord()
	if debug.gethook() then
		self:StopRecord()
		return
	end

	memory_state = {}
	current_memory = collectgarbage("count")
	debug.sethook(recordAlloc, "l")
end

function utilsMemoryLeakDetector:ShowRecord(count)
	if not memory_state then return end
	local sorted = {}

	for k, v in pairs(memory_state) do
		table.insert(sorted, v)
	end

	table.sort(sorted, function(a, b) return a[3] > b[3] end)

	for i = 1, count do
		local v = sorted[i]
		print(string.format("MemoryDump [MEM: %sK] [COUNT: %s ] [AVG: %s k] %s:", v[3], v[2], v[3] / v[2], v[1]))
	end
end

function utilsMemoryLeakDetector:EndRecord()
	debug.sethook()
end

utilsMemoryLeakDetector:StartRecord()

if IsInToolsMode() then
	Convars:RegisterCommand("debug_dump_lua_memory_detail",function(_, top_count)
		count = tonumber(top_count) or 30
		utilsMemoryLeakDetector:ShowRecord(count)
	end,"Dump lua usage",FCVAR_CHEAT)
end