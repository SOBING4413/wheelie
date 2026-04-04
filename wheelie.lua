local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local isWheeliePressed = false
local notifikasiEnabled = true
local scriptActive = true

-- Extra Features State
local freecamActive = false
local noclipActive = false
local godModeActive = false
local healActive = false
local freecamSpeed = 1
local originalCameraType = nil
local noclipConnection = nil
local healConnection = nil
local freecamRunning = false

-- ==================== THEME SYSTEM ====================
local themes = {
    ["Dark Blue"] = {
        bg = Color3.fromRGB(12, 12, 24),
        panel = Color3.fromRGB(18, 18, 36),
        card = Color3.fromRGB(24, 24, 44),
        accent = Color3.fromRGB(60, 130, 255),
        accentAlt = Color3.fromRGB(80, 160, 255),
        text = Color3.fromRGB(220, 225, 240),
        textDim = Color3.fromRGB(120, 130, 160),
        success = Color3.fromRGB(0, 220, 120),
        danger = Color3.fromRGB(255, 60, 70),
        warning = Color3.fromRGB(255, 190, 0),
        border = Color3.fromRGB(40, 50, 80),
        tabActive = Color3.fromRGB(60, 130, 255),
        tabInactive = Color3.fromRGB(30, 30, 55),
        gradStart = Color3.fromRGB(40, 80, 255),
        gradEnd = Color3.fromRGB(100, 60, 255),
    },
    ["Purple Neon"] = {
        bg = Color3.fromRGB(14, 8, 22),
        panel = Color3.fromRGB(22, 14, 36),
        card = Color3.fromRGB(30, 20, 48),
        accent = Color3.fromRGB(160, 60, 255),
        accentAlt = Color3.fromRGB(200, 100, 255),
        text = Color3.fromRGB(230, 220, 245),
        textDim = Color3.fromRGB(140, 120, 170),
        success = Color3.fromRGB(0, 230, 150),
        danger = Color3.fromRGB(255, 50, 80),
        warning = Color3.fromRGB(255, 180, 0),
        border = Color3.fromRGB(60, 30, 90),
        tabActive = Color3.fromRGB(160, 60, 255),
        tabInactive = Color3.fromRGB(35, 20, 55),
        gradStart = Color3.fromRGB(160, 40, 255),
        gradEnd = Color3.fromRGB(255, 60, 180),
    },
    ["Green Matrix"] = {
        bg = Color3.fromRGB(8, 16, 10),
        panel = Color3.fromRGB(12, 24, 16),
        card = Color3.fromRGB(18, 32, 22),
        accent = Color3.fromRGB(0, 220, 100),
        accentAlt = Color3.fromRGB(0, 255, 140),
        text = Color3.fromRGB(200, 240, 210),
        textDim = Color3.fromRGB(100, 160, 120),
        success = Color3.fromRGB(0, 255, 120),
        danger = Color3.fromRGB(255, 60, 60),
        warning = Color3.fromRGB(255, 200, 0),
        border = Color3.fromRGB(30, 70, 40),
        tabActive = Color3.fromRGB(0, 200, 90),
        tabInactive = Color3.fromRGB(20, 40, 25),
        gradStart = Color3.fromRGB(0, 200, 80),
        gradEnd = Color3.fromRGB(0, 255, 180),
    },
    ["Red Crimson"] = {
        bg = Color3.fromRGB(18, 8, 8),
        panel = Color3.fromRGB(28, 14, 14),
        card = Color3.fromRGB(38, 20, 20),
        accent = Color3.fromRGB(255, 50, 60),
        accentAlt = Color3.fromRGB(255, 90, 90),
        text = Color3.fromRGB(240, 220, 220),
        textDim = Color3.fromRGB(160, 120, 120),
        success = Color3.fromRGB(0, 220, 120),
        danger = Color3.fromRGB(255, 40, 50),
        warning = Color3.fromRGB(255, 180, 0),
        border = Color3.fromRGB(80, 30, 30),
        tabActive = Color3.fromRGB(255, 50, 60),
        tabInactive = Color3.fromRGB(45, 20, 20),
        gradStart = Color3.fromRGB(255, 40, 40),
        gradEnd = Color3.fromRGB(255, 100, 50),
    },
}

local currentThemeName = "Dark Blue"
local currentTheme = themes[currentThemeName]

-- ==================== GUI UTAMA ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MaoScriptGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player.PlayerGui

-- ==================== LOADING SCREEN (FULLSCREEN FIX) ====================
local LoadingScreen = Instance.new("Frame")
LoadingScreen.Name = "LoadingScreen"
LoadingScreen.Size = UDim2.new(1, 0, 1, 36)
LoadingScreen.Position = UDim2.new(0, 0, 0, -36)
LoadingScreen.BackgroundColor3 = Color3.fromRGB(6, 6, 14)
LoadingScreen.BorderSizePixel = 0
LoadingScreen.ZIndex = 100
LoadingScreen.Parent = ScreenGui

local LoadingGradient = Instance.new("UIGradient")
LoadingGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(6, 6, 14)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(10, 10, 28)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(10, 10, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(6, 6, 14))
})
LoadingGradient.Rotation = 45
LoadingGradient.Parent = LoadingScreen

local LoadingIcon = Instance.new("TextLabel")
LoadingIcon.Name = "LoadingIcon"
LoadingIcon.Size = UDim2.new(0, 120, 0, 120)
LoadingIcon.Position = UDim2.new(0.5, -60, 0.3, -40)
LoadingIcon.BackgroundTransparency = 1
LoadingIcon.Text = "🏍️"
LoadingIcon.TextSize = 80
LoadingIcon.ZIndex = 101
LoadingIcon.Parent = LoadingScreen

local LoadingTitle = Instance.new("TextLabel")
LoadingTitle.Name = "LoadingTitle"
LoadingTitle.Size = UDim2.new(0, 500, 0, 45)
LoadingTitle.Position = UDim2.new(0.5, -250, 0.3, 80)
LoadingTitle.BackgroundTransparency = 1
LoadingTitle.Text = "EXTER TUNER v1"
LoadingTitle.TextColor3 = Color3.fromRGB(80, 180, 255)
LoadingTitle.TextSize = 36
LoadingTitle.Font = Enum.Font.GothamBold
LoadingTitle.ZIndex = 101
LoadingTitle.Parent = LoadingScreen

local LoadingSubtitle = Instance.new("TextLabel")
LoadingSubtitle.Name = "LoadingSubtitle"
LoadingSubtitle.Size = UDim2.new(0, 500, 0, 25)
LoadingSubtitle.Position = UDim2.new(0.5, -250, 0.3, 125)
LoadingSubtitle.BackgroundTransparency = 1
LoadingSubtitle.Text = "by.Sobing4413"
LoadingSubtitle.TextColor3 = Color3.fromRGB(100, 120, 160)
LoadingSubtitle.TextSize = 14
LoadingSubtitle.Font = Enum.Font.GothamSemibold
LoadingSubtitle.ZIndex = 101
LoadingSubtitle.Parent = LoadingScreen

local LoadingBarBG = Instance.new("Frame")
LoadingBarBG.Name = "LoadingBarBG"
LoadingBarBG.Size = UDim2.new(0, 360, 0, 8)
LoadingBarBG.Position = UDim2.new(0.5, -180, 0.55, 0)
LoadingBarBG.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
LoadingBarBG.BorderSizePixel = 0
LoadingBarBG.ZIndex = 101
LoadingBarBG.Parent = LoadingScreen
Instance.new("UICorner", LoadingBarBG).CornerRadius = UDim.new(1, 0)

local LoadingBarFill = Instance.new("Frame")
LoadingBarFill.Name = "LoadingBarFill"
LoadingBarFill.Size = UDim2.new(0, 0, 1, 0)
LoadingBarFill.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
LoadingBarFill.BorderSizePixel = 0
LoadingBarFill.ZIndex = 102
LoadingBarFill.Parent = LoadingBarBG
Instance.new("UICorner", LoadingBarFill).CornerRadius = UDim.new(1, 0)

local LoadingBarGlow = Instance.new("UIGradient")
LoadingBarGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 100, 255))
})
LoadingBarGlow.Parent = LoadingBarFill

local LoadingPercent = Instance.new("TextLabel")
LoadingPercent.Name = "LoadingPercent"
LoadingPercent.Size = UDim2.new(0, 100, 0, 20)
LoadingPercent.Position = UDim2.new(0.5, -50, 0.55, 14)
LoadingPercent.BackgroundTransparency = 1
LoadingPercent.Text = "0%"
LoadingPercent.TextColor3 = Color3.fromRGB(140, 160, 200)
LoadingPercent.TextSize = 13
LoadingPercent.Font = Enum.Font.GothamBold
LoadingPercent.ZIndex = 101
LoadingPercent.Parent = LoadingScreen

local LoadingStatus = Instance.new("TextLabel")
LoadingStatus.Name = "LoadingStatus"
LoadingStatus.Size = UDim2.new(0, 500, 0, 20)
LoadingStatus.Position = UDim2.new(0.5, -250, 0.62, 0)
LoadingStatus.BackgroundTransparency = 1
LoadingStatus.Text = "Memuat komponen..."
LoadingStatus.TextColor3 = Color3.fromRGB(80, 90, 130)
LoadingStatus.TextSize = 11
LoadingStatus.Font = Enum.Font.Gotham
LoadingStatus.ZIndex = 101
LoadingStatus.Parent = LoadingScreen

local LoadingCredits = Instance.new("TextLabel")
LoadingCredits.Name = "LoadingCredits"
LoadingCredits.Size = UDim2.new(0, 300, 0, 20)
LoadingCredits.Position = UDim2.new(0.5, -150, 1, -50)
LoadingCredits.BackgroundTransparency = 1
LoadingCredits.Text = "Made with love by MAO"
LoadingCredits.TextColor3 = Color3.fromRGB(50, 55, 80)
LoadingCredits.TextSize = 11
LoadingCredits.Font = Enum.Font.Gotham
LoadingCredits.ZIndex = 101
LoadingCredits.Parent = LoadingScreen

-- Particle dots
for i = 1, 14 do
    local dot = Instance.new("Frame")
    dot.Name = "Particle_" .. i
    local sz = math.random(2, 5)
    dot.Size = UDim2.new(0, sz, 0, sz)
    dot.Position = UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.8 + 0.1, 0)
    dot.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
    dot.BackgroundTransparency = math.random(4, 8) / 10
    dot.BorderSizePixel = 0
    dot.ZIndex = 101
    dot.Parent = LoadingScreen
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        while dot.Parent do
            TweenService:Create(dot, TweenInfo.new(math.random(3, 7), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Position = UDim2.new(math.random() * 0.9 + 0.05, 0, math.random() * 0.8 + 0.1, 0),
                BackgroundTransparency = math.random(3, 9) / 10
            }):Play()
            task.wait(math.random(3, 7))
        end
    end)
end

-- Icon breathing
task.spawn(function()
    while LoadingScreen.Parent do
        TweenService:Create(LoadingIcon, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 90, Rotation = 4}):Play()
        task.wait(1.2)
        TweenService:Create(LoadingIcon, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextSize = 78, Rotation = -4}):Play()
        task.wait(1.2)
    end
end)

local loadingSteps = {
    {percent = 12, status = "Menginisialisasi core engine..."},
    {percent = 25, status = "Memuat modul Wheelie..."},
    {percent = 40, status = "Memuat modul Extra Features..."},
    {percent = 55, status = "Memuat modul Speed Kendaraan..."},
    {percent = 70, status = "Menyiapkan Theme System..."},
    {percent = 85, status = "Membangun GUI Modern..."},
    {percent = 95, status = "Menghubungkan ke server..."},
    {percent = 100, status = "Selesai! Memulai EXTER TUNER v1..."},
}

task.spawn(function()
    for _, step in ipairs(loadingSteps) do
        task.wait(math.random(3, 7) / 10)
        LoadingStatus.Text = step.status
        LoadingPercent.Text = step.percent .. "%"
        TweenService:Create(LoadingBarFill, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(step.percent / 100, 0, 1, 0)
        }):Play()
    end
    task.wait(0.6)
    TweenService:Create(LoadingScreen, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
    for _, child in pairs(LoadingScreen:GetDescendants()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        elseif child:IsA("Frame") then
            TweenService:Create(child, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        end
    end
    task.wait(1.2)
    LoadingScreen:Destroy()
end)

-- ==================== MAIN FRAME ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 360)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -180)
MainFrame.BackgroundColor3 = currentTheme.bg
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 1
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = currentTheme.accent
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

task.delay(4.5, function()
    TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
end)

-- ==================== TITLE BAR ====================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = currentTheme.panel
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 16)
TitleFix.Position = UDim2.new(0, 0, 1, -16)
TitleFix.BackgroundColor3 = currentTheme.panel
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local TitleAccent = Instance.new("Frame")
TitleAccent.Size = UDim2.new(1, 0, 0, 2)
TitleAccent.Position = UDim2.new(0, 0, 1, -2)
TitleAccent.BorderSizePixel = 0
TitleAccent.Parent = TitleBar

local TitleAccentGradient = Instance.new("UIGradient")
TitleAccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, currentTheme.gradStart),
    ColorSequenceKeypoint.new(0.5, currentTheme.gradEnd),
    ColorSequenceKeypoint.new(1, currentTheme.gradStart)
})
TitleAccentGradient.Parent = TitleAccent

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "EXTER TUNER v1"
TitleLabel.TextColor3 = currentTheme.accent
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 34, 0, 34)
MinBtn.Position = UDim2.new(1, -78, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(220, 160, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 10)

local ThemeBtn = Instance.new("TextButton")
ThemeBtn.Name = "ThemeBtn"
ThemeBtn.Size = UDim2.new(0, 34, 0, 34)
ThemeBtn.Position = UDim2.new(1, -116, 0, 5)
ThemeBtn.BackgroundColor3 = currentTheme.card
ThemeBtn.Text = "T"
ThemeBtn.TextColor3 = currentTheme.accent
ThemeBtn.TextSize = 14
ThemeBtn.Font = Enum.Font.GothamBold
ThemeBtn.BorderSizePixel = 0
ThemeBtn.Parent = TitleBar
Instance.new("UICorner", ThemeBtn).CornerRadius = UDim.new(0, 10)
local ThemeBtnStroke = Instance.new("UIStroke", ThemeBtn)
ThemeBtnStroke.Color = currentTheme.border
ThemeBtnStroke.Thickness = 1

-- ==================== THEME DROPDOWN ====================
local ThemeDropdown = Instance.new("Frame")
ThemeDropdown.Name = "ThemeDropdown"
ThemeDropdown.Size = UDim2.new(0, 160, 0, 0)
ThemeDropdown.Position = UDim2.new(1, -176, 0, 44)
ThemeDropdown.BackgroundColor3 = currentTheme.panel
ThemeDropdown.BorderSizePixel = 0
ThemeDropdown.ClipsDescendants = true
ThemeDropdown.ZIndex = 50
ThemeDropdown.Visible = false
ThemeDropdown.Parent = MainFrame
Instance.new("UICorner", ThemeDropdown).CornerRadius = UDim.new(0, 10)
local DropStroke = Instance.new("UIStroke", ThemeDropdown)
DropStroke.Color = currentTheme.border
DropStroke.Thickness = 1
DropStroke.Transparency = 0.3

local themeDropdownOpen = false
local themeNames = {"Dark Blue", "Purple Neon", "Green Matrix", "Red Crimson"}
local themeButtons = {}

for i, name in ipairs(themeNames) do
    local tBtn = Instance.new("TextButton")
    tBtn.Name = "Theme_" .. name
    tBtn.Size = UDim2.new(1, -12, 0, 30)
    tBtn.Position = UDim2.new(0, 6, 0, 6 + (i - 1) * 34)
    tBtn.BackgroundColor3 = themes[name].accent
    tBtn.BackgroundTransparency = 0.85
    tBtn.Text = "  " .. name
    tBtn.TextColor3 = themes[name].accent
    tBtn.TextSize = 11
    tBtn.Font = Enum.Font.GothamBold
    tBtn.TextXAlignment = Enum.TextXAlignment.Left
    tBtn.BorderSizePixel = 0
    tBtn.ZIndex = 51
    tBtn.Parent = ThemeDropdown
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
    themeButtons[name] = tBtn
end

-- ==================== TAB BUTTONS ====================
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 36)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local WheelieTabBtn = Instance.new("TextButton")
WheelieTabBtn.Name = "WheelieTab"
WheelieTabBtn.Size = UDim2.new(0.25, -4, 1, 0)
WheelieTabBtn.Position = UDim2.new(0, 0, 0, 0)
WheelieTabBtn.BackgroundColor3 = currentTheme.tabActive
WheelieTabBtn.Text = "Wheelie"
WheelieTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WheelieTabBtn.TextSize = 12
WheelieTabBtn.Font = Enum.Font.GothamBold
WheelieTabBtn.BorderSizePixel = 0
WheelieTabBtn.Parent = TabBar
Instance.new("UICorner", WheelieTabBtn).CornerRadius = UDim.new(0, 10)

local ExtraTabBtn = Instance.new("TextButton")
ExtraTabBtn.Name = "ExtraTab"
ExtraTabBtn.Size = UDim2.new(0.25, -4, 1, 0)
ExtraTabBtn.Position = UDim2.new(0.25, 2, 0, 0)
ExtraTabBtn.BackgroundColor3 = currentTheme.tabInactive
ExtraTabBtn.Text = "Extra"
ExtraTabBtn.TextColor3 = currentTheme.textDim
ExtraTabBtn.TextSize = 12
ExtraTabBtn.Font = Enum.Font.GothamBold
ExtraTabBtn.BorderSizePixel = 0
ExtraTabBtn.Parent = TabBar
Instance.new("UICorner", ExtraTabBtn).CornerRadius = UDim.new(0, 10)

local SpeedTabBtn = Instance.new("TextButton")
SpeedTabBtn.Name = "SpeedTab"
SpeedTabBtn.Size = UDim2.new(0.25, -4, 1, 0)
SpeedTabBtn.Position = UDim2.new(0.5, 4, 0, 0)
SpeedTabBtn.BackgroundColor3 = currentTheme.tabInactive
SpeedTabBtn.Text = "Speed"
SpeedTabBtn.TextColor3 = currentTheme.textDim
SpeedTabBtn.TextSize = 12
SpeedTabBtn.Font = Enum.Font.GothamBold
SpeedTabBtn.BorderSizePixel = 0
SpeedTabBtn.Parent = TabBar
Instance.new("UICorner", SpeedTabBtn).CornerRadius = UDim.new(0, 10)

local TeleportTabBtn = Instance.new("TextButton")
TeleportTabBtn.Name = "TeleportTab"
TeleportTabBtn.Size = UDim2.new(0.25, -4, 1, 0)
TeleportTabBtn.Position = UDim2.new(0.75, 6, 0, 0)
TeleportTabBtn.BackgroundColor3 = currentTheme.tabInactive
TeleportTabBtn.Text = "Teleport"
TeleportTabBtn.TextColor3 = currentTheme.textDim
TeleportTabBtn.TextSize = 12
TeleportTabBtn.Font = Enum.Font.GothamBold
TeleportTabBtn.BorderSizePixel = 0
TeleportTabBtn.Parent = TabBar
Instance.new("UICorner", TeleportTabBtn).CornerRadius = UDim.new(0, 10)

-- ==================== WHEELIE CONTENT ====================
local WheelieContent = Instance.new("Frame")
WheelieContent.Name = "WheelieContent"
WheelieContent.Size = UDim2.new(1, -20, 1, -94)
WheelieContent.Position = UDim2.new(0, 10, 0, 88)
WheelieContent.BackgroundTransparency = 1
WheelieContent.Visible = true
WheelieContent.Parent = MainFrame

local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Size = UDim2.new(0.5, -5, 1, 0)
LeftPanel.BackgroundColor3 = currentTheme.panel
LeftPanel.BorderSizePixel = 0
LeftPanel.Parent = WheelieContent
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 12)
local LeftStroke = Instance.new("UIStroke", LeftPanel)
LeftStroke.Color = currentTheme.border
LeftStroke.Thickness = 1
LeftStroke.Transparency = 0.3

local ControlTitle = Instance.new("TextLabel")
ControlTitle.Size = UDim2.new(1, -10, 0, 22)
ControlTitle.Position = UDim2.new(0, 12, 0, 10)
ControlTitle.BackgroundTransparency = 1
ControlTitle.Text = "Kontrol"
ControlTitle.TextColor3 = currentTheme.accent
ControlTitle.TextSize = 13
ControlTitle.Font = Enum.Font.GothamBold
ControlTitle.TextXAlignment = Enum.TextXAlignment.Left
ControlTitle.Parent = LeftPanel

local ScriptLabel = Instance.new("TextLabel")
ScriptLabel.Size = UDim2.new(1, -70, 0, 25)
ScriptLabel.Position = UDim2.new(0, 12, 0, 40)
ScriptLabel.BackgroundTransparency = 1
ScriptLabel.Text = "Script Wheelie"
ScriptLabel.TextColor3 = currentTheme.text
ScriptLabel.TextSize = 12
ScriptLabel.Font = Enum.Font.GothamSemibold
ScriptLabel.TextXAlignment = Enum.TextXAlignment.Left
ScriptLabel.Parent = LeftPanel

local ScriptToggleBG = Instance.new("Frame")
ScriptToggleBG.Size = UDim2.new(0, 48, 0, 24)
ScriptToggleBG.Position = UDim2.new(1, -58, 0, 41)
ScriptToggleBG.BackgroundColor3 = currentTheme.success
ScriptToggleBG.BorderSizePixel = 0
ScriptToggleBG.Parent = LeftPanel
Instance.new("UICorner", ScriptToggleBG).CornerRadius = UDim.new(1, 0)

local ScriptToggleCircle = Instance.new("Frame")
ScriptToggleCircle.Size = UDim2.new(0, 20, 0, 20)
ScriptToggleCircle.Position = UDim2.new(1, -22, 0, 2)
ScriptToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ScriptToggleCircle.BorderSizePixel = 0
ScriptToggleCircle.Parent = ScriptToggleBG
Instance.new("UICorner", ScriptToggleCircle).CornerRadius = UDim.new(1, 0)

local ScriptToggleBtn = Instance.new("TextButton")
ScriptToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ScriptToggleBtn.BackgroundTransparency = 1
ScriptToggleBtn.Text = ""
ScriptToggleBtn.Parent = ScriptToggleBG

local NotifLabel = Instance.new("TextLabel")
NotifLabel.Size = UDim2.new(1, -70, 0, 25)
NotifLabel.Position = UDim2.new(0, 12, 0, 72)
NotifLabel.BackgroundTransparency = 1
NotifLabel.Text = "Notifikasi"
NotifLabel.TextColor3 = currentTheme.text
NotifLabel.TextSize = 12
NotifLabel.Font = Enum.Font.GothamSemibold
NotifLabel.TextXAlignment = Enum.TextXAlignment.Left
NotifLabel.Parent = LeftPanel

local NotifToggleBG = Instance.new("Frame")
NotifToggleBG.Size = UDim2.new(0, 48, 0, 24)
NotifToggleBG.Position = UDim2.new(1, -58, 0, 73)
NotifToggleBG.BackgroundColor3 = currentTheme.success
NotifToggleBG.BorderSizePixel = 0
NotifToggleBG.Parent = LeftPanel
Instance.new("UICorner", NotifToggleBG).CornerRadius = UDim.new(1, 0)

local NotifToggleCircle = Instance.new("Frame")
NotifToggleCircle.Size = UDim2.new(0, 20, 0, 20)
NotifToggleCircle.Position = UDim2.new(1, -22, 0, 2)
NotifToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
NotifToggleCircle.BorderSizePixel = 0
NotifToggleCircle.Parent = NotifToggleBG
Instance.new("UICorner", NotifToggleCircle).CornerRadius = UDim.new(1, 0)

local NotifToggleBtn = Instance.new("TextButton")
NotifToggleBtn.Size = UDim2.new(1, 0, 1, 0)
NotifToggleBtn.BackgroundTransparency = 1
NotifToggleBtn.Text = ""
NotifToggleBtn.Parent = NotifToggleBG

local KeybindLabel = Instance.new("TextLabel")
KeybindLabel.Size = UDim2.new(1, -10, 0, 22)
KeybindLabel.Position = UDim2.new(0, 12, 0, 108)
KeybindLabel.BackgroundTransparency = 1
KeybindLabel.Text = "Tekan [F] untuk Wheelie"
KeybindLabel.TextColor3 = currentTheme.textDim
KeybindLabel.TextSize = 11
KeybindLabel.Font = Enum.Font.Gotham
KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
KeybindLabel.Parent = LeftPanel

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(1, -24, 0, 1)
Separator.Position = UDim2.new(0, 12, 0, 136)
Separator.BackgroundColor3 = currentTheme.border
Separator.BorderSizePixel = 0
Separator.Parent = LeftPanel

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -10, 0, 25)
StatusLabel.Position = UDim2.new(0, 12, 1, -34)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Script Aktif"
StatusLabel.TextColor3 = currentTheme.success
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = LeftPanel

-- RIGHT PANEL
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.5, -5, 1, 0)
RightPanel.Position = UDim2.new(0.5, 5, 0, 0)
RightPanel.BackgroundColor3 = currentTheme.panel
RightPanel.BorderSizePixel = 0
RightPanel.Parent = WheelieContent
Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 12)
local RightStroke = Instance.new("UIStroke", RightPanel)
RightStroke.Color = currentTheme.border
RightStroke.Thickness = 1
RightStroke.Transparency = 0.3

local InfoTitle = Instance.new("TextLabel")
InfoTitle.Size = UDim2.new(1, -10, 0, 22)
InfoTitle.Position = UDim2.new(0, 12, 0, 10)
InfoTitle.BackgroundTransparency = 1
InfoTitle.Text = "Info Kendaraan"
InfoTitle.TextColor3 = currentTheme.accent
InfoTitle.TextSize = 13
InfoTitle.Font = Enum.Font.GothamBold
InfoTitle.TextXAlignment = Enum.TextXAlignment.Left
InfoTitle.Parent = RightPanel

local ThrottleLabel = Instance.new("TextLabel")
ThrottleLabel.Size = UDim2.new(1, -10, 0, 18)
ThrottleLabel.Position = UDim2.new(0, 12, 0, 40)
ThrottleLabel.BackgroundTransparency = 1
ThrottleLabel.Text = "Throttle"
ThrottleLabel.TextColor3 = currentTheme.textDim
ThrottleLabel.TextSize = 11
ThrottleLabel.Font = Enum.Font.GothamSemibold
ThrottleLabel.TextXAlignment = Enum.TextXAlignment.Left
ThrottleLabel.Parent = RightPanel

local ThrottleBarBG = Instance.new("Frame")
ThrottleBarBG.Size = UDim2.new(1, -24, 0, 8)
ThrottleBarBG.Position = UDim2.new(0, 12, 0, 58)
ThrottleBarBG.BackgroundColor3 = currentTheme.card
ThrottleBarBG.BorderSizePixel = 0
ThrottleBarBG.Parent = RightPanel
Instance.new("UICorner", ThrottleBarBG).CornerRadius = UDim.new(1, 0)

local ThrottleBarFill = Instance.new("Frame")
ThrottleBarFill.Name = "ThrottleBarFill"
ThrottleBarFill.Size = UDim2.new(0, 0, 1, 0)
ThrottleBarFill.BackgroundColor3 = currentTheme.success
ThrottleBarFill.BorderSizePixel = 0
ThrottleBarFill.Parent = ThrottleBarBG
Instance.new("UICorner", ThrottleBarFill).CornerRadius = UDim.new(1, 0)

local ThrottleInfo = Instance.new("TextLabel")
ThrottleInfo.Name = "ThrottleInfo"
ThrottleInfo.Size = UDim2.new(0, 40, 0, 18)
ThrottleInfo.Position = UDim2.new(1, -52, 0, 40)
ThrottleInfo.BackgroundTransparency = 1
ThrottleInfo.Text = "0%"
ThrottleInfo.TextColor3 = currentTheme.success
ThrottleInfo.TextSize = 11
ThrottleInfo.Font = Enum.Font.GothamBold
ThrottleInfo.TextXAlignment = Enum.TextXAlignment.Right
ThrottleInfo.Parent = RightPanel

local BrakeLabel = Instance.new("TextLabel")
BrakeLabel.Size = UDim2.new(1, -10, 0, 18)
BrakeLabel.Position = UDim2.new(0, 12, 0, 74)
BrakeLabel.BackgroundTransparency = 1
BrakeLabel.Text = "Brake"
BrakeLabel.TextColor3 = currentTheme.textDim
BrakeLabel.TextSize = 11
BrakeLabel.Font = Enum.Font.GothamSemibold
BrakeLabel.TextXAlignment = Enum.TextXAlignment.Left
BrakeLabel.Parent = RightPanel

local BrakeBarBG = Instance.new("Frame")
BrakeBarBG.Size = UDim2.new(1, -24, 0, 8)
BrakeBarBG.Position = UDim2.new(0, 12, 0, 92)
BrakeBarBG.BackgroundColor3 = currentTheme.card
BrakeBarBG.BorderSizePixel = 0
BrakeBarBG.Parent = RightPanel
Instance.new("UICorner", BrakeBarBG).CornerRadius = UDim.new(1, 0)

local BrakeBarFill = Instance.new("Frame")
BrakeBarFill.Name = "BrakeBarFill"
BrakeBarFill.Size = UDim2.new(0, 0, 1, 0)
BrakeBarFill.BackgroundColor3 = currentTheme.danger
BrakeBarFill.BorderSizePixel = 0
BrakeBarFill.Parent = BrakeBarBG
Instance.new("UICorner", BrakeBarFill).CornerRadius = UDim.new(1, 0)

local BrakeInfo = Instance.new("TextLabel")
BrakeInfo.Name = "BrakeInfo"
BrakeInfo.Size = UDim2.new(0, 40, 0, 18)
BrakeInfo.Position = UDim2.new(1, -52, 0, 74)
BrakeInfo.BackgroundTransparency = 1
BrakeInfo.Text = "0%"
BrakeInfo.TextColor3 = currentTheme.danger
BrakeInfo.TextSize = 11
BrakeInfo.Font = Enum.Font.GothamBold
BrakeInfo.TextXAlignment = Enum.TextXAlignment.Right
BrakeInfo.Parent = RightPanel

local WheelieStatus = Instance.new("TextLabel")
WheelieStatus.Name = "WheelieStatus"
WheelieStatus.Size = UDim2.new(1, -10, 0, 30)
WheelieStatus.Position = UDim2.new(0, 12, 0, 114)
WheelieStatus.BackgroundTransparency = 1
WheelieStatus.Text = "Wheelie: OFF"
WheelieStatus.TextColor3 = currentTheme.danger
WheelieStatus.TextSize = 14
WheelieStatus.Font = Enum.Font.GothamBold
WheelieStatus.TextXAlignment = Enum.TextXAlignment.Left
WheelieStatus.Parent = RightPanel

local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, -10, 0, 18)
CreditLabel.Position = UDim2.new(0, 12, 1, -26)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "v1 | Wheelie + Extra + Speed"
CreditLabel.TextColor3 = currentTheme.border
CreditLabel.TextSize = 10
CreditLabel.Font = Enum.Font.Gotham
CreditLabel.TextXAlignment = Enum.TextXAlignment.Left
CreditLabel.Parent = RightPanel

-- ==================== EXTRA CONTENT ====================
local ExtraContent = Instance.new("Frame")
ExtraContent.Name = "ExtraContent"
ExtraContent.Size = UDim2.new(1, -20, 1, -94)
ExtraContent.Position = UDim2.new(0, 10, 0, 88)
ExtraContent.BackgroundTransparency = 1
ExtraContent.Visible = false
ExtraContent.Parent = MainFrame

local ExtraPanel = Instance.new("Frame")
ExtraPanel.Size = UDim2.new(1, 0, 1, 0)
ExtraPanel.BackgroundColor3 = currentTheme.panel
ExtraPanel.BorderSizePixel = 0
ExtraPanel.Parent = ExtraContent
Instance.new("UICorner", ExtraPanel).CornerRadius = UDim.new(0, 12)
local ExtraPanelStroke = Instance.new("UIStroke", ExtraPanel)
ExtraPanelStroke.Color = currentTheme.border
ExtraPanelStroke.Thickness = 1
ExtraPanelStroke.Transparency = 0.3

local ExtraTitle = Instance.new("TextLabel")
ExtraTitle.Size = UDim2.new(1, -10, 0, 25)
ExtraTitle.Position = UDim2.new(0, 12, 0, 8)
ExtraTitle.BackgroundTransparency = 1
ExtraTitle.Text = "Extra Features"
ExtraTitle.TextColor3 = currentTheme.accent
ExtraTitle.TextSize = 14
ExtraTitle.Font = Enum.Font.GothamBold
ExtraTitle.TextXAlignment = Enum.TextXAlignment.Left
ExtraTitle.Parent = ExtraPanel

local ExtraDesc = Instance.new("TextLabel")
ExtraDesc.Size = UDim2.new(1, -10, 0, 18)
ExtraDesc.Position = UDim2.new(0, 12, 0, 30)
ExtraDesc.BackgroundTransparency = 1
ExtraDesc.Text = "Fitur tambahan untuk gameplay kamu!"
ExtraDesc.TextColor3 = currentTheme.textDim
ExtraDesc.TextSize = 11
ExtraDesc.Font = Enum.Font.Gotham
ExtraDesc.TextXAlignment = Enum.TextXAlignment.Left
ExtraDesc.Parent = ExtraPanel

local ExtraScroll = Instance.new("ScrollingFrame")
ExtraScroll.Size = UDim2.new(1, -16, 1, -55)
ExtraScroll.Position = UDim2.new(0, 8, 0, 52)
ExtraScroll.BackgroundTransparency = 1
ExtraScroll.BorderSizePixel = 0
ExtraScroll.ScrollBarThickness = 4
ExtraScroll.ScrollBarImageColor3 = currentTheme.accent
ExtraScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ExtraScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ExtraScroll.Parent = ExtraPanel

local ExtraLayout = Instance.new("UIListLayout", ExtraScroll)
ExtraLayout.SortOrder = Enum.SortOrder.LayoutOrder
ExtraLayout.Padding = UDim.new(0, 8)
local ExtraPad = Instance.new("UIPadding", ExtraScroll)
ExtraPad.PaddingLeft = UDim.new(0, 4)
ExtraPad.PaddingRight = UDim.new(0, 4)
ExtraPad.PaddingTop = UDim.new(0, 2)
ExtraPad.PaddingBottom = UDim.new(0, 4)

-- Helper function for toggle cards
local function createToggleCard(parent, order, title, desc, accentColor, defaultOn)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = currentTheme.card
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 4, 1, -10)
    bar.Position = UDim2.new(0, 5, 0, 5)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.Parent = card
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, -80, 0, 20)
    tl.Position = UDim2.new(0, 18, 0, 8)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = currentTheme.text
    tl.TextSize = 13
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = card

    local dl = Instance.new("TextLabel")
    dl.Size = UDim2.new(1, -80, 0, 16)
    dl.Position = UDim2.new(0, 18, 0, 28)
    dl.BackgroundTransparency = 1
    dl.Text = desc
    dl.TextColor3 = currentTheme.textDim
    dl.TextSize = 10
    dl.Font = Enum.Font.Gotham
    dl.TextXAlignment = Enum.TextXAlignment.Left
    dl.Parent = card

    local tbg = Instance.new("Frame")
    tbg.Size = UDim2.new(0, 48, 0, 24)
    tbg.Position = UDim2.new(1, -60, 0.5, -12)
    tbg.BackgroundColor3 = defaultOn and accentColor or Color3.fromRGB(60, 60, 90)
    tbg.BorderSizePixel = 0
    tbg.Parent = card
    Instance.new("UICorner", tbg).CornerRadius = UDim.new(1, 0)

    local tc = Instance.new("Frame")
    tc.Size = UDim2.new(0, 20, 0, 20)
    tc.Position = defaultOn and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    tc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tc.BorderSizePixel = 0
    tc.Parent = tbg
    Instance.new("UICorner", tc).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = tbg

    return btn, tbg, tc, accentColor
end

local fcBtn, fcBG, fcCircle, fcAccent = createToggleCard(ExtraScroll, 1, "FreeCam [G]", "Kamera bebas, jelajahi map", Color3.fromRGB(0, 180, 255), false)
local hlBtn, hlBG, hlCircle, hlAccent = createToggleCard(ExtraScroll, 2, "Auto Heal", "Heal otomatis saat HP rendah", Color3.fromRGB(255, 60, 100), false)
local gdBtn, gdBG, gdCircle, gdAccent = createToggleCard(ExtraScroll, 3, "God Mode", "Tidak bisa mati (Infinite HP)", Color3.fromRGB(255, 200, 0), false)
local ncBtn, ncBG, ncCircle, ncAccent = createToggleCard(ExtraScroll, 4, "Noclip [H]", "Tembus dinding dan objek", Color3.fromRGB(180, 80, 255), false)

-- ==================== SPEED CONTENT ====================
local SpeedContent = Instance.new("Frame")
SpeedContent.Name = "SpeedContent"
SpeedContent.Size = UDim2.new(1, -20, 1, -94)
SpeedContent.Position = UDim2.new(0, 10, 0, 88)
SpeedContent.BackgroundTransparency = 1
SpeedContent.Visible = false
SpeedContent.Parent = MainFrame

local SpeedPanel = Instance.new("Frame")
SpeedPanel.Size = UDim2.new(1, 0, 1, 0)
SpeedPanel.BackgroundColor3 = currentTheme.panel
SpeedPanel.BorderSizePixel = 0
SpeedPanel.Parent = SpeedContent
Instance.new("UICorner", SpeedPanel).CornerRadius = UDim.new(0, 12)
local SpeedPanelStroke = Instance.new("UIStroke", SpeedPanel)
SpeedPanelStroke.Color = currentTheme.border
SpeedPanelStroke.Thickness = 1

local SpeedTitle = Instance.new("TextLabel")
SpeedTitle.Size = UDim2.new(1, -10, 0, 25)
SpeedTitle.Position = UDim2.new(0, 12, 0, 8)
SpeedTitle.BackgroundTransparency = 1
SpeedTitle.Text = "Ubah Speed Kendaraan"
SpeedTitle.TextColor3 = currentTheme.warning
SpeedTitle.TextSize = 14
SpeedTitle.Font = Enum.Font.GothamBold
SpeedTitle.TextXAlignment = Enum.TextXAlignment.Left
SpeedTitle.Parent = SpeedPanel

local SpeedScroll = Instance.new("ScrollingFrame")
SpeedScroll.Size = UDim2.new(1, -16, 1, -40)
SpeedScroll.Position = UDim2.new(0, 8, 0, 36)
SpeedScroll.BackgroundTransparency = 1
SpeedScroll.BorderSizePixel = 0
SpeedScroll.ScrollBarThickness = 4
SpeedScroll.ScrollBarImageColor3 = currentTheme.warning
SpeedScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SpeedScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SpeedScroll.Parent = SpeedPanel

local SpeedLayout = Instance.new("UIListLayout", SpeedScroll)
SpeedLayout.SortOrder = Enum.SortOrder.LayoutOrder
SpeedLayout.Padding = UDim.new(0, 8)
local SpeedPad = Instance.new("UIPadding", SpeedScroll)
SpeedPad.PaddingLeft = UDim.new(0, 4)
SpeedPad.PaddingRight = UDim.new(0, 4)
SpeedPad.PaddingTop = UDim.new(0, 2)
SpeedPad.PaddingBottom = UDim.new(0, 4)

-- Speed Display
local SpeedDisplayFrame = Instance.new("Frame")
SpeedDisplayFrame.Size = UDim2.new(1, 0, 0, 50)
SpeedDisplayFrame.BackgroundColor3 = currentTheme.card
SpeedDisplayFrame.BorderSizePixel = 0
SpeedDisplayFrame.LayoutOrder = 0
SpeedDisplayFrame.Parent = SpeedScroll
Instance.new("UICorner", SpeedDisplayFrame).CornerRadius = UDim.new(0, 10)

local SpeedCurrentValue = Instance.new("TextLabel")
SpeedCurrentValue.Name = "SpeedCurrentValue"
SpeedCurrentValue.Size = UDim2.new(1, -20, 1, 0)
SpeedCurrentValue.Position = UDim2.new(0, 10, 0, 0)
SpeedCurrentValue.BackgroundTransparency = 1
SpeedCurrentValue.Text = "Kecepatan: Default (1x)"
SpeedCurrentValue.TextColor3 = currentTheme.warning
SpeedCurrentValue.TextSize = 16
SpeedCurrentValue.Font = Enum.Font.GothamBold
SpeedCurrentValue.TextXAlignment = Enum.TextXAlignment.Left
SpeedCurrentValue.Parent = SpeedDisplayFrame

-- Speed Input
local SpeedInputFrame = Instance.new("Frame")
SpeedInputFrame.Size = UDim2.new(1, 0, 0, 80)
SpeedInputFrame.BackgroundColor3 = currentTheme.card
SpeedInputFrame.BorderSizePixel = 0
SpeedInputFrame.LayoutOrder = 1
SpeedInputFrame.Parent = SpeedScroll
Instance.new("UICorner", SpeedInputFrame).CornerRadius = UDim.new(0, 10)

local SpeedInputLabel = Instance.new("TextLabel")
SpeedInputLabel.Size = UDim2.new(1, -10, 0, 18)
SpeedInputLabel.Position = UDim2.new(0, 12, 0, 6)
SpeedInputLabel.BackgroundTransparency = 1
SpeedInputLabel.Text = "Speed Multiplier"
SpeedInputLabel.TextColor3 = currentTheme.text
SpeedInputLabel.TextSize = 12
SpeedInputLabel.Font = Enum.Font.GothamBold
SpeedInputLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedInputLabel.Parent = SpeedInputFrame

local SpeedInputBox = Instance.new("TextBox")
SpeedInputBox.Size = UDim2.new(1, -90, 0, 28)
SpeedInputBox.Position = UDim2.new(0, 12, 0, 28)
SpeedInputBox.BackgroundColor3 = currentTheme.bg
SpeedInputBox.Text = ""
SpeedInputBox.PlaceholderText = "Masukkan multiplier (contoh: 2)"
SpeedInputBox.PlaceholderColor3 = currentTheme.textDim
SpeedInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedInputBox.TextSize = 13
SpeedInputBox.Font = Enum.Font.GothamSemibold
SpeedInputBox.BorderSizePixel = 0
SpeedInputBox.ClearTextOnFocus = false
SpeedInputBox.Parent = SpeedInputFrame
Instance.new("UICorner", SpeedInputBox).CornerRadius = UDim.new(0, 6)

local SpeedSetBtn = Instance.new("TextButton")
SpeedSetBtn.Size = UDim2.new(0, 60, 0, 28)
SpeedSetBtn.Position = UDim2.new(1, -68, 0, 28)
SpeedSetBtn.BackgroundColor3 = currentTheme.warning
SpeedSetBtn.Text = "SET"
SpeedSetBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
SpeedSetBtn.TextSize = 11
SpeedSetBtn.Font = Enum.Font.GothamBold
SpeedSetBtn.BorderSizePixel = 0
SpeedSetBtn.Parent = SpeedInputFrame
Instance.new("UICorner", SpeedSetBtn).CornerRadius = UDim.new(0, 6)

-- Quick speeds
local quickSpeeds = {{"1x",1},{"1.5x",1.5},{"2x",2},{"3x",3},{"5x",5}}
for i, qs in ipairs(quickSpeeds) do
    local qb = Instance.new("TextButton")
    qb.Size = UDim2.new(0, 52, 0, 20)
    qb.Position = UDim2.new(0, 12 + (i-1)*57, 0, 58)
    qb.BackgroundColor3 = currentTheme.tabInactive
    qb.Text = qs[1]
    qb.TextColor3 = currentTheme.warning
    qb.TextSize = 10
    qb.Font = Enum.Font.GothamBold
    qb.BorderSizePixel = 0
    qb.Parent = SpeedInputFrame
    Instance.new("UICorner", qb).CornerRadius = UDim.new(0, 5)
    qb.MouseButton1Click:Connect(function()
        SpeedInputBox.Text = tostring(qs[2])
    end)
end

-- WalkSpeed
local WalkFrame = Instance.new("Frame")
WalkFrame.Size = UDim2.new(1, 0, 0, 80)
WalkFrame.BackgroundColor3 = currentTheme.card
WalkFrame.BorderSizePixel = 0
WalkFrame.LayoutOrder = 2
WalkFrame.Parent = SpeedScroll
Instance.new("UICorner", WalkFrame).CornerRadius = UDim.new(0, 10)

local WalkLabel = Instance.new("TextLabel")
WalkLabel.Size = UDim2.new(1, -10, 0, 18)
WalkLabel.Position = UDim2.new(0, 12, 0, 6)
WalkLabel.BackgroundTransparency = 1
WalkLabel.Text = "WalkSpeed (Jalan Kaki)"
WalkLabel.TextColor3 = currentTheme.text
WalkLabel.TextSize = 12
WalkLabel.Font = Enum.Font.GothamBold
WalkLabel.TextXAlignment = Enum.TextXAlignment.Left
WalkLabel.Parent = WalkFrame

local WalkInputBox = Instance.new("TextBox")
WalkInputBox.Size = UDim2.new(1, -90, 0, 28)
WalkInputBox.Position = UDim2.new(0, 12, 0, 28)
WalkInputBox.BackgroundColor3 = currentTheme.bg
WalkInputBox.Text = ""
WalkInputBox.PlaceholderText = "WalkSpeed (default: 16)"
WalkInputBox.PlaceholderColor3 = currentTheme.textDim
WalkInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkInputBox.TextSize = 13
WalkInputBox.Font = Enum.Font.GothamSemibold
WalkInputBox.BorderSizePixel = 0
WalkInputBox.ClearTextOnFocus = false
WalkInputBox.Parent = WalkFrame
Instance.new("UICorner", WalkInputBox).CornerRadius = UDim.new(0, 6)

local WalkSetBtn = Instance.new("TextButton")
WalkSetBtn.Size = UDim2.new(0, 60, 0, 28)
WalkSetBtn.Position = UDim2.new(1, -68, 0, 28)
WalkSetBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 230)
WalkSetBtn.Text = "SET"
WalkSetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WalkSetBtn.TextSize = 11
WalkSetBtn.Font = Enum.Font.GothamBold
WalkSetBtn.BorderSizePixel = 0
WalkSetBtn.Parent = WalkFrame
Instance.new("UICorner", WalkSetBtn).CornerRadius = UDim.new(0, 6)

local quickWalks = {{"16",16},{"32",32},{"50",50},{"100",100},{"200",200}}
for i, qw in ipairs(quickWalks) do
    local qb = Instance.new("TextButton")
    qb.Size = UDim2.new(0, 52, 0, 20)
    qb.Position = UDim2.new(0, 12 + (i-1)*57, 0, 58)
    qb.BackgroundColor3 = currentTheme.tabInactive
    qb.Text = qw[1]
    qb.TextColor3 = Color3.fromRGB(0, 200, 255)
    qb.TextSize = 10
    qb.Font = Enum.Font.GothamBold
    qb.BorderSizePixel = 0
    qb.Parent = WalkFrame
    Instance.new("UICorner", qb).CornerRadius = UDim.new(0, 5)
    qb.MouseButton1Click:Connect(function() WalkInputBox.Text = tostring(qw[2]) end)
end

-- JumpPower
local JumpFrame = Instance.new("Frame")
JumpFrame.Size = UDim2.new(1, 0, 0, 80)
JumpFrame.BackgroundColor3 = currentTheme.card
JumpFrame.BorderSizePixel = 0
JumpFrame.LayoutOrder = 3
JumpFrame.Parent = SpeedScroll
Instance.new("UICorner", JumpFrame).CornerRadius = UDim.new(0, 10)

local JumpLabel = Instance.new("TextLabel")
JumpLabel.Size = UDim2.new(1, -10, 0, 18)
JumpLabel.Position = UDim2.new(0, 12, 0, 6)
JumpLabel.BackgroundTransparency = 1
JumpLabel.Text = "JumpPower (Lompat)"
JumpLabel.TextColor3 = currentTheme.text
JumpLabel.TextSize = 12
JumpLabel.Font = Enum.Font.GothamBold
JumpLabel.TextXAlignment = Enum.TextXAlignment.Left
JumpLabel.Parent = JumpFrame

local JumpInputBox = Instance.new("TextBox")
JumpInputBox.Size = UDim2.new(1, -90, 0, 28)
JumpInputBox.Position = UDim2.new(0, 12, 0, 28)
JumpInputBox.BackgroundColor3 = currentTheme.bg
JumpInputBox.Text = ""
JumpInputBox.PlaceholderText = "JumpPower (default: 50)"
JumpInputBox.PlaceholderColor3 = currentTheme.textDim
JumpInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpInputBox.TextSize = 13
JumpInputBox.Font = Enum.Font.GothamSemibold
JumpInputBox.BorderSizePixel = 0
JumpInputBox.ClearTextOnFocus = false
JumpInputBox.Parent = JumpFrame
Instance.new("UICorner", JumpInputBox).CornerRadius = UDim.new(0, 6)

local JumpSetBtn = Instance.new("TextButton")
JumpSetBtn.Size = UDim2.new(0, 60, 0, 28)
JumpSetBtn.Position = UDim2.new(1, -68, 0, 28)
JumpSetBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 255)
JumpSetBtn.Text = "SET"
JumpSetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpSetBtn.TextSize = 11
JumpSetBtn.Font = Enum.Font.GothamBold
JumpSetBtn.BorderSizePixel = 0
JumpSetBtn.Parent = JumpFrame
Instance.new("UICorner", JumpSetBtn).CornerRadius = UDim.new(0, 6)

local quickJumps = {{"50",50},{"100",100},{"150",150},{"200",200},{"300",300}}
for i, qj in ipairs(quickJumps) do
    local qb = Instance.new("TextButton")
    qb.Size = UDim2.new(0, 52, 0, 20)
    qb.Position = UDim2.new(0, 12 + (i-1)*57, 0, 58)
    qb.BackgroundColor3 = currentTheme.tabInactive
    qb.Text = qj[1]
    qb.TextColor3 = Color3.fromRGB(180, 80, 255)
    qb.TextSize = 10
    qb.Font = Enum.Font.GothamBold
    qb.BorderSizePixel = 0
    qb.Parent = JumpFrame
    Instance.new("UICorner", qb).CornerRadius = UDim.new(0, 5)
    qb.MouseButton1Click:Connect(function() JumpInputBox.Text = tostring(qj[2]) end)
end

-- Reset
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(1, 0, 0, 36)
ResetBtn.BackgroundColor3 = currentTheme.danger
ResetBtn.Text = "RESET SEMUA KE DEFAULT"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextSize = 12
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.BorderSizePixel = 0
ResetBtn.LayoutOrder = 10
ResetBtn.Parent = SpeedScroll
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 8)

-- ==================== TELEPORT CONTENT ====================
local TeleportContent = Instance.new("Frame")
TeleportContent.Name = "TeleportContent"
TeleportContent.Size = UDim2.new(1, -20, 1, -94)
TeleportContent.Position = UDim2.new(0, 10, 0, 88)
TeleportContent.BackgroundTransparency = 1
TeleportContent.Visible = false
TeleportContent.Parent = MainFrame

local TeleportPanel = Instance.new("Frame")
TeleportPanel.Size = UDim2.new(1, 0, 1, 0)
TeleportPanel.BackgroundColor3 = currentTheme.panel
TeleportPanel.BorderSizePixel = 0
TeleportPanel.Parent = TeleportContent
Instance.new("UICorner", TeleportPanel).CornerRadius = UDim.new(0, 12)
local TeleportPanelStroke = Instance.new("UIStroke", TeleportPanel)
TeleportPanelStroke.Color = currentTheme.border
TeleportPanelStroke.Thickness = 1

local TeleportTitle = Instance.new("TextLabel")
TeleportTitle.Size = UDim2.new(1, -10, 0, 25)
TeleportTitle.Position = UDim2.new(0, 12, 0, 8)
TeleportTitle.BackgroundTransparency = 1
TeleportTitle.Text = "Teleport ke Pemain"
TeleportTitle.TextColor3 = currentTheme.accent
TeleportTitle.TextSize = 14
TeleportTitle.Font = Enum.Font.GothamBold
TeleportTitle.TextXAlignment = Enum.TextXAlignment.Left
TeleportTitle.Parent = TeleportPanel

local TeleportSearchBox = Instance.new("TextBox")
TeleportSearchBox.Size = UDim2.new(1, -120, 0, 28)
TeleportSearchBox.Position = UDim2.new(0, 10, 0, 36)
TeleportSearchBox.BackgroundColor3 = currentTheme.card
TeleportSearchBox.PlaceholderText = "Cari pemain..."
TeleportSearchBox.PlaceholderColor3 = currentTheme.textDim
TeleportSearchBox.Text = ""
TeleportSearchBox.ClearTextOnFocus = false
TeleportSearchBox.TextColor3 = currentTheme.text
TeleportSearchBox.TextSize = 12
TeleportSearchBox.Font = Enum.Font.GothamSemibold
TeleportSearchBox.BorderSizePixel = 0
TeleportSearchBox.Parent = TeleportPanel
Instance.new("UICorner", TeleportSearchBox).CornerRadius = UDim.new(0, 8)

local TeleportRefreshBtn = Instance.new("TextButton")
TeleportRefreshBtn.Size = UDim2.new(0, 96, 0, 28)
TeleportRefreshBtn.Position = UDim2.new(1, -106, 0, 36)
TeleportRefreshBtn.BackgroundColor3 = currentTheme.tabInactive
TeleportRefreshBtn.Text = "Refresh"
TeleportRefreshBtn.TextColor3 = currentTheme.text
TeleportRefreshBtn.TextSize = 11
TeleportRefreshBtn.Font = Enum.Font.GothamBold
TeleportRefreshBtn.BorderSizePixel = 0
TeleportRefreshBtn.Parent = TeleportPanel
Instance.new("UICorner", TeleportRefreshBtn).CornerRadius = UDim.new(0, 8)

local TeleportHeader = Instance.new("Frame")
TeleportHeader.Size = UDim2.new(1, -20, 0, 24)
TeleportHeader.Position = UDim2.new(0, 10, 0, 72)
TeleportHeader.BackgroundColor3 = currentTheme.card
TeleportHeader.BorderSizePixel = 0
TeleportHeader.Parent = TeleportPanel
Instance.new("UICorner", TeleportHeader).CornerRadius = UDim.new(0, 8)

local NameHeader = Instance.new("TextLabel")
NameHeader.Size = UDim2.new(0.52, 0, 1, 0)
NameHeader.Position = UDim2.new(0, 10, 0, 0)
NameHeader.BackgroundTransparency = 1
NameHeader.Text = "Nama"
NameHeader.TextColor3 = currentTheme.textDim
NameHeader.TextSize = 10
NameHeader.Font = Enum.Font.GothamBold
NameHeader.TextXAlignment = Enum.TextXAlignment.Left
NameHeader.Parent = TeleportHeader

local StatusHeader = Instance.new("TextLabel")
StatusHeader.Size = UDim2.new(0.2, 0, 1, 0)
StatusHeader.Position = UDim2.new(0.52, 0, 0, 0)
StatusHeader.BackgroundTransparency = 1
StatusHeader.Text = "Status"
StatusHeader.TextColor3 = currentTheme.textDim
StatusHeader.TextSize = 10
StatusHeader.Font = Enum.Font.GothamBold
StatusHeader.TextXAlignment = Enum.TextXAlignment.Left
StatusHeader.Parent = TeleportHeader

local ActionHeader = Instance.new("TextLabel")
ActionHeader.Size = UDim2.new(0.22, 0, 1, 0)
ActionHeader.Position = UDim2.new(0.74, 0, 0, 0)
ActionHeader.BackgroundTransparency = 1
ActionHeader.Text = "Aksi"
ActionHeader.TextColor3 = currentTheme.textDim
ActionHeader.TextSize = 10
ActionHeader.Font = Enum.Font.GothamBold
ActionHeader.TextXAlignment = Enum.TextXAlignment.Left
ActionHeader.Parent = TeleportHeader

local TeleportScroll = Instance.new("ScrollingFrame")
TeleportScroll.Size = UDim2.new(1, -20, 1, -150)
TeleportScroll.Position = UDim2.new(0, 10, 0, 100)
TeleportScroll.BackgroundTransparency = 1
TeleportScroll.BorderSizePixel = 0
TeleportScroll.ScrollBarThickness = 4
TeleportScroll.ScrollBarImageColor3 = currentTheme.accent
TeleportScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TeleportScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
TeleportScroll.Parent = TeleportPanel

local TeleportListLayout = Instance.new("UIListLayout", TeleportScroll)
TeleportListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TeleportListLayout.Padding = UDim.new(0, 6)

local TeleportFooter = Instance.new("TextLabel")
TeleportFooter.Size = UDim2.new(1, -20, 0, 22)
TeleportFooter.Position = UDim2.new(0, 10, 1, -24)
TeleportFooter.BackgroundTransparency = 1
TeleportFooter.Text = "0 pemain | Favorite: -"
TeleportFooter.TextColor3 = currentTheme.textDim
TeleportFooter.TextSize = 11
TeleportFooter.Font = Enum.Font.Gotham
TeleportFooter.TextXAlignment = Enum.TextXAlignment.Left
TeleportFooter.Parent = TeleportPanel

local teleportRows = {}
local teleportFavorites = {}
local teleportLastTarget = nil

local function teleportToPlayer(targetPlayer)
    if not targetPlayer or targetPlayer == player then
        sendNotification("Teleport Gagal", "Target tidak valid.", "error", 3)
        return
    end

    local localCharacter = player.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local targetCharacter = targetPlayer.Character
    local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot or not targetRoot then
        sendNotification("Teleport Gagal", "Posisi pemain belum tersedia.", "warning", 3)
        return
    end

    if (localRoot.Position - targetRoot.Position).Magnitude < 2 then
        sendNotification("Teleport", "Kamu sudah dekat dengan " .. targetPlayer.Name, "info", 2)
        return
    end

    local destination = targetRoot.Position + Vector3.new(0, 4, 0)
    pcall(function()
        localRoot.CFrame = CFrame.new(destination, targetRoot.Position)
    end)
    teleportLastTarget = targetPlayer
    sendNotification("Teleport Berhasil", "Kamu teleport ke " .. targetPlayer.Name, "success", 3)
end

local function updateTeleportList()
    local query = string.lower(string.gsub(TeleportSearchBox.Text or "", "^%s*(.-)%s*$", "%1"))
    local players = Players:GetPlayers()
    table.sort(players, function(a, b)
        return string.lower(a.Name) < string.lower(b.Name)
    end)

    local visibleCount = 0
    local favoriteName = "-"
    for _, plr in ipairs(players) do
        if teleportFavorites[plr.UserId] then
            favoriteName = plr.Name
            break
        end
    end

    for _, row in pairs(teleportRows) do
        row.Visible = false
    end

    for _, plr in ipairs(players) do
        local row = teleportRows[plr.UserId]
        if not row then
            local createdUserId = plr.UserId
            row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 34)
            row.BackgroundColor3 = currentTheme.card
            row.BorderSizePixel = 0
            row.Parent = TeleportScroll
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

            local playerLabel = Instance.new("TextLabel")
            playerLabel.Name = "PlayerLabel"
            playerLabel.Size = UDim2.new(0.52, -8, 1, 0)
            playerLabel.Position = UDim2.new(0, 10, 0, 0)
            playerLabel.BackgroundTransparency = 1
            playerLabel.TextColor3 = currentTheme.text
            playerLabel.TextSize = 11
            playerLabel.Font = Enum.Font.GothamSemibold
            playerLabel.TextXAlignment = Enum.TextXAlignment.Left
            playerLabel.Parent = row

            local statusLabel = Instance.new("TextLabel")
            statusLabel.Name = "StatusLabel"
            statusLabel.Size = UDim2.new(0.2, 0, 1, 0)
            statusLabel.Position = UDim2.new(0.52, 0, 0, 0)
            statusLabel.BackgroundTransparency = 1
            statusLabel.TextSize = 10
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextXAlignment = Enum.TextXAlignment.Left
            statusLabel.Parent = row

            local favBtn = Instance.new("TextButton")
            favBtn.Name = "FavBtn"
            favBtn.Size = UDim2.new(0, 26, 0, 24)
            favBtn.Position = UDim2.new(0.74, 0, 0.5, -12)
            favBtn.BackgroundColor3 = currentTheme.tabInactive
            favBtn.TextSize = 10
            favBtn.Font = Enum.Font.GothamBold
            favBtn.BorderSizePixel = 0
            favBtn.Parent = row
            Instance.new("UICorner", favBtn).CornerRadius = UDim.new(0, 6)

            local tpBtn = Instance.new("TextButton")
            tpBtn.Name = "TeleportBtn"
            tpBtn.Size = UDim2.new(0, 72, 0, 24)
            tpBtn.Position = UDim2.new(1, -76, 0.5, -12)
            tpBtn.BackgroundColor3 = currentTheme.accent
            tpBtn.Text = "Teleport"
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.TextSize = 10
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.BorderSizePixel = 0
            tpBtn.Parent = row
            Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

            favBtn.MouseButton1Click:Connect(function()
                local targetPlayer = Players:GetPlayerByUserId(createdUserId)
                if not targetPlayer then return end
                teleportFavorites[createdUserId] = not teleportFavorites[createdUserId]
                if teleportFavorites[createdUserId] then
                    sendNotification("Favorite", targetPlayer.Name .. " ditambahkan ke favorite.", "success", 2)
                else
                    sendNotification("Favorite", targetPlayer.Name .. " dihapus dari favorite.", "warning", 2)
                end
                updateTeleportList()
            end)

            tpBtn.MouseButton1Click:Connect(function()
                local targetPlayer = Players:GetPlayerByUserId(createdUserId)
                teleportToPlayer(targetPlayer)
            end)

            teleportRows[plr.UserId] = row
        end

        local rowMatches = query == "" or string.find(string.lower(plr.Name), query, 1, true) ~= nil
        if rowMatches then
            visibleCount = visibleCount + 1
            row.LayoutOrder = teleportFavorites[plr.UserId] and -1000 + visibleCount or visibleCount
            row.Visible = true
            row.PlayerLabel.Text = plr.DisplayName ~= plr.Name and (plr.DisplayName .. " (@" .. plr.Name .. ")") or plr.Name

            local isReady = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            row.StatusLabel.Text = isReady and "Online" or "Offline"
            row.StatusLabel.TextColor3 = isReady and currentTheme.success or currentTheme.warning

            row.FavBtn.Text = teleportFavorites[plr.UserId] and "★" or "☆"
            row.FavBtn.TextColor3 = teleportFavorites[plr.UserId] and currentTheme.warning or currentTheme.textDim
            row.FavBtn.BackgroundColor3 = currentTheme.tabInactive

            row.TeleportBtn.BackgroundColor3 = currentTheme.accent
            row.TeleportBtn.Text = plr == player and "Kamu" or "Teleport"
            row.TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            row.TeleportBtn.AutoButtonColor = plr ~= player
            row.TeleportBtn.Active = plr ~= player
        end
    end

    TeleportFooter.Text = string.format("%d pemain | Favorite: %s", visibleCount, favoriteName)
end

TeleportSearchBox:GetPropertyChangedSignal("Text"):Connect(updateTeleportList)
TeleportRefreshBtn.MouseButton1Click:Connect(updateTeleportList)
Players.PlayerAdded:Connect(updateTeleportList)
Players.PlayerRemoving:Connect(function(removingPlayer)
    local row = teleportRows[removingPlayer.UserId]
    if row then
        row:Destroy()
        teleportRows[removingPlayer.UserId] = nil
    end
    teleportFavorites[removingPlayer.UserId] = nil
    if teleportLastTarget == removingPlayer then
        teleportLastTarget = nil
    end
    updateTeleportList()
end)

task.delay(0.1, updateTeleportList)

-- ==================== NOTIFIKASI ====================
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 320, 0, 0)
NotifContainer.Position = UDim2.new(1, -330, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui
Instance.new("UIListLayout", NotifContainer).Padding = UDim.new(0, 6)

local function sendNotification(title, text, notifType, duration)
    if not notifikasiEnabled then return end
    duration = duration or 4
    local nf = Instance.new("Frame")
    nf.Size = UDim2.new(1, 0, 0, 60)
    nf.BackgroundColor3 = currentTheme.panel
    nf.BorderSizePixel = 0
    nf.BackgroundTransparency = 1
    nf.Parent = NotifContainer
    Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 12)
    local ns = Instance.new("UIStroke", nf)
    ns.Thickness = 1.5
    ns.Transparency = 0.3
    local ac
    if notifType == "success" then ac = currentTheme.success
    elseif notifType == "error" then ac = currentTheme.danger
    elseif notifType == "warning" then ac = currentTheme.warning
    else ac = currentTheme.accent end
    ns.Color = ac

    local ab = Instance.new("Frame")
    ab.Size = UDim2.new(0, 4, 1, -10)
    ab.Position = UDim2.new(0, 5, 0, 5)
    ab.BackgroundColor3 = ac
    ab.BorderSizePixel = 0
    ab.Parent = nf
    Instance.new("UICorner", ab).CornerRadius = UDim.new(0, 2)

    local nt = Instance.new("TextLabel")
    nt.Size = UDim2.new(1, -20, 0, 20)
    nt.Position = UDim2.new(0, 16, 0, 6)
    nt.BackgroundTransparency = 1
    nt.Text = title
    nt.TextColor3 = Color3.fromRGB(255, 255, 255)
    nt.TextSize = 13
    nt.Font = Enum.Font.GothamBold
    nt.TextXAlignment = Enum.TextXAlignment.Left
    nt.TextTruncate = Enum.TextTruncate.AtEnd
    nt.Parent = nf

    local nd = Instance.new("TextLabel")
    nd.Size = UDim2.new(1, -20, 0, 18)
    nd.Position = UDim2.new(0, 16, 0, 26)
    nd.BackgroundTransparency = 1
    nd.Text = text
    nd.TextColor3 = currentTheme.textDim
    nd.TextSize = 11
    nd.Font = Enum.Font.Gotham
    nd.TextXAlignment = Enum.TextXAlignment.Left
    nd.TextTruncate = Enum.TextTruncate.AtEnd
    nd.Parent = nf

    local pb = Instance.new("Frame")
    pb.Size = UDim2.new(1, -16, 0, 3)
    pb.Position = UDim2.new(0, 8, 1, -7)
    pb.BackgroundColor3 = currentTheme.card
    pb.BorderSizePixel = 0
    pb.Parent = nf
    Instance.new("UICorner", pb).CornerRadius = UDim.new(1, 0)
    local pf = Instance.new("Frame")
    pf.Size = UDim2.new(1, 0, 1, 0)
    pf.BackgroundColor3 = ac
    pf.BorderSizePixel = 0
    pf.Parent = pb
    Instance.new("UICorner", pf).CornerRadius = UDim.new(1, 0)

    TweenService:Create(nf, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.05}):Play()
    TweenService:Create(pf, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    task.delay(duration, function()
        local fo = TweenService:Create(nf, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        fo:Play()
        fo.Completed:Connect(function() nf:Destroy() end)
    end)
end

-- ==================== EXTRA FEATURES LOGIC ====================
local freecamRotX = 0
local freecamRotY = 0

local function toggleFreeCam()
    freecamActive = not freecamActive
    local tc = freecamActive and fcAccent or Color3.fromRGB(60, 60, 90)
    local tp = freecamActive and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    TweenService:Create(fcBG, TweenInfo.new(0.3), {BackgroundColor3 = tc}):Play()
    TweenService:Create(fcCircle, TweenInfo.new(0.3), {Position = tp}):Play()
    if freecamActive then
        sendNotification("FreeCam ON", "WASD+Q/E gerak, Klik Kanan+Mouse=rotasi, Shift=cepat, G=toggle", "success", 5)
        -- Simpan rotasi awal dari kamera saat ini
        local camCF = Camera.CFrame
        local lookDir = camCF.LookVector
        freecamRotY = math.atan2(-lookDir.X, -lookDir.Z)
        freecamRotX = math.asin(lookDir.Y)
        -- Bekukan karakter
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
            end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Anchored = true
            end
        end
        originalCameraType = Camera.CameraType
        Camera.CameraType = Enum.CameraType.Scriptable
        freecamRunning = true
        task.spawn(function()
            while freecamActive and freecamRunning do
                local dt = RunService.RenderStepped:Wait()
                
                -- Rotasi kamera dengan klik kanan + mouse
                if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                    local delta = UserInputService:GetMouseDelta()
                    local sensitivity = 0.003
                    freecamRotY = freecamRotY - delta.X * sensitivity
                    freecamRotX = math.clamp(freecamRotX - delta.Y * sensitivity, -math.rad(80), math.rad(80))
                else
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                end
                
                -- Buat CFrame rotasi dari rotasi yang disimpan
                local rotation = CFrame.Angles(0, freecamRotY, 0) * CFrame.Angles(freecamRotX, 0, 0)
                
                -- Movement
                local mv = Vector3.new(0, 0, 0)
                local spd = 50
                local camLook = rotation.LookVector
                local camRight = rotation.RightVector
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + camLook end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - camLook end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - camRight end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + camRight end
                if UserInputService:IsKeyDown(Enum.KeyCode.E) then mv = mv + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.Q) then mv = mv - Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then spd = 120 end
                if mv.Magnitude > 0 then mv = mv.Unit end
                
                -- Update posisi kamera
                local newPos = Camera.CFrame.Position + (mv * spd * dt)
                Camera.CFrame = CFrame.new(newPos) * rotation
            end
        end)
    else
        freecamRunning = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        -- STEP 1: Pindahkan kamera ke dekat karakter DULU sebelum ganti CameraType
        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 5, 10), hrp.Position)
            end
        end
        
        -- STEP 2: Ganti CameraType setelah kamera sudah dekat karakter
        Camera.CameraType = originalCameraType or Enum.CameraType.Custom
        
        -- STEP 3: Tunggu 1 frame supaya kamera system settle
        task.wait()
        
        -- STEP 4: Baru kembalikan karakter ke normal
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
            end
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Reset velocity supaya tidak ada sisa momentum/getaran
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                hrp.Anchored = false
            end
        end
        
        sendNotification("FreeCam OFF", "Kamera kembali normal", "warning", 3)
    end
end

local function toggleHeal()
    healActive = not healActive
    local tc = healActive and hlAccent or Color3.fromRGB(60, 60, 90)
    local tp = healActive and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    TweenService:Create(hlBG, TweenInfo.new(0.3), {BackgroundColor3 = tc}):Play()
    TweenService:Create(hlCircle, TweenInfo.new(0.3), {Position = tp}):Play()
    if healActive then
        sendNotification("Auto Heal ON", "HP otomatis terisi penuh!", "success", 3)
        healConnection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local c = player.Character
                if c then
                    local h = c:FindFirstChildOfClass("Humanoid")
                    if h and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
                end
            end)
        end)
    else
        if healConnection then healConnection:Disconnect(); healConnection = nil end
        sendNotification("Auto Heal OFF", "Auto heal dinonaktifkan", "warning", 3)
    end
end

local function toggleGodMode()
    godModeActive = not godModeActive
    local tc = godModeActive and gdAccent or Color3.fromRGB(60, 60, 90)
    local tp = godModeActive and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    TweenService:Create(gdBG, TweenInfo.new(0.3), {BackgroundColor3 = tc}):Play()
    TweenService:Create(gdCircle, TweenInfo.new(0.3), {Position = tp}):Play()
    if godModeActive then
        sendNotification("God Mode ON", "Kamu tidak bisa mati!", "success", 3)
        task.spawn(function()
            while godModeActive do
                pcall(function()
                    local c = player.Character
                    if c then
                        local h = c:FindFirstChildOfClass("Humanoid")
                        if h then h.MaxHealth = math.huge; h.Health = math.huge end
                    end
                end)
                task.wait(0.5)
            end
            pcall(function()
                local c = player.Character
                if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.MaxHealth = 100; h.Health = 100 end end
            end)
        end)
    else
        sendNotification("God Mode OFF", "HP kembali normal", "warning", 3)
    end
end

local function toggleNoclip()
    noclipActive = not noclipActive
    local tc = noclipActive and ncAccent or Color3.fromRGB(60, 60, 90)
    local tp = noclipActive and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    TweenService:Create(ncBG, TweenInfo.new(0.3), {BackgroundColor3 = tc}):Play()
    TweenService:Create(ncCircle, TweenInfo.new(0.3), {Position = tp}):Play()
    if noclipActive then
        sendNotification("Noclip ON", "Tembus dinding! H=toggle", "success", 3)
        noclipConnection = RunService.Stepped:Connect(function()
            pcall(function()
                local c = player.Character
                if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
            end)
        end)
    else
        if noclipConnection then noclipConnection:Disconnect(); noclipConnection = nil end
        pcall(function()
            local c = player.Character
            if c then for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end end end
        end)
        sendNotification("Noclip OFF", "Collision normal", "warning", 3)
    end
end

fcBtn.MouseButton1Click:Connect(toggleFreeCam)
hlBtn.MouseButton1Click:Connect(toggleHeal)
gdBtn.MouseButton1Click:Connect(toggleGodMode)
ncBtn.MouseButton1Click:Connect(toggleNoclip)

-- ==================== SPEED FUNCTIONS ====================
local currentSpeedMultiplier = 1
local speedLoopActive = false
local cachedVehicle = nil
local cachedDescendants = nil
local lastDescScan = 0

local function findPlayerVehicle()
    local character = player.Character
    if not character then return nil end
    local interface = player.PlayerGui:FindFirstChild("Interface")
    if interface then
        local bv = interface:FindFirstChild("Bike")
        if bv and bv.Value then return bv.Value end
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        local seat = humanoid.SeatPart
        if seat:IsA("VehicleSeat") then
            if not seat:GetAttribute("_cf") then seat:SetAttribute("_cf", seat.MaxSpeed) end
            seat.MaxSpeed = seat:GetAttribute("_cf") * currentSpeedMultiplier
            local v = seat.Parent
            while v and not v:IsA("Model") do v = v.Parent end
            return v
        end
    end
    return nil
end

local function applyVehicleSpeed(multiplier)
    currentSpeedMultiplier = multiplier
    SpeedCurrentValue.Text = "Kecepatan: " .. multiplier .. "x"
    sendNotification("Speed Diubah", "Kecepatan kendaraan: " .. multiplier .. "x", "success", 3)
    if not speedLoopActive then
        speedLoopActive = true
        task.spawn(function()
            local fc = 0
            while speedLoopActive and scriptActive do
                pcall(function()
                    local character = player.Character
                    if not character then return end
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    fc = fc + 1
                    if fc % 4 == 1 or not cachedVehicle then
                        cachedVehicle = findPlayerVehicle()
                        if cachedVehicle then cachedDescendants = cachedVehicle:GetDescendants() end
                    end
                    if not cachedVehicle then return end
                    local now = tick()
                    if now - lastDescScan > 2 then cachedDescendants = cachedVehicle:GetDescendants(); lastDescScan = now end
                    if not cachedDescendants then return end
                    for _, desc in pairs(cachedDescendants) do
                        if desc:IsA("IntValue") or desc:IsA("NumberValue") then
                            local nl = desc.Name:lower()
                            if nl:find("speed") or nl:find("maxspeed") or nl:find("topspeed") or nl:find("velocity") or nl:find("power") or nl:find("torque") then
                                pcall(function()
                                    if not desc:GetAttribute("_cf") then desc:SetAttribute("_cf", desc.Value) end
                                    desc.Value = desc:GetAttribute("_cf") * currentSpeedMultiplier
                                end)
                            end
                        end
                        if desc:IsA("VehicleSeat") then
                            pcall(function()
                                if not desc:GetAttribute("_ms") then desc:SetAttribute("_ms", desc.MaxSpeed); desc:SetAttribute("_tq", desc.Torque) end
                                desc.MaxSpeed = desc:GetAttribute("_ms") * currentSpeedMultiplier
                                desc.Torque = desc:GetAttribute("_tq") * currentSpeedMultiplier
                            end)
                        end
                        if desc:IsA("HingeConstraint") and desc.ActuatorType == Enum.ActuatorType.Motor then
                            pcall(function()
                                if not desc:GetAttribute("_av") then desc:SetAttribute("_av", desc.AngularVelocity); desc:SetAttribute("_mt", desc.MotorMaxTorque) end
                                desc.AngularVelocity = desc:GetAttribute("_av") * currentSpeedMultiplier
                                desc.MotorMaxTorque = desc:GetAttribute("_mt") * currentSpeedMultiplier
                            end)
                        end
                        if desc:IsA("CylindricalConstraint") then
                            pcall(function()
                                if not desc:GetAttribute("_av") then desc:SetAttribute("_av", desc.AngularVelocity); desc:SetAttribute("_mt", desc.MotorMaxTorque) end
                                desc.AngularVelocity = desc:GetAttribute("_av") * currentSpeedMultiplier
                                desc.MotorMaxTorque = desc:GetAttribute("_mt") * currentSpeedMultiplier
                            end)
                        end
                    end
                    if currentSpeedMultiplier > 1 and hrp then
                        local vel = hrp.AssemblyLinearVelocity
                        local spd = vel.Magnitude
                        if spd > 10 and spd < 300 then
                            local dir = vel.Unit
                            local bf = (currentSpeedMultiplier - 1) * 0.15
                            hrp.AssemblyLinearVelocity = vel + (dir * spd * bf)
                        end
                    end
                end)
                task.wait(0.25)
            end
        end)
    end
end

local function setWalkSpeed(speed)
    local c = player.Character
    if not c then sendNotification("Error", "Karakter tidak ditemukan!", "error", 3); return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then sendNotification("Error", "Humanoid tidak ditemukan!", "error", 3); return end
    pcall(function() h.WalkSpeed = speed end)
    sendNotification("WalkSpeed Diubah", "WalkSpeed: " .. speed, "success", 3)
end

local function setJumpPower(power)
    local c = player.Character
    if not c then sendNotification("Error", "Karakter tidak ditemukan!", "error", 3); return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then sendNotification("Error", "Humanoid tidak ditemukan!", "error", 3); return end
    pcall(function() h.UseJumpPower = true; h.JumpPower = power end)
    sendNotification("JumpPower Diubah", "JumpPower: " .. power, "success", 3)
end

local function resetAllSpeeds()
    currentSpeedMultiplier = 1
    speedLoopActive = false
    cachedVehicle = nil
    cachedDescendants = nil
    SpeedCurrentValue.Text = "Kecepatan: Default (1x)"
    local c = player.Character
    if c then
        local h = c:FindFirstChildOfClass("Humanoid")
        if h then pcall(function() h.WalkSpeed = 16; h.UseJumpPower = true; h.JumpPower = 50 end) end
    end
    pcall(function()
        local interface = player.PlayerGui:FindFirstChild("Interface")
        if interface then
            local bv = interface:FindFirstChild("Bike")
            if bv and bv.Value then
                for _, desc in pairs(bv.Value:GetDescendants()) do
                    if (desc:IsA("IntValue") or desc:IsA("NumberValue")) then
                        local o = desc:GetAttribute("_cf"); if o then pcall(function() desc.Value = o end) end
                    end
                    if desc:IsA("VehicleSeat") then
                        local o = desc:GetAttribute("_ms"); if o then pcall(function() desc.MaxSpeed = o end) end
                        local t = desc:GetAttribute("_tq"); if t then pcall(function() desc.Torque = t end) end
                    end
                    if desc:IsA("HingeConstraint") or desc:IsA("CylindricalConstraint") then
                        local o = desc:GetAttribute("_av"); if o then pcall(function() desc.AngularVelocity = o end) end
                        local m = desc:GetAttribute("_mt"); if m then pcall(function() desc.MotorMaxTorque = m end) end
                    end
                end
            end
        end
    end)
    sendNotification("Reset Berhasil", "Semua speed kembali default!", "success", 3)
end

-- Speed button connections
SpeedSetBtn.MouseButton1Click:Connect(function()
    local val = tonumber(SpeedInputBox.Text)
    if not val or val <= 0 then sendNotification("Error", "Masukkan angka valid!", "error", 3); return end
    applyVehicleSpeed(val)
end)

WalkSetBtn.MouseButton1Click:Connect(function()
    local val = tonumber(WalkInputBox.Text)
    if not val or val <= 0 then sendNotification("Error", "Masukkan angka valid!", "error", 3); return end
    setWalkSpeed(val)
end)

JumpSetBtn.MouseButton1Click:Connect(function()
    local val = tonumber(JumpInputBox.Text)
    if not val or val <= 0 then sendNotification("Error", "Masukkan angka valid!", "error", 3); return end
    setJumpPower(val)
end)

ResetBtn.MouseButton1Click:Connect(resetAllSpeeds)

-- ==================== TAB SWITCHING ====================
local currentTab = "wheelie"
local allTabs = {
    {name = "wheelie", btn = WheelieTabBtn, content = WheelieContent},
    {name = "extra", btn = ExtraTabBtn, content = ExtraContent},
    {name = "speed", btn = SpeedTabBtn, content = SpeedContent},
    {name = "teleport", btn = TeleportTabBtn, content = TeleportContent},
}

local function switchTab(tabName)
    if currentTab == tabName then return end
    currentTab = tabName
    for _, tab in ipairs(allTabs) do
        if tab.name == tabName then
            tab.content.Visible = true
            TweenService:Create(tab.btn, TweenInfo.new(0.25), {BackgroundColor3 = currentTheme.tabActive}):Play()
            tab.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            tab.content.Visible = false
            TweenService:Create(tab.btn, TweenInfo.new(0.25), {BackgroundColor3 = currentTheme.tabInactive}):Play()
            tab.btn.TextColor3 = currentTheme.textDim
        end
    end
end

WheelieTabBtn.MouseButton1Click:Connect(function() switchTab("wheelie") end)
ExtraTabBtn.MouseButton1Click:Connect(function() switchTab("extra") end)
SpeedTabBtn.MouseButton1Click:Connect(function() switchTab("speed") end)
TeleportTabBtn.MouseButton1Click:Connect(function() switchTab("teleport") end)

-- ==================== THEME SWITCHING ====================
local function applyTheme(themeName)
    if not themes[themeName] then return end
    currentThemeName = themeName
    currentTheme = themes[themeName]
    TweenService:Create(MainFrame, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.bg}):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.4), {Color = currentTheme.accent}):Play()
    TweenService:Create(TitleBar, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.panel}):Play()
    TweenService:Create(TitleFix, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.panel}):Play()
    TweenService:Create(TitleLabel, TweenInfo.new(0.4), {TextColor3 = currentTheme.accent}):Play()
    TweenService:Create(ThemeBtn, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.card, TextColor3 = currentTheme.accent}):Play()
    TitleAccentGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, currentTheme.gradStart),
        ColorSequenceKeypoint.new(0.5, currentTheme.gradEnd),
        ColorSequenceKeypoint.new(1, currentTheme.gradStart)
    })
    TweenService:Create(LeftPanel, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.panel}):Play()
    TweenService:Create(RightPanel, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.panel}):Play()
    TweenService:Create(ControlTitle, TweenInfo.new(0.4), {TextColor3 = currentTheme.accent}):Play()
    TweenService:Create(InfoTitle, TweenInfo.new(0.4), {TextColor3 = currentTheme.accent}):Play()
    TweenService:Create(ExtraPanel, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.panel}):Play()
    TweenService:Create(ExtraTitle, TweenInfo.new(0.4), {TextColor3 = currentTheme.accent}):Play()
    TweenService:Create(SpeedPanel, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.panel}):Play()
    TweenService:Create(TeleportPanel, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.panel}):Play()
    TweenService:Create(TeleportTitle, TweenInfo.new(0.4), {TextColor3 = currentTheme.accent}):Play()
    TweenService:Create(TeleportSearchBox, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.card, TextColor3 = currentTheme.text}):Play()
    TweenService:Create(TeleportHeader, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.card}):Play()
    TweenService:Create(TeleportRefreshBtn, TweenInfo.new(0.4), {BackgroundColor3 = currentTheme.tabInactive, TextColor3 = currentTheme.text}):Play()
    NameHeader.TextColor3 = currentTheme.textDim
    StatusHeader.TextColor3 = currentTheme.textDim
    ActionHeader.TextColor3 = currentTheme.textDim
    TeleportFooter.TextColor3 = currentTheme.textDim
    TeleportScroll.ScrollBarImageColor3 = currentTheme.accent
    updateTeleportList()
    TweenService:Create(ThemeDropdown, TweenInfo.new(0.3), {BackgroundColor3 = currentTheme.panel}):Play()
    for _, tab in ipairs(allTabs) do
        if tab.name == currentTab then
            TweenService:Create(tab.btn, TweenInfo.new(0.3), {BackgroundColor3 = currentTheme.tabActive}):Play()
        else
            TweenService:Create(tab.btn, TweenInfo.new(0.3), {BackgroundColor3 = currentTheme.tabInactive}):Play()
            tab.btn.TextColor3 = currentTheme.textDim
        end
    end
    sendNotification("Theme Diubah", "Theme: " .. themeName, "success", 3)
end

ThemeBtn.MouseButton1Click:Connect(function()
    themeDropdownOpen = not themeDropdownOpen
    ThemeDropdown.Visible = true
    if themeDropdownOpen then
        TweenService:Create(ThemeDropdown, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 160, 0, 6 + #themeNames * 34)
        }):Play()
    else
        local ct = TweenService:Create(ThemeDropdown, TweenInfo.new(0.2), {Size = UDim2.new(0, 160, 0, 0)})
        ct:Play()
        ct.Completed:Connect(function() if not themeDropdownOpen then ThemeDropdown.Visible = false end end)
    end
end)

for name, btn in pairs(themeButtons) do
    btn.MouseButton1Click:Connect(function()
        applyTheme(name)
        themeDropdownOpen = false
        local ct = TweenService:Create(ThemeDropdown, TweenInfo.new(0.2), {Size = UDim2.new(0, 160, 0, 0)})
        ct:Play()
        ct.Completed:Connect(function() ThemeDropdown.Visible = false end)
    end)
end

-- ==================== TOGGLE FUNCTIONS ====================
local function toggleScript()
    scriptActive = not scriptActive
    local tc = scriptActive and currentTheme.success or Color3.fromRGB(80, 80, 110)
    local tp = scriptActive and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    TweenService:Create(ScriptToggleBG, TweenInfo.new(0.3), {BackgroundColor3 = tc}):Play()
    TweenService:Create(ScriptToggleCircle, TweenInfo.new(0.3), {Position = tp}):Play()
    if scriptActive then
        StatusLabel.Text = "Script Aktif"
        StatusLabel.TextColor3 = currentTheme.success
        sendNotification("Script ON", "Wheelie script diaktifkan!", "success")
    else
        StatusLabel.Text = "Script Nonaktif"
        StatusLabel.TextColor3 = currentTheme.danger
        sendNotification("Script OFF", "Wheelie script dinonaktifkan.", "warning")
    end
end

local function toggleNotifikasi()
    notifikasiEnabled = not notifikasiEnabled
    local tc = notifikasiEnabled and currentTheme.success or Color3.fromRGB(80, 80, 110)
    local tp = notifikasiEnabled and UDim2.new(1, -22, 0, 2) or UDim2.new(0, 2, 0, 2)
    TweenService:Create(NotifToggleBG, TweenInfo.new(0.3), {BackgroundColor3 = tc}):Play()
    TweenService:Create(NotifToggleCircle, TweenInfo.new(0.3), {Position = tp}):Play()
    if notifikasiEnabled then sendNotification("Notifikasi ON", "Notifikasi diaktifkan.", "success") end
end

ScriptToggleBtn.MouseButton1Click:Connect(toggleScript)
NotifToggleBtn.MouseButton1Click:Connect(toggleNotifikasi)

-- ==================== MINIMIZE / CLOSE ====================
local isMinimized = false
local originalSize = MainFrame.Size

MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 500, 0, 44)}):Play()
        WheelieContent.Visible = false
        ExtraContent.Visible = false
        SpeedContent.Visible = false
        TeleportContent.Visible = false
        TabBar.Visible = false
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = originalSize}):Play()
        task.delay(0.2, function()
            TabBar.Visible = true
            for _, tab in ipairs(allTabs) do
                if tab.name == currentTab then tab.content.Visible = true end
            end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    speedLoopActive = false
    freecamRunning = false
    freecamActive = false
    if noclipConnection then noclipConnection:Disconnect() end
    if healConnection then healConnection:Disconnect() end
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    task.delay(0.35, function()
        ScreenGui:Destroy()
        scriptActive = false
    end)
end)

-- ==================== KEYBINDS ====================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        isWheeliePressed = true
    elseif input.KeyCode == Enum.KeyCode.G then
        toggleFreeCam()
    elseif input.KeyCode == Enum.KeyCode.H then
        toggleNoclip()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        isWheeliePressed = false
    end
end)

-- ==================== WHEELIE LOGIC ====================
task.spawn(function()
    while task.wait(0.1) do
        if not scriptActive then
            WheelieStatus.Text = "Wheelie: DISABLED"
            WheelieStatus.TextColor3 = Color3.fromRGB(80, 80, 110)
            continue
        end
        if isWheeliePressed then
            WheelieStatus.Text = "Wheelie: ON"
            WheelieStatus.TextColor3 = currentTheme.success
        else
            WheelieStatus.Text = "Wheelie: OFF"
            WheelieStatus.TextColor3 = currentTheme.danger
        end
        pcall(function()
            local interface = player.PlayerGui:FindFirstChild("Interface")
            if not interface then return end
            local bikeValObj = interface:FindFirstChild("Bike")
            if not bikeValObj or not bikeValObj.Value then return end
            local vehicle = bikeValObj.Value
            local weight = vehicle:FindFirstChild("Body") and vehicle.Body:FindFirstChild("Weight")
            if not weight then return end
            local originalGyro = weight:FindFirstChild("wheelie")
            if originalGyro then originalGyro:Destroy() end
            local myGyro = weight:FindFirstChild("PC_Wheelie")
            if not myGyro then
                myGyro = Instance.new("BodyGyro")
                myGyro.Name = "PC_Wheelie"
                myGyro.Parent = weight
            end
            local values = interface:FindFirstChild("Values")
            if not values then return end
            local throttle = values:FindFirstChild("Throttle") and values.Throttle.Value or 0
            local brake = values:FindFirstChild("Brake") and values.Brake.Value or 0
            ThrottleInfo.Text = math.floor(throttle * 100) .. "%"
            BrakeInfo.Text = math.floor(brake * 100) .. "%"
            TweenService:Create(ThrottleBarFill, TweenInfo.new(0.1), {Size = UDim2.new(throttle, 0, 1, 0)}):Play()
            TweenService:Create(BrakeBarFill, TweenInfo.new(0.1), {Size = UDim2.new(brake, 0, 1, 0)}):Play()
            local wheelieOutput = 0
            if isWheeliePressed then wheelieOutput = -1 * (throttle - brake) end
            local cfPos = weight.CFrame.Position
            local cfLookY = weight.CFrame.LookVector.Y
            local cfLook = weight.CFrame.LookVector
            if throttle > 0.1 then
                myGyro.D = 2 * (-math.min(wheelieOutput, 0) * throttle)
                myGyro.MaxTorque = Vector3.new(130 * (-math.min(wheelieOutput, 0) * throttle), 0, 0)
                myGyro.P = 5 * (-math.min(wheelieOutput, 0) * throttle)
                myGyro.CFrame = CFrame.new(cfPos, cfPos + cfLook) * CFrame.Angles(-(math.min(wheelieOutput, 0) * 1.5 / 2) * throttle - cfLookY, 0, 0)
            elseif brake > 0.1 then
                myGyro.D = 0.5 * (math.min(-wheelieOutput, 0) * brake)
                myGyro.MaxTorque = Vector3.new(35 * (math.min(-wheelieOutput, 0) * brake), 0, 0)
                myGyro.P = 5 * (math.min(-wheelieOutput, 0) * brake)
                myGyro.CFrame = CFrame.new(cfPos, cfPos + cfLook) * CFrame.Angles(math.min(-wheelieOutput, 0) * 0.5 / 1 * brake - cfLookY, 0, 0)
            else
                myGyro.D = 0
                myGyro.MaxTorque = Vector3.new(0, 0, 0)
                myGyro.P = 0
                myGyro.CFrame = CFrame.new(cfPos, cfPos + cfLook) * CFrame.Angles(0, 0, 0)
            end
        end)
    end
end)

-- ==================== NOTIFIKASI AWAL ====================
task.delay(5, function()
    sendNotification("EXTER TUNER v1 sudah berjalan!", "success", 5)
    task.wait(0.5)
    sendNotification("Fitur Baru!", "Tab Extra: FreeCam, Heal, God Mode, Noclip + Theme Selector!", "info", 6)
end)
