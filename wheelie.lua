local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ==============================
-- STATE
-- ==============================
local state = {
    scriptEnabled = true,
    notifications = true,
    wheeliePressed = false,
    freecam = false,
    freecamSpeed = 2,
    freecamConn = nil,
    freecamYaw = 0,
    freecamPitch = 0,
    noclip = false,
    noclipConn = nil,
    godMode = false,
    godModeConn = nil,
    heal = false,
    healConn = nil,
    speedLoop = false,
    speedValue = 2,
    currentTab = "Wheelie",
}

local themes = {
    Aurora = {
        bg = Color3.fromRGB(8, 10, 18),
        panel = Color3.fromRGB(16, 20, 34),
        panelSoft = Color3.fromRGB(22, 28, 42),
        card = Color3.fromRGB(28, 36, 54),
        text = Color3.fromRGB(229, 236, 255),
        textDim = Color3.fromRGB(145, 161, 195),
        accent = Color3.fromRGB(103, 154, 255),
        accent2 = Color3.fromRGB(161, 102, 255),
        success = Color3.fromRGB(63, 232, 153),
        danger = Color3.fromRGB(255, 98, 116),
        warning = Color3.fromRGB(255, 194, 90),
        border = Color3.fromRGB(70, 88, 126),
    },
    Sunset = {
        bg = Color3.fromRGB(20, 10, 14),
        panel = Color3.fromRGB(34, 18, 22),
        panelSoft = Color3.fromRGB(44, 24, 30),
        card = Color3.fromRGB(57, 31, 39),
        text = Color3.fromRGB(255, 230, 226),
        textDim = Color3.fromRGB(212, 160, 157),
        accent = Color3.fromRGB(255, 112, 93),
        accent2 = Color3.fromRGB(255, 182, 85),
        success = Color3.fromRGB(71, 235, 170),
        danger = Color3.fromRGB(255, 83, 114),
        warning = Color3.fromRGB(255, 206, 84),
        border = Color3.fromRGB(138, 83, 80),
    },
    Matrix = {
        bg = Color3.fromRGB(7, 14, 10),
        panel = Color3.fromRGB(14, 24, 17),
        panelSoft = Color3.fromRGB(20, 34, 24),
        card = Color3.fromRGB(26, 42, 30),
        text = Color3.fromRGB(215, 255, 228),
        textDim = Color3.fromRGB(126, 194, 150),
        accent = Color3.fromRGB(62, 235, 132),
        accent2 = Color3.fromRGB(71, 255, 196),
        success = Color3.fromRGB(79, 255, 158),
        danger = Color3.fromRGB(255, 100, 115),
        warning = Color3.fromRGB(255, 205, 100),
        border = Color3.fromRGB(63, 117, 78),
    },
}

local themeName = "Aurora"
local theme = themes[themeName]

local function tween(instance, duration, props, style, direction)
    return TweenService:Create(
        instance,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
        props
    )
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function makeStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

-- ==============================
-- ROOT GUI
-- ==============================
local gui = Instance.new("ScreenGui")
gui.Name = "WheelieNeoUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local loading = Instance.new("Frame")
loading.Size = UDim2.fromScale(1, 1)
loading.BackgroundColor3 = Color3.fromRGB(6, 8, 14)
loading.BorderSizePixel = 0
loading.ZIndex = 100
loading.Parent = gui

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(0, 520, 0, 70)
loadTitle.Position = UDim2.new(0.5, -260, 0.45, -80)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "WHEELIE NEO INTERFACE"
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.TextSize = 38
loadTitle.TextColor3 = Color3.fromRGB(130, 178, 255)
loadTitle.ZIndex = 101
loadTitle.Parent = loading

local loadSub = Instance.new("TextLabel")
loadSub.Size = UDim2.new(0, 520, 0, 30)
loadSub.Position = UDim2.new(0.5, -260, 0.45, -10)
loadSub.BackgroundTransparency = 1
loadSub.Text = "Membangun GUI baru yang lebih modern..."
loadSub.Font = Enum.Font.GothamSemibold
loadSub.TextSize = 16
loadSub.TextColor3 = Color3.fromRGB(145, 163, 196)
loadSub.ZIndex = 101
loadSub.Parent = loading

local loadBarBack = Instance.new("Frame")
loadBarBack.Size = UDim2.new(0, 440, 0, 10)
loadBarBack.Position = UDim2.new(0.5, -220, 0.56, 0)
loadBarBack.BackgroundColor3 = Color3.fromRGB(28, 34, 52)
loadBarBack.BorderSizePixel = 0
loadBarBack.ZIndex = 101
loadBarBack.Parent = loading
makeCorner(loadBarBack, 999)

local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(117, 165, 255)
loadBar.BorderSizePixel = 0
loadBar.ZIndex = 102
loadBar.Parent = loadBarBack
makeCorner(loadBar, 999)

local loadPercent = Instance.new("TextLabel")
loadPercent.Size = UDim2.new(0, 120, 0, 22)
loadPercent.Position = UDim2.new(0.5, -60, 0.59, 0)
loadPercent.BackgroundTransparency = 1
loadPercent.Text = "0%"
loadPercent.Font = Enum.Font.GothamBold
loadPercent.TextSize = 15
loadPercent.TextColor3 = Color3.fromRGB(178, 195, 224)
loadPercent.ZIndex = 101
loadPercent.Parent = loading

local app = Instance.new("Frame")
app.Name = "App"
app.Size = UDim2.new(0, 920, 0, 560)
app.Position = UDim2.new(0.5, -460, 0.5, -280)
app.BackgroundColor3 = theme.bg
app.BorderSizePixel = 0
app.Visible = false
app.Parent = gui
app.Active = true
app.Draggable = true
makeCorner(app, 22)
makeStroke(app, theme.border, 1.4, 0.2)

local appGlow = Instance.new("UIGradient")
appGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, theme.accent),
    ColorSequenceKeypoint.new(1, theme.accent2),
})
appGlow.Rotation = 20
appGlow.Parent = app

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 220, 1, 0)
sidebar.BackgroundColor3 = theme.panel
sidebar.BorderSizePixel = 0
sidebar.Parent = app
makeCorner(sidebar, 22)

local sidebarFix = Instance.new("Frame")
sidebarFix.Size = UDim2.new(0, 22, 1, 0)
sidebarFix.Position = UDim2.new(1, -22, 0, 0)
sidebarFix.BackgroundColor3 = theme.panel
sidebarFix.BorderSizePixel = 0
sidebarFix.Parent = sidebar

local brand = Instance.new("TextLabel")
brand.Size = UDim2.new(1, -24, 0, 70)
brand.Position = UDim2.new(0, 12, 0, 12)
brand.BackgroundTransparency = 1
brand.Text = "WHEELIE\nNEO"
brand.Font = Enum.Font.GothamBlack
brand.TextSize = 26
brand.TextColor3 = theme.accent
brand.TextXAlignment = Enum.TextXAlignment.Left
brand.TextYAlignment = Enum.TextYAlignment.Top
brand.Parent = sidebar

local subBrand = Instance.new("TextLabel")
subBrand.Size = UDim2.new(1, -24, 0, 26)
subBrand.Position = UDim2.new(0, 12, 0, 78)
subBrand.BackgroundTransparency = 1
subBrand.Text = "UI revamp total"
subBrand.Font = Enum.Font.Gotham
subBrand.TextSize = 13
subBrand.TextColor3 = theme.textDim
subBrand.TextXAlignment = Enum.TextXAlignment.Left
subBrand.Parent = sidebar

local nav = Instance.new("Frame")
nav.Size = UDim2.new(1, -20, 0, 300)
nav.Position = UDim2.new(0, 10, 0, 118)
nav.BackgroundTransparency = 1
nav.Parent = sidebar

local navList = Instance.new("UIListLayout")
navList.Padding = UDim.new(0, 8)
navList.Parent = nav

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 46)
footer.Position = UDim2.new(0, 12, 1, -58)
footer.BackgroundTransparency = 1
footer.Text = "F = Wheelie • Insert = Hide"
footer.Font = Enum.Font.Gotham
footer.TextSize = 12
footer.TextColor3 = theme.textDim
footer.TextWrapped = true
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.TextYAlignment = Enum.TextYAlignment.Bottom
footer.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -236, 1, -20)
content.Position = UDim2.new(0, 226, 0, 10)
content.BackgroundColor3 = theme.panelSoft
content.BorderSizePixel = 0
content.Parent = app
makeCorner(content, 18)
makeStroke(content, theme.border, 1, 0.35)

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, -18, 0, 56)
topbar.Position = UDim2.new(0, 9, 0, 9)
topbar.BackgroundColor3 = theme.card
topbar.BorderSizePixel = 0
topbar.Parent = content
makeCorner(topbar, 14)

local tabTitle = Instance.new("TextLabel")
tabTitle.Size = UDim2.new(0.6, 0, 1, 0)
tabTitle.Position = UDim2.new(0, 16, 0, 0)
tabTitle.BackgroundTransparency = 1
tabTitle.Text = "Wheelie"
tabTitle.Font = Enum.Font.GothamBold
tabTitle.TextSize = 23
tabTitle.TextColor3 = theme.text
tabTitle.TextXAlignment = Enum.TextXAlignment.Left
tabTitle.Parent = topbar

local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 36, 0, 36)
btnClose.Position = UDim2.new(1, -44, 0.5, -18)
btnClose.BackgroundColor3 = theme.danger
btnClose.Text = "×"
btnClose.Font = Enum.Font.GothamBlack
btnClose.TextSize = 22
btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
btnClose.BorderSizePixel = 0
btnClose.Parent = topbar
makeCorner(btnClose, 10)

local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 36, 0, 36)
btnMin.Position = UDim2.new(1, -86, 0.5, -18)
btnMin.BackgroundColor3 = theme.warning
btnMin.Text = "–"
btnMin.Font = Enum.Font.GothamBlack
btnMin.TextSize = 26
btnMin.TextColor3 = Color3.fromRGB(255, 255, 255)
btnMin.BorderSizePixel = 0
btnMin.Parent = topbar
makeCorner(btnMin, 10)

local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, -18, 1, -76)
pagesContainer.Position = UDim2.new(0, 9, 0, 67)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = content

local pages = {}
local navButtons = {}

local function buildPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 5
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pagesContainer

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 4)
    pad.Parent = page

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = page

    pages[name] = page
    return page
end

local function card(parent, title, subtitle, height)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -6, 0, height or 110)
    f.BackgroundColor3 = theme.card
    f.BorderSizePixel = 0
    f.Parent = parent
    makeCorner(f, 14)
    makeStroke(f, theme.border, 1, 0.5)

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -24, 0, 26)
    t.Position = UDim2.new(0, 12, 0, 10)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = theme.text
    t.Font = Enum.Font.GothamBold
    t.TextSize = 16
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = f

    if subtitle then
        local s = Instance.new("TextLabel")
        s.Size = UDim2.new(1, -24, 0, 20)
        s.Position = UDim2.new(0, 12, 0, 33)
        s.BackgroundTransparency = 1
        s.Text = subtitle
        s.TextColor3 = theme.textDim
        s.Font = Enum.Font.Gotham
        s.TextSize = 12
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.Parent = f
    end

    return f
end

local notifyHolder = Instance.new("Frame")
notifyHolder.Size = UDim2.new(0, 360, 1, -20)
notifyHolder.Position = UDim2.new(1, -370, 0, 10)
notifyHolder.BackgroundTransparency = 1
notifyHolder.Parent = gui

local notifyList = Instance.new("UIListLayout")
notifyList.FillDirection = Enum.FillDirection.Vertical
notifyList.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyList.Padding = UDim.new(0, 8)
notifyList.Parent = notifyHolder

local function notify(title, msg, kind)
    if not state.notifications then
        return
    end

    local color = theme.accent
    if kind == "success" then color = theme.success end
    if kind == "danger" then color = theme.danger end
    if kind == "warning" then color = theme.warning end

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 340, 0, 72)
    box.BackgroundColor3 = theme.panel
    box.BorderSizePixel = 0
    box.BackgroundTransparency = 0.05
    box.Parent = notifyHolder
    makeCorner(box, 12)
    makeStroke(box, color, 1.2, 0.15)

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -20, 0, 22)
    ttl.Position = UDim2.new(0, 10, 0, 8)
    ttl.BackgroundTransparency = 1
    ttl.Text = title
    ttl.TextColor3 = color
    ttl.Font = Enum.Font.GothamBold
    ttl.TextSize = 14
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = box

    local tx = Instance.new("TextLabel")
    tx.Size = UDim2.new(1, -20, 0, 34)
    tx.Position = UDim2.new(0, 10, 0, 30)
    tx.BackgroundTransparency = 1
    tx.Text = msg
    tx.TextColor3 = theme.text
    tx.Font = Enum.Font.Gotham
    tx.TextSize = 12
    tx.TextWrapped = true
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.TextYAlignment = Enum.TextYAlignment.Top
    tx.Parent = box

    box.Position = box.Position + UDim2.new(0, 24, 0, 0)
    box.BackgroundTransparency = 1
    tween(box, 0.22, {Position = box.Position - UDim2.new(0, 24, 0, 0), BackgroundTransparency = 0.05}):Play()

    task.delay(3.2, function()
        local out = tween(box, 0.2, {Position = box.Position + UDim2.new(0, 20, 0, 0), BackgroundTransparency = 1})
        out:Play()
        out.Completed:Wait()
        box:Destroy()
    end)
end

local function createToggle(parent, label, desc, default, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 56)
    row.Position = UDim2.new(0, 12, 0, 0)
    row.BackgroundColor3 = theme.panel
    row.BorderSizePixel = 0
    row.Parent = parent
    makeCorner(row, 11)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -100, 0, 22)
    lbl.Position = UDim2.new(0, 10, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = theme.text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1, -100, 0, 18)
    d.Position = UDim2.new(0, 10, 0, 28)
    d.BackgroundTransparency = 1
    d.Text = desc
    d.TextColor3 = theme.textDim
    d.Font = Enum.Font.Gotham
    d.TextSize = 11
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Parent = row

    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0, 56, 0, 28)
    sw.Position = UDim2.new(1, -68, 0.5, -14)
    sw.BackgroundColor3 = default and theme.success or Color3.fromRGB(90, 96, 118)
    sw.BorderSizePixel = 0
    sw.Parent = row
    makeCorner(sw, 999)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 24, 0, 24)
    knob.Position = default and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sw
    makeCorner(knob, 999)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.Text = ""
    btn.BackgroundTransparency = 1
    btn.Parent = sw

    local val = default
    btn.MouseButton1Click:Connect(function()
        val = not val
        tween(sw, 0.16, {BackgroundColor3 = val and theme.success or Color3.fromRGB(90, 96, 118)}):Play()
        tween(knob, 0.16, {Position = val and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
        callback(val)
    end)

    return row
end

local function createInput(parent, label, placeholder, defaultText)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -24, 0, 70)
    holder.Position = UDim2.new(0, 12, 0, 0)
    holder.BackgroundColor3 = theme.panel
    holder.BorderSizePixel = 0
    holder.Parent = parent
    makeCorner(holder, 11)

    local ttl = Instance.new("TextLabel")
    ttl.Size = UDim2.new(1, -20, 0, 20)
    ttl.Position = UDim2.new(0, 10, 0, 8)
    ttl.BackgroundTransparency = 1
    ttl.Text = label
    ttl.TextColor3 = theme.text
    ttl.Font = Enum.Font.GothamSemibold
    ttl.TextSize = 13
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Parent = holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 0, 30)
    box.Position = UDim2.new(0, 10, 0, 30)
    box.BackgroundColor3 = theme.card
    box.PlaceholderText = placeholder
    box.Text = defaultText or ""
    box.TextColor3 = theme.text
    box.PlaceholderColor3 = theme.textDim
    box.Font = Enum.Font.Gotham
    box.TextSize = 13
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0
    box.Parent = holder
    makeCorner(box, 9)

    return holder, box
end

local function createButton(parent, text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 38)
    b.Position = UDim2.new(0, 12, 0, 0)
    b.BackgroundColor3 = color or theme.accent
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.Parent = parent
    makeCorner(b, 10)
    return b
end

-- ==============================
-- PAGES
-- ==============================
local wheeliePage = buildPage("Wheelie")
local extraPage = buildPage("Extra")
local speedPage = buildPage("Speed")
local teleportPage = buildPage("Teleport")
local settingsPage = buildPage("Settings")

local wMain = card(wheeliePage, "Kontrol Wheelie", "Mode wheelie aktif saat tombol F ditahan.", 190)
local wheelieStatus = Instance.new("TextLabel")
wheelieStatus.Size = UDim2.new(1, -24, 0, 24)
wheelieStatus.Position = UDim2.new(0, 12, 0, 64)
wheelieStatus.BackgroundTransparency = 1
wheelieStatus.Text = "Status: OFF"
wheelieStatus.TextColor3 = theme.danger
wheelieStatus.Font = Enum.Font.GothamBold
wheelieStatus.TextSize = 14
wheelieStatus.TextXAlignment = Enum.TextXAlignment.Left
wheelieStatus.Parent = wMain

createToggle(wMain, "Script Wheelie", "Aktif/nonaktif script utama.", true, function(v)
    state.scriptEnabled = v
    notify("Script", v and "Script wheelie diaktifkan." or "Script wheelie dimatikan.", v and "success" or "warning")
end).Position = UDim2.new(0, 0, 0, 92)

local helpCard = card(wheeliePage, "Tips Penggunaan", "Berkendara stabil + throttle sedang biasanya hasil wheelie lebih smooth.", 120)
local hTxt = Instance.new("TextLabel")
hTxt.Size = UDim2.new(1, -24, 0, 58)
hTxt.Position = UDim2.new(0, 12, 0, 46)
hTxt.BackgroundTransparency = 1
hTxt.TextWrapped = true
hTxt.Text = "• Tekan dan tahan F saat di motor\n• Lepas F untuk normal\n• Toggle script OFF jika tidak dipakai"
hTxt.TextColor3 = theme.textDim
hTxt.Font = Enum.Font.Gotham
hTxt.TextSize = 12
hTxt.TextXAlignment = Enum.TextXAlignment.Left
hTxt.TextYAlignment = Enum.TextYAlignment.Top
hTxt.Parent = helpCard

local eCard = card(extraPage, "Extra Features", "Fitur utilitas untuk mobilitas.", 300)
local eList = Instance.new("UIListLayout")
eList.Padding = UDim.new(0, 8)
eList.Parent = eCard
eList.HorizontalAlignment = Enum.HorizontalAlignment.Left

local ePad = Instance.new("UIPadding")
ePad.PaddingTop = UDim.new(0, 52)
ePad.Parent = eCard

createToggle(eCard, "Freecam", "Kamera bebas (WASD + Mouse).", false, function(v)
    state.freecam = v
end)
createToggle(eCard, "Noclip", "Lewat objek tanpa tabrakan.", false, function(v)
    state.noclip = v
end)
createToggle(eCard, "God Mode", "Cegah HP turun ke 0.", false, function(v)
    state.godMode = v
end)
createToggle(eCard, "Auto Heal", "Isi HP terus-menerus.", false, function(v)
    state.heal = v
end)

local spVehicle = card(speedPage, "Speed Kendaraan", "Set multiplier kecepatan kendaraan.", 170)
local _, vehInput = createInput(spVehicle, "Multiplier Vehicle", "contoh: 2.5", "2")
_.Position = UDim2.new(0, 0, 0, 52)
local btnSetVehicle = createButton(spVehicle, "Apply Vehicle Speed", theme.accent)
btnSetVehicle.Position = UDim2.new(0, 0, 1, -46)

local spCharacter = card(speedPage, "Speed Karakter", "Atur WalkSpeed dan JumpPower.", 230)
local wHolder, walkInput = createInput(spCharacter, "WalkSpeed", "contoh: 16", "16")
wHolder.Position = UDim2.new(0, 0, 0, 52)
local jHolder, jumpInput = createInput(spCharacter, "JumpPower", "contoh: 50", "50")
jHolder.Position = UDim2.new(0, 0, 0, 128)
local applyCharBtn = createButton(spCharacter, "Apply Character Stats", theme.success)
applyCharBtn.Position = UDim2.new(0, 0, 1, -46)

local resetBtn = createButton(speedPage, "Reset Semua Speed ke Default", theme.danger)

local tpCard = card(teleportPage, "Teleport ke Player", "Klik tombol teleport untuk pindah lokasi.", 380)
local tpListFrame = Instance.new("ScrollingFrame")
tpListFrame.Size = UDim2.new(1, -24, 1, -56)
tpListFrame.Position = UDim2.new(0, 12, 0, 46)
tpListFrame.BackgroundColor3 = theme.panel
tpListFrame.BorderSizePixel = 0
tpListFrame.ScrollBarThickness = 4
tpListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
tpListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tpListFrame.Parent = tpCard
makeCorner(tpListFrame, 10)

local tpLayout = Instance.new("UIListLayout")
tpLayout.Padding = UDim.new(0, 6)
tpLayout.Parent = tpListFrame

local tpRefresh = createButton(teleportPage, "Refresh Daftar Player", theme.warning)

local setCard = card(settingsPage, "UI Settings", "Pengaturan tampilan dan notifikasi.", 220)
local setList = Instance.new("UIListLayout")
setList.Padding = UDim.new(0, 8)
setList.Parent = setCard
local setPad = Instance.new("UIPadding")
setPad.PaddingTop = UDim.new(0, 52)
setPad.Parent = setCard

createToggle(setCard, "Notifikasi", "Tampilkan toast notifikasi di kanan bawah.", true, function(v)
    state.notifications = v
end)

local function applyTheme(newName)
    themeName = newName
    theme = themes[newName]

    app.BackgroundColor3 = theme.bg
    sidebar.BackgroundColor3 = theme.panel
    sidebarFix.BackgroundColor3 = theme.panel
    content.BackgroundColor3 = theme.panelSoft
    topbar.BackgroundColor3 = theme.card
    brand.TextColor3 = theme.accent
    subBrand.TextColor3 = theme.textDim
    footer.TextColor3 = theme.textDim
    tabTitle.TextColor3 = theme.text
    btnMin.BackgroundColor3 = theme.warning
    btnClose.BackgroundColor3 = theme.danger

    for _, page in pairs(pages) do
        for _, obj in ipairs(page:GetDescendants()) do
            if obj:IsA("TextLabel") then
                if obj.TextColor3 ~= Color3.fromRGB(255, 255, 255) then
                    obj.TextColor3 = theme.text
                end
            elseif obj:IsA("Frame") and obj.Name ~= "Knob" then
                if obj.BackgroundTransparency < 1 then
                    if obj.Parent == page then
                        obj.BackgroundColor3 = theme.card
                    end
                end
            end
        end
    end

    notify("Theme", "Tema diganti ke " .. newName, "success")
end

for themeKey in pairs(themes) do
    local b = createButton(settingsPage, "Theme: " .. themeKey, theme.accent2)
    b.MouseButton1Click:Connect(function()
        applyTheme(themeKey)
    end)
end

local tabs = {"Wheelie", "Extra", "Speed", "Teleport", "Settings"}
local function switchTab(name)
    state.currentTab = name
    tabTitle.Text = name

    for tabName, page in pairs(pages) do
        page.Visible = (tabName == name)
    end

    for tabName, button in pairs(navButtons) do
        local active = tabName == name
        tween(button, 0.18, {BackgroundColor3 = active and theme.accent or theme.card}):Play()
        button.TextColor3 = active and Color3.fromRGB(255, 255, 255) or theme.textDim
    end
end

for _, tab in ipairs(tabs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 44)
    b.BackgroundColor3 = theme.card
    b.Text = tab
    b.TextColor3 = theme.textDim
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.Parent = nav
    makeCorner(b, 12)

    b.MouseButton1Click:Connect(function()
        switchTab(tab)
    end)

    navButtons[tab] = b
end

switchTab("Wheelie")

-- ==============================
-- GAME LOGIC
-- ==============================
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function setWalkSpeed(v)
    local h = getCharacter():FindFirstChildOfClass("Humanoid")
    if h then
        h.WalkSpeed = v
    end
end

local function setJumpPower(v)
    local h = getCharacter():FindFirstChildOfClass("Humanoid")
    if h then
        h.UseJumpPower = true
        h.JumpPower = v
    end
end

local function findVehicle()
    local char = getCharacter()
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("VehicleSeat") and d.Occupant and d.Occupant.Parent == char then
            return d
        end
    end
    return nil
end

local function applyVehicleSpeed(mult)
    state.speedLoop = true
    task.spawn(function()
        while state.speedLoop do
            local seat = findVehicle()
            if seat then
                pcall(function()
                    if seat:GetAttribute("_baseMax") == nil then
                        seat:SetAttribute("_baseMax", seat.MaxSpeed)
                    end
                    seat.MaxSpeed = math.max(10, seat:GetAttribute("_baseMax") * mult)
                    seat.Torque = math.max(seat.Torque, 5000 * mult)
                end)
            end
            task.wait(0.2)
        end
    end)
end

local function stopVehicleSpeed()
    state.speedLoop = false
    local seat = findVehicle()
    if seat then
        local base = seat:GetAttribute("_baseMax")
        if base then
            seat.MaxSpeed = base
        end
    end
end

local function refreshTeleportList()
    for _, child in ipairs(tpListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local all = Players:GetPlayers()
    table.sort(all, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)

    for _, plr in ipairs(all) do
        if plr ~= player then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -6, 0, 38)
            row.BackgroundColor3 = theme.card
            row.BorderSizePixel = 0
            row.Parent = tpListFrame
            makeCorner(row, 9)

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -90, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = plr.Name .. " (@" .. plr.DisplayName .. ")"
            lbl.TextColor3 = theme.text
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 12
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = row

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 70, 0, 28)
            b.Position = UDim2.new(1, -76, 0.5, -14)
            b.BackgroundColor3 = theme.accent
            b.Text = "Teleport"
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.BorderSizePixel = 0
            b.Parent = row
            makeCorner(b, 8)

            b.MouseButton1Click:Connect(function()
                local c1 = getCharacter()
                local c2 = plr.Character
                if not c2 then
                    notify("Teleport", "Target belum spawn.", "warning")
                    return
                end

                local hrp1 = c1:FindFirstChild("HumanoidRootPart")
                local hrp2 = c2:FindFirstChild("HumanoidRootPart")
                if hrp1 and hrp2 then
                    hrp1.CFrame = hrp2.CFrame + Vector3.new(2, 0, 2)
                    notify("Teleport", "Berhasil ke " .. plr.Name, "success")
                end
            end)
        end
    end
end

-- Freecam runtime
local freecamKeys = {W=false,A=false,S=false,D=false,Q=false,E=false}
local function stopFreecam()
    if state.freecamConn then
        state.freecamConn:Disconnect()
        state.freecamConn = nil
    end
    camera.CameraType = Enum.CameraType.Custom
end

local function startFreecam()
    camera.CameraType = Enum.CameraType.Scriptable
    local cf = camera.CFrame
    local look = cf.LookVector
    state.freecamYaw = math.atan2(-look.X, -look.Z)
    state.freecamPitch = math.asin(look.Y)

    if state.freecamConn then
        state.freecamConn:Disconnect()
    end

    state.freecamConn = RunService.RenderStepped:Connect(function(dt)
        if not state.freecam then
            stopFreecam()
            return
        end

        local delta = UserInputService:GetMouseDelta()
        local sensitivity = 0.0025
        state.freecamYaw -= delta.X * sensitivity
        state.freecamPitch = math.clamp(state.freecamPitch - delta.Y * sensitivity, -1.3, 1.3)

        local rot = CFrame.Angles(0, state.freecamYaw, 0) * CFrame.Angles(state.freecamPitch, 0, 0)
        local move = Vector3.zero
        if freecamKeys.W then move += Vector3.new(0,0,-1) end
        if freecamKeys.S then move += Vector3.new(0,0,1) end
        if freecamKeys.A then move += Vector3.new(-1,0,0) end
        if freecamKeys.D then move += Vector3.new(1,0,0) end
        if freecamKeys.E then move += Vector3.new(0,1,0) end
        if freecamKeys.Q then move += Vector3.new(0,-1,0) end

        local speed = state.freecamSpeed * 36
        camera.CFrame = camera.CFrame * rot.Rotation + (rot:VectorToWorldSpace(move.Unit == move and Vector3.zero or move.Unit) * speed * dt)
    end)
end

-- loops
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then
        return
    end

    if state.noclip then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if state.heal then
            hum.Health = math.min(hum.MaxHealth, hum.Health + 0.8)
        end

        if state.godMode and hum.Health < hum.MaxHealth * 0.3 then
            hum.Health = hum.MaxHealth
        end
    end
end)

-- wheelie logic
task.spawn(function()
    while gui.Parent do
        task.wait(0.05)

        if not state.scriptEnabled then
            wheelieStatus.Text = "Status: DISABLED"
            wheelieStatus.TextColor3 = theme.warning
            continue
        end

        wheelieStatus.Text = state.wheeliePressed and "Status: ON" or "Status: OFF"
        wheelieStatus.TextColor3 = state.wheeliePressed and theme.success or theme.danger

        local ok, err = pcall(function()
            local char = player.Character
            if not char then return end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local seatPart = hum.SeatPart
            if not seatPart then return end

            local vehicle = seatPart.Parent
            if not vehicle then return end

            local primary = vehicle.PrimaryPart or seatPart
            if not primary then return end

            local gyro = primary:FindFirstChild("WheelieGyro")
            if not gyro then
                gyro = Instance.new("BodyGyro")
                gyro.Name = "WheelieGyro"
                gyro.MaxTorque = Vector3.new(1e5, 0, 1e5)
                gyro.P = 1.2e4
                gyro.D = 800
                gyro.CFrame = primary.CFrame
                gyro.Parent = primary
            end

            if state.wheeliePressed then
                local tilt = CFrame.Angles(math.rad(-20), 0, 0)
                gyro.CFrame = primary.CFrame * tilt
            else
                gyro.CFrame = primary.CFrame
            end
        end)

        if not ok and err then
            -- keep silent to avoid spam
        end
    end
end)

-- ==============================
-- BUTTONS / INPUT
-- ==============================
btnSetVehicle.MouseButton1Click:Connect(function()
    local n = tonumber(vehInput.Text)
    if not n or n <= 0 then
        notify("Speed", "Multiplier tidak valid.", "danger")
        return
    end
    state.speedValue = n
    applyVehicleSpeed(n)
    notify("Speed", "Vehicle multiplier: x" .. tostring(n), "success")
end)

applyCharBtn.MouseButton1Click:Connect(function()
    local ws = tonumber(walkInput.Text)
    local jp = tonumber(jumpInput.Text)
    if ws then setWalkSpeed(ws) end
    if jp then setJumpPower(jp) end
    notify("Character", "Walk/Jump berhasil diubah.", "success")
end)

resetBtn.MouseButton1Click:Connect(function()
    stopVehicleSpeed()
    setWalkSpeed(16)
    setJumpPower(50)
    notify("Reset", "Semua speed kembali default.", "success")
end)

tpRefresh.MouseButton1Click:Connect(refreshTeleportList)
refreshTeleportList()

btnMin.MouseButton1Click:Connect(function()
    local hidden = pagesContainer.Visible
    pagesContainer.Visible = not hidden
    if hidden then
        content.Size = UDim2.new(1, -236, 0, 74)
    else
        content.Size = UDim2.new(1, -236, 1, -20)
    end
end)

btnClose.MouseButton1Click:Connect(function()
    state.freecam = false
    state.noclip = false
    state.godMode = false
    state.heal = false
    stopVehicleSpeed()
    stopFreecam()
    gui:Destroy()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.F then
        state.wheeliePressed = true
    elseif input.KeyCode == Enum.KeyCode.Insert then
        app.Visible = not app.Visible
    elseif input.KeyCode == Enum.KeyCode.W then
        freecamKeys.W = true
    elseif input.KeyCode == Enum.KeyCode.A then
        freecamKeys.A = true
    elseif input.KeyCode == Enum.KeyCode.S then
        freecamKeys.S = true
    elseif input.KeyCode == Enum.KeyCode.D then
        freecamKeys.D = true
    elseif input.KeyCode == Enum.KeyCode.Q then
        freecamKeys.Q = true
    elseif input.KeyCode == Enum.KeyCode.E then
        freecamKeys.E = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        state.wheeliePressed = false
    elseif input.KeyCode == Enum.KeyCode.W then
        freecamKeys.W = false
    elseif input.KeyCode == Enum.KeyCode.A then
        freecamKeys.A = false
    elseif input.KeyCode == Enum.KeyCode.S then
        freecamKeys.S = false
    elseif input.KeyCode == Enum.KeyCode.D then
        freecamKeys.D = false
    elseif input.KeyCode == Enum.KeyCode.Q then
        freecamKeys.Q = false
    elseif input.KeyCode == Enum.KeyCode.E then
        freecamKeys.E = false
    end
end)

RunService.RenderStepped:Connect(function()
    if state.freecam and camera.CameraType ~= Enum.CameraType.Scriptable then
        startFreecam()
    elseif not state.freecam and camera.CameraType == Enum.CameraType.Scriptable then
        stopFreecam()
    end
end)

Players.PlayerAdded:Connect(refreshTeleportList)
Players.PlayerRemoving:Connect(refreshTeleportList)

-- Loading animation
local steps = {10, 23, 39, 56, 72, 87, 100}
for _, p in ipairs(steps) do
    task.wait(0.15)
    tween(loadBar, 0.2, {Size = UDim2.new(p / 100, 0, 1, 0)}):Play()
    loadPercent.Text = p .. "%"
end

task.wait(0.18)
app.Visible = true
app.BackgroundTransparency = 1
TweenService:Create(app, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

local fade = tween(loading, 0.3, {BackgroundTransparency = 1})
fade:Play()
fade.Completed:Wait()
loading:Destroy()

notify("Berhasil", "GUI baru berhasil dimuat. Selamat mencoba!", "success")
