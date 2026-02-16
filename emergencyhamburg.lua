-- Emergency Hamburg Script by Venice
-- Features: Kill Aura, Anti-Cuff, Keep-Away, Car Blaster
-- For use with Delta Executor or similar

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EmergencyHamburgGUI"
screenGui.Parent = game.CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Active = true
mainFrame.Draggable = true

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.BorderSizePixel = 0
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Emergency Hamburg - GUI"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18

-- Function to create toggles and sliders
local function createToggle(parent, name, position, default)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Parent = parent
    button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    button.BorderSizePixel = 0
    button.Position = position
    button.Size = UDim2.new(0, 100, 0, 30)
    button.Font = Enum.Font.SourceSans
    button.Text = name .. ": " .. (default and "ON" or "OFF")
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    
    local state = default
    button.MouseButton1Click:Connect(function()
        state = not state
        button.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        button.Text = name .. ": " .. (state and "ON" or "OFF")
    end)
    
    return button, function() return state end
end

local function createSlider(parent, name, position, min, max, default)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = parent
    label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    label.BorderSizePixel = 0
    label.Position = UDim2.new(0, position.X.Offset, 0, position.Y.Offset)
    label.Size = UDim2.new(0, 150, 0, 20)
    label.Font = Enum.Font.SourceSans
    label.Text = name .. ": " .. default
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    
    local slider = Instance.new("TextButton")
    slider.Name = name .. "Slider"
    slider.Parent = parent
    slider.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    slider.BorderSizePixel = 0
    slider.Position = UDim2.new(0, position.X.Offset + 160, 0, position.Y.Offset)
    slider.Size = UDim2.new(0, 100, 0, 20)
    slider.Font = Enum.Font.SourceSans
    slider.Text = ""
    slider.TextColor3 = Color3.fromRGB(255, 255, 255)
    slider.TextSize = 14
    
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Parent = slider
    fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    fill.BorderSizePixel = 0
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    
    local value = default
    local dragging = false
    
    local function updateSlider(input)
        local sliderPos = slider.AbsolutePosition.X
        local sliderSize = slider.AbsoluteSize.X
        local mousePos = input.Position.X
        local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
        value = min + (max - min) * percent
        fill.Size = UDim2.new(percent, 0, 1, 0)
        label.Text = name .. ": " .. math.floor(value)
    end
    
    slider.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return label, function() return value end
end

-- Create UI Elements
local killAuraToggle, getKillAuraState = createToggle(mainFrame, "Kill Aura", UDim2.new(0, 20, 0, 50), false)
local killAuraSlider, getKillAuraRadius = createSlider(mainFrame, "Kill Radius", UDim2.new(0, 20, 0, 90), 10, 200, 50)

local antiCuffToggle, getAntiCuffState = createToggle(mainFrame, "Anti-Cuff", UDim2.new(0, 220, 0, 50), false)

local keepAwayToggle, getKeepAwayState = createToggle(mainFrame, "Keep-Away", UDim2.new(0, 20, 0, 130), false)
local keepAwaySlider, getKeepAwayRadius = createSlider(mainFrame, "Away Radius", UDim2.new(0, 20, 0, 170), 10, 100, 30)

local carBlastToggle, getCarBlastState = createToggle(mainFrame, "Car Blaster", UDim2.new(0, 220, 0, 130), false)
local carBlastSlider, getCarBlastRadius = createSlider(mainFrame, "Blast Radius", UDim2.new(0, 220, 0, 170), 20, 300, 100)

local blastButton = Instance.new("TextButton")
blastButton.Name = "BlastButton"
blastButton.Parent = mainFrame
blastButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
blastButton.BorderSizePixel = 0
blastButton.Position = UDim2.new(0, 220, 0, 210)
blastButton.Size = UDim2.new(0, 160, 0, 40)
blastButton.Font = Enum.Font.SourceSansBold
blastButton.Text = "!!! BIG BANG !!!"
blastButton.TextColor3 = Color3.fromRGB(255, 255, 255)
blastButton.TextSize = 16

-- Core Logic
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local myPos = myRoot.Position

    -- Kill Aura
    if getKillAuraState() then
        local radius = getKillAuraRadius()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                if (targetRoot.Position - myPos).Magnitude <= radius then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        -- Method 1: Set Health to 0 (most common for downing)
                        humanoid.Health = 0
                        -- Method 2: If the game uses a custom down system, try to find a remote event/function
                        -- This is game-specific and may require finding the correct remote.
                        -- Example (replace with actual remote name if found):
                        -- game.ReplicatedStorage.SomeDownEvent:Fire
-- Example (replace with actual remote name if found):
                        -- game.ReplicatedStorage.SomeDownEvent:FireServer(player)
                    end
                end
            end
        end
    end

    -- Anti-Cuff
    if getAntiCuffState() then
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("cuff") or tool.Name:lower():find("handcuff")) then
                tool:Destroy()
            end
        end
        -- This is a more aggressive approach: destroy any tool added to the character
        LocalPlayer.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and (child.Name:lower():find("cuff") or child.Name:lower():find("handcuff")) then
                child:Destroy()
            end
        end)
    end

    -- Keep-Away (Forcefield Push)
    if getKeepAwayState() then
        local radius = getKeepAwayRadius()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                local distance = (targetRoot.Position - myPos).Magnitude
                if distance <= radius and distance > 0 then
                    -- Calculate push direction
                    local pushDirection = (targetRoot.Position - myPos).Unit
                    -- Apply a strong velocity to push them away
                    local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if targetHumanoid and targetHumanoid.RootPart then
                        targetHumanoid.RootPart.Velocity = pushDirection * 100 -- Adjust power as needed
                    end
                end
            end
        end
    end
end)

-- Car Blaster Logic
local function blastCars()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local radius = getCarBlastRadius()

    for _, model in ipairs(workspace:GetDescendants()) do
        -- Check if it's a car model. This is a guess and might need adjustment.
        if model:IsA("Model") and model:FindFirstChild("VehicleSeat") then
            local primaryPart = model.PrimaryPart
            if not primaryPart then
                -- Fallback to the first BasePart found
                for _, part in ipairs(model:GetChildren()) do
                    if part:IsA("BasePart") then
                        primaryPart = part
                        break
                    end
                end
            end
            
            if primaryPart and (primaryPart.Position - myPos).Magnitude <= radius then
                -- Method 1: Set it on fire (if Fire is a valid object in this game's context)
                local fire = Instance.new("Fire")
                fire.Parent = primaryPart
                fire.Size = 15
                fire.Heat = 25
                
                -- Method 2: Apply an explosive force
                local explosion = Instance.new("Explosion")
                explosion.Position = primaryPart.Position
                explosion.BlastRadius = 10 -- Small radius to affect the car itself
                explosion.BlastPressure = 500000 -- High pressure to launch it
                explosion.Parent = workspace
                
                -- Method 3: Break all joints to make it fall apart
                for _, joint in ipairs(model:GetDescendants()) do
                    if joint:IsA("Motor6D") or joint:IsA("Weld") or joint:IsA("WeldConstraint") then
                        joint:Destroy()
                    end
                end
            end
        end
    end
end

-- Connect the Big Bang button
blastButton.MouseButton1Click:Connect(function()
    if getCarBlastState() then
        blastCars()
    end
end)

print("Emergency Hamburg GUI Loaded. Made by Venice.")
