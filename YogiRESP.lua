local gameName = string.sub(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, 1, 11)
local playerGui = game.Players.LocalPlayer.PlayerGui

local function createSwitch()
	local switch

	if (gameName == "Blox Fruits") then
		-- The settings image button at the right
		local settings = playerGui.Main.Settings

		-- Creates the ESP switch by making a copy of an existent one
		switch = settings.DmgCounterButton:Clone()
		switch.Notify.Text = "Shows where targets are located"
		switch.Position = UDim2.new(-1.2, 0, -4.03, 0) -- Above counter switch
		switch.Size = UDim2.new(5, 0, 0.8, 0) -- Similar size to the other switchs
		switch.Parent = settings

		-- Shows/hide the switch when settings image button is clicked
		settings.Activated:Connect(function()
			if (switch.Visible) then
				switch.Visible = false
			else
				switch.Visible = true
			end
		end)
	else
		local gui = playerGui.scrGui

		switch = Instance.new("TextButton")
		switch.Text = ""
		switch.BackgroundColor3 = Color3.fromRGB(255, 255, 55)
		switch.Position = UDim2.new(0.5, 0, 0, 2)
		switch.AnchorPoint = Vector2.new (0.5, 0)
		switch.Size = UDim2.fromOffset(70, 25)
		switch.Parent = gui

		local label = Instance.new("TextLabel")
		label.BorderSizePixel = 0
		label.Position = UDim2.new(0.5, 0, 0.5, 0)
		label.AnchorPoint = Vector2.new (0.5, 0)
		label.Parent = switch
	end

	switch.Name = "espSwitch"
	switch.TextLabel.Text = "ESP (OFF)"

	return switch
end

local function toScreen(text, time, color)
	local label = Instance.new("TextLabel")
	label.Text = text
	label.TextColor3 = color
	label.RichText = true
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0.5, 0, 0.7, 0)
	label.AnchorPoint = Vector2.new (0.5, 0)
	label.Size = UDim2.fromOffset(100, 25)
	label.Parent = playerGui.scrGui

	wait(time)

	label.Text = ""
end

-- Adds a Text Label on a thing, you can see it through walls
local function addLabel(thing, name, color)
	local name = name or thing.Name
	local size = UDim2.fromOffset(100, 25)

	local billboard = Instance.new("BillboardGui")
	billboard.AlwaysOnTop = true
	billboard.Size = size
	billboard.Parent = thing

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = "<b>" .. name .. "</b>"
	label.TextColor3 = color
	label.RichText = true
	label.Size = size
	label.Parent = billboard
end

local gui = Instance.new("ScreenGui")
gui.Name = "scrGui"
gui.Parent = playerGui

local switch = createSwitch()

toScreen("The script has been started", 10, Color3.fromRGB(255, 255, 255))

-- Variable to keep the connection, so after we can disconnect
local workspaceConnection

local targetsNames = {["Fruit"] = true, ["Fruit "] = true}

-- Enables/disables the ESP when ESP switch is clicked
switch.Activated:Connect(function()
	-- Adds/removes the label to existent children if their name is one of targetsNames
	for _, child in ipairs(workspace:GetChildren()) do
		if targetsNames[child.Name] then
			if child:FindFirstChild("BillboardGui") == nil then
				if gameName == "Blox Fruits" then
					local meshesName 

					for __, descendant in ipairs(child:GetChildren()) do
						if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then
							meshesName = string.sub(descendant.Name, 8, #descendant.Name)

							break
						end
					end

					if meshesName then
						addLabel(child, meshesName, Color3.fromRGB(255, 255, 0))
					else
						addLabel(child, nil, Color3.fromRGB(255, 255, 0))
					end

					toScreen("A fruit has spawned", 10, Color3.fromRGB(255, 255, 255))
				else
					addLabel(child, nil, Color3.fromRGB(255, 255, 0))
				end
			else
				child.BillboardGui:Destroy()
			end

		-- On Blox Fruits I want to add/remove the label to tools with a
		-- child named "Fruits", because thats how dropped fruits are there
		elseif gameName == "Blox Fruits" and child.ClassName == "Tool" then
			if child:FindFirstChild("BillboardGui") == nil then
				if child:FindFirstChild("Fruits") then
					addLabel(child, nil, Color3.fromRGB(0, 0, 255))
				end
			else
				child.BillboardGui:Destroy()
			end
		end
	end

	-- Enables/disables the workspace connection listening for children added 
	if workspaceConnection then -- check if we are connected
		switch.TextLabel.Text = "ESP (OFF)"

		workspaceConnection:Disconnect() -- disconnect the event and stop the listening
		workspaceConnection = nil -- clear the variable
	else -- if the connection does not exist
		switch.TextLabel.Text = "ESP (ON)"

		-- Connect the event and start the listening
		workspaceConnection = workspace.ChildAdded:Connect (function(child)
			-- Adds label to the child added if it's name is one of targetsNames or if the game is Blox Fruits and the child is a Tool and has a the name "Fruit"
			if targetsNames[child.Name] then
				if gameName == "Blox Fruits" then
					local meshesName 

					for __, descendant in ipairs(child:GetChildren()) do
						if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then
							meshesName = string.sub(descendant.Name, 8, #descendant.Name)

							break
						end
					end

					if meshesName then
						addLabel(child, meshesName, Color3.fromRGB(255, 255, 0))
					else
						addLabel(child, nil, Color3.fromRGB(255, 255, 0))
					end

					toScreen("A fruit has spawned", 10, Color3.fromRGB(255, 255, 255))
				else
					addLabel(child, nil, Color3.fromRGB(255, 255, 0))
				end
			elseif gameName == "Blox Fruits" and child.ClassName == "Tool" then
				if child:FindFirstChild("BillboardGui") == nil and child:FindFirstChild("Fruit") then
					addLabel(child, nil, Color3.fromRGB(0, 0, 255))
				end
			end
		end)
	end
end)
