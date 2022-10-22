if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 258258996 then return end

--// SERVICES

local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")
local starterGui = game:GetService("StarterGui")
local userInputService = game:GetService("UserInputService")

--// PLAYER

local player = players.LocalPlayer

--// GUI

local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("GUI") 					-- also counts as dependant :P
local craftsman = gui:WaitForChild("Craftsman")
local draedon = gui:WaitForChild("SuperstitiousCrafting")

--// EXCALIBUR INITIALIZATION

getgenv().Excalibur = {}
getgenv().Excalibur.Data = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nkuhanas/Excalibur/main/data.lua", true))()
getgenv().Excalibur.Items = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nkuhanas/Excalibur/main/items.lua", true))()
getgenv().Excalibur.Automation = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nkuhanas/Excalibur/main/automation.lua", true))()

--// DEPENDANT VARIABLES

local withdrawRemote = replicatedStorage:WaitForChild("DestroyAll")
local layoutRemote = replicatedStorage:WaitForChild("Layouts")

local placement = require(replicatedStorage:WaitForChild("PlacementModule"))
local placement2 = require(gui:WaitForChild("Placement"))
local layoutUtility = require(replicatedStorage:WaitForChild("LayoutUtility"))
local theCraftsman = require(gui:WaitForChild("Craftsman"):WaitForChild("TheCraftsman"))
local focus = require(gui:WaitForChild("Focus"))

--// FUNCTIONS

local function sendNotification(txt, dur, til)
	starterGui:SetCore("SendNotification", {
		Title = til or "Notification",
		Text = txt,
		Duration = dur or 5,
	})
end

local function valToText(val)
	if val then
		return "enabled"
	else
		return "disabled"
	end
end

-- LAYOUTS

local function withdrawAll()
	if withdrawRemote:InvokeServer() then
		placement2.withdrawAll()
	end
end

local function loadLayout(num)
	withdrawAll()
	layoutRemote:InvokeServer("Load", "Layout"..tostring(num))
end

-- MENUS

local function openCraftsman()
	theCraftsman.forceopen("ShinyEvo")
	focus.change(craftsman)
end

local function openDraedon()
	focus.Change(draedon)
end

-- INPUT

local function inputHandler(func, keybind, ...)
	local args = {...}
	userInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == keybind and userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			func(unpack(args))
		end
	end)
end

--// BINDS

inputHandler(withdrawAll, Enum.KeyCode.Zero)		-- all the simple ones
inputHandler(loadLayout, Enum.KeyCode.One, 1)
inputHandler(loadLayout, Enum.KeyCode.Two, 2)
inputHandler(loadLayout, Enum.KeyCode.Three, 3)

inputHandler(function() sendNotification("Auto box "..valToText(getgenv().Excalibur.Automation.Toggles.AutoBox())..".") end, Enum.KeyCode.Four)
inputHandler(function() sendNotification("Ore boosting "..valToText(getgenv().Excalibur.Automation.Toggles.OreBoost())..".") end, Enum.KeyCode.Five)
inputHandler(function() sendNotification("Auto rebirthing "..valToText(getgenv().Excalibur.Automation.Toggles.AutoRebirth())..".") end, Enum.KeyCode.Six)


inputHandler(openCraftsman, Enum.KeyCode.Seven)
inputHandler(openDraedon, Enum.KeyCode.Eight)

inputHandler(function() sendNotification("Auto Box set to: "..getgenv().Excalibur.Data.Boxes[getgenv().Excalibur.Automation.Cycles.BoxCycle()].." box") end, Enum.KeyCode.Comma)
inputHandler(function() sendNotification("Rebirth layout set to: Layout "..tostring(getgenv().Excalibur.Automation.Cycles.LayoutCycle())) end, Enum.KeyCode.Period)

--// START

sendNotification("Excalibur fully loaded.", 15, "Welcome")	
task.wait(5)
replicatedStorage:FindFirstChild("RedeemFreeBox"):FireServer()
