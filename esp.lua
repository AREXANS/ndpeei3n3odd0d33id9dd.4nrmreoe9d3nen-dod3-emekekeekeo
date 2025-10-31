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

-- [[ PERUBAHAN: Variabel Warna Global ]]
-- Ini adalah warna default yang sekarang bisa diubah oleh slider
local teamColor = Color3.fromRGB(100, 255, 100)
local enemyColor = Color3.fromRGB(0, 150, 255)

-- Default state 'false' agar master switch bisa mengontrolnya
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
                
                -- [[ PERUBAHAN: Menggunakan Variabel Warna Global ]]
                local espColor
                if isTeam then
                    espColor = teamColor -- Menggunakan warna tim dari slider
                else
                    espColor = enemyColor -- Menggunakan warna musuh dari slider
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
-- createToggle now returns 'setToggleState'
local function createToggle(parent, name, initialState, callback)
    local toggleFrame = Instance.new("Frame", parent); toggleFrame.Size = UDim2.new(1, 0, 0, 25); toggleFrame.BackgroundTransparency = 1; local toggleLabel = Instance.new("TextLabel", toggleFrame); toggleLabel.Size = UDim2.new(0.8, -10, 1, 0); toggleLabel.Position = UDim2.new(0, 5, 0, 0); toggleLabel.BackgroundTransparency = 1; toggleLabel.Text = name; toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); toggleLabel.TextSize = 12; toggleLabel.TextXAlignment = Enum.TextXAlignment.Left; toggleLabel.Font = Enum.Font.SourceSans
    local switch = Instance.new("TextButton", toggleFrame); switch.Name = "Switch"; switch.Size = UDim2.new(0, 40, 0, 20); switch.Position = UDim2.new(1, -50, 0.5, -10); switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50); switch.BorderSizePixel = 0; switch.Text = ""; local switchCorner = Instance.new("UICorner", switch); switchCorner.CornerRadius = UDim.new(1, 0)
    local thumb = Instance.new("Frame", switch); thumb.Name = "Thumb"; thumb.Size = UDim2.new(0, 16, 0, 16); thumb.Position = UDim2.new(0, 2, 0.5, -8); thumb.BackgroundColor3 = Color3.fromRGB(220, 220, 220); thumb.BorderSizePixel = 0; local thumbCorner = Instance.new("UICorner", thumb); thumbCorner.CornerRadius = UDim.new(1, 0)
    local onColor, offColor = Color3.fromRGB(0, 150, 255), Color3.fromRGB(60, 60, 60); local onPosition, offPosition = UDim2.new(1, -18, 0.5, -8), UDim2.new(0, 2, 0.5, -8); local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out); local isToggled = initialState
    
    local function updateVisuals(isInstant) local goalPosition, goalColor = isToggled and onPosition or offPosition, isToggled and onColor or offColor; if isInstant then thumb.Position, switch.BackgroundColor3 = goalPosition, goalColor else TweenService:Create(thumb, tweenInfo, {Position = goalPosition}):Play(); TweenService:Create(switch, tweenInfo, {BackgroundColor3 = goalColor}):Play() end end
    
    -- Tambahkan fungsi setter eksternal
    local function setToggleState(newState, runCallback)
        if isToggled == newState then return end -- Hindari update jika state sudah sama
        isToggled = newState
        updateVisuals(false) -- Gunakan tween
        if runCallback and callback then
            callback(isToggled)
        end
    end

    switch.MouseButton1Click:Connect(function() isToggled = not isToggled; updateVisuals(false); if callback then callback(isToggled) end end); updateVisuals(true)
    
    -- Kembalikan setToggleState
    return toggleFrame, switch, setToggleState
end

-- ====================================================================
-- == BAGIAN FUNGSI HSV PICKER (DIPERLUKAN)                          ==
-- ====================================================================

-- [[ FUNGSI UI BARU: createHueSlider ]]
-- Fungsi untuk membuat slider HUE (pelangi)
local function createHueSlider(parent, label, initialVal, callback)
    local sliderHeight = 16
    local thumbSize = 16
    local minVal, maxVal = 0, 1 -- Hue adalah 0-1 (akan ditampilkan sebagai 0-360)
    
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, 0)
    frame.BackgroundTransparency = 1
    
    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(0, 20, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 35, 1, 0)
    valueLabel.Position = UDim2.new(1, -35, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local track = Instance.new("TextButton", frame)
    track.Name = "Track"
    track.Size = UDim2.new(1, -65, 0, sliderHeight / 2)
    track.Position = UDim2.new(0, 25, 0.5, -(sliderHeight/4))
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Latar belakang putih untuk gradien
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(1, 0)
    
    -- Gradien Pelangi
    local gradient = Instance.new("UIGradient", track)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    })

    local thumb = Instance.new("Frame", track)
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
    thumb.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    thumb.BorderSizePixel = 0
    local thumbCorner = Instance.new("UICorner", thumb)
    thumbCorner.CornerRadius = UDim.new(1, 0)

    local currentValue = initialVal

    local function setValue(newValue, fireCallback)
        currentValue = math.clamp(newValue, minVal, maxVal)
        local percentage = (currentValue - minVal) / (maxVal - minVal)
        
        local trackWidth = track.AbsoluteSize.X
        local thumbWidth = thumb.AbsoluteSize.X
        local newThumbX = (trackWidth - thumbWidth) * percentage
        
        thumb.Position = UDim2.new(0, newThumbX, 0.5, -thumbSize/2)
        valueLabel.Text = tostring(math.floor(currentValue * 360)) -- Tampilkan 0-360
        
        if fireCallback and callback then
            callback(currentValue)
        end
    end
    
    local function updateFromInput(input)
        local trackWidth = track.AbsoluteSize.X
        local thumbWidth = thumb.AbsoluteSize.X
        if trackWidth <= thumbWidth then return end 

        local relativeX = input.Position.X - track.AbsolutePosition.X - (thumbWidth / 2)
        local percentage = math.clamp(relativeX / (trackWidth - thumbWidth), 0, 1)
        
        local newValue = minVal + (maxVal - minVal) * percentage
        setValue(newValue, true)
    end
    
    local isDragging = false
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true; updateFromInput(input) end end)
    UserInputService.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateFromInput(input) end end)
    UserInputService.InputEnded:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then isDragging = false end end)
    
    frame.AncestryChanged:Connect(function(_, parent) if parent then RunService.Heartbeat:Wait(); setValue(currentValue, false) end end)
    if frame:IsDescendantOf(game) then RunService.Heartbeat:Wait(); setValue(currentValue, false) end

    return frame, setValue
end

-- [[ FUNGSI UI BARU: createDynamicSlider ]]
-- Fungsi untuk membuat slider S (Saturation) dan V (Value)
-- Slider ini memiliki gradien yang dapat diperbarui
local function createDynamicSlider(parent, label, initialVal, callback)
    local sliderHeight = 16
    local thumbSize = 16
    local minVal, maxVal = 0, 1 -- S dan V adalah 0-1 (akan ditampilkan sebagai 0-100)
    
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.Position = UDim2.new(0, 5, 0, 0)
    frame.BackgroundTransparency = 1
    
    local textLabel = Instance.new("TextLabel", frame)
    textLabel.Size = UDim2.new(0, 20, 1, 0)
    textLabel.Position = UDim2.new(0, 0, 0, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = label
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0, 35, 1, 0)
    valueLabel.Position = UDim2.new(1, -35, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.SourceSans
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local track = Instance.new("TextButton", frame)
    track.Name = "Track"
    track.Size = UDim2.new(1, -65, 0, sliderHeight / 2)
    track.Position = UDim2.new(0, 25, 0.5, -(sliderHeight/4))
    track.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Latar belakang putih
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    local trackCorner = Instance.new("UICorner", track)
    trackCorner.CornerRadius = UDim.new(1, 0)
    
    -- Gradien Dinamis (akan diatur oleh Color Picker Group)
    local gradient = Instance.new("UIGradient", track)
    gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255)) -- Default putih

    local thumb = Instance.new("Frame", track)
    thumb.Name = "Thumb"
    thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
    thumb.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    thumb.BorderSizePixel = 0
    local thumbCorner = Instance.new("UICorner", thumb)
    thumbCorner.CornerRadius = UDim.new(1, 0)

    local currentValue = initialVal

    local function setValue(newValue, fireCallback)
        currentValue = math.clamp(newValue, minVal, maxVal)
        local percentage = (currentValue - minVal) / (maxVal - minVal)
        
        local trackWidth = track.AbsoluteSize.X
        local thumbWidth = thumb.AbsoluteSize.X
        local newThumbX = (trackWidth - thumbWidth) * percentage
        
        thumb.Position = UDim2.new(0, newThumbX, 0.5, -thumbSize/2)
        valueLabel.Text = tostring(math.floor(currentValue * 100)) -- Tampilkan 0-100
        
        if fireCallback and callback then
            callback(currentValue)
        end
    end
    
    local function updateFromInput(input)
        local trackWidth = track.AbsoluteSize.X
        local thumbWidth = thumb.AbsoluteSize.X
        if trackWidth <= thumbWidth then return end 

        local relativeX = input.Position.X - track.AbsolutePosition.X - (thumbWidth / 2)
        local percentage = math.clamp(relativeX / (trackWidth - thumbWidth), 0, 1)
        
        local newValue = minVal + (maxVal - minVal) * percentage
        setValue(newValue, true)
    end
    
    local isDragging = false
    track.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true; updateFromInput(input) end end)
    UserInputService.InputChanged:Connect(function(input) if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateFromInput(input) end end)
    UserInputService.InputEnded:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then isDragging = false end end)
    
    frame.AncestryChanged:Connect(function(_, parent) if parent then RunService.Heartbeat:Wait(); setValue(currentValue, false) end end)
    if frame:IsDescendantOf(game) then RunService.Heartbeat:Wait(); setValue(currentValue, false) end

    -- Fungsi untuk memperbarui gradien slider ini
    local function updateGradient(colorSeq)
        gradient.Color = colorSeq
    end
    
    return frame, setValue, updateGradient
end


-- [[ FUNGSI UI DIGANTI: createHSVColorPickerGroup ]]
-- Fungsi ini menggantikan createColorPickerGroup
-- Menggunakan slider H, S, dan V
local function createHSVColorPickerGroup(parent, title, initialColor, colorChangedCallback)
    local groupFrame = Instance.new("Frame", parent)
    groupFrame.Size = UDim2.new(1, 0, 0, 120) -- 30 (title) + 3*30 (sliders)
    groupFrame.BackgroundTransparency = 1
    
    local groupLayout = Instance.new("UIListLayout", groupFrame)
    groupLayout.Padding = UDim.new(0, 0)
    
    local titleFrame = Instance.new("Frame", groupFrame)
    titleFrame.Size = UDim2.new(1, 0, 0, 30)
    titleFrame.BackgroundTransparency = 1
    
    local titleLabel = Instance.new("TextLabel", titleFrame)
    titleLabel.Size = UDim2.new(0.7, -5, 1, 0)
    titleLabel.Position = UDim2.new(0, 5, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("Frame", titleFrame)
    preview.Size = UDim2.new(0, 50, 0, 20)
    preview.Position = UDim2.new(1, -55, 0.5, -10)
    preview.BackgroundColor3 = initialColor
    preview.BorderSizePixel = 1
    preview.BorderColor3 = Color3.fromRGB(150, 150, 150)
    local previewCorner = Instance.new("UICorner", preview)
    previewCorner.CornerRadius = UDim.new(0, 4)

    -- Konversi Color3 awal ke HSV (Roblox H,S,V adalah 0-1)
    local initialH, initialS, initialV = initialColor:ToHSV()
    
    local currentH, currentS, currentV = initialH, initialS, initialV
    local setSGradient, setVGradient -- Fungsi untuk update gradien slider S dan V

    -- Fungsi untuk update warna akhir
    local function updateColor()
        local newColor = Color3.fromHSV(currentH, currentS, currentV)
        preview.BackgroundColor3 = newColor
        if colorChangedCallback then
            colorChangedCallback(newColor)
        end
    end

    -- Fungsi untuk update gradien slider Saturation
    local function updateSaturationGradient()
        if setSGradient then
            local startColor = Color3.fromHSV(currentH, 0, currentV) -- (Abu-abu/Putih/Hitam)
            local endColor = Color3.fromHSV(currentH, 1, currentV)   -- (Warna Penuh)
            setSGradient(ColorSequence.new(startColor, endColor))
        end
    end

    -- Fungsi untuk update gradien slider Value
    local function updateValueGradient()
        if setVGradient then
            local startColor = Color3.fromHSV(currentH, currentS, 0) -- (Hitam)
            local endColor = Color3.fromHSV(currentH, currentS, 1)   -- (Warna Penuh)
            setVGradient(ColorSequence.new(startColor, endColor))
        end
    end

    -- Buat Slider HUE (H)
    createHueSlider(groupFrame, "H", currentH, function(h)
        currentH = h
        updateColor()
        updateSaturationGradient() -- Perbarui gradien S
        updateValueGradient()      -- Perbarui gradien V
    end)
    
    -- Buat Slider SATURATION (S)
    local sFrame, sSetValue, sSetGradient = createDynamicSlider(groupFrame, "S", currentS, function(s)
        currentS = s
        updateColor()
        updateValueGradient() -- Perbarui gradien V
    end)
    setSGradient = sSetGradient -- Simpan fungsi update gradiennya
    
    -- Buat Slider VALUE (V)
    local vFrame, vSetValue, vSetGradient = createDynamicSlider(groupFrame, "V", currentV, function(v)
        currentV = v
        updateColor()
        updateSaturationGradient() -- Perbarui gradien S
    end)
    setVGradient = vSetGradient -- Simpan fungsi update gradiennya
    
    -- Panggil sekali untuk inisialisasi gradien S dan V
    updateSaturationGradient()
    updateValueGradient()
    
    return groupFrame
end

-- ====================================================================
-- == BAGIAN GUI UTAMA (DIMODIFIKASI)                                ==
-- ====================================================================

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

-- [[ PERUBAHAN: Buat frame konten untuk "Umum" ]]
local GeneralTabContent = Instance.new("ScrollingFrame")
GeneralTabContent.Name = "GeneralTab"
GeneralTabContent.Size = UDim2.new(1, -10, 1, -10)
GeneralTabContent.Position = UDim2.new(0, 5, 0, 5)
GeneralTabContent.BackgroundTransparency = 1
GeneralTabContent.Visible = true -- Tab pertama, jadi terlihat
GeneralTabContent.CanvasSize = UDim2.new(0, 0, 0, 0) 
GeneralTabContent.ScrollBarThickness = 4
GeneralTabContent.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
GeneralTabContent.ElasticBehavior = Enum.ElasticBehavior.Never
GeneralTabContent.VerticalScrollBarInset = Enum.ScrollBarInset.Always
GeneralTabContent.ScrollingDirection = Enum.ScrollingDirection.Y
GeneralTabContent.Parent = ContentFrame

local GeneralListLayout = Instance.new("UIListLayout")
GeneralListLayout.Padding = UDim.new(0, 5)
GeneralListLayout.SortOrder = Enum.SortOrder.LayoutOrder -- Pastikan menggunakan LayoutOrder
GeneralListLayout.Parent = GeneralTabContent

-- [[ BARU: Buat frame KONTEN KEDUA untuk "Warna" (Awalnya tersembunyi) ]]
local ColorSettingsPage = Instance.new("Frame")
ColorSettingsPage.Name = "ColorSettingsPage"
ColorSettingsPage.Size = UDim2.new(1, -10, 1, -10) -- Ukuran sama
ColorSettingsPage.Position = UDim2.new(0, 5, 0, 5)  -- Posisi sama
ColorSettingsPage.BackgroundTransparency = 1
ColorSettingsPage.Visible = false -- Sembunyikan awalnya
ColorSettingsPage.Parent = ContentFrame

-- [[ BARU: Buat Scrolling Frame DI DALAM ColorSettingsPage ]]
local ColorPickerScrollingFrame = Instance.new("ScrollingFrame")
ColorPickerScrollingFrame.Name = "ColorPickerScrollingFrame"
ColorPickerScrollingFrame.Size = UDim2.new(1, 0, 1, 0) -- Isi penuh parent
ColorPickerScrollingFrame.Position = UDim2.new(0, 0, 0, 0)
ColorPickerScrollingFrame.BackgroundTransparency = 1
ColorPickerScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0) 
ColorPickerScrollingFrame.ScrollBarThickness = 4
ColorPickerScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
ColorPickerScrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Never
ColorPickerScrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
ColorPickerScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ColorPickerScrollingFrame.Parent = ColorSettingsPage

local ColorListLayout = Instance.new("UIListLayout")
ColorListLayout.Padding = UDim.new(0, 5)
ColorListLayout.SortOrder = Enum.SortOrder.LayoutOrder -- Pastikan menggunakan LayoutOrder
ColorListLayout.Parent = ColorPickerScrollingFrame

-- Atur CanvasSize untuk kedua list layout
local function setupCanvasSize(listLayout, scrollingFrame)
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)
    -- Panggil sekali untuk inisialisasi jika konten sudah ada
    task.wait()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

setupCanvasSize(GeneralListLayout, GeneralTabContent)
setupCanvasSize(ColorListLayout, ColorPickerScrollingFrame) -- BARU

-- [[ PERUBAHAN: Fungsi untuk membuat tombol Tab ]]
-- Sekarang menerima 'contentFrame' untuk ditampilkan
local function createTabButton(name, parent, contentToShow)
    local button = Instance.new("TextButton"); button.Size = UDim2.new(1, 0, 0, 25); button.BackgroundColor3 = Color3.fromRGB(30, 30, 30); button.BorderSizePixel = 0; button.Text = name; button.TextColor3 = Color3.fromRGB(255, 255, 255); button.TextSize = 12; button.Font = Enum.Font.SourceSansSemibold; button.Parent = parent; local btnCorner = Instance.new("UICorner", button); btnCorner.CornerRadius = UDim.new(0, 5);
    
    button.MouseButton1Click:Connect(function()
        -- 1. Atur warna tombol
        for _, btn in ipairs(parent:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        
        -- 2. Sembunyikan SEMUA frame konten
        for _, frame in ipairs(ContentFrame:GetChildren()) do
            if frame:IsA("ScrollingFrame") or frame.Name == "ColorSettingsPage" then
                frame.Visible = false
            end
        end
        
        -- 3. Tampilkan frame konten yang TEPAT
        contentToShow.Visible = true
    end)
    return button
end

-- [[ PERUBAHAN: Buat tombol tab ]]
local GeneralTabButton = createTabButton("Umum", TabsFrame, GeneralTabContent)
GeneralTabButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255) -- Aktifkan tab pertama secara default

-- Tombol Tab Warna DIHAPUS


-- ====================================================================
-- == BAGIAN PENGATURAN KONTEN TAB                                  ==
-- ====================================================================

-- [[ FUNGSI setupGeneralTab DIMODIFIKASI ]]
-- Mengganti toggle master dengan header yang bisa diciutkan (collapsible)
local function setupGeneralTab()
    local espToggleFrames = {}
    local espSetters = {}
    local isMasterEnabled = false -- State awal (terciut/mati)
    
    -- Fungsi callback ini tetap SAMA, mengontrol visibilitas DAN state anak-anak
    local function MasterToggleCallback(masterState)
        for _, frame in ipairs(espToggleFrames) do
            frame.Visible = masterState
        end
        for _, setter in ipairs(espSetters) do
            setter(masterState, true) -- Ini adalah fungsionalitas MASTER SWITCH
        end
    end
    
    -- [[ BARU: Buat Header Frame ]]
    -- Frame ini hanya sebagai container
    local headerContainer = Instance.new("Frame")
    headerContainer.Name = "MasterHeaderContainer"
    headerContainer.Size = UDim2.new(1, 0, 0, 25)
    headerContainer.Position = UDim2.new(0, 0, 0, 0)
    headerContainer.BackgroundTransparency = 1
    headerContainer.LayoutOrder = 1 -- <<<<<<< PERBAIKAN: Tetapkan urutan 1
    headerContainer.Parent = GeneralTabContent

    -- [[ BARU: Tombol Gear (PINDAH HALAMAN) ]]
    local gearButton = Instance.new("TextButton", headerContainer)
    gearButton.Size = UDim2.new(0, 25, 1, 0)
    gearButton.Position = UDim2.new(0, 3, 0, 0)
    gearButton.BackgroundTransparency = 1
    gearButton.Font = Enum.Font.SourceSans
    gearButton.TextSize = 16
    gearButton.Text = "⚙" -- Icon Gear/Settings
    gearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    gearButton.TextXAlignment = Enum.TextXAlignment.Left
    gearButton.AutoButtonColor = false

    -- [[ BARU: Tombol Ciu/Lebar (Toggle Visibilitas) ]]
    local collapseButton = Instance.new("TextButton", headerContainer)
    collapseButton.Size = UDim2.new(1, -28, 1, 0) -- Isi sisa ruang
    collapseButton.Position = UDim2.new(0, 28, 0, 0)
    collapseButton.BackgroundTransparency = 1
    collapseButton.Text = "" -- Teks akan diisi oleh label
    collapseButton.AutoButtonColor = false

    local titleLabel = Instance.new("TextLabel", collapseButton)
    titleLabel.Size = UDim2.new(1, -25, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSans
    titleLabel.TextSize = 12
    titleLabel.Text = "Tampilkan ESP"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local triangleIcon = Instance.new("TextLabel", collapseButton)
    triangleIcon.Size = UDim2.new(0, 20, 1, 0)
    triangleIcon.Position = UDim2.new(1, -20, 0, 0)
    triangleIcon.BackgroundTransparency = 1
    triangleIcon.Font = Enum.Font.SourceSansBold
    triangleIcon.TextSize = 16
    triangleIcon.Text = "▼" -- State awal (terciut)
    triangleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    triangleIcon.TextXAlignment = Enum.TextXAlignment.Right
    
    -- [[ KONEKSI EVENT BARU ]]
    -- 1. Tombol Gear: Pindah ke Halaman Warna
    gearButton.MouseButton1Click:Connect(function()
        GeneralTabContent.Visible = false
        ColorSettingsPage.Visible = true
    end)
    
    -- 2. Tombol Ciu/Lebar: Tampilkan/Sembunyikan Toggles
    collapseButton.MouseButton1Click:Connect(function()
        isMasterEnabled = not isMasterEnabled -- Balik state
        triangleIcon.Text = isMasterEnabled and "▲" or "▼" -- Update ikon
        MasterToggleCallback(isMasterEnabled) -- Jalankan logika master
    end)
    
    -- [[ Bagian ini SAMA seperti sebelumnya ]]
    -- Anak-anak toggle (sekarang tersembunyi secara default)
    -- **PERHATIKAN: Parentnya adalah GeneralTabContent**
    local nameFrame, _, setNameState = createToggle(GeneralTabContent, "ESP Nama & Jarak", IsEspNameEnabled, ToggleESPName)
    nameFrame.LayoutOrder = 2 -- <<<<<<< PERBAIKAN: Tetapkan urutan 2
    table.insert(espToggleFrames, nameFrame)
    table.insert(espSetters, setNameState)
    
    local healthFrame, _, setHealthState = createToggle(GeneralTabContent, "ESP Health Bar", IsEspHealthBarEnabled, ToggleESPHealthBar)
    healthFrame.LayoutOrder = 2 -- <<<<<<< PERBAIKAN: Tetapkan urutan 2
    table.insert(espToggleFrames, healthFrame)
    table.insert(espSetters, setHealthState)
    
    local bodyFrame, _, setBodyState = createToggle(GeneralTabContent, "ESP Tubuh", IsEspBodyEnabled, ToggleESPBody)
    bodyFrame.LayoutOrder = 2 -- <<<<<<< PERBAIKAN: Tetapkan urutan 2
    table.insert(espToggleFrames, bodyFrame)
    table.insert(espSetters, setBodyState)

    local lineFrame, _, setLineState = createToggle(GeneralTabContent, "ESP Garis", IsEspLineEnabled, ToggleESPLine)
    lineFrame.LayoutOrder = 2 -- <<<<<<< PERBAIKAN: Tetapkan urutan 2
    table.insert(espToggleFrames, lineFrame)
    table.insert(espSetters, setLineState)
    
    -- Panggil sekali untuk mengatur state awal (menyembunyikan anak-anak)
    MasterToggleCallback(isMasterEnabled)
end


-- [[ FUNGSI BARU: setupColorPage ]]
-- Mengisi halaman "Warna" (ColorSettingsPage)
local function setupColorPage()
    local parentFrame = ColorPickerScrollingFrame -- Target parent baru
    
    -- [[ BARU: Tombol Kembali ]]
    local backButton = Instance.new("TextButton", parentFrame)
    backButton.Name = "BackButton"
    backButton.Size = UDim2.new(0, 80, 0, 25)
    backButton.Position = UDim2.new(0, 5, 0, 0) -- Sedikit padding
    backButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    backButton.BorderSizePixel = 0
    backButton.Font = Enum.Font.SourceSansSemibold
    backButton.Text = "< Kembali"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.TextSize = 12
    backButton.LayoutOrder = 1 -- <<<<<<< PERBAIKAN: Tetapkan urutan
    local backCorner = Instance.new("UICorner", backButton)
    backCorner.CornerRadius = UDim.new(0, 4)
    
    backButton.MouseButton1Click:Connect(function()
        ColorSettingsPage.Visible = false
        GeneralTabContent.Visible = true
    end)
    
    -- Pemisah
    local separator1 = Instance.new("Frame", parentFrame)
    separator1.Size = UDim2.new(1, -10, 0, 1)
    separator1.Position = UDim2.new(0, 5, 0, 0)
    separator1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    separator1.BorderSizePixel = 0
    separator1.LayoutOrder = 2 -- <<<<<<< PERBAIKAN: Tetapkan urutan
    
    -- Color Picker untuk TIM
    local teamColorGroup = createHSVColorPickerGroup(parentFrame, "Warna Tim", teamColor, function(newColor)
        teamColor = newColor -- Update variabel global
    end)
    teamColorGroup.LayoutOrder = 3 -- <<<<<<< PERBAIKAN: Tetapkan urutan
    
    -- Pemisah
    local separator2 = Instance.new("Frame", parentFrame)
    separator2.Size = UDim2.new(1, -10, 0, 1)
    separator2.Position = UDim2.new(0, 5, 0, 0)
    separator2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    separator2.BorderSizePixel = 0
    separator2.LayoutOrder = 4 -- <<<<<<< PERBAIKAN: Tetapkan urutan

    -- Color Picker untuk MUSUH
    local enemyColorGroup = createHSVColorPickerGroup(parentFrame, "Warna Musuh", enemyColor, function(newColor)
        enemyColor = newColor -- Update variabel global
    end)
    enemyColorGroup.LayoutOrder = 5 -- <<<<<<< PERBAIKAN: Tetapkan urutan
end

-- =================================================================================
-- == BAGIAN UTAMA DAN KONEKSI EVENT                                              ==
-- =================================================================================

-- Panggil fungsi untuk mengisi tab "Umum"
setupGeneralTab()
-- Panggil fungsi BARU untuk mengisi halaman "Warna"
setupColorPage()

-- Panggil manageEspConnection() sekali di awal
manageEspConnection()

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

