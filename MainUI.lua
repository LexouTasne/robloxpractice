--[[==========================================================================
	MainUI — Interface moderna e responsiva (LocalScript)

	Criado 100% por código: não é preciso criar nenhum Frame/Button na base.
	O script cria um botão flutuante e uma janela principal chamada "Main".

	Onde colocar:
		StarterPlayer (Explorer) -> StarterPlayerScripts -> LocalScript
		(cole este código inteiro dentro desse LocalScript)

	Por que StarterPlayerScripts?
		- Scripts aqui rodam UMA vez por jogador (não repetem no respawn),
		  então a GUI não duplica quando o personagem morre/renasce.
		- A ScreenGui fica em PlayerGui e some apenas se o jogador sair.
============================================================================--]]

-- Serviços //
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

----------------------------------------------------------------------------
-- 0. Guarda anti-duplicação
----------------------------------------------------------------------------
local GUI_NAME = "MainSettingsUI"

-- Se algum caso estranho rodar o script de novo, apaga a GUI antiga
-- e recria uma nova, garantindo que só exista UMA interface.
local old = PlayerGui:FindFirstChild(GUI_NAME)
if old then
	old:Destroy()
end

----------------------------------------------------------------------------
-- Tema escuro (cores centralizadas para facilitar modificações)
----------------------------------------------------------------------------
local Theme = {
	background = Color3.fromRGB(13, 15, 23),   -- fundo da tela (notches)
	surface    = Color3.fromRGB(26, 29, 40),   -- fundo dos painéis
	surfaceAlt = Color3.fromRGB(37, 41, 56),   -- fundo dos itens/cards
	accent     = Color3.fromRGB(99, 130, 246), -- azul moderno
	success    = Color3.fromRGB(72, 199, 142), -- verde (ligado)
	danger     = Color3.fromRGB(235, 87, 87),  -- vermelho (fechar)
	text       = Color3.fromRGB(240, 240, 248),
	textMuted  = Color3.fromRGB(150, 155, 175),
	white      = Color3.fromRGB(255, 255, 255),
}

local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

----------------------------------------------------------------------------
-- Estado das configurações (persiste enquanto o jogo estiver aberto)
----------------------------------------------------------------------------
local settings = {
	wsEnabled = false,  -- WalkSpeed personalizada ligada?
	wsValue   = DEFAULT_WALKSPEED,
	jpEnabled = false,  -- JumpPower personalizado ligado?
	jpValue   = DEFAULT_JUMPPOWER,
	fovValue  = 70,
	infiniteJump = false,
}

----------------------------------------------------------------------------
-- Aplica as configurações em um personagem (usa no início e no respawn)
----------------------------------------------------------------------------
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

-- Reaplica quando o personagem morre e renasce
player.CharacterAdded:Connect(applySettings)

-- Aplica assim que o personagem existir
if player.Character then
	applySettings(player.Character)
end

----------------------------------------------------------------------------
-- Cria a ScreenGui (não some no respawn por causa do ResetOnSpawn=false)
----------------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 100
gui.Parent = PlayerGui

-- Tamanho do viewport (funciona para PC, celular e tablet)
-- Espera a câmera existir (evita travamentos no spawn inicial)
local camera = workspace.CurrentCamera
while not camera do
	task.wait()
	camera = workspace.CurrentCamera
end
local viewport = camera.ViewportSize
local windowW = math.clamp(viewport.X * 0.94, 320, 420)
local windowH = math.clamp(viewport.Y * 0.82, 430, 540)

-- Guarda dimensões reais para poder animar a janela sem quebrar o layout
local windowSize = UDim2.fromOffset(windowW, windowH)

--------------------------------------------------------------
-- Helpers visuais
--------------------------------------------------------------
local function applyCorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = obj
end

-- Anima "Size" de um elemento com easing suave
local function tweenSize(obj, fromScale, toScale, time, easingStyle)
	local base = obj._baseSize or obj.Size
	obj._baseSize = base
	local from = UDim2.new(base.X.Scale, base.X.Offset * fromScale, base.Y.Scale, base.Y.Offset * fromScale)
	local to   = UDim2.new(base.X.Scale, base.X.Offset * toScale,   base.Y.Scale, base.Y.Offset * toScale)
	obj.Size = from
	local tw = TweenService:Create(obj, TweenInfo.new(time or 0.15, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = to })
	tw:Play()
end

--------------------------------------------------------------
-- 1. BOTÃO FLUTUANTE (abre/fecha a Main)
--------------------------------------------------------------
local floatingBtn = Instance.new("TextButton")
floatingBtn.Name = "FloatingButton"
floatingBtn.BackgroundColor3 = Theme.surfaceAlt
floatingBtn.BorderSizePixel = 0
floatingBtn.AutoButtonColor = false
floatingBtn.Text = ""
floatingBtn.Size = UDim2.fromOffset(56, 56)
floatingBtn.AnchorPoint = Vector2.new(1, 1)
local marginBottom = UserInputService.TouchEnabled and 40 or 24 -- folga p/ mobile
floatingBtn.Position = UDim2.new(1, -20, 1, -marginBottom)
floatingBtn.ZIndex = 20
applyCorner(floatingBtn, 28) -- totalmente redondo
floatingBtn.Parent = gui

-- Ícone "hambúrguer" desenhado com 3 barras (funciona em qualquer fonte/plataforma)
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

-- Hover (PC): cresce um pouco
floatingBtn.MouseEnter:Connect(function()
	tweenSize(floatingBtn, 1, 1.12, 0.12, Enum.EasingStyle.Back)
end)
floatingBtn.MouseLeave:Connect(function()
	tweenSize(floatingBtn, 1, 1, 0.12)
end)

-- Toque/clique: encolhe ao pressionar e volta ao soltar (efeito "squash")
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

--------------------------------------------------------------
-- 2. JANELA PRINCIPAL "Main"
--------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.BackgroundColor3 = Theme.surface
mainFrame.BorderSizePixel = 0
mainFrame.Size = windowSize
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.Visible = false
mainFrame.ZIndex = 30
applyCorner(mainFrame, 14)
mainFrame.Parent = gui

-- Barra de título (também usada para arrastar a janela no PC)
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

-- Botão fechar (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Text = "✕"
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

-- Área rolável para os controles
local scroll = Instance.new("ScrollingFrame")
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Theme.surfaceAlt
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.fromScale(0, 0)
scroll.Position = UDim2.new(0, 10, 0, 44)
scroll.Size = UDim2.new(1, -20, 1, -54)
scroll.ZIndex = mainFrame.ZIndex + 1
scroll.Parent = mainFrame

-- Conteúdo + layout automático (responsivo)
local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.Size = UDim2.new(1, 0, 0, 0)
content.AutomaticSize = Enum.AutomaticSize.Y
content.ZIndex = scroll.ZIndex + 1
content.Parent = scroll

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local padding = Instance.new("UIPadding")
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingTop = UDim.new(0, 8)
padding.Parent = content

--------------------------------------------------------------
-- Helpers de controles (slider e toggle)
--------------------------------------------------------------

-- Título de seção ("MOVIMENTO", "EXTRAS")
local function addSectionTitle(parent, text)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.accent
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Size = UDim2.new(1, 0, 0, 22)
	label.LayoutOrder = 0
	label.Parent = parent
	return label
end

-- Slider personalizado (funciona com mouse E toque)
-- onChange(value) é chamado sempre que o valor mudar.
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

	-- posição da "bolinha" conforme o valor atual
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

	-- move o slider com o mouse / dedo mesmo fora dos objetos
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

	return { row = row, valueLabel = valueLabel, setValue = update }
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

	return { row = row, toggleBtn = toggleBtn, setState = function(v) state = v; refreshStyle() end, getState = function() return state end }
end

--------------------------------------------------------------
-- 3. CONSTRÓI OS CONTROLES DENTRO DA MAIN
--------------------------------------------------------------
local function buildControls()
	addSectionTitle(content, "MOVIMENTO").LayoutOrder = 1

	-- Toggle Velocidade (WalkSpeed)
	addToggle(content, "Velocidade personalizada", "Liga o controle deslizante de WalkSpeed", 2, function(on)
		settings.wsEnabled = on
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if on then
			if humanoid then humanoid.WalkSpeed = settings.wsValue end
		else
			if humanoid then humanoid.WalkSpeed = DEFAULT_WALKSPEED end
		end
	end)

	-- Slider Velocidade
	local wsFrac = addSlider(content, "Velocidade (WalkSpeed)", 1, 100, 0, "ws", settings.wsValue, function(value)
		settings.wsValue = value
		if settings.wsEnabled then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.WalkSpeed = value end
		end
	end, 3)

	-- Toggle Pulo (JumpPower)
	addToggle(content, "Pulo personalizado", "Liga o controle deslizante de JumpPower", 4, function(on)
		settings.jpEnabled = on
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if on then
			if humanoid then humanoid.JumpPower = settings.jpValue end
		else
			if humanoid then humanoid.JumpPower = DEFAULT_JUMPPOWER end
		end
	end)

	-- Slider Pulo
	local jpFrac = addSlider(content, "Força do Pulo (JumpPower)", 5, 200, 0, "jp", settings.jpValue, function(value)
		settings.jpValue = value
		if settings.jpEnabled then
			local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid.JumpPower = value end
		end
	end, 5)

	addSectionTitle(content, "EXTRAS").LayoutOrder = 6

	-- Slider FOV (campo de visão da câmera)
	addSlider(content, "Campo de visão (FOV)", 50, 120, 0, "fov", settings.fovValue, function(value)
		settings.fovValue = value
		local cam = workspace.CurrentCamera
		if cam then
			cam.FieldOfView = value
		end
	end, 7)

	-- Pulo infinito (aplica no botão do jogador)
	addToggle(content, "Pulo infinito", "Salte repetidamente no ar", 8, function(on)
		settings.infiniteJump = on
	end)
end
buildControls()

-- Mantém o Slider sincronizado caso o valor mude por fora
-- (ex.: valor padrão após matar/respawn) — atualiza os textos
local function syncSliders()
	wsFrac.setValue((settings.wsValue - 1) / 99)
	jpFrac.setValue((settings.jpValue - 5) / 195)
end
RunService.RenderStepped:Connect(function()
	syncSliders()
end)

--------------------------------------------------------------
-- 4. ABRIR / FECHAR COM ANIMAÇÃO
--------------------------------------------------------------
local mainOpen = false

local function animateMain(open)
	mainFrame.Visible = true
	local goalSize = windowSize
	local startSize = UDim2.new(0, windowW * 0.92, 0, windowH * 0.92)
	local fadeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local popInfo = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	if open then
		mainFrame.Size = startSize
		mainFrame.GroupTransparency = 1
		TweenService:Create(mainFrame, fadeInfo, { GroupTransparency = 0 }):Play()
		TweenService:Create(mainFrame, popInfo, { Size = goalSize }):Play()
	else
		TweenService:Create(mainFrame, fadeInfo, { GroupTransparency = 1 }):Play()
		local tw = TweenService:Create(mainFrame, popInfo, { Size = startSize })
		tw:Play()
		tw.Completed:Connect(function()
			if not mainOpen then
				mainFrame.Visible = false
			end
		end)
	end
end

function toggleMain(open)
	if mainOpen == open then return end
	mainOpen = open
	animateMain(open)
end

-- Botão flutuante abre/fecha a Main
floatingBtn.MouseButton1Click:Connect(function()
	toggleMain(not mainOpen)
end)

--------------------------------------------------------------
-- 5. ARRASTAR A JANELA (PC: mouse — funciona bem no mobile também)
--------------------------------------------------------------
local dragging = false
local dragStartPoint = nil
local dragStartPos = nil

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStartPoint = input.Position
		dragStartPos = mainFrame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then return end
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
	if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		dragging = false
	end
end)

print("MainUI: interface criada com sucesso!")