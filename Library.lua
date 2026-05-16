-- UILibrary.lua
-- Phantom Forces / BLooket-style config UI
-- Usage: local UI = loadstring(...)() or require(...)

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ─────────────────────────────────────────────
-- THEME
-- ─────────────────────────────────────────────
local Theme = {
    Bg1          = Color3.fromRGB(22, 22, 22),   -- outer window
    Bg2          = Color3.fromRGB(14, 14, 14),   -- inner / content
    Bg3          = Color3.fromRGB(30, 30, 30),   -- element bg
    Accent       = Color3.fromRGB(115, 255, 115),-- green outline / active
    AccentDim    = Color3.fromRGB(60, 140, 60),  -- subdued green
    TextPrimary  = Color3.fromRGB(220, 220, 220),
    TextSecondary= Color3.fromRGB(140, 140, 140),
    TextAccent   = Color3.fromRGB(185, 255, 185),
    Outline      = Color3.fromRGB(55, 55, 55),
    TabActive    = Color3.fromRGB(30, 30, 30),
    TabInactive  = Color3.fromRGB(18, 18, 18),
    Toggle_ON    = Color3.fromRGB(80, 200, 80),
    Toggle_OFF   = Color3.fromRGB(55, 55, 55),
    SliderFill   = Color3.fromRGB(115, 255, 115),
    SliderTrack  = Color3.fromRGB(40, 40, 40),
    DropBg       = Color3.fromRGB(20, 20, 20),
    DropHover    = Color3.fromRGB(38, 38, 38),
    KeybindBg    = Color3.fromRGB(28, 28, 28),
    SectionLine  = Color3.fromRGB(40, 40, 40),
    TitleBg      = Color3.fromRGB(12, 12, 12),
}

-- ─────────────────────────────────────────────
-- HELPERS
-- ─────────────────────────────────────────────
local function New(cls, props, children)
    local obj = Instance.new(cls)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad), props):Play()
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame

    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inp.Position
            startPos = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function Stroke(parent, color, thickness)
    return New("UIStroke", {
        Color = color or Theme.Outline,
        Thickness = thickness or 1,
        Parent = parent,
    })
end

local function Corner(parent, radius)
    return New("UICorner", { CornerRadius = UDim.new(0, radius or 3), Parent = parent })
end

local function Pad(parent, t, r, b, l)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, t or 4),
        PaddingRight  = UDim.new(0, r or 6),
        PaddingBottom = UDim.new(0, b or 4),
        PaddingLeft   = UDim.new(0, l or 6),
        Parent = parent,
    })
end

local function Label(props)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        TextColor3 = props.color or Theme.TextPrimary,
        Font = props.font or Enum.Font.Code,
        TextSize = props.size or 11,
        Text = props.text or "",
        TextXAlignment = props.xa or Enum.TextXAlignment.Left,
        TextYAlignment = props.ya or Enum.TextYAlignment.Center,
        Size = props.size2 or UDim2.new(1, 0, 0, 16),
        Position = props.pos or UDim2.new(0, 0, 0, 0),
        ZIndex = props.z or 2,
    })
end

-- ─────────────────────────────────────────────
-- CONSTRUCTION TABLE
-- ─────────────────────────────────────────────
local Construction = {}
Construction.__index = Construction

-- ─────────────────────────────────────────────
-- WINDOW
-- ─────────────────────────────────────────────
function Construction:CreateWindow(Params)
    assert(Params and Params.Text, "[UILib] CreateWindow requires Params.Text")

    local tabs     = {}
    local tabBtns  = {}
    local activeTab

    local W = Params.Width  or 420
    local H = Params.Height or 320

    -- Root ScreenGui
    local SG = New("ScreenGui", {
        Name           = "UILib_" .. Params.Text,
        ResetOnSpawn   = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent         = CoreGui,
    })

    -- Outer window frame
    local WinFrame = New("Frame", {
        Name              = "Window",
        Size              = UDim2.new(0, W, 0, H),
        Position          = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3  = Theme.Bg1,
        BorderSizePixel   = 0,
        ZIndex            = 2,
        Parent            = SG,
    })
    Stroke(WinFrame, Theme.Accent, 1)

    -- Title bar
    local TitleBar = New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Theme.TitleBg,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = WinFrame,
    })

    local TitleLabel = New("TextLabel", {
        Size               = UDim2.new(1, -8, 1, 0),
        Position           = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text               = Params.Text,
        TextColor3         = Theme.Accent,
        Font               = Enum.Font.Code,
        TextSize           = 11,
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 4,
        Parent             = TitleBar,
    })

    -- Subtitle / version
    if Params.SubText then
        New("TextLabel", {
            Size               = UDim2.new(0.5, 0, 1, 0),
            Position           = UDim2.new(0.5, -4, 0, 0),
            BackgroundTransparency = 1,
            Text               = Params.SubText,
            TextColor3         = Theme.TextSecondary,
            Font               = Enum.Font.Code,
            TextSize           = 10,
            TextXAlignment     = Enum.TextXAlignment.Right,
            ZIndex             = 4,
            Parent             = TitleBar,
        })
    end

    MakeDraggable(WinFrame, TitleBar)

    -- Tab bar
    local TabBar = New("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, 0, 0, 18),
        Position         = UDim2.new(0, 0, 0, 22),
        BackgroundColor3 = Theme.Bg2,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = WinFrame,
    })

    local TabLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Parent        = TabBar,
    })

    -- Separator below tab bar
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = WinFrame,
    })

    -- Content area
    local ContentArea = New("Frame", {
        Name             = "Content",
        Size             = UDim2.new(1, 0, 1, -42),
        Position         = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Theme.Bg2,
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = WinFrame,
    })

    -- Window object
    local WindowObj = {}

    -- ── AddTab ──────────────────────────────────
    function WindowObj:AddTab(tabName)
        local tabFrame = New("ScrollingFrame", {
            Name                      = tabName,
            Size                      = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency    = 1,
            BorderSizePixel           = 0,
            ScrollBarThickness        = 3,
            ScrollBarImageColor3      = Theme.AccentDim,
            CanvasSize                = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize       = Enum.AutomaticSize.Y,
            Visible                   = false,
            ZIndex                    = 2,
            Parent                    = ContentArea,
        })
        New("UIListLayout", {
            SortOrder  = Enum.SortOrder.LayoutOrder,
            Padding    = UDim.new(0, 0),
            Parent     = tabFrame,
        })
        Pad(tabFrame, 4, 4, 4, 4)

        -- Tab button
        local btn = New("TextButton", {
            Size             = UDim2.new(0, 0, 1, 0),
            AutomaticSize    = Enum.AutomaticSize.X,
            BackgroundColor3 = Theme.TabInactive,
            BorderSizePixel  = 0,
            Text             = tabName,
            TextColor3       = Theme.TextSecondary,
            Font             = Enum.Font.Code,
            TextSize         = 10,
            ZIndex           = 4,
            Parent           = TabBar,
        })
        Pad(btn, 0, 8, 0, 8)

        local function Activate()
            -- Deactivate all
            for _, t in pairs(tabs) do t.Visible = false end
            for _, b in pairs(tabBtns) do
                b.BackgroundColor3 = Theme.TabInactive
                b.TextColor3       = Theme.TextSecondary
            end
            -- Activate this
            tabFrame.Visible  = true
            btn.BackgroundColor3 = Theme.TabActive
            btn.TextColor3    = Theme.Accent
            activeTab = tabFrame
        end

        btn.MouseButton1Click:Connect(Activate)

        table.insert(tabs, tabFrame)
        table.insert(tabBtns, btn)

        if #tabs == 1 then Activate() end

        -- ── Section & element builders ───────────────
        local TabObj = {}

        local function MakeRow(height)
            local row = New("Frame", {
                Size             = UDim2.new(1, 0, 0, height or 22),
                BackgroundTransparency = 1,
                ZIndex           = 2,
                Parent           = tabFrame,
            })
            return row
        end

        -- Section header
        function TabObj:AddSection(name)
            local sec = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                ZIndex           = 2,
                Parent           = tabFrame,
            })
            New("Frame", {
                Size             = UDim2.new(1, -12, 0, 1),
                Position         = UDim2.new(0, 6, 0.5, 0),
                BackgroundColor3 = Theme.SectionLine,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = sec,
            })
            local lbl = New("TextLabel", {
                Size               = UDim2.new(0, 0, 1, 0),
                AutomaticSize      = Enum.AutomaticSize.X,
                BackgroundColor3   = Theme.Bg2,
                BackgroundTransparency = 0,
                Text               = " " .. name .. " ",
                TextColor3         = Theme.AccentDim,
                Font               = Enum.Font.Code,
                TextSize           = 10,
                Position           = UDim2.new(0, 8, 0, 0),
                ZIndex             = 3,
                Parent             = sec,
            })
        end

        -- Toggle (checkbox style — square box + label, no rounded corners)
        function TabObj:AddToggle(Params2)
            local row = MakeRow(18)
            local on = Params2.Default or false
            local callback = Params2.Callback or function() end

            -- Outer checkbox border (square, 1px outline)
            local box = New("Frame", {
                Size             = UDim2.new(0, 11, 0, 11),
                Position         = UDim2.new(0, 4, 0.5, -6),
                BackgroundColor3 = Theme.Bg3,
                BorderSizePixel  = 1,
                BorderColor3     = Theme.Accent,
                ZIndex           = 3,
                Parent           = row,
            })

            -- Inner fill square (visible when ON)
            local fill = New("Frame", {
                Size             = UDim2.new(0, 7, 0, 7),
                Position         = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel  = 0,
                Visible          = on,
                ZIndex           = 4,
                Parent           = box,
            })

            -- Label to the right
            local lbl = New("TextLabel", {
                Size               = UDim2.new(1, -20, 1, 0),
                Position           = UDim2.new(0, 18, 0, 0),
                BackgroundTransparency = 1,
                Text               = Params2.Text or "Toggle",
                TextColor3         = on and Theme.TextPrimary or Theme.TextSecondary,
                Font               = Enum.Font.Code,
                TextSize           = 11,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 3,
                Parent             = row,
            })

            -- Invisible click catcher
            local btn = New("TextButton", {
                Size               = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = 5,
                Parent             = row,
            })

            local function SetState(state)
                on = state
                fill.Visible   = on
                lbl.TextColor3 = on and Theme.TextPrimary or Theme.TextSecondary
                callback(on)
            end

            btn.MouseButton1Click:Connect(function() SetState(not on) end)

            local Obj = { Value = on }
            function Obj:Set(v) SetState(v) end
            return Obj
        end

        -- Slider (flat — no corners, label left, value right, track below)
        function TabObj:AddSlider(Params2)
            local row = MakeRow(28)
            local min = Params2.Min or 0
            local max = Params2.Max or 100
            local val = Params2.Default or min
            local callback = Params2.Callback or function() end

            -- Top label row
            local nameLbl = New("TextLabel", {
                Size               = UDim2.new(1, -32, 0, 14),
                Position           = UDim2.new(0, 4, 0, 2),
                BackgroundTransparency = 1,
                Text               = Params2.Text or "Slider",
                TextColor3         = Theme.TextPrimary,
                Font               = Enum.Font.Code,
                TextSize           = 11,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 3,
                Parent             = row,
            })

            local valLbl = New("TextLabel", {
                Size               = UDim2.new(0, 28, 0, 14),
                Position           = UDim2.new(1, -32, 0, 2),
                BackgroundTransparency = 1,
                Text               = tostring(val),
                TextColor3         = Theme.TextSecondary,
                Font               = Enum.Font.Code,
                TextSize           = 11,
                TextXAlignment     = Enum.TextXAlignment.Right,
                ZIndex             = 3,
                Parent             = row,
            })

            -- Track (flat, full width, no corners)
            local trackFrame = New("Frame", {
                Size             = UDim2.new(1, -8, 0, 3),
                Position         = UDim2.new(0, 4, 0, 18),
                BackgroundColor3 = Theme.SliderTrack,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = row,
            })

            -- Fill (flat)
            local fillPct = (val - min) / math.max(max - min, 1)
            local fill = New("Frame", {
                Size             = UDim2.new(fillPct, 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel  = 0,
                ZIndex           = 4,
                Parent           = trackFrame,
            })

            -- Invisible wide click zone over track
            local hitbox = New("TextButton", {
                Size               = UDim2.new(1, 0, 0, 12),
                Position           = UDim2.new(0, 0, 0.5, -6),
                BackgroundTransparency = 1,
                Text               = "",
                ZIndex             = 5,
                Parent             = trackFrame,
            })

            local dragging = false
            local function Update(x)
                local abs = trackFrame.AbsolutePosition.X
                local w   = trackFrame.AbsoluteSize.X
                local pct = math.clamp((x - abs) / w, 0, 1)
                val = math.floor(min + pct * (max - min) + 0.5)
                local p = (val - min) / math.max(max - min, 1)
                fill.Size   = UDim2.new(p, 0, 1, 0)
                valLbl.Text = tostring(val)
                callback(val)
            end

            hitbox.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    Update(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            local Obj = { Value = val }
            function Obj:Set(v)
                val = math.clamp(v, min, max)
                local p = (val - min) / math.max(max - min, 1)
                fill.Size   = UDim2.new(p, 0, 1, 0)
                valLbl.Text = tostring(val)
            end
            return Obj
        end

        -- Dropdown
        function TabObj:AddDropdown(Params2)
            local row = MakeRow(22)
            local options  = Params2.Options or {}
            local selected = Params2.Default or options[1] or "None"
            local callback = Params2.Callback or function() end
            local open     = false

            local btn = New("TextButton", {
                Size             = UDim2.new(1, -4, 0, 18),
                Position         = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Theme.Bg3,
                BorderSizePixel  = 0,
                Text             = "",
                ZIndex           = 3,
                Parent           = row,
            })
            Stroke(btn, Theme.Outline, 1)

            New("TextLabel", {
                Size               = UDim2.new(0, 80, 1, 0),
                BackgroundTransparency = 1,
                Text               = Params2.Text or "Dropdown",
                TextColor3         = Theme.TextSecondary,
                Font               = Enum.Font.Code,
                TextSize           = 10,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 4,
                Parent             = btn,
            })
            Pad(btn:FindFirstChildOfClass("TextLabel") or btn, 0, 0, 0, 4)

            local valLbl = New("TextLabel", {
                Size               = UDim2.new(1, -16, 1, 0),
                Position           = UDim2.new(0, 70, 0, 0),
                BackgroundTransparency = 1,
                Text               = selected,
                TextColor3         = Theme.TextAccent,
                Font               = Enum.Font.Code,
                TextSize           = 11,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 4,
                Parent             = btn,
            })

            local arrow = New("TextLabel", {
                Size               = UDim2.new(0, 12, 1, 0),
                Position           = UDim2.new(1, -14, 0, 0),
                BackgroundTransparency = 1,
                Text               = "▼",
                TextColor3         = Theme.AccentDim,
                Font               = Enum.Font.Code,
                TextSize           = 9,
                ZIndex             = 4,
                Parent             = btn,
            })

            -- Dropdown list (rendered above all)
            local listFrame = New("Frame", {
                Size             = UDim2.new(0, btn.AbsoluteSize.X, 0, #options * 18),
                BackgroundColor3 = Theme.DropBg,
                BorderSizePixel  = 0,
                Visible          = false,
                ZIndex           = 20,
                Parent           = SG,
            })
            Stroke(listFrame, Theme.Accent, 1)

            New("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = listFrame,
            })

            for i, opt in ipairs(options) do
                local item = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 18),
                    BackgroundColor3 = Theme.DropBg,
                    BorderSizePixel  = 0,
                    Text             = opt,
                    TextColor3       = opt == selected and Theme.TextAccent or Theme.TextPrimary,
                    Font             = Enum.Font.Code,
                    TextSize         = 11,
                    TextXAlignment   = Enum.TextXAlignment.Left,
                    ZIndex           = 21,
                    Parent           = listFrame,
                })
                Pad(item, 0, 0, 0, 6)

                item.MouseEnter:Connect(function()
                    Tween(item, { BackgroundColor3 = Theme.DropHover })
                end)
                item.MouseLeave:Connect(function()
                    Tween(item, { BackgroundColor3 = Theme.DropBg })
                end)
                item.MouseButton1Click:Connect(function()
                    selected    = opt
                    valLbl.Text = opt
                    callback(opt)
                    listFrame.Visible = false
                    open = false
                    arrow.Text = "▼"
                end)
            end

            local function PositionList()
                local absPos  = btn.AbsolutePosition
                local absSize = btn.AbsoluteSize
                listFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 2)
                listFrame.Size     = UDim2.new(0, absSize.X, 0, #options * 18)
            end

            btn.MouseButton1Click:Connect(function()
                open = not open
                PositionList()
                listFrame.Visible = open
                arrow.Text = open and "▲" or "▼"
            end)

            -- Close on outside click
            UserInputService.InputBegan:Connect(function(inp)
                if open and inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mp = inp.Position
                    local lp = listFrame.AbsolutePosition
                    local ls = listFrame.AbsoluteSize
                    if not (mp.X >= lp.X and mp.X <= lp.X+ls.X and mp.Y >= lp.Y and mp.Y <= lp.Y+ls.Y) then
                        listFrame.Visible = false
                        open = false
                        arrow.Text = "▼"
                    end
                end
            end)

            local Obj = { Value = selected }
            function Obj:Set(v)
                selected = v
                valLbl.Text = v
            end
            return Obj
        end

        -- Keybind
        function TabObj:AddKeybind(Params2)
            local row = MakeRow(20)
            local key = Params2.Default or Enum.KeyCode.Unknown
            local callback = Params2.Callback or function() end
            local listening = false

            New("TextLabel", {
                Size               = UDim2.new(0.6, 0, 1, 0),
                Position           = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text               = Params2.Text or "Keybind",
                TextColor3         = Theme.TextPrimary,
                Font               = Enum.Font.Code,
                TextSize           = 11,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 3,
                Parent             = row,
            })

            local keyBtn = New("TextButton", {
                Size             = UDim2.new(0, 56, 0, 14),
                Position         = UDim2.new(1, -60, 0.5, -7),
                BackgroundColor3 = Theme.KeybindBg,
                BorderSizePixel  = 0,
                Text             = key == Enum.KeyCode.Unknown and "NONE" or key.Name,
                TextColor3       = Theme.TextAccent,
                Font             = Enum.Font.Code,
                TextSize         = 10,
                ZIndex           = 4,
                Parent           = row,
            })
            Stroke(keyBtn, Theme.Outline, 1)

            keyBtn.MouseButton1Click:Connect(function()
                listening = true
                keyBtn.Text      = "..."
                keyBtn.TextColor3 = Theme.Accent
            end)

            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    key = inp.KeyCode
                    keyBtn.Text       = key.Name
                    keyBtn.TextColor3 = Theme.TextAccent
                    callback(key)
                end
            end)

            -- Fire callback when key pressed
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if not listening and inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode == key then
                    callback(key)
                end
            end)

            local Obj = { Value = key }
            function Obj:Set(k)
                key = k
                keyBtn.Text = k.Name
            end
            return Obj
        end

        -- Label (read-only text row)
        function TabObj:AddLabel(text)
            local row = MakeRow(18)
            New("TextLabel", {
                Size               = UDim2.new(1, -8, 1, 0),
                Position           = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text               = text or "",
                TextColor3         = Theme.TextSecondary,
                Font               = Enum.Font.Code,
                TextSize           = 10,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 3,
                Parent             = row,
            })
        end

        -- Textbox
        function TabObj:AddTextbox(Params2)
            local row = MakeRow(22)
            local callback = Params2.Callback or function() end

            local frame = New("Frame", {
                Size             = UDim2.new(1, -4, 0, 18),
                Position         = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = Theme.Bg3,
                BorderSizePixel  = 0,
                ZIndex           = 3,
                Parent           = row,
            })
            Stroke(frame, Theme.Outline, 1)

            New("TextLabel", {
                Size               = UDim2.new(0, 80, 1, 0),
                Position           = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency = 1,
                Text               = Params2.Text or "Input",
                TextColor3         = Theme.TextSecondary,
                Font               = Enum.Font.Code,
                TextSize           = 10,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ZIndex             = 4,
                Parent             = frame,
            })

            local box = New("TextBox", {
                Size               = UDim2.new(1, -84, 1, -2),
                Position           = UDim2.new(0, 76, 0, 1),
                BackgroundTransparency = 1,
                Text               = Params2.Default or "",
                PlaceholderText    = Params2.Placeholder or "...",
                TextColor3         = Theme.TextAccent,
                PlaceholderColor3  = Theme.TextSecondary,
                Font               = Enum.Font.Code,
                TextSize           = 11,
                TextXAlignment     = Enum.TextXAlignment.Left,
                ClearTextOnFocus   = false,
                ZIndex             = 4,
                Parent             = frame,
            })

            box.FocusLost:Connect(function(enter)
                callback(box.Text, enter)
            end)

            local stroke = Stroke(frame, Theme.Outline, 1)
            box.Focused:Connect(function()
                Tween(stroke, { Color = Theme.Accent })
            end)
            box.FocusLost:Connect(function()
                Tween(stroke, { Color = Theme.Outline })
            end)

            local Obj = { Value = box.Text }
            function Obj:Set(v) box.Text = v end
            return Obj
        end

        return TabObj
    end

    -- Minimize / destroy helpers
    local visible = true
    function WindowObj:Toggle()
        visible = not visible
        ContentArea.Visible = visible
        TabBar.Visible      = visible
        WinFrame.Size = visible
            and UDim2.new(0, W, 0, H)
            or  UDim2.new(0, W, 0, 22)
    end
    function WindowObj:Destroy()
        SG:Destroy()
    end

    return WindowObj
end

return Construction
