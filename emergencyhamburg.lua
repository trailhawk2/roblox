-- Kill Aura with Freeze for Emergency Hamburg by Venice
-- Features: Kill Aura (Health + Push), Freeze Aura

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
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.BorderSizePixel = 0
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Kill & Freeze Aura"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16

-- Kill Aura Toggle
local killToggle = Instance.new("TextButton")
killToggle.Parent = mainFrame
killToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killToggle.BorderSizePixel = 0
killToggle.Position = UDim2.new(0, 10, 0, 40)
killToggle.Size = UDim2.new(0, 80, 0, 25)
killToggle.Font = Enum.Font.SourceSans
killToggle.Text = "Kill: OFF"
killToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
killToggle.TextSize = 14

-- Freeze Aura Toggle
local freezeToggle = Instance.new("TextButton")
freezeToggle.Parent = mainFrame
freezeToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
freezeToggle.BorderSizePixel = 0
freezeToggle.Position = UDim2.new(0, 100, 0, 40)
freezeToggle.Size = UDim2.new(0, 80, 0, 25)
freezeToggle.Font = Enum.Font.SourceSans
freezeToggle.Text = "Freeze: OFF"
freezeToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
freezeToggle.TextSize = 14

-- Radius Input
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Parent = mainFrame
radiusLabel.BackgroundTransparency = 1
radiusLabel.Position = UDim2.new(0, 10, 0, 75)
radiusLabel.Size = UDim2.new(0, 50, 0, 20)
radiusLabel.Font = Enum.Font.SourceSans
radiusLabel.Text = "Radius:"
radiusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusLabel.TextSize = 14
radiusLabel.TextXAlignment = Enum.TextXAlignment.Left

local radiusBox = Instance.new("TextBox")
radiusBox.Parent = mainFrame
radiusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radiusBox.BorderSizePixel = 0
radiusBox.Position = UDim2.new(0, 60, 0, 73)
radiusBox.Size = UDim2.new(0, 50, 0, 24)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.Text = "50"
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.TextSize = 14

-- Logic
local isKillEnabled = false
local isFreezeEnabled = false
local frozenPlayers = {} -- To store original speeds

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

RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    if not isKillEnabled and not isFreezeEnabled then return end

    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local radius = tonumber(radiusBox.Text) or 50

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local distance = (targetRoot.Position - myPos).Magnitude
            
            if distance <= radius then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if not humanoid then continue end

                -- Kill Aura Logic
                if isKillEnabled and humanoid.Health > 0 then
                    humanoid.Health = 0
                    targetRoot.CFrame = CFrame.new(0, -500, 0)
                end

                -- Freeze Aura Logic
                if isFreezeEnabled then
                    if not frozenPlayers[player] then
                        frozenPlayers[player] = {
                            walkSpeed = humanoid.WalkSpeed,
                            jumpPower = humanoid.JumpPower
                        }
                    end
                    humanoid.WalkSpeed = 0
                    humanoid.JumpPower = 0
                end
            end
        end
    end

    -- Unfreeze players who are out of range if freeze is enabled
    if isFreezeEnabled then
        for player, data in pairs(frozenPlayers) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                local distance = (targetRoot.Position - myPos).Magnitude
                
                if distance > radius then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.WalkSpeed = data.walkSpeed
                        humanoid.JumpPower = data.jumpPower
                    end
                    frozenPlayers[player] = nil
                end
            else
                -- Player left or died, remove from table
                frozenPlayers[player] = nil
            end
        end
    end

    -- If freeze is disabled, unfreeze everyone and clear the table
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

print("Kill & Freeze Aura Loaded.")
