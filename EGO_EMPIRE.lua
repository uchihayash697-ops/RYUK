local __ok, __err = xpcall(function()
--[[
    RYUK x OBITO  |  EDITS GUI  (everything embedded - one script)
    Solara-compatible (optional funcs are wrapped). Needs writefile + getcustomasset. Script size ~13 MB.
]]




------------------------------------------------------------
-- CONFIG
------------------------------------------------------------
local CONFIG = {
	Title      = "EGO EMPIRE 🔱🚩",
	HubIntro   = true,   -- show the name / BOY / GIRL intro after loading (set false to skip)
	NoxUrl     = "https://raw.githubusercontent.com/RYUKPAPA17/RYUKBB/refs/heads/main/RYUK", -- RYUK script (replaces ULTRA INSTINCT)
	AutoShrine = true,   -- auto-run the Malevolent Shrine when the GUI finishes loading (set false to disable)
	Credit     = "MADE BY RYUK X OBITO",
	Image      = "img",   -- embedded image (background + toggle)
	Accent     = Color3.fromRGB(255, 170, 60),
	Dark       = Color3.fromRGB(14, 4, 6),
	ToggleSize = 54,
}

-- mood: "OK!" | "SAD" | "LONELY" | "MAD"
local EDITS = {
	{ name = "Short Hair Cozy", mood = "OK!", video = "v1" },
	{ name = "Cozy Pinterest", mood = "OK!", video = "v2" },
	{ name = "Cozy Beauty", mood = "SAD", video = "v3" },
	{ name = "Meal Prep", mood = "OK!", video = "v4" },
	{ name = "Wedding Aisle", mood = "SAD", video = "v5" },
	{ name = "Side Hustle", mood = "MAD", video = "v6" },
	{ name = "Fresh Meal Prep", mood = "OK!", video = "v7" },
	{ name = "Cozy Pet Beds", mood = "OK!", video = "v8" },
	{ name = "Travel Bucket List", mood = "LONELY", video = "v9" },
	{ name = "Plus Size Fashion", mood = "OK!", video = "v10" },
	{ name = "Village Life", mood = "LONELY", video = "v11" },
	{ name = "Motivation Words", mood = "MAD", video = "v12" },
	{ name = "Romantic Vibes", mood = "SAD", video = "v13" },
	{ name = "DIY Gifts", mood = "OK!", video = "v14" },
	{ name = "Side Hustle Ideas", mood = "MAD", video = "v15" },
	{ name = "Packing List", mood = "LONELY", video = "v16" },
	{ name = "Wedding Favors", mood = "SAD", video = "v17" },
	{ name = "Bridesmaid Dresses", mood = "SAD", video = "v18" },
	{ name = "Travel Journal", mood = "LONELY", video = "v19" },
	{ name = "Road Trip Essentials", mood = "LONELY", video = "v20" },
	{ name = "Road Trip Smart", mood = "LONELY", video = "v21" },
	{ name = "Wedding Hair", mood = "SAD", video = "v22" },
	{ name = "DIY Gift Tips", mood = "OK!", video = "v23" },
	{ name = "Skincare Glow", mood = "OK!", video = "v24" },
}

local MOODS = {
	{ "OK!",    Color3.fromRGB(90, 220, 140) },
	{ "SAD",    Color3.fromRGB(90, 150, 255) },
	{ "LONELY", Color3.fromRGB(180, 120, 255) },
	{ "MAD",    Color3.fromRGB(255, 80, 80) },
}

------------------------------------------------------------
-- SERVICES / HELPERS
------------------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local parentGui = (gethui and gethui()) or (pcall(function() return game.CoreGui.Name end) and game.CoreGui) or Players.LocalPlayer:WaitForChild("PlayerGui")
local G = (getgenv and getgenv()) or _G
local __conns = {}
local function track_conn(signal, fn) local c = signal:Connect(fn) table.insert(__conns, c) return c end
if G.RYUK_CLEANUP then pcall(G.RYUK_CLEANUP) end
G.RYUK_CLEANUP = function()
	for _, c in ipairs(__conns) do pcall(function() c:Disconnect() end) end
	pcall(function() local g = parentGui:FindFirstChild("NoxEditsGui") if g then g:Destroy() end end)
	if G.RYUK_SHRINE_STOP then pcall(G.RYUK_SHRINE_STOP) G.RYUK_SHRINE_STOP = nil end
	pcall(function() if G.RYUKM then if G.RYUKM.group then G.RYUKM.group:Destroy() end if G.RYUKM.orbit then G.RYUKM.orbit:Destroy() end G.RYUKM = nil end end)
end
pcall(function()
	if parentGui:FindFirstChild("NoxEditsGui") then parentGui.NoxEditsGui:Destroy() end
end)

local function new(class, props, children)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = o end
	return o
end
local function corner(r) return new("UICorner", { CornerRadius = UDim.new(0, r) }) end
local function stroke(c, t, tr) return new("UIStroke", { Color = c, Thickness = t or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end
local function tween(o, t, p) TweenService:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play() end

local TITLE_FONT = Enum.Font.Michroma
local BODY_FONT  = Enum.Font.GothamMedium
local BOLD_FONT  = Enum.Font.GothamBold

local function makeDraggable(handle, target)
	local state = { moved = false }
	local dragging, startPos, startInput
	local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end
	handle.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, state.moved = true, false
			startPos, startInput = target.Position, i.Position
		end
	end)
	track_conn(UIS.InputChanged, function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startInput
			if d.Magnitude > 6 then state.moved = true end
			if state.moved then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end
	end)
	track_conn(UIS.InputEnded, function(i) if isPress(i) then dragging = false end end)
	return state
end

-- decode embedded base64 -> file -> asset
local ASSETS = {}
local nativeB64 = (crypt and crypt.base64decode) or (crypt and crypt.base64 and crypt.base64.decode) or base64decode or base64_decode or (base64 and base64.decode)
local L = {}
do
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	for i = 1, 64 do L[chars:byte(i)] = i - 1 end
end
local function pureDecode(s)
	local out, o = {}, 0
	for i = 1, #s, 4 do
		local a, b, c, d = s:byte(i, i + 3)
		local n = (L[a] or 0) * 262144 + (L[b] or 0) * 4096 + (L[c] or 0) * 64 + (L[d] or 0)
		local x, y, z = math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256
		o = o + 1
		if c == 61 then out[o] = string.char(x)
		elseif d == 61 then out[o] = string.char(x, y)
		else out[o] = string.char(x, y, z) end
	end
	return table.concat(out)
end
local function decodeChunk(s)
	if nativeB64 then
		local ok, r = pcall(nativeB64, s)
		if ok and r then return r end
	end
	return pureDecode(s)
end

-- executor compatibility layer (Solara etc.): every function is optional + wrapped
local env = (getgenv and getgenv()) or _G
-- direct globals first (Delta/Solara/etc. inject differently), getgenv() as backup
local _writefile = writefile or env.writefile
local _isfile = isfile or env.isfile
local _asset = getcustomasset or env.getcustomasset or get_custom_asset or env.get_custom_asset or getsynasset or env.getsynasset
if not (_writefile and _asset) then
	pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "EGO EMPIRE 🔱🚩", Text = "your executor has no writefile/getcustomasset - images & edits can't load", Duration = 10 }) end)
end

local function prepare(key)
	local d = DATA[key]
	if not d or not _writefile or not _asset then return end
	local ok, res = pcall(function()
		-- flat file name (no folders = safest on mobile); size in the name so old versions never get reused
		local name = "RYUK_" .. key .. "_" .. d.size .. "." .. d.ext
		local have = false
		if _isfile then
			local okf, ex = pcall(_isfile, name)
			have = (okf and ex) and true or false
		end
		if not have then
			local buf = {}
			for i, p in ipairs(d.parts) do
				buf[i] = decodeChunk(p)
				if not nativeB64 or i % 10 == 0 then task.wait() end
			end
			_writefile(name, table.concat(buf))
		end
		return _asset(name)
	end)
	if ok and res then ASSETS[key] = res end
end

local function resolve(key) return ASSETS[key] or "" end

local likes = {} -- [editName] = true
local EDIT_STATE = { ready = false } -- edits finish decoding in the background

------------------------------------------------------------
-- ROOT
------------------------------------------------------------
local gui = new("ScreenGui", { Name = "NoxEditsGui", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
gui.Parent = parentGui

prepare("img")
local img = resolve(CONFIG.Image)

------------------------------------------------------------
-- MUSIC (top-right ON/OFF toggle + Toofan edit after the Malevolent Shrine intro)
------------------------------------------------------------
G.RYUKM = { on = true }
do
	local M = G.RYUKM
	local grp = Instance.new("SoundGroup")
	grp.Name, grp.Volume = "NoxMusic", 1
	pcall(function() grp.Parent = game:GetService("SoundService") end)
	M.group = grp
	M.toofan = new("Sound", { Name = "NoxToofan", Volume = 0.8, Looped = true, Parent = gui })
	pcall(function() M.toofan.SoundGroup = grp end)
	local tbtn = new("TextButton", {
		Name = "NoxMusicToggle", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 8), Size = UDim2.fromOffset(120, 30),
		BackgroundColor3 = CONFIG.Dark, BackgroundTransparency = 0.2, Text = "🎵 TOOFAN: ON", Font = BOLD_FONT, TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1), ZIndex = 200, Parent = gui,
	}, { corner(8), stroke(CONFIG.Accent, 1.5, 0) })
	M.btn = tbtn
	function M.set(on)
		M.on = on
		grp.Volume = on and 1 or 0
		tbtn.Text = on and "🎵 TOOFAN: ON" or "🔇 TOOFAN: OFF"
		for _, s in ipairs({ M.toofan }) do
			pcall(function()
				if on then
					if s.IsPaused then s:Resume() end
				elseif s.IsPlaying then
					s:Pause()
				end
			end)
		end
	end
	tbtn.MouseButton1Click:Connect(function() M.set(not M.on) end)
	local hbtn = new("TextButton", {
		Name = "NoxHideUI", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -138, 0, 8), Size = UDim2.fromOffset(104, 30),
		BackgroundColor3 = CONFIG.Dark, BackgroundTransparency = 0.2, Text = "🙈 HIDE UI", Font = BOLD_FONT, TextSize = 12,
		TextColor3 = Color3.new(1, 1, 1), ZIndex = 200, Visible = false, Parent = gui,
	}, { corner(8), stroke(CONFIG.Accent, 1.5, 0) })
	M.hideBtn = hbtn
	local saved, hidden = {}, false
	hbtn.MouseButton1Click:Connect(function()
		local mainF = gui:FindFirstChild("Main")
		if not mainF then return end
		if not hidden then
			hidden, saved = true, {}
			local bg = mainF:FindFirstChildWhichIsA("ImageLabel")
			saved[mainF] = mainF.Visible
			mainF.Visible = true
			for _, o in ipairs(mainF:GetChildren()) do
				if o:IsA("GuiObject") and o ~= bg then saved[o] = o.Visible o.Visible = false
				elseif o:IsA("UIStroke") then saved[o] = o.Enabled o.Enabled = false end
			end
			for _, o in ipairs(gui:GetChildren()) do
				if o:IsA("GuiObject") and o ~= mainF and o ~= hbtn and o ~= tbtn then saved[o] = o.Visible o.Visible = false end
			end
			hbtn.Text = "👁 SHOW UI"
		else
			hidden = false
			for o, v in pairs(saved) do
				if o.Parent then
					if o:IsA("UIStroke") then o.Enabled = v else o.Visible = v end
				end
			end
			saved = {}
			hbtn.Text = "🙈 HIDE UI"
		end
	end)
	-- plays the Toofan edit (called after the Malevolent Shrine intro part)
	function M.PlayToofan()
		if not M.on or M.toofan.IsPlaying then return end
		if not ASSETS.m4 then prepare("m4") end
		local id = ASSETS.m4
		if not id then return end
		M.toofan.SoundId = id
		M.toofan.TimePosition = 0
		M.toofan:Play()
	end
end

------------------------------------------------------------
-- DEVICE CHOOSER (PC = bigger GUI, MOBILE = normal size)
------------------------------------------------------------
do
	local pick
	local chooser = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = CONFIG.Dark, ZIndex = 150, Parent = gui })
	new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = img, ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.55, ZIndex = 150, Parent = chooser })
	new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.36), Size = UDim2.fromOffset(420, 30),
		BackgroundTransparency = 1, Text = "SELECT YOUR DEVICE", Font = TITLE_FONT, TextSize = 18, TextColor3 = CONFIG.Accent, ZIndex = 151, Parent = chooser,
	})
	local function opt(text, x, val)
		local b = new("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, x, 0.5, 10), Size = UDim2.fromOffset(150, 84),
			BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Text = text, Font = BOLD_FONT, TextSize = 18,
			TextColor3 = Color3.new(1, 1, 1), ZIndex = 151, Parent = chooser,
		}, { corner(12), stroke(CONFIG.Accent, 2, 0) })
		b.MouseButton1Click:Connect(function() pick = val end)
	end
	opt("🖥️  PC", -90, "PC")
	opt("📱  MOBILE", 90, "MOBILE")
	while not pick and gui.Parent do task.wait(0.1) end
	G.RYUKM.device = pick or "MOBILE"
	chooser:Destroy()
end

------------------------------------------------------------
-- LOADING SCREEN
------------------------------------------------------------
local loading = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = CONFIG.Dark, ZIndex = 100, Parent = gui })
new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = img, ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.55, ZIndex = 100, Parent = loading })
local lTitle = new("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.4), Size = UDim2.fromOffset(400, 50),
	BackgroundTransparency = 1, Text = CONFIG.Title, Font = TITLE_FONT, TextSize = 20, TextColor3 = CONFIG.Accent, ZIndex = 101, Parent = loading,
})
local lSub = new("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(400, 24),
	BackgroundTransparency = 1, Text = "LOADING", Font = BOLD_FONT, TextSize = 14, TextColor3 = Color3.new(1, 1, 1), ZIndex = 101, Parent = loading,
})
local barBg = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.58), Size = UDim2.fromOffset(240, 6),
	BackgroundColor3 = Color3.fromRGB(40, 20, 20), ZIndex = 101, Parent = loading,
}, { corner(3) })
local bar = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = CONFIG.Accent, ZIndex = 102, Parent = barBg }, { corner(3) })
new("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -24), Size = UDim2.fromOffset(400, 20),
	BackgroundTransparency = 1, Text = CONFIG.Credit, Font = BODY_FONT, TextSize = 12, TextColor3 = Color3.fromRGB(220, 200, 180), ZIndex = 101, Parent = loading,
})

------------------------------------------------------------
-- MAIN WINDOW  (image background)
------------------------------------------------------------
local main = new("Frame", {
	Name = "Main", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(430, 300),
	BackgroundColor3 = CONFIG.Dark, ClipsDescendants = true, Visible = false, Parent = gui,
}, { corner(14), stroke(CONFIG.Accent, 1.5, 0.35) })
if G.RYUKM.device == "PC" then new("UIScale", { Scale = 1.3, Parent = main }) end
new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = img, ScaleType = Enum.ScaleType.Crop, ImageTransparency = 0.1, Parent = main })
new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Parent = main })

local top = new("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, Parent = main })
new("TextLabel", {
	Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -60, 1, 0), BackgroundTransparency = 1, Text = CONFIG.Title,
	Font = TITLE_FONT, TextSize = 14, TextColor3 = CONFIG.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = top,
})
local closeBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(22, 22),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0.5, Text = "×", Font = BOLD_FONT, TextSize = 16,
	TextColor3 = Color3.new(1, 1, 1), Parent = top,
}, { corner(11) })
makeDraggable(top, main)

-- tabs
local tabBar = new("ScrollingFrame", {
	Position = UDim2.fromOffset(14, 40), Size = UDim2.new(1, -28, 0, 28), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = main,
	ScrollingDirection = Enum.ScrollingDirection.X, AutomaticCanvasSize = Enum.AutomaticSize.X, CanvasSize = UDim2.new(),
	ScrollBarThickness = 2, ScrollBarImageColor3 = CONFIG.Accent,
}, {
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
})
local tabCount = 0
local pages, tabButtons = {}, {}
local function pageFrame()
	return new("Frame", { Position = UDim2.fromOffset(14, 74), Size = UDim2.new(1, -28, 1, -88), BackgroundTransparency = 1, Visible = false, Parent = main })
end
local function setTab(name)
	for n, p in pairs(pages) do p.Visible = (n == name) end
	for n, b in pairs(tabButtons) do
		tween(b, 0.2, { BackgroundTransparency = (n == name) and 0.1 or 0.6, TextColor3 = (n == name) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1) })
		b.BackgroundColor3 = (n == name) and CONFIG.Accent or Color3.new(0, 0, 0)
	end
end
local function addTab(name)
	tabCount = tabCount + 1
	pages[name] = pageFrame()
	tabButtons[name] = new("TextButton", {
		Size = UDim2.fromOffset(72, 24), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.6,
		Text = name, Font = BOLD_FONT, TextSize = 11, TextColor3 = Color3.new(1, 1, 1), LayoutOrder = tabCount, Parent = tabBar,
	}, { corner(8), new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }) })
	tabButtons[name].MouseButton1Click:Connect(function() setTab(name) end)
	return pages[name]
end

-- HOME PAGE
local home = addTab("HOME")
new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Text = "EGO EMPIRE V1",
	Font = TITLE_FONT, TextSize = 15, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, Parent = home,
})
new("TextLabel", {
	Position = UDim2.fromOffset(0, 38), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, TextWrapped = true,
	Text = [[🔥👑 EGO EMPIRE ! V1 👑 🔥

⚔️ EGO EMPIRE ! ⚔️
━━━━━━━━━━━━━━━━━━━━━━━━
🪪 ROBLOX ID'S
💀 RYUK — DUMMY_VEGETA [OFC_KAiZeR]
💀 OBITO  --- OBITO
━━━━━━━━━━━━━━━━━━━━━━━━
📸 INSTA ID'S
🔥 RYUK — itz_ryuk_0 [MAIN]
✨ OBITO — urfavv._.obitooo_ [MAIN]

━━━━━━━━━━━━━━━━━━━━━━━━
👑 GANG LEADERSHIP/OWNERSHIP
💀 OBITO —  THE  OWNER OF EGO EMPIRE 💀 !
💀 RYUK —  THE  2 LEADER OF EGO EMPIRE 💀 !
━━━━━━━━━━━━━━━━━━━━━━━━
🩸 EGO EMPIRE 🩸
👑 MADE BY RYUK  👑]] , Font = BODY_FONT, TextSize = 12,
	TextColor3 = Color3.fromRGB(230, 210, 190), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = home,
})

-- EDITS PAGE
local editsPage = addTab("EDITS")
local moodView = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = editsPage })
local listView = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, Parent = editsPage })

new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Text = "WHAT'S UR MOOD?", Font = TITLE_FONT, TextSize = 14,
	TextColor3 = Color3.new(1, 1, 1), Parent = moodView,
})
local moodGrid = new("Frame", { Position = UDim2.fromOffset(0, 34), Size = UDim2.new(1, 0, 1, -34), BackgroundTransparency = 1, Parent = moodView }, {
	new("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 56), CellPadding = UDim2.fromOffset(8, 8) }),
})

local listTitle = new("TextLabel", {
	Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -34, 0, 24), BackgroundTransparency = 1, Text = "", Font = TITLE_FONT,
	TextSize = 13, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, Parent = listView,
})
local backBtn = new("TextButton", {
	Size = UDim2.fromOffset(26, 24), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Text = "‹",
	Font = BOLD_FONT, TextSize = 18, TextColor3 = Color3.new(1, 1, 1), Parent = listView,
}, { corner(8) })
local editList = new("ScrollingFrame", {
	Position = UDim2.fromOffset(0, 30), Size = UDim2.new(1, 0, 1, -30), BackgroundTransparency = 1, BorderSizePixel = 0,
	ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = listView,
}, { new("UIListLayout", { Padding = UDim.new(0, 6) }) })

------------------------------------------------------------
-- PHONE (draggable, scroll feed, like)
------------------------------------------------------------
local PH_W, PH_H = 210, 390
local SCREEN_H = PH_H - 34
local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
local PHONE_POS = (vp.X > 430 + PH_W + 70) and UDim2.new(0.5, 225, 0.5, -PH_H / 2) or UDim2.new(0.5, -PH_W / 2, 0.5, -PH_H / 2)
local phone = new("Frame", {
	Name = "Phone", Size = UDim2.fromOffset(PH_W, PH_H), Position = PHONE_POS,
	BackgroundColor3 = Color3.fromRGB(8, 8, 10), Visible = false, ClipsDescendants = true, ZIndex = 20, Parent = gui,
}, { corner(22), stroke(CONFIG.Accent, 2, 0.2) })
local notch = new("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, ZIndex = 21, Parent = phone })
new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(50, 6), BackgroundColor3 = Color3.fromRGB(40, 40, 46), ZIndex = 22, Parent = notch }, { corner(3) })
local phClose = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(18, 18),
	BackgroundTransparency = 1, Text = "×", Font = BOLD_FONT, TextSize = 16, TextColor3 = Color3.new(1, 1, 1), ZIndex = 23, Parent = notch,
})
makeDraggable(notch, phone)

local feed = new("ScrollingFrame", {
	Position = UDim2.fromOffset(6, 30), Size = UDim2.new(1, -12, 0, SCREEN_H - 2), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0,
	ScrollBarThickness = 0, ClipsDescendants = true, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 21, Parent = phone,
}, { corner(14), new("UIListLayout", { Padding = UDim.new(0, 0) }) })

local pageData = {}
local currentIdx, snapping, lastScroll = 1, false, 0
local FEED_H = SCREEN_H - 2

local function updatePlaying(idx)
	currentIdx = idx
	for i, d in ipairs(pageData) do
		local on = (i == idx)
		d.t0 = os.clock()
		d.last = nil
		if d.sound then
			pcall(function()
				if on then d.sound.TimePosition = 0 d.sound:Play() else d.sound:Stop() end
			end)
		end
	end
end

-- flipbook player: shows frames from sprite sheets, synced to the sound
track_conn(RunService.Heartbeat, function()
	if not phone.Visible then return end
	local d = pageData[currentIdx]
	if not d or not d.meta then return end
	local m = d.meta
	local t
	if d.sound and d.sound.IsPlaying and d.sound.TimeLength > 0 then t = d.sound.TimePosition
	else t = (os.clock() - d.t0) % m.dur end
	local f = math.clamp(math.floor(t * m.fps), 0, m.n - 1)
	if f ~= d.last then
		d.last = f
		local per = m.cols * m.rows
		local sh = math.floor(f / per) + 1
		local k = f % per
		if d.sheet ~= sh then d.sheet = sh d.img.Image = d.sheets[sh] or "" end
		d.img.ImageRectOffset = Vector2.new((k % m.cols) * m.fw, math.floor(k / m.cols) * m.fh)
	end
end)

local function goTo(idx, instant)
	idx = math.clamp(idx, 1, #pageData)
	local target = Vector2.new(0, (idx - 1) * FEED_H)
	snapping = true
	if instant then feed.CanvasPosition = target else tween(feed, 0.25, { CanvasPosition = target }) end
	updatePlaying(idx)
	task.delay(0.3, function() snapping = false end)
end

feed:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
	if snapping then return end
	lastScroll = tick()
	local mark = lastScroll
	task.delay(0.12, function()
		if mark == lastScroll and #pageData > 0 then
			goTo(math.floor(feed.CanvasPosition.Y / FEED_H + 0.5) + 1)
		end
	end)
end)

local function buildFeed()
	for _, c in ipairs(feed:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
	pageData = {}
	for i, e in ipairs(EDITS) do
		local pg = new("Frame", { Size = UDim2.new(1, 0, 0, FEED_H), BackgroundColor3 = Color3.new(0, 0, 0), LayoutOrder = i, ZIndex = 21, Parent = feed })
		local meta = VMETA[e.video]
		local sheets, okAll = {}, meta ~= nil
		if meta then
			for n = 1, meta.sheets do
				local asset = ASSETS[e.video .. "s" .. n]
				if not asset then okAll = false end
				sheets[n] = asset or ""
			end
		end
		local vid, snd
		if okAll then
			vid = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = sheets[1], ImageRectSize = Vector2.new(meta.fw, meta.fh),
				ImageRectOffset = Vector2.new(0, 0), ZIndex = 21, Parent = pg })
			local au = ASSETS[e.video .. "a"]
			if au then snd = new("Sound", { SoundId = au, Looped = true, Volume = 0.6, Parent = pg }) end
			task.spawn(function() pcall(function() game:GetService("ContentProvider"):PreloadAsync(sheets) end) end)
		else
			new("TextLabel", {
				Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "EDIT FAILED TO LOAD\nneeds writefile +\ngetcustomasset\n\n" .. e.name, Font = BODY_FONT,
				TextSize = 12, TextColor3 = Color3.fromRGB(160, 160, 160), ZIndex = 21, Parent = pg,
			})
		end
		-- bottom shade + name
		new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 60), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, ZIndex = 22, Parent = pg })
		new("TextLabel", {
			AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -60, 0, 36), BackgroundTransparency = 1,
			Text = e.name .. "\n" .. e.mood, Font = BOLD_FONT, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 23, Parent = pg,
		})
		-- like
		local like = new("TextButton", {
			AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -10, 1, -12), Size = UDim2.fromOffset(38, 38), BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.4, Text = "♥", Font = BOLD_FONT, TextSize = 20, ZIndex = 24, Parent = pg,
			TextColor3 = likes[e.name] and Color3.fromRGB(255, 70, 90) or Color3.new(1, 1, 1),
		}, { corner(19) })
		like.MouseButton1Click:Connect(function()
			likes[e.name] = not likes[e.name]
			like.TextColor3 = likes[e.name] and Color3.fromRGB(255, 70, 90) or Color3.new(1, 1, 1)
			like.TextSize = 28
			tween(like, 0.25, { TextSize = 20 })
		end)
		pageData[i] = { img = vid, sound = snd, meta = okAll and meta or nil, sheets = sheets, t0 = os.clock() }
	end
end

local feedBuilt = false
local feedBuilding = false
local function openPhone(editIndex)
	phone.Visible = true
	if not feedBuilt then
		if feedBuilding then return end
		feedBuilding = true
		if not EDIT_STATE.ready then
			local waitLbl = new("TextLabel", {
				Position = UDim2.fromOffset(6, 30), Size = UDim2.new(1, -12, 0, SCREEN_H - 2), BackgroundColor3 = Color3.new(0, 0, 0),
				Text = "LOADING EDITS...\n(first time only)", Font = BOLD_FONT, TextSize = 12, TextColor3 = Color3.fromRGB(200, 200, 200), ZIndex = 30, Parent = phone,
			}, { corner(14) })
			while not EDIT_STATE.ready and gui.Parent do task.wait(0.1) end
			waitLbl:Destroy()
		end
		buildFeed()
		feedBuilt, feedBuilding = true, false
	end
	task.delay(0.2, function() goTo(editIndex, true) end)
end
phClose.MouseButton1Click:Connect(function()
	phone.Visible = false
	for _, d in ipairs(pageData) do if d.sound then pcall(function() d.sound:Stop() end) end end
end)

------------------------------------------------------------
-- MOOD LOGIC
------------------------------------------------------------
local function showMoods()
	listView.Visible, moodView.Visible = false, true
end

local function showMood(mood, color)
	moodView.Visible, listView.Visible = false, true
	listTitle.Text = mood
	listTitle.TextColor3 = color
	for _, c in ipairs(editList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	for idx, e in ipairs(EDITS) do
		if e.mood == mood then
			local b = new("TextButton", {
				Size = UDim2.new(1, -4, 0, 42), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Text = "   ▶  " .. e.name,
				Font = BOLD_FONT, TextSize = 14, TextColor3 = Color3.new(1, 1, 1), TextXAlignment = Enum.TextXAlignment.Left, Parent = editList,
			}, { corner(8), stroke(color, 1, 0.5) })
			b.MouseButton1Click:Connect(function() openPhone(idx) end)
		end
	end
end

for _, m in ipairs(MOODS) do
	local b = new("TextButton", {
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Text = m[1], Font = TITLE_FONT, TextSize = 14,
		TextColor3 = m[2], Parent = moodGrid,
	}, { corner(10), stroke(m[2], 1.2, 0.2) })
	b.MouseButton1Click:Connect(function() showMood(m[1], m[2]) end)
end
backBtn.MouseButton1Click:Connect(showMoods)
tabButtons["EDITS"].MouseButton1Click:Connect(showMoods)

-- SUKUNA PAGE
local SK = {}
local sukPage = addTab("SUKUNA")
new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = "SUKUNA MOVES", Font = TITLE_FONT, TextSize = 13,
	TextColor3 = Color3.fromRGB(255, 100, 90), TextXAlignment = Enum.TextXAlignment.Left, Parent = sukPage,
})
local sukStatus = new("TextLabel", {
	AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1,
	Text = "tap a move", Font = BODY_FONT, TextSize = 11, TextColor3 = Color3.fromRGB(225, 205, 185), TextXAlignment = Enum.TextXAlignment.Left, Parent = sukPage,
})
SK.setStatus = function(t) sukStatus.Text = t end
local sukScroll = new("ScrollingFrame", {
	Position = UDim2.fromOffset(0, 26), Size = UDim2.new(1, 0, 1, -46), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
	ScrollBarImageColor3 = CONFIG.Accent, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = sukPage,
}, { new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
local sukGrid = new("Frame", { Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = 1, Parent = sukScroll }, {
	new("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 48), CellPadding = UDim2.fromOffset(8, 8) }),
})
for _, mv in ipairs({ { "MALEVOLENT SHRINE", "shrine" }, { "FURNACE", "furnace" }, { "WORLD CUTTING SLASH", "worldcut" }, { "RUSH BEATDOWN", "rush" } }) do
	local b = new("TextButton", {
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Text = mv[1], Font = BOLD_FONT, TextSize = 12, TextWrapped = true,
		TextColor3 = Color3.fromRGB(255, 125, 105), Parent = sukGrid,
	}, { corner(10), stroke(Color3.fromRGB(255, 90, 90), 1.2, 0.2) })
	b.MouseButton1Click:Connect(function()
		if SK[mv[2]] then task.spawn(SK[mv[2]]) else SK.setStatus("still loading...") end
	end)
end

-- RYUK script + more character scripts, inside the SUKUNA tab
do local __sukOk, __sukErr = pcall(function()
	local VIM = nil
	local function getVIM()
		if VIM == nil then
			local ok, svc = pcall(function() return game:GetService("VirtualInputManager") end)
			VIM = (ok and svc) or false
		end
		return VIM
	end
	local order = 1
	local function sukLoad(name, url, raw)
		SK.setStatus("loading " .. name .. "...")
		task.spawn(function()
			local ok, err = pcall(function() loadstring(RYUKGet(url, raw))() end)
			if ok then
				SK.setStatus(name .. " loaded")
			else
				warn("RYUK HUB: " .. name .. " failed -> " .. tostring(err))
				SK.setStatus(name .. " failed (link may be dead)")
			end
		end)
	end
	local function sukHeader(text)
		order = order + 1
		new("TextLabel", { Size = UDim2.new(1, -6, 0, 18), BackgroundTransparency = 1, Text = text, Font = TITLE_FONT, TextSize = 12,
			TextColor3 = Color3.fromRGB(255, 100, 90), TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = order, Parent = sukScroll })
	end

	-- RYUK script (replaces ULTRA INSTINCT)
	sukHeader("RYUK")
	order = order + 1
	local noxBtn = new("TextButton", {
		Size = UDim2.new(1, -6, 0, 40), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Text = "⚡ RYUK SCRIPT",
		Font = BOLD_FONT, TextSize = 13, TextColor3 = CONFIG.Accent, LayoutOrder = order, Parent = sukScroll,
	}, { corner(10), stroke(CONFIG.Accent, 1.2, 0.2) })
	noxBtn.MouseButton1Click:Connect(function()
		sukLoad("RYUK", CONFIG.NoxUrl, true)
	end)

	-- more characters
	sukHeader("MORE CHARACTERS")
	order = order + 1
	local charGrid = new("Frame", { Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = order, Parent = sukScroll }, {
		new("UIGridLayout", { CellSize = UDim2.new(0.5, -4, 0, 40), CellPadding = UDim2.fromOffset(8, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
	})
	local CHARS = {
		{ "AYANOKOJI (MAIN)", "https://pastefy.app/IF1h8gKK/raw", true },
		{ "AYANOKOJI (TEXT)", "https://pastefy.app/pYBJqC36/raw", true },
		{ "GAROU 📱", "https://pastefy.app/rCsSpwn3/raw" },
		{ "SHADES", "https://pastefy.app/wOmfg6M0/raw" },
		{ "DYSYNC", "https://pastefy.app/MKQhZyAn/raw", true },
		{ "SAITAMA", "https://pastefy.app/pa9ok3yb/raw" },
		{ "GUN?~", "https://raw.githubusercontent.com/randomstring0/Qwerty/refs/heads/main/qwerty34.lua" },
		{ "SONIC 🖥 PC", "https://pastefy.app/WkruxXtv/raw", true },
		{ "SONIC 📱 PHONE", "https://pastefy.app/CEb6oAMl/raw", true },
		{ "FPS OPTIMIZER", "https://pastefy.app/vYTnF234/raw", true },
		{ "GOJO", "https://pastefy.app/nz8UV553/raw" },
		{ "TIME STOP", "https://pastefy.app/rAfE34wv/raw" },
		{ "SYSTEM BROKEN", "https://raw.githubusercontent.com/GZSSF/script3/95a45577475502cfbf546ae9ca8fc4f00b61eb83/script3" },
		{ "IDK BRO", "https://pastefy.app/az0yaa2e/raw" },
		{ "SANS", "https://pastefy.app/rLplSwYW/raw", true },
		{ "SHADOW (FLASH)", "https://raw.githubusercontent.com/NetlessScripter/Miles-Morales/refs/heads/main/The%20Flash%20Script", true },
	}
	for i, c in ipairs(CHARS) do
		local b = new("TextButton", {
			BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Text = c[1], Font = BOLD_FONT, TextSize = 12, TextWrapped = true,
			TextColor3 = Color3.new(1, 1, 1), LayoutOrder = i, Parent = charGrid,
		}, { corner(10), stroke(CONFIG.Accent, 1, 0.45) })
		b.MouseButton1Click:Connect(function() sukLoad(c[1], c[2], c[3]) end)
	end
end)
if not __sukOk then warn("RYUK HUB: SUKUNA extras failed -> " .. tostring(__sukErr)) end
end

-- TOOLS PAGE (utility + self-protection features ported from the earlier hub)
do
	local tpage = addTab("TOOLS")
	local scroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = tpage,
	}, { new("UIListLayout", { Padding = UDim.new(0, 6) }) })
	local lpl = Players.LocalPlayer
	local S = {}

	local function addBtn(text, fn)
		local b = new("TextButton", {
			Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Text = text,
			Font = BOLD_FONT, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), Parent = scroll,
		}, { corner(8), stroke(CONFIG.Accent, 1, 0.5) })
		b.MouseButton1Click:Connect(function() fn(b) end)
		return b
	end
	local function addToggle(label, key, onChange)
		local b
		b = addBtn(label .. ": OFF", function()
			S[key] = not S[key]
			b.Text = label .. ": " .. (S[key] and "ON" or "OFF")
			b.TextColor3 = S[key] and CONFIG.Accent or Color3.new(1, 1, 1)
			if onChange then onChange(S[key]) end
		end)
	end
	local function me()
		local c = lpl.Character
		return c, c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
	end
	local function safeLoad(url)
		local ok, err = pcall(function() loadstring(RYUKGet(url))() end)
		if not ok then warn("TOOLS: failed to run " .. url .. " -> " .. tostring(err)) end
	end

	new("TextLabel", { Size = UDim2.new(1, -6, 0, 18), BackgroundTransparency = 1, Text = "SELF / PROTECTION", Font = BOLD_FONT, TextSize = 11,
		TextColor3 = CONFIG.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = scroll })
	addToggle("ANTI-VOID", "antivoid")
	addToggle("ANTI-SIT", "antisit")
	addToggle("ANTI-FLING", "antifling")
	addToggle("NOCLIP", "noclip")
	addToggle("INFINITE JUMP", "infjump")
	local afk = false
	addBtn("ANTI-AFK", function(b)
		if afk then return end
		afk = true
		b.Text = "ANTI-AFK: ON"
		b.TextColor3 = CONFIG.Accent
		track_conn(lpl.Idled, function()
			pcall(function()
				game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
		end)
	end)

	new("TextLabel", { Size = UDim2.new(1, -6, 0, 18), BackgroundTransparency = 1, Text = "PLAYERS", Font = BOLD_FONT, TextSize = 11,
		TextColor3 = CONFIG.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = scroll })
	local box = new("TextBox", {
		Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Text = "", PlaceholderText = "[PLAYER NAME]",
		PlaceholderColor3 = Color3.fromRGB(170, 170, 170), TextColor3 = Color3.new(1, 1, 1), Font = BODY_FONT, TextSize = 12, ClearTextOnFocus = false, Parent = scroll,
	}, { corner(8) })
	local function getTarget()
		local n = box.Text:lower()
		if n == "" then return nil end
		for _, v in ipairs(Players:GetPlayers()) do
			if v ~= lpl and (v.Name:lower():find(n, 1, true) or v.DisplayName:lower():find(n, 1, true)) then return v end
		end
	end
	addBtn("SPECTATE", function()
		local t = getTarget()
		local h = t and t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if h then workspace.CurrentCamera.CameraSubject = h end
	end)
	addBtn("STOP SPECTATING", function()
		local _, h = me()
		if h then workspace.CurrentCamera.CameraSubject = h end
	end)
	addBtn("TELEPORT TO PLAYER", function()
		local t = getTarget()
		local _, _, r = me()
		local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
		if r and tr then r.CFrame = tr.CFrame * CFrame.new(0, 0, 3) end
	end)

	new("TextLabel", { Size = UDim2.new(1, -6, 0, 18), BackgroundTransparency = 1, Text = "EMOTES / MUSIC", Font = BOLD_FONT, TextSize = 11,
		TextColor3 = CONFIG.Accent, TextXAlignment = Enum.TextXAlignment.Left, Parent = scroll })
	addBtn("7YD7 EMOTE", function() safeLoad("https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024") end)
	addBtn("GAZE EMOTE", function() safeLoad("https://rawsec.dev/raw/Gazer-Ha/Gaze-stuff/refs/heads/main/Gaze%20emote") end)
	addBtn("COPY EMOTE", function() safeLoad("https://pastefy.app/sXWHdc9F/raw") end)
	addBtn("MUSIC PLAYER", function() safeLoad("https://pastebin.com/raw/rnNdW3Hd") end)

	-- background loops (cleaned up on re-run through track_conn)
	track_conn(RunService.Stepped, function()
		local c, h = me()
		if not c then return end
		if S.noclip or S.antifling then
			for _, v in ipairs(c:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
		end
		if S.antisit and h then h.Sit = false end
	end)
	track_conn(RunService.Heartbeat, function()
		if not S.antivoid then return end
		local _, _, r = me()
		if r and r.Position.Y < -50 then
			r.AssemblyLinearVelocity = Vector3.new()
			r.CFrame = CFrame.new(r.Position.X, 45, r.Position.Z)
		end
	end)
	track_conn(UIS.JumpRequest, function()
		if not S.infjump then return end
		local _, h = me()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
end

------------------------------------------------------------
-- HAIDER E KARRAR V1 FEATURES (merged into RYUK - same tabs / sections as the original hub)
-- TROLL / SPAMMER-1 / SPAMMER-2 / OTHER / SHIELD / FAKEOUT / MUSIC / CREDITS + intro + background loops
------------------------------------------------------------
local E = { Loop = false, LoopId = 0, Noclip = false, Spin = false, AntiSit = false, AntiTarget = false, AntiVoid = false, InfJump = false, AntiFling = false }
G.NoxHub = E
do local __hubOk, __hubErr = pcall(function()
	local lpl = Players.LocalPlayer
	local function me()
		local c = lpl.Character
		return c, c and c:FindFirstChildOfClass("Humanoid"), c and c:FindFirstChild("HumanoidRootPart")
	end
	local function ping(text)
		pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = CONFIG.Title, Text = text, Duration = 4 }) end)
	end

	-- SAFE LOADSTRING HELPER
	function E.SafeLoad(url)
		task.spawn(function()
			local ok, err = pcall(function() loadstring(RYUKGet(url))() end)
			if not ok then warn("RYUK HUB: Execution failed on " .. tostring(url) .. " -> " .. tostring(err)) end
		end)
	end
	local SafeLoad = E.SafeLoad

	-- UNIVERSAL CHAT BROADCAST HELPER
	function E.SendChatMessage(msg)
		pcall(function()
			local cs = game:GetService("TextChatService")
			if cs.ChatVersion == Enum.ChatVersion.TextChatService then
				local chans = cs:FindFirstChild("TextChannels")
				local general = chans and chans:FindFirstChild("RBXGeneral")
				if general then general:SendAsync(msg) end
			else
				local rep = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
				if rep and rep:FindFirstChild("SayMessageRequest") then rep.SayMessageRequest:FireServer(msg, "All") end
			end
		end)
	end
	local SendChatMessage = E.SendChatMessage

	-- HYPHENATION FOR BOY BROADCAST
	function E.Hyphenate(str)
		local chars = {}
		for i = 1, #str do
			local c = str:sub(i, i)
			if c ~= " " then table.insert(chars, c:upper()) end
		end
		return table.concat(chars, "-")
	end

	-- page / button builders (RYUK style)
	local orders = {}
	local function nextOrder(parent)
		orders[parent] = (orders[parent] or 0) + 1
		return orders[parent]
	end
	local function listPage(tabName)
		local p = addTab(tabName)
		return new("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = CONFIG.Accent,
			AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Parent = p,
		}, { new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }) })
	end
	local function header(parent, text)
		new("TextLabel", { Size = UDim2.new(1, -6, 0, 18), BackgroundTransparency = 1, Text = text, Font = BOLD_FONT, TextSize = 11,
			TextColor3 = CONFIG.Accent, TextXAlignment = Enum.TextXAlignment.Left, LayoutOrder = nextOrder(parent), Parent = parent })
	end
	local function btn(text, parent, fn)
		local b = new("TextButton", {
			Size = UDim2.new(1, -6, 0, 34), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45, Text = text,
			Font = BOLD_FONT, TextSize = 12, TextColor3 = Color3.new(1, 1, 1), TextWrapped = true, LayoutOrder = nextOrder(parent), Parent = parent,
		}, { corner(8), stroke(CONFIG.Accent, 1, 0.5) })
		b.MouseButton1Click:Connect(function() fn(b) end)
		return b
	end
	local function flagToggle(label, parent, key, onChange)
		local b
		b = btn(label .. ": OFF", parent, function()
			E[key] = not E[key]
			b.Text = label .. ": " .. (E[key] and "ON" or "OFF")
			b.TextColor3 = E[key] and CONFIG.Accent or Color3.new(1, 1, 1)
			if onChange then onChange(E[key]) end
		end)
		return b
	end

	-- one troll loop at a time (a new one replaces the old one, STOP TROLL ends it)
	local function startLoop(stepFn)
		E.LoopId = E.LoopId + 1
		local id = E.LoopId
		E.Loop = true
		task.spawn(function()
			while E.Loop and E.LoopId == id do
				pcall(stepFn)
				task.wait()
			end
		end)
	end

	--------------------------------------------------------
	-- TAB: TROLL ⚔
	--------------------------------------------------------
	local P1 = listPage("TROLL ⚔")
	local targetBox = new("TextBox", {
		Size = UDim2.new(1, -6, 0, 30), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.4, Text = "", PlaceholderText = "[TARGET NAME]",
		PlaceholderColor3 = Color3.fromRGB(170, 170, 170), TextColor3 = Color3.new(1, 1, 1), Font = BODY_FONT, TextSize = 12, ClearTextOnFocus = false,
		LayoutOrder = nextOrder(P1), Parent = P1,
	}, { corner(8) })
	function E.GetTarget()
		local n = targetBox.Text:lower()
		if n == "" then return nil end
		for _, v in ipairs(Players:GetPlayers()) do
			if v ~= lpl and (v.Name:lower():find(n, 1, true) or v.DisplayName:lower():find(n, 1, true)) then return v end
		end
	end
	local getT = E.GetTarget
	local function needTarget()
		local t = getT()
		if not t then ping("target not found") end
		return t
	end

	btn("HEADSIT ⚔", P1, function()
		local t = needTarget() if not t then return end
		startLoop(function()
			local _, h, r = me()
			local th = t.Character and t.Character:FindFirstChild("Head")
			if h and r and th then
				h.Sit = true
				r.CFrame = th.CFrame * CFrame.new(0, 1, 0)
			end
		end)
	end)
	
local banging = false
btn("BANG 🔥", P1, function(b)
    banging = not banging
    if banging then
        b.Text = "STOP BANG"
        _G.Edrin.StartBang()
        if not getT() then banging = false b.Text = "BANG 🔥" end
    else
        b.Text = "BANG 🔥"
        _G.Edrin.StopBang()
    end
end)

local headSitting = false
btn("HEAD BANG 💀", P1, function(b)
    headSitting = not headSitting
    if headSitting then
        b.Text = "STOP HEAD SIT"
        _G.Edrin.StartHeadSit()
        if not getT() then headSitting = false b.Text = "HEAD BANG 💀" end
    else
        b.Text = "HEAD BANG 💀"
        _G.Edrin.StopHeadSit()
    end
end)

btn("SUCKER 🌚", P1, function() 
    _G.Edrin.Loop = true
    local t = getT() 
    while _G.Edrin.Loop and t do 
        task.wait() 
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,-0.9,-1) * CFrame.Angles(math.rad(85),0,0) + t.Character.HumanoidRootPart.CFrame.LookVector * math.sin(tick()*25)*0.8 
        end
    end 
end)

btn("FRONT HUMP 👽", P1, function() 
    _G.Edrin.Loop = true
    local t = getT() 
    while _G.Edrin.Loop and t do 
        task.wait() 
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame * CFrame.new(0,-0.6,-1.2) * CFrame.Angles(math.rad(40),math.pi,0) + t.Character.HumanoidRootPart.CFrame.LookVector * math.sin(tick()*25)*0.8 
        end
    end 
end)

btn("FRONT HEADSIT 👺", P1, function()
		local t = needTarget() if not t then return end
		startLoop(function()
			local _, h, r = me()
			local th = t.Character and t.Character:FindFirstChild("Head")
			if h and r and th then
				h.Sit = true
				r.CFrame = th.CFrame * CFrame.new(0, 0.5, -1) * CFrame.Angles(0, math.pi, 0)
			end
		end)
	end)
	btn("SPECTATE 👀", P1, function()
		local t = needTarget()
		local h = t and t.Character and t.Character:FindFirstChildOfClass("Humanoid")
		if h then workspace.CurrentCamera.CameraSubject = h end
	end)
	btn("TELEPORT TO 😽", P1, function()
		local t = needTarget()
		local _, _, r = me()
		local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
		if r and tr then r.CFrame = tr.CFrame end
	end)
	btn("ORBIT TARGET 🤯", P1, function()
		local t = needTarget() if not t then return end
		local a = 0
		startLoop(function()
			a = a + 0.03
			local _, _, r = me()
			local tr = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
			if r and tr then r.CFrame = tr.CFrame * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, 8) end
		end)
	end)
	btn("ANNOY 💦", P1, function()
		local t = needTarget() if not t then return end
		startLoop(function()
			local _, _, r = me()
			local tr = t.Character and t.Character:FindFirstChild("HumanoidRootPart")
			if r and tr then r.CFrame = tr.CFrame * CFrame.new(math.random(-4, 4), math.random(-2, 4), math.random(-4, 4)) end
		end)
	end)
	btn("FLING 💥", P1, function() SafeLoad("https://raw.githubusercontent.com/0866/lua/main/Fling.lua") end)
	btn("STOP TROLL 🚫", P1, function()
		E.Loop = false
		E.LoopId = E.LoopId + 1
		local _, h = me()
		if h then
			h.Sit = false
			workspace.CurrentCamera.CameraSubject = h
		end
	end)

	--------------------------------------------------------
	-- TABS: SPAMMER-1 💫 / SPAMMER-2 💥
	--------------------------------------------------------
	local P2 = listPage("SPAMMER-1 💫")
	btn("EGO EMPIRE 💢", P2, function() SafeLoad("https://pastebin.com/raw/g2wyKQu9") end)
         btn("RYUK SPAMMER 💢", P2, function() SafeLoad("https://pastebin.com/raw/g2wyKQu9") end)
	btn("🖤 RYUK XOBITO 🍁", P2, function() SafeLoad("https://pastebin.com/raw/CjdkFsW7") end)
	btn("⛩️ CUSTOM SPAM ⛩️ 🍁", P2, function() SafeLoad("https://pastebin.com/raw/CjdkFsW7") end)
         btn(" ROAST SPAM  🍁", P2, function() SafeLoad("https://pastebin.com/raw/CjdkFsW7") end) 


btn("🚫 FORBID SPAMMER", P2, function() SafeLoad("https://rawscripts.net/raw/Brookhaven-RP-Forbid-Spammer-149128") end)

	local P3 = listPage("SPAMMER-2 💥")
	btn("💻 AUTO REPLY BOT 💻", P3, function() SafeLoad("https://pastebin.com/raw/g6c9hANL") end)
	btn("🇮🇳 2X CUSTOM HINDI", P3, function() SafeLoad("https://pastebin.com/raw/LPhwLLqY") end)
	btn("🌴 CUSTOM OWNER (MALAYALAM)", P3, function() SafeLoad("https://pastebin.com/raw/D6GUx6Df") end)
	btn("💀 CUSTOM OWNER (MALAYALAM)", P3, function() SafeLoad("https://pastebin.com/raw/S56WKDbU") end)

	--------------------------------------------------------
	-- TAB: BANG ☣
	--------------------------------------------------------
	local P5 = listPage("BANG ☣")
	btn("🕷 BEST BACK BANG", P5, function() 
    SafeLoad("https://pastefy.app/wdF0Iubo/raw") 
end)
	btn("🗿 BEST FACE BANG", P5, function() 
    SafeLoad("https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/mouthbang.lua") 
end)
	btn("🇦🇱 BANG PANEL", P5, function()
    SendChatMessage("🌸 ᴍᴀᴅᴇ ʙʏ RYUK 🌸 __________________________________________________________________________________________________________________________🇦🇱 RYUK ʙᴀɴɢ ᴘᴀɴᴇʟ ʟᴏᴀᴅᴇᴅ 💀⚡")
    SafeLoad("https://raw.githubusercontent.com/RYUKPAPA17/RYUKHIKHDELALA/refs/heads/main/RYUKFATHER")
end)
	btn("✨ BANGER", P5, function()
    SendChatMessage("🌸 ᴍᴀᴅᴇ ʙʏ RYUK 🌸 __________________________________________________________________________________________________________________________🔥 ᴛʜᴇ RYUK ʙᴀɴɢᴇʀ ʟᴏᴀᴅᴇᴅ 🇦🇱💀")
    SafeLoad("https://raw.githubusercontent.com/RYUKPAPA17/RYUKHIKHDELALA/refs/heads/main/noxchor")
end)
	btn("✨ BANGER 0 delay", P5, function() SafeLoad("https://raw.githubusercontent.com/RYUKPAPA17/RYUKHIKHDELALA/refs/heads/main/RYUK") end)

	btn("WIERD BANG💀", P5, function() SafeLoad("https://zoncn.vercel.app/raw/ffa970b2-1c83-403e-a912-8fb78ba1c165") end)
        
    btn("BACK BANG🌸", P5, function() SafeLoad("https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/Bang.lua") end)
	

	
btn("MULTI BANG RYUK X OBITO🔥", P5, function() SafeLoad("https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/Multi%20bang.lua") end)
	


btn("UNLIMITED TARGET BANG🔥", P5, function() SafeLoad("https://raw.githubusercontent.com/ayanjaveed503-a11y/All-Resources/refs/heads/main/Unlimited%20target%20bang.lua") end)
	


btn("✨ BANGER 1 ", P5, function() SafeLoad("https://raw.githubusercontent.com/your-username/bang5/main/script.lua") end)
	


btn("✨ BANGER 2", P5, function() SafeLoad("https://raw.githubusercontent.com/your-username/bang6/main/script.lua") end)
	



--------------------------------------------------------
	-- TAB: SHIELD 🤖
	--------------------------------------------------------
	local P6 = listPage("SHIELD 🤖")
	flagToggle("👑 ANTI-VOID (GOD MODE)", P6, "AntiVoid")
	local revBtn
	revBtn = btn("🔄 REVERSE FLING: OFF", P6, function()
		local _, _, r = me()
		local old = r and r:FindFirstChild("RYUK_ReverseFling")
		if old then
			old:Destroy()
			revBtn.Text = "🔄 REVERSE FLING: OFF"
			revBtn.TextColor3 = Color3.new(1, 1, 1)
		elseif r then
			local s = Instance.new("BodyAngularVelocity")
			s.Name = "RYUK_ReverseFling"
			s.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
			s.AngularVelocity = Vector3.new(0, 999999, 0)
			s.Parent = r
			revBtn.Text = "🔄 REVERSE FLING: ON"
			revBtn.TextColor3 = CONFIG.Accent
		end
	end)
	flagToggle("🔥 ANTI-FLING", P6, "AntiFling")
	flagToggle("🪑 ANTI-SIT", P6, "AntiSit")
	local afkOn = false
	btn("😴 ANTI-AFK", P6, function(b)
		if afkOn then return end
		afkOn = true
		b.Text = "😴 ANTI-AFK: ON"
		b.TextColor3 = CONFIG.Accent
		track_conn(lpl.Idled, function()
			pcall(function()
				game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
				task.wait(1)
				game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			end)
		end)
	end)
	-- the original hub had these flags in its background loop, now they have switches too
	flagToggle("🌀 SPIN", P6, "Spin")
	flagToggle("🛡 ANTI-TARGET", P6, "AntiTarget")
	flagToggle("👻 NOCLIP", P6, "Noclip")
	flagToggle("🦘 INFINITE JUMP", P6, "InfJump")

	--------------------------------------------------------
	-- TAB: FAKEOUT 🌌
	--------------------------------------------------------
	local P7 = listPage("FAKEOUT 🌌")
	btn("🪂 TELEPORTER V1", P7, function()
		SendChatMessage("TELEPORTER V1 BY RYUK 🚀_______________________________________________________________________________________________________________RYUK TELEPORTER V1 Loaded...")
		SafeLoad("https://pastebin.com/raw/EUSknnAF")
	end)
	btn("⚓ TELEPORTER V2 (+ VOID)", P7, function()
		SendChatMessage("TELEPORTER V2 BY RYUK 👤_______________________________________________________________________________________________________________RYUK TELEPORTER V2 Loaded...")
		SafeLoad("https://pastebin.com/raw/216FSAFS")
	end)
	btn("🕳 SKY AND VOID FALL", P7, function()
		SendChatMessage("SKY AND VOID FALLER BY RYUK 🕳 _________________________________________________________________________________________________________KOI SA BHI BANG TRY KR LE💀😂...")
		SafeLoad("https://pastefy.app/R19boYKQ/raw")
	end)
	btn("⚡ ANTIBANG", P7, function()
		SendChatMessage("ANTIBANG BY RYUK 💪_________________________________________________________________________________________________________________________________RYUK ANTIBANG Loaded...")
		SafeLoad("https://pastebin.com/raw/c3R861CE")
	end)
	btn("♾️ INFINITY LOOP", P7, function()
		SendChatMessage("INFINITY LOOP BY RYUK ♾️💪______________________________________________________________________________________________________________________________________________INFINITY LOOP LOADED...")
		SafeLoad("https://pastebin.com/raw/5TwyH081")
	end)

	--------------------------------------------------------
	-- TAB: MUSIC 🎵
	--------------------------------------------------------
	local P8 = listPage("MUSIC 🎵")
	btn("🎵 MUSIC PLAYER", P8, function()
		SendChatMessage("MUSIC PLAYER EXECUTED 🎵_____________________________________________________________________________________________FEEL THA AURA 🗿...")
		SafeLoad("https://pastebin.com/raw/rnNdW3Hd")
	end)
	header(P8, "SONGS (only you hear them)")
	local SONGS = {
		{ key = "m1", name = "💙 REZE & DENJI - KALYANI" },
		{ key = "m2", name = "💃 KAMARIYA - NAVRATRI SPECIAL" },
		{ key = "m3", name = "💜 WAGURI & RINTARO - ISHQ DE FUNNIYAR" },
		{ key = "m4", name = "🔥 TOOFAN - BAKUGO vs ALL FOR ONE" },
	}
	local songSound = new("Sound", { Name = "NoxSong", Volume = 1.2, Looped = true, Parent = gui })
	local playingKey, songBtns = nil, {}
	local function resetSongBtns()
		for _, s in ipairs(SONGS) do
			local b = songBtns[s.key]
			if b then b.Text = "▶  " .. s.name b.TextColor3 = Color3.new(1, 1, 1) end
		end
	end
	for _, s in ipairs(SONGS) do
		songBtns[s.key] = btn("▶  " .. s.name, P8, function(b)
			if playingKey == s.key then
				songSound:Stop()
				playingKey = nil
				resetSongBtns()
				return
			end
			b.Text = "⏳  " .. s.name
			if not ASSETS[s.key] then prepare(s.key) end
			local id = ASSETS[s.key]
			if not id then
				resetSongBtns()
				ping("song couldn't load - needs writefile + getcustomasset")
				return
			end
			songSound:Stop()
			songSound.SoundId = id
			songSound.TimePosition = 0
			songSound:Play()
			playingKey = s.key
			resetSongBtns()
			b.Text = "⏸  " .. s.name
			b.TextColor3 = CONFIG.Accent
		end)
	end
	btn("⏹ STOP SONG", P8, function()
		songSound:Stop()
		playingKey = nil
		resetSongBtns()
	end)
	local loopBtn
	loopBtn = btn("🔁 LOOP: ON", P8, function()
		songSound.Looped = not songSound.Looped
		loopBtn.Text = "🔁 LOOP: " .. (songSound.Looped and "ON" or "OFF")
	end)

	-- VOLUME 1-10 (at 10 = 100% = 8D AUDIO: the song circles around your head)
	header(P8, "VOLUME 1-10  (10 = 100% = 8D AUDIO 🎧)")
	local volLevel, eightD, orbitPart, orbitConn, reverb = 5, false, nil, nil, nil
	local volLabel
	local function set8D(on)
		if on == eightD then return end
		eightD = on
		local wasPlaying, pos = songSound.IsPlaying, songSound.TimePosition
		if on then
			orbitPart = Instance.new("Part")
			orbitPart.Name, orbitPart.Anchored, orbitPart.CanCollide, orbitPart.Transparency = "NoxOrbit", true, false, 1
			orbitPart.Size = Vector3.new(0.5, 0.5, 0.5)
			pcall(function() orbitPart.CanQuery, orbitPart.CanTouch = false, false end)
			orbitPart.Parent = workspace
			G.RYUKM.orbit = orbitPart
			songSound.RollOffMode = Enum.RollOffMode.Linear
			songSound.RollOffMinDistance, songSound.RollOffMaxDistance = 20, 80
			songSound.Parent = orbitPart
			reverb = Instance.new("ReverbSoundEffect")
			reverb.DecayTime, reverb.Density, reverb.Diffusion, reverb.DryLevel, reverb.WetLevel = 1.8, 0.8, 0.8, 0, -12
			reverb.Parent = songSound
			local ang = 0
			orbitConn = track_conn(RunService.RenderStepped, function(dt)
				local cam = workspace.CurrentCamera
				if not cam or not orbitPart then return end
				ang = ang + dt * 0.9
				local cf = cam.CFrame
				orbitPart.Position = cf.Position + cf.RightVector * (math.cos(ang) * 8) + cf.LookVector * (math.sin(ang) * 8)
			end)
		else
			if orbitConn then orbitConn:Disconnect() orbitConn = nil end
			songSound.Parent = gui
			if reverb then reverb:Destroy() reverb = nil end
			if orbitPart then orbitPart:Destroy() orbitPart = nil G.RYUKM.orbit = nil end
		end
		if wasPlaying and not songSound.IsPlaying then
			songSound.TimePosition = pos
			songSound:Play()
		end
	end
	local function applyVolume()
		songSound.Volume = volLevel * 0.24
		volLabel.Text = volLevel >= 10 and "10/10 (100%)  🎧 8D AUDIO" or ("🔊 VOLUME  " .. volLevel .. " / 10")
		set8D(volLevel >= 10)
	end
	local volRow = new("Frame", { Size = UDim2.new(1, -6, 0, 34), BackgroundTransparency = 1, LayoutOrder = nextOrder(P8), Parent = P8 })
	local function volBtn(text, x, w, fn)
		local b = new("TextButton", {
			Position = UDim2.new(x, 0, 0, 0), Size = UDim2.new(w, -4, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.45,
			Text = text, Font = BOLD_FONT, TextSize = 16, TextColor3 = Color3.new(1, 1, 1), Parent = volRow,
		}, { corner(8), stroke(CONFIG.Accent, 1, 0.5) })
		b.MouseButton1Click:Connect(fn)
		return b
	end
	volBtn("−", 0, 0.2, function() volLevel = math.max(1, volLevel - 1) applyVolume() end)
	volLabel = new("TextLabel", {
		Position = UDim2.fromScale(0.2, 0), Size = UDim2.fromScale(0.6, 1), BackgroundTransparency = 1, Text = "", Font = BOLD_FONT,
		TextSize = 12, TextColor3 = CONFIG.Accent, Parent = volRow,
	})
	volBtn("+", 0.8, 0.2, function() volLevel = math.min(10, volLevel + 1) applyVolume() end)
	applyVolume()
        	--------------------------------------------------------
	-- TAB: OTHER ☣
	--------------------------------------------------------
	local P10 = listPage("OTHER ☣")
	btn("OUTFIT REVEALER🛍️", P9, function() SafeLoad("https://pastebin.com/raw/cWss0QSN") end)
        btn("🎭 7YD7 EMOTE", P9, function() SafeLoad("https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024") end)
	btn("✨ GAZE EMOTE", P9, function() SafeLoad("https://rawsec.dev/raw/Gazer-Ha/Gaze-stuff/refs/heads/main/Gaze%20emote") end)
	btn("💃 COPY EMOTE FULL WORKING", P9, function() SafeLoad("https://pastefy.app/sXWHdc9F/raw") end)
	btn("🪓 SKY DESTROYER", P9, function() SafeLoad("https://rawscripts.net/raw/Universal-Script-sky-destroyer-V2-AXEZZ-110640") end)
	btn("🧘‍♂️ STAND BY", P9, function() SafeLoad("https://pastebin.com/raw/10c0XURE") end)
	btn("🎈 HEADSTAND", P9, function() SafeLoad("https://pastebin.com/raw/1zxuPzS4") end)

	--------------------------------------------------------
	-- TAB: CREDITS 👑
	--------------------------------------------------------
	local P10 = listPage("CREDITS 👑")
	new("TextLabel", {
		Size = UDim2.new(1, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1),
		TextSize = 16, Font = BOLD_FONT, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = nextOrder(P10), Parent = P10,
		Text = "👑 OWNER - RYUK x ali\n\n🌐 INSTAGRAM ID - itz_ryuk_0 , urfavv._.obitooo_\n🔥 BANG AND SPAM TO DESTROY ANYONE 🔥\n~~~~~~~~~~~~~~~~~~~~~~\n\n💬 ROBLOX USERNAME -(OFC_KAiZeRU) (OBITO)\n\n💬 SCRIPT WITH UNBELIEVABLE FEATURES ♡\n\n" .. CONFIG.Credit,
	})

	--------------------------------------------------------
	-- GLOBAL LOOPS (from the original hub)
	--------------------------------------------------------
	track_conn(RunService.Stepped, function()
		local c, h, r = me()
		if c and (E.Noclip or E.AntiFling) then
			for _, v in ipairs(c:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
		end
		if E.Spin and r then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(30), 0) end
		if E.AntiSit and h then h.Sit = false end
		if E.AntiTarget then
			for _, v in ipairs(Players:GetPlayers()) do
				local vr = v ~= lpl and v.Character and v.Character:FindFirstChild("HumanoidRootPart")
				if vr then pcall(function() vr.CanCollide = false end) end
			end
		end
	end)
	track_conn(RunService.Heartbeat, function()
		if not E.AntiVoid then return end
		local _, _, r = me()
		if r and r.Position.Y < -50 then
			r.AssemblyLinearVelocity = Vector3.new()
			r.CFrame = CFrame.new(r.Position.X, 45, r.Position.Z)
		end
	end)
	track_conn(UIS.JumpRequest, function()
		if not E.InfJump then return end
		local _, h = me()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)

	--------------------------------------------------------
	-- INTRO MODAL & CHAT ANNOUNCEMENTS (shown after the loading screen)
	--------------------------------------------------------
	function E.ShowIntro(onDone)
		local IntroFrame = new("Frame", {
			Size = UDim2.fromOffset(310, 210), Position = UDim2.new(0.5, -155, 0.5, -105), BackgroundColor3 = CONFIG.Dark,
			BackgroundTransparency = 0.1, Active = true, ClipsDescendants = true, ZIndex = 60, Parent = gui,
		}, { corner(16) })
		local introStroke = stroke(CONFIG.Accent, 2, 0)
		introStroke.Parent = IntroFrame
		task.spawn(function()
			while IntroFrame.Parent do
				introStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
				task.wait()
			end
		end)
		makeDraggable(IntroFrame, IntroFrame)
		new("TextLabel", {
			Size = UDim2.new(1, 0, 0, 42), BackgroundTransparency = 1, Text = "HAIDER E KARRAR V1", TextColor3 = CONFIG.Accent,
			Font = TITLE_FONT, TextSize = 16, ZIndex = 61, Parent = IntroFrame,
		})
		local NameInput = new("TextBox", {
			Size = UDim2.new(1, -30, 0, 38), Position = UDim2.fromOffset(15, 52), BackgroundColor3 = Color3.fromRGB(30, 14, 16), Text = "",
			PlaceholderText = "ENTER UR NAME 📛", PlaceholderColor3 = Color3.fromRGB(180, 160, 150), TextColor3 = Color3.new(1, 1, 1),
			Font = BOLD_FONT, TextSize = 16, ClearTextOnFocus = false, ZIndex = 61, Parent = IntroFrame,
		}, { corner(8), stroke(CONFIG.Accent, 1, 0) })
		local BoyBtn = new("TextButton", {
			Size = UDim2.new(0.44, 0, 0, 42), Position = UDim2.new(0.05, 0, 0, 115), BackgroundColor3 = Color3.fromRGB(30, 30, 60),
			Text = "BOY 👦", TextColor3 = Color3.fromRGB(100, 200, 255), Font = BOLD_FONT, TextSize = 16, ZIndex = 61, Parent = IntroFrame,
		}, { corner(8) })
		local GirlBtn = new("TextButton", {
			Size = UDim2.new(0.44, 0, 0, 42), Position = UDim2.new(0.51, 0, 0, 115), BackgroundColor3 = Color3.fromRGB(60, 30, 50),
			Text = "GIRL 👧", TextColor3 = Color3.fromRGB(255, 150, 220), Font = BOLD_FONT, TextSize = 16, ZIndex = 61, Parent = IntroFrame,
		}, { corner(8) })
		local done = false
		local function completeIntro(gender)
			if done then return end
			done = true
			local entered = NameInput.Text
			if entered:gsub("%s+", "") == "" then entered = lpl.DisplayName or lpl.Name end
			local repeatedAt = string.rep("@", 130)
			SendChatMessage("SCRIPT BY " .. entered .. " " .. repeatedAt .. " " .. entered .. " V2 LOADED 🇦🇱")
			task.wait(0.35)
			if gender == "BOY" then
				local spaced = E.Hyphenate(entered)
				SendChatMessage("WARNING ⚠️ " .. entered .. " HAS EXCUTEED THE SCRIPT 💀 AB HOGA TERE KHEL KYUKI " .. spaced .. " IS HERE 💀 DON'T FEAR " .. entered .. " V2 IS HERE 💀")
			elseif gender == "GIRL" then
				SendChatMessage("WARNING ⚠️ " .. entered .. " HAS EXCUTEED THIS SCRIPT 💀 💅🏻 KYUKI THE QUEEN IS HERE 💅🏻 " .. entered .. " SHE IS BACK 💀 AB HOGA TERE KHEL 💀")
			end
			IntroFrame:Destroy()
			if onDone then onDone() end
		end
		BoyBtn.MouseButton1Click:Connect(function() completeIntro("BOY") end)
		GirlBtn.MouseButton1Click:Connect(function() completeIntro("GIRL") end)
	end
end)
if not __hubOk then
	warn("RYUK HUB: hub section failed -> " .. tostring(__hubErr))
	pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "RYUK", Text = "some tabs failed to load: " .. tostring(__hubErr):sub(1, 120), Duration = 10 }) end)
end

end

setTab("HOME")

------------------------------------------------------------
-- TOGGLE (the image)
------------------------------------------------------------
local toggle = new("ImageButton", {
	Name = "Toggle", Size = UDim2.fromOffset(CONFIG.ToggleSize, CONFIG.ToggleSize), Position = UDim2.new(0, 20, 0.5, -CONFIG.ToggleSize / 2),
	BackgroundColor3 = CONFIG.Dark, Image = img, ScaleType = Enum.ScaleType.Crop, Visible = false, AutoButtonColor = false, ZIndex = 10, Parent = gui,
}, { corner(CONFIG.ToggleSize / 2), stroke(CONFIG.Accent, 2, 0.1) })

local open = true
local toggleState = makeDraggable(toggle, toggle)
toggle.Activated:Connect(function()
	if toggleState.moved then return end -- it was a drag, not a click
	open = not main.Visible
	main.Visible = open
end)
closeBtn.MouseButton1Click:Connect(function() open = false main.Visible = false end)


------------------------------------------------------------
-- SUKUNA MOVES: Malevolent Shrine / Furnace / World Cutting Slash / Rush Beatdown
-- (R6 / R15 / custom rigs; files come from the same GitHub sources as the original script)
------------------------------------------------------------
do
	local TS = TweenService
	local Lighting = game:GetService("Lighting")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Debris = game:GetService("Debris")
	local lp = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local RAW = "https://github.com/ian49972/smth/raw/refs/heads/main/"

	local function notify(t)
		pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "RYUK SUKUNA", Text = tostring(t):sub(1, 180), Duration = 6 }) end)
	end
	local function status(t) if SK.setStatus then SK.setStatus(t) end end

	local function ensure(name, url)
		if not (_isfile and _writefile) then return false end
		pcall(function() if not _isfile(name) then _writefile(name, RYUKGet(url)) end end)
		local ok, ex = pcall(_isfile, name)
		return ok and ex and true or false
	end
	local function sound(file, vol)
		task.spawn(function()
			pcall(function()
				if not ensure(file, RAW .. file) then return end
				local s = Instance.new("Sound")
				s.SoundId, s.Volume, s.Parent = _asset(file), vol or 1, workspace
				s:Play()
				Debris:AddItem(s, 40)
			end)
		end)
	end
	local function soundId(id, vol)
		pcall(function()
			local s = Instance.new("Sound")
			s.SoundId, s.Volume, s.Parent = id, vol or 1, workspace
			s:Play()
			Debris:AddItem(s, 40)
		end)
	end

	-- current character (refreshed before every move, so respawns / any rig work)
	local character, humanoid, hrp, isR6
	local function refresh()
		character = lp.Character
		humanoid = character and character:FindFirstChildOfClass("Humanoid")
		hrp = character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart"))
		if not (character and humanoid and hrp) then notify("your character isn't ready yet") return false end
		isR6 = humanoid.RigType == Enum.HumanoidRigType.R6
		return true
	end
	local function findPart(...)
		for _, n in ipairs({ ... }) do
			local p = character:FindFirstChild(n, true)
			if p and p:IsA("BasePart") then return p end
		end
	end
	local function killAnimator()
		for _, a in ipairs(character:GetDescendants()) do if a:IsA("Animator") then a:Destroy() end end
	end
	local function restoreAnimator()
		if humanoid and humanoid.Parent and not humanoid:FindFirstChildOfClass("Animator") then Instance.new("Animator", humanoid) end
	end

	-- ===== keyframe player with rig matching =====
	local EasingStyleMap = {
		[Enum.PoseEasingStyle.Linear] = Enum.EasingStyle.Linear, [Enum.PoseEasingStyle.Bounce] = Enum.EasingStyle.Bounce,
		[Enum.PoseEasingStyle.Cubic] = Enum.EasingStyle.Cubic, [Enum.PoseEasingStyle.Elastic] = Enum.EasingStyle.Elastic,
		[Enum.PoseEasingStyle.Constant] = Enum.EasingStyle.Linear,
	}
	local EasingDirectionMap = {
		[Enum.PoseEasingDirection.In] = Enum.EasingDirection.In, [Enum.PoseEasingDirection.Out] = Enum.EasingDirection.Out,
		[Enum.PoseEasingDirection.InOut] = Enum.EasingDirection.InOut,
	}
	-- R6 <-> R15 names (UpperTorso has no R6 twin, so it is skipped on R6)
	local OBITOAS = {
		LowerTorso = { "Torso" }, Torso = { "LowerTorso", "UpperTorso" }, Head = { "Head" },
		LeftUpperArm = { "Left Arm" }, RightUpperArm = { "Right Arm" }, LeftUpperLeg = { "Left Leg" }, RightUpperLeg = { "Right Leg" },
		["Left Arm"] = { "LeftUpperArm" }, ["Right Arm"] = { "RightUpperArm" }, ["Left Leg"] = { "LeftUpperLeg" }, ["Right Leg"] = { "RightUpperLeg" },
	}

	local function PlayKeyframeSequence(Model, KeyframeSequence, SpeedMult)
		SpeedMult = SpeedMult or 1
		local keyframes = {}
		for _, kf in ipairs(KeyframeSequence:GetKeyframes()) do table.insert(keyframes, { Time = kf.Time, KF = kf }) end
		table.sort(keyframes, function(a, b) return a.Time < b.Time end)
		if #keyframes == 0 then return end

		local motors, bones = {}, {}
		for _, d in ipairs(Model:GetDescendants()) do
			if d:IsA("Motor6D") and d.Part0 and d.Part1 and d.Name ~= "LeftFingerJoint" and d.Name ~= "RightFingerJoint" then table.insert(motors, d)
			elseif d:IsA("Bone") then table.insert(bones, d) end
		end

		local resolved, used, valueMap, tweenList = {}, {}, {}, {}
		local function resolve(pose)
			local name = pose.Name
			if resolved[name] ~= nil then return resolved[name] or nil end
			local parentName = pose.Parent and pose.Parent.Name
			local found, typ
			local function try(n, strict)
				for _, m in ipairs(motors) do
					if not used[m] and m.Part1.Name == n and (not strict or m.Part0.Name == parentName) then return m, "Motor6D" end
				end
				for _, b in ipairs(bones) do
					if not used[b] and b.Name == n and (not strict or (b.Parent and b.Parent.Name == parentName)) then return b, "Bone" end
				end
			end
			found, typ = try(name, true)
			if not found then found, typ = try(name, false) end
			if not found and OBITOAS[name] then
				for _, alt in ipairs(OBITOAS[name]) do
					found, typ = try(alt, false)
					if found then break end
				end
			end
			if found then
				used[found] = true
				resolved[name] = { Instance = found, Type = typ }
				return resolved[name]
			end
			resolved[name] = false
			return nil
		end

		local poseTables = {}
		for i, entry in ipairs(keyframes) do
			local tab = { Time = entry.Time, Poses = {} }
			for _, pose in ipairs(entry.KF:GetDescendants()) do
				if pose:IsA("Pose") and pose.Weight > 0 then
					local r = resolve(pose)
					if r then
						if not valueMap[pose.Name] then
							local val = Instance.new("CFrameValue")
							val.Name = "AnimValue"
							val.Parent = r.Instance
							valueMap[pose.Name] = val
						end
						tab.Poses[pose.Name] = { CFrame = pose.CFrame, Style = pose.EasingStyle, Dir = pose.EasingDirection }
					end
				end
			end
			poseTables[i] = tab
		end

		for i = 1, #poseTables - 1 do
			local kf1, kf2 = poseTables[i], poseTables[i + 1]
			local duration = math.max((kf2.Time - kf1.Time) / SpeedMult, 0.001)
			local group = { Duration = duration, Tweens = {} }
			for name, data2 in pairs(kf2.Poses) do
				if (kf1.Poses[name] or poseTables[1].Poses[name]) and valueMap[name] then
					local ti = TweenInfo.new(duration, EasingStyleMap[data2.Style] or Enum.EasingStyle.Linear, EasingDirectionMap[data2.Dir] or Enum.EasingDirection.InOut)
					group.Tweens[name] = TS:Create(valueMap[name], ti, { Value = data2.CFrame })
				end
			end
			table.insert(tweenList, group)
		end

		local heartbeatConn = RunService.Heartbeat:Connect(function()
			for name, valObj in pairs(valueMap) do
				local r = resolved[name]
				if r and r.Instance and r.Instance.Parent then r.Instance.Transform = valObj.Value end
			end
		end)

		local playing = true
		local function PlayOnce()
			for _, group in ipairs(tweenList) do
				for _, tween in pairs(group.Tweens) do tween:Play() end
				task.wait(group.Duration)
			end
		end
		task.spawn(function()
			while playing and Model and Model.Parent do PlayOnce() task.wait() end
		end)

		return {
			Stop = function()
				playing = false
				if heartbeatConn then heartbeatConn:Disconnect() heartbeatConn = nil end
				for _, group in ipairs(tweenList) do for _, tween in pairs(group.Tweens) do tween:Cancel() end end
				for _, v in pairs(valueMap) do if v then v:Destroy() end end
				for name, r in pairs(resolved) do
					if r and r.Instance and r.Instance.Parent then pcall(function() r.Instance.Transform = CFrame.new() end) end
				end
			end,
		}
	end

	-- ===== fingers (R6 arm / R15 + custom rigs hand) =====
	local leftHandle, rightHandle, leftMotor, rightMotor
	local function destroyFingers()
		if leftMotor then leftMotor:Destroy() leftMotor = nil end
		if rightMotor then rightMotor:Destroy() rightMotor = nil end
		if leftHandle then leftHandle:Destroy() leftHandle = nil end
		if rightHandle then rightHandle:Destroy() rightHandle = nil end
	end
	local function hideFingers()
		for _, h in ipairs({ leftHandle, rightHandle }) do
			if h then
				for _, p in ipairs(h:GetDescendants()) do
					if p:IsA("BasePart") then p.Transparency = 1 p.CanCollide = false end
				end
			end
		end
	end
	local function spawnFingers(assetId)
		destroyFingers()
		local ok, model = pcall(function() return game:GetObjects(assetId)[1] end)
		if not ok or not model then return end
		leftHandle, rightHandle = model:FindFirstChild("LeftHandle"), model:FindFirstChild("RightHandle")
		if not (leftHandle and rightHandle) then model:Destroy() return end

		local leftArm, rightArm, offset
		if isR6 then
			leftArm, rightArm, offset = findPart("Left Arm"), findPart("Right Arm"), CFrame.new(0, -0.85, 0)
		else
			leftArm = findPart("LeftHand", "LeftLowerArm", "LeftUpperArm", "Left Arm")
			rightArm = findPart("RightHand", "RightLowerArm", "RightUpperArm", "Right Arm")
			offset = CFrame.new(0, -0.15, 0)
		end
		if not (leftArm and rightArm) then model:Destroy() destroyFingers() return end
		local skin = leftArm.Color

		local function attach(handle, arm, name)
			for _, p in ipairs(handle:GetDescendants()) do if p:IsA("BasePart") then p.Color = skin end end
			local base = handle:FindFirstChildWhichIsA("BasePart") or handle
			local m = Instance.new("Motor6D")
			m.Name = name
			m.Part0, m.Part1, m.C0, m.C1 = arm, base, offset, CFrame.new()
			m.Parent = arm
			handle.Parent = character
			return m
		end
		leftMotor = attach(leftHandle, leftArm, "LeftFingerJoint")
		rightMotor = attach(rightHandle, rightArm, "RightFingerJoint")
		model:Destroy()
	end


	-- ===== load files + model once =====
	local T
	local function load()
		if T then return T end
		status("loading Sukuna files...")
		ensure("Sukuna.rbxmx", "https://github.com/ian49972/RBXMS/raw/refs/heads/main/Sukuna.rbxmx")
		local ok, model = pcall(function() return game:GetObjects(_asset("Sukuna.rbxmx"))[1] end)
		if not ok or not model then
			status("failed: couldn't load Sukuna.rbxmx")
			notify("couldn't load Sukuna.rbxmx (HttpGet / link may be dead)")
			return nil
		end
		model.Parent = ReplicatedStorage
		local E = model:WaitForChild("Effects", 10)
		local A = model:WaitForChild("Anims", 10)
		if not (E and A) then status("failed: model is missing folders") return nil end
		local D = E:FindFirstChild("Domain")
		local F = E:FindFirstChild("Furnance")
		local W = E:FindFirstChild("WorldSlash")
		local R = E:FindFirstChild("Rush")
		T = {
			model = model,
			shrineAnim = A:FindFirstChild("Shrine", true), openAnim = A:FindFirstChild("Open", true),
			worldCutAnim = A:FindFirstChild("WorldCut", true), rushAnim = A:FindFirstChild("Rush", true),
			shrine = D and D:FindFirstChild("MalevolentShrine", true),
			FX = D and D:FindFirstChild("FX", true), GroundFX = D and D:FindFirstChild("GroundFX", true),
			Att1 = D and D:FindFirstChild("Attachment", true), Att2 = D and D:FindFirstChild("Attachment2", true),
			Red = F and F:FindFirstChild("Red"), Black = F and F:FindFirstChild("Black"),
			leftArm = F and F:FindFirstChild("Left FireArm"), rightArm = F and F:FindFirstChild("Right FireArm"),
			arrow = F and F:FindFirstChild("Arrow"), arrow2 = F and F:FindFirstChild("Arrow2"),
			groundFire = F and F:FindFirstChild("GroundFire"), fireSlap = F and F:FindFirstChild("fireslap"), thingy = F and F:FindFirstChild("thingy"),
			PreBeam = F and F:FindFirstChild("PreBeam"), BeamCore = F and F:FindFirstChild("BeamCore"),
			Floor = F and F:FindFirstChild("Floor"), Hitbox = F and F:FindFirstChild("Hitbox"),
			Dust = W and W:FindFirstChild("Dust"), Slash = W and W:FindFirstChild("Slash"),
			Slashes = R and R:FindFirstChild("Slashes"),
		}
		status("ready")
		return T
	end

	local busy = {}
	local function guard(name, label, fn)
		return function()
			if busy[name] then status(label .. " is still running...") return end
			busy[name] = true
			status("using " .. label .. "...")
			local ok, err = pcall(function()
				if not refresh() then return end
				local t = load()
				if t then fn(t) end
			end)
			busy[name] = nil
			if not ok then
				warn("RYUK " .. label .. " error: " .. tostring(err))
				notify(label .. " error: " .. tostring(err))
				status("error - see notification")
			elseif T then status("ready") end
		end
	end

	-- ===== MALEVOLENT SHRINE =====
	SK.shrine = guard("shrine", "Malevolent Shrine", function(t)
		local shrine, FX, GroundFX, Att1, Att2 = t.shrine, t.FX, t.GroundFX, t.Att1, t.Att2
		if not shrine then notify("MalevolentShrine model not found") return end

		local function tweenShrine(fromCF, toCF, time, onDone)
			local startTime = tick()
			local conn
			conn = RunService.RenderStepped:Connect(function()
				local alpha = math.clamp((tick() - startTime) / time, 0, 1)
				shrine:PivotTo(fromCF:Lerp(toCF, alpha))
				if alpha >= 1 then conn:Disconnect() if onDone then onDone() end end
			end)
		end
		local function resetShrine()
			if FX then FX.Parent = nil end
			if GroundFX then GroundFX.Parent = nil end
			TS:Create(Lighting, TweenInfo.new(2, Enum.EasingStyle.Sine), { ClockTime = 14 }):Play()
			if shrine.Parent == workspace then
				local current = shrine:GetPivot()
				tweenShrine(current, current * CFrame.new(0, -60, 0), 2, function() shrine.Parent = ReplicatedStorage end)
			end
		end

		sound("SUKUNA.mp3")
		spawnFingers("rbxassetid://18637374258")

		local char, hum, root = character, humanoid, hrp
		if t.shrineAnim then
			killAnimator()
			root.Anchored = true
			local domainAnimPlayer = PlayKeyframeSequence(char, t.shrineAnim, 1)
			task.delay(4, function()
				if domainAnimPlayer then domainAnimPlayer:Stop() end
				local red = t.Red and t.Red:Clone()
				if red then red.Parent = root task.delay(3, function() if red then red:Destroy() end end) end
				task.delay(3, function()
					local black = t.Black and t.Black:Clone()
					if black then
						black.Parent = root
						task.delay(2, function()
							if black then black:Destroy() end
							if Att1 then Att1.Parent = root end
							if Att2 then Att2.Parent = root end
							for _, att in pairs({ Att1, Att2 }) do
								if att then
									for _, p in ipairs(att:GetChildren()) do
										if p:IsA("ParticleEmitter") then
											p.Enabled = true
											task.delay(0.5, function() if p and p.Parent then p.Enabled = false end end)
										end
									end
								end
							end
						end)
					end
				end)
			end)
			task.delay(20, function()
				if hum and hum.Parent and not hum:FindFirstChildOfClass("Animator") then Instance.new("Animator", hum) end
				root.Anchored = false
				hideFingers()
				destroyFingers()
				for _, att in pairs({ Att1, Att2 }) do
					if att then
						for _, p in ipairs(att:GetChildren()) do
							if p:IsA("ParticleEmitter") then p.Enabled = false end
						end
					end
				end
			end)
		end

		task.wait(7)
		pcall(function() if G.RYUKM and G.RYUKM.PlayToofan then task.spawn(G.RYUKM.PlayToofan) end end)
		if shrine.Parent ~= workspace then shrine.Parent = workspace end
		TS:Create(Lighting, TweenInfo.new(2), { ClockTime = 0 }):Play()

		local back = root.CFrame - root.CFrame.LookVector * 25
		local endPos = back.Position + Vector3.new(0, 1, 0)
		local targetCF = CFrame.new(endPos, endPos + root.CFrame.LookVector)
		local startCF = targetCF * CFrame.new(0, -100, 0)
		shrine:PivotTo(startCF)

		local rockPart = shrine:FindFirstChild("Rock2", true) or shrine:FindFirstChild("Rocks2", true)
		local beam = rockPart and rockPart:FindFirstChildWhichIsA("Beam")
		if beam then beam.Enabled = true end

		task.wait(2)
		local finished = false
		tweenShrine(startCF, targetCF, 3, function()
			task.wait(2)
			local shakeConn = RunService.RenderStepped:Connect(function()
				camera.CFrame = camera.CFrame * CFrame.Angles((math.random() - 0.5) * 0.08, (math.random() - 0.5) * 0.08, (math.random() - 0.5) * 0.06)
			end)
			local shrine2 = shrine:FindFirstChild("Shrine2", true)
			if shrine2 and shrine2:IsA("MeshPart") then
				local centerCF = shrine2.CFrame
				if FX then FX.Parent = workspace FX.CFrame = centerCF end
				if GroundFX then GroundFX.Parent = workspace GroundFX.CFrame = centerCF * CFrame.new(0, -35, 0) end
			end
			if beam then beam.Enabled = false end
			task.delay(32, function()
				if shakeConn then shakeConn:Disconnect() end
				resetShrine()
				finished = true
			end)
		end)
		-- keep the "busy" flag until the domain is fully over
		local waited = 0
		while not finished and waited < 60 do task.wait(0.5) waited = waited + 0.5 end
	end)

	-- ===== FURNACE =====
	SK.furnace = guard("furnace", "Furnace", function(t)
		if not t.openAnim then notify("Furnace animation missing") return end
		local char, hum, root = character, humanoid, hrp
		sound("Furnance.mp3")

		local originalSpeed = hum.WalkSpeed
		hum.WalkSpeed = 0
		killAnimator()
		local furnaceAnim = PlayKeyframeSequence(char, t.openAnim, 1.3)

		local leftClone, rightClone, fireSlapClone, thingyClone
		local leftArm = findPart("Left Arm", "LeftUpperArm", "LeftHand")
		local rightArm = findPart("Right Arm", "RightUpperArm", "RightHand")

		if t.leftArm and t.rightArm and leftArm and rightArm then
			leftClone, rightClone = t.leftArm:Clone(), t.rightArm:Clone()

			local leftWeld = Instance.new("Motor6D")
			leftWeld.Part0, leftWeld.Part1, leftWeld.C0 = leftArm, leftClone, CFrame.new()
			leftWeld.Parent = leftClone
			leftClone.Parent = char
			leftClone.Anchored = false

			local rightWeld = Instance.new("Motor6D")
			rightWeld.Part0, rightWeld.Part1, rightWeld.C0 = rightArm, rightClone, CFrame.new()
			rightWeld.Parent = rightClone
			rightClone.Parent = char
			rightClone.Anchored = false

			for _, obj in ipairs(leftClone:GetDescendants()) do if obj:IsA("Beam") then obj.Enabled = false end end
			for _, obj in ipairs(rightClone:GetDescendants()) do if obj:IsA("Beam") then obj.Enabled = false end end

			task.delay(2.5, function()
				if not (leftClone and rightClone and leftClone.Parent and rightClone.Parent) then return end
				local d1, d2 = leftClone:FindFirstChild("d1"), rightClone:FindFirstChild("d2")
				if d1 and d2 then
					for _, beam in ipairs(d1:GetChildren()) do
						if beam:IsA("Beam") then beam.Attachment0, beam.Attachment1, beam.Enabled = d1, d2, true end
					end
				end

				local colorCorr = Instance.new("ColorCorrectionEffect")
				colorCorr.Saturation = -1
				colorCorr.Parent = Lighting
				local zoomIn = TS:Create(camera, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { FieldOfView = 50 })
				local zoomOut = TS:Create(camera, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { FieldOfView = 70 })
				zoomIn:Play()
				task.wait(0.5)
				zoomOut:Play()
				task.delay(1.2, function()
					TS:Create(colorCorr, TweenInfo.new(1.5), { Saturation = 0 }):Play()
					task.delay(2, function() colorCorr:Destroy() end)
				end)

				if t.fireSlap then
					fireSlapClone = t.fireSlap:Clone()
					fireSlapClone.Parent = char
					local slapWeld = fireSlapClone:FindFirstChild("HitboxWeld")
					if slapWeld and slapWeld:IsA("ManualWeld") then slapWeld.Part1 = leftArm end
					fireSlapClone.Anchored = false
					for _, e in ipairs(fireSlapClone:GetDescendants()) do if e:IsA("ParticleEmitter") then e.Enabled = true end end
					task.delay(0.3, function()
						if fireSlapClone then
							for _, e in ipairs(fireSlapClone:GetDescendants()) do if e:IsA("ParticleEmitter") then e.Enabled = false end end
						end
					end)
				end
				if t.thingy then
					thingyClone = t.thingy:Clone()
					thingyClone.Parent = char
					local thingyWeld = thingyClone:FindFirstChild("HitboxWeld")
					if thingyWeld and thingyWeld:IsA("ManualWeld") then thingyWeld.Part1 = root end
					thingyClone.Anchored = false
				end
			end)

			task.delay(6, function()
				if leftClone then leftClone:Destroy() end
				if rightClone then rightClone:Destroy() end
				if fireSlapClone then fireSlapClone:Destroy() end
				if thingyClone then thingyClone:Destroy() end

				if t.arrow and t.arrow2 and t.groundFire then
					local arrowClone, groundClone = t.arrow:Clone(), t.groundFire:Clone()
					arrowClone.Parent, groundClone.Parent = workspace, workspace
					arrowClone:PivotTo(root.CFrame)
					groundClone:PivotTo(root.CFrame * CFrame.new(0, -3, -5))
					local arrowWeld, groundWeld = arrowClone:FindFirstChild("HitboxWeld"), groundClone:FindFirstChild("HitboxWeld")
					if arrowWeld and arrowWeld:IsA("ManualWeld") then arrowWeld.Part1 = root end
					if groundWeld and groundWeld:IsA("ManualWeld") then groundWeld.Part1 = root end

					task.delay(4, function()
						local shootPos = arrowClone:GetPivot().Position
						if arrowClone then arrowClone:Destroy() end
						if groundClone then groundClone:Destroy() end
						soundId("rbxassetid://331888892")

						local flyingArrow = t.arrow2:Clone()
						flyingArrow.Parent = workspace
						local mainPart = flyingArrow:FindFirstChildWhichIsA("BasePart") or flyingArrow
						for _, v in ipairs(flyingArrow:GetDescendants()) do if v:IsA("BodyVelocity") then v:Destroy() end end
						flyingArrow:PivotTo(CFrame.new(shootPos))

						local bv = Instance.new("BodyVelocity")
						bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						bv.Velocity = root.CFrame.LookVector * 150
						bv.Parent = mainPart

						local conn
						conn = RunService.Heartbeat:Connect(function()
							if not flyingArrow or not flyingArrow.Parent then if conn then conn:Disconnect() end return end
							if bv.Velocity.Magnitude > 5 then
								local vel = bv.Velocity
								mainPart.Rotation = Vector3.new(0, math.deg(math.atan2(-vel.X, -vel.Z)), 0)
							end
						end)

						local hitConn
						hitConn = mainPart.Touched:Connect(function(hit)
							local other = hit.Parent and hit.Parent:FindFirstChildWhichIsA("Humanoid")
							if other and other ~= hum then
								hitConn:Disconnect()
								if conn then conn:Disconnect() end
								if bv then bv:Destroy() end
								local hitPos = mainPart.Position
								flyingArrow:Destroy()
								sound("ArrowExplode.mp3")
								task.delay(11, function() soundId("rbxassetid://86403148146111") end)

								if t.PreBeam then
									local pre = t.PreBeam:Clone()
									pre:PivotTo(CFrame.new(hitPos))
									pre.Parent = workspace
									pre.Anchored = true
									local preShake = RunService.RenderStepped:Connect(function()
										camera.CFrame = camera.CFrame * CFrame.Angles((math.random() - 0.5) * 0.18, (math.random() - 0.5) * 0.18, (math.random() - 0.5) * 0.12)
									end)
									task.delay(2, function()
										preShake:Disconnect()
										if pre then pre:Destroy() end
										local core, floor, hb
										if t.BeamCore then
											core = t.BeamCore:Clone()
											core:PivotTo(CFrame.new(hitPos + Vector3.new(0, 8, 0)))
											core.Rotation = Vector3.new(0, 0, 90)
											core.Parent = workspace
											core.Anchored = true
										end
										if t.Floor then
											floor = t.Floor:Clone()
											floor:PivotTo(CFrame.new(hitPos - Vector3.new(0, 4, 0)))
											floor.Rotation = Vector3.new(0, 0, 90)
											floor.Parent = workspace
											floor.Anchored = true
										end
										if t.Hitbox then
											hb = t.Hitbox:Clone()
											hb:PivotTo(CFrame.new(hitPos))
											hb.Rotation = Vector3.new(0, 0, 90)
											hb.Parent = workspace
											hb.Anchored = true
										end
										local impactShake = RunService.RenderStepped:Connect(function()
											camera.CFrame = camera.CFrame * CFrame.Angles((math.random() - 0.5) * 0.35, (math.random() - 0.5) * 0.35, (math.random() - 0.5) * 0.25)
										end)
										task.delay(7, function()
											impactShake:Disconnect()
											if core then core:Destroy() end
											if floor then floor:Destroy() end
											if hb then hb:Destroy() end
										end)
									end)
								end
							end
						end)
						task.delay(20, function() if flyingArrow then flyingArrow:Destroy() end end)
					end)
				end
			end)
		else
			notify("Furnace parts missing - the animation will still play")
		end

		task.wait(10)
		if furnaceAnim then furnaceAnim:Stop() end
		restoreAnimator()
		hum.WalkSpeed = originalSpeed
	end)

	-- ===== WORLD CUTTING SLASH =====
	SK.worldcut = guard("worldcut", "World Cutting Slash", function(t)
		local hum, root = humanoid, hrp
		sound("SLASH.mp3")
		local originalSpeed = hum.WalkSpeed
		hum.WalkSpeed = 0
		killAnimator()
		local anim = t.worldCutAnim and PlayKeyframeSequence(character, t.worldCutAnim, 2)

		local dust = t.Dust and t.Dust:Clone()
		if dust then
			dust.Parent = root
			for _, p in ipairs(dust:GetDescendants()) do if p:IsA("ParticleEmitter") then p.Enabled = true end end
		end

		task.delay(3.3, function()
			if dust then dust:Destroy() end
			if t.Slash then
				local slash = t.Slash:Clone()
				slash.Anchored = false
				slash.Parent = workspace
				local part = slash:FindFirstChildWhichIsA("BasePart") or slash
				slash:PivotTo(root.CFrame * CFrame.new(0, 3, -8))
				local bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = root.CFrame.LookVector * 250
				bv.Parent = part
				local conn
				conn = RunService.Heartbeat:Connect(function()
					if not slash or not slash.Parent then if conn then conn:Disconnect() end return end
					if bv.Velocity.Magnitude > 5 then
						local vel = bv.Velocity
						part.Rotation = Vector3.new(0, math.deg(math.atan2(-vel.X, -vel.Z)), 0)
					end
				end)
				task.delay(10, function() if slash then slash:Destroy() end end)
			end
		end)

		task.wait(5)
		if anim then anim:Stop() end
		restoreAnimator()
		hum.WalkSpeed = originalSpeed
	end)

	-- ===== RUSH BEATDOWN =====
	SK.rush = guard("rush", "Rush Beatdown", function(t)
		local hum, root = humanoid, hrp
		sound("HAHAHA.mp3")
		local originalSpeed = hum.WalkSpeed
		hum.WalkSpeed = 75
		killAnimator()
		local anim = t.rushAnim and PlayKeyframeSequence(character, t.rushAnim, 1.1)
		local slashes = t.Slashes and t.Slashes:Clone()
		if slashes then slashes.Parent = root task.delay(3.2, function() if slashes then slashes:Destroy() end end) end
		task.wait(4)
		if anim then anim:Stop() end
		restoreAnimator()
		hum.WalkSpeed = originalSpeed
	end)

	-- re-run cleanup hook
	G.RYUK_SHRINE_STOP = function()
		pcall(function() if lp.Character then
			local r = lp.Character:FindFirstChild("HumanoidRootPart") if r then r.Anchored = false end
			local h = lp.Character:FindFirstChildOfClass("Humanoid") if h and not h:FindFirstChildOfClass("Animator") then Instance.new("Animator", h) end
		end end)
		pcall(destroyFingers)
		if T then
			pcall(function() if T.shrine then T.shrine:Destroy() end end)
			pcall(function() if T.FX then T.FX:Destroy() end end)
			pcall(function() if T.GroundFX then T.GroundFX:Destroy() end end)
			pcall(function() T.model:Destroy() end)
		end
	end
end

------------------------------------------------------------
-- RGB (every text, outline and button cycles through rainbow colours)
------------------------------------------------------------
do
	local list, idx = {}, 0
	local known = setmetatable({}, { __mode = "k" })
	local function addStroke(o, th)
		local s = Instance.new("UIStroke")
		s.Thickness, s.ApplyStrokeMode = th, Enum.ApplyStrokeMode.Border
		s.Parent = o
		return s
	end
	local function add(o, prop)
		known[o] = true
		idx = idx + 1
		list[#list + 1] = { o, prop, idx }
	end
	local function register(o)
		if known[o] then return end
		if o:IsA("UIStroke") then
			o.Transparency = 0
			add(o, "Color")
		elseif o:IsA("TextLabel") then
			add(o, "TextColor3")
		elseif o:IsA("TextButton") then
			add(o, "TextColor3")
			if not o:FindFirstChildOfClass("UIStroke") then register(addStroke(o, 1.5)) end
		elseif o:IsA("ImageButton") then
			known[o] = true
			if not o:FindFirstChildOfClass("UIStroke") then register(addStroke(o, 2)) end
		elseif o:IsA("Frame") and o.Parent == gui and o ~= loading then
			known[o] = true
			if not o:FindFirstChildOfClass("UIStroke") then register(addStroke(o, 2)) end
		end
	end
	local function scan()
		for _, o in ipairs(gui:GetDescendants()) do register(o) end
	end
	scan()
	local acc, scanAcc = 0, 0
	track_conn(RunService.Heartbeat, function(dt)
		acc, scanAcc = acc + dt, scanAcc + dt
		if scanAcc > 0.6 then scanAcc = 0 pcall(scan) end
		if acc < 0.033 then return end
		acc = 0
		local t = tick() * 0.25
		for i = #list, 1, -1 do
			local e = list[i]
			if e[1].Parent == nil then
				table.remove(list, i)
			else
				pcall(function() e[1][e[2]] = Color3.fromHSV((t + e[3] * 0.012) % 1, 0.9, 1) end)
			end
		end
	end)
end

------------------------------------------------------------
-- LOADING SEQUENCE
------------------------------------------------------------
-- edit videos decode in the background (the GUI does not wait for them)
local EDIT_KEYS = {}
for _, e in ipairs(EDITS) do
	local m = VMETA[e.video]
	if m then
		for n = 1, m.sheets do table.insert(EDIT_KEYS, e.video .. "s" .. n) end
		table.insert(EDIT_KEYS, e.video .. "a")
	end
end
task.spawn(function()
	for i, k in ipairs(EDIT_KEYS) do
		if not gui.Parent then return end
		prepare(k)
		if i % 4 == 0 then task.wait() end
	end
	EDIT_STATE.ready = true
end)

task.spawn(function()
	lSub.Text = "LOADING..."
	TweenService:Create(bar, TweenInfo.new(4, Enum.EasingStyle.Linear), { Size = UDim2.fromScale(1, 1) }):Play()
	task.wait(4)
	tween(loading, 0.25, { BackgroundTransparency = 1 })
	for _, d in ipairs(loading:GetDescendants()) do
		if d:IsA("TextLabel") then tween(d, 0.25, { TextTransparency = 1 })
		elseif d:IsA("ImageLabel") then tween(d, 0.25, { ImageTransparency = 1 })
		elseif d:IsA("Frame") then tween(d, 0.25, { BackgroundTransparency = 1 }) end
	end
	task.wait(0.27)
	loading:Destroy()
	local function reveal()
		main.Visible, toggle.Visible = true, true
		pcall(function() G.RYUKM.hideBtn.Visible = true end)
		-- GUI fully loaded -> auto-run the Malevolent Shrine
		task.wait(1)
		if CONFIG.AutoShrine ~= false and SK.shrine then task.spawn(SK.shrine) end
	end
	if CONFIG.HubIntro ~= false and E.ShowIntro then
		E.ShowIntro(function() task.spawn(reveal) end)
	else
		reveal()
	end
end)

end, function(e) return debug.traceback(tostring(e)) end)
if not __ok then
	warn("RYUK EDITS ERROR: " .. tostring(__err))
	pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = "RYUK ERROR", Text = tostring(__err):sub(1, 180), Duration = 15}) end)
end
