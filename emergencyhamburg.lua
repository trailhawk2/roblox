-- Kill Aura with Health Downing for Emergency Hamburg by Venice
-- Kills players by teleporting them below the map AND setting their health to 0.

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
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Active = true
mainFrame.Draggable = true

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = mainFrame
titleLabel.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.BorderSizePixel = 0
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "Kill Aura v2"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16

-- Kill Toggle
local killToggle = Instance.new("TextButton")
killToggle.Parent = mainFrame
killToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
killToggle.BorderSizePixel = 0
killToggle.Position = UDim2.new(0, 10, 0, 40)
killToggle.Size = UDim2.new(0, 80, 0, 25)
killToggle.Font = Enum.Font.SourceSans
killToggle.Text = "OFF"
killToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
killToggle.TextSize = 14

-- Radius Input
local radiusLabel = Instance.new("TextLabel")
radiusLabel.Parent = mainFrame
radiusLabel.BackgroundTransparency = 1
radiusLabel.Position = UDim2.new(0, 10, 0, 70)
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
radiusBox.Position = UDim2.new(0, 60, 0, 68)
radiusBox.Size = UDim2.new(0, 50, 0, 24)
radiusBox.Font = Enum.Font.SourceSans
radiusBox.Text = "50"
radiusBox.TextColor3 = Color3.fromRGB(255, 255, 255)
radiusBox.TextSize = 14

-- Logic
local isEnabled = false

killToggle.MouseButton1Click:Connect(function()
    isEnabled = not isEnabled
    killToggle.BackgroundColor3 = isEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    killToggle.Text = isEnabled and "ON" or "OFF"
end)

RunService.Heartbeat:Connect(function()
    if not isEnabled then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local radius = tonumber(radiusBox.Text) or 50

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            if (targetRoot.Position - myPos).Magnitude <= radius then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                
                -- Dual Action: Set health to 0 AND teleport them
                if humanoid then
                    humanoid.Health = 0
                end
                targetRoot.CFrame = CFrame.new(0, -500, 0)
            end
        end
    end
end)

print("Kill Aura v2 (Health + Push) Loaded.")
