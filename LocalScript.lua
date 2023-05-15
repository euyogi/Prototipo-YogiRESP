-- Makes a copy of an existent in game text button and changes it to be an Esp Switch
local function createEspSwitch(targetEspName, existentSwitch)
	local Switch = existentSwitch:Clone()
	Switch.Name = targetEspName .. "EspSwitch"
	Switch.Position = UDim2.new(-1.2, 0, -4.03, 0)
	Switch.Size = UDim2.new(5, 0, 0.8, 0)
	Switch.TextLabel.Text = targetEspName .. " Esp (OFF)"
	Switch.Notify.Text = "Shows where a " .. targetEspName .. " is located"
	Switch.Parent = existentSwitch.Parent

	return Switch
end

-- Adds a Text Label on a thing written the thing name, you can see it through walls
local function addTextLabel(thing)
	local BillboardGui = Instance.new("BillboardGui")
	BillboardGui.AlwaysOnTop = true
	BillboardGui.Size = UDim2.fromOffset(100, 25)
	BillboardGui.Parent = thing

	local Text = Instance.new("TextLabel")
	Text.BackgroundTransparency = 1
	Text.Text = "<b>" .. thing.Name .. "</b>"
	Text.TextColor3 = Color3.fromRGB(255, 255, 0)
	Text.RichText = true
	Text.Size = UDim2.fromOffset(100, 25)
	Text.Parent = BillboardGui
end

local targetEspName = "Fruit"

local SettingsButton = game.Players.LocalPlayer.PlayerGui.Main.Settings

-- Creates the Esp Switch
local EspSwitch = createEspSwitch(targetEspName, SettingsButton.DmgCounterButton)

-- Declares that variable to, when we want to turn off the Esp, disconnecting that variable will
local listeningToWorkspace

SettingsButton.Activated:Connect(function()
	if (EspSwitch.Visible) then
		EspSwitch.Visible = false
	else
		EspSwitch.Visible = true
	end
end)

-- When the Esp Switch is clicked
EspSwitch.Activated:Connect(function()
	-- Adds/removes the label to existent childs
	for _, child in ipairs(workspace:GetChildren()) do
		if child.Name == targetEspName .. " " then
			if child:FindFirstChild("BillboardGui") == nil then
				addTextLabel(child)
			else
				child.BillboardGui:Destroy()
			end

		-- In addition to childs with targetEspName name I want to add/remove the label to a Tool
		-- that has a child with targetEspName name, but without iterating over all workspace descendants
		elseif child.ClassName == "Tool" then
			if child:FindFirstChild("BillboardGui") == nil then
				if child:FindFirstChild(targetEspName) ~= nil then
					addTextLabel(child)
				end
			else
				child.BillboardGui:Destroy()
			end
		end
	end

	-- Enables/disables the workspace listening for childs added 
	if listeningToWorkspace then -- check if we are listening
		EspSwitch.TextLabel.Text = targetEspName .. " Esp (OFF)"

		listeningToWorkspace:Disconnect() -- disconnect the event and stop the listening
		listeningToWorkspace = nil -- clear the variable
	else -- if the connection does not exist
		EspSwitch.TextLabel.Text = targetEspName .. " Esp (ON)"

		-- Connect the event and start the listening
		listeningToWorkspace = workspace.ChildAdded:Connect (function(child)
			-- Adds label to the child added if it's name is targetEspName or if the child is a Tool and has a child with the name
			if child.Name == targetEspName or child.Name == targetEspName .. " " then
				addTextLabel(child)
			elseif child.ClassName == "Tool" then
				if child:FindFirstChild("BillboardGui") == nil and child:FindFirstChild(targetEspName) ~= nil then
					addTextLabel(child)
				end
			end
		end)
	end
end)