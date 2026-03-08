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

local function LoadFont()
	local fontUrl = "https://raw.githubusercontent.com/llocalsskoi/g33t_lib/refs/heads/main/Monocraft-Bold.tff"
	local fontId = nil

	pcall(function()
		local fontData = HttpService:GetAsync(fontUrl)
		if not fontData then return end
		local fontPath = "Monocraft-Bold.tff"
		writefile(fontPath, fontData)

		local fontFamilyData = HttpService:JSONEncode({
			name = "Monocraft Bold",
			faces = {
				{
					name = "Regular",
					weight = 700,
					style = "normal",
					assetId = "rbxasset://" .. fontPath
				}
			}
		})

		local familyPath = "Monocraft-Bold.json"
		writefile(familyPath, fontFamilyData)
	
		Library.Theme.CustomFont = Font.new(
			"rbxasset://" .. familyPath,
			Enum.FontWeight.Bold,
			Enum.FontStyle.Normal
		)
	end)
end

LoadFont()

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

local function ApplyFont(obj)
	if Library.Theme.CustomFont and obj:IsA("TextLabel") or
	   Library.Theme.CustomFont and obj:IsA("TextButton") or
	   Library.Theme.CustomFont and obj:IsA("TextBox") then
		pcall(function()
			obj.FontFace = Library.Theme.CustomFont
		end)
	end
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

	ApplyFont(TitleLabel)

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

	MakeDraggable(WindowFrame, TitleFrame)
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
