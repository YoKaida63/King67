-- KingV3 Complete Script (UI + Example Modules)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local KingV3 = {
    Categories = {},
    Modules = {},
    GUIColor = Color3.fromRGB(138, 43, 226),
    ActiveCategory = nil
}

-- Theme
local Theme = {
    Background = Color3.fromRGB(18, 18, 24),
    Sidebar = Color3.fromRGB(24, 24, 32),
    Element = Color3.fromRGB(28, 28, 38),
    Border = Color3.fromRGB(40, 40, 55),
    Text = Color3.fromRGB(235, 235, 245),
    SubText = Color3.fromRGB(160, 160, 175),
    Accent = Color3.fromRGB(138, 43, 226),
    Danger = Color3.fromRGB(255, 85, 85)
}

-- Helpers
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function Tween(object, time, properties)
    local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    return TweenService:Create(object, info, properties)
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KingV3_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(700, 450)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
CreateCorner(MainFrame, 10)
CreateStroke(MainFrame, Theme.Border, 1.5)

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Theme.Sidebar
Header.BorderSizePixel = 0
Header.Parent = MainFrame
CreateCorner(Header, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.fromOffset(20, 0)
Title.BackgroundTransparency = 1
Title.Text = "KING V3"
Title.TextColor3 = Theme.Accent
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(30, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Theme.Danger
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
CreateCorner(CloseBtn, 6)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)

-- Dragging
local dragging, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -40)
Sidebar.Position = UDim2.fromOffset(0, 40)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 4)
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)
SidebarPadding.Parent = Sidebar

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -160, 1, -40)
Content.Position = UDim2.fromOffset(160, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Theme.Accent
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = MainFrame

local ContentList = Instance.new("UIListLayout")
ContentList.SortOrder = Enum.SortOrder.LayoutOrder
ContentList.Padding = UDim.new(0, 8)
ContentList.Parent = Content

local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 15)
ContentPadding.PaddingLeft = UDim.new(0, 15)
ContentPadding.PaddingRight = UDim.new(0, 15)
ContentPadding.Parent = Content

-- API Functions
function KingV3:CreateCategory(name)
    local category = {
        Name = name,
        Modules = {},
        Button = nil,
        Frame = nil
    }
    
    -- Sidebar Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Theme.Sidebar
    btn.Text = "  " .. name
    btn.TextColor3 = Theme.SubText
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = Sidebar
    CreateCorner(btn, 6)
    
    -- Content Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.Parent = Content
    
    local frameList = Instance.new("UIListLayout")
    frameList.SortOrder = Enum.SortOrder.LayoutOrder
    frameList.Padding = UDim.new(0, 8)
    frameList.Parent = frame
    
    category.Button = btn
    category.Frame = frame
    self.Categories[name] = category
    
    btn.MouseButton1Click:Connect(function()
        self:SwitchCategory(name)
    end)
    
    return category
end

function KingV3:SwitchCategory(name)
    local category = self.Categories[name]
    if not category then return end
    
    if self.ActiveCategory then
        self.ActiveCategory.Frame.Visible = false
        Tween(self.ActiveCategory.Button, 0.2, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.SubText})
    end
    
    self.ActiveCategory = category
    category.Frame.Visible = true
    Tween(category.Button, 0.2, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.new(1,1,1)})
end

function KingV3:CreateModule(category, settings)
    local module = {
        Enabled = false,
        Name = settings.Name,
        Category = category.Name
    }
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Theme.Element
    container.BorderSizePixel = 0
    container.Parent = category.Frame
    CreateCorner(container, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.fromOffset(15, 0)
    label.BackgroundTransparency = 1
    label.Text = settings.Name
    label.TextColor3 = Theme.Text
    label.TextSize = 15
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.fromScale(1, 1)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Text = ""
    toggleBtn.Parent = container
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0.6, 0)
    indicator.Position = UDim2.new(0, 0, 0.2, 0)
    indicator.BackgroundColor3 = Theme.Border
    indicator.Parent = container
    CreateCorner(indicator, 2)
    
    local function updateVisuals()
        if module.Enabled then
            Tween(indicator, 0.2, {BackgroundColor3 = Theme.Accent})
            Tween(container, 0.2, {BackgroundColor3 = Color3.fromRGB(35, 35, 48)})
        else
            Tween(indicator, 0.2, {BackgroundColor3 = Theme.Border})
            Tween(container, 0.2, {BackgroundColor3 = Theme.Element})
        end
    end
    
    toggleBtn.MouseButton1Click:Connect(function()
        module.Enabled = not module.Enabled
        updateVisuals()
        if settings.Function then settings.Function(module.Enabled) end
    end)
    
    module.Object = container
    category.Modules[settings.Name] = module
    self.Modules[settings.Name] = module
    
    return module
end

-- Create Categories
local combat = KingV3:CreateCategory("Combat")
local utility = KingV3:CreateCategory("Utility")
local render = KingV3:CreateCategory("Render")

-- Create Example Modules
KingV3:CreateModule(combat, {
    Name = "Auto Clicker",
    Function = function(enabled)
        print("Auto Clicker:", enabled)
    end
})

KingV3:CreateModule(combat, {
    Name = "Reach",
    Function = function(enabled)
        print("Reach:", enabled)
    end
})

KingV3:CreateModule(utility, {
    Name = "Auto Play",
    Function = function(enabled)
        print("Auto Play:", enabled)
    end
})

KingV3:CreateModule(render, {
    Name = "ESP",
    Function = function(enabled)
        print("ESP:", enabled)
    end
})

-- Open first category
KingV3:SwitchCategory("Combat")

-- Toggle UI with RightShift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("KingV3 Loaded!")
