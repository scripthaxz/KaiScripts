local TOTAL_DURATION = 40

local Theme = {
    Primary     = Color3.fromHex("#E5E7EB"),
    DeepBlack   = Color3.fromHex("#000000"),
    Grey        = Color3.fromHex("#1F1F1F"),
    DarkGrey    = Color3.fromHex("#0A0A0A"),
    Card        = Color3.fromHex("#141414"),
    CardHover   = Color3.fromHex("#1E1E1E"),
    Text        = Color3.fromRGB(240, 240, 240),
    Muted       = Color3.fromHex("#808080"),
    Glow        = Color3.fromHex("#FFFFFF"),
    White       = Color3.fromRGB(255, 255, 255),
}

local Messages = {
    "Connecting to Kai Scripts",
    "Loading modules",
    "Preparing interface",
    "Fading into the void",
    "Sharpening the shadows",
    "Charging the dark core",
    "Calibrating the silence",
    "Syncing the night signal",
    "Polishing the obsidian",
    "Painting the sky midnight",
    "Waking the shadows",
    "Whispering to the dark",
    "Loading the void engine",
    "Charging the onyx cannons",
    "Wrapping gifts in midnight",
    "Blowing silence into the code",
    "Serving style and loading scripts",
    "Almost ready, shadow",
    "Final touch of night",
    "Igniting the final spark",
    "Ready when you are",
}

local LOADER_URL = "https://api.rubis.app/v2/scrap/MV0aoqsww2YCR9r0/raw"

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local loaderThread = task.spawn(function()
    local ok, chunk = pcall(function()
        return game:HttpGet(LOADER_URL)
    end)
    if not ok or not chunk then
        warn("[Kai Scripts] Failed to fetch loader payload: " .. tostring(chunk))
        return
    end
    local fn, err = loadstring(chunk)
    if not fn then
        warn("[Kai Scripts] Failed to compile loader payload: " .. tostring(err))
        return
    end
    local runOk, runErr = pcall(fn)
    if not runOk then
        warn("[Kai Scripts] Loader payload errored at runtime: " .. tostring(runErr))
    end
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KaiScriptsLoader"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local container = Instance.new("Frame")
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.Size = UDim2.new(0, 0, 0, 0)
container.BackgroundColor3 = Theme.DarkGrey
container.BorderSizePixel = 0
container.ClipsDescendants = false
container.ZIndex = 1
container.Parent = screenGui

Instance.new("UICorner", container).CornerRadius = UDim.new(0, 22)

local grad = Instance.new("UIGradient", container)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 10, 10)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30)),
})
grad.Rotation = 130

local stroke = Instance.new("UIStroke", container)
stroke.Color = Theme.Grey
stroke.Thickness = 2
stroke.Transparency = 0.1

local glow = Instance.new("UIStroke", container)
glow.Color = Theme.Glow
glow.Thickness = 8
glow.Transparency = 0.85
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local logoShell = Instance.new("Frame", container)
logoShell.AnchorPoint = Vector2.new(0.5, 0)
logoShell.Position = UDim2.new(0.5, 0, 0, 26)
logoShell.Size = UDim2.new(0, 78, 0, 78)
logoShell.BackgroundColor3 = Theme.Card
logoShell.BorderSizePixel = 0
logoShell.ZIndex = 5
Instance.new("UICorner", logoShell).CornerRadius = UDim.new(0, 22)

local shellGrad = Instance.new("UIGradient", logoShell)
shellGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Card),
    ColorSequenceKeypoint.new(1, Theme.Grey),
})
shellGrad.Rotation = 90

local shellStroke = Instance.new("UIStroke", logoShell)
shellStroke.Color = Theme.Primary
shellStroke.Thickness = 2
shellStroke.Transparency = 0.3

local shellGlow = Instance.new("UIStroke", logoShell)
shellGlow.Color = Theme.Glow
shellGlow.Thickness = 4
shellGlow.Transparency = 0.7

local logoLetter = Instance.new("TextLabel", logoShell)
logoLetter.Size = UDim2.new(1, 0, 1, 0)
logoLetter.BackgroundTransparency = 1
logoLetter.Text = "K"
logoLetter.TextColor3 = Theme.Primary
logoLetter.TextSize = 42
logoLetter.Font = Enum.Font.GothamBlack
logoLetter.ZIndex = 6

local logoLetterGrad = Instance.new("UIGradient", logoLetter)
logoLetterGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.White),
    ColorSequenceKeypoint.new(0.5, Theme.Primary),
    ColorSequenceKeypoint.new(1, Theme.Muted),
})
logoLetterGrad.Rotation = 90

local title = Instance.new("TextLabel", container)
title.Size = UDim2.new(1, 0, 0, 32)
title.Position = UDim2.new(0, 0, 0, 118)
title.BackgroundTransparency = 1
title.Text = "Kai Scripts"
title.TextColor3 = Theme.Text
title.TextSize = 26
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Center
title.ZIndex = 4

local subtitle = Instance.new("TextLabel", container)
subtitle.Size = UDim2.new(1, 0, 0, 16)
subtitle.Position = UDim2.new(0, 0, 0, 150)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Universal Scripts"
subtitle.TextColor3 = Theme.Muted
subtitle.TextSize = 12
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.ZIndex = 4

local barWrap = Instance.new("Frame", container)
barWrap.Size = UDim2.new(1, -64, 0, 12)
barWrap.Position = UDim2.new(0, 32, 0, 184)
barWrap.BackgroundColor3 = Theme.Card
barWrap.BorderSizePixel = 0
barWrap.ClipsDescendants = true
barWrap.ZIndex = 4
Instance.new("UICorner", barWrap).CornerRadius = UDim.new(1, 0)

local barWrapStroke = Instance.new("UIStroke", barWrap)
barWrapStroke.Color = Theme.Grey
barWrapStroke.Thickness = 1
barWrapStroke.Transparency = 0.15

local barFill = Instance.new("Frame", barWrap)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.Position = UDim2.new(0, 0, 0, 0)
barFill.BackgroundColor3 = Theme.Primary
barFill.BorderSizePixel = 0
barFill.ZIndex = 5
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local barGrad = Instance.new("UIGradient", barFill)
barGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Muted),
    ColorSequenceKeypoint.new(0.5, Theme.Primary),
    ColorSequenceKeypoint.new(1, Theme.White),
})

local shine = Instance.new("Frame", barFill)
shine.Size = UDim2.new(0.3, 0, 1, 0)
shine.Position = UDim2.new(-0.3, 0, 0, 0)
shine.BackgroundColor3 = Theme.White
shine.BackgroundTransparency = 0.35
shine.BorderSizePixel = 0
shine.ZIndex = 6

local statusText = Instance.new("TextLabel", container)
statusText.Size = UDim2.new(1, -64, 0, 16)
statusText.Position = UDim2.new(0, 32, 0, 206)
statusText.BackgroundTransparency = 1
statusText.Text = Messages[1]
statusText.TextColor3 = Theme.Muted
statusText.TextSize = 12
statusText.Font = Enum.Font.GothamMedium
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.ZIndex = 4

local percentText = Instance.new("TextLabel", container)
percentText.Size = UDim2.new(1, -64, 0, 18)
percentText.Position = UDim2.new(0, 32, 0, 226)
percentText.BackgroundTransparency = 1
percentText.Text = "0%"
percentText.TextColor3 = Theme.Primary
percentText.TextSize = 15
percentText.Font = Enum.Font.GothamBold
percentText.TextXAlignment = Enum.TextXAlignment.Right
percentText.TextTransparency = 1
percentText.ZIndex = 4

for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") and c ~= percentText and c ~= logoLetter then
        c.TextTransparency = 1
    elseif c:IsA("Frame") and c ~= barFill and c ~= shine then
        c.BackgroundTransparency = 1
    elseif c:IsA("UIStroke") and c ~= glow and c ~= shellGlow then
        c.Transparency = 1
    end
end

local running = true

task.spawn(function()
    while running do
        shine.Position = UDim2.new(-0.3, 0, 0, 0)
        TweenService:Create(shine, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Position = UDim2.new(1.3, 0, 0, 0) }):Play()
        task.wait(1.6)
    end
end)

TweenService:Create(shellGlow, TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 0.9 }):Play()
TweenService:Create(logoShell, TweenInfo.new(2.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Rotation = 3 }):Play()

local intro = TweenService:Create(container, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(0, 400, 0, 260) })
intro:Play()
intro.Completed:Wait()

for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") and c ~= logoLetter then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
    elseif c:IsA("Frame") and c ~= shine and c ~= barFill then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
    elseif c:IsA("UIStroke") and c ~= glow and c ~= shellGlow then
        TweenService:Create(c, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.3 }):Play()
    end
    task.wait(0.012)
end

barFill.BackgroundTransparency = 0
shine.BackgroundTransparency = 0.35

TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Transparency = 0.7 }):Play()

local messageIndex = 1
local messageTimer = 0
local messageInterval = TOTAL_DURATION / #Messages
local elapsed = 0
local tickRate = 0.05

while elapsed < TOTAL_DURATION do
    task.wait(tickRate)
    elapsed = elapsed + tickRate

    local progress = math.clamp(elapsed / TOTAL_DURATION, 0, 1)
    local eased = progress * progress * (3 - 2 * progress)

    barFill.Size = UDim2.new(eased, 0, 1, 0)
    barFill.BackgroundTransparency = 0
    percentText.Text = string.format("%.0f%%", eased * 100)

    messageTimer = messageTimer + tickRate
    if messageTimer >= messageInterval and messageIndex < #Messages then
        messageTimer = 0
        messageIndex = messageIndex + 1
        local textOut = TweenService:Create(statusText, TweenInfo.new(0.15), { TextTransparency = 1 })
        textOut:Play()
        textOut.Completed:Wait()
        statusText.Text = Messages[messageIndex]
        TweenService:Create(statusText, TweenInfo.new(0.2), { TextTransparency = 0 }):Play()
    end
end

barFill.Size = UDim2.new(1, 0, 1, 0)
barFill.BackgroundTransparency = 0
percentText.Text = "100%"
statusText.Text = "Complete"
TweenService:Create(glow, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Transparency = 0.3 }):Play()
task.wait(0.8)
running = false

local outro = TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) })
for _, c in ipairs(container:GetDescendants()) do
    if c:IsA("TextLabel") then TweenService:Create(c, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
    elseif c:IsA("Frame") then TweenService:Create(c, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
    elseif c:IsA("UIStroke") then TweenService:Create(c, TweenInfo.new(0.35), { Transparency = 1 }):Play() end
end
outro:Play()
outro.Completed:Wait()
screenGui:Destroy()

if coroutine.status(loaderThread) == "suspended" then
    task.wait()
end
