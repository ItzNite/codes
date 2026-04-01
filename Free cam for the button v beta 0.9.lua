local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local cam = workspace.CurrentCamera
local active = false

-- Control de Personaje
local PlayerModule = require(lp:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

-- Ajustes Variables
_G.CamSpeed = 2
_G.CamSens = 0.5
local camPos = cam.CFrame.Position
local rotX, rotY = 0, 0

-- --- SISTEMA DE NOMBRES Y VIDA (ESP) ---
local function createESP(p)
    if p == lp then return end
    local function setup(char)
        local head = char:WaitForChild("Head", 10)
        local hum = char:WaitForChild("Humanoid", 10)
        if not head or not hum then return end

        local bill = Instance.new("BillboardGui", CoreGui)
        bill.Name = "ESP_" .. p.Name
        bill.Adornee = head
        bill.Size = UDim2.new(0, 150, 0, 50)
        bill.AlwaysOnTop = true
        bill.ExtentsOffset = Vector3.new(0, 3, 0)

        local txt = Instance.new("TextLabel", bill)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.SourceSansBold
        txt.TextSize = 16

        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char.Parent or not hum.Parent then
                bill:Destroy()
                conn:Disconnect()
            else
                txt.Text = string.format("%s\nHP: %d", p.Name, math.floor(hum.Health))
                -- Color dinámico según la vida
                if hum.Health < 30 then txt.TextColor3 = Color3.new(1, 0, 0)
                else txt.TextColor3 = Color3.new(1, 1, 1) end
            end
        end)
    end
    if p.Character then setup(p.Character) end
    p.CharacterAdded:Connect(setup)
end

for _, v in pairs(Players:GetPlayers()) do createESP(v) end
Players.PlayerAdded:Connect(createESP)

-- --- INTERFAZ GRÁFICA MEJORADA ---
local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "OvercellFinal"

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 350)
mainFrame.Position = UDim2.new(0, 10, 0.5, -175)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
local corner = Instance.new("UICorner", mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "OVERCELL SPECTATOR"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.SourceSansBold
title.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0.8, 0, 0, 40)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
toggleBtn.Text = "ESTADO: APAGADO"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.SourceSansBold

-- Etiquetas de los inputs
local function addInputLabel(text, yPos)
    local lbl = Instance.new("TextLabel", mainFrame)
    lbl.Size = UDim2.new(0.4, 0, 0, 30)
    lbl.Position = UDim2.new(0.05, 0, 0, yPos)
    lbl.Text = text
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.SourceSans
end

addInputLabel("VELOCIDAD:", 100)
local speedBox = Instance.new("TextBox", mainFrame)
speedBox.Size = UDim2.new(0.4, 0, 0, 30)
speedBox.Position = UDim2.new(0.5, 0, 0, 100)
speedBox.Text = tostring(_G.CamSpeed)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.new(1, 1, 1)

addInputLabel("SENSIBILIDAD:", 140)
local sensBox = Instance.new("TextBox", mainFrame)
sensBox.Size = UDim2.new(0.4, 0, 0, 30)
sensBox.Position = UDim2.new(0.5, 0, 0, 140)
sensBox.Text = tostring(_G.CamSens)
sensBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
sensBox.TextColor3 = Color3.new(1, 1, 1)

local guide = Instance.new("TextLabel", mainFrame)
guide.Size = UDim2.new(1, 0, 0, 120)
guide.Position = UDim2.new(0, 0, 0, 190)
guide.Text = "TECLAS:\n[W,A,S,D] Mover\n[E] Subir | [Q] Bajar\n[Click Der] Girar Cámara\nINFO: ESP Activado"
guide.TextColor3 = Color3.fromRGB(180, 180, 180)
guide.TextSize = 14
guide.BackgroundTransparency = 1

-- Lógica de Botón
toggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        _G.CamSpeed = tonumber(speedBox.Text) or 2
        _G.CamSens = tonumber(sensBox.Text) or 0.5
        camPos = cam.CFrame.Position
        toggleBtn.Text = "ESTADO: ACTIVADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        cam.CameraType = Enum.CameraType.Scriptable
        Controls:Disable()
    else
        toggleBtn.Text = "ESTADO: APAGADO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        cam.CameraType = Enum.CameraType.Custom
        Controls:Enable()
    end
end)

-- --- LOOP DE MOVIMIENTO ---
RunService.RenderStepped:Connect(function(dt)
    if not active then return end

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local delta = UserInputService:GetMouseDelta()
        rotY = rotY - (delta.X * _G.CamSens * 0.4)
        rotX = math.clamp(rotX - (delta.Y * _G.CamSens * 0.4), -88, 88)
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    local lookCF = CFrame.Angles(0, math.rad(rotY), 0) * CFrame.Angles(math.rad(rotX), 0, 0)
    local moveDir = Vector3.new(0,0,0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += lookCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= lookCF.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += lookCF.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= lookCF.RightVector end
    
    -- Eje Vertical Corregido
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then moveDir += Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then moveDir -= Vector3.new(0, 1, 0) end

    camPos = camPos + (moveDir * _G.CamSpeed)
    cam.CFrame = CFrame.new(camPos) * lookCF
end)