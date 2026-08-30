--[[==========================================================================
	MainUI - Hub com abas (Main / Pulo / Velocidade) - LocalScript

	Criado 100% por codigo. O script cria:
	  - Um botao flutuante circular no canto inferior direito
	  - Um hub com abas laterais: MAIN | PULO | VELOCIDADE
	  Cada aba abre uma "janela" interna com seus proprios controles.

	ONDE COLOCAR:
		StarterPlayer (Explorer) -> StarterPlayerScripts -> LocalScript
		(cole este codigo inteiro dentro desse LocalScript)

	Roda uma vez por jogador (nao duplica no respawn) e reaplica as
	configuracoes depois que o personagem morre e renasce.
============================================================================--]]

-- Servicos //
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

---------------------------------------------------------------------------
-- 0. Guarda anti-duplicacao
---------------------------------------------------------------------------
local GUI_NAME = "MainSettingsUI"

local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then
	old:Destroy()
end

local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

---------------------------------------------------------------------------
-- Estado das configuracoes
---------------------------------------------------------------------------
local settings = {
	wsEnabled = false,
	wsValue = DEFAULT_WALKSPEED,
	jpEnabled = false,
	jpValue = DEFAULT_JUMPPOWER,
	fovValue = 70,
	infiniteJump = false,

	espEnabled = false,
	espTeamColor = true,
	aimbotEnabled = false,
	aimFOV = 150,
	aimSmooth = 4,
	flyEnabled = false,
	flySpeed = 50,
	noclipEnabled = false,
}

-- Alvos (nao-jogadores) para ESP/Aimbot: cavalos, inimigos, etc.
local ESP_TARGETS = {
	Workspace = { "Zombie", "Zombies", "Creeper" },
}

---------------------------------------------------------------------------
-- Aplica as configuracoes em um personagem (inicio + respawn)
---------------------------------------------------------------------------
local function applySettings(character)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return
	end
	if settings.wsEnabled then
		humanoid.WalkSpeed = settings.wsValue
	end
	if settings.jpEnabled then
		humanoid.JumpPower = settings.jpValue
	end
end

player.CharacterAdded:Connect(applySettings)

if player.Character then
	applySettings(player.Character)
end

---------------------------------------------------------------------------
-- CONSTRUCAO DA INTERFACE (dentro de createUI para capturar erros)
---------------------------------------------------------------------------
local function createUI()

	-- Tema escuro
	local Theme = {
		background = Color3.fromRGB(13, 15, 23),
		surface    = Color3.fromRGB(26, 29, 40),
		surfaceAlt = Color3.fromRGB(37, 41, 56),
		accent     = Color3.fromRGB(99, 130, 246),
		success    = Color3.fromRGB(72, 199, 142),
		danger     = Color3.fromRGB(235, 87, 87),
		text       = Color3.fromRGB(240, 240, 248),
		textMuted  = Color3.fromRGB(150, 155, 175),
		white      = Color3.fromRGB(255, 255, 255),
	}

	-- ScreenGui (nao some no respawn)
	local gui = Instance.new("ScreenGui")
	gui.Name = GUI_NAME
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.DisplayOrder = 100
	gui.Parent = PlayerGui

	-- Tamanho da tela (nao depende da camera)
	local viewport = gui.AbsoluteSize
	if viewport.X < 1 or viewport.Y < 1 then
		viewport = Vector2.new(1000, 750)
	end
	local windowW = math.clamp(viewport.X * 0.94, 340, 440)
	local windowH = math.clamp(viewport.Y * 0.82, 430, 560)
	local windowSize = UDim2.fromOffset(windowW, windowH)
	local windowCenter = UDim2.fromScale(0.5, 0.5)

	-- Helpers visuais
	local function applyCorner(obj, radius)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, radius)
		corner.Parent = obj
	end

	local function tweenSize(obj, fromScale, toScale, time, easingStyle)
		local base = obj._baseSize or obj.Size
		obj._baseSize = base
		local from = UDim2.new(base.X.Scale, base.X.Offset * fromScale, base.Y.Scale, base.Y.Offset * fromScale)
		local to = UDim2.new(base.X.Scale, base.X.Offset * toScale, base.Y.Scale, base.Y.Offset * toScale)
		obj.Size = from
		local tw = TweenService:Create(obj, TweenInfo.new(time or 0.15, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = to })
		tw:Play()
	end

	-------------------------------------------------------------
	-- 1. BOTAO FLUTUANTE (abre/fecha o hub)
	-------------------------------------------------------------
	local floatingBtn = Instance.new("TextButton")
	floatingBtn.Name = "FloatingButton"
	floatingBtn.BackgroundColor3 = Theme.surfaceAlt
	floatingBtn.BorderSizePixel = 0
	floatingBtn.AutoButtonColor = false
	floatingBtn.Text = ""
	floatingBtn.Size = UDim2.fromOffset(56, 56)
	floatingBtn.AnchorPoint = Vector2.new(1, 1)
	local marginBottom = UserInputService.TouchEnabled and 40 or 24
	floatingBtn.Position = UDim2.new(1, -20, 1, -marginBottom)
	floatingBtn.ZIndex = 20
	applyCorner(floatingBtn, 28)
	floatingBtn.Parent = gui

	-- Icone "hamburguer" feito de 3 barras
	local iconParent = Instance.new("Frame")
	iconParent.BackgroundTransparency = 1
	iconParent.Size = UDim2.fromOffset(22, 14)
	iconParent.AnchorPoint = Vector2.new(0.5, 0.5)
	iconParent.Position = UDim2.fromScale(0.5, 0.5)
	iconParent.ZIndex = floatingBtn.ZIndex + 1
	iconParent.Parent = floatingBtn

	for i = 0, 2 do
		local bar = Instance.new("Frame")
		bar.BackgroundColor3 = Theme.text
		bar.BorderSizePixel = 0
		bar.Size = UDim2.new(1, 0, 0, 3)
		bar.Position = UDim2.new(0, 0, 0, i * 5)
		bar.ZIndex = iconParent.ZIndex
		applyCorner(bar, 2)
		bar.Parent = iconParent
	end

	floatingBtn.MouseEnter:Connect(function()
		tweenSize(floatingBtn, 1, 1.12, 0.12, Enum.EasingStyle.Back)
	end)
	floatingBtn.MouseLeave:Connect(function()
		tweenSize(floatingBtn, 1, 1, 0.12)
	end)

	local function pressDown(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			tweenSize(floatingBtn, 1, 0.9, 0.08)
		end
	end
	local function pressUp(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			tweenSize(floatingBtn, 1, 1, 0.12, Enum.EasingStyle.Back)
		end
	end
	floatingBtn.InputBegan:Connect(pressDown)
	floatingBtn.InputEnded:Connect(pressUp)

	-------------------------------------------------------------
	-- 2. JANELA PRINCIPAL DO HUB
	-------------------------------------------------------------
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainWindow"
	mainFrame.BackgroundColor3 = Theme.surface
	mainFrame.BorderSizePixel = 0
	mainFrame.Size = windowSize
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = windowCenter
	mainFrame.Visible = false
	mainFrame.ZIndex = 30
	applyCorner(mainFrame, 14)
	mainFrame.Parent = gui

	-- Barra de titulo (usada para arrastar)
	local titleBar = Instance.new("TextButton")
	titleBar.Name = "TitleBar"
	titleBar.BackgroundTransparency = 1
	titleBar.Text = ""
	titleBar.AutoButtonColor = false
	titleBar.Size = UDim2.new(1, 0, 0, 38)
	titleBar.ZIndex = mainFrame.ZIndex + 1
	titleBar.Parent = mainFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Main"
	titleLabel.TextColor3 = Theme.text
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextScaled = true
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.AnchorPoint = Vector2.new(0, 0.5)
	titleLabel.Position = UDim2.new(0, 14, 0.5, 0)
	titleLabel.Size = UDim2.fromOffset(120, 20)
	titleLabel.ZIndex = titleBar.ZIndex + 1
	titleLabel.Parent = mainFrame

	-- Botao fechar (X)
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Theme.text
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextScaled = true
	closeBtn.TextSize = 16
	closeBtn.BackgroundColor3 = Theme.surfaceAlt
	closeBtn.BackgroundTransparency = 1
	closeBtn.AutoButtonColor = false
	closeBtn.Size = UDim2.fromOffset(32, 32)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -10, 0.5, 0)
	closeBtn.ZIndex = titleBar.ZIndex + 1
	applyCorner(closeBtn, 10)
	closeBtn.Parent = mainFrame

	closeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			closeBtn.BackgroundColor3 = Theme.danger
		end
	end)
	closeBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			closeBtn.BackgroundTransparency = 1
		end
	end)
	closeBtn.MouseButton1Click:Connect(function()
		toggleMain(false)
	end)

	-------------------------------------------------------------
	-- 3. BARRA LATERAL DE ABAS (MAIN | PULO | VELOCIDADE)
	-------------------------------------------------------------
	local sidebar = Instance.new("Frame")
	sidebar.BackgroundColor3 = Theme.background
	sidebar.BorderSizePixel = 0
	sidebar.Position = UDim2.new(0, 10, 0, 48)
	sidebar.Size = UDim2.fromOffset(92, windowH - 62)
	sidebar.ZIndex = mainFrame.ZIndex + 1
	applyCorner(sidebar, 12)
	sidebar.Parent = mainFrame

	local sideLayout = Instance.new("UIListLayout")
	sideLayout.Padding = UDim.new(0, 8)
	sideLayout.FillDirection = Enum.FillDirection.Vertical
	sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	sideLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	sideLayout.SortOrder = Enum.SortOrder.LayoutOrder
	sideLayout.Parent = sidebar

	local sidePadding = Instance.new("UIPadding")
	sidePadding.PaddingTop = UDim.new(0, 10)
	sidePadding.PaddingBottom = UDim.new(0, 8)
	sidePadding.Parent = sidebar

	-- Painel interno (onde o conteudo de cada aba aparece)
	local contentBox = Instance.new("Frame")
	contentBox.BackgroundColor3 = Theme.background
	contentBox.BorderSizePixel = 0
	contentBox.Position = UDim2.new(0, 110, 0, 48)
	contentBox.Size = UDim2.fromOffset(windowW - 120, windowH - 62)
	contentBox.ZIndex = mainFrame.ZIndex + 1
	applyCorner(contentBox, 12)
	contentBox.Parent = mainFrame

	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = Theme.surfaceAlt
	scroll.Position = UDim2.new(0, 0, 0, 0)
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.ZIndex = contentBox.ZIndex + 1
	scroll.Parent = contentBox

	local panelContainer = Instance.new("Frame")
	panelContainer.BackgroundTransparency = 1
	panelContainer.BorderSizePixel = 0
	panelContainer.Size = UDim2.new(1, 0, 0, 0)
	panelContainer.AutomaticSize = Enum.AutomaticSize.Y
	panelContainer.Parent = scroll

	-- Cria um painel vazio para cada aba
	local panels = {}
	local function makePanel()
		local panel = Instance.new("Frame")
		panel.BackgroundTransparency = 1
		panel.BorderSizePixel = 0
		panel.Size = UDim2.new(1, 0, 0, 0)
		panel.AutomaticSize = Enum.AutomaticSize.Y
		panel.Visible = false
		panel.Parent = panelContainer

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 9)
		list.FillDirection = Enum.FillDirection.Vertical
		list.HorizontalAlignment = Enum.HorizontalAlignment.Center
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = panel

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 8)
		pad.Parent = panel

		-- Mantem a rolagem do tamanho certo conforme o painel cresce
		panel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if panel.Visible and panel.AbsoluteSize.Y > 0 then
				scroll.CanvasSize = UDim2.fromOffset(0, panel.AbsoluteSize.Y + 12)
			end
		end)

		return panel
	end

	local function switchPanel(panel)
		for _, p in pairs(panels) do
			p.Visible = (p == panel)
		end
		panel.Position = UDim2.fromOffset(-8, 0)
		local tw = TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.fromOffset(0, 0) })
		tw:Play()
		if panel.AbsoluteSize.Y > 0 then
			scroll.CanvasSize = UDim2.fromOffset(0, panel.AbsoluteSize.Y + 12)
		end
	end

	-- Cria o botao de uma aba
	local function addTabButton(name, order)
		local btn = Instance.new("TextButton")
		btn.Text = name
		btn.TextColor3 = Theme.textMuted
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.TextSize = 14
		btn.BackgroundColor3 = Theme.surfaceAlt
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0
		btn.Size = UDim2.fromOffset(76, 44)
		btn.LayoutOrder = order
		applyCorner(btn, 12)
		btn.Parent = sidebar
		return btn
	end

	-------------------------------------------------------------
	-- 4. HELPERS DE CONTROLES (slider, toggle e botao de acao)
	-------------------------------------------------------------

	local function addSectionTitle(parent, text, order)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = Theme.accent
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Size = UDim2.new(1, 0, 0, 22)
		label.LayoutOrder = order or 0
		label.Parent = parent
		return label
	end

	-- Slider (funciona com mouse E toque)
	local function addSlider(parent, title, minValue, maxValue, decimals, suffix, initial, onChange, order)
		local row = Instance.new("Frame")
		row.BackgroundColor3 = Theme.surfaceAlt
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 78)
		row.LayoutOrder = order
		applyCorner(row, 12)
		row.Parent = parent

		local titleLabel = Instance.new("TextLabel")
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = Theme.text
		titleLabel.Font = Enum.Font.GothamSemibold
		titleLabel.TextScaled = true
		titleLabel.TextSize = 14
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Position = UDim2.new(0, 12, 0, 8)
		titleLabel.Size = UDim2.new(0.7, -20, 0, 18)
		titleLabel.Parent = row

		local valueLabel = Instance.new("TextLabel")
		valueLabel.BackgroundTransparency = 1
		valueLabel.TextColor3 = Theme.accent
		valueLabel.Font = Enum.Font.GothamBold
		valueLabel.TextScaled = true
		valueLabel.TextSize = 14
		valueLabel.TextXAlignment = Enum.TextXAlignment.Right
		valueLabel.AnchorPoint = Vector2.new(1, 0)
		valueLabel.Position = UDim2.new(1, -12, 0, 8)
		valueLabel.Size = UDim2.fromOffset(90, 18)
		valueLabel.Parent = row

		local rail = Instance.new("Frame")
		rail.BackgroundColor3 = Theme.background
		rail.BorderSizePixel = 0
		rail.Position = UDim2.new(0, 12, 0, 46)
		rail.Size = UDim2.new(1, -24, 0, 8)
		applyCorner(rail, 4)
		rail.Parent = row

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = Theme.accent
		fill.BorderSizePixel = 0
		fill.Size = UDim2.new(0, 0, 1, 0)
		applyCorner(fill, 4)
		fill.Parent = rail

		local thumb = Instance.new("TextButton")
		thumb.BackgroundColor3 = Theme.white
		thumb.Text = ""
		thumb.AutoButtonColor = false
		thumb.BorderSizePixel = 0
		thumb.Size = UDim2.fromOffset(20, 20)
		thumb.AnchorPoint = Vector2.new(0.5, 0.5)
		applyCorner(thumb, 10)
		thumb.Parent = rail

		local dragging = false

		local function update(frac, silent)
			frac = math.clamp(frac, 0, 1)
			local value = minValue + frac * (maxValue - minValue)
			local step = 10 ^ decimals
			value = math.round(value * step) / step
			valueLabel.Text = tostring(value) .. " " .. (suffix or "")
			fill.Size = UDim2.fromScale(frac, 1)
			thumb.Position = UDim2.fromScale(frac, 0.5)
			if not silent then
				onChange(value)
			end
		end

		local function setByValue(value)
			local frac = (value - minValue) / (maxValue - minValue)
			update(frac, true)
		end

		local startFrac = (initial - minValue) / (maxValue - minValue)
		update(startFrac)

		local function dragTo(inputPos)
			local rel = (inputPos.X - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1)
			update(rel)
		end

		local function beginDrag(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				tweenSize(thumb, 1, 1.25, 0.1)
				dragTo(input.Position)
			end
		end

		local function endDrag(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				tweenSize(thumb, 1, 1, 0.12, Enum.EasingStyle.Back)
			end
		end

		thumb.InputBegan:Connect(beginDrag)
		rail.InputBegan:Connect(beginDrag)
		thumb.InputEnded:Connect(endDrag)
		rail.InputEnded:Connect(endDrag)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				dragTo(input.Position)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if dragging then
				endDrag(input)
			end
		end)

		return {
			setByValue = setByValue,
		}
	end

	-- Toggle (liga/desliga)
	local function addToggle(parent, title, subtitle, order, onToggle, initialState)
		local row = Instance.new("Frame")
		row.BackgroundColor3 = Theme.surfaceAlt
		row.BorderSizePixel = 0
		row.Size = UDim2.new(1, 0, 0, 64)
		row.LayoutOrder = order
		applyCorner(row, 12)
		row.Parent = parent

		local titleLabel = Instance.new("TextLabel")
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = title
		titleLabel.TextColor3 = Theme.text
		titleLabel.Font = Enum.Font.GothamSemibold
		titleLabel.TextScaled = true
		titleLabel.TextSize = 15
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.AnchorPoint = Vector2.new(0, 0.5)
		titleLabel.Position = UDim2.new(0, 12, 0.5, -8)
		titleLabel.Size = UDim2.new(0.6, 0, 0, 18)
		titleLabel.Parent = row

		local subLabel = Instance.new("TextLabel")
		subLabel.BackgroundTransparency = 1
		subLabel.Text = subtitle or ""
		subLabel.TextColor3 = Theme.textMuted
		subLabel.Font = Enum.Font.Gotham
		subLabel.TextScaled = true
		subLabel.TextSize = 12
		subLabel.TextXAlignment = Enum.TextXAlignment.Left
		subLabel.Position = UDim2.new(0, 12, 0, 36)
		subLabel.Size = UDim2.new(0.6, 0, 0, 16)
		subLabel.Parent = row

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Text = "OFF"
		toggleBtn.TextColor3 = Theme.textMuted
		toggleBtn.Font = Enum.Font.GothamBold
		toggleBtn.TextScaled = true
		toggleBtn.TextSize = 14
		toggleBtn.BackgroundColor3 = Theme.background
		toggleBtn.AutoButtonColor = false
		toggleBtn.BorderSizePixel = 0
		toggleBtn.Size = UDim2.fromOffset(86, 32)
		toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
		toggleBtn.Position = UDim2.new(1, -12, 0.5, 0)
		applyCorner(toggleBtn, 10)
		toggleBtn.Parent = row

		local state = initialState or false

		local function refreshStyle()
			if state then
				toggleBtn.Text = "ON"
				toggleBtn.TextColor3 = Theme.white
				local tw = TweenService:Create(toggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.success })
				tw:Play()
			else
				toggleBtn.Text = "OFF"
				toggleBtn.TextColor3 = Theme.textMuted
				local tw = TweenService:Create(toggleBtn, TweenInfo.new(0.2), { BackgroundColor3 = Theme.background })
				tw:Play()
			end
		end

		toggleBtn.MouseButton1Click:Connect(function()
			state = not state
			refreshStyle()
			onToggle(state)
		end)

		refreshStyle()

		return {
			setState = function(v) state = v; refreshStyle() end,
			getState = function() return state end,
		}
	end

	-- Botao de acao simples (ex.: restaurar padroes)
	local function addActionButton(parent, text, order, onClick)
		local btn = Instance.new("TextButton")
		btn.Text = text
		btn.TextColor3 = Theme.text
		btn.Font = Enum.Font.GothamSemibold
		btn.TextScaled = true
		btn.TextSize = 15
		btn.BackgroundColor3 = Theme.surfaceAlt
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0
		btn.Size = UDim2.new(1, 0, 0, 46)
		btn.LayoutOrder = order
		applyCorner(btn, 12)
		btn.Parent = parent
		btn.MouseButton1Click:Connect(onClick)
		return btn
	end

	-------------------------------------------------------------
	-- 5. CONTEUDO DE CADA ABA
	-------------------------------------------------------------
	local mainPanel = makePanel()
	local jumpPanel = makePanel()
	local speedPanel = makePanel()
	local playerPanel = makePanel()
	panels.main = mainPanel
	panels.jump = jumpPanel
	panels.speed = speedPanel
	panels.player = playerPanel

	-- === ABA MAIN ===
	addSectionTitle(mainPanel, "GERAL", 1)

	-- FOV
	fovSlider = addSlider(mainPanel, "Campo de visao (FOV)", 50, 120, 0, "fov", settings.fovValue, function(value)
		settings.fovValue = value
		local cam = workspace.CurrentCamera
		if cam then
			cam.FieldOfView = value
		end
	end, 2)

	-- Botao restaurar padroes
	addActionButton(mainPanel, "Restaurar padroes", 3, function()
		settings.wsEnabled = false
		settings.wsValue = DEFAULT_WALKSPEED
		settings.jpEnabled = false
		settings.jpValue = DEFAULT_JUMPPOWER
		settings.infiniteJump = false
		settings.fovValue = 70

		wsToggle.setState(false)
		jpToggle.setState(false)
		infToggle.setState(false)

		wsSlider.setByValue(DEFAULT_WALKSPEED)
		jpSlider.setByValue(DEFAULT_JUMPPOWER)
		fovSlider.setByValue(70)

		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = DEFAULT_WALKSPEED
			humanoid.JumpPower = DEFAULT_JUMPPOWER
		end
		local cam = workspace.CurrentCamera
		if cam then
			cam.FieldOfView = 70
		end
	end)

	-- === ABA PULO ===
	addSectionTitle(jumpPanel, "PULO", 1)

	jpToggle = addToggle(jumpPanel, "Pulo personalizado", "Liga o controle deslizante de JumpPower", 2, function(on)
		settings.jpEnabled = on
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if on then
			if humanoid then humanoid.JumpPower = settings.jpValue end
		else
			if humanoid then humanoid.JumpPower = DEFAULT_JUMPPOWER end
		end
	end)

	jpSlider = addSlider(jumpPanel, "Forca do Pulo (JumpPower)", 5, 200, 0, "jp", settings.jpValue, function(value)
		settings.jpValue = value
		if settings.jpEnabled then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.JumpPower = value end
		end
	end, 3)

	infToggle = addToggle(jumpPanel, "Pulo infinito", "Salte repetidamente no ar", 4, function(on)
		settings.infiniteJump = on
	end)

	-- === ABA VELOCIDADE ===
	addSectionTitle(speedPanel, "VELOCIDADE", 1)

	wsToggle = addToggle(speedPanel, "Velocidade personalizada", "Liga o controle deslizante de WalkSpeed", 2, function(on)
		settings.wsEnabled = on
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if on then
			if humanoid then humanoid.WalkSpeed = settings.wsValue end
		else
			if humanoid then humanoid.WalkSpeed = DEFAULT_WALKSPEED end
		end
	end)

	wsSlider = addSlider(speedPanel, "Velocidade (WalkSpeed)", 1, 100, 0, "ws", settings.wsValue, function(value)
		settings.wsValue = value
		if settings.wsEnabled then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = value end
		end
	end, 3)

	-- === ABA JOGADOR ===
	addSectionTitle(playerPanel, "JOGADOR", 1)

	-- ESP
	espToggle = addToggle(playerPanel, "ESP", "Destaca outros jogadores no mapa", 2, function(on)
		settings.espEnabled = on
		refreshESP()
	end)
	addToggle(playerPanel, "ESP por cor da equipe", "Usa a cor da equipe (ou vermelho)", 3, function(on)
		settings.espTeamColor = on
		refreshESP()
	end)

	-- Aimbot
	aimToggle = addToggle(playerPanel, "Aimbot", "Aponta a cam para o inimigo mais proximo", 4, function(on)
		settings.aimbotEnabled = on
	end)
	aimFOVSlider = addSlider(playerPanel, "FOV do Aimbot (graus)", 30, 360, 0, "graus", settings.aimFOV, function(value)
		settings.aimFOV = value
	end, 5)
	aimSmoothSlider = addSlider(playerPanel, "Suavidade (quanto menor, mais rapido)", 1, 30, 1, "", settings.aimSmooth, function(value)
		settings.aimSmooth = math.round(value)
	end, 6)

	-- Fly
	flyToggle = addToggle(playerPanel, "Fly", "Voe mantendo a tecla Espaco", 7, function(on)
		settings.flyEnabled = on
		toggleFly(on)
	end)
	flySpeedSlider = addSlider(playerPanel, "Velocidade do Fly", 10, 200, 0, "studs/s", settings.flySpeed, function(value)
		settings.flySpeed = value
		if flyBody then flyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9) end
	end, 8)

	-- Noclip
	noclipToggle = addToggle(playerPanel, "Noclip", "Atravessa paredes", 9, function(on)
		settings.noclipEnabled = on
	end)

	-------------------------------------------------------------
	-- 6. MONTAGEM DAS ABAS + ESTILO DE BOTAO ATIVO
	-------------------------------------------------------------
	local tabButtons = {}

	local function styleTab(btn, active)
		if active then
			TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundColor3 = Theme.accent }):Play()
			TweenService:Create(btn, TweenInfo.new(0.18), { TextColor3 = Theme.white }):Play()
		else
			TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundColor3 = Theme.surfaceAlt }):Play()
			TweenService:Create(btn, TweenInfo.new(0.18), { TextColor3 = Theme.textMuted }):Play()
		end
	end

	local function addTab(name, order, panel)
		local btn = addTabButton(name, order)
		btn.MouseButton1Click:Connect(function()
			switchPanel(panel)
			for _, other in pairs(tabButtons) do
				styleTab(other, false)
			end
			styleTab(btn, true)
		end)
		tabButtons[name] = btn
		return btn
	end

	addTab("Main", 1, mainPanel)
	addTab("Pulo", 2, jumpPanel)
	addTab("Velocidade", 3, speedPanel)
	addTab("Jogador", 4, playerPanel)

	-- Abre na aba Main
	switchPanel(mainPanel)
	styleTab(tabButtons.Main, true)

	-------------------------------------------------------------
	-- 7. PULO INFINITO (responde ao botao de pular do jogador)
	-------------------------------------------------------------
	UserInputService.JumpRequest:Connect(function()
		if not settings.infiniteJump then return end
		local humane = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if not humane then return end
		local st = humane:GetState()
		if st == Enum.HumanoidStateType.Jumping or st == Enum.HumanoidStateType.Freefall then
			return
		end
		humane:ChangeState(Enum.HumanoidStateType.Jumping)
	end)

	-------------------------------------------------------------
	-- 8. ABRIR / FECHAR COM ANIMACAO
	-------------------------------------------------------------
	local mainOpen = false

	local function animateMain(open)
		local popInfo = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		local shrinkInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		if open then
			mainFrame.Visible = true
			mainFrame.Position = UDim2.new(0.5, 0, 0.5, 30)
			mainFrame.Size = UDim2.new(0, windowW * 0.9, 0, windowH * 0.9)
			TweenService:Create(mainFrame, popInfo, { Size = windowSize, Position = windowCenter }):Play()
		else
			local twSize = TweenService:Create(mainFrame, shrinkInfo, { Size = UDim2.new(0, windowW * 0.9, 0, windowH * 0.9) })
			local twPos = TweenService:Create(mainFrame, shrinkInfo, { Position = UDim2.new(0.5, 0, 0.5, 30) })
			twSize:Play()
			twPos:Play()
			twSize.Completed:Connect(function()
				if not mainOpen then
					mainFrame.Visible = false
				end
			end)
		end
	end

	local function toggleMain(open)
		if mainOpen == open then return end
		mainOpen = open
		animateMain(open)
	end

	floatingBtn.MouseButton1Click:Connect(function()
		toggleMain(not mainOpen)
	end)

	-------------------------------------------------------------
	-- 9. ARRASTAR A JANELA
	-------------------------------------------------------------
	local dragActive = false
	local dragStartPoint = nil
	local dragStartPos = nil

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragActive = true
			dragStartPoint = input.Position
			dragStartPos = mainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragActive then return end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
			local delta = input.Position - dragStartPoint
			mainFrame.Position = UDim2.new(
				dragStartPos.X.Scale,
				dragStartPos.X.Offset + delta.X,
				dragStartPos.Y.Scale,
				dragStartPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if dragActive and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragActive = false
		end
	end)
end

---------------------------------------------------------------------------
-- LOGICA: ESP / AIMBOT / FLY / NOCLIP
---Digital (funcoes globais chamadas pelos callbacks da GUI)
---------------------------------------------------------------------------

-- Ajuda: retorna a lista de personagens-alvo (outros jogadores + inimigos)
local function getTargets()
	local targets = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character.PrimaryPart then
			table.insert(targets, p.Character)
		end
	end
	-- Inimigos do workspace (cavalos, etc.)
	for _, folderName in pairs(ESP_TARGETS.Workspace) do
		local folder = workspace:FindFirstChild(folderName)
		if folder then
			for _, child in ipairs(folder:GetChildren()) do
				if child:IsA("Model") and child.PrimaryPart then
					table.insert(targets, child)
				end
			end
		end
	end
	return targets
end

-- ESP: cria/destroi Highlights nos alvos
espHighlights = {}

function refreshESP()
	for _, hl in pairs(espHighlights) do
		if hl and hl.Parent then
			hl:Destroy()
		end
	end
	espHighlights = {}

	if not settings.espEnabled then
		return
	end

	for _, char in ipairs(getTargets()) do
		local existing = char:FindFirstChildOfClass("Highlight")
		if not existing then
			local hl = Instance.new("Highlight")
			hl.Name = "ESP_Highlight"
			local team = (not settings.espTeamColor) and player.Team
			hl.FillColor = (team and team.TeamColor.Color) or Color3.fromRGB(235, 70, 70)
			hl.OutlineColor = Color3.new(0, 0, 0)
			hl.FillTransparency = 0.4
			hl.OutlineTransparency = 0.3
			hl.Parent = char
			espHighlights[char] = hl
		end
	end
end

-- Mantem o ESP atualizado quando novos personagens aparecem
Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		if settings.espEnabled then
			refreshESP()
		end
	end)
end)

-- FLY: usa um BodyVelocity para voar enquanto segura Espaco
flyBody = nil

function refreshFlyBody(root)
	if flyBody and flyBody.Parent == root then
		return
	end
	if flyBody then
		flyBody:Destroy()
	end
	flyBody = Instance.new("BodyVelocity")
	flyBody.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBody.Velocity = Vector3.zero
	flyBody.Parent = root
end

function toggleFly(on)
	local char = player.Character
	if on then
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root then
			refreshFlyBody(root)
		end
	else
		if flyBody then
			flyBody:Destroy()
			flyBody = nil
		end
	end
end

-- NOCLIP: desliga a colisao do personagem periodicamente
local function noclipping(character)
	character = character or player.Character
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

-- LOOP PRINCIPAL (heartbeat): Fly, Noclip e Aimbot
local RunService = game:GetService("RunService")

RunService.Heartbeat:Connect(function()
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart")

	-- FLY: mantem o corpo flutuando enquanto segura Espaco (e desce com Shift)
	if settings.flyEnabled and root and humanoid then
		refreshFlyBody(root)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Falling, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

		local up = 0
		local forward = 0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up = 1 end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then up = -1 end
		local cam = workspace.CurrentCamera
		local camDir = cam and cam.CFrame:VectorToWorldSpace(Vector3.new(0, 0, -1)) or root.CFrame.LookVector
		local forward2d = Vector3.new(camDir.X, 0, camDir.Z).Unit * settings.flySpeed

		local moveDir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + forward2d end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - forward2d end

		local horiz = root.CFrame.RightVector
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - horiz * settings.flySpeed end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + horiz * settings.flySpeed end

		flyBody.Velocity = (moveDir * settings.flySpeed) + Vector3.new(0, up * settings.flySpeed, 0)
	elseif flyBody and flyBody.Parent and flyBody.Parent.Parent == char then
		flyBody:Destroy()
		flyBody = nil
		if humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Falling, true)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end

	-- NOCLIP
	if settings.noclipEnabled and char and humanoid then
		noclipping(char)
	end
end)

-- NOCLIP: continuar apos respawn
player.CharacterAdded:Connect(function(char)
	if settings.noclipEnabled then
		noclipping(char)
	end
end)

-- FLY: recria o BodyVelocity apos respawn
player.CharacterAdded:Connect(function(char)
	if settings.flyEnabled then
		local root = char:WaitForChild("HumanoidRootPart", 5)
		if root then
			refreshFlyBody(root)
		end
	end
end)

-- AIMBOT: gira a cam para o alvo mais proximo dentro do FOV
RunService.RenderStepped:Connect(function()
	if not settings.aimbotEnabled then return end
	local cam = workspace.CurrentCamera
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not (cam and root) then return end

	local camPos = cam.CFrame.Position
	local best = nil
	local bestDist = settings.aimFOV

	for _, target in ipairs(getTargets()) do
		local head = target:FindFirstChild("Head") or target.PrimaryPart
		if head then
			local hp = head.Position
			local dir = (hp - camPos).Unit
			local dot = cam.CFrame.LookVector:Dot(dir)
			local angle = math.deg(math.acos(math.clamp(dot, -1, 1)))
			if angle <= bestDist then
				local dist = (hp - camPos).Magnitude
				if not best or dist < best then
					best = hp
					bestDist = angle
				end
			end
		end
	end

	if best then
		local cframe = CFrame.lookAt(camPos, best)
		local current = cam.CFrame
		local smooth = math.max(settings.aimSmooth, 1)
		local alpha = 1 / (smooth + 1)
		local interp = current:Lerp(cframe, alpha)
		cam.CFrame = interp
	end
end)

-- Recompor o ESP/estado apos respawn (ensures settings persistem)
player.CharacterAdded:Connect(function()
	if settings.espEnabled then
		refreshESP()
	end
end)

-- Executa a construcao capturando qualquer erro (aparece no Output)
local okCreate, createErr = pcall(createUI)
if okCreate then
	print("MainUI: hub com abas criado com sucesso!")
else
	warn("MainUI ERRO: " .. tostring(createErr))
end