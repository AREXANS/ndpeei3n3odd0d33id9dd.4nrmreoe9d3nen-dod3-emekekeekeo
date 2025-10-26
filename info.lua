--[[
    Script: Halaman Info & Update untuk Arexanstools (Versi Revisi Tema Biru)
    Deskripsi: Menampilkan jendela pop-up dengan pemberitahuan update dan daftar fitur.
    Perubahan (Tema Biru):
    - Seluruh UI diubah menjadi tema biru yang transparan dan modern.
    - Semua warna teks diubah menjadi variasi biru agar serasi.
    - Ukuran jendela diperkecil dan jarak antar elemen dirapatkan agar lebih rapi dan ringkas.
]]

-- Mencegah GUI dibuat berulang kali jika skrip dieksekusi lebih dari sekali.
if game:GetService("CoreGui"):FindFirstChild("ArexanstoolsInfoGUI") then
    game:GetService("CoreGui"):FindFirstChild("ArexanstoolsInfoGUI"):Destroy()
end

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ====================================================================
-- == DATA UPDATE BARU                                             ==
-- ====================================================================
local UPDATE_INFO = {
    Title = "✨ Update Arexans Tools V5.4 ✨",
    Changes = {
        "- Tab Game",
        "- Fitur terbaru Game Perang",
        "- Ganti slider menjadi textbox",
        "- Fix error Kunci Kecepatan"
    }
}

-- ====================================================================
-- == DATA FITUR (Daftar Lengkap dari Arexanstools.lua)             ==
-- ====================================================================
local FEATURES = {
    {
        Tab = "🔥 Player",
        Items = {
            "**Daftar Pemain & Pencarian**: Fungsi: Menampilkan daftar semua pemain yang sedang online di server. Terdapat bar pencarian untuk menemukan pemain spesifik dengan cepat berdasarkan nama atau display name mereka. Detail: Di samping nama setiap pemain, terdapat informasi jarak (dalam meter) dari Anda ke pemain tersebut.",
            "**Refresh List (Ikon 🔄)**: Fungsi: Mengklik ikon panah berputar ini akan memperbarui daftar pemain secara manual. Berguna jika ada pemain baru masuk atau keluar server.",
            "**Spectate / Mata-matai (Ikon Avatar Pemain)**: Fungsi: Dengan mengklik gambar avatar seorang pemain, Anda akan masuk ke mode penonton (spectator). Kamera Anda akan mengikuti pergerakan pemain tersebut, seolah-olah Anda melihat dari sudut pandang mereka. Selama mode ini, karakter Anda akan disembunyikan dan dipindahkan ke lokasi yang aman. Kontrol Spectate: Saat memata-matai, akan muncul bar di bagian bawah layar dengan nama pemain yang sedang diamati. Anda bisa menekan tombol < atau > untuk beralih memata-matai pemain lain, atau klik nama pemain tersebut untuk berhenti.",
            "**Teleport (Ikon 🌀)**: Fungsi: Mengklik ikon teleport ini akan langsung memindahkan karakter Anda ke posisi pemain yang dipilih.",
            "**Fling (Ikon ☠️)**: Fungsi: Mengaktifkan mode \"fling\" pada pemain target. Karakter Anda akan menabrak target berulang kali dengan kecepatan sangat tinggi, membuat mereka terpental tak terkendali. Fitur ini akan terus aktif sampai Anda mengklik kembali ikon tengkorak tersebut atau menekan bar status \"Hentikan Fling\" yang muncul di atas layar.",
            "**Copy Movement (Ikon 👯)**: Fungsi: Meniru semua gerakan dan animasi pemain yang dipilih secara real-time. Karakter Anda akan berlari, melompat, dan menggunakan animasi yang sama persis dengan target. Fitur ini aktif/nonaktif dengan mengklik ikon orang kembar."
        }
    },
    {
        Tab = "⚙️ Umum (General)",
        Items = {
            "**ESP Nama & ESP Tubuh (Wallhack)**: Fungsi: Extra Sensory Perception memungkinkan Anda melihat pemain lain menembus objek seperti dinding. ESP Nama: Menampilkan nama dan jarak pemain di atas kepala mereka. ESP Tubuh: Memberikan sorotan (highlight) berwarna pada seluruh tubuh karakter pemain. Detail: Pemain satu tim akan berwarna hijau, sedangkan pemain lain (musuh/netral) akan berwarna biru.",
            "**WalkSpeed / Kecepatan Jalan**: Fungsi: Mengatur kecepatan berjalan karakter Anda menggunakan slider. Anda harus mengaktifkan toggle \"Jalan Cepat\" agar kecepatan yang diatur pada slider diterapkan.",
            "**Fly / Terbang**: Fungsi: Mengaktifkan mode terbang. Kontrol (PC): Gunakan tombol W, A, S, D untuk bergerak maju/kiri/mundur/kanan, E untuk naik, dan Q untuk turun. Kecepatan terbang bisa diatur melalui slider. Kontrol (Mobile): Gunakan joystick di layar untuk bergerak.",
            "**Noclip**: Fungsi: Memungkinkan karakter Anda menembus semua objek solid seperti dinding, lantai, dan bangunan.",
            "**Infinity Jump**: Fungsi: Anda bisa melompat berkali-kali di udara tanpa perlu menyentuh tanah.",
            "**God Mode (Mode Kebal)**: Fungsi: Karakter Anda tidak akan bisa mati. Jika darah Anda mencapai 0, akan langsung terisi kembali penuh.",
            "**FE Invisible**: Fungsi: Filtering Enabled Invisible. Membuat karakter Anda menjadi transparan (sulit dilihat) oleh pemain lain. Anda bisa mengatur tingkat transparansi melalui slider.",
            "**Touch Fling**: Fungsi: Membuka jendela kecil untuk mengaktifkan/menonaktifkan fitur \"fling sentuh\". Jika aktif, setiap pemain yang Anda sentuh akan terpental dengan keras.",
            "**Anti-Fling**: Fungsi: Melindungi Anda dari fitur Fling milik pemain lain. Jika script mendeteksi karakter Anda bergerak dengan kecepatan tidak wajar (karena dilempar), posisi Anda akan direset ke lokasi aman terakhir.",
            "**Magnet**: Fungsi: Membuka jendela GUI Magnet. Anda bisa memindai (scan) objek-objek lepas (unanchored parts) di sekitar Anda dalam radius tertentu, lalu menariknya ke arah Anda atau membuatnya mengorbit secara acak. Kekuatan tarikan juga bisa diatur.",
            "**Part Controller**: Fungsi: Mirip dengan Magnet, namun jauh lebih canggih. Anda bisa mengumpulkan ratusan objek di sekitar dan mengontrolnya untuk membuat berbagai formasi seperti Tornado, Blackhole, Shield, Wave, dan banyak lagi."
        }
    },
    {
        Tab = "🌀 Teleport",
        Items = {
            "**Pindai Map**: Secara otomatis mencari objek di map yang namanya mengandung kata kunci seperti \"checkpoint\", \"finish\", atau \"start\", lalu menyimpannya sebagai lokasi teleport.",
            "**Simpan Lokasi Saat Ini**: Menyimpan posisi Anda saat ini sebagai titik teleport baru dengan nama \"Kustom [nomor]\".",
            "**Impor/Ekspor**: Ekspor: Menyalin semua data lokasi teleport Anda ke clipboard untuk dibagikan. Impor: Membuka jendela untuk menempelkan (paste) data lokasi dari orang lain.",
            "**Auto Loop Teleport**: Membuka menu kecil untuk teleportasi otomatis. Anda bisa mengatur jumlah pengulangan (0 untuk tak terbatas) dan jeda waktu antar teleportasi. Script akan teleportasi ke semua lokasi yang tersimpan secara berurutan.",
            "**Ikon pada Daftar Lokasi**: 👁️ (Spectate): Melihat pratinjau lokasi sebelum berteleportasi. Anda bisa terbang bebas di sekitar lokasi untuk memeriksanya. R (Rename): Mengganti nama lokasi yang tersimpan. X (Delete): Menghapus lokasi dari daftar."
        }
    },
    {
        Tab = "🎥 Rekaman (Recording)",
        Items = {
            "**Rekam Gerakan (Ikon 🔴 / ⏹️)**: Fungsi: Mulai merekam pergerakan Anda sendiri atau pemain lain (jika sedang spectate). Tombol akan berubah menjadi kotak (⏹️) selama merekam. Klik lagi untuk berhenti dan menyimpan rekaman.",
            "**Impor (Ikon 📥) & Ekspor (Ikon 📤)**: Fungsi: Memungkinkan Anda menyimpan rekaman yang dipilih ke dalam sebuah file di folder ArexansTools/Rekaman, atau mengimpor file rekaman dari folder tersebut. Sangat berguna untuk berbagi gerakan kompleks dengan orang lain.",
            "**Putar Rekaman (Ikon ▶️ / ⏸️)**: Fungsi: Memutar rekaman yang telah dipilih dari daftar. Jika ada lebih dari satu rekaman yang dipilih, semua akan diputar secara berurutan (sekuens). Saat pemutaran berlangsung, tombol berubah menjadi jeda (⏸️).",
            "**Hentikan Rekaman (Ikon ⏹️)**: Fungsi: Menghentikan semua proses pemutaran rekaman.",
            "**Pilih Semua (Ikon ☑️)**: Fungsi: Memilih atau membatalkan pilihan semua rekaman di daftar.",
            "**Hapus Pilihan (Ikon 🗑️)**: Fungsi: Menghapus semua rekaman yang sedang dipilih secara permanen.",
            "**Jumlah Ulang (Looping)**: Anda bisa menentukan berapa kali sekuens rekaman akan diulang. Isi dengan 0 untuk pengulangan tanpa batas (infinity).",
            "**Bypass Animasi**: Jika diaktifkan, saat memutar rekaman, karakter Anda akan menggunakan set animasi (berjalan, berlari, lompat) yang sudah Anda atur di tab VIP, bukan animasi asli dari rekaman."
        }
    },
    {
        Tab = "⭐ VIP",
        Items = {
            "**Emote VIP (Ikon 🤡)**: Fungsi: Mengaktifkan/menonaktifkan tombol akses cepat ke menu Emote. Menu ini berisi ratusan emote yang bisa Anda gunakan. Terdapat fitur pencarian dan favorit (ikon ♥️).",
            "**Animasi VIP (Ikon 😀)**: Fungsi: Mengaktifkan/menonaktifkan tombol akses cepat ke menu Animasi. Di sini Anda bisa mengubah paket animasi karakter Anda (berjalan, berlari, melompat, jatuh, dll) menjadi paket animasi populer seperti Rthro, Toy, Superhero, dll.",
            "**GUI Transparan**: Opsi untuk membuat jendela Emote dan Animasi menjadi tembus pandang agar tidak terlalu mengganggu pemandangan."
        }
    },
    {
        Tab = "🔧 Pengaturan (Settings)",
        Items = {
            "**Kunci Posisi UI**: Mengunci posisi bar tombol di sisi kanan layar agar tidak bisa digeser-geser.",
            "**Simpan Posisi UI**: Menyimpan posisi semua jendela (menu utama, emote, animasi, dll) sehingga saat Anda membuka script lagi, posisinya akan sama seperti terakhir kali Anda atur.",
            "**Hop Server**: Pindah ke server publik lain secara acak di game yang sama.",
            "**Anti-Lag**: Menonaktifkan partikel, bayangan, dan efek-efek visual lain yang tidak penting untuk meningkatkan performa.",
            "**Boost FPS**: Opsi optimisasi yang lebih agresif dari Anti-Lag, menyederhanakan lebih banyak elemen visual untuk mendapatkan FPS semaksimal mungkin.",
            "**Optimized Game**: Mode optimisasi paling ekstrem. Menyembunyikan objek-objek dekoratif seperti pohon dan rumput, serta menonaktifkan efek-efek berat lainnya.",
            "**Dark Texture**: Mengubah semua tekstur dan warna di dalam game menjadi abu-abu gelap. Berguna untuk mengurangi silau atau untuk fokus pada gameplay.",
            "**Shift Lock**: Mengunci rotasi karakter agar selalu menghadap ke arah kamera, mirip dengan fitur Shift Lock bawaan Roblox.",
            "**Logout & Tutup**: Logout: Keluar dari sesi Anda, menghapus data login. Anda perlu memasukkan password lagi saat membuka script kembali. Tutup: Mematikan semua fitur dan menutup script sepenuhnya."
        }
    }
}

-- ====================================================================
-- == FUNGSI PEMBUATAN GUI                                         ==
-- ====================================================================
local function MakeDraggable(guiObject, dragHandle)
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
            dragStart = input.Position
            startPos = guiObject.Position
        end
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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ArexanstoolsInfoGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999 

-- UKURAN DIPERKECIL
local mainFrameSize = Vector2.new(280, 350) 
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, mainFrameSize.X, 0, mainFrameSize.Y)
MainFrame.Position = UDim2.new(0.5, -mainFrameSize.X/2, 0.5, -mainFrameSize.Y/2)
-- WARNA DIUBAH MENJADI BIRU TRANSPARAN
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 50, 90)
MainFrame.BackgroundTransparency = 0.7
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(0, 170, 255)
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.4

local TitleBar = Instance.new("TextButton")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 28) -- Title bar lebih kecil
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 40, 75)
TitleBar.BackgroundTransparency = 0.6
TitleBar.Text = ""
TitleBar.AutoButtonColor = false
TitleBar.Parent = MainFrame

MakeDraggable(MainFrame, TitleBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.SourceSansSemibold
TitleLabel.Text = "Arexanstools - Info & Update"
TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255) -- Teks biru
TitleLabel.TextSize = 14 -- Ukuran teks diperkecil
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 22, 0, 22)
CloseButton.Position = UDim2.new(1, -26, 0.5, -11)
CloseButton.BackgroundColor3 = Color3.fromRGB(15, 40, 75) -- Tombol biru
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextColor3 = Color3.fromRGB(150, 200, 255) -- Teks biru
CloseButton.TextSize = 12 
CloseButton.Parent = TitleBar
local cbCorner = Instance.new("UICorner", CloseButton)
cbCorner.CornerRadius = UDim.new(0, 6)

-- Efek hover biru
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 170, 255), TextColor3 = Color3.fromRGB(15, 40, 75)}):Play()
end)
CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 40, 75), TextColor3 = Color3.fromRGB(150, 200, 255)}):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -10, 1, -33)
ContentFrame.Position = UDim2.new(0, 5, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 5
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
ContentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout", ContentFrame)
UIListLayout.Padding = UDim.new(0, 4) -- Sedikit merapatkan jarak antar elemen
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- PANEL NOTIFIKASI UPDATE DENGAN TEMA BIRU
local UpdateFrame = Instance.new("Frame")
UpdateFrame.Name = "UpdateFrame"
UpdateFrame.BackgroundColor3 = Color3.fromRGB(25, 60, 100)
UpdateFrame.BackgroundTransparency = 0.5
UpdateFrame.BorderSizePixel = 0
UpdateFrame.Size = UDim2.new(1, 0, 0, 100) 
UpdateFrame.AutomaticSize = Enum.AutomaticSize.Y
UpdateFrame.LayoutOrder = 0
UpdateFrame.Parent = ContentFrame

local ufCorner = Instance.new("UICorner", UpdateFrame)
ufCorner.CornerRadius = UDim.new(0, 6)
local ufStroke = Instance.new("UIStroke", UpdateFrame)
ufStroke.Color = Color3.fromRGB(0, 200, 255) -- Stroke biru
ufStroke.Thickness = 1
ufStroke.Transparency = 0.3

local ufListLayout = Instance.new("UIListLayout", UpdateFrame)
ufListLayout.Padding = UDim.new(0, 2)
ufListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local ufPadding = Instance.new("UIPadding", UpdateFrame)
ufPadding.PaddingTop = UDim.new(0, 3)
ufPadding.PaddingBottom = UDim.new(0, 3)
ufPadding.PaddingLeft = UDim.new(0, 4)
ufPadding.PaddingRight = UDim.new(0, 4)

local UpdateTitle = Instance.new("TextLabel")
UpdateTitle.Name = "UpdateTitle"
UpdateTitle.Size = UDim2.new(1, 0, 0, 20)
UpdateTitle.BackgroundTransparency = 1
UpdateTitle.Font = Enum.Font.SourceSansBold
UpdateTitle.Text = UPDATE_INFO.Title
UpdateTitle.TextColor3 = Color3.fromRGB(0, 200, 255) -- Teks biru
UpdateTitle.TextSize = 15
UpdateTitle.Parent = UpdateFrame

for _, change in ipairs(UPDATE_INFO.Changes) do
    local ChangeLabel = Instance.new("TextLabel")
    ChangeLabel.Name = "ChangeLabel"
    -- [PERBAIKAN] Ukuran disesuaikan dengan padding & tinggi otomatis agar teks tidak terpotong.
    ChangeLabel.Size = UDim2.new(1, -8, 0, 0)
    ChangeLabel.BackgroundTransparency = 1
    ChangeLabel.Font = Enum.Font.SourceSans
    ChangeLabel.Text = change
    ChangeLabel.TextColor3 = Color3.fromRGB(180, 210, 255) -- Teks biru
    ChangeLabel.TextSize = 12
    ChangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    ChangeLabel.TextWrapped = true -- [PERBAIKAN] Aktifkan TextWrapped agar teks turun baris
    ChangeLabel.AutomaticSize = Enum.AutomaticSize.Y -- [PERBAIKAN] Aktifkan tinggi otomatis
    ChangeLabel.Parent = UpdateFrame
end

-- Masukkan semua fitur ke dalam ContentFrame
for i, category in ipairs(FEATURES) do
    local TabLabel = Instance.new("TextLabel")
    TabLabel.Name = category.Tab .. "Label"
    TabLabel.Size = UDim2.new(1, 0, 0, 22)
    TabLabel.BackgroundTransparency = 1
    TabLabel.Font = Enum.Font.SourceSansBold
    TabLabel.Text = " " .. category.Tab
    TabLabel.TextColor3 = Color3.fromRGB(150, 200, 255) -- Teks biru
    TabLabel.TextSize = 15
    TabLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabLabel.LayoutOrder = (i * 100)
    TabLabel.Parent = ContentFrame
    
    local divider = Instance.new("Frame", ContentFrame)
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = Color3.fromRGB(0, 170, 255) -- Garis biru
    divider.BackgroundTransparency = 0.7
    divider.BorderSizePixel = 0
    divider.LayoutOrder = (i * 100) + 1

    for j, item in ipairs(category.Items) do
        local FeatureLabel = Instance.new("TextLabel")
        FeatureLabel.Name = "Feature" .. i .. "-" .. j
        -- [PERBAIKAN] Tinggi awal diatur ke 0 agar AutomaticSize bisa menyesuaikan dengan rapat.
        FeatureLabel.Size = UDim2.new(1, -10, 0, 0)
        FeatureLabel.Position = UDim2.new(0, 5, 0, 0)
        FeatureLabel.BackgroundTransparency = 1
        FeatureLabel.Font = Enum.Font.SourceSans
        
        local formattedText = item:gsub("%*%*(.-)%*%*", "<b>%1</b>")
        FeatureLabel.Text = "  •  " .. formattedText
        
        FeatureLabel.RichText = true
        FeatureLabel.TextColor3 = Color3.fromRGB(180, 210, 255) -- Teks biru
        FeatureLabel.TextSize = 12
        FeatureLabel.TextXAlignment = Enum.TextXAlignment.Left
        FeatureLabel.TextWrapped = true
        FeatureLabel.AutomaticSize = Enum.AutomaticSize.Y
        FeatureLabel.LayoutOrder = (i * 100) + j + 2
        FeatureLabel.Parent = ContentFrame
    end
end

task.wait(0.1)
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)

-- Animasi saat muncul
MainFrame.Size = UDim2.new(0,0,0,0)
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
local tweenIn = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, mainFrameSize.X, 0, mainFrameSize.Y),
    Position = UDim2.new(0.5, -mainFrameSize.X/2, 0.5, -mainFrameSize.Y/2)
})
tweenIn:Play()
