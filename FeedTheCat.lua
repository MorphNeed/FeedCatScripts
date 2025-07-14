-- Feed the Cat – Pls Donate Script (ULTIMATE PRO VERSION) – FIXED
getgenv().catFeedEnabled = true
getgenv().showGUI = true
getgenv().showRaised = true
getgenv().boothTextEnabled = true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local catFeedEnabled = getgenv().catFeedEnabled
local lastDonation, totalRaised = 0, 0
local boothFound = false
local raisedGUI = nil

local donationChat = { "She’s still waiting for her meal 🐾", "One pass = one full bowl 🍽️", "Feeding just one cat can mean a lot 🐱", "Your kindness fills her bowl 🦡", "Not every paw gets to eat... but you can change that 🐾", "Help her eat today. That’s all 🐿" }
local attractChat = { "Feel free to stop by 🐾 I made something warm for you", "You’re welcome to visit my little booth 🐱", "Passing by? Take a look — she’s waiting 💖", "Just here sharing kindness today. Come say hi! 🐾" }
local thankChat     = { "Thank you so much! That meal means a lot 🐾", "Truly grateful — she can eat today thanks to you! 🦡", "You just made her day better. Thank you! 🐱", "Kindness like yours keeps her fed. Thanks! 💖" }
local boothMessages = { "Help her eat today 🍽️", "Support her next meal 🐾", "One pass = one warm bowl 💖", "Every R$ fills her dish 🐱" }
local emotes = { "507770239", "507770677", "507770818" }

local function safeChar()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function say(msg)
    local chat = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest")
    if chat then chat:FireServer(msg, "All") end
end

local function playEmote()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if hum then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            if track.IsPlaying then return end
        end
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. emotes[math.random(1, #emotes)]
        hum:LoadAnimation(anim):Play()
    end
end

local function stopEmotesOnMove()
    while catFeedEnabled do
        task.wait(0.5)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum and hum.MoveDirection.Magnitude > 0 then
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
end

local function moveToBooth()
    for i = 1, 10 do
        for _, booth in ipairs(workspace:GetDescendants()) do
            if booth:IsA("Model") and booth:FindFirstChild("Owner") and booth.Owner:IsA("StringValue") and booth.Owner.Value == LocalPlayer.Name then
                local boothPart = booth:FindFirstChild("Booth")
                local root = safeChar()
                if boothPart and boothPart:IsA("BasePart") and root then
                    boothFound = true
                    if (root.Position - boothPart.Position).Magnitude > 5 then
                        root.CFrame = boothPart.CFrame + boothPart.CFrame.LookVector * -3 + Vector3.new(0, 2.5, 0)
                    end
                    return booth
                end
            end
        end
        task.wait(2)
    end
    warn("Booth not found or not claimed.")
    return nil
end

local function setBoothText(booth)
    if booth and booth:FindFirstChild("Sign") then
        local sign = booth.Sign
        if sign:IsA("MeshPart") and sign:FindFirstChild("SurfaceGui") then
            local textLabel = sign.SurfaceGui:FindFirstChildWhichIsA("TextLabel")
            if textLabel then
                textLabel.Text = boothMessages[math.random(1, #boothMessages)]
            end
        end
    end
end

local function trackRaised()
    local success, err = pcall(function()
        local stat = LocalPlayer:WaitForChild("leaderstats"):WaitForChild("Raised")
        lastDonation = tonumber(stat.Value) or 0
        totalRaised = lastDonation
        stat:GetPropertyChangedSignal("Value"):Connect(function()
            local newVal = tonumber(stat.Value) or 0
            local gained = newVal - lastDonation
            if gained > 0 then
                lastDonation = newVal
                totalRaised = totalRaised + gained
                say(thankChat[math.random(1, #thankChat)])
                say("+" .. tostring(gained) .. " R$ received. Thank you!")
                if getgenv().showRaised and raisedGUI then
                    raisedGUI.Text = "Raised: " .. tostring(totalRaised) .. " R$"
                end
            end
        end)
    end)
    if not success then warn("Failed to track donations", err) end
end

local function someoneNearby()
    local root = safeChar()
    if not root then return false end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (p.Character.HumanoidRootPart.Position - root.Position).Magnitude < 10 then
                return true
            end
        end
    end
    return false
end

-- GUI SETUP
if game.CoreGui:FindFirstChild("CatFeedControls") then
    game.CoreGui.CatFeedControls:Destroy()
end

if getgenv().showGUI then
    local screen = Instance.new("ScreenGui", game.CoreGui)
    screen.Name = "CatFeedControls"

    local toggle = Instance.new("TextButton", screen)
    toggle.Size = UDim2.new(0, 120, 0, 35)
    toggle.Position = UDim2.new(0, 10, 0, 10)
    toggle.Text = "AutoChat: ON"
    toggle.BackgroundColor3 = Color3.fromRGB(255, 200, 150)
    toggle.TextColor3 = Color3.new(0, 0, 0)
    toggle.MouseButton1Click:Connect(function()
        catFeedEnabled = not catFeedEnabled
        toggle.Text = "AutoChat: " .. (catFeedEnabled and "ON" or "OFF")
        if raisedGUI then raisedGUI.Visible = catFeedEnabled end
    end)

    local closeBtn = Instance.new("TextButton", screen)
    closeBtn.Size = UDim2.new(0, 30
