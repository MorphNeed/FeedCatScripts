--[[
Feed The Cat GUI Script v2
Tema: Makanan Kucing 🐱
Desain: Mirip GUI Goomba Hub
Kompatibel: 100% Delta Mobile
]]

-- === UI Library Setup ===
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "🐾 Feed The Cat GUI",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FeedCatConfig"
})

-- === Default Settings ===
getgenv().AutoInvite = true
getgenv().AutoThank = true
getgenv().ChatInterval = 35
getgenv().InviteMessages = {
    "Help feed my virtual cat 🐱 1 Robux = 1 cat snack!",
    "Stop by my booth to support my hungry pixel cat 🐟",
    "Every Robux helps! Drop by if you care about cats 😸"
}
getgenv().ThankYouMessages = {
    "Thanks {user}! My cat just had a snack 🐾",
    "{user} fed my cat! You're amazing 🐟",
    "Appreciate it {user}! Meow~ 😻"
}

-- === Chat Function ===
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local function safeChat(msg)
    pcall(function()
        game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
    end)
end

-- === Main Tab ===
local MainTab = Window:MakeTab({Name = "Main", Icon = "rbxassetid://7734053494", PremiumOnly = false})

MainTab:AddToggle({
    Name = "Auto Invite (Promote Booth)",
    Default = getgenv().AutoInvite,
    Callback = function(v) getgenv().AutoInvite = v end
})

MainTab:AddToggle({
    Name = "Auto Thank Donators",
    Default = getgenv().AutoThank,
    Callback = function(v) getgenv().AutoThank = v end
})

MainTab:AddSlider({
    Name = "Chat Delay (Seconds)",
    Min = 10,
    Max = 120,
    Default = getgenv().ChatInterval,
    Increment = 5,
    ValueName = "s",
    Callback = function(v) getgenv().ChatInterval = v end
})

-- === Text Tab ===
local TextTab = Window:MakeTab({Name = "Text Settings", Icon = "rbxassetid://7733960981", PremiumOnly = false})

TextTab:AddTextbox({
    Name = "Add Invite Message",
    Default = "",
    TextDisappear = true,
    Callback = function(txt)
        table.insert(getgenv().InviteMessages, txt)
    end
})

TextTab:AddTextbox({
    Name = "Add Thank You Message (use {user})",
    Default = "",
    TextDisappear = true,
    Callback = function(txt)
        table.insert(getgenv().ThankYouMessages, txt)
    end
})

-- === Misc Tab ===
local MiscTab = Window:MakeTab({Name = "Misc", Icon = "rbxassetid://7733658505", PremiumOnly = false})

MiscTab:AddButton({
    Name = "Send Test Chat",
    Callback = function() safeChat("Test: Feed the cat 🐱") end
})

MiscTab:AddButton({
    Name = "Reset GUI Position",
    Callback = function() OrionLib:Destroy() end
})

-- === Invite Chat Loop ===
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoInvite then
            local msg = getgenv().InviteMessages[math.random(1, #getgenv().InviteMessages)]
            safeChat(msg)
            wait(getgenv().ChatInterval)
        end
    end
end)

-- === Donation Monitor ===
local function monitorBooth()
    local booth
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Owner") and tostring(v.Owner.Value) == LP.Name then
            booth = v
            break
        end
    end
    if not booth then return end

    local oldRaised = 0
    if booth:FindFirstChild("Raised") then
        oldRaised = tonumber(booth.Raised.Value) or 0
    end

    booth.Raised.Changed:Connect(function()
        local newVal = tonumber(booth.Raised.Value) or 0
        if newVal > oldRaised and getgenv().AutoThank then
            local donor = "Someone"
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LP and plr:DistanceFromCharacter(LP.Character.HumanoidRootPart.Position) < 15 then
                    donor = plr.Name break
                end
            end
            local msg = getgenv().ThankYouMessages[math.random(1, #getgenv().ThankYouMessages)]
            safeChat(msg:gsub("{user}", donor))
        end
        oldRaised = newVal
    end)
end

task.delay(5, function()
    pcall(monitorBooth)
end)

OrionLib:Init()
