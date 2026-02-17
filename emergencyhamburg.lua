hfffvaoerUxLIYVJrdEyFAZTYdZOYlnn

-- Kill, Freeze, and Shield Auras for Emergency Hamburg by Venice
-- Features: Independent Kill, Freeze, and Shield Auras with separate radii.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Simple GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleKillGUI"
screenGui.Parent = game.CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
mainFrame.BorderSizePixel = 2
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -125)
mainFrame.Size = UDim2.new(0, 220, 0, 250)
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.BorderSizePixel = 0
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Kill, Freeze & Shield"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16

-- Helper function to create a control row
local function createControlRow(parent, yPosition, name, defaultRadius)
    local toggle = Instance.new("TextButton")
    toggle.Parent = parent
    toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    toggle.BorderSizePixel = 0
    toggle.Position = UDim2.new(0, 10, 0, yPosition)
    toggle.Size = UDim2.new(0, 80, 0, 25)
    toggle.Font = Enum.Font.SourceSans
    toggle.Text = name .. ": OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.TextSize = 14

    local radiusLabel = Instance.new("TextLabel")
    radiusLabel.Parent = parent
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Position = UDim2.new(0, 100, 0, yPosition)
    radiusLabel.Size = UDim2.new(0, 50, 0, 25)
    radiusLabel.Font = Enum.Font.SourceSans
    radiusLabel.Text = "Radius:"
    radiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    radiusLabel.TextSize = 14
    radiusLabel.TextXAlignment = Enum.TextXAlignment.Left

    local radiusBox = Instance.new("TextBox")
    radiusBox.Parent = parent
    radiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    radiusBox.BorderSizePixel = 0
    radiusBox.Position = UDim2.new(0, 150, 0, yPosition + 1)
    radiusBox.Size = UDim2.new(0, 50, 0, 23)
    radiusBox.Font = Enum.Font.SourceSans
    radiusBox.Text = tostring(defaultRadius)
    radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    radiusBox.TextSize = 14

    return toggle, radiusBox
end

-- Create UI Elements
local killToggle, killRadiusBox = createControlRow(mainFrame, 40, "Kill", 50)
local freezeToggle, freezeRadiusBox = createControlRow(mainFrame, 80, "Freeze", 30)
local shieldToggle, shieldRadiusBox = createControlRow(mainFrame, 120, "Shield", 20)


-- Logic
local isKillEnabled = false
local isFreezeEnabled = false
local isShieldEnabled = false
local frozenPlayers = {} -- To store original speeds

-- Toggle Connections
killToggle.MouseButton1Click:Connect(function()
    isKillEnabled = not isKillEnabled
    killToggle.BackgroundColor3 = isKillEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    killToggle.Text = "Kill: " .. (isKillEnabled and "ON" or "OFF")
end)

freezeToggle.MouseButton1Click:Connect(function()
    isFreezeEnabled = not isFreezeEnabled
    freezeToggle.BackgroundColor3 = isFreezeEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    freezeToggle.Text = "Freeze: " .. (isFreezeEnabled and "ON" or "OFF")
end)

shieldToggle.MouseButton1Click:Connect(function()
    isShieldEnabled = not isShieldEnabled
    shieldToggle.BackgroundColor3 = isShieldEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    shieldToggle.Text = "Shield: " .. (isShieldEnabled and "ON" or "OFF")
end)


RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if not isKillEnabled and not isFreezeEnabled and not isShieldEnabled then return end

    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local myPos = myRoot.Position
    local killRadius = tonumber(killRadiusBox.Text) or 50
    local freezeRadius = tonumber(freezeRadiusBox.Text) or 30
    local shieldRadius = tonumber(shieldRadiusBox.Text) or 20

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if not humanoid then continue end

            local distance = (targetRoot.Position - myPos).Magnitude

            -- Kill Aura Logic
            if isKillEnabled and distance <= killRadius and humanoid.Health > 0 then
                humanoid.Health = 0
                targetRoot.CFrame = CFrame.new(0, -500, 0)
            end

            -- Freeze Aura Logic
            if isFreezeEnabled and distance <= freezeRadius then
                if not frozenPlayers[player] then
                    frozenPlayers[player] = {
                        walkSpeed = humanoid.WalkSpeed,
                        jumpPower = humanoid.JumpPower
                    }
                end
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
            end

            -- Shield Logic
            if isShieldEnabled and distance <= shieldRadius and distance > 0 then
                local direction = (targetRoot.Position - myPos).Unit
                local pushForce = direction * (shieldRadius - distance + 10) -- Stronger push as they get closer
                targetRoot:ApplyImpulse(pushForce)
            end
        end
    end

    -- Manage frozen players
    if isFreezeEnabled then
        for player, data in pairs(frozenPlayers) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - myPos).Magnitude
                if distance > freezeRadius then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = data.walkSpeed
                        humanoid.JumpPower = data.jumpPower
                    end
                    frozenPlayers[player] = nil
                end
            else
                frozenPlayers[player] = nil
            end
        end
    end

    -- Unfreeze all if toggle is off
    if not isFreezeEnabled then
        for player, data in pairs(frozenPlayers) do
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = data.walkSpeed
                    humanoid.JumpPower = data.jumpPower
                end
            end
        end
        frozenPlayers = {}
    end
end)

print("Kill, Freeze & Shield Auras Loaded.")
