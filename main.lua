local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Teams = game:GetService("Teams")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Workspace = workspace
local UserInputService = game:GetService("UserInputService")

local ESP_UPDATE_INTERVAL = 0.08
local AIMBOT_UPDATE_INTERVAL = 0.03
local RAY_INTERVAL = 0.12
local espTick = 0
local aimTick = 0
local rayTick = 0
local cachedTargets = {}
local visibilityCache = {}

local PlayerCache = {}

local State = {
    AimbotEnabled = false,
    LockTeammates = true,
    DisableWallLock = true,
    AimbotFOV = 50,
    AimbotTargetPart = "Head",
    ShowFOV = true,
    ESP = {
        BoxESP = false,
        OutlineESP = false,
        NameESP = false,
        DistanceESP = false,
        ESPTeammates = false
    },
    FlyEnabled = false,
    FlySpeed = 50,
    NoClip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    SelectedPlayer = nil,
    ReturnPosition = nil
}

local Theme = {
    Primary    = Color3.fromHex("#DC2626"),
    DeepRed    = Color3.fromHex("#991B1B"),
    BrightRed  = Color3.fromHex("#EF4444"),
    SoftRed    = Color3.fromHex("#FCA5A5"),
    Background = Color3.fromRGB(250, 250, 252),
    Card       = Color3.fromRGB(255, 255, 255),
    CardHover  = Color3.fromRGB(254, 242, 242),
    Text       = Color3.fromRGB(60, 15, 15),
    Muted      = Color3.fromHex("#B07070"),
    White      = Color3.fromRGB(255, 255, 255),
    TrackOff   = Color3.fromRGB(240, 220, 220),
    Error      = Color3.fromHex("#7F1D1D"),
}

local Messages = {
    "Connecting to Kai Scripts...",
    "Loading modules...",
    "Preparing interface...",
    "Almost there...",
}

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KaiScriptsLoader"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = CoreGui

local container = Instance.new("Frame")
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.Size = UDim2.new(0, 0, 0, 0)
container.BackgroundColor3 = Theme.Background
container.BorderSizePixel = 0
container.Parent = screenGui
Instance.new("UICorner", container).CornerRadius = UDim.new(0, 18)

local grad = Instance.new("UIGradient", container)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 240, 240)),
    ColorSequenceKeypoint.new(1, Theme.SoftRed),
})
grad.Rotation = 135

local stroke = Instance.new("UIStroke", container)
stroke.Color = Theme.Primary
stroke.Thickness = 2.2
stroke.Transparency = 0.05

local glow = Instance.new("UIStroke", container)
glow.Color = Theme.SoftRed
glow.Thickness = 10
glow.Transparency = 1
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local logoShell = Instance.new("Frame", container)
logoShell.AnchorPoint = Vector2.new(0.5, 0)
logoShell.Position = UDim2.new(0.5, 0, 0, 28)
logoShell.Size = UDim2.new(0, 64, 0, 64)
logoShell.BackgroundColor3 = Theme.White
logoShell.BorderSizePixel = 0
Instance.new("UICorner", logoShell).CornerRadius = UDim.new(0, 16)

local shellGrad = Instance.new("UIGradient", logoShell)
shellGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.White),
    ColorSequenceKeypoint.new(1, Theme.SoftRed),
})
shellGrad.Rotation = 90

local shellStroke = Instance.new("UIStroke", logoShell)
shellStroke.Color = Theme.Primary
shellStroke.Thickness = 1.8
shellStroke.Transparency = 0.15

local logo = Instance.new("ImageLabel", logoShell)
logo.Size = UDim2.new(0.85, 0, 0.85, 0)
logo.Position = UDim2.new(0.075, 0, 0.075, 0)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://122390204298899"
logo.ScaleType = Enum.ScaleType.Fit
logo.Parent = logoShell
Instance.new("UICorner", logo).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", container)
title.Size = UDim2.new(1, -40, 0, 32)
title.Position = UDim2.new(0, 20, 0, 100)
title.BackgroundTransparency = 1
title.Text = "Kai Scripts"
title.TextColor3 = Theme.Text
title.TextSize = 24
title.Font = Enum.Font.GothamBlack

local subtitle = Instance.new("TextLabel", container)
subtitle.Size = UDim2.new(1, -40, 0, 18)
subtitle.Position = UDim2.new(0, 20, 0, 132)
subtitle.BackgroundTransparency = 1
subtitle.Text = "by kaixns"
subtitle.TextColor3 = Theme.Muted
subtitle.TextSize = 13
subtitle.Font = Enum.Font.Gotham

local barBg = Instance.new("Frame", container)
barBg.Size = UDim2.new(1, -60, 0, 6)
barBg.Position = UDim2.new(0, 30, 0, 168)
barBg.BackgroundColor3 = Theme.TrackOff
barBg.BorderSizePixel = 0
barBg.ClipsDescendants = true
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Theme.Primary
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local barGrad = Instance.new("UIGradient", barFill)
barGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.SoftRed),
    ColorSequenceKeypoint.new(0.5, Theme.Primary),
    ColorSequenceKeypoint.new(1, Theme.DeepRed),
})

local shine = Instance.new("Frame", barFill)
shine.Size = UDim2.new(0.3, 0, 1, 0)
shine.Position = UDim2.new(-0.3, 0, 0, 0)
shine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
shine.BackgroundTransparency = 0.5
shine.BorderSizePixel = 0

local statusText = Instance.new("TextLabel", container)
statusText.Size = UDim2.new(1, -40, 0, 18)
statusText.Position = UDim2.new(0, 20, 0, 190)
statusText.BackgroundTransparency = 1
statusText.Text = Messages[1]
statusText.TextColor3 = Theme.Muted
statusText.TextSize = 12
statusText.Font = Enum.Font.Code

local percentText = Instance.new("TextLabel", container)
percentText.Size = UDim2.new(1, -40, 0, 18)
percentText.Position = UDim2.new(0, 20, 0, 210)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.TextColor3 = Theme.DeepRed
percentText.TextSize = 14
percentText.Font = Enum.Font.GothamBold
percentText.TextTransparency = 1

for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") and c ~= percentText then c.TextTransparency = 1
    elseif c:IsA("Frame") and c ~= barFill and c ~= shine then c.BackgroundTransparency = 1
    elseif c:IsA("UIStroke") then c.Transparency = 1 end
end

local shineRunning = true
task.spawn(function()
    while shineRunning do
        shine.Position = UDim2.new(-0.3, 0, 0, 0)
        TweenService:Create(shine, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(1.3, 0, 0, 0) }):Play()
        task.wait(1.2)
    end
end)

TweenService:Create(blur, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Size = 16 }):Play()
local intro = TweenService:Create(container, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 380, 0, 250) })
intro:Play()
intro.Completed:Wait()

for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
    elseif c:IsA("Frame") and c ~= shine then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
    elseif c:IsA("UIStroke") and c ~= glow then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.15 }):Play()
    end
    task.wait(0.015)
end

TweenService:Create(shine, TweenInfo.new(0.5), { BackgroundTransparency = 0.5 }):Play()

local currentProgress = 0
for i, msg in ipairs(Messages) do
    local textOut = TweenService:Create(statusText, TweenInfo.new(0.15), { TextTransparency = 1 })
    textOut:Play()
    textOut.Completed:Wait()
    statusText.Text = msg
    TweenService:Create(statusText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
    local targetProgress = ({0.25, 0.50, 0.75, 1.00})[i]
    local duration = 0.4
    local startProgress = currentProgress
    local stepAmount = targetProgress - startProgress
    for t = 0, 1, 0.02 do
        local eased = t * t * (3 - 2 * t)
        local progress = startProgress + (stepAmount * eased)
        barFill.Size = UDim2.new(progress, 0, 1, 0)
        percentText.Text = string.format("%.0f%%", progress * 100)
        task.wait(duration / 50)
    end
    currentProgress = targetProgress
    task.wait(0.15)
end

barFill.Size = UDim2.new(1, 0, 1, 0)
percentText.Text = "100%"
statusText.Text = "Complete!"
TweenService:Create(glow, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.5 }):Play()
task.wait(0.35)
shineRunning = false

TweenService:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Size = 0 }):Play()
local outro = TweenService:Create(container, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
    elseif c:IsA("Frame") then TweenService:Create(c, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
    elseif c:IsA("UIStroke") then TweenService:Create(c, TweenInfo.new(0.3), { Transparency = 1 }):Play() end
end
outro:Play()
outro.Completed:Wait()
screenGui:Destroy()

local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Theme.Primary
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Visible = true
end)

local function isTeammate(p)
    return LocalPlayer.Team and p.Team == LocalPlayer.Team
end

local function isVisible(part)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local r = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
    return r and r.Instance:IsDescendantOf(part.Parent)
end

local function getESPColor(p)
    if #Teams:GetChildren() > 0 and p.TeamColor then
        return p.TeamColor.Color
    end
    return Theme.Primary
end

local function getDistance(pos1, pos2)
    return math.floor((pos1 - pos2).Magnitude)
end

local Gui = Instance.new("ScreenGui", CoreGui)
Gui.Name = "KaiScripts_GUI"
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.new(0, 480, 0, 340)
Main.Position = UDim2.new(0.5, -240, 0.5, -170)
Main.BackgroundColor3 = Theme.Background
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local mainGrad = Instance.new("UIGradient", Main)
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 245, 245)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 230, 230)),
})
mainGrad.Rotation = 135

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Theme.Primary
mainStroke.Thickness = 1.8
mainStroke.Transparency = 0.1

local mainGlow = Instance.new("UIStroke", Main)
mainGlow.Color = Theme.SoftRed
mainGlow.Thickness = 6
mainGlow.Transparency = 0.75
mainGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Theme.Card
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 16)

local headerGrad = Instance.new("UIGradient", Header)
headerGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 235)),
})
headerGrad.Rotation = 90

local headerAccent = Instance.new("Frame", Header)
headerAccent.Size = UDim2.new(1, 0, 0, 2)
headerAccent.Position = UDim2.new(0, 0, 1, -2)
headerAccent.BackgroundColor3 = Theme.Primary
headerAccent.BorderSizePixel = 0
headerAccent.ZIndex = 3

local headerAccentGrad = Instance.new("UIGradient", headerAccent)
headerAccentGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.SoftRed),
    ColorSequenceKeypoint.new(0.5, Theme.Primary),
    ColorSequenceKeypoint.new(1, Theme.DeepRed),
})

local HeaderLogo = Instance.new("ImageLabel", Header)
HeaderLogo.Size = UDim2.new(0, 30, 0, 30)
HeaderLogo.Position = UDim2.new(0, 12, 0.5, -15)
HeaderLogo.BackgroundTransparency = 1
HeaderLogo.Image = "rbxassetid://122390204298899"
HeaderLogo.ScaleType = Enum.ScaleType.Fit
HeaderLogo.Parent = Header
Instance.new("UICorner", HeaderLogo).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(0, 240, 0, 22)
Title.Position = UDim2.new(0, 50, 0.5, -20)
Title.BackgroundTransparency = 1
Title.Text = "Kai Scripts"
Title.TextColor3 = Theme.DeepRed
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel", Header)
Subtitle.Size = UDim2.new(0, 240, 0, 12)
Subtitle.Position = UDim2.new(0, 50, 0.5, 2)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "by kaixns  ·  v1.0"
Subtitle.TextColor3 = Theme.Muted
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local MinBtn = Instance.new("TextButton", Header)
MinBtn.Size = UDim2.new(0, 26, 0, 26)
MinBtn.Position = UDim2.new(1, -60, 0.5, -13)
MinBtn.Text = "−"
MinBtn.BackgroundColor3 = Theme.CardHover
MinBtn.TextColor3 = Theme.DeepRed
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.AutoButtonColor = false
MinBtn.Parent = Header
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 7)

local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = Theme.SoftRed
MinStroke.Thickness = 1
MinStroke.Transparency = 0.4

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -13)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Theme.Primary
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 7)

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -24, 0, 32)
TabBar.Position = UDim2.new(0, 12, 0, 60)
TabBar.BackgroundColor3 = Theme.Card
TabBar.BackgroundTransparency = 0.3
TabBar.BorderSizePixel = 0
TabBar.Parent = Main
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

local TabBarStroke = Instance.new("UIStroke", TabBar)
TabBarStroke.Color = Theme.SoftRed
TabBarStroke.Thickness = 1
TabBarStroke.Transparency = 0.4

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -24, 1, -110)
Content.Position = UDim2.new(0, 12, 0, 100)
Content.BackgroundTransparency = 1
Content.Parent = Main

local function makePage(name)
    local page = Instance.new("ScrollingFrame", Content)
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Primary
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    return page
end

local AimbotPage = makePage("Aimbot")
local ESPPage = makePage("ESP")
local MovementPage = makePage("Movement")

local Pages = {
    Aimbot = AimbotPage,
    ESP = ESPPage,
    Movement = MovementPage,
}

local TabButtons = {}
local activeTab = nil

local function switchTab(name)
    if activeTab == name then return end
    for key, btn in pairs(TabButtons) do
        if key == name then
            TweenService:Create(btn.bg, TweenInfo.new(0.2), { BackgroundTransparency = 0 }):Play()
            TweenService:Create(btn.label, TweenInfo.new(0.2), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        else
            TweenService:Create(btn.bg, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
            TweenService:Create(btn.label, TweenInfo.new(0.2), { TextColor3 = Theme.DeepRed }):Play()
        end
    end
    for key, page in pairs(Pages) do
        page.Visible = (key == name)
    end
    activeTab = name
end

local TabOrder = { "Aimbot", "ESP", "Movement" }
local tabCount = #TabOrder
local tabWidth = 1 / tabCount
for i, name in ipairs(TabOrder) do
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(tabWidth, -4, 1, -8)
    btn.Position = UDim2.new((i - 1) * tabWidth, 2, 0, 4)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = TabBar

    local bg = Instance.new("Frame", btn)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Theme.Primary
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.ZIndex = 1
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)

    local bgGrad = Instance.new("UIGradient", bg)
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.SoftRed),
        ColorSequenceKeypoint.new(0.5, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.DeepRed),
    })

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Theme.DeepRed
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.ZIndex = 2
    label.Parent = btn

    TabButtons[name] = { btn = btn, bg = bg, label = label }

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

local function makeSectionHeader(parent, text, yPos)
    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.new(1, 0, 0, 18)
    holder.Position = UDim2.new(0, 0, 0, yPos)
    holder.BackgroundTransparency = 1

    local accent = Instance.new("Frame", holder)
    accent.Size = UDim2.new(0, 3, 1, -4)
    accent.Position = UDim2.new(0, 0, 0, 2)
    accent.BackgroundColor3 = Theme.Primary
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", holder)
    lbl.Size = UDim2.new(1, -14, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.DeepRed
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function makeToggle(parent, text, yPos, default, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 34)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundColor3 = Theme.Card
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Theme.SoftRed
    rowStroke.Thickness = 1
    rowStroke.Transparency = 0.5

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, 42, 0, 22)
    track.Position = UDim2.new(1, -54, 0.5, -11)
    track.BackgroundColor3 = default and Theme.Primary or Theme.TrackOff
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local trackStroke = Instance.new("UIStroke", track)
    trackStroke.Color = default and Theme.DeepRed or Theme.Muted
    trackStroke.Thickness = 1
    trackStroke.Transparency = 0.4

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 17, 0, 17)
    knob.Position = default and UDim2.new(1, -19, 0.5, -8.5) or UDim2.new(0, 2, 0.5, -8.5)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Theme.Primary or Theme.TrackOff
        }):Play()
        TweenService:Create(trackStroke, TweenInfo.new(0.2), {
            Color = state and Theme.DeepRed or Theme.Muted
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -19, 0.5, -8.5) or UDim2.new(0, 2, 0.5, -8.5)
        }):Play()
        cb(state)
    end)

    btn.MouseEnter:Connect(function()
        TweenService:Create(rowStroke, TweenInfo.new(0.15), { Transparency = 0.1 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(rowStroke, TweenInfo.new(0.15), { Transparency = 0.5 }):Play()
    end)
end

local function makeSlider(parent, text, yPos, min, max, start, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 40)
    row.Position = UDim2.new(0, 0, 0, yPos)
    row.BackgroundColor3 = Theme.Card
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -80, 0, 14)
    lbl.Position = UDim2.new(0, 14, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Text
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.new(0, 60, 0, 14)
    val.Position = UDim2.new(1, -74, 0, 4)
    val.BackgroundTransparency = 1
    val.Text = tostring(start)
    val.TextColor3 = Theme.DeepRed
    val.Font = Enum.Font.GothamBold
    val.TextSize = 11
    val.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBg = Instance.new("Frame", row)
    sliderBg.Size = UDim2.new(1, -28, 0, 6)
    sliderBg.Position = UDim2.new(0, 14, 0, 26)
    sliderBg.BackgroundColor3 = Theme.TrackOff
    sliderBg.BorderSizePixel = 0
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((start - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Primary
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fillGrad = Instance.new("UIGradient", fill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.SoftRed),
        ColorSequenceKeypoint.new(1, Theme.DeepRed),
    })

    local knob = Instance.new("Frame", sliderBg)
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((start - min) / (max - min), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local knobStroke = Instance.new("UIStroke", knob)
    knobStroke.Color = Theme.DeepRed
    knobStroke.Thickness = 1.5

    local btnDec = Instance.new("TextButton", row)
    btnDec.Size = UDim2.new(0, 22, 0, 20)
    btnDec.Position = UDim2.new(1, -52, 0, 4)
    btnDec.Text = "-"
    btnDec.BackgroundColor3 = Theme.CardHover
    btnDec.TextColor3 = Theme.DeepRed
    btnDec.Font = Enum.Font.GothamBold
    btnDec.TextSize = 13
    btnDec.AutoButtonColor = false
    Instance.new("UICorner", btnDec).CornerRadius = UDim.new(0, 5)

    local btnInc = Instance.new("TextButton", row)
    btnInc.Size = UDim2.new(0, 22, 0, 20)
    btnInc.Position = UDim2.new(1, -28, 0, 4)
    btnInc.Text = "+"
    btnInc.BackgroundColor3 = Theme.CardHover
    btnInc.TextColor3 = Theme.DeepRed
    btnInc.Font = Enum.Font.GothamBold
    btnInc.TextSize = 13
    btnInc.AutoButtonColor = false
    Instance.new("UICorner", btnInc).CornerRadius = UDim.new(0, 5)

    local function update(v)
        v = math.clamp(v, min, max)
        val.Text = tostring(math.floor(v + 0.5))
        local rel = (v - min) / (max - min)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        cb(math.floor(v + 0.5))
    end

    btnDec.MouseButton1Click:Connect(function()
        update(tonumber(val.Text) - 1)
    end)
    btnInc.MouseButton1Click:Connect(function()
        update(tonumber(val.Text) + 1)
    end)

    local dragging = false
    local sliderBtn = Instance.new("TextButton", sliderBg)
    sliderBtn.Size = UDim2.new(1, 0, 1, 0)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""

    local function sliderUpdate(input)
        local rel = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
        rel = math.clamp(rel, 0, 1)
        update(min + (max - min) * rel)
    end

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            sliderUpdate(input)
        end
    end)
    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            sliderUpdate(input)
        end
    end)
end

local function makeButton(parent, text, yPos, cb)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Position = UDim2.new(0, 0, 0, yPos)
    btn.BackgroundColor3 = Theme.Primary
    btn.Text = ""
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local btnGrad = Instance.new("UIGradient", btn)
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.SoftRed),
        ColorSequenceKeypoint.new(0.5, Theme.Primary),
        ColorSequenceKeypoint.new(1, Theme.DeepRed),
    })

    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Theme.DeepRed
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12

    btn.MouseEnter:Connect(function()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), { Transparency = 0.1 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btnStroke, TweenInfo.new(0.15), { Transparency = 0.4 }):Play()
    end)

    btn.MouseButton1Click:Connect(cb)
end

makeSectionHeader(AimbotPage, "AIMBOT", 0)
makeToggle(AimbotPage, "Enable Aimbot",    22, false, function(v) State.AimbotEnabled = v end)
makeToggle(AimbotPage, "Lock Teammates",   60, true,  function(v) State.LockTeammates = v end)
makeToggle(AimbotPage, "Disable Wall Lock",98, true,  function(v) State.DisableWallLock = v end)
makeToggle(AimbotPage, "Show FOV",         136, true,  function(v) State.ShowFOV = v end)

makeSectionHeader(AimbotPage, "FOV SETTINGS", 180)
makeSlider(AimbotPage, "Aimbot FOV", 202, 10, 500, 50, function(v)
    State.AimbotFOV = v
end)

makeSectionHeader(AimbotPage, "TARGET", 254)
local PartBtn = Instance.new("TextButton", AimbotPage)
PartBtn.Size = UDim2.new(1, 0, 0, 34)
PartBtn.Position = UDim2.new(0, 0, 0, 276)
PartBtn.Text = "Target Part: Head"
PartBtn.BackgroundColor3 = Theme.CardHover
PartBtn.TextColor3 = Theme.DeepRed
PartBtn.Font = Enum.Font.GothamBold
PartBtn.TextSize = 11
PartBtn.AutoButtonColor = false
PartBtn.Parent = AimbotPage
Instance.new("UICorner", PartBtn).CornerRadius = UDim.new(0, 8)
PartBtn.MouseButton1Click:Connect(function()
    State.AimbotTargetPart = State.AimbotTargetPart == "Head" and "Torso" or "Head"
    PartBtn.Text = "Target Part: " .. State.AimbotTargetPart
end)

makeSectionHeader(ESPPage, "ESP", 0)
makeToggle(ESPPage, "Box ESP",      22,  false, function(v) State.ESP.BoxESP = v end)
makeToggle(ESPPage, "Outline ESP",  60,  false, function(v) State.ESP.OutlineESP = v end)
makeToggle(ESPPage, "Name ESP",     98,  false, function(v) State.ESP.NameESP = v end)
makeToggle(ESPPage, "Distance ESP", 136, false, function(v) State.ESP.DistanceESP = v end)
makeToggle(ESPPage, "Team ESP",     174, false, function(v) State.ESP.ESPTeammates = v end)

makeSectionHeader(MovementPage, "FLIGHT", 0)
makeToggle(MovementPage, "Enable Fly", 22, false, function(v) State.FlyEnabled = v end)
makeSlider(MovementPage, "Fly Speed", 60, 16, 200, 50, function(v) State.FlySpeed = v end)

makeSectionHeader(MovementPage, "CHARACTER", 112)
makeToggle(MovementPage, "No Clip",     134, false, function(v) State.NoClip = v end)
makeSlider(MovementPage, "Walk Speed",  172, 16, 200, 16, function(v)
    State.WalkSpeed = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end)
makeSlider(MovementPage, "Jump Power",  224, 50, 200, 50, function(v)
    State.JumpPower = v
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end)
makeToggle(MovementPage, "Infinite Jump", 276, false, function(v) State.InfiniteJump = v end)

makeSectionHeader(MovementPage, "TELEPORT", 320)
makeButton(MovementPage, "TP To Nearest Player", 342, function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart
    local nearest, dist = nil, math.huge
    for p, _ in pairs(PlayerCache) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; nearest = p end
        end
    end
    if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
        State.ReturnPosition = root.CFrame
        root.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)
makeButton(MovementPage, "TP Back / Return", 384, function()
    if not State.ReturnPosition then return end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = State.ReturnPosition
    end
end)

local FloatGui = Instance.new("ScreenGui", CoreGui)
FloatGui.Enabled = false
FloatGui.ResetOnSpawn = false

local FloatBtn = Instance.new("TextButton", FloatGui)
FloatBtn.Size = UDim2.new(0, 150, 0, 32)
FloatBtn.Position = UDim2.new(1, -160, 0, 10)
FloatBtn.Text = "OPEN KAI"
FloatBtn.BackgroundColor3 = Theme.Primary
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 13
FloatBtn.AutoButtonColor = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 8)

local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Theme.DeepRed
FloatStroke.Thickness = 1
FloatStroke.Transparency = 0.4

CloseBtn.MouseButton1Click:Connect(function()
    Gui.Enabled = false
    FloatGui.Enabled = true
end)
MinBtn.MouseButton1Click:Connect(function()
    Gui.Enabled = false
    FloatGui.Enabled = true
end)
FloatBtn.MouseButton1Click:Connect(function()
    Gui.Enabled = true
    FloatGui.Enabled = false
end)

switchTab("Aimbot")

local ESPTable = {}
local function createESP(player)
    if player == LocalPlayer then return end
    local function onChar(char)
        local root = char:WaitForChild("HumanoidRootPart", 5)
        if not root then return end
        if ESPTable[player] then
            for _, v in pairs(ESPTable[player]) do
                if typeof(v) == "Instance" then pcall(function() v:Destroy() end) end
            end
        end
        local box = Instance.new("BoxHandleAdornment", Workspace)
        box.Adornee = char
        box.Size = Vector3.new(4, 6, 2)
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Transparency = 0.6
        local outline = Instance.new("Highlight", Workspace)
        outline.Adornee = char
        outline.FillTransparency = 1
        outline.OutlineTransparency = 0
        outline.OutlineColor = Theme.Primary
        outline.Enabled = false
        local bb = Instance.new("BillboardGui", Workspace)
        bb.Adornee = root
        bb.Size = UDim2.new(0, 120, 0, 40)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 12
        txt.TextStrokeTransparency = 0.5
        ESPTable[player] = {Box = box, Outline = outline, BB = bb, TXT = txt, Root = root, Char = char}
    end
    if player.Character then onChar(player.Character) end
    player.CharacterAdded:Connect(onChar)
end
local function addPlayer(p)
    if p ~= LocalPlayer then PlayerCache[p] = true; createESP(p) end
end
local function removePlayer(p)
    PlayerCache[p] = nil
    visibilityCache[p] = nil
    if ESPTable[p] then
        for _, v in pairs(ESPTable[p]) do
            if typeof(v) == "Instance" then pcall(function() v:Destroy() end) end
        end
        ESPTable[p] = nil
    end
end
for _, p in ipairs(Players:GetPlayers()) do addPlayer(p) end
Players.PlayerAdded:Connect(addPlayer)
Players.PlayerRemoving:Connect(removePlayer)

UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

RunService.RenderStepped:Connect(function()
    if State.FlyEnabled then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
        local root = char.HumanoidRootPart
        local hum = char.Humanoid
        hum.PlatformStand = true
        local camCF = Camera.CFrame
        local moveDir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
        root.AssemblyLinearVelocity = moveDir * State.FlySpeed
    else
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.PlatformStand = false
        end
    end
    if State.NoClip then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    rayTick  = rayTick  + dt
    espTick  = espTick  + dt
    aimTick  = aimTick  + dt
    local doRay       = rayTick  >= RAY_INTERVAL
    local doESP       = espTick  >= ESP_UPDATE_INTERVAL
    local doAimUpdate = aimTick  >= AIMBOT_UPDATE_INTERVAL
    if doRay       then rayTick  = 0 end
    if doESP       then espTick  = 0 end
    if doAimUpdate then aimTick  = 0 end

    local camPos      = Camera.CFrame.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if doESP then
        for p, _ in pairs(PlayerCache) do
            local e = ESPTable[p]
            if e and e.Char and e.Root then
                local hum = e.Char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local teamOK = not isTeammate(p) or State.ESP.ESPTeammates
                    local color = getESPColor(p)
                    e.Box.Visible     = State.ESP.BoxESP     and teamOK
                    e.Box.Color3      = color
                    e.Outline.Enabled = State.ESP.OutlineESP and teamOK
                    e.Outline.OutlineColor = color
                    local bbEnabled   = teamOK and (State.ESP.NameESP or State.ESP.DistanceESP)
                    e.BB.Enabled      = bbEnabled
                    if bbEnabled then
                        local text = ""
                        if State.ESP.NameESP then text = p.Name end
                        if State.ESP.DistanceESP then
                            local d = getDistance(camPos, e.Root.Position)
                            text = text ~= "" and text .. " [" .. d .. "]" or d .. " studs"
                        end
                        e.TXT.Text       = text
                        e.TXT.TextColor3 = color
                    end
                else
                    e.Box.Visible     = false
                    e.Outline.Enabled = false
                    e.BB.Enabled      = false
                end
            end
        end
    end

    if FOVCircle then
        FOVCircle.Visible = State.ShowFOV
        FOVCircle.Radius  = State.AimbotFOV
        FOVCircle.Position = screenCenter
    end

    if doAimUpdate then
        cachedTargets = {}
        for p, _ in pairs(PlayerCache) do
            local char = p.Character
            if char then
                local hum  = char:FindFirstChild("Humanoid")
                local part = char:FindFirstChild(State.AimbotTargetPart == "Head" and "Head" or "HumanoidRootPart")
                if hum and hum.Health > 0 and part then
                    if not (State.LockTeammates and isTeammate(p)) then
                        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                            if dist <= State.AimbotFOV then
                                table.insert(cachedTargets, {part = part, dist = dist, player = p})
                            end
                        end
                    end
                end
            end
        end
        table.sort(cachedTargets, function(a, b) return a.dist < b.dist end)
    end

    if State.AimbotEnabled and #cachedTargets > 0 then
        for i = 1, #cachedTargets do
            local data = cachedTargets[i]
            if State.DisableWallLock then
                if doRay then visibilityCache[data.player] = isVisible(data.part) end
                if not visibilityCache[data.player] then continue end
            end
            Camera.CFrame = CFrame.lookAt(camPos, data.part.Position)
            break
        end
    end
end)
