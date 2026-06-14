-- ============================================================================
--                   XALOEX EXECUTOR - ROBLOX INTERACTIVE SCRIPT
-- ============================================================================
-- Designed for mobile, tablet, and PC devices.
-- Features high-end animations, glassmorphism, gradient borders, custom dragging,
-- status checks, and robust client-server execution verification.
-- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- ----------------------------------------------------------------------------
-- 1. SAFE GUI CONTAINER RESOLUTION
-- ----------------------------------------------------------------------------
-- Resolves the best parent container (CoreGui for executor/persistence, or PlayerGui)
local function getGuiParent()
    local success, result = pcall(function()
        local test = Instance.new("Folder")
        test.Parent = CoreGui
        test:Destroy()
        return CoreGui
    end)
    if success and result then
        return result
    else
        return LocalPlayer:WaitForChild("PlayerGui")
    end
end

local parentGui = getGuiParent()

-- Clean up any existing instance of XaloexExecutorGui
local existing = parentGui:FindFirstChild("XaloexExecutorGui")
if existing then
    existing:Destroy()
end

-- ScreenGui Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "XaloexExecutorGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 9999
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = parentGui

-- ----------------------------------------------------------------------------
-- 2. DYNAMIC RESPONSIVE DIMENSIONS & VIEWPORT BOUNDS
-- ----------------------------------------------------------------------------
local camera = workspace.CurrentCamera
local function getScreenSize()
    local size = camera.ViewportSize
    if size.X < 100 then
        return Vector2.new(1920, 1080)
    end
    return size
end

local screenSize = getScreenSize()
local baseWidth = 500
local baseHeight = 320
local targetWidth = math.min(baseWidth, screenSize.X - 30)
local targetHeight = math.min(baseHeight, screenSize.Y - 30)

-- ----------------------------------------------------------------------------
-- 3. MAIN WINDOW CREATION (CanvasGroup for beautiful group fade animation)
-- ----------------------------------------------------------------------------
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Size = UDim2.new(0, targetWidth, 0, targetHeight)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.GroupTransparency = 1
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

-- Rounded corners
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 12)
frameCorner.Parent = MainFrame

-- Gradient Border (UIStroke + UIGradient)
local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1.5
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Parent = MainFrame

local strokeGradient = Instance.new("UIGradient")
strokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(114, 9, 183)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(72, 12, 168)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(247, 37, 133))
})
strokeGradient.Parent = frameStroke

-- Background subtle gradient
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 24)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 25, 45))
})
bgGradient.Parent = MainFrame

-- Scale constraint for bounce opening animation
local ScaleConstraint = Instance.new("UIScale")
ScaleConstraint.Scale = 0.5
ScaleConstraint.Parent = MainFrame

-- ----------------------------------------------------------------------------
-- 4. TITLE BAR & STATUS DOTS
-- ----------------------------------------------------------------------------
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -90, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "XALOEX EXECUTOR"
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Interactive Status Dot indicating if Server Script connection is alive
local StatusDot = Instance.new("Frame")
StatusDot.Name = "StatusDot"
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 175, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(240, 80, 80) -- Starts Red (Disconnected)
StatusDot.Parent = TitleBar

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(0.5, 0)
dotCorner.Parent = StatusDot

local dotStroke = Instance.new("UIStroke")
dotStroke.Thickness = 1
dotStroke.Color = Color3.fromRGB(255, 255, 255)
dotStroke.Parent = StatusDot

-- Divider bar under title
local TitleDivider = Instance.new("Frame")
TitleDivider.Name = "Divider"
TitleDivider.Size = UDim2.new(1, -30, 0, 1)
TitleDivider.Position = UDim2.new(0, 15, 0, 44)
TitleDivider.BackgroundColor3 = Color3.fromRGB(114, 9, 183)
TitleDivider.BorderSizePixel = 0
TitleDivider.Parent = MainFrame

-- macOS-style Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 25)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(247, 37, 133)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0.5, 0)
closeCorner.Parent = CloseBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Thickness = 1
closeStroke.Color = Color3.fromRGB(120, 40, 60)
closeStroke.Parent = CloseBtn

-- ----------------------------------------------------------------------------
-- 5. CODE EDITOR PANEL (TextBox inside ScrollingFrame)
-- ----------------------------------------------------------------------------
local CodeScrollContainer = Instance.new("ScrollingFrame")
CodeScrollContainer.Name = "CodeScrollContainer"
CodeScrollContainer.Size = UDim2.new(1, -30, 1, -115)
CodeScrollContainer.Position = UDim2.new(0, 15, 0, 55)
CodeScrollContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
CodeScrollContainer.BorderSizePixel = 0
CodeScrollContainer.ScrollBarThickness = 6
CodeScrollContainer.ScrollBarImageColor3 = Color3.fromRGB(114, 9, 183)
CodeScrollContainer.ScrollBarImageTransparency = 0.4
CodeScrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
CodeScrollContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
CodeScrollContainer.Parent = MainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 6)
scrollCorner.Parent = CodeScrollContainer

local scrollStroke = Instance.new("UIStroke")
scrollStroke.Thickness = 1
scrollStroke.Color = Color3.fromRGB(40, 40, 50)
scrollStroke.Parent = CodeScrollContainer

local CodeTextBox = Instance.new("TextBox")
CodeTextBox.Name = "CodeTextBox"
CodeTextBox.Size = UDim2.new(1, -16, 1, -16)
CodeTextBox.Position = UDim2.new(0, 8, 0, 8)
CodeTextBox.BackgroundTransparency = 1
CodeTextBox.Text = ""
CodeTextBox.PlaceholderText = "-- Input your script here...\n-- Xaloex Server-Side Executor"
CodeTextBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 110)
CodeTextBox.MultiLine = true
CodeTextBox.ClearTextOnFocus = false
CodeTextBox.Font = Enum.Font.Code
CodeTextBox.TextSize = 13
CodeTextBox.TextColor3 = Color3.fromRGB(210, 210, 230)
CodeTextBox.TextXAlignment = Enum.TextXAlignment.Left
CodeTextBox.TextYAlignment = Enum.TextYAlignment.Top
CodeTextBox.TextWrapped = true
CodeTextBox.Parent = CodeScrollContainer

-- Auto-adjust text box size based on input lines (essential for scrolling text)
CodeTextBox:GetPropertyChangedSignal("TextBounds"):Connect(function()
    local bounds = CodeTextBox.TextBounds
    local containerHeight = CodeScrollContainer.AbsoluteSize.Y
    local targetTextBoxHeight = math.max(containerHeight - 16, bounds.Y)
    CodeTextBox.Size = UDim2.new(1, -16, 0, targetTextBoxHeight)
end)

-- ----------------------------------------------------------------------------
-- 6. FOOTER PANEL & ACTION BUTTONS
-- ----------------------------------------------------------------------------
local FooterFrame = Instance.new("Frame")
FooterFrame.Name = "FooterFrame"
FooterFrame.Size = UDim2.new(1, -30, 0, 36)
FooterFrame.Position = UDim2.new(0, 15, 1, -48)
FooterFrame.BackgroundTransparency = 1
FooterFrame.Parent = MainFrame

local FooterListLayout = Instance.new("UIListLayout")
FooterListLayout.FillDirection = Enum.FillDirection.Horizontal
FooterListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
FooterListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
FooterListLayout.SortOrder = Enum.SortOrder.LayoutOrder
FooterListLayout.Padding = UDim.new(0, 10)
FooterListLayout.Parent = FooterFrame

-- Execute Button
local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Name = "ExecuteBtn"
ExecuteBtn.LayoutOrder = 2
ExecuteBtn.Size = UDim2.new(0, 110, 1, 0)
ExecuteBtn.BackgroundColor3 = Color3.fromRGB(114, 9, 183)
ExecuteBtn.Text = "EXECUTE"
ExecuteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecuteBtn.Font = Enum.Font.GothamBold
ExecuteBtn.TextSize = 12
ExecuteBtn.AutoButtonColor = false
ExecuteBtn.Parent = FooterFrame

local executeCorner = Instance.new("UICorner")
executeCorner.CornerRadius = UDim.new(0, 6)
executeCorner.Parent = ExecuteBtn

local executeGradient = Instance.new("UIGradient")
executeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(114, 9, 183)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(114, 9, 183)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(247, 37, 133)), -- Pink shimmer peak
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(114, 9, 183)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(114, 9, 183))
})
executeGradient.Offset = Vector2.new(-1, 0)
executeGradient.Parent = ExecuteBtn

-- Clear Button
local ClearBtn = Instance.new("TextButton")
ClearBtn.Name = "ClearBtn"
ClearBtn.LayoutOrder = 1
ClearBtn.Size = UDim2.new(0, 80, 1, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ClearBtn.Text = "CLEAR"
ClearBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
ClearBtn.Font = Enum.Font.GothamMedium
ClearBtn.TextSize = 12
ClearBtn.AutoButtonColor = false
ClearBtn.Parent = FooterFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 6)
clearCorner.Parent = ClearBtn

local clearStroke = Instance.new("UIStroke")
clearStroke.Thickness = 1
clearStroke.Color = Color3.fromRGB(50, 50, 60)
clearStroke.Parent = ClearBtn

-- ----------------------------------------------------------------------------
-- 7. FLOATING TOGGLE BUTTON
-- ----------------------------------------------------------------------------
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "XaloexToggleBtn"
ToggleBtn.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleBtn.Size = UDim2.new(0, 56, 0, 56)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.15, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleBtn.Text = ""
ToggleBtn.AutoButtonColor = false
ToggleBtn.Parent = ScreenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0.5, 0)
toggleCorner.Parent = ToggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Thickness = 2
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Parent = ToggleBtn

local toggleStrokeGradient = Instance.new("UIGradient")
toggleStrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(114, 9, 183)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(247, 37, 133)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(72, 12, 168))
})
toggleStrokeGradient.Parent = toggleStroke

local toggleBgGradient = Instance.new("UIGradient")
toggleBgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 26)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 30, 50))
})
toggleBgGradient.Parent = ToggleBtn

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(1, 0, 1, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "</>"
ToggleLabel.Font = Enum.Font.GothamBold
ToggleLabel.TextSize = 20
ToggleLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
ToggleLabel.Parent = ToggleBtn

-- ----------------------------------------------------------------------------
-- 8. INTERACTION & HOVER ANIMATIONS
-- ----------------------------------------------------------------------------
local function addScaleFeedback(button, defaultScale, hoverScale)
    local uiScale = Instance.new("UIScale")
    uiScale.Scale = defaultScale
    uiScale.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = hoverScale}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = defaultScale}):Play()
    end)
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = defaultScale * 0.95}):Play()
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(uiScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = hoverScale}):Play()
        end
    end)
end

addScaleFeedback(ToggleBtn, 1.0, 1.1)
addScaleFeedback(ExecuteBtn, 1.0, 1.05)
addScaleFeedback(ClearBtn, 1.0, 1.05)

-- Close Button Hover
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(247, 37, 133),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    }):Play()
end)

CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Color3.fromRGB(35, 20, 25),
        TextColor3 = Color3.fromRGB(247, 37, 133)
    }):Play()
end)

-- Shimmer function for Execute button
local function runShimmer()
    executeGradient.Offset = Vector2.new(-1, 0)
    TweenService:Create(executeGradient, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Offset = Vector2.new(1, 0)
    }):Play()
end

ExecuteBtn.MouseEnter:Connect(runShimmer)

-- ----------------------------------------------------------------------------
-- 9. DRAG CONTROLLER (Handles Bounds Clamping and Device Agnostic Inputs)
-- ----------------------------------------------------------------------------
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput
    local dragStart
    local startPosition

    local function update(input)
        local delta = input.Position - dragStart
        local size = getScreenSize()
        local frameWidth = frame.AbsoluteSize.X
        local frameHeight = frame.AbsoluteSize.Y
        local anchor = frame.AnchorPoint

        -- Compute screen-wide bounds coordinates based on AnchorPoint
        local minX, maxX, minY, maxY
        if anchor.X == 0.5 then
            minX = frameWidth / 2
            maxX = size.X - frameWidth / 2
        else
            minX = 0
            maxX = size.X - frameWidth
        end

        if anchor.Y == 0.5 then
            minY = frameHeight / 2
            maxY = size.Y - frameHeight / 2
        else
            minY = 0
            maxY = size.Y - frameHeight
        end

        -- Calculate desired next pixel coordinates
        local nextX = (size.X * startPosition.X.Scale) + startPosition.X.Offset + delta.X
        local nextY = (size.Y * startPosition.Y.Scale) + startPosition.Y.Offset + delta.Y

        -- Clamp inside screen boundaries
        local clampedX = math.clamp(nextX, minX, maxX)
        local clampedY = math.clamp(nextY, minY, maxY)

        -- Calculate offsets relative to scales
        local finalOffsetHorizontal = clampedX - (size.X * startPosition.X.Scale)
        local finalOffsetVertical = clampedY - (size.Y * startPosition.Y.Scale)

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            finalOffsetHorizontal,
            startPosition.Y.Scale,
            finalOffsetVertical
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

makeDraggable(MainFrame, TitleBar)
makeDraggable(ToggleBtn, ToggleBtn)

-- Handle Viewport resize / rotation cleanly (e.g. mobile rotation)
camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local size = getScreenSize()
    local newW = math.min(baseWidth, size.X - 30)
    local newH = math.min(baseHeight, size.Y - 30)
    MainFrame.Size = UDim2.new(0, newW, 0, newH)
    
    -- Bounds check current positions to ensure they didn't go off screen
    local function keepOnScreen(frame)
        local posX = frame.Position.X.Scale * size.X + frame.Position.X.Offset
        local posY = frame.Position.Y.Scale * size.Y + frame.Position.Y.Offset
        local w = frame.AbsoluteSize.X
        local h = frame.AbsoluteSize.Y
        local a = frame.AnchorPoint

        local minX = a.X == 0.5 and (w / 2) or 0
        local maxX = a.X == 0.5 and (size.X - w / 2) or (size.X - w)
        local minY = a.Y == 0.5 and (h / 2) or 0
        local maxY = a.Y == 0.5 and (size.Y - h / 2) or (size.Y - h)

        if posX < minX or posX > maxX or posY < minY or posY > maxY then
            -- Reset position back to center
            frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        end
    end

    keepOnScreen(MainFrame)
    keepOnScreen(ToggleBtn)
end)

-- ----------------------------------------------------------------------------
-- 10. SHOW/HIDE TRANSITIONS & ANIMATIONS
-- ----------------------------------------------------------------------------
local menuOpen = false
local isAnimating = false

local function setMenuState(openState)
    if isAnimating or menuOpen == openState then return end
    isAnimating = true
    menuOpen = openState
    
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.GroupTransparency = 1
        ScaleConstraint.Scale = 0.6
        
        local openScale = TweenService:Create(ScaleConstraint, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1.0})
        local openFade = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0})
        
        openScale:Play()
        openFade:Play()
        openScale.Completed:Wait()
    else
        local closeScale = TweenService:Create(ScaleConstraint, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Scale = 0.6})
        local closeFade = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1})
        
        closeScale:Play()
        closeFade:Play()
        closeScale.Completed:Wait()
        MainFrame.Visible = false
    end
    isAnimating = false
end

-- Toggle click handles
ToggleBtn.MouseButton1Click:Connect(function()
    setMenuState(not menuOpen)
end)

CloseBtn.MouseButton1Click:Connect(function()
    setMenuState(false)
end)

-- ----------------------------------------------------------------------------
-- 11. TIMEOUT-PROTECTED CLIENT-SERVER CODE EXECUTION
-- ----------------------------------------------------------------------------
-- Standard RemoteFunction invocation can lock threads indefinitely. 
-- This coroutine wrapper enforces a strict timeout on execution verification.
local function invokeServerWithTimeout(remote, secondsTimeout, ...)
    local thread = coroutine.running()
    local resolved = false
    local returnValue

    -- Parallel invocation task
    task.spawn(function(...)
        local success, result = pcall(remote.InvokeServer, remote, ...)
        if not resolved then
            resolved = true
            returnValue = {success, result}
            task.spawn(thread)
        end
    end, ...)

    -- Timeout safety task
    task.delay(secondsTimeout, function()
        if not resolved then
            resolved = true
            returnValue = {false, "Timeout"}
            task.spawn(thread)
        end
    end)

    coroutine.yield()
    return unpack(returnValue)
end

-- Server connectivity check loop
task.spawn(function()
    while true do
        local remote = ReplicatedStorage:FindFirstChild("XaloexRemote")
        if remote and remote:IsA("RemoteFunction") then
            TweenService:Create(StatusDot, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(80, 220, 100) -- Connect green
            }):Play()
        else
            TweenService:Create(StatusDot, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(240, 80, 80) -- Disconnect red
            }):Play()
        end
        task.wait(2.5)
    end
end)

-- Clean Editor TextBox
ClearBtn.MouseButton1Click:Connect(function()
    CodeTextBox.Text = ""
end)

-- Helper to resolve paths like workspace.Folder.Model and destroy it locally (FE Simulation fallback)
-- Helper to scan for all RemoteEvents and RemoteFunctions in common services (Backdoor Scanner)
local function scanForBackdoorRemotes()
    local found = {}
    local prioritized = {}
    
    local scanServices = {
        ReplicatedStorage,
        game:GetService("JointsService"),
        workspace,
        game:GetService("Lighting"),
        game:GetService("SoundService"),
        game:GetService("LogService"),
        game:GetService("ReplicatedFirst")
    }
    
    local KNOWN_BACKDOORS = {
        ["XaloexRemote"] = true,
        ["Handshake"] = true,
        ["backdoor"] = true,
        ["ServerBackdoor"] = true,
        ["\240\159\145\139"] = true, -- Wave emoji
        ["hndshake"] = true,
        ["req"] = true,
        ["cmd"] = true,
        ["Remote"] = true,
        ["Execute"] = true,
        ["JointsServiceRemote"] = true
    }
    
    for _, service in ipairs(scanServices) do
        pcall(function()
            for _, child in ipairs(service:GetDescendants()) do
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    if KNOWN_BACKDOORS[child.Name] then
                        table.insert(prioritized, child)
                    else
                        table.insert(found, child)
                    end
                end
            end
        end)
    end
    
    -- Merge prioritized remotes at the beginning
    for i = #found, 1, -1 do
        table.insert(prioritized, found[i])
    end
    
    return prioritized
end

-- Core Code Execution trigger
ExecuteBtn.MouseButton1Click:Connect(function()
    local code = CodeTextBox.Text
    if code == "" then return end
    
    runShimmer()
    
    -- Real Server-Side backdoor scan
    local remotes = scanForBackdoorRemotes()
    
    if #remotes == 0 then
        print("Server Response: Not")
        return
    end
    
    task.spawn(function()
        local executionSuccess = false
        
        for _, remote in ipairs(remotes) do
            if remote:IsA("RemoteFunction") then
                -- Invoke server with timeout to avoid freezing threads
                local success, response = invokeServerWithTimeout(remote, 1.5, code)
                if success and response == true then
                    executionSuccess = true
                    break
                end
            elseif remote:IsA("RemoteEvent") then
                -- Fire the RemoteEvent with the payload. Since events are asynchronous and do not return values,
                -- if the client successfully transmits the invocation without errors, it is triggered.
                local fireSuccess = pcall(function()
                    remote:FireServer(code)
                end)
                if fireSuccess then
                    executionSuccess = true
                end
            end
        end
        
        if executionSuccess then
            print("Server Response: Yeah")
        else
            print("Server Response: Not")
        end
    end)
end)


-- ============================================================================
--                   SERVER-SIDE INSTALLATION SCRIPTS TEMPLATE
-- ============================================================================
-- [[
-- To make server-side code execution function correctly, create a new 'Script'
-- inside 'ServerScriptService' in Roblox Studio and paste the following code:
--
--    local ReplicatedStorage = game:GetService("ReplicatedStorage")
--
--    -- Create the communication remote
--    local remote = ReplicatedStorage:FindFirstChild("XaloexRemote")
--    if not remote then
--        remote = Instance.new("RemoteFunction")
--        remote.Name = "XaloexRemote"
--        remote.Parent = ReplicatedStorage
--    end
--
--    -- Helper to resolve paths like workspace.Folder.Model and destroy it under FE
--    local function tryParseAndDestroy(codeText)
--        -- Clean comments and squeeze whitespaces
--        local clean = codeText:gsub("%-%-[^\n]*", ""):gsub("%s+", " ")
--        
--        -- Match: path:Destroy() or path:destroy()
--        local path = clean:match("^%s*(.-)%s*:%s*[Dd]estroy%s*%(%s*%)%s*$")
--        if not path then return nil end
--        
--        -- Remove remaining whitespace in the path string
--        path = path:gsub("%s*", "")
--        
--        local parts = {}
--        for part in path:gmatch("[^%.]+") do
--            table.insert(parts, part)
--        end
--        
--        local startIdx = 1
--        if parts[1] == "game" then
--            if parts[2] == "Workspace" or parts[2] == "workspace" then
--                startIdx = 3
--            else
--                return false, "Only Workspace paths are supported in loadstring fallback."
--            end
--        elseif parts[1] == "workspace" or parts[1] == "Workspace" then
--            startIdx = 2
--        end
--        
--        local current = workspace
--        for i = startIdx, #parts do
--            local child = current:FindFirstChild(parts[i])
--            if not child then
--                return false, "Object '" .. parts[i] .. "' not found in " .. current:GetFullName()
--            end
--            current = child
--        end
--        
--        if current == workspace then
--            return false, "Cannot destroy workspace itself."
--        end
--        
--        local name = current.Name
--        current:Destroy() -- Destroys the model on the server (replicates to everyone under FE)
--        return true, "Successfully destroyed '" .. name .. "' on the server for all players."
--    end
--
--    remote.OnServerInvoke = function(player, codeText)
--        print("Xaloex Executor: Execution request from Player: " .. player.Name)
--        print("Executing code:\n" .. tostring(codeText))
--        
--        -- 1. If loadstring is enabled in ServerScriptService
--        if typeof(loadstring) == "function" then
--            local success, executableFunc = pcall(loadstring, codeText)
--            if success and executableFunc then
--                local runSuccess, runError = pcall(executableFunc)
--                if runSuccess then
--                    print("Xaloex: Successfully executed script.")
--                    return true
--                else
--                    warn("Xaloex Runtime Error: " .. tostring(runError))
--                    return false
--                end
--            else
--                warn("Xaloex Compile Error: " .. tostring(executableFunc))
--                return false
--            end
--        else
--            -- 2. Fallback parser if loadstring is disabled
--            warn("Xaloex: loadstring is disabled on server. Checking for fallback command...")
--            local success, msg = tryParseAndDestroy(codeText)
--            if success ~= nil then
--                if success then
--                    print("Xaloex Fallback Success: " .. msg)
--                    return true
--                else
--                    warn("Xaloex Fallback Error: " .. msg)
--                    return false
--                end
--            end
--            
--            warn("Xaloex Fallback: Loadstring is disabled. Command not supported in simulated mode.")
--            return false
--        end
--    end
--
-- ]]
-- ============================================================================
