local targetGameName = "Blox Fruits"
local targetsNames = {["Fruit"] = true, ["Fruit "] = true}

local gameName = string.sub(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, 1, #targetGameName)
local playerGui = game.Players.LocalPlayer.PlayerGui

-- Creates a screen gui for our script stuff
local function createGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "scrGui"
	gui.Parent = playerGui
end

-- The switch to turn the ESP on/off
local function createSwitch()
	local switch

	if (gameName == "Blox Fruits") then
		-- The settings image button at the right on Blox Fruits
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
		switch = Instance.new("TextButton")
		switch.Text = ""
		switch.BackgroundColor3 = Color3.fromRGB(255, 255, 55)
		switch.Position = UDim2.new(0.5, 0, 0, 2)
		switch.AnchorPoint = Vector2.new (0.5, 0)
		switch.Size = UDim2.fromOffset(70, 25)
		switch.Parent = playerGui.scrGui

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

-- Shows temporarily text at the middle of the screen
local function toScreen(text, time, color)
	local time = time or 10
	local color = color or Color3.fromRGB(255, 255, 255)

	local label = Instance.new("TextLabel")
	label.Text = text
	label.TextColor3 = color
	label.FontSize = Enum.FontSize.Size14
	label.RichText = true
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0.5, 0, 0.7, 0)
	label.AnchorPoint = Vector2.new (0.5, 0)
	label.Size = UDim2.fromOffset(100, 25)
	label.Parent = playerGui.scrGui

	wait(time)

	label.Text = ""
end

-- Adds text to thing, you can see it through walls (ESP)
local function addLabel(thing, name, color)
	local name = name or thing.Name
	local color = color or Color3.fromRGB(255, 255, 255)

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

-- this can't be removed because createSwitch and toScreen depends on it
createGui()

-- Creates the switch to turn the ESP on/off
local switch = createSwitch()

-- Variable to keep the connection, so after we can disconnect
local workspaceConnection

-- To be called when a fruit spawns (BLOXFRUITS)
local function fruitSpawned(child) -- Child = Fruit
	local meshesName -- Spawned fruits have their name on a MeshPart

	wait(1) -- Wait for children to born (I think that fixes fruits spawning without name)

	-- The MeshPart is a children of the fruit and the name is like Meshes/fruitsname_34
	for __, descendant in ipairs(child:GetChildren()) do -- Iterates over fruit's children
		if descendant:IsA("MeshPart") and string.sub(descendant.Name, 1, 7) == "Meshes/" then
			local i, j = string.find(descendant.Name, "_") -- Gets the index of "_"

			meshesName = string.sub(descendant.Name, 8, i - 1) -- Keep the fruit name after "Meshes/" and before "_"
			meshesName = meshesName:gsub("^%l", string.upper) .. " Fruit"

			break
		end
	end

	if meshesName then -- If we got the fruit's name
		addLabel(child, meshesName, Color3.fromRGB(255, 255, 0))
	else -- It's possible that the fruit didn't have it and therefore no name
		addLabel(child, nil, Color3.fromRGB(255, 255, 0))
	end

	toScreen("A " .. meshesName .. " has spawned", nil, Color3.fromRGB(0, 255, 255))
end

-- To be called when a fruit is dropped (BLOXFRUITS)
local function fruitDropped(child)
	if child.ClassName == "Tool" then -- Dropped fruits are tools
		if not child:FindFirstChild("BillboardGui") then
			if child:FindFirstChild("Fruit") then -- Dropped fruits can't be searched by name, but they have a child called "Fruit"
				addLabel(child, nil, Color3.fromRGB(0, 0, 255))

				toScreen("A " .. child.Name .. " has been dropped", nil, Color3.fromRGB(255, 0, 255))
			end
		else
			child.BillboardGui:Destroy() -- Disables ESP if the function is called when turning off ESP
		end
	end
end

-- Enables/disables the ESP when ESP switch is clicked
switch.Activated:Connect(function()

	-- Enables/disables the workspace connection listening for children added 
	if workspaceConnection then -- check if we are connected
		switch.TextLabel.Text = "ESP (OFF)"

		workspaceConnection:Disconnect() -- disconnect the event and stop the listening
		workspaceConnection = nil -- clear the variable
	else -- if the connection does not exist
		switch.TextLabel.Text = "ESP (ON)"

		-- Connect the event and start the listening
		workspaceConnection = workspace.ChildAdded:Connect (function(child)
			
			-- Adds label to the child added if it's name is one of targetsNames
			if targetsNames[child.Name] then
				if gameName == "Blox Fruits" then
					fruitSpawned(child)
				else
					addLabel(child, nil, Color3.fromRGB(255, 255, 0))
				end

			-- On Blox Fruits I want to add/remove the label to fruits dropped and they don't have predictable names
			elseif gameName == "Blox Fruits" then -- so we call the function to handle that
				fruitDropped(child)
			end
		end)
	end

	-- Adds/removes the label to existent children if their name is one of targetsNames
	for _, child in ipairs(workspace:GetChildren()) do
		if targetsNames[child.Name] then
			if not child:FindFirstChild("BillboardGui") then
				if gameName == "Blox Fruits" then
					fruitSpawned(child)
				else
					addLabel(child, nil, Color3.fromRGB(255, 255, 0))
				end
			else
				child.BillboardGui:Destroy() -- Disables ESP if the function is called when turning off ESP
			end

		-- On Blox Fruits I want to add/remove the label to fruits dropped and they don't have predictable names
		elseif gameName == "Blox Fruits" then -- so we call the function to handle that
			fruitDropped(child)
		end
	end
end)

toScreen("The script has been started", nil, Color3.fromRGB(0, 255, 0))

-- By Yogi
