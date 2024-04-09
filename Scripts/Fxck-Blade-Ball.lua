local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
InterfaceManager.Settings = {
    Theme = "Amethyst",
    Acrylic = true,
    Transparency = true,
    MenuKeybind = "RightControl"
}
local Window = Fluent:CreateWindow({
    Title = "Blade Ball",
    SubTitle = "by ig kiryowasdie",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Amethyst",
    MinimizeKey = Enum.KeyCode.RightControl
})
local Tabs = {
    Main = Window:AddTab({ Title = "General", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    local AutoParry = Tabs.Main:AddToggle("AutoParry", {Title = "Auto Parry", Default = false })
    local PingBased = Tabs.Main:AddToggle("PingBased", {Title = "Ping Based", Default = true })
    local BallSpeedCheck = Tabs.Main:AddToggle("BallSpeedCheck", {Title = "Ball Speed Check", Default = true })
    
    local Slider = Tabs.Main:AddSlider("DistanceToParry", {
        Title = "Distance To Parry",
        Description = "Distance To Parry",
        Default = 0.3,
        Min = 0,
        Max = 2,
        Rounding = 1,
        Callback = function(Value)
            _G.DistanceToParry = Value
        end
    })

    Slider:SetValue(0.3)

    Tabs.Main:AddButton({
        Title = "Rank FFA",
        Description = "Rank FFA",
        Callback = function()
            Window:Dialog({
                Title = "Choose Start or Cacel",
                Content = "???",
                Buttons = {
                    {
                        Title = "Start",
                        Callback = function()
                            game:GetService("ReplicatedStorage").Remotes.JoinQueue:FireServer("FFA", "Normal")                            
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            Fluent:Notify({
                                Title = "Kiryowasdie",
                                Content = "Ok",
                                Duration = 8
                            })                            
                            game:GetService("ReplicatedStorage").Remotes.LeaveQueue:FireServer("FFA")                            
                        end
                    }
                }
            })
        end
    })

end


SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("Kiryowasdie")
SaveManager:SetFolder("Kiryowasdie/blade-ball")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

local Player = game:GetService("Players").LocalPlayer or game:GetService("Players").PlayerAdded:Wait()

local Paws = game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9)
local PawsBalls = workspace:WaitForChild("Balls", 9e9)
local PawsTable = getgenv().Paws

local function IsTheTarget()
    return Player.Character:FindFirstChild("Highlight")
end

local function FindBall()
    local RealBall
    for i, v in pairs(PawsBalls:GetChildren()) do
        if v:GetAttribute("realBall") == true then
            RealBall = v
        end
    end
    return RealBall
end

spawn(function()
    game:GetService("RunService").Stepped:connect(function()
        if not FindBall() then 
            return
        end
        local Ball = FindBall()
    
        local BallPosition = Ball.Position
    
        local BallVelocity = Ball.AssemblyLinearVelocity.Magnitude
    
        local Distance = Player:DistanceFromCharacter(BallPosition)
    
        local Ping = BallVelocity * (game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000)
    
        if Options.PingBased.Value then
            Distance -= Ping + 0
        end
    
        if Options.BallSpeedCheck.Value and BallVelocity == 0 then return end
    
        if (Distance / BallVelocity) <= _G.DistanceToParry and IsTheTarget() and Options.AutoParry.Value then
            for i,v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui.Hotbar.Block.Activated)) do
                v.Function()
            end
        end
    end)
end)
spawn(function()
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)
Window:SelectTab(1)

Fluent:Notify({
    Title = "Kiryowasdie",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
