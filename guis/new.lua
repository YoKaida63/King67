-- KingV3 UI Framework
-- Modern Sidebar Dashboard Design

local mainapi = {
	Categories = {},
	GUIColor = {Hue = 0.75, Sat = 0.9, Value = 0.9}, -- Default Neon Purple
	Modules = {},
	Loaded = false,
	Libraries = {},
	Windows = {},
	Version = "3.0"
}

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme Configuration
local Theme = {
	Background = Color3.fromRGB(18, 18, 24),
	Sidebar = Color3.fromRGB(24, 24, 32),
	Element = Color3.fromRGB(28, 28, 38),
	Border = Color3.fromRGB(40, 40, 55),
	Text = Color3.fromRGB(235, 235, 245),
	SubText = Color3.fromRGB(160, 160, 175),
	Accent = Color3.fromRGB(138, 43, 226), -- Neon Purple
	Success = Color3.fromRGB(80, 250, 123),
	Danger = Color3.fromRGB(255, 85, 85)
}

-- Helper Functions
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

local function GetTextSize(text, size, font)
	return TextService:GetTextSize(text, size, font, Vector2.new(1000, 1000))
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KingV3_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

if gethui then
	ScreenGui.Parent = gethui()
else
	ScreenGui.Parent = CoreGui
end

-- Main Container
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

CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, 0.1, {BackgroundColor3 = Color3.fromRGB(255, 120, 120)}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, 0.1, {BackgroundColor3 = Theme.Danger}) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = false end)

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

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
Header.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Component Library
local Components = {}

Components.Toggle = function(settings, parent, moduleApi)
	local optionApi = {Enabled = settings.Default or false, Type = "Toggle"}
	
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 35)
	container.BackgroundColor3 = Theme.Element
	container.BorderSizePixel = 0
	container.Parent = parent
	CreateCorner(container, 6)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = settings.Name
	label.TextColor3 = Theme.Text
	label.TextSize = 14
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	
	local switchBg = Instance.new("Frame")
	switchBg.Size = UDim2.fromOffset(36, 20)
	switchBg.Position = UDim2.new(1, -44, 0.5, -10)
	switchBg.BackgroundColor3 = Theme.Border
	switchBg.Parent = container
	CreateCorner(switchBg, 10)
	
	local switchKnob = Instance.new("Frame")
	switchKnob.Size = UDim2.fromOffset(16, 16)
	switchKnob.Position = UDim2.fromOffset(2, 2)
	switchKnob.BackgroundColor3 = Color3.new(1, 1, 1)
	switchKnob.Parent = switchBg
	CreateCorner(switchKnob, 8)
	
	local function updateVisuals()
		if optionApi.Enabled then
			Tween(switchBg, 0.2, {BackgroundColor3 = Theme.Accent})
			Tween(switchKnob, 0.2, {Position = UDim2.fromOffset(18, 2)})
		else
			Tween(switchBg, 0.2, {BackgroundColor3 = Theme.Border})
			Tween(switchKnob, 0.2, {Position = UDim2.fromOffset(2, 2)})
		end
	end
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = container
	
	btn.MouseButton1Click:Connect(function()
		optionApi.Enabled = not optionApi.Enabled
		updateVisuals()
		if settings.Function then settings.Function(optionApi.Enabled) end
	end)
	
	updateVisuals()
	optionApi.Object = container
	return optionApi
end

Components.Slider = function(settings, parent, moduleApi)
	local optionApi = {Value = settings.Default or settings.Min, Type = "Slider"}
	
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 45)
	container.BackgroundColor3 = Theme.Element
	container.BorderSizePixel = 0
	container.Parent = parent
	CreateCorner(container, 6)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.5, 0, 0, 20)
	label.Position = UDim2.fromOffset(12, 5)
	label.BackgroundTransparency = 1
	label.Text = settings.Name
	label.TextColor3 = Theme.Text
	label.TextSize = 14
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0.5, -20, 0, 20)
	valueLabel.Position = UDim2.new(0.5, 10, 0, 5)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(optionApi.Value)
	valueLabel.TextColor3 = Theme.Accent
	valueLabel.TextSize = 14
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Parent = container
	
	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -24, 0, 6)
	track.Position = UDim2.fromOffset(12, 30)
	track.BackgroundColor3 = Theme.Border
	track.Parent = container
	CreateCorner(track, 3)
	
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((optionApi.Value - settings.Min) / (settings.Max - settings.Min), 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.Parent = track
	CreateCorner(fill, 3)
	
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(14, 14)
	knob.Position = UDim2.new((optionApi.Value - settings.Min) / (settings.Max - settings.Min), -7, 0.5, -7)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.Parent = track
	CreateCorner(knob, 7)
	
	local sliding = false
	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
			local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			local newVal = math.floor(settings.Min + (settings.Max - settings.Min) * percent)
			optionApi.Value = newVal
			fill.Size = UDim2.fromScale(percent, 1)
			knob.Position = UDim2.new(percent, -7, 0.5, -7)
			valueLabel.Text = tostring(newVal)
			if settings.Function then settings.Function(newVal) end
		end
	end)
	
	optionApi.Object = container
	return optionApi
end

Components.Dropdown = function(settings, parent, moduleApi)
	local optionApi = {Value = settings.List[1] or "None", Type = "Dropdown"}
	
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 35)
	container.BackgroundColor3 = Theme.Element
	container.BorderSizePixel = 0
	container.Parent = parent
	CreateCorner(container, 6)
	
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = container
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Position = UDim2.fromOffset(12, 0)
	label.BackgroundTransparency = 1
	label.Text = settings.Name .. ": " .. optionApi.Value
	label.TextColor3 = Theme.Text
	label.TextSize = 14
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container
	
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.fromOffset(20, 20)
	arrow.Position = UDim2.new(1, -25, 0.5, -10)
	arrow.BackgroundTransparency = 1
	arrow.Text = "v"
	arrow.TextColor3 = Theme.SubText
	arrow.TextSize = 14
	arrow.Font = Enum.Font.GothamBold
	arrow.Parent = container
	
	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(1, 0, 0, 0)
	listFrame.Position = UDim2.fromOffset(0, 35)
	listFrame.BackgroundColor3 = Theme.Element
	listFrame.BorderSizePixel = 0
	listFrame.Visible = false
	listFrame.Parent = container
	CreateCorner(listFrame, 6)
	listFrame.ClipsDescendants = true
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = listFrame
	
	btn.MouseButton1Click:Connect(function()
		listFrame.Visible = not listFrame.Visible
		if listFrame.Visible then
			listFrame.Size = UDim2.new(1, 0, 0, #settings.List * 30)
			Tween(listFrame, 0.2, {Size = UDim2.new(1, 0, 0, #settings.List * 30)})
		else
			Tween(listFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
			task.delay(0.2, function() listFrame.Visible = false end)
		end
	end)
	
	for _, val in ipairs(settings.List) do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 30)
		optBtn.BackgroundColor3 = Theme.Element
		optBtn.Text = "  " .. val
		optBtn.TextColor3 = Theme.Text
		optBtn.TextSize = 13
		optBtn.Font = Enum.Font.Gotham
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		optBtn.Parent = listFrame
		
		optBtn.MouseEnter:Connect(function() Tween(optBtn, 0.1, {BackgroundColor3 = Theme.Border}) end)
		optBtn.MouseLeave:Connect(function() Tween(optBtn, 0.1, {BackgroundColor3 = Theme.Element}) end)
		
		optBtn.MouseButton1Click:Connect(function()
			optionApi.Value = val
			label.Text = settings.Name .. ": " .. val
			listFrame.Visible = false
			Tween(listFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
			task.delay(0.2, function() listFrame.Visible = false end)
			if settings.Function then settings.Function(val) end
		end)
	end
	
	optionApi.Object = container
	return optionApi
end

-- API Functions
function mainapi:CreateCategory(name)
	local categoryApi = {
		Name = name,
		Modules = {},
		Button = nil,
		Frame = nil
	}
	
	-- Sidebar Button
	local btn = Instance.new("TextButton")
	btn.Name = name .. "_Btn"
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
	frame.Name = name .. "_Content"
	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = Content
	
	local frameList = Instance.new("UIListLayout")
	frameList.SortOrder = Enum.SortOrder.LayoutOrder
	frameList.Padding = UDim.new(0, 8)
	frameList.Parent = frame
	
	categoryApi.Button = btn
	categoryApi.Frame = frame
	
	btn.MouseEnter:Connect(function()
		if self.ActiveCategory ~= categoryApi then
			Tween(btn, 0.2, {BackgroundColor3 = Theme.Border, TextColor3 = Theme.Text})
		end
	end)
	btn.MouseLeave:Connect(function()
		if self.ActiveCategory ~= categoryApi then
			Tween(btn, 0.2, {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.SubText})
		end
	end)
	
	btn.MouseButton1Click:Connect(function()
		self:SwitchCategory(name)
	end)
	
	self.Categories[name] = categoryApi
	return categoryApi
end

function mainapi:SwitchCategory(name)
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

function mainapi:CreateModule(category, settings)
	local moduleApi = {
		Enabled = false,
		Options = {},
		Name = settings.Name,
		Category = category.Name
	}
	
	local container = Instance.new("Frame")
	container.Name = settings.Name
	container.Size = UDim2.new(1, 0, 0, 40)
	container.BackgroundColor3 = Theme.Element
	container.BorderSizePixel = 0
	container.Parent = category.Frame
	CreateCorner(container, 6)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
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
	
	-- Options Container (Hidden by default)
	local optionsFrame = Instance.new("Frame")
	optionsFrame.Size = UDim2.new(1, 0, 0, 0)
	optionsFrame.Position = UDim2.fromOffset(0, 40)
	optionsFrame.BackgroundColor3 = Theme.Background
	optionsFrame.BorderSizePixel = 0
	optionsFrame.Visible = false
	optionsFrame.Parent = container
	CreateCorner(optionsFrame, 6)
	optionsFrame.ClipsDescendants = true
	
	local optionsList = Instance.new("UIListLayout")
	optionsList.SortOrder = Enum.SortOrder.LayoutOrder
	optionsList.Padding = UDim.new(0, 4)
	optionsList.Parent = optionsFrame
	
	local optionsPadding = Instance.new("UIPadding")
	optionsPadding.PaddingTop = UDim.new(0, 8)
	optionsPadding.PaddingLeft = UDim.new(0, 8)
	optionsPadding.PaddingRight = UDim.new(0, 8)
	optionsPadding.PaddingBottom = UDim.new(0, 8)
	optionsPadding.Parent = optionsFrame
	
	local isOpen = false
	
	local function updateVisuals()
		if moduleApi.Enabled then
			Tween(indicator, 0.2, {BackgroundColor3 = Theme.Accent})
			Tween(container, 0.2, {BackgroundColor3 = Color3.fromRGB(35, 35, 48)})
		else
			Tween(indicator, 0.2, {BackgroundColor3 = Theme.Border})
			Tween(container, 0.2, {BackgroundColor3 = Theme.Element})
		end
	end
	
	toggleBtn.MouseButton1Click:Connect(function()
		moduleApi.Enabled = not moduleApi.Enabled
		updateVisuals()
		if settings.Function then settings.Function(moduleApi.Enabled) end
	end)
	
	-- Right Click to Expand Options
	toggleBtn.MouseButton2Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			optionsFrame.Visible = true
			Tween(optionsFrame, 0.2, {Size = UDim2.new(1, 0, 0, optionsList.AbsoluteContentSize.Y + 16)})
			Tween(container, 0.2, {Size = UDim2.new(1, 0, 0, 40 + optionsList.AbsoluteContentSize.Y + 16)})
		else
			Tween(optionsFrame, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
			Tween(container, 0.2, {Size = UDim2.new(1, 0, 0, 40)})
			task.delay(0.2, function() optionsFrame.Visible = false end)
		end
	end)
	
	-- Component Creators for this Module
	function moduleApi:CreateToggle(settings)
		settings.Function = settings.Function or function() end
		local opt = Components.Toggle(settings, optionsFrame, moduleApi)
		table.insert(moduleApi.Options, opt)
		return opt
	end
	
	function moduleApi:CreateSlider(settings)
		settings.Function = settings.Function or function() end
		local opt = Components.Slider(settings, optionsFrame, moduleApi)
		table.insert(moduleApi.Options, opt)
		return opt
	end
	
	function moduleApi:CreateDropdown(settings)
		settings.Function = settings.Function or function() end
		local opt = Components.Dropdown(settings, optionsFrame, moduleApi)
		table.insert(moduleApi.Options, opt)
		return opt
	end
	
	moduleApi.Object = container
	category.Modules[settings.Name] = moduleApi
	self.Modules[settings.Name] = moduleApi
	
	return moduleApi
end

-- Notifications
function mainapi:CreateNotification(title, text, duration)
	local notif = Instance.new("Frame")
	notif.Size = UDim2.fromOffset(250, 60)
	notif.Position = UDim2.new(1, 260, 1, -80)
	notif.BackgroundColor3 = Theme.Sidebar
	notif.BorderSizePixel = 0
	notif.Parent = ScreenGui
	CreateCorner(notif, 8)
	CreateStroke(notif, Theme.Accent, 2)
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 20)
	titleLabel.Position = UDim2.fromOffset(10, 5)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Accent
	titleLabel.TextSize = 14
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = notif
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -20, 0, 30)
	textLabel.Position = UDim2.fromOffset(10, 25)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Theme.Text
	textLabel.TextSize = 12
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextWrapped = true
	textLabel.Parent = notif
	
	Tween(notif, 0.4, {Position = UDim2.new(1, -260, 1, -80)})
	task.delay(duration or 3, function()
		Tween(notif, 0.4, {Position = UDim2.new(1, 260, 1, -80)})
		task.delay(0.5, function() notif:Destroy() end)
	end)
end

-- Initialization
local combat = mainapi:CreateCategory("Combat")
local utility = mainapi:CreateCategory("Utility")
local render = mainapi:CreateCategory("Render")

-- Example Module
local testMod = mainapi:CreateModule(combat, {
	Name = "Test Module",
	Function = function(state)
		print("Test Module:", state)
	end
})

testMod:CreateToggle({Name = "Enable Feature", Default = false})
testMod:CreateSlider({Name = "Range", Min = 1, Max = 100, Default = 50})
testMod:CreateDropdown({Name = "Mode", List = {"Silent", "Legit", "Rage"}})

mainapi:SwitchCategory("Combat")
mainapi.Loaded = true

-- Global Access
shared.vape = mainapi
getgenv().vape = mainapi

return mainapi
