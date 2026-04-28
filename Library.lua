local Input = game:GetService("UserInputService")
local Tween = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local ContentProvider = game:GetService("ContentProvider")

local Library = {
	Theme = {
		BackgroundOutline = Color3.fromRGB(10, 10, 10),
		Background = Color3.fromRGB(25, 27, 25),
		Font = Enum.Font.Code
	},
	Utils = {
		Showed = true,
		Key = nil
	}
}

getfenv().Objects = {}

local ScreenGui__ = Instance.new("ScreenGui")
ScreenGui__.Parent = CoreGui
ScreenGui__.IgnoreGuiInset = true
ScreenGui__.ResetOnSpawn = false
ScreenGui__.DisplayOrder = 10000

local function CreateObj(Class, Parametrs)
	if not Class or not Parametrs then return end
	local Obj = Instance.new(Class)
	table.insert(getfenv().Objects, Obj)
	for p,v in pairs(Parametrs) do Obj[p]=v end
	return Obj
end

local function MakeDraggable(frame, dragHandle)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	local handle = dragHandle or frame
	handle = typeof(handle) == "table" and handle[1] or handle

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	Input.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
end

function Library:CreateWindow(Parametrs)
	if not Parametrs then return end
	if typeof(Parametrs["Name"]) ~= "string" then return end

	local WindowFrame = CreateObj("Frame",{
		Parent = ScreenGui__,
		Size = UDim2.new(0, 500, 0, 550),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundColor3 = Library.Theme.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Visible = true
	})

	local TitleFrame = CreateObj("Frame", {
		Parent = WindowFrame,
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1
	})

	local TitleOutline = CreateObj("Frame", {
		Parent = TitleFrame,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Parametrs["Color"],
		BorderSizePixel = 0
	})

	local TitleInner = CreateObj("Frame", {
		Parent = TitleOutline,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0
	})

	local TitleLabel = CreateObj("TextLabel", {
		Parent = TitleInner,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = Parametrs["Name"],
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = false,
		TextSize = 14,
		Font = Library.Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left
	})

	local WindowOutline = CreateObj("Frame", {
		Parent = WindowFrame,
		Size = UDim2.new(1, -2, 1, -42),
		Position = UDim2.new(0, 1, 0, 41),
		BackgroundColor3 = Parametrs["Color"],
		BorderSizePixel = 0
	})

	local WindowInner = CreateObj("Frame", {
		Parent = WindowOutline,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0
	})

	local TabsFrame = CreateObj("Frame",{
		Parent = WindowFrame,
		Size = UDim2.new(.265, 0, 0, 550),
		Position = UDim2.new(0, -133, 0, 0),
		BackgroundTransparency = 0,
		BackgroundColor3 = Library.Theme.Background,
		BorderSizePixel = 0,
		Visible = true
	})

	local TabsOutline = CreateObj("Frame", {
		Parent = TabsFrame,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Parametrs["Color"],
		BorderSizePixel = 0
	})

	local TabsInner = CreateObj("Frame", {
		Parent = TabsOutline,
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		BackgroundColor3 = Library.Theme.BackgroundOutline,
		BorderSizePixel = 0
	})

	local TabsListLayout = CreateObj("UIListLayout", {
		Parent = TabsInner,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 5)
	})

	local TabsPadding = CreateObj("UIPadding", {
		Parent = TabsInner,
		PaddingTop = UDim.new(0, 45),
		PaddingLeft = UDim.new(0, 5),
		PaddingRight = UDim.new(0, 5)
	})

	local ContentFrame = CreateObj("Frame", {
		Parent = WindowInner,
		Size = UDim2.new(1, -10, 1, -10),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})

	MakeDraggable(WindowFrame, TitleFrame)

	local Window = {}
	Window.Tabs = {}
	Window.CurrentTab = nil

	function Window:AddTab(TabName)
		local Tab = {}
		Tab.Name = TabName
		Tab.Sections = {}
		Tab.Button = nil
		Tab.Frame = nil

		local TabButton = CreateObj("TextButton", {
			Parent = TabsInner,
			Size = UDim2.new(1, -10, 0, 30),
			BackgroundColor3 = Library.Theme.BackgroundOutline,
			BorderSizePixel = 0,
			Text = TabName,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
			Font = Library.Theme.Font,
			AutoButtonColor = false
		})

		local TabButtonOutline = CreateObj("Frame", {
			Parent = TabButton,
			Size = UDim2.new(1, 2, 1, 2),
			Position = UDim2.new(0, -1, 0, -1),
			BackgroundColor3 = Parametrs["Color"],
			BorderSizePixel = 0,
			ZIndex = 0
		})

		local TabContentFrame = CreateObj("ScrollingFrame", {
			Parent = ContentFrame,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Parametrs["Color"],
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false
		})

		local TabContentLayout = CreateObj("UIListLayout", {
			Parent = TabContentFrame,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10)
		})

		TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContentFrame.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 10)
		end)

		local TabContentPadding = CreateObj("UIPadding", {
			Parent = TabContentFrame,
			PaddingTop = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5)
		})

		Tab.Button = TabButton
		Tab.Frame = TabContentFrame

		TabButton.MouseButton1Click:Connect(function()
			for _, tab in pairs(Window.Tabs) do
				tab.Frame.Visible = false
				tab.Button.BackgroundColor3 = Library.Theme.BackgroundOutline
			end
			TabContentFrame.Visible = true
			TabButton.BackgroundColor3 = Library.Theme.Background
			Window.CurrentTab = Tab
		end)

		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			TabContentFrame.Visible = true
			TabButton.BackgroundColor3 = Library.Theme.Background
			Window.CurrentTab = Tab
		end

		function Tab:AddSection(SectionParams)
			if not SectionParams or typeof(SectionParams.Name) ~= "string" then return end

			local Section = {}
			Section.Name = SectionParams.Name

			local SectionFrame = CreateObj("Frame", {
				Parent = TabContentFrame,
				Size = UDim2.new(1, -10, 0, 30),
				BackgroundColor3 = Library.Theme.BackgroundOutline,
				BorderSizePixel = 0
			})

			local SectionOutline = CreateObj("Frame", {
				Parent = SectionFrame,
				Size = UDim2.new(1, 2, 1, 2),
				Position = UDim2.new(0, -1, 0, -1),
				BackgroundColor3 = Parametrs["Color"],
				BorderSizePixel = 0,
				ZIndex = 0
			})

			local SectionLabel = CreateObj("TextLabel", {
				Parent = SectionFrame,
				Size = UDim2.new(1, -10, 0, 30),
				Position = UDim2.new(0, 5, 0, 0),
				BackgroundTransparency = 1,
				Text = SectionParams.Name,
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 14,
				Font = Library.Theme.Font,
				TextXAlignment = Enum.TextXAlignment.Left
			})

			local SectionContent = CreateObj("Frame", {
				Parent = SectionFrame,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 30),
				BackgroundTransparency = 1,
				BorderSizePixel = 0
			})

			local SectionLayout = CreateObj("UIListLayout", {
				Parent = SectionContent,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5)
			})

			local SectionPadding = CreateObj("UIPadding", {
				Parent = SectionContent,
				PaddingTop = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5)
			})

			SectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				SectionContent.Size = UDim2.new(1, 0, 0, SectionLayout.AbsoluteContentSize.Y + 10)
				SectionFrame.Size = UDim2.new(1, -10, 0, SectionLayout.AbsoluteContentSize.Y + 40)
			end)

			function Section:AddToggle(ToggleParams)
				if not ToggleParams or typeof(ToggleParams.Name) ~= "string" then return end

				local Toggle = {}
				Toggle.Value = ToggleParams.Default or false
				Toggle.Callback = ToggleParams.Func or function() end

				local ToggleFrame = CreateObj("Frame", {
					Parent = SectionContent,
					Size = UDim2.new(1, 0, 0, 25),
					BackgroundTransparency = 1,
					BorderSizePixel = 0
				})

				local ToggleLabel = CreateObj("TextLabel", {
					Parent = ToggleFrame,
					Size = UDim2.new(1, -35, 1, 0),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					Text = ToggleParams.Name,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 13,
					Font = Library.Theme.Font,
					TextXAlignment = Enum.TextXAlignment.Left
				})

				local ToggleButton = CreateObj("TextButton", {
					Parent = ToggleFrame,
					Size = UDim2.new(0, 25, 0, 25),
					Position = UDim2.new(1, -25, 0, 0),
					BackgroundColor3 = Toggle.Value and Parametrs["Color"] or Library.Theme.BackgroundOutline,
					BorderSizePixel = 0,
					Text = "",
					AutoButtonColor = false
				})

				local ToggleButtonOutline = CreateObj("Frame", {
					Parent = ToggleButton,
					Size = UDim2.new(1, 2, 1, 2),
					Position = UDim2.new(0, -1, 0, -1),
					BackgroundColor3 = Parametrs["Color"],
					BorderSizePixel = 0,
					ZIndex = 0
				})

				ToggleButton.MouseButton1Click:Connect(function()
					Toggle.Value = not Toggle.Value
					ToggleButton.BackgroundColor3 = Toggle.Value and Parametrs["Color"] or Library.Theme.BackgroundOutline
					pcall(Toggle.Callback, Toggle.Value)
				end)

				function Toggle:Set(value)
					Toggle.Value = value
					ToggleButton.BackgroundColor3 = Toggle.Value and Parametrs["Color"] or Library.Theme.BackgroundOutline
					pcall(Toggle.Callback, Toggle.Value)
				end

				if Toggle.Value then
					pcall(Toggle.Callback, Toggle.Value)
				end

				return Toggle
			end

			function Section:AddButton(ButtonParams)
				if not ButtonParams or typeof(ButtonParams.Name) ~= "string" then return end

				local Button = {}
				Button.Callback = ButtonParams.Func or function() end

				local ButtonFrame = CreateObj("TextButton", {
					Parent = SectionContent,
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = Library.Theme.BackgroundOutline,
					BorderSizePixel = 0,
					Text = ButtonParams.Name,
					TextColor3 = Color3.new(1, 1, 1),
					TextSize = 13,
					Font = Library.Theme.Font,
					AutoButtonColor = false
				})

				local ButtonOutline = CreateObj("Frame", {
					Parent = ButtonFrame,
					Size = UDim2.new(1, 2, 1, 2),
					Position = UDim2.new(0, -1, 0, -1),
					BackgroundColor3 = Parametrs["Color"],
					BorderSizePixel = 0,
					ZIndex = 0
				})

				ButtonFrame.MouseButton1Click:Connect(function()
					pcall(Button.Callback)
				end)

				ButtonFrame.MouseEnter:Connect(function()
					ButtonFrame.BackgroundColor3 = Library.Theme.Background
				end)

				ButtonFrame.MouseLeave:Connect(function()
					ButtonFrame.BackgroundColor3 = Library.Theme.BackgroundOutline
				end)

				return Button
			end

			return Section
		end

		return Tab
	end

	return Window
end

function Library:Unload()
	pcall(function() ScreenGui__:Destroy() end)
end

function Library:SetKeybind(Key)
	Library.Utils.Key = typeof(Key) == "EnumItem" and Key or Enum.KeyCode[Key]
end

Input.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or Input:GetFocusedTextBox() then return end

	if input.KeyCode == Library.Utils.Key then
		Library.Utils.Showed = not Library.Utils.Showed
		ScreenGui__.Enabled = Library.Utils.Showed
	end
end)

return Library
