-- Layanan dan Variabel Global
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Mencegah GUI dibuat berulang kali
if game:GetService("CoreGui"):FindFirstChild("ArexansESPGUI") then
    game:GetService("CoreGui"):FindFirstChild("ArexansESPGUI"):Destroy()
end

-- ====================================================================
-- == BAGIAN FUNGSI ESP (Visuals)                                    ==
-- ====================================================================

-- Toggles baru, Health Bar kini terpisah dari Nama
local IsEspNameEnabled = false
local IsEspBodyEnabled = false
local IsEspLineEnabled = false
local IsEspHealthBarEnabled = false -- TOGGLE BARU UNTUK HEALTH BAR
local EspRenderConnection = nil
local espCache = {} -- Cache untuk elemen GUI ESP

-- Fungsi BARU untuk membersihkan semua elemen ESP UNTUK SATU PEMAIN
local function cleanupPlayerESP(userId)
    local elements = espCache[userId]
    if elements then
        -- Hancurkan semua elemen Billboard (yang berisi nama dan health bar)
        if elements.billboard then pcall(function() elements.billboard:Destroy() end) end
        if elements.highlight then pcall(function() elements.highlight:Destroy() end) end
        if elements.beam then pcall(function() elements.beam:Destroy() end) end
        if elements.attachment0 then pcall(function() elements.attachment0:Destroy() end) end
        if elements.attachment1 then pcall(function() elements.attachment1:Destroy() end) end
        espCache[userId] = nil -- Hapus dari cache setelah dihancurkan
    end
end

-- Fungsi untuk membersihkan SEMUA elemen ESP
local function cleanupAllESP()
    if EspRenderConnection then
        EspRenderConnection:Disconnect()
        EspRenderConnection = nil
    end
    
    -- Gunakan fungsi cleanupPlayerESP untuk setiap entri di cache
    for userId, _ in pairs(espCache) do
        cleanupPlayerESP(userId)
    end
end

-- Fungsi utama yang di-loop untuk menggambar ESP
local function UpdateESP()
    -- Cek apakah ada fitur ESP yang aktif
    local isAnyEspActive = IsEspNameEnabled or IsEspBodyEnabled or IsEspLineEnabled or IsEspHealthBarEnabled
    if not isAnyEspActive then return end
    
    local localPlayerTeam = LocalPlayer.Team
    local localCharacter = LocalPlayer.Character
    local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera

    -- Jika pemain lokal (kita) tidak memiliki root part (mati atau respawn), hentikan sementara.
    if not localRoot or not camera then return end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            -- Cek: Apakah target player hidup (memiliki semua bagian penting dan Health > 0)?
            if head and hrp and humanoid and humanoid.Health > 0 then
                
                local espElements = espCache[player.UserId]
                if not espElements then
                    espElements = {}
                    espCache[player.UserId] = espElements
                end

                local isTeam = (player.Team == localPlayerTeam and localPlayerTeam ~= nil)
                
                local espColor
                if isTeam then
                    espColor = Color3.fromRGB(0, 150, 255) -- BIRU (Kawan)
                else
                    espColor = Color3.fromRGB(255, 100, 100) -- MERAH (Musuh)
                end

                local distance = (localRoot.Position - head.Position).Magnitude
                
                -- Cek apakah Billboard GUI (Nama, Jarak, Health Bar) diperlukan
                local isBillboardNeeded = IsEspNameEnabled or IsEspHealthBarEnabled

                if isBillboardNeeded then
                    if not espElements.billboard then
                        local billboardGui = Instance.new("BillboardGui")
                        billboardGui.Name = "PlayerESP_Billboard"
                        billboardGui.AlwaysOnTop = true
                        billboardGui.Size = UDim2.new(0, 150, 0, 45) -- Ukuran tetap
                        billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)

                        -- Name Label
                        local nameLabel = Instance.new("TextLabel", billboardGui)
                        nameLabel.Name = "NameLabel"
                        nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
                        nameLabel.Position = UDim2.new(0, 0, 0, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Font = Enum.Font.SourceSansBold
                        nameLabel.TextSize = 14
                        nameLabel.Text = player.DisplayName
                        nameLabel.TextXAlignment = Enum.TextXAlignment.Center

                        -- Distance Label
                        local distLabel = Instance.new("TextLabel", billboardGui)
                        distLabel.Name = "DistanceLabel"
                        distLabel.Size = UDim2.new(1, 0, 0.3, 0)
                        distLabel.Position = UDim2.new(0, 0, 0.4, 0)
                        distLabel.BackgroundTransparency = 1
                        distLabel.Font = Enum.Font.SourceSans
                        distLabel.TextSize = 12
                        distLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
                        distLabel.TextXAlignment = Enum.TextXAlignment.Center
                        
                        -- HEALTH BAR CONTAINER
                        local healthFrame = Instance.new("Frame", billboardGui)
                        healthFrame.Name = "HealthBackground"
                        healthFrame.Size = UDim2.new(1, -10, 0, 8) -- Ukuran awal
                        healthFrame.Position = UDim2.new(0.5, -70, 0.7, 0)
                        healthFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                        healthFrame.BorderSizePixel = 1
                        healthFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        
                        local healthFill = Instance.new("Frame", healthFrame)
                        healthFill.Name = "HealthFill"
                        healthFill.Size = UDim2.new(1, 0, 1, 0)
                        healthFill.Position = UDim2.new(0, 0, 0, 0)
                        healthFill.BackgroundColor3 = espColor 
                        healthFill.BorderSizePixel = 0
                        
                        espElements.billboard = billboardGui
                    end

                    espElements.billboard.Adornee = head
                    espElements.billboard.Parent = CoreGui
                    
                    -- A. Update Visibility Nama/Jarak (Tergantung Toggle)
                    espElements.billboard.NameLabel.Visible = IsEspNameEnabled
                    espElements.billboard.NameLabel.TextColor3 = espColor
                    
                    espElements.billboard.DistanceLabel.Visible = IsEspNameEnabled
                    
                    -- Update jarak dan teks
                    local distanceText = "[" .. tostring(math.floor(distance)) .. "m]"
                    espElements.billboard.DistanceLabel.Text = distanceText

                    -- B. Update Health Bar
                    local healthBackground = espElements.billboard:FindFirstChild("HealthBackground")
                    
                    if healthBackground then
                        healthBackground.Visible = IsEspHealthBarEnabled -- Visibilitas berdasarkan toggle baru
                        
                        if IsEspHealthBarEnabled then
                            -- === LOGIKA SCALING DINAMIS ===
                            local MaxDistance = 150 -- Jarak maks untuk scaling (150 stud)
                            local MinScaleFactor = 0.3 -- Skala minimum (30% dari ukuran penuh)
                            local BaseBarWidth = 140 -- Lebar bar dasar (150 - 10)

                            -- Hitung skala: 1.0 (dekat) hingga MinScaleFactor (jauh)
                            local scaleFactor = math.max(MinScaleFactor, 1 - (distance / MaxDistance))

                            local scaledWidth = BaseBarWidth * scaleFactor

                            -- Terapkan ukuran dan posisi yang diskalakan
                            healthBackground.Size = UDim2.new(0, scaledWidth, 0, 8)
                            -- Penempatan di tengah (0.5 - (scaledWidth / 2) / 150)
                            local centerOffset = (150 - scaledWidth) / 2
                            healthBackground.Position = UDim2.new(0, centerOffset, 0.7, 0)
                            
                            -- Update fill bar
                            local healthPercentage = humanoid.Health / humanoid.MaxHealth
                            local healthFillFrame = healthBackground.HealthFill
                            
                            healthFillFrame.Size = UDim2.new(healthPercentage, 0, 1, 0)
                            healthFillFrame.BackgroundColor3 = espColor -- Warna tim/musuh
                        end
                    end
                
                elseif espElements.billboard then
                    -- Hancurkan Billboard jika tidak ada fitur yang memerlukannya
                    espElements.billboard:Destroy()
                    espElements.billboard = nil
                end

                -- 2. Logika ESP Tubuh (Highlight)
                if IsEspBodyEnabled then
                    if not espElements.highlight then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
                        highlight.FillTransparency = 0.7
                        highlight.OutlineTransparency = 0.5
                        highlight.Parent = char
                        espElements.highlight = highlight
                    end
                    
                    if espElements.highlight.Parent ~= char then
                        espElements.highlight.Parent = char
                    end

                    espElements.highlight.FillColor = espColor 
                    espElements.highlight.OutlineColor = espColor 

                elseif espElements.highlight then
                    espElements.highlight:Destroy()
                    espElements.highlight = nil
                end

                -- 3. Logika ESP Garis (Line)
                if IsEspLineEnabled then
                    if not espElements.attachment0 then
                        local att0 = Instance.new("Attachment")
                        att0.Name = "ESPGarisAtt0_Origin"
                        att0.Parent = camera 
                        espElements.attachment0 = att0
                    end
                    
                    if not espElements.attachment1 then
                        local att1 = Instance.new("Attachment")
                        att1.Name = "ESPGarisAtt1_Target"
                        att1.Parent = hrp
                        espElements.attachment1 = att1
                    end

                    if not espElements.beam then
                        local beam = Instance.new("Beam")
                        beam.Name = "ESPBeam"
                        beam.Attachment0 = espElements.attachment0
                        beam.Attachment1 = espElements.attachment1
                        beam.Width0 = 0.01 
                        beam.Width1 = 0.01
                        beam.FaceCamera = true
                        beam.Transparency = NumberSequence.new(0.5)
                        beam.Parent = espElements.attachment0 
                        espElements.beam = beam
                    end

                    local viewportSize = camera.ViewportSize
                    local screenBottom = Vector2.new(viewportSize.X / 2, viewportSize.Y * 0.95) 
                    
                    local ray = camera:ViewportPointToRay(screenBottom.X, screenBottom.Y)
                    espElements.attachment0.WorldPosition = ray.Origin + ray.Direction 

                    if espElements.attachment1.Parent ~= hrp then
                        espElements.attachment1.Parent = hrp
                    end

                    espElements.beam.Color = ColorSequence.new(espColor) 
                    espElements.beam.Enabled = true

                elseif espElements.beam then
                    if espElements.beam then espElements.beam:Destroy(); espElements.beam = nil end
                    if espElements.attachment0 then espElements.attachment0:Destroy(); espElements.attachment0 = nil end
                    if espElements.attachment1 then espElements.attachment1:Destroy(); espElements.attachment1 = nil end
                end

            else
                -- Pemain tidak punya karakter atau mati (Health <= 0), bersihkan ESP mereka.
                -- Ini memastikan ESP hilang saat pemain target mati dan muncul kembali saat mereka respawn.
                if espCache[player.UserId] then
                    cleanupPlayerESP(player.UserId) -- Panggil fungsi bersih yang benar
                end
            end
        end
    end
end

-- Fungsi untuk mengelola koneksi loop ESP
local function manageEspConnection()
    local isAnyEspActive = IsEspNameEnabled or IsEspBodyEnabled or IsEspLineEnabled or IsEspHealthBarEnabled
    if isAnyEspActive and not EspRenderConnection then
        EspRenderConnection = RunService.RenderStepped:Connect(UpdateESP)
    elseif not isAnyEspActive and EspRenderConnection then
        cleanupAllESP() -- Fungsi ini juga Disconnect
    end
end

-- Fungsi Toggle untuk setiap fitur
local function ToggleESPName(enabled)
    IsEspNameEnabled = enabled
    manageEspConnection()
end

local function ToggleESPBody(enabled)
    IsEspBodyEnabled = enabled
    manageEspConnection()
end

local function ToggleESPLine(enabled)
    IsEspLineEnabled = enabled
    manageEspConnection()
end

-- Fungsi Toggle Baru untuk Health Bar
local function ToggleESPHealthBar(enabled)
    IsEspHealthBarEnabled = enabled
    manageEspConnection()
end

-- ====================================================================
-- == BAGIAN PEMBUATAN GUI (DISALIN DARI FILE ASLI)                  ==
-- ====================================================================

-- [[ FUNGSI DRAGGABLE YANG DI-REFACTOR ]] --
local function MakeDraggable(guiObject, dragHandle)
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if not (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then return end
        dragInput = input
        dragStart = input.Position
        startPos = guiObject.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local newPos = input.Position
            local delta = newPos - dragStart
            guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragInput and input.UserInputType == dragInput.UserInputType then
            dragInput = nil
        end
    end)
end

-- Fungsi pembuat elemen UI
local function createToggle(parent, name, initialState, callback)
    local toggleFrame = Instance.new("Frame", parent); toggleFrame.Size = UDim2.new(1, 0, 0, 25); toggleFrame.BackgroundTransparency = 1; local toggleLabel = Instance.new("TextLabel", toggleFrame); toggleLabel.Size = UDim2.new(0.8, -10, 1, 0); toggleLabel.Position = UDim2.new(0, 5, 0, 0); toggleLabel.BackgroundTransparency = 1; toggleLabel.Text = name; toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); toggleLabel.TextSize = 12; toggleLabel.TextXAlignment = Enum.TextXAlignment.Left; toggleLabel.Font = Enum.Font.SourceSans
    local switch = Instance.new("TextButton", toggleFrame); switch.Name = "Switch"; switch.Size = UDim2.new(0, 40, 0, 20); switch.Position = UDim2.new(1, -50, 0.5, -10); switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50); switch.BorderSizePixel = 0; switch.Text = ""; local switchCorner = Instance.new("UICorner", switch); switchCorner.CornerRadius = UDim.new(1, 0)
    local thumb = Instance.new("Frame", switch); thumb.Name = "Thumb"; thumb.Size = UDim2.new(0, 16, 0, 16); thumb.Position = UDim2.new(0, 2, 0.5, -8); thumb.BackgroundColor3 = Color3.fromRGB(220, 220, 220); thumb.BorderSizePixel = 0; local thumbCorner = Instance.new("UICorner", thumb); thumbCorner.CornerRadius = UDim.new(1, 0)
    local onColor, offColor = Color3.fromRGB(0, 150, 255), Color3.fromRGB(60, 60, 60); local onPosition, offPosition = UDim2.new(1, -18, 0.5, -8), UDim2.new(0, 2, 0.5, -8); local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out); local isToggled = initialState
    local function updateVisuals(isInstant) local goalPosition, goalColor = isToggled and onPosition or offPosition, isToggled and onColor or offColor; if isInstant then thumb.Position, switch.BackgroundColor3 = goalPosition, goalColor else TweenService:Create(thumb, tweenInfo, {Position = goalPosition}):Play(); TweenService:Create(switch, tweenInfo, {BackgroundColor3 = goalColor}):Play() end end
    switch.MouseButton1Click:Connect(function() isToggled = not isToggled; updateVisuals(false); callback(isToggled) end); updateVisuals(true)
    return toggleFrame, switch
end

-- GUI Utama
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArexansESPGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10

-- Frame GUI utama
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 280) 
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -140) 
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
MainFrame.Visible = true 

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 8)
MainUICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 150, 255)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.5
UIStroke.Parent = MainFrame

local TitleBar = Instance.new("TextButton")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Text = ""
TitleBar.AutoButtonColor = false
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 14
TitleLabel.Parent = TitleBar
TitleLabel.Text = "Arexans ESP" 
TitleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Tombol Close (X)
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -25, 0.5, -10)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local TabsFrame = Instance.new("ScrollingFrame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(0, 60, 1, -30) 
TabsFrame.Position = UDim2.new(0, 0, 0, 30) 
TabsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabsFrame.BorderSizePixel = 0
TabsFrame.Parent = MainFrame
TabsFrame.ScrollingDirection = Enum.ScrollingDirection.Y
TabsFrame.ScrollBarThickness = 0

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Name = "TabListLayout"
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
TabListLayout.FillDirection = Enum.FillDirection.Vertical
TabListLayout.Parent = TabsFrame

local TabPadding = Instance.new("UIPadding", TabsFrame)
TabPadding.PaddingTop = UDim.new(0, 5)
TabPadding.PaddingBottom = UDim.new(0, 5)

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -60, 1, -30) 
ContentFrame.Position = UDim2.new(0, 60, 0, 30) 
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Hanya buat frame konten untuk "Umum"
local GeneralTabContent = Instance.new("ScrollingFrame")
GeneralTabContent.Name = "GeneralTab"
GeneralTabContent.Size = UDim2.new(1, -10, 1, -10)
GeneralTabContent.Position = UDim2.new(0, 5, 0, 5)
GeneralTabContent.BackgroundTransparency = 1
GeneralTabContent.Visible = true 
GeneralTabContent.CanvasSize = UDim2.new(0, 0, 0, 0) 
GeneralTabContent.ScrollBarThickness = 4
GeneralTabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
GeneralTabContent.ElasticBehavior = Enum.ElasticBehavior.Never
GeneralTabContent.VerticalScrollBarInset = Enum.ScrollBarInset.Always
GeneralTabContent.ScrollingDirection = Enum.ScrollingDirection.Y
GeneralTabContent.Parent = ContentFrame

local GeneralListLayout = Instance.new("UIListLayout")
GeneralListLayout.Padding = UDim.new(0, 5)
GeneralListLayout.Parent = GeneralTabContent

-- Atur CanvasSize
local function setupCanvasSize(listLayout, scrollingFrame)
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
end
setupCanvasSize(GeneralListLayout, GeneralTabContent)

-- Fungsi untuk membuat tombol Tab
local function createTabButton(name, parent)
    local button = Instance.new("TextButton"); button.Size = UDim2.new(1, 0, 0, 25); button.BackgroundColor3 = Color3.fromRGB(30, 30, 30); button.BorderSizePixel = 0; button.Text = name; button.TextColor3 = Color3.fromRGB(255, 255, 255); button.TextSize = 12; button.Font = Enum.Font.SourceSansSemibold; button.Parent = parent; local btnCorner = Instance.new("UICorner", button); btnCorner.CornerRadius = UDim.new(0, 5);
    
    button.MouseButton1Click:Connect(function()
        for _, btn in ipairs(parent:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        GeneralTabContent.Visible = true
    end)
    return button
end

-- Buat tombol tab "Umum"
local GeneralTabButton = createTabButton("Umum", TabsFrame)
GeneralTabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)


-- ====================================================================
-- == BAGIAN PENGATURAN KONTEN TAB                                  ==
-- ====================================================================

local function setupGeneralTab()
    createToggle(GeneralTabContent, "ESP Nama & Jarak", IsEspNameEnabled, ToggleESPName) -- Nama dikembalikan
    createToggle(GeneralTabContent, "ESP Health Bar", IsEspHealthBarEnabled, ToggleESPHealthBar) -- TOGGLE TERPISAH
    createToggle(GeneralTabContent, "ESP Tubuh", IsEspBodyEnabled, ToggleESPBody)
    createToggle(GeneralTabContent, "ESP Garis", IsEspLineEnabled, ToggleESPLine)
end

-- =================================================================================
-- == BAGIAN UTAMA DAN KONEKSI EVENT                                              ==
-- =================================================================================

-- Panggil fungsi untuk mengisi tab "Umum"
setupGeneralTab()

-- Buat GUI dapat digeser
MakeDraggable(MainFrame, TitleBar)

-- Fungsi untuk menutup skrip
local function CloseScript()
    cleanupAllESP() 
    
    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
end

-- Hubungkan tombol Close (X)
CloseButton.MouseButton1Click:Connect(CloseScript)

-- Hubungkan event PlayerRemoving untuk membersihkan cache
Players.PlayerRemoving:Connect(function(player)
    cleanupPlayerESP(player.UserId) -- Gunakan fungsi cleanup yang baru
end)

