--// SERVICES

local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")

--// PLAYER

local player = players.LocalPlayer

--// DATA

local items = getgenv().Excalibur.Items
local data = getgenv().Excalibur.Data
	
--// DEPENDANT VARIABLES

local boxRemote = replicatedStorage:WaitForChild("MysteryBox")
local layoutRemote = replicatedStorage:WaitForChild("Layouts")
local rebirthRemote = replicatedStorage:WaitForChild("Rebirth")
local moneyMirror = replicatedStorage:WaitForChild("MoneyMirror")
local moneyLib = require(replicatedStorage:WaitForChild("MoneyLib"))

--// VARIABLES

local rebirthLayout = 1
--local cashLayout = 1 // honestly too lazy to make

local currentBox = 1

local default = {CFrame = (items.Tycoon:WaitForChild("Base").CFrame * CFrame.new(0, 25, 0))}

local autoBoxEnabled = false
local autoRebirthEnabled = false
local oreBoostingEnabled = false

--// FUNCTIONS

local function getMoney()
	local money = moneyMirror:FindFirstChild(player.Name)
	if money then
		return money.Value
	end
	return nil
end

local function cycleRebirthLayout()
	if rebirthLayout == 3 then 
		rebirthLayout = 1 
	else 
		rebirthLayout += 1 
	end
	return rebirthLayout
end

local function autoRebirth()
	autoRebirthEnabled = not autoRebirthEnabled
	if autoRebirthEnabled then
		task.spawn(function()
			while true do
				task.wait(0.1)
				if (getMoney() or 0) >= moneyLib.RebornPrice(player) then
					rebirthRemote:InvokeServer()
					layoutRemote:InvokeServer("Load", "Layout"..tostring(rebirthLayout)) --// eventually replace with cash layout maybe
				end
			end
		end)
	end
	return autoRebirthEnabled
end

local function cycleBox()
	if currentBox == #data.Boxes then 
		currentBox = 1 
	else 
		currentBox += 1
	end
	return currentBox
end

local function autoBox()
	if not autoBoxEnabled then
		autoBoxEnabled = runService.Stepped:Connect(function()
			local args = {data.Boxes[currentBox]}
			boxRemote:InvokeServer(table.unpack(args))
		end)
		return true
	else
		autoBoxEnabled:Disconnect()
		autoBoxEnabled = nil
		return false
	end
end

--// BOOSTING; REMOVE WHEN NEEDED

local function boostOre(ore, latency)
	task.spawn(function()
		for _, Upgrader in pairs(items.Upgraders) do
			ore.CFrame = Upgrader.CFrame
			task.wait(latency)
		end
		for _, Resetter in pairs(items.Resetters) do
			ore.CFrame = Resetter.CFrame
			task.wait(latency)
			for _, Upgrader in pairs(items.Upgraders) do
				ore.CFrame = Upgrader.CFrame
				task.wait(latency)
			end
		end
		ore.CFrame = (items.Furnaces[1] or default).CFrame * CFrame.new(0, 0.2, 0)
	end)
end

local function oreBoost(latency)
	if not oreBoostingEnabled then
		table.foreach(items.Upgraders, print)
		oreBoostingEnabled = items.Ores.ChildAdded:Connect(function(ore)
			boostOre(ore, latency or 0.025)
		end)
		for _, Ore in ipairs(items.Ores:GetChildren()) do
			boostOre(Ore, latency or 0.025)
		end
		return true
	else
		oreBoostingEnabled:Disconnect()
		oreBoostingEnabled = nil
		return false
	end
end

items.Ores.DescendantAdded:Connect(function(x)
	if oreBoostingEnabled and x:IsA("BodyVelocity") then
		x.Velocity = Vector3.new(0,0,0)
	end
end)

--// BOOSTING END

return {
	Toggles = {
		AutoRebirth = autoRebirth,
		OreBoost = oreBoost,
		AutoBox = autoBox,
	},
	Cycles = {
		BoxCycle = cycleBox,
		LayoutCycle = cycleRebirthLayout,
	},
}
