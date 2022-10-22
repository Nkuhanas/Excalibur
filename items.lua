--// PLAYER

local players = game:GetService("Players")

local player = players.LocalPlayer

--// DEPENDANT VARIABLES

local factory = player:WaitForChild("ActiveTycoon").Value.Name
local ores = workspace:WaitForChild("DroppedParts"):WaitForChild(factory)
local tycoon = workspace:WaitForChild("Tycoons"):WaitForChild(factory)

--// DATA

local data = getgenv().Excalibur.Data

--// VARIABLES

local items = setmetatable({Ores = ores, Tycoon = tycoon, Factory = factory}, {__newindex = function(x, y, z)
	if type(z) ~= "function" then z = function() end end
	rawset(x, y, setmetatable({}, {__newindex = function(t, k, v)
		local c
		c = v.AncestryChanged:Connect(function()
			if table.find(t, v) then
				table.remove(t, table.find(t, v))
			else
				rawset(t, k, nil)
			end
			z(t, k, v)
			c:Disconnect()
			c = nil
		end)
		rawset(t, k, v)
	end}))
end})

items.Upgraders = {}
items.Furnaces = {}
items.Droppers = {}
items.Resetters = {}
items.Teleporters = {}

--// FUNCTIONS

local function assignItem(item)
	if not item:IsA("Model") or not item:WaitForChild("Plane", 3) then return end
	
	local model = item:WaitForChild("Model")
	
	for i,v in pairs(data.Resetters) do 
		for x = #v, 1, -1 do
			if string.find(model.Parent.Name, v[x]) then 
				items.Resetters[i] = model:FindFirstChild("Upgrade")
				print("Found resetter: "..item.Name)
				return
			end 
		end 
	end
	
	for name, category in pairs(types) do
		if model:FindFirstChild(name) then
			
			if name == "Lava" and model:FindFirstChild(name):FindFirstChild("TeleportSend") then --// teleporter
				items.Teleporters[#items.Teleporters+1] = model:FindFirstChild(name) 
				return
			end
			
			if name == "Upgrade" then --// get all upgraders
				for _, v in ipairs(model:GetChildren()) do 
					if v.Name:sub(1,7) == "Upgrade"and #v.Name <= 8 then 
						items.Upgraders[#items.Upgraders+1] = v 
					end
				end
				return
			end
			
			items[category][#items[category]+1] = model:FindFirstChild(name)
			return
		end
	end
end

--// INIT

tycoon.ChildAdded:Connect(assignItem)
for _, item in ipairs(tycoon:GetChildren()) do
	assignItem(item)
end

return items
