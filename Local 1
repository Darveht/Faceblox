-- FaceBlox_Client_01_UI
-- Parte 1: creación completa de la UI y variables globales de estado (sin lógica de remotes).
-- Este script crea exactamente la interfaz que tenías en tu Local original.

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Desactivar controles de CoreGui
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCore("ResetButtonCallback", false)

-- Desactivar movimiento del jugador (PlatformStand)
wait(1)
if player.Character and player.Character:FindFirstChild("Humanoid") then
    pcall(function() player.Character.Humanoid.PlatformStand = true end)
    end
        player.CharacterAdded:Connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.PlatformStand = true
        end)
        
        -- Variables de estado (exportadas vía _G)
        _G.FaceBlox = _G.FaceBlox or {}
        _G.FaceBlox.state = _G.FaceBlox.state or {}
        local state = _G.FaceBlox.state
        
        state.currentView = "feed"
        state.currentProfileId = player.UserId
        state.currentPostId = nil
        state.selectedMusicId = ""
        state.postWidgets = {}
        state.commentWidgets = {}
        state.availableMusic = { -- vacía por defecto; la llenará servidor o admin más tarde
        -- {id="...", title="..."}, etc.
        }
        
        -- Crear ScreenGui principal
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FaceBloxGui"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = playerGui
        
        -- Frame principal
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(1, 0, 1, 0)
        mainFrame.Position = UDim2.new(0, 0, 0, 0)
        mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        
        -- Header con gradiente
        local headerFrame = Instance.new("Frame")
        headerFrame.Name = "HeaderFrame"
        headerFrame.Size = UDim2.new(1, 0, 0, 60)
        headerFrame.Position = UDim2.new(0, 0, 0, 0)
        headerFrame.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
        headerFrame.BorderSizePixel = 0
        headerFrame.Parent = mainFrame
        
        local headerGradient = Instance.new("UIGradient")
        headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 89, 152)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 70, 120))
        }
        headerGradient.Rotation = 90
        headerGradient.Parent = headerFrame
        
        -- Logo
        local logoLabel = Instance.new("TextLabel")
        logoLabel.Name = "LogoLabel"
        logoLabel.Size = UDim2.new(0, 150, 1, 0)
        logoLabel.Position = UDim2.new(0, 10, 0, 0)
        logoLabel.BackgroundTransparency = 1
        logoLabel.Text = "FaceBlox"
        logoLabel.TextColor3 = Color3.new(1, 1, 1)
        logoLabel.TextScaled = true
        logoLabel.Font = Enum.Font.SourceSansBold
        logoLabel.Parent = headerFrame
        
        -- Search box (solo visible en descubrir)
        local searchFrame = Instance.new("Frame")
        searchFrame.Name = "SearchFrame"
        searchFrame.Size = UDim2.new(0, 250, 0, 35)
        searchFrame.Position = UDim2.new(0.5, -125, 0.5, -17)
        searchFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        searchFrame.BorderSizePixel = 0
        searchFrame.Visible = false
        searchFrame.Parent = headerFrame
        
        local searchCorner = Instance.new("UICorner")
        searchCorner.CornerRadius = UDim.new(0, 17)
        searchCorner.Parent = searchFrame
        
        local searchBox = Instance.new("TextBox")
        searchBox.Name = "SearchBox"
        searchBox.Size = UDim2.new(1, -10, 1, 0)
        searchBox.Position = UDim2.new(0, 5, 0, 0)
        searchBox.BackgroundTransparency = 1
        searchBox.Text = ""
        searchBox.PlaceholderText = "Buscar usuarios..."
        searchBox.TextColor3 = Color3.fromRGB(50, 50, 50)
        searchBox.TextScaled = true
        searchBox.Font = Enum.Font.SourceSans
        searchBox.Parent = searchFrame
        
        local searchIndicator = Instance.new("TextLabel")
        searchIndicator.Name = "SearchIndicator"
        searchIndicator.Size = UDim2.new(0, 200, 0, 30)
        searchIndicator.Position = UDim2.new(0.5, -100, 1, 5)
        searchIndicator.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
        searchIndicator.BorderSizePixel = 0
        searchIndicator.Text = "🔍 Buscando..."
        searchIndicator.TextColor3 = Color3.new(0, 0, 0)
        searchIndicator.Font = Enum.Font.SourceSansBold
        searchIndicator.TextSize = 14
        searchIndicator.Visible = false
        searchIndicator.Parent = searchFrame
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 8)
        indicatorCorner.Parent = searchIndicator
        
        -- Foto de perfil del usuario (clickeable)
        local profileButton = Instance.new("ImageButton")
        profileButton.Name = "ProfileButton"
        profileButton.Size = UDim2.new(0, 45, 0, 45)
        profileButton.Position = UDim2.new(1, -55, 0.5, -22)
        profileButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        profileButton.BorderSizePixel = 0
        profileButton.Image = "rbxasset://textures/face.png"
        profileButton.Parent = headerFrame
        
        local profileCorner = Instance.new("UICorner")
        profileCorner.CornerRadius = UDim.new(0.5, 0)
        profileCorner.Parent = profileButton
        
        -- Botón de vincular perfil
        local linkProfileBtn = Instance.new("TextButton")
        linkProfileBtn.Name = "LinkProfileBtn"
        linkProfileBtn.Size = UDim2.new(0, 20, 0, 20)
        linkProfileBtn.Position = UDim2.new(1, -75, 0.5, -32)
        linkProfileBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
        linkProfileBtn.BorderSizePixel = 0
        linkProfileBtn.Text = "🔗"
        linkProfileBtn.TextColor3 = Color3.new(1, 1, 1)
        linkProfileBtn.Font = Enum.Font.SourceSansBold
        linkProfileBtn.TextSize = 12
        linkProfileBtn.Parent = headerFrame
        
        local linkCorner = Instance.new("UICorner")
        linkCorner.CornerRadius = UDim.new(0.5, 0)
        linkCorner.Parent = linkProfileBtn
        
        -- Badge de verificación del usuario actual
        local verifiedBadge = Instance.new("ImageLabel")
        verifiedBadge.Name = "VerifiedBadge"
        verifiedBadge.Size = UDim2.new(0, 15, 0, 15)
        verifiedBadge.Position = UDim2.new(1, -10, 0, 2)
        verifiedBadge.BackgroundTransparency = 1
        verifiedBadge.Image = "rbxassetid://125268479387354"
        verifiedBadge.ImageColor3 = Color3.fromRGB(29, 161, 242)
        verifiedBadge.Visible = false
        verifiedBadge.Parent = profileButton
        
        -- Contenido principal
        local contentFrame = Instance.new("Frame")
        contentFrame.Name = "ContentFrame"
        contentFrame.Size = UDim2.new(1, 0, 1, -140)
        contentFrame.Position = UDim2.new(0, 0, 0, 60)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Parent = mainFrame
        
        -- MUSIC SELECTION
        local musicSection = Instance.new("ScrollingFrame")
        musicSection.Name = "MusicSection"
        musicSection.Size = UDim2.new(1, -20, 1, 0)
        musicSection.Position = UDim2.new(0, 10, 0, 0)
        musicSection.BackgroundTransparency = 1
        musicSection.BorderSizePixel = 0
        musicSection.Visible = false
        musicSection.Parent = contentFrame
        
        local musicLayout = Instance.new("UIListLayout")
        musicLayout.SortOrder = Enum.SortOrder.LayoutOrder
        musicLayout.Padding = UDim.new(0, 10)
        musicLayout.Parent = musicSection
        
        -- FEED
        local feedScroll = Instance.new("ScrollingFrame")
        feedScroll.Name = "FeedSection"
        feedScroll.Size = UDim2.new(1, -20, 1, 0)
        feedScroll.Position = UDim2.new(0, 10, 0, 0)
        feedScroll.BackgroundTransparency = 1
        feedScroll.BorderSizePixel = 0
        feedScroll.Visible = true
        feedScroll.Parent = contentFrame
        
        local feedLayout = Instance.new("UIListLayout")
        feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
        feedLayout.Padding = UDim.new(0, 10)
        feedLayout.Parent = feedScroll
        
        -- DISCOVER
        local discoverFrame = Instance.new("ScrollingFrame")
        discoverFrame.Name = "DiscoverSection"
        discoverFrame.Size = UDim2.new(1, -20, 1, 0)
        discoverFrame.Position = UDim2.new(0, 10, 0, 0)
        discoverFrame.BackgroundTransparency = 1
        discoverFrame.BorderSizePixel = 0
        discoverFrame.Visible = false
        discoverFrame.Parent = contentFrame
        
        local discoverLayout = Instance.new("UIListLayout")
        discoverLayout.SortOrder = Enum.SortOrder.LayoutOrder
        discoverLayout.Padding = UDim.new(0, 10)
        discoverLayout.Parent = discoverFrame
        
        -- CREATE
        local createFrame = Instance.new("Frame")
        createFrame.Name = "CreateSection"
        createFrame.Size = UDim2.new(1, -20, 1, 0)
        createFrame.Position = UDim2.new(0, 10, 0, 0)
        createFrame.BackgroundTransparency = 1
        createFrame.Visible = false
        createFrame.Parent = contentFrame
        
        -- SETTINGS (PROFILE)
        local settingsFrame = Instance.new("ScrollingFrame")
        settingsFrame.Name = "SettingsSection"
        settingsFrame.Size = UDim2.new(1, -20, 1, 0)
        settingsFrame.Position = UDim2.new(0, 10, 0, 0)
        settingsFrame.BackgroundTransparency = 1
        settingsFrame.BorderSizePixel = 0
        settingsFrame.Visible = false
        settingsFrame.Parent = contentFrame
        
        local settingsLayout = Instance.new("UIListLayout")
        settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        settingsLayout.Padding = UDim.new(0, 15)
        settingsLayout.Parent = settingsFrame
        
        -- COMMENTS SECTION
        local commentsSection = Instance.new("ScrollingFrame")
        commentsSection.Name = "CommentsSection"
        commentsSection.Size = UDim2.new(1, -20, 1, 0)
        commentsSection.Position = UDim2.new(0, 10, 0, 0)
        commentsSection.BackgroundColor3 = Color3.fromRGB(25,25,25)
        commentsSection.Visible = false
        commentsSection.BorderSizePixel = 0
        commentsSection.Parent = contentFrame
        
        local commentsLayout = Instance.new("UIListLayout")
        commentsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        commentsLayout.Padding = UDim.new(0, 10)
        commentsLayout.Parent = commentsSection
        
        -- REPORT SECTION
        local reportSection = Instance.new("Frame")
        reportSection.Name = "ReportSection"
        reportSection.Size = UDim2.new(1, 0, 1, -60)
        reportSection.Position = UDim2.new(0, 0, 0, 0)
        reportSection.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        reportSection.Visible = false
        reportSection.BorderSizePixel = 0
        reportSection.Parent = contentFrame
        
        -- Barra de navegación inferior
        local navBar = Instance.new("Frame")
        navBar.Name = "NavBar"
        navBar.Size = UDim2.new(1, 0, 0, 80)
        navBar.Position = UDim2.new(0, 0, 1, -80)
        navBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        navBar.BorderSizePixel = 0
        navBar.Parent = mainFrame
        
        local navButtons = {
        {name = "Inicio", icon = "🏠", view = "feed"},
        {name = "Descubrir", icon = "🔍", view = "discover"},
        {name = "Crear", icon = "➕", view = "create"},
        {name = "Perfil", icon = "👤", view = "settings"}
        }
        
        local navButtonInstances = {}
        
        -- <<< CREACIÓN COMPLETA DE BOTONES DE NAVEGACIÓN >>>
        for i, buttonData in ipairs(navButtons) do
            local navButton = Instance.new("TextButton")
            navButton.Size = UDim2.new(1/#navButtons, 0, 1, 0)
            navButton.Position = UDim2.new((i-1)/#navButtons, 0, 0, 0)
            navButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            navButton.BorderSizePixel = 0
            navButton.Text = ""
            navButton.Parent = navBar
            
            if buttonData.view == "feed" then
                local icon = Instance.new("ImageLabel")
                icon.Name = "NavIcon"
                icon.Size = UDim2.new(0, 36, 0, 36)
                icon.Position = UDim2.new(0.5, -18, 0, 8)
                icon.BackgroundTransparency = 1
                icon.Image = "rbxassetid://120125722355552"
                icon.Parent = navButton
                local iconCorner = Instance.new("UICorner")
                iconCorner.CornerRadius = UDim.new(0, 8)
                iconCorner.Parent = icon
            else
                local iconLabel = Instance.new("TextLabel")
                iconLabel.Name = "NavIcon"
                iconLabel.Size = UDim2.new(1, 0, 0, 36)
                iconLabel.Position = UDim2.new(0, 0, 0, 8)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Text = buttonData.icon
                iconLabel.TextColor3 = Color3.new(1, 1, 1)
                iconLabel.TextScaled = true
                iconLabel.Font = Enum.Font.SourceSans
                iconLabel.Parent = navButton
            end
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NavLabel"
            nameLabel.Size = UDim2.new(1, 0, 0, 30)
            nameLabel.Position = UDim2.new(0, 0, 0, 50)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = buttonData.name
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.Parent = navButton
            
            navButtonInstances[buttonData.view] = navButton
        end
        -- <<< FIN CREACIÓN NAV >>>
        
        -- Exportar referencias UI y navButtons a _G para que otras partes las usen
        _G.FaceBlox.ui = _G.FaceBlox.ui or {}
        local ui = _G.FaceBlox.ui
        ui.screenGui = screenGui
        ui.mainFrame = mainFrame
        ui.headerFrame = headerFrame
        ui.logoLabel = logoLabel
        ui.searchFrame = searchFrame
        ui.searchBox = searchBox
        ui.searchIndicator = searchIndicator
        ui.profileButton = profileButton
        ui.linkProfileBtn = linkProfileBtn
        ui.verifiedBadge = verifiedBadge
        ui.contentFrame = contentFrame
        ui.feedScroll = feedScroll
        ui.feedLayout = feedLayout
        ui.discoverFrame = discoverFrame
        ui.discoverLayout = discoverLayout
        ui.createFrame = createFrame
        ui.settingsFrame = settingsFrame
        ui.settingsLayout = settingsLayout
        ui.commentsSection = commentsSection
        ui.commentsLayout = commentsLayout
        ui.musicSection = musicSection
        ui.musicLayout = musicLayout
        ui.reportSection = reportSection
        ui.navBar = navBar
        ui.navButtonInstances = navButtonInstances
        
        print("FaceBlox Cliente - Parte 01 (UI) cargada.")
