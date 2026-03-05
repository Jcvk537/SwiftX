local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- ========================================== --
-- [[ FUNZIONE PRINCIPALE DELLO SCRIPT ]] --
-- ========================================== --
local function LoadSwiftX()
    local SwiftX = {}

    local Stats = game:GetService("Stats")
    local RunService = game:GetService("RunService")
    local Market = game:GetService("MarketplaceService")

    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- [[ CONFIGURAZIONE ]] --
    local AimbotSettings = {
        Enabled = false,
        Method = "Camera",
        Part = "Head",
        Smoothness = 0.5,
        Prediction = 0.15,
        FOV = 100,
        ShowFOV = false,
        WallCheck = false,
        TeamCheck = false
    }

    local VisualSettings = {
        Box = false,
        Health = false,
        Tracers = false,
        Distance = false,
        Count = false,
        Accent = Color3.fromRGB(0, 170, 255)
    }

    -- [[ DRAWING API CACHE ]] --
    local ESP_Cache = {}

    local function CreateDrawing(type, properties)
        local obj = Drawing.new(type)
        for i, v in pairs(properties) do obj[i] = v end
        return obj
    end

    local function RemoveESP(player)
        if ESP_Cache[player] then
            for _, obj in pairs(ESP_Cache[player]) do
                obj:Remove()
            end
            ESP_Cache[player] = nil
        end
    end

    local function Tween(obj, info, goal)
        local t = TweenService:Create(obj, info, goal)
        t:Play()
        return t
    end

    -- [[ UI UTILS ]] --
    local CountLabel = Instance.new("TextLabel", CoreGui)
    CountLabel.Size = UDim2.fromOffset(200, 30)
    CountLabel.Position = UDim2.new(0.5, -100, 0, 20)
    CountLabel.BackgroundTransparency = 1
    CountLabel.TextColor3 = VisualSettings.Accent
    CountLabel.Font = Enum.Font.GothamBold
    CountLabel.TextSize = 16
    CountLabel.Visible = false
    CountLabel.Text = "Players Visible: 0"
    CountLabel.TextStrokeTransparency = 0

    function SwiftX:CreateWindow(cfg)
        local Accent = VisualSettings.Accent
        local ScreenGui = Instance.new("ScreenGui", CoreGui)
        ScreenGui.Name = "SwiftX_Ultimate"
        ScreenGui.ResetOnSpawn = false

        -- FOV UI
        local FOVFrame = Instance.new("Frame", ScreenGui)
        FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        FOVFrame.BackgroundTransparency = 1
        FOVFrame.Size = UDim2.fromOffset(AimbotSettings.FOV * 2, AimbotSettings.FOV * 2)
        FOVFrame.Visible = false
        local FOVStroke = Instance.new("UIStroke", FOVFrame)
        FOVStroke.Thickness = 2
        FOVStroke.Color = Accent
        Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

        -- MAIN FRAME
        local Main = Instance.new("CanvasGroup", ScreenGui)
        Main.Size = UDim2.fromOffset(580, 400)
        Main.Position = UDim2.new(0.5, -290, 0.5, -200)
        Main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        Main.BorderSizePixel = 0
        Main.GroupTransparency = 0
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
        local MainStroke = Instance.new("UIStroke", Main)
        MainStroke.Color = Accent
        MainStroke.Thickness = 2

        -- [[ FLOATING TOGGLE BUTTON ]] --
        local ToggleBtn = Instance.new("TextButton", ScreenGui)
        ToggleBtn.Size = UDim2.fromOffset(50, 50)
        ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
        ToggleBtn.Text = "SX"
        ToggleBtn.TextColor3 = Accent
        ToggleBtn.Font = Enum.Font.GothamBold
        ToggleBtn.TextSize = 20
        ToggleBtn.AutoButtonColor = false
        Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
        local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
        ToggleStroke.Color = Color3.fromRGB(40, 40, 45)
        ToggleStroke.Thickness = 1.5

        -- TOGGLE LOGIC
        local tDragging, tDragStart, tStartPos
        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                tDragging = true; tDragStart = input.Position; tStartPos = ToggleBtn.Position
                Tween(ToggleBtn, TweenInfo.new(0.1), {Size = UDim2.fromOffset(45, 45)})
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if tDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - tDragStart
                ToggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                tDragging = false
                Tween(ToggleBtn, TweenInfo.new(0.1), {Size = UDim2.fromOffset(50, 50)})
                if (input.Position - tDragStart).Magnitude < 10 then
                    local isVisible = Main.GroupTransparency == 0
                    if isVisible then
                        Tween(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(580, 0), GroupTransparency = 1}).Completed:Connect(function()
                            if Main.GroupTransparency == 1 then Main.Visible = false end
                        end)
                    else
                        Main.Visible = true
                        Tween(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(580, 400), GroupTransparency = 0})
                    end
                end
            end
        end)

        -- SIDEBAR
        local Sidebar = Instance.new("Frame", Main)
        Sidebar.Size = UDim2.new(0, 170, 1, 0)
        Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
        Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

        -- PROFILE HEADER
        local ProfileContainer = Instance.new("Frame", Sidebar)
        ProfileContainer.Size = UDim2.new(1, 0, 0, 80)
        ProfileContainer.Position = UDim2.new(0, 0, 0, 10)
        ProfileContainer.BackgroundTransparency = 1

        local AvatarImg = Instance.new("ImageLabel", ProfileContainer)
        AvatarImg.Size = UDim2.fromOffset(45, 45)
        AvatarImg.Position = UDim2.new(0, 12, 0.5, -22.5)
        AvatarImg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)
        pcall(function() AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
        
        local SwiftText = Instance.new("TextLabel", ProfileContainer)
        SwiftText.Position = UDim2.new(0, 65, 0.5, -18)
        SwiftText.Size = UDim2.new(0, 100, 0, 20)
        SwiftText.Text = "SwiftX"
        SwiftText.TextColor3 = Accent
        SwiftText.Font = Enum.Font.GothamBold
        SwiftText.TextSize = 22
        SwiftText.BackgroundTransparency = 1
        SwiftText.TextXAlignment = "Left"

        local UserWelcome = Instance.new("TextLabel", ProfileContainer)
        UserWelcome.Position = UDim2.new(0, 65, 0.5, 2)
        UserWelcome.Size = UDim2.new(0, 100, 0, 14)
        UserWelcome.Text = "Hi, @" .. LocalPlayer.DisplayName .. "!"
        UserWelcome.TextColor3 = Color3.fromRGB(200, 200, 200)
        UserWelcome.Font = Enum.Font.GothamMedium
        UserWelcome.TextSize = 11
        UserWelcome.BackgroundTransparency = 1
        UserWelcome.TextXAlignment = "Left"

        task.spawn(function()
            while true do
                Tween(SwiftText, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(255, 255, 255)})
                task.wait(1.2)
                Tween(SwiftText, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Accent})
                task.wait(1.2)
            end
        end)

        -- STATS SIDEBAR
        local StatsFolder = Instance.new("Frame", Sidebar)
        StatsFolder.Size = UDim2.new(1, -20, 0, 70)
        StatsFolder.Position = UDim2.new(0, 15, 1, -80)
        StatsFolder.BackgroundTransparency = 1

        local function AddStat(pos)
            local l = Instance.new("TextLabel", StatsFolder)
            l.Size = UDim2.new(1, 0, 0, 18); l.Position = pos; l.BackgroundTransparency = 1
            l.TextColor3 = Color3.fromRGB(120, 120, 125); l.Font = Enum.Font.GothamMedium; l.TextSize = 12; l.TextXAlignment = "Left"
            return l
        end

        local FPSLabel = AddStat(UDim2.new(0, 0, 0, 0))
        local PingLabel = AddStat(UDim2.new(0, 0, 0, 18))
        local TimeLabel = AddStat(UDim2.new(0, 0, 0, 36))

        task.spawn(function()
            while task.wait(0.5) do
                FPSLabel.Text = "FPS: " .. math.floor(workspace:GetRealPhysicsFPS())
                PingLabel.Text = "Ping: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
                TimeLabel.Text = "Time: " .. os.date("%X")
            end
        end)

        -- DRAG LOGIC
        local dragging, dragStart, startPos
        Sidebar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function() dragging = false end)

        local TabScroll = Instance.new("ScrollingFrame", Sidebar)
        TabScroll.Size = UDim2.new(1, 0, 1, -190)
        TabScroll.Position = UDim2.new(0, 0, 0, 95)
        TabScroll.BackgroundTransparency = 1
        TabScroll.ScrollBarThickness = 0
        TabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabScroll.CanvasSize = UDim2.new(0,0,0,0)

        local TabList = Instance.new("UIListLayout", TabScroll)
        TabList.Padding = UDim.new(0, 8)
        TabList.HorizontalAlignment = "Center"

        local Container = Instance.new("Frame", Main)
        Container.Size = UDim2.new(1, -190, 1, -20)
        Container.Position = UDim2.new(0, 185, 0, 10)
        Container.BackgroundTransparency = 1

        local Tabs = {}
        local FirstTab = nil
        local FirstPage = nil

        function Tabs:CreateTab(name)
            local TabBtn = Instance.new("TextButton", TabScroll)
            TabBtn.Size = UDim2.new(0.88, 0, 0, 45)
            TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
            TabBtn.Text = name; TabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
            TabBtn.Font = Enum.Font.GothamBold; TabBtn.TextSize = 18; TabBtn.AutoButtonColor = false
            Instance.new("UICorner", TabBtn)
            local btnStr = Instance.new("UIStroke", TabBtn)
            btnStr.Color = Color3.fromRGB(40, 40, 45); btnStr.Thickness = 1.5

            local Page = Instance.new("ScrollingFrame", Container)
            Page.Size = UDim2.new(1, 0, 1, 0)
            Page.Visible = false
            Page.BackgroundTransparency = 1
            Page.ScrollBarThickness = 0
            Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Page.CanvasSize = UDim2.new(0,0,0,0)
            local PageLayout = Instance.new("UIListLayout", Page)
            PageLayout.Padding = UDim.new(0, 12)

            if not FirstTab then FirstTab = TabBtn FirstPage = Page end

            TabBtn.MouseButton1Click:Connect(function()
                for _, v in pairs(Container:GetChildren()) do v.Visible = false end
                for _, t in pairs(TabScroll:GetChildren()) do 
                    if t:IsA("TextButton") then t.TextColor3 = Color3.fromRGB(160, 160, 160) end 
                end
                Page.Visible = true; TabBtn.TextColor3 = Accent
            end)

            local Elements = {}
            function Elements:CreateToggle(text, callback)
                local Tgl = Instance.new("TextButton", Page)
                Tgl.Size = UDim2.new(0.96, 0, 0, 50)
                Tgl.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Tgl.Text = "   " .. text; Tgl.TextColor3 = Color3.new(1,1,1)
                Tgl.Font = Enum.Font.GothamBold; Tgl.TextSize = 16; Tgl.TextXAlignment = "Left"
                Instance.new("UICorner", Tgl)
                local Box = Instance.new("Frame", Tgl)
                Box.Size = UDim2.fromOffset(40, 20); Box.Position = UDim2.new(1, -55, 0.5, -10); Box.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)
                local Dot = Instance.new("Frame", Box)
                Dot.Size = UDim2.fromOffset(14, 14); Dot.Position = UDim2.fromOffset(3, 3); Dot.BackgroundColor3 = Color3.new(1,1,1)
                Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
                local s = false
                Tgl.MouseButton1Click:Connect(function()
                    s = not s
                    Tween(Box, TweenInfo.new(0.2), {BackgroundColor3 = s and Accent or Color3.fromRGB(40, 40, 45)})
                    Tween(Dot, TweenInfo.new(0.2), {Position = s and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)})
                    callback(s)
                end)
            end

            function Elements:CreateSlider(text, min, max, default, callback)
                local Sld = Instance.new("Frame", Page)
                Sld.Size = UDim2.new(0.96, 0, 0, 65); Sld.BackgroundColor3 = Color3.fromRGB(18, 18, 22); Instance.new("UICorner", Sld)
                local Title = Instance.new("TextLabel", Sld)
                Title.Text = "   " .. text; Title.Size = UDim2.new(1, 0, 0, 30); Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"
                local ValueText = Instance.new("TextLabel", Sld)
                ValueText.Text = tostring(default); ValueText.Size = UDim2.new(0, 50, 0, 30); ValueText.Position = UDim2.new(1, -60, 0, 0); ValueText.TextColor3 = Accent; ValueText.Font = Enum.Font.GothamBold; ValueText.TextSize = 16; ValueText.BackgroundTransparency = 1
                local Bar = Instance.new("Frame", Sld)
                Bar.Size = UDim2.new(0.9, 0, 0, 8); Bar.Position = UDim2.new(0.05, 0, 0.7, 0); Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 45); Instance.new("UICorner", Bar)
                local Fill = Instance.new("Frame", Bar)
                Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Accent; Instance.new("UICorner", Fill)
                
                local function updateS(input)
                    local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + (max - min) * pos)
                    ValueText.Text = tostring(val); callback(val)
                end
                local sliding = false
                Sld.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true updateS(i) end end)
                Sld.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end end)
                UserInputService.InputChanged:Connect(function(i) if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then updateS(i) end end)
            end

            function Elements:CreateButton(text, callback)
                local Btn = Instance.new("TextButton", Page)
                Btn.Size = UDim2.new(0.96, 0, 0, 45)
                Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
                Btn.Text = "  " .. text; Btn.TextColor3 = Color3.new(1,1,1)
                Btn.Font = Enum.Font.GothamBold; Btn.TextSize = 16; Btn.TextXAlignment = "Left"
                Instance.new("UICorner", Btn)
                local btnStr = Instance.new("UIStroke", Btn)
                btnStr.Color = Color3.fromRGB(45, 45, 50); btnStr.Thickness = 1.2
                Btn.MouseButton1Click:Connect(callback)
            end

            function Elements:CreateInfoBox(title, details)
                local Box = Instance.new("Frame", Page)
                Box.Size = UDim2.new(0.96, 0, 0, 100); Box.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Instance.new("UICorner", Box)
                local tt = Instance.new("TextLabel", Box)
                tt.Size = UDim2.new(1, -20, 0, 30); tt.Position = UDim2.fromOffset(10, 5); tt.Text = title:upper(); tt.TextColor3 = Accent; tt.Font = Enum.Font.GothamBold; tt.TextSize = 18; tt.BackgroundTransparency = 1; tt.TextXAlignment = "Left"
                local dd = Instance.new("TextLabel", Box)
                dd.Size = UDim2.new(1, -20, 0, 60); dd.Position = UDim2.fromOffset(10, 35); dd.Text = details; dd.TextColor3 = Color3.new(0.9,0.9,0.9); dd.Font = Enum.Font.GothamMedium; dd.TextSize = 15; dd.BackgroundTransparency = 1; dd.TextXAlignment = "Left"; dd.TextWrapped = true; dd.TextYAlignment = "Top"
                return dd
            end
            return Elements
        end

        function Tabs:OpenFirst() if FirstTab and FirstPage then FirstPage.Visible = true FirstTab.TextColor3 = Accent end end
        return Tabs, FOVFrame
    end

    local Win, FOV = SwiftX:CreateWindow({})

    -- [[ HOME ]]
    local Home = Win:CreateTab("Home")
    Home:CreateInfoBox("User Info", "Logged as: "..LocalPlayer.DisplayName.." (@"..LocalPlayer.Name..")\nUser ID: "..LocalPlayer.UserId)
    Home:CreateInfoBox("Game Info", "Game: "..Market:GetProductInfo(game.PlaceId).Name.."\nPlace ID: "..game.PlaceId)

    local ServerLabel = Home:CreateInfoBox("Server Info", "Loading...")
    task.spawn(function()
        while task.wait(1) do
            local uptime = math.floor(workspace.DistributedGameTime)
            local hours = math.floor(uptime / 3600)
            local mins = math.floor((uptime % 3600) / 60)
            local secs = uptime % 60
            ServerLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers .. "\nUptime: " .. string.format("%02d:%02d:%02d", hours, mins, secs) .. "\nRegion: " .. game:GetService("LocalizationService").RobloxLocaleId
        end
    end)

    -- [[ AIMBOT ]]
    local Aimbot = Win:CreateTab("Aimbot")
    Aimbot:CreateToggle("Enable Aimbot", function(v) AimbotSettings.Enabled = v end)
    Aimbot:CreateToggle("Show FOV Circle", function(v) AimbotSettings.ShowFOV = v end)
    Aimbot:CreateSlider("FOV Radius", 30, 600, 100, function(v) AimbotSettings.FOV = v end)
    Aimbot:CreateSlider("Smoothness", 1, 10, 5, function(v) AimbotSettings.Smoothness = v/10 end)
    Aimbot:CreateSlider("Prediction", 1, 30, 15, function(v) AimbotSettings.Prediction = v/100 end)
    Aimbot:CreateToggle("Team Check", function(v) AimbotSettings.TeamCheck = v end)
    Aimbot:CreateToggle("Wall Check", function(v) AimbotSettings.WallCheck = v end)

    -- [[ VISUAL ]]
    local Visual = Win:CreateTab("Visual")
    Visual:CreateToggle("Esp Box", function(v) VisualSettings.Box = v end)
    Visual:CreateToggle("Esp Health", function(v) VisualSettings.Health = v end)
    Visual:CreateToggle("Esp Tracers", function(v) VisualSettings.Tracers = v end)
    Visual:CreateToggle("Esp Distance", function(v) VisualSettings.Distance = v end)
    Visual:CreateToggle("Esp Count", function(v) VisualSettings.Count = v CountLabel.Visible = v end)

    -- [[ SETTINGS ]]
    local Settings = Win:CreateTab("Settings")
    Settings:CreateButton("Join Discord", function()
        setclipboard("https://discord.gg/sgZGsG93R9")
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "SwiftX", Text = "Link copied to clipboard!", Duration = 3})
    end)
    Settings:CreateButton("Unload Script", function()
        for _, p in pairs(Players:GetPlayers()) do RemoveESP(p) end
        if CoreGui:FindFirstChild("SwiftX_Ultimate") then CoreGui.SwiftX_Ultimate:Destroy() end
        if CountLabel then CountLabel:Destroy() end
        AimbotSettings.Enabled = false
    end)

    Win:OpenFirst()

    -- [[ DRAWING ESP LOGIC ]] --
    local function UpdateESP()
        local visibleCount = 0
        for _, p in pairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            local char = p.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if char and hum and hrp and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local passTeamCheck = not AimbotSettings.TeamCheck or p.Team ~= LocalPlayer.Team

                if onScreen and passTeamCheck then
                    visibleCount = visibleCount + 1
                    if not ESP_Cache[p] then
                        ESP_Cache[p] = {
                            Box = CreateDrawing("Square", {Thickness = 1.5, Color = VisualSettings.Accent, Filled = false}),
                            Tracer = CreateDrawing("Line", {Thickness = 1, Color = VisualSettings.Accent}),
                            Dist = CreateDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
                            HealthBarBG = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.new(0,0,0)}),
                            HealthBar = CreateDrawing("Square", {Thickness = 1, Filled = true, Color = Color3.new(0,1,0)})
                        }
                    end

                    local cache = ESP_Cache[p]
                    local head = char:FindFirstChild("Head")
                    local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height * 0.6
                    
                    cache.Box.Visible = VisualSettings.Box
                    if VisualSettings.Box then
                        cache.Box.Size = Vector2.new(width, height)
                        cache.Box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                    end

                    cache.Tracer.Visible = VisualSettings.Tracers
                    if VisualSettings.Tracers then
                        cache.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        cache.Tracer.To = Vector2.new(pos.X, pos.Y + height/2)
                    end

                    cache.Dist.Visible = VisualSettings.Distance
                    if VisualSettings.Distance then
                        local d = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
                        cache.Dist.Text = "["..d.."m]"
                        cache.Dist.Position = Vector2.new(pos.X, pos.Y + height/2 + 5)
                    end

                    cache.HealthBar.Visible = VisualSettings.Health
                    cache.HealthBarBG.Visible = VisualSettings.Health
                    if VisualSettings.Health then
                        local hp = hum.Health / hum.MaxHealth
                        cache.HealthBarBG.Size = Vector2.new(2, height)
                        cache.HealthBarBG.Position = Vector2.new(pos.X - width/2 - 5, pos.Y - height/2)
                        cache.HealthBar.Size = Vector2.new(2, height * hp)
                        cache.HealthBar.Position = Vector2.new(pos.X - width/2 - 5, pos.Y + height/2 - (height * hp))
                        cache.HealthBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), hp)
                    end
                else
                    if ESP_Cache[p] then for _, v in pairs(ESP_Cache[p]) do v.Visible = false end end
                end
            else
                RemoveESP(p)
            end
        end
        if VisualSettings.Count then CountLabel.Text = "Players Visible: " .. visibleCount end
    end

    Players.PlayerRemoving:Connect(RemoveESP)

    -- [[ MAIN LOOP ]] --
    RunService.RenderStepped:Connect(function()
        if not CoreGui:FindFirstChild("SwiftX_Ultimate") then return end
        FOV.Visible = AimbotSettings.ShowFOV
        FOV.Size = UDim2.fromOffset(AimbotSettings.FOV * 2, AimbotSettings.FOV * 2)
        UpdateESP()

        if AimbotSettings.Enabled then
            local target = nil
            local closestDist = AimbotSettings.FOV
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(AimbotSettings.Part) then
                    local char = p.Character
                    if not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then continue end
                    if AimbotSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local aimPart = char[AimbotSettings.Part]
                    local pos, vis = Camera:WorldToViewportPoint(aimPart.Position)
                    if AimbotSettings.WallCheck and vis then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, char}
                        local res = workspace:Raycast(Camera.CFrame.Position, aimPart.Position - Camera.CFrame.Position, rayParams)
                        if res then vis = false end
                    end
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if mag < closestDist then closestDist = mag target = p end
                    end
                end
            end
            if target then
                local aimPart = target.Character[AimbotSettings.Part]
                local pred = (aimPart.Velocity * AimbotSettings.Prediction) * ((aimPart.Position - Camera.CFrame.Position).Magnitude / 100)
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPart.Position + pred), AimbotSettings.Smoothness)
            end
        end
    end)
end

-- ========================================== --
-- [[ SWIFTX KEY SYSTEM UI & LOGIC ]] --
-- ========================================== --
local AccentColor = Color3.fromRGB(0, 170, 255)
local KeySysGui = Instance.new("ScreenGui", CoreGui)
KeySysGui.Name = "SwiftX_KeySystem"

local KeyFrame = Instance.new("CanvasGroup", KeySysGui)
KeyFrame.Size = UDim2.fromOffset(400, 220)
KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -110)
KeyFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
KeyFrame.GroupTransparency = 1 -- Partenza invisibile per l'animazione
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 12)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Color = AccentColor
KeyStroke.Thickness = 2

-- Entrata Animata
local TweenService = game:GetService("TweenService")
local function TweenObj(obj, info, goal)
    local tween = TweenService:Create(obj, info, goal)
    tween:Play()
    return tween
end
TweenObj(KeyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupTransparency = 0})

local Title = Instance.new("TextLabel", KeyFrame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "SwiftX Key System"
Title.TextColor3 = AccentColor
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24

local Desc = Instance.new("TextLabel", KeyFrame)
Desc.Size = UDim2.new(1, 0, 0, 20)
Desc.Position = UDim2.new(0, 0, 0, 45)
Desc.BackgroundTransparency = 1
Desc.Text = "Join our Discord to get the free key."
Desc.TextColor3 = Color3.fromRGB(150, 150, 150)
Desc.Font = Enum.Font.GothamMedium
Desc.TextSize = 13

local KeyBox = Instance.new("TextBox", KeyFrame)
KeyBox.Size = UDim2.new(0.8, 0, 0, 45)
KeyBox.Position = UDim2.new(0.1, 0, 0.4, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
KeyBox.PlaceholderText = "Enter Key Here..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.new(1, 1, 1)
KeyBox.Font = Enum.Font.GothamMedium
KeyBox.TextSize = 14
Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", KeyBox).Color = Color3.fromRGB(40, 40, 45)

local GetKeyBtn = Instance.new("TextButton", KeyFrame)
GetKeyBtn.Size = UDim2.new(0.38, 0, 0, 40)
GetKeyBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.new(1, 1, 1)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 14
GetKeyBtn.AutoButtonColor = false
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)

local CheckKeyBtn = Instance.new("TextButton", KeyFrame)
CheckKeyBtn.Size = UDim2.new(0.38, 0, 0, 40)
CheckKeyBtn.Position = UDim2.new(0.52, 0, 0.7, 0)
CheckKeyBtn.BackgroundColor3 = AccentColor
CheckKeyBtn.Text = "Check Key"
CheckKeyBtn.TextColor3 = Color3.fromRGB(10, 10, 12)
CheckKeyBtn.Font = Enum.Font.GothamBold
CheckKeyBtn.TextSize = 14
CheckKeyBtn.AutoButtonColor = false
Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 8)

-- Animazioni Hover Bottoni
local function AddHoverAnim(btn, defaultColor, hoverColor)
    btn.MouseEnter:Connect(function() TweenObj(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}) end)
    btn.MouseLeave:Connect(function() TweenObj(btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}) end)
end
AddHoverAnim(GetKeyBtn, Color3.fromRGB(30, 30, 35), Color3.fromRGB(45, 45, 50))
AddHoverAnim(CheckKeyBtn, AccentColor, Color3.fromRGB(0, 200, 255))

-- Logica Get Key
GetKeyBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/sgZGsG93R9")
    GetKeyBtn.Text = "Copied!"
    task.wait(1.5)
    GetKeyBtn.Text = "Get Key"
end)

-- Logica Check Key
CheckKeyBtn.MouseButton1Click:Connect(function()
    if KeyBox.Text == "swiftx-free019e" then
        CheckKeyBtn.Text = "Validating..."
        task.wait(0.5)
        CheckKeyBtn.Text = "Success!"
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        
        -- Dissolvenza e avvio main script
        TweenObj(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {GroupTransparency = 1})
        task.wait(0.5)
        KeySysGui:Destroy()
        LoadSwiftX() -- Esegue il tuo script Aimbot/ESP
    else
        CheckKeyBtn.Text = "Invalid Key!"
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        -- Animazione Shake
        local origPos = KeyFrame.Position
        for i = 1, 4 do
            KeyFrame.Position = origPos + UDim2.new(0, math.random(-5, 5), 0, math.random(-5, 5))
            task.wait(0.05)
        end
        KeyFrame.Position = origPos
        
        task.wait(1)
        CheckKeyBtn.Text = "Check Key"
        CheckKeyBtn.BackgroundColor3 = AccentColor
    end
end)

-- Trascinamento UI (Draggable)
local dragging, dragStart, startPos
KeyFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = KeyFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        KeyFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function() dragging = false end)
