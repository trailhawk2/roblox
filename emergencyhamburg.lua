-- Emergency Hamburg Script by Venice (Updated v2)
-- Features: Down & Freeze Aura, Anti-Cuff, Keep-Away
-- For use with Delta Executor or similar

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

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
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
mainFrame.Size = UDim2.new(0, 300, 0, 250)
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

-- Function to create toggles
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

-- Function to create text boxes for radius
local function createRadiusInput(parent, name, position, default)
    local label = Instance.new("TextLabel")
    label.Name = name .. "Label"
    label.Parent = parent
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = UDim2.new(0, 80, 0, 20)
    label.Font = Enum.Font.SourceSans
    label.Text = name .. ":"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local textBox = Instance.new("TextBox")
    textBox.Name = name .. "Box"
    textBox.Parent = parent
    textBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    textBox.BorderSizePixel = 0
    textBox.Position = UDim2.new(0, position.X.Offset + 85, 0, position.Y.Offset - 2)
    textBox.Size = UDim2.new(0, 50, 0, 24)
    textBox.Font = Enum.Font.SourceSans
    textBox.PlaceholderText = tostring(default)
    textBox.Text = ""
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14

    local function getValue()
        local val = tonumber(textBox.Text)
        if val then
            return val
        else
            -- Return default if text is not a number
            return default
        end
    end

    return label, textBox, getValue
end

-- Create UI Elements
local downFreezeToggle, getDownFreezeState = createToggle(mainFrame, "Down & Freeze", UDim2.new(0, 20, 0, 50), false)
local downFreezeRadiusBox = createRadiusInput(mainFrame, "Radius", UDim2.new(0, 20, 0, 90), 50)

local antiCuffToggle, getAntiCuffState = createToggle(mainFrame, "Anti-Cuff", UDim2.new(0, 160, 0, 50), false)

local keepAwayToggle, getKeepAwayState = createToggle(mainFrame, "Keep-Away", UDim2.new(0, 20, 0, 130), false)
local keepAwayRadiusBox = createRadiusInput(mainFrame, "Radius", UDim2.new(0, 20, 0, 170), 30)

-- Table to keep track of frozen players to restore their speed later
local frozenPlayers = {}

-- Core Logic
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot = LocalPlayer.Character.HumanoidRootPart
    local myPos = myRoot.Position

    -- Down & Freeze Aura
    if getDownFreezeState() then
        local radius = downFreezeRadiusBox()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                if (targetRoot.Position - myPos).Magnitude <= radius then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        -- Down the player
                        humanoid.Health = 0
                        -- Freeze them immediately after downing
                        humanoid.WalkSpeed = 0
                        humanoid.JumpPower = 0
                        -- Add to frozen list to manage them
                        if not frozenPlayers[player] then
                            frozenPlayers[player] = true
                        end
                    end
                end
            end
        end
    else
        -- If the toggle is OFF, unfreeze everyone we previously froze
        for player, _ in pairs(frozenPlayers) do
            if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                -- Only restore if they are still downed (health is 0)
                if humanoid.Health == 0 then
                    humanoid.WalkSpeed = 0 -- Keep them frozen while downed
                    humanoid.JumpPower = 0
                else
                    -- If they are revived, restore normal movement
                    humanoid.WalkSpeed = 16 -- Default walk speed
                    humanoid.JumpPower = 50 -- Default jump power
                end
            end
        end
        -- We don't clear the table here in case they are re-downed
    end

    -- Clean up the frozen list for players who have been revived
    for player, _ in pairs(frozenPlayers) do
        if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid.Health > 0 then
                -- They are alive, so remove them from the list
                frozenPlayers[player] = nil
            end
        else
            -- Character no longer exists, remove from list
            frozenPlayers[player] = nil
        end
    end

    -- Anti-Cuff (Improved)
    if getAntiCuffState() then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("cuff") or tool.Name:lower():find("handcuff")) then
                tool:Destroy()
            end
        end
    end

    -- Keep-Away (Forcefield Push)
    if getKeepAwayState() then
        local radius = keepAwayRadiusBox()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = player.Character.HumanoidRootPart
                local distance = (targetRoot.Position - myPos).Magnitude
                local distance = (targetRoot.Position - myPos).Magnitude
                if distance <= radius and distance > 0 then
                    local pushDirection = (targetRoot.Position - myPos).Unit
                    local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if targetHumanoid and targetHumanoid.RootPart then
                        targetHumanoid.RootPart.Velocity = pushDirection * 100
                    end
                end
            end
        end
    end
end)

print("Updated Emergency Hamburg GUI v2 Loaded. Made by Venice.")
