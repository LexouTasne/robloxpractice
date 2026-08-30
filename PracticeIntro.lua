P,T,A,X=game:GetService("Players"),game:GetService("TweenService"),game:GetService("AssetService"),game:GetService("TextService")
local pg=P.LocalPlayer:WaitForChild("PlayerGui")local o=pg:FindFirstChild("PracticeIntro")if o then o:Destroy()end

-- CONFIG
local SPEED,GEAR=5,2.5
local WW,WH,MW,MH=420,150,560,340
local HW,HH,CY=320,88,44
local FONT,FS=Enum.Font.GothamBlack,44
local PW,PH,PS=45,35,40
local GP,GPS,RPAD=4,1,2
local PXO,PYO,TXO,TYO,LXO,LYO=0,0,0,0,0,0
local ROT,OPEN,HOLD=-2,.40,.52
local TDELAY=.12
local WIPE,WA=62,-5
local LOAD,TURNS=.6,2
local BLEN,BTH,BPX,BPY=30,4.5,10,8
local SHW,SHA=36,.9
local BG,BD,W=Color3.fromRGB(17,17,20),Color3.fromRGB(48,48,55),Color3.fromRGB(249,249,250)

local function D(t)return t*5/math.max(SPEED,.01)end
local function G(t)return D(t)*5/math.max(GEAR,.01)end
local function N(c,p)local x=Instance.new(c)for k,v in pairs(p)do x[k]=v end return x end
local function Q(x,t,p,s,d)local a=T:Create(x,TweenInfo.new(t,s or Enum.EasingStyle.Quint,d or Enum.EasingDirection.Out),p)a:Play()return a end
local function R(x,r)N("UICorner",{Parent=x,CornerRadius=UDim.new(0,r)})end

local function mkP()
	local w,h=128,96 local im=A:CreateEditableImage({Size=Vector2.new(w,h)})local b=buffer.create(w*h*4)
	local O={{2,2},{88,2},{98,3},{108,7},{117,11},{123,19},{126,28},{125,36},{121,43},{115,49},{108,53},{99,55},{50,55},{41,78},{19,94},{26,55},{35,21},{20,21}}
	local H={{52,22},{92,22},{98,24},{103,27},{104,32},{102,37},{98,40},{92,42},{47,42}}
	local S={{.25,.25},{.75,.25},{.25,.75},{.75,.75}}
	local function poly(x,y,p)local z=false local j=#p for i=1,#p do local a,b=p[i],p[j]if((a[2]>y)~=(b[2]>y))and x<(b[1]-a[1])*(y-a[2])/((b[2]-a[2])+.0001)+a[1]then z=not z end j=i end return z end
	for y=0,h-1 do for x=0,w-1 do
		local n=0
		for _,s in ipairs(S)do if poly(x+s[1],y+s[2],O)and not poly(x+s[1],y+s[2],H)then n=n+1 end end
		local i=(y*w+x)*4
		buffer.writeu8(b,i,249)buffer.writeu8(b,i+1,249)buffer.writeu8(b,i+2,250)buffer.writeu8(b,i+3,math.floor(n/4*255))
	end end
	im:WritePixelsBuffer(Vector2.zero,Vector2.new(w,h),b)return im
end

local function mkPlus()
	local w,h,c=96,96,48 local im=A:CreateEditableImage({Size=Vector2.new(w,h)})local b=buffer.create(w*h*4)
	local pts={{-.82,-.05,.8,Color3.fromRGB(245,55,155)},{-.55,.58,.72,Color3.fromRGB(125,60,235)},{-.3,-.74,.68,Color3.fromRGB(255,105,32)},{.14,-.8,.68,Color3.fromRGB(255,225,28)},{.68,-.34,.68,Color3.fromRGB(140,255,45)},{.82,.08,.72,Color3.fromRGB(35,235,95)},{.48,.62,.72,Color3.fromRGB(15,220,220)},{0,.82,.72,Color3.fromRGB(25,115,250)}}
	local function g(x,y,a,b,r)local dx,dy=x-a,y-b return math.exp(-((dx*dx+dy*dy)/(r*r))*2)end
	local function rb(x,y,sx,sy,r)local qx,qy=math.abs(x)-sx+r,math.abs(y)-sy+r local ox,oy=math.max(qx,0),math.max(qy,0)return math.sqrt(ox*ox+oy*oy)+math.min(math.max(qx,qy),0)-r end
	for y=0,h-1 do for x=0,w-1 do
		local dx,dy=x-c,y-c
		local al=math.clamp(-math.min(rb(dx,dy,39,13,10),rb(dx,dy,13,39,10))+1,0,1)*255
		local nx,ny=dx/39,dy/39 local r,gg,bl,t=0,0,0,0
		for _,p in ipairs(pts)do local q=g(nx,ny,p[1],p[2],p[3])r=r+p[4].R*q gg=gg+p[4].G*q bl=bl+p[4].B*q t=t+q end
		r,gg,bl=r/t,gg/t,bl/t
		local l=g(nx,ny,-.1,-.15,.65)*.07
		r=r+(1-r)*l gg=gg+(1-gg)*l bl=bl+(1-bl)*l
		local i=(y*w+x)*4
		buffer.writeu8(b,i,math.floor(r*255))buffer.writeu8(b,i+1,math.floor(gg*255))buffer.writeu8(b,i+2,math.floor(bl*255))buffer.writeu8(b,i+3,math.floor(al))
	end end
	im:WritePixelsBuffer(Vector2.zero,Vector2.new(w,h),b)return im
end

local PI,LI
local okA,errA=pcall(function()PI=mkP()end)
if not okA then warn("ESP mkP falhou: "..tostring(errA)) end
local okB,errB=pcall(function()LI=mkPlus()end)
if not okB then warn("ESP mkPlus falhou: "..tostring(errB)) end
local gui=N("ScreenGui",{Name="PracticeIntro",Parent=pg,IgnoreGuiInset=true,ResetOnSpawn=false,DisplayOrder=999999})
local win=N("CanvasGroup",{Parent=gui,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(WW,WH),BackgroundColor3=BG,BorderSizePixel=0,GroupTransparency=1})
R(win,10)N("UIStroke",{Parent=win,Color=BD,Transparency=.4,Thickness=1})
local sc=N("UIScale",{Parent=win,Scale=.97})
local logo=N("CanvasGroup",{Parent=win,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(HW,HH),BackgroundTransparency=1})

local TW=X:GetTextSize("ractice",FS,FONT,Vector2.new(1000,100)).X
local ST=(HW-(PW+GP+RPAD+TW+GPS+PS))/2
local PX,TX=ST+PW/2+PXO,ST+PW+GP+RPAD+TXO
local LX=TX+TW+GPS+PS/2+LXO
local IP,IL=UDim2.fromOffset(HW/2-18,CY),UDim2.fromOffset(HW/2+24,CY)

local rev=N("Frame",{Parent=logo,Position=UDim2.fromOffset(TX,4+TYO),Size=UDim2.fromOffset(0,80),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2})
N("TextLabel",{Parent=rev,Size=UDim2.fromOffset(TW+6,80),BackgroundTransparency=1,Text="ractice",Font=FONT,TextSize=FS,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,ZIndex=2})

local wipe=N("Frame",{Parent=logo,AnchorPoint=Vector2.new(0,.5),Position=UDim2.fromOffset(TX-10,CY),Size=UDim2.fromOffset(WIPE,88),BackgroundColor3=BG,BorderSizePixel=0,Rotation=WA,ZIndex=4})

local p=N("ImageLabel",{Parent=logo,AnchorPoint=Vector2.new(.5,.5),Position=IP,Size=UDim2.fromOffset(PW,PH),BackgroundTransparency=1,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,Rotation=ROT,ZIndex=5})
if PI then pcall(function()p.ImageContent=Content.fromObject(PI)end) end

local ph=N("Frame",{Parent=logo,AnchorPoint=Vector2.new(.5,.5),Position=IL,Size=UDim2.fromOffset(PS,PS),BackgroundTransparency=1,ZIndex=5})
local plus=N("ImageLabel",{Parent=ph,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ImageTransparency=1,ScaleType=Enum.ScaleType.Fit,ZIndex=5})
if LI then pcall(function()plus.ImageContent=Content.fromObject(LI)end) end

-- SHINE
local fx=N("Frame",{Parent=logo,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=7})
local shine=N("Frame",{Parent=fx,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromOffset(-60,CY),Size=UDim2.fromOffset(SHW,120),BackgroundColor3=W,BackgroundTransparency=1,BorderSizePixel=0,Rotation=-18,ZIndex=7})R(shine,99)

-- BORDAS
local corners={}
local function C(ax,ay,h)
	local sx,sy=h and 0 or BTH,h and BTH or 0
	local tx,ty=h and BLEN or BTH,h and BTH or BLEN
	local f=N("Frame",{Parent=win,AnchorPoint=Vector2.new(ax,ay),Position=UDim2.new(ax,ax==1 and-BPX or BPX,ay,ay==1 and-BPY or BPY),Size=UDim2.fromOffset(sx,sy),BackgroundColor3=W,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=6})
	R(f,99)corners[#corners+1]={f,UDim2.fromOffset(sx,sy),UDim2.fromOffset(tx,ty)}
end
C(0,0,true)C(0,0,false)C(1,0,true)C(1,0,false)
C(0,1,true)C(0,1,false)C(1,1,true)C(1,1,false)

-- MENU
local menu=N("CanvasGroup",{Parent=win,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,GroupTransparency=1,Visible=false})
local top=N("Frame",{Parent=menu,Size=UDim2.new(1,0,0,50),BackgroundColor3=Color3.fromRGB(21,21,25),BorderSizePixel=0})R(top,10)
N("Frame",{Parent=top,Position=UDim2.new(0,0,1,-10),Size=UDim2.new(1,0,0,10),BackgroundColor3=top.BackgroundColor3,BorderSizePixel=0})
N("TextLabel",{Parent=top,Position=UDim2.fromOffset(18,0),Size=UDim2.fromOffset(180,50),BackgroundTransparency=1,Text="Practice+",Font=FONT,TextSize=17,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})

local close=N("TextButton",{Parent=top,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-15,.5,0),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(30,30,35),BorderSizePixel=0,Text="X",Font=Enum.Font.GothamBold,TextSize=15,TextColor3=Color3.fromRGB(200,80,80)})
R(close,7)
close.MouseButton1Click:Connect(function()gui:Destroy()end)

-- Minimizar para botao flutuante
local minBtn=N("TextButton",{Parent=top,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-51,.5,0),Size=UDim2.fromOffset(28,28),BackgroundColor3=Color3.fromRGB(30,30,35),BorderSizePixel=0,Text="-",Font=Enum.Font.GothamBold,TextSize=17,TextColor3=W})
R(minBtn,7)
local floatBtn=N("TextButton",{Parent=gui,AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-22,1,-22),Size=UDim2.fromOffset(52,52),BackgroundColor3=Color3.fromRGB(37,41,56),BorderSizePixel=0,Text="P+",Font=Enum.Font.GothamBlack,TextSize=18,TextColor3=W,Visible=false,ZIndex=999999})
R(floatBtn,26)N("UIStroke",{Parent=floatBtn,Color=W,Transparency=.3,Thickness=1})
local function minimize()
	Q(win,D(.15),{GroupTransparency=1},Enum.EasingStyle.Quad)
	task.wait(D(.15))
	win.Visible=false
	floatBtn.Visible=true
end
local function restore()
	floatBtn.Visible=false
	win.Visible=true
	Q(win,D(.15),{GroupTransparency=0},Enum.EasingStyle.Quad)
end
minBtn.MouseButton1Click:Connect(minimize)
floatBtn.MouseButton1Click:Connect(restore)

local side=N("Frame",{Parent=menu,Position=UDim2.fromOffset(0,50),Size=UDim2.new(0,145,1,-50),BackgroundColor3=Color3.fromRGB(14,14,17),BorderSizePixel=0})
N("Frame",{Parent=side,AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.new(0,1,1,0),BackgroundColor3=BD,BackgroundTransparency=.4,BorderSizePixel=0})

-- #####################################################################
-- ABA PLAYER (controles: ESP / Aimbot / Fly / Noclip)
-- #####################################################################

-- Estado das configuracoes
local SET = {
	espEnabled        = false,
	espTeamColor      = true,
	espNames          = false,
	espTracers        = false,
	espBoxes          = false,
	espShowSelf       = false,
	espColor          = Color3.fromRGB(235,70,70),
	aimbotEnabled     = false,
	aimFOV            = 150,
	aimSmooth         = 4,
	flyEnabled        = false,
	flySpeed          = 50,
	noclipEnabled     = false,
	walkSpeed         = 16,
	jumpPower         = 50,
	noFallDamage      = false,
	godMode           = false,
	hitboxExpand      = false,
	hitboxSize        = 1.5,
	antiAfk           = false,
	zoomFOV           = 0,
	theme             = 1,
}

local ESP_FOLDERS = { "Zombie", "Zombies", "Creeper", "Enemies", "Mobs" }

-- Containers de conteudo: um por aba (Home / Player / Visuals / Settings)
local ct=N("Frame",{Parent=menu,Position=UDim2.fromOffset(145,50),Size=UDim2.new(1,-145,1,-50),BackgroundTransparency=1})

-- Construtor de card (estilo escuro do menu)
local function card(parent, y, h)
	local f=N("Frame",{Parent=parent,Position=UDim2.fromOffset(14,y),Size=UDim2.new(1,-28,0,h),BackgroundColor3=Color3.fromRGB(23,23,28),BorderSizePixel=0})
	R(f,8)N("UIStroke",{Parent=f,Color=BD,Transparency=.45})
	return f
end

-- Toggle estilo switch (ON/OFF)
local function mkToggle(parent, y, title, sub, onChange, def)
	local c=card(parent,y,52)
	N("TextLabel",{Parent=c,Position=UDim2.fromOffset(14,8),Size=UDim2.new(.62,0,0,20),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(220,220,225),TextXAlignment=Enum.TextXAlignment.Left})
	local lbl=N("TextLabel",{Parent=c,Position=UDim2.fromOffset(14,26),Size=UDim2.new(.62,0,0,16),BackgroundTransparency=1,Text=sub or "",Font=Enum.Font.Gotham,TextSize=11,TextColor3=Color3.fromRGB(115,115,125),TextXAlignment=Enum.TextXAlignment.Left})
	local state=def or false
	local btn=N("TextButton",{Parent=c,AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-14,.5,0),Size=UDim2.fromOffset(62,24),BackgroundColor3=Color3.fromRGB(30,30,35),BorderSizePixel=0,Text="OFF",Font=Enum.Font.GothamBold,TextSize=12})
	R(btn,7)
	local function refresh()
		if state then btn.Text="ON" btn.TextColor3=W btn.BackgroundColor3=Color3.fromRGB(45,120,80)
		else btn.Text="OFF" btn.TextColor3=Color3.fromRGB(115,115,125) btn.BackgroundColor3=Color3.fromRGB(30,30,35) end
	end
	refresh()
	btn.MouseButton1Click:Connect(function() state=not state refresh() onChange(state) end)
	return {set=function(v) state=v refresh() end, get=function() return state end}
end

-- Slider horizontal
local function mkSlider(parent, y, title, minV, maxV, decimals, suffix, val, onChange)
	local c=card(parent,y,78)
	N("TextLabel",{Parent=c,Position=UDim2.fromOffset(14,8),Size=UDim2.new(.7,-20,0,18),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(220,220,225),TextXAlignment=Enum.TextXAlignment.Left})
	local vl=N("TextLabel",{Parent=c,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,8),Size=UDim2.fromOffset(80,18),BackgroundTransparency=1,TextColor3=W,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right})
	local rail=N("Frame",{Parent=c,Position=UDim2.fromOffset(14,42),Size=UDim2.new(1,-28,0,8),BackgroundColor3=Color3.fromRGB(30,30,35),BorderSizePixel=0})R(rail,4)
	local fill=N("Frame",{Parent=rail,Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(99,130,246),BorderSizePixel=0})R(fill,4)
	local thumb=N("TextButton",{Parent=rail,AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(18,18),BackgroundColor3=W,Text="",BorderSizePixel=0})R(thumb,9)
	local dragging=false
	local function update(frac,silent)
		frac=math.clamp(frac,0,1)
		local value=minV+frac*(maxV-minV)
		local step=10^decimals value=math.round(value*step)/step
		vl.Text=tostring(value)..(suffix and " "..suffix or "")
		fill.Size=UDim2.fromScale(frac,1)
		thumb.Position=UDim2.fromScale(frac,.5)
		if not silent then onChange(value) end
	end
	local function setByValue(v)
		update((v-minV)/(maxV-minV),true)
	end
	local function dragTo(pos)
		update((pos.X-rail.AbsolutePosition.X)/math.max(rail.AbsoluteSize.X,1))
	end
	local function beginDrag(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
			dragging=true dragTo(input.Position)
		end
	end
	local function endDrag(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
	end
	thumb.InputBegan:Connect(beginDrag) rail.InputBegan:Connect(beginDrag)
	thumb.InputEnded:Connect(endDrag) rail.InputEnded:Connect(endDrag)
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then dragTo(input.Position) end
	end)
	game:GetService("UserInputService").InputEnded:Connect(function(input) if dragging then endDrag(input) end end)
	update((val-minV)/(maxV-minV))
	return {set=setByValue,get=function() return minV+(fill.Size.X.Scale)*(maxV-minV) end,frame=c}
end

local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=P.LocalPlayer

-- Aberaca ESP: destaca outros jogadores + inimigos (chams, nomes, caixas)
local espHighlights={}
local espTags={}
local function getTargets()
	local ts={}
	if SET.espShowSelf and player.Character and player.Character.PrimaryPart then
		ts[#ts+1]=player.Character
	end
	for _,pl in ipairs(P:GetPlayers()) do
		if pl~=player and pl.Character and pl.Character.PrimaryPart then ts[#ts+1]=pl.Character end
	end
	for _,fn in ipairs(ESP_FOLDERS) do
		local f=workspace:FindFirstChild(fn)
		if f then for _,child in ipairs(f:GetChildren()) do
			if child:IsA("Model") and child.PrimaryPart then ts[#ts+1]=child end
		end end
	end
	return ts
end

local function isEnemy(char)
	local pl=P:GetPlayerFromCharacter(char)
	if not pl then return true end
	local myT,plT=player.Team,pl.Team
	if myT and plT and not player.Neutral and not pl.Neutral then return myT~=plT end
	return true
end
local function espColorFor(char,base)
	if SET.espTeamColor then
		local pl=P:GetPlayerFromCharacter(char)
		local tm=pl and pl.Team and pl.Team.TeamColor.Color
		if tm then return tm end
	end
	return base
end

local function clearESP()
	for _,hl in pairs(espHighlights) do if hl and hl.Parent then hl:Destroy() end end
	espHighlights={}
	for _,t in pairs(espTags) do
		if t then
			if t.tag then pcall(function() t.tag:Destroy() end) end
			if t.box then pcall(function() t.box:Destroy() end) end
		end
	end
	espTags={}
end

local function refreshESP()
	clearESP()
	if not SET.espEnabled then return end
	local baseColor=SET.espColor
	for _,char in ipairs(getTargets()) do
		if (char==player.Character and SET.espShowSelf) or (char~=player.Character and isEnemy(char)) then
			local color=espColorFor(char,baseColor)
			if not char:FindFirstChildOfClass("Highlight") then
				local hl=Instance.new("Highlight")
				hl.Name="ESP_Highlight"
				hl.FillColor=color
				hl.OutlineColor=Color3.new(0,0,0)
				hl.FillTransparency=.4 hl.OutlineTransparency=.3
				hl.Parent=char
				espHighlights[char]=hl
			end
			local head=char:FindFirstChild("Head") or char.PrimaryPart
			if head and (SET.espNames or SET.espBoxes) then
				local tag={}
				local bg=Instance.new("BillboardGui")
				bg.Name="ESP_Tag"
				bg.AlwaysOnTop=true
				bg.Adornee=head
				bg.Size=UDim2.fromScale(3*head.Size.X,8)
				bg.StudsOffsetWorldSpace=Vector3.new(0,head.Size.Y*1.4,0)
				bg.ClipsDescendants=false
				if SET.espNames then
					local nm=Instance.new("TextLabel")
					local nmText=P:GetPlayerFromCharacter(char) and P:GetPlayerFromCharacter(char).Name or "Inimigo"
					nm.Name="ESP_Name"
					nm.Size=UDim2.fromScale(1,.5)
					nm.BackgroundTransparency=1
					nm.Text=nmText
					nm.Font=Enum.Font.GothamBold
					nm.TextSize=14
					nm.TextColor3=Color3.new(1,1,1)
					nm.TextStrokeTransparency=.1
					nm.Parent=bg
					tag.tag=nm
				end
				if SET.espBoxes then
					local bx=Instance.new("Frame")
					bx.Name="ESP_Box"
					bx.Size=UDim2.new(1,0,2,0)
					bx.Position=UDim2.new(0,-0.5,0.5,0)
					bx.BackgroundTransparency=1
					bx.BorderSizePixel=0
					bx.Parent=bg
					local s=N("UIStroke",{Parent=bx,Color=color,Thickness=1.5,Transparency=.2})
					tag.box=bx
					tag.stroke=s
				end
				bg.Parent=char
				espTags[char]=tag
			end
		end
	end
end

-- Tracers: linhas da tela ate o alvo
local tracerLines={}
local tracerLabels={}
local DrawingOK=pcall(function() local d=Drawing.new("Line") d:Destroy() return true end)
local DrawingTextOK=pcall(function() local d=Drawing.new("Text") d:Destroy() return true end)
local function clearTracers()
	for _,l in pairs(tracerLines) do if l then pcall(function() l:Destroy() end) end end
	tracerLines={}
	for _,t in pairs(tracerLabels) do if t then pcall(function() t:Destroy() end) end end
	tracerLabels={}
end
RunService.RenderStepped:Connect(function()
	if DrawingOK and SET.espEnabled and SET.espTracers then
		local cam=workspace.CurrentCamera
		if not cam then return end
		local cs,rs=cam.CFrame.Position,cam.ViewportSize
		local idx=0
		for _,char in ipairs(getTargets()) do
			if (char==player.Character and SET.espShowSelf) or (char~=player.Character and isEnemy(char)) then
				local pt=char.PrimaryPart or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
				if pt then
					local sp=pt.Position
					local col=(isEnemy(char) and SET.espColor) or espColorFor(char,SET.espColor)
					local line=tracerLines[idx]
					if not line then
						line=Drawing.new("Line")
						line.Thickness=1.5
						line.Transparency=1
						line.Color=col
						tracerLines[idx]=line
					end
					line.Visible=true
					line.Color=col
					local p2=Vector2.new(rs.X/2,rs.Y)
					local screen,vis=cam:WorldToViewportPoint(sp)
					line.From=p2
					line.To=Vector2.new(screen.X,screen.Y)
					local lbl=tracerLabels[idx]
					if not lbl and DrawingTextOK then
						local ok,l2=pcall(function()
							local d=Drawing.new("Text")
							d.Size=14
							d.Center=true
							d.Outline=true
							d.OutlineColor=Color3.new(0,0,0)
							d.Color=col
							return d
						end)
						if ok and l2 then lbl=l2 tracerLabels[idx]=l2 end
					end
					if lbl then
						lbl.Visible=vis
						lbl.Text=math.floor((sp-cs).Magnitude).." studs"
						lbl.Position=Vector2.new(screen.X,screen.Y-16)
						lbl.Color=col
					end
					idx=idx+1
				end
			end
		end
		for i=idx,#tracerLines do
			local l=tracerLines[i]
			if l then l.Visible=false end
		end
		for i=idx,#tracerLabels do
			local t=tracerLabels[i]
			if t then t.Visible=false end
		end
	else
		for _,l in pairs(tracerLines) do if l then l.Visible=false end end
	end
end)


-- Fly (via BodyVelocity + gravidade desligada - levita e se move por impulso)
-- Nota: alguns executores/jogos nao tem todos os estados do enum; usa pcall p/ nao quebrar
local HST=Enum.HumanoidStateType
local function hstSafe(name)
	local ok,v=pcall(function() return HST[name] end)
	return ok and v or nil
end
local S_FALL=hstSafe("Falling")
local S_JUMP=hstSafe("Jumping")
local function setState(h,s,en)
	if not s then return end
	pcall(function() h:SetStateEnabled(s,en) end)
end

local flyBody=nil
local function ensureFlyBody(root)
	if flyBody and flyBody.Parent==root then return end
	if flyBody then flyBody:Destroy() end
	flyBody=Instance.new("BodyVelocity")
	flyBody.MaxForce=Vector3.new(9e9,9e9,9e9)
	flyBody.Velocity=Vector3.zero
	flyBody.Parent=root
end
local function toggleFly(on)
	if not on then
		if flyBody then pcall(function() flyBody:Destroy() end) flyBody=nil end
		local pl=player
		local char=pl and pl.Character
		local h=char and char:FindFirstChildOfClass("Humanoid")
		if h then
			setState(h,S_FALL,true)
			setState(h,S_JUMP,true)
		end
	end
end

-- Noclip
local function noclipping(char)
	char=char or player.Character
	if not char then return end
	for _,prt in ipairs(char:GetDescendants()) do
		if prt:IsA("BasePart") then prt.CanCollide=false end
	end
end

-- Loop principal: Fly + Noclip
RunService.Heartbeat:Connect(function()
	local char=player.Character
	local humanoid=char and char:FindFirstChildOfClass("Humanoid")
	local root=char and char:FindFirstChild("HumanoidRootPart")
	if SET.flyEnabled and root and humanoid then
		ensureFlyBody(root)
		setState(humanoid,S_FALL,false)
		setState(humanoid,S_JUMP,false)
		local up=0
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then up=1 end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then up=-1 end
		local cam=workspace.CurrentCamera
		local camDir=cam and cam.CFrame:VectorToWorldSpace(Vector3.new(0,0,-1)) or root.CFrame.LookVector
		local f2d=Vector3.new(camDir.X,0,camDir.Z).Unit
		local mv=Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv=mv+f2d end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv=mv-f2d end
		local hz=root.CFrame.RightVector
		hz=Vector3.new(hz.X,0,hz.Z).Unit
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv=mv-hz end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv=mv+hz end
		flyBody.Velocity=(mv*SET.flySpeed)+Vector3.new(0,up*SET.flySpeed,0)
	elseif flyBody and flyBody.Parent and flyBody.Parent.Parent==char then
		flyBody:Destroy() flyBody=nil
		if humanoid then
			setState(humanoid,S_FALL,true)
			setState(humanoid,S_JUMP,true)
		end
	end
	if SET.noclipEnabled and char and humanoid then noclipping(char) end
end)

-- Movimento (velocidade / pulo) + Infinite Jump + NoFallDamage
RunService.Heartbeat:Connect(function()
	local char=player.Character
	local humanoid=char and char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	pcall(function() humanoid.WalkSpeed=SET.walkSpeed end)
	pcall(function() humanoid.JumpPower=SET.jumpPower end)
	if SET.noFallDamage then
		pcall(function() humanoid:SetStateEnabled(S_FALL,true) end)
	end
	if SET.godMode then
		pcall(function()
			local max=humanoid.MaxHealth
			if humanoid.Health<max then humanoid.Health=max end
		end)
	end
end)

-- Hitbox expandido (HumanoidRootPart maior p/ acertar com mais facilidade)
RunService.Heartbeat:Connect(function()
	if not SET.hitboxExpand then return end
	local char=player.Character
	if not char then return end
	local selfRoot=char:FindFirstChild("HumanoidRootPart")
	if not selfRoot then return end
	for _,t in ipairs(getTargets()) do
		local isSelf=(t==char)
		if SET.espShowSelf or not isSelf then
			local hd=t:FindFirstChild("HumanoidRootPart")
			if hd then
				pcall(function() hd.Size=selfRoot.Size*SET.hitboxSize end)
			end
		end
	end
end)

-- Anti-afk (mantem o personagem ativo - mexe levemente para nao ser kickado)
task.spawn(function()
	local lastMove=os.clock()
	while true do
		task.wait(1)
		if SET.antiAfk then
			pcall(function()
				local r=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if r then
					r.Velocity=Vector3.new(r.Velocity.X,0,r.Velocity.Z)
					lastMove=os.clock()
				end
			end)
		end
	end
end)

-- Zoom FOV da camera
RunService.RenderStepped:Connect(function()
	if SET.zoomFOV~=0 and SET.zoomFOV~=math.huge then
		local cam=workspace.CurrentCamera
		if cam then
			local targetFOV=math.clamp(70-SET.zoomFOV,40,70)
			pcall(function() cam.FieldOfView=cam.FieldOfView+(targetFOV-cam.FieldOfView)*.2 end)
		end
	end
end)

-- Aimbot (segue a mira: gruda em quem voce apontar e troca ao mirar em outro)
RunService.RenderStepped:Connect(function()
	if not SET.aimbotEnabled then return end
	local cam=workspace.CurrentCamera
	local char=player.Character
	local root=char and char:FindFirstChild("HumanoidRootPart")
	if not (cam and root) then return end
	local camPos=cam.CFrame.Position
	local camLook=cam.CFrame.LookVector
	local best,bestAng=nil,SET.aimFOV
	for _,t in ipairs(getTargets()) do
		if t==char then continue end
		if not isEnemy(t) then continue end
		local hd=t:FindFirstChild("Head") or t.PrimaryPart
		if hd then
			local hp=hd.Position
			local dir=(hp-camPos).Unit
			local ang=math.deg(math.acos(math.clamp(camLook:Dot(dir),-1,1)))
			if ang<=bestAng then best=hp bestAng=ang end
		end
	end
	if best then
		local alpha=1/(math.max(SET.aimSmooth,1)+1)
		cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(camPos,best),alpha)
	end
end)

-- Reaplica apos respawn
player.CharacterAdded:Connect(function()
	if SET.noclipEnabled then noclipping() end
	if SET.espEnabled then refreshESP() end
end)
P.PlayerAdded:Connect(function(pl) pl.CharacterAdded:Connect(function() if SET.espEnabled then refreshESP() end end) end)

-- HOME: conteudo estatico
local home=N("Frame",{Parent=ct,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1})
N("TextLabel",{Parent=home,Position=UDim2.fromOffset(20,18),Size=UDim2.new(1,-40,0,28),BackgroundTransparency=1,Text="Home",Font=FONT,TextSize=21,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})
N("TextLabel",{Parent=home,Position=UDim2.fromOffset(20,48),Size=UDim2.new(1,-40,0,20),BackgroundTransparency=1,Text="Welcome to Practice+",Font=Enum.Font.Gotham,TextSize=12,TextColor3=Color3.fromRGB(115,115,125),TextXAlignment=Enum.TextXAlignment.Left})
local cardHome=card(home,84,145)
N("TextLabel",{Parent=cardHome,Position=UDim2.fromOffset(14,10),Size=UDim2.new(1,-28,0,25),BackgroundTransparency=1,Text="Practice",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(220,220,225),TextXAlignment=Enum.TextXAlignment.Left})

-- PLAYER: controles de Combate e Movimento em scrolling
local function mkScrollFrame()
	local sc=N("ScrollingFrame",{Parent=ct,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=4,ScrollBarImageColor3=Color3.fromRGB(48,48,55)})
	local fr=N("Frame",{Parent=sc,Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y})
	fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() sc.CanvasSize=UDim2.fromOffset(0,fr.AbsoluteSize.Y+12) end)
	return sc,fr
end

local scroll,pframe=mkScrollFrame()
N("TextLabel",{Parent=pframe,Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(200,24),BackgroundTransparency=1,Text="Player",Font=FONT,TextSize=21,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})
N("TextLabel",{Parent=pframe,Position=UDim2.fromOffset(14,42),Size=UDim2.new(1,-28,0,18),BackgroundTransparency=1,Text="Combate e Movimento",Font=Enum.Font.Gotham,TextSize=12,TextColor3=Color3.fromRGB(115,115,125),TextXAlignment=Enum.TextXAlignment.Left})

local y=72
local aimTog=mkToggle(pframe,y,"Aimbot","Aponta a cam para o inimigo mais proximo",function(on) SET.aimbotEnabled=on end) y=y+58
mkSlider(pframe,y,"FOV do Aimbot",30,360,0,"graus",SET.aimFOV,function(v) SET.aimFOV=v end) y=y+84
mkSlider(pframe,y,"Suavidade do Aimbot",1,30,0,"",SET.aimSmooth,function(v) SET.aimSmooth=math.round(v) end) y=y+84

mkSlider(pframe,y,"Forca do pulo",20,200,0,"",SET.jumpPower,function(v) SET.jumpPower=v end) y=y+84
local noFallTog=mkToggle(pframe,y,"Sem dano de queda","Nao toma dano ao cair",function(on) SET.noFallDamage=on end) y=y+58
local godTog=mkToggle(pframe,y,"God Mode","Imortal: nao toma dano nem morre",function(on) SET.godMode=on end) y=y+58
local hitboxTog=mkToggle(pframe,y,"Hitbox expandido","Inimigos com partes maiores",function(on) SET.hitboxExpand=on end) y=y+58
mkSlider(pframe,y,"Tamanho do Hitbox",1.2,3,1,"x",SET.hitboxSize,function(v) SET.hitboxSize=v end) y=y+84

local flyTog=mkToggle(pframe,y,"Fly","Voe segurando Espaco (sobe) / Shift (desce)",function(on) pcall(function() SET.flyEnabled=on toggleFly(on) end) end) y=y+58
mkSlider(pframe,y,"Velocidade do Fly",10,200,0,"studs/s",SET.flySpeed,function(v) SET.flySpeed=v end) y=y+84
local noclipTog=mkToggle(pframe,y,"Noclip","Atravessa paredes",function(on) SET.noclipEnabled=on end) y=y+58
pframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() scroll.CanvasSize=UDim2.fromOffset(0,pframe.AbsoluteSize.Y+12) end)
scroll.CanvasSize=UDim2.fromOffset(0,y+12)

-- VISUALS: ESP em scrolling
local vscroll,vframe=mkScrollFrame()
N("TextLabel",{Parent=vframe,Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(200,24),BackgroundTransparency=1,Text="Visuals",Font=FONT,TextSize=21,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})
local vy=72
local espTog=mkToggle(vframe,vy,"ESP","Destaca outros jogadores no mapa",function(on) SET.espEnabled=on refreshESP() end) vy=vy+58
local espColTog=mkToggle(vframe,vy,"ESP cor da equipe","Usa a cor da equipe do alvo",function(on) SET.espTeamColor=on refreshESP() end,true) vy=vy+58
local espNamesTog=mkToggle(vframe,vy,"Nomes acima da cabeca","Mostra o nome dos alvos",function(on) SET.espNames=on refreshESP() end) vy=vy+58
local espTracersTog=mkToggle(vframe,vy,"Tracers","Linhas da tela ate os alvos",function(on) SET.espTracers=on end) vy=vy+58
local espBoxesTog=mkToggle(vframe,vy,"Caixas (Boxes)","Caixa ao redor dos alvos",function(on) SET.espBoxes=on refreshESP() end) vy=vy+58
local espSelfTog=mkToggle(vframe,vy,"Mostrar voce no ESP","Marca o proprio personagem tambem",function(on) SET.espShowSelf=on refreshESP() end) vy=vy+58
N("TextLabel",{Parent=vframe,Position=UDim2.fromOffset(14,vy),Size=UDim2.new(1,-28,0,18),BackgroundTransparency=1,Text="Cor do ESP (RGB)",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=Color3.fromRGB(220,220,225),TextXAlignment=Enum.TextXAlignment.Left}) vy=vy+24
mkSlider(vframe,vy,"Vermelho",0,255,0,"",SET.espColor.R*255,function(v) SET.espColor=Color3.fromRGB(math.round(v),math.round(SET.espColor.G*255),math.round(SET.espColor.B*255)) refreshESP() end) vy=vy+84
mkSlider(vframe,vy,"Verde",0,255,0,"",SET.espColor.G*255,function(v) SET.espColor=Color3.fromRGB(math.round(SET.espColor.R*255),math.round(v),math.round(SET.espColor.B*255)) refreshESP() end) vy=vy+84
mkSlider(vframe,vy,"Azul",0,255,0,"",SET.espColor.B*255,function(v) SET.espColor=Color3.fromRGB(math.round(SET.espColor.R*255),math.round(SET.espColor.G*255),math.round(v)) refreshESP() end) vy=vy+84
vframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() vscroll.CanvasSize=UDim2.fromOffset(0,vframe.AbsoluteSize.Y+12) end)
vscroll.CanvasSize=UDim2.fromOffset(0,vy+12)

-- SETTINGS
local sscroll,sframe=mkScrollFrame()
N("TextLabel",{Parent=sframe,Position=UDim2.fromOffset(14,12),Size=UDim2.fromOffset(200,24),BackgroundTransparency=1,Text="Settings",Font=FONT,TextSize=21,TextColor3=W,TextXAlignment=Enum.TextXAlignment.Left})
local sy=72
local antiAfkTog=mkToggle(sframe,sy,"Anti-afk","Impede o kick por inatividade",function(on) SET.antiAfk=on end) sy=sy+58
mkSlider(sframe,sy,"Zoom da camera (FOV)",0,30,0,"",SET.zoomFOV,function(v) SET.zoomFOV=math.round(v) end) sy=sy+84
local themeBtn=N("TextButton",{Parent=sframe,Position=UDim2.fromOffset(14,sy),Size=UDim2.new(1,-28,0,52),BackgroundColor3=Color3.fromRGB(23,23,28),BorderSizePixel=0,Text="Tema: Padrao (clique p/ trocar)",Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=W})
R(themeBtn,8)N("UIStroke",{Parent=themeBtn,Color=BD,Transparency=.45})
local themes={{"Padrao",Color3.fromRGB(99,130,246)},{"Verde",Color3.fromRGB(60,179,113)},{"Laranja",Color3.fromRGB(255,140,0)},{"Rosa",Color3.fromRGB(255,105,180)}}
local function applyTheme(idx)
	local c=themes[idx]
	SET.theme=idx
	themeBtn.Text="Tema: "..c[1].." (clique p/ trocar)"
	Q(win,D(.1),{BackgroundColor3=SET.theme~=1 and Color3.fromRGB(20,20,24) or Color3.fromRGB(17,17,20)},Enum.EasingStyle.Quad)
end
themeBtn.MouseButton1Click:Connect(function() applyTheme((SET.theme%#themes)+1) end)
applyTheme(SET.theme)
sy=sy+58
local resetBtn=N("TextButton",{Parent=sframe,Position=UDim2.fromOffset(14,sy),Size=UDim2.new(1,-28,0,46),BackgroundColor3=Color3.fromRGB(120,45,45),BorderSizePixel=0,Text="Resetar todas as configs",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=W})
R(resetBtn,8)
resetBtn.MouseButton1Click:Connect(function()
	for _,t in ipairs({espTog,aimTog,noFallTog,godTog,hitboxTog,flyTog,noclipTog,espColTog,espNamesTog,espTracersTog,espBoxesTog,espSelfTog,antiAfkTog}) do t.set(false) end
	SET.aimFOV=150 SET.aimSmooth=4 SET.flySpeed=50 SET.walkSpeed=16 SET.jumpPower=50 SET.hitboxSize=1.5 SET.zoomFOV=0 SET.godMode=false
	SET.espColor=Color3.fromRGB(235,70,70)
	SET.espEnabled=false
	setState(player.Character and player.Character:FindFirstChildOfClass("Humanoid"),S_FALL,true)
	setState(player.Character and player.Character:FindFirstChildOfClass("Humanoid"),S_JUMP,true)
	refreshESP()
end)
sy=sy+58
sframe:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() sscroll.CanvasSize=UDim2.fromOffset(0,sframe.AbsoluteSize.Y+12) end)
sscroll.CanvasSize=UDim2.fromOffset(0,sy+12)

local col={Visuals=vscroll,Settings=sscroll}

-- Troca de abas: sidebar
local pages={Home=home,Player=pframe,Visuals=col.Visuals,Settings=col.Settings}
local allBtns={}
local function switchTab(name,btn)
	for k,v in pairs(pages) do
		if v then v.Visible=(k==name) v.Position=UDim2.fromOffset(0,0) end
	end
	for _,b in pairs(allBtns) do
		b.BackgroundTransparency=1 b.TextColor3=Color3.fromRGB(115,115,125)
	end
	if btn then btn.BackgroundTransparency=0 btn.TextColor3=W end
end

local function mkTab(s,y,on)
	local b=N("TextButton",{Parent=side,Position=UDim2.fromOffset(10,y),Size=UDim2.new(1,-20,0,36),BackgroundColor3=Color3.fromRGB(30,30,35),BackgroundTransparency=on and 0 or 1,BorderSizePixel=0,Text=s,Font=Enum.Font.GothamMedium,TextSize=13,TextColor3=on and W or Color3.fromRGB(115,115,125),TextXAlignment=Enum.TextXAlignment.Left})
	R(b,7)N("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
	b.MouseButton1Click:Connect(function() switchTab(s,b) end)
	allBtns[#allBtns+1]=b
	return b
end
mkTab("Home",18,true)mkTab("Player",59,false)mkTab("Visuals",100,false)mkTab("Settings",141,false)
switchTab("Home",allBtns[1])
for k,v in pairs(pages) do
	if v and k~="Home" and k~="Player" then v.Visible=false end
end

-- IN
Q(win,D(.15),{GroupTransparency=0},Enum.EasingStyle.Quad)
Q(sc,D(.2),{Scale=1})
task.wait(D(.04))
Q(p,D(.15),{ImageTransparency=0},Enum.EasingStyle.Quad)
Q(plus,D(.15),{ImageTransparency=0},Enum.EasingStyle.Quad)
task.wait(D(.18))

-- OPEN
local F=G(OPEN)local DL=F*TDELAY local TD=F-DL

Q(p,F,{Position=UDim2.fromOffset(PX,CY+PYO),Rotation=0})
Q(ph,F,{Position=UDim2.fromOffset(LX,CY+LYO)},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
Q(plus,F,{Rotation=360},Enum.EasingStyle.Quint,Enum.EasingDirection.Out)

task.delay(DL,function()
	Q(rev,TD,{Size=UDim2.fromOffset(TW+6,80)},Enum.EasingStyle.Quart)
	Q(wipe,TD*.78,{Position=UDim2.fromOffset(TX-WIPE-5,CY),Size=UDim2.fromOffset(0,88)},Enum.EasingStyle.Quart)
	for _,c in ipairs(corners)do Q(c[1],TD*.5,{Size=c[3],BackgroundTransparency=.04},Enum.EasingStyle.Quart)end
	shine.Position=UDim2.fromOffset(-60,CY)
	shine.BackgroundTransparency=1
	Q(shine,TD*.12,{BackgroundTransparency=SHA},Enum.EasingStyle.Quad)
	Q(shine,TD*.6,{Position=UDim2.fromOffset(HW+60,CY),BackgroundTransparency=1},Enum.EasingStyle.Linear)
end)

task.wait(F)
wipe.Visible=false
task.wait(D(HOLD))

-- REVERSE
local RF=F local LEAD=RF*.07
wipe.Visible=true
wipe.Position=UDim2.fromOffset(TX-10,CY)
wipe.Size=UDim2.fromOffset(0,88)
for _,c in ipairs(corners)do Q(c[1],RF*.28,{Size=c[2],BackgroundTransparency=1},Enum.EasingStyle.Quart,Enum.EasingDirection.In)end
Q(wipe,RF*.78,{Size=UDim2.fromOffset(TW+WIPE+20,88)},Enum.EasingStyle.Quart,Enum.EasingDirection.InOut)
task.wait(LEAD)
local MOVE=RF-LEAD
Q(p,MOVE,{Position=IP,Rotation=ROT},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
Q(ph,MOVE,{Position=IL},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
Q(plus,MOVE,{Rotation=0},Enum.EasingStyle.Quint,Enum.EasingDirection.InOut)
task.wait(MOVE)
rev.Size=UDim2.fromOffset(0,80)
wipe.Visible=false

-- LOAD (nao-bloqueante, com timeout de seguranca)
plus.Rotation=0
local loadTw=Q(plus,D(LOAD),{Rotation=360*TURNS},Enum.EasingStyle.Linear)
task.wait(D(LOAD)+.3)
plus.Rotation=0

-- MENU (abre via coroutine para nunca travar a GUI)
task.spawn(function()
	Q(logo,D(.14),{GroupTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)
	Q(sc,D(.12),{Scale=.98},Enum.EasingStyle.Quad)
	local winTw=Q(win,D(.38),{Size=UDim2.fromOffset(MW,MH)},Enum.EasingStyle.Quint)
	-- espera o tween OU um tempo maximo, o que vier primeiro
	task.wait(D(.38)+.2)
	logo.Visible=false
	for _,c in ipairs(corners)do c[1].Visible=false end
	menu.Visible=true
	Q(sc,D(.22),{Scale=1})
	Q(menu,D(.28),{GroupTransparency=0},Enum.EasingStyle.Quad)
end)
