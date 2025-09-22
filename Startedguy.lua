-- FaceBlox Client (completo) - versión con icono "Inicio" usando rbxassetid://120125722355552

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Desactivar controles de movimiento
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
StarterGui:SetCore("ResetButtonCallback", false)

-- Desactivar movimiento del jugador
wait(1)
if player.Character and player.Character:FindFirstChild("Humanoid") then
    player.Character.Humanoid.PlatformStand = true
end
player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.PlatformStand = true
end)

-- Esperar RemoteEvents/Functions
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local createPostEvent = remoteEvents:WaitForChild("CreatePost")
local likePostEvent = remoteEvents:WaitForChild("LikePost")
local commentPostEvent = remoteEvents:WaitForChild("CommentPost")
local followUserEvent = remoteEvents:WaitForChild("FollowUser")
local hideCommentEvent = remoteEvents:WaitForChild("HideComment")

-- Broadcast events (server -> client)
local postCreatedEvent  = remoteEvents:WaitForChild("PostCreated")
local postUpdatedEvent  = remoteEvents:WaitForChild("PostUpdated")
local commentAddedEvent = remoteEvents:WaitForChild("CommentAdded")
local followUpdatedEvent= remoteEvents:WaitForChild("FollowUpdated")
local linkProfileEvent  = remoteEvents:WaitForChild("LinkProfile")
local searchResultsEvent = remoteEvents:WaitForChild("SearchResults")

-- RemoteFunctions
local getFeedFunction = remoteEvents:WaitForChild("GetFeed")
local getProfileFunction = remoteEvents:WaitForChild("GetProfile")
local searchUsersFunction = remoteEvents:WaitForChild("SearchUsers")
local getCommentsFunction = remoteEvents:WaitForChild("GetComments")
local getUserPostsFunction = remoteEvents:WaitForChild("GetUserPosts")
local getRecommendationsFunction = remoteEvents:WaitForChild("GetRecommendations")
local reportUserEvent = remoteEvents:WaitForChild("ReportUser")
local deleteCommentEvent = remoteEvents:WaitForChild("DeleteComment")
local getAdminReportsFunction = remoteEvents:WaitForChild("GetAdminReports")

-- Variables
local currentView = "feed"
local currentProfileId = player.UserId
local currentPostId = nil -- Para comentarios
local screenGui
local mainFrame
local contentFrame
local feedScroll
local discoverFrame
local createFrame
local settingsFrame
local commentsSection
local reportSection
local navButtonInstances = {}
local selectedMusicId = ""
local logoLabel -- Variable para acceder al logo más tarde

-- map de widgets de posts para updates en tiempo real
local postWidgets = {}
local commentWidgets = {} -- Para manejar comentarios

-- Lista de músicas disponibles
local availableMusic = {
{id = "5506713323", title = "Shakira - Waka Waka"},
{id = "1838601604", title = "Brasil Funk"}
}

-- Función para obtener título de música
local function getMusicTitle(musicId)
    for _, music in ipairs(availableMusic) do
        if music.id == musicId then
            return music.title
        end
    end
    return "Música desconocida"
end

-- Crear ScreenGui principal
screenGui = Instance.new("ScreenGui")
screenGui.Name = "FaceBloxGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Frame principal
mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Header con gradiente
local headerFrame = Instance.new("Frame")
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

-- Logo FaceBlox
logoLabel = Instance.new("TextLabel")
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
searchBox.Size = UDim2.new(1, -10, 1, 0)
searchBox.Position = UDim2.new(0, 5, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Buscar usuarios..."
searchBox.TextColor3 = Color3.fromRGB(50, 50, 50)
searchBox.TextScaled = true
searchBox.Font = Enum.Font.SourceSans
searchBox.Parent = searchFrame

-- Indicador de búsqueda
local searchIndicator = Instance.new("TextLabel")
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
profileButton = Instance.new("ImageButton")
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
verifiedBadge.Size = UDim2.new(0, 15, 0, 15)
verifiedBadge.Position = UDim2.new(1, -5, 0, 0)
verifiedBadge.BackgroundTransparency = 1
verifiedBadge.Image = "rbxassetid://125268479387354"
verifiedBadge.ImageColor3 = Color3.fromRGB(29, 161, 242)
verifiedBadge.Visible = false -- Se actualizará dinámicamente
verifiedBadge.Parent = profileButton

-- Contenido principal
contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -140)
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- CREAR TODAS LAS SECCIONES
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
feedScroll = Instance.new("ScrollingFrame")
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
discoverFrame = Instance.new("ScrollingFrame")
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
createFrame = Instance.new("Frame")
createFrame.Name = "CreateSection"
createFrame.Size = UDim2.new(1, -20, 1, 0)
createFrame.Position = UDim2.new(0, 10, 0, 0)
createFrame.BackgroundTransparency = 1
createFrame.Visible = false
createFrame.Parent = contentFrame

-- SETTINGS (PROFILE)
settingsFrame = Instance.new("ScrollingFrame")
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
commentsSection = Instance.new("ScrollingFrame")
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
reportSection = Instance.new("Frame")
reportSection.Name = "ReportSection"
reportSection.Size = UDim2.new(1, 0, 1, -60)
reportSection.Position = UDim2.new(0, 0, 0, 0)
reportSection.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
reportSection.Visible = false
reportSection.BorderSizePixel = 0
reportSection.Parent = contentFrame

-- Barra de navegación inferior
local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, 0, 0, 80)
navBar.Position = UDim2.new(0, 0, 1, -80)
navBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
navBar.BorderSizePixel = 0
navBar.Parent = mainFrame

-- Botones de navegación (datos)
local navButtons = {
{name = "Inicio", icon = "🏠", view = "feed"},
{name = "Descubrir", icon = "🔍", view = "discover"},
{name = "Crear", icon = "➕", view = "create"},
{name = "Perfil", icon = "👤", view = "settings"}
}

-- <<< CAMBIO: creación completa de botones de navegación con ImageLabel para "Inicio" >>>
for i, buttonData in ipairs(navButtons) do
    local navButton = Instance.new("TextButton")
    navButton.Size = UDim2.new(1/#navButtons, 0, 1, 0)
    navButton.Position = UDim2.new((i-1)/#navButtons, 0, 0, 0)
    navButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    navButton.BorderSizePixel = 0
    navButton.Text = "" -- sin texto directo, usaremos hijos
    navButton.Parent = navBar
    
    -- Icono: para "Inicio" usamos la imagen que nos diste; otros usan emoji
    if buttonData.view == "feed" then
        local icon = Instance.new("ImageLabel")
        icon.Name = "NavIcon"
        icon.Size = UDim2.new(0, 36, 0, 36)
        icon.Position = UDim2.new(0.5, -18, 0, 8)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://120125722355552" -- <-- TU ASSET ID AQUI
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
    
    -- Etiqueta (nombre debajo del icono)
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
    
    navButton.MouseButton1Click:Connect(function()
        switchView(buttonData.view)
    end)
end
-- <<< FIN CAMBIO >>>

-- Función para crear verificación dinámica
local function createVerificationBadge(parent, isVerified, xOffset, yOffset)
    if isVerified then
        local badge = Instance.new("ImageLabel")
        badge.Size = UDim2.new(0, 16, 0, 16)
        badge.Position = UDim2.new(0, xOffset or 0, 0, yOffset or 3)
        badge.BackgroundTransparency = 1
        badge.Image = "rbxassetid://125268479387354"
        badge.ImageColor3 = Color3.fromRGB(29, 161, 242)
        badge.Parent = parent
        return badge
    end
    return nil
end

-- Función para crear un frame de post visual
local function createPostFrame(postData)
    local idStr = tostring(postData.id)
    local postFrame = Instance.new("Frame")
    postFrame.Name = "PostFrame_" .. idStr
    postFrame.Size = UDim2.new(1, 0, 0, 10)
    postFrame.AutomaticSize = Enum.AutomaticSize.Y
    postFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    postFrame.BorderSizePixel = 0
    postFrame.Parent = feedScroll
    
    local postCorner = Instance.new("UICorner")
    postCorner.CornerRadius = UDim.new(0, 10)
    postCorner.Parent = postFrame
    
    local postLayout = Instance.new("UIListLayout")
    postLayout.Padding = UDim.new(0, 6)
    postLayout.SortOrder = Enum.SortOrder.LayoutOrder
    postLayout.Parent = postFrame
    
    -- Header del post
    local postHeader = Instance.new("Frame")
    postHeader.Name = "Header"
    postHeader.Size = UDim2.new(1, 0, 0, 60)
    postHeader.BackgroundTransparency = 1
    postHeader.Parent = postFrame
    
    -- Foto de perfil del autor
    local authorPic = Instance.new("ImageButton")
    authorPic.Size = UDim2.new(0, 44, 0, 44)
    authorPic.Position = UDim2.new(0, 10, 0, 8)
    authorPic.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    authorPic.BorderSizePixel = 0
    authorPic.Image = postData.profilePicture or "rbxasset://textures/face.png"
    authorPic.Parent = postHeader
    
    local authorPicCorner = Instance.new("UICorner")
    authorPicCorner.CornerRadius = UDim.new(0.5, 0)
    authorPicCorner.Parent = authorPic
    
    -- Nombre del autor
    local authorName = Instance.new("TextLabel")
    authorName.Size = UDim2.new(0, 300, 0, 22)
    authorName.Position = UDim2.new(0, 64, 0, 8)
    authorName.BackgroundTransparency = 1
    authorName.Text = postData.authorName
    authorName.TextColor3 = Color3.new(1, 1, 1)
    authorName.TextScaled = false
    authorName.Font = Enum.Font.SourceSansBold
    authorName.TextSize = 18
    authorName.TextXAlignment = Enum.TextXAlignment.Left
    authorName.Parent = postHeader
    
    -- Username debajo del display name
    local authorUsername = Instance.new("TextLabel")
    authorUsername.Size = UDim2.new(0, 300, 0, 18)
    authorUsername.Position = UDim2.new(0, 64, 0, 28)
    authorUsername.BackgroundTransparency = 1
    authorUsername.Text = "@" .. (postData.authorUsername or "usuario")
    authorUsername.TextColor3 = Color3.fromRGB(150, 150, 150)
    authorUsername.TextScaled = false
    authorUsername.Font = Enum.Font.SourceSans
    authorUsername.TextSize = 14
    authorUsername.TextXAlignment = Enum.TextXAlignment.Left
    authorUsername.Parent = postHeader
    
    -- Verificación
    createVerificationBadge(postHeader, postData.isVerified, 370, 8)
    
    -- Tiempo
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 140, 0, 18)
    timeLabel.Position = UDim2.new(1, -150, 0, 10)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%d/%m/%Y %H:%M", postData.timestamp)
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.TextScaled = false
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.TextSize = 14
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = postHeader
    
    -- Contenido del post
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -20, 0, 10)
    contentLabel.Position = UDim2.new(0, 10, 0, 60)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = postData.content or ""
    contentLabel.TextColor3 = Color3.new(1, 1, 1)
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.TextSize = 20
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.Parent = postFrame
    
    -- Reproductor de música
    if postData.musicId and postData.musicId ~= "" then
        local musicFrame = Instance.new("Frame")
        musicFrame.Name = "MusicPlayer"
        musicFrame.Size = UDim2.new(1, -20, 0, 60)
        musicFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        musicFrame.BorderSizePixel = 0
        musicFrame.Parent = postFrame
        
        local musicCorner = Instance.new("UICorner")
        musicCorner.CornerRadius = UDim.new(0, 8)
        musicCorner.Parent = musicFrame
        
        local musicIcon = Instance.new("TextLabel")
        musicIcon.Size = UDim2.new(0, 40, 0, 40)
        musicIcon.Position = UDim2.new(0, 10, 0, 10)
        musicIcon.BackgroundTransparency = 1
        musicIcon.Text = "🎵"
        musicIcon.TextScaled = true
        musicIcon.Font = Enum.Font.SourceSansBold
        musicIcon.Parent = musicFrame
        
        local musicTitle = Instance.new("TextLabel")
        musicTitle.Size = UDim2.new(0, 200, 0, 20)
        musicTitle.Position = UDim2.new(0, 60, 0, 10)
        musicTitle.BackgroundTransparency = 1
        musicTitle.Text = getMusicTitle(postData.musicId)
        musicTitle.TextColor3 = Color3.new(1, 1, 1)
        musicTitle.Font = Enum.Font.SourceSansBold
        musicTitle.TextSize = 16
        musicTitle.TextXAlignment = Enum.TextXAlignment.Left
        musicTitle.Parent = musicFrame
        
        local playButton = Instance.new("TextButton")
        playButton.Size = UDim2.new(0, 80, 0, 35)
        playButton.Position = UDim2.new(1, -90, 0, 12)
        playButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        playButton.BorderSizePixel = 0
        playButton.Text = "▶ Play"
        playButton.TextColor3 = Color3.new(1, 1, 1)
        playButton.Font = Enum.Font.SourceSansBold
        playButton.TextSize = 14
        playButton.Parent = musicFrame
        
        local playCorner = Instance.new("UICorner")
        playCorner.CornerRadius = UDim.new(0, 6)
        playCorner.Parent = playButton
        
        -- Crear Sound
        local musicPlayer = Instance.new("Sound")
        musicPlayer.SoundId = "rbxassetid://" .. postData.musicId
        musicPlayer.Volume = 0.5
        musicPlayer.Parent = workspace
        
        local isPlaying = false
        playButton.MouseButton1Click:Connect(function()
            if not isPlaying then
                musicPlayer:Play()
                playButton.Text = "⏸ Pause"
                playButton.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
                isPlaying = true
            else
                musicPlayer:Pause()
                playButton.Text = "▶ Play"
                playButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                isPlaying = false
            end
        end)
    end
    
    -- Botones de interaccion
    local interactionFrame = Instance.new("Frame")
    interactionFrame.Name = "Interaction"
    interactionFrame.Size = UDim2.new(1, 0, 0, 42)
    interactionFrame.BackgroundTransparency = 1
    interactionFrame.Parent = postFrame
    
    local likeButton = Instance.new("TextButton")
    likeButton.Size = UDim2.new(0, 110, 0, 36)
    likeButton.Position = UDim2.new(0, 10, 0, 3)
    likeButton.BorderSizePixel = 0
    likeButton.TextColor3 = Color3.new(1, 1, 1)
    likeButton.TextScaled = false
    likeButton.Font = Enum.Font.SourceSansBold
    likeButton.TextSize = 18
    likeButton.Parent = interactionFrame
    
    local commentButton = Instance.new("TextButton")
    commentButton.Size = UDim2.new(0, 130, 0, 36)
    commentButton.Position = UDim2.new(0, 130, 0, 3)
    commentButton.BorderSizePixel = 0
    commentButton.TextColor3 = Color3.new(1, 1, 1)
    commentButton.TextScaled = false
    commentButton.Font = Enum.Font.SourceSansBold
    commentButton.TextSize = 18
    commentButton.Parent = interactionFrame
    
    -- Inicializar estados
    local likesCount = postData.likesCount or 0
    local commentsCount = postData.commentsCount or 0
    local isLiked = postData.isLikedByUser or false
    
    likeButton.Text = (isLiked and "❤ " or "♡ ") .. tostring(likesCount)
    likeButton.BackgroundColor3 = isLiked and Color3.fromRGB(233, 69, 96) or Color3.fromRGB(60, 60, 60)
    commentButton.Text = "💬 " .. tostring(commentsCount)
    commentButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    -- Guardar referencias
    postWidgets[idStr] = {
    frame = postFrame,
    likeButton = likeButton,
    commentButton = commentButton,
    likesCount = likesCount,
    commentsCount = commentsCount,
    isLikedByUser = isLiked,
    contentLabel = contentLabel,
    postId = idStr
    }
    
    -- Eventos
    authorPic.MouseButton1Click:Connect(function()
        showUserProfile(postData.authorId)
    end)
    
    likeButton.MouseButton1Click:Connect(function()
        local wasLiked = postWidgets[idStr].isLikedByUser
        postWidgets[idStr].isLikedByUser = not wasLiked
        postWidgets[idStr].likesCount = postWidgets[idStr].likesCount + (wasLiked and -1 or 1)
        postWidgets[idStr].likeButton.BackgroundColor3 = postWidgets[idStr].isLikedByUser and Color3.fromRGB(233, 69, 96) or Color3.fromRGB(60, 60, 60)
        postWidgets[idStr].likeButton.Text = (postWidgets[idStr].isLikedByUser and "❤ " or "♡ ") .. tostring(postWidgets[idStr].likesCount)
        likePostEvent:FireServer(idStr)
    end)
    
    commentButton.MouseButton1Click:Connect(function()
        showCommentsSection(idStr)
    end)
    
    return postFrame
end

-- Función que muestra la sección de comentarios
function showCommentsSection(postId)
    currentPostId = postId
    
    -- Ocultar otras secciones
    feedScroll.Visible = false
    discoverFrame.Visible = false
    createFrame.Visible = false
    settingsFrame.Visible = false
    commentsSection.Visible = true
    
    -- Ocultar navbar Y header para más espacio
    navBar.Visible = false
    headerFrame.Visible = false
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 0)
    
    -- Limpiar commentsSection
    for _, child in pairs(commentsSection:GetChildren()) do
        if child ~= commentsLayout then
            child:Destroy()
        end
    end
    commentWidgets = {}
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    header.Parent = commentsSection
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Comentarios"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 80, 0, 40)
    closeBtn.Position = UDim2.new(1, -90, 0.5, -20)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.Text = "Cerrar"
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        commentsSection.Visible = false
        navBar.Visible = true
        headerFrame.Visible = true
        contentFrame.Size = UDim2.new(1, 0, 1, -140)
        contentFrame.Position = UDim2.new(0, 0, 0, 60)
        switchView("feed")
    end)
    
    -- Scroll con comentarios
    local commentsScroll = Instance.new("ScrollingFrame")
    commentsScroll.Size = UDim2.new(1, 0, 1, -140)
    commentsScroll.Position = UDim2.new(0, 0, 0, 60)
    commentsScroll.BackgroundTransparency = 1
    commentsScroll.Parent = commentsSection
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = commentsScroll
    layout.Padding = UDim.new(0, 10)
    
    -- Caja para escribir comentario (fija abajo)
    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, 0, 0, 80)
    inputFrame.Position = UDim2.new(0, 0, 1, -80)
    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    inputFrame.ZIndex = 10
    inputFrame.Parent = commentsSection
    
    local commentTextBox = Instance.new("TextBox")
    commentTextBox.Size = UDim2.new(1, -120, 0, 40)
    commentTextBox.Position = UDim2.new(0, 10, 0, 20)
    commentTextBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    commentTextBox.BorderSizePixel = 0
    commentTextBox.PlaceholderText = "Escribe un comentario..."
    commentTextBox.Text = ""
    commentTextBox.TextColor3 = Color3.new(1, 1, 1)
    commentTextBox.Font = Enum.Font.SourceSans
    commentTextBox.TextSize = 16
    commentTextBox.Parent = inputFrame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = commentTextBox
    
    local postCommentButton = Instance.new("TextButton")
    postCommentButton.Size = UDim2.new(0, 100, 0, 40)
    postCommentButton.Position = UDim2.new(1, -110, 0, 20)
    postCommentButton.BackgroundColor3 = Color3.fromRGB(66, 103, 178)
    postCommentButton.BorderSizePixel = 0
    postCommentButton.Text = "Comentar"
    postCommentButton.TextColor3 = Color3.new(1, 1, 1)
    postCommentButton.Font = Enum.Font.SourceSansBold
    postCommentButton.TextSize = 16
    postCommentButton.Parent = inputFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = postCommentButton
    
    -- Función para crear widget de comentario
    local function createCommentWidget(commentData)
        local commentFrame = Instance.new("Frame")
        commentFrame.Name = "Comment_" .. commentData.id
        commentFrame.Size = UDim2.new(1, -20, 0, 80)
        commentFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        commentFrame.BorderSizePixel = 0
        commentFrame.AutomaticSize = Enum.AutomaticSize.Y
        commentFrame.Parent = commentsScroll
        
        local commentCorner = Instance.new("UICorner")
        commentCorner.CornerRadius = UDim.new(0, 8)
        commentCorner.Parent = commentFrame
        
        -- Nombre y username del autor
        local authorLabel = Instance.new("TextLabel")
        authorLabel.Size = UDim2.new(1, -120, 0, 20)
        authorLabel.Position = UDim2.new(0, 10, 0, 5)
        authorLabel.BackgroundTransparency = 1
        authorLabel.Font = Enum.Font.SourceSansBold
        authorLabel.Text = commentData.authorName
        authorLabel.TextColor3 = Color3.new(1,1,1)
        authorLabel.TextSize = 16
        authorLabel.TextXAlignment = Enum.TextXAlignment.Left
        authorLabel.Parent = commentFrame
        
        local usernameLabel = Instance.new("TextLabel")
        usernameLabel.Size = UDim2.new(1, -120, 0, 16)
        usernameLabel.Position = UDim2.new(0, 10, 0, 22)
        usernameLabel.BackgroundTransparency = 1
        usernameLabel.Font = Enum.Font.SourceSans
        usernameLabel.Text = "@" .. (commentData.authorUsername or "usuario")
        usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        usernameLabel.TextSize = 14
        usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
        usernameLabel.Parent = commentFrame
        
        -- Verificación
        createVerificationBadge(commentFrame, commentData.isVerified, authorLabel.TextBounds.X + 15, 5)
        
        -- Contenido del comentario
        local contentLabel = Instance.new("TextLabel")
        contentLabel.Size = UDim2.new(1, -120, 0, 40)
        contentLabel.Position = UDim2.new(0, 10, 0, 40)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Font = Enum.Font.SourceSans
        contentLabel.Text = commentData.content
        contentLabel.TextWrapped = true
        contentLabel.TextSize = 16
        contentLabel.TextColor3 = Color3.fromRGB(220,220,220)
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.AutomaticSize = Enum.AutomaticSize.Y
        contentLabel.Parent = commentFrame
        
        -- Botones de acción
        local buttonFrame = Instance.new("Frame")
        buttonFrame.Size = UDim2.new(0, 100, 0, 70)
        buttonFrame.Position = UDim2.new(1, -110, 0, 5)
        buttonFrame.BackgroundTransparency = 1
        buttonFrame.Parent = commentFrame
        
        -- Botón de reportar
        local reportCommentBtn = Instance.new("TextButton")
        reportCommentBtn.Size = UDim2.new(0, 30, 0, 25)
        reportCommentBtn.Position = UDim2.new(0, 5, 0, 5)
        reportCommentBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
        reportCommentBtn.BorderSizePixel = 0
        reportCommentBtn.Text = "⚠"
        reportCommentBtn.TextColor3 = Color3.new(1, 1, 1)
        reportCommentBtn.Font = Enum.Font.SourceSansBold
        reportCommentBtn.TextSize = 14
        reportCommentBtn.Parent = buttonFrame
        
        -- Botón de eliminar (solo para autor o admin)
        if tostring(commentData.authorId) == tostring(player.UserId) or player.Name:lower() == "vegetl_t" then
            local deleteCommentBtn = Instance.new("TextButton")
            deleteCommentBtn.Size = UDim2.new(0, 30, 0, 25)
            deleteCommentBtn.Position = UDim2.new(0, 40, 0, 5)
            deleteCommentBtn.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
            deleteCommentBtn.BorderSizePixel = 0
            deleteCommentBtn.Text = "🗑"
            deleteCommentBtn.TextColor3 = Color3.new(0, 0, 0)
            deleteCommentBtn.Font = Enum.Font.SourceSansBold
            deleteCommentBtn.TextSize = 14
            deleteCommentBtn.Parent = buttonFrame
            
            deleteCommentBtn.MouseButton1Click:Connect(function()
                deleteCommentEvent:FireServer(commentData.id)
            end)
        end
        
        reportCommentBtn.MouseButton1Click:Connect(function()
            reportCommentBtn.Text = "✓"
            reportCommentBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
            wait(1)
            reportCommentBtn.Text = "⚠"
            reportCommentBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
        end)
        
        commentWidgets[commentData.id] = commentFrame
        return commentFrame
    end
    
    -- Cargar comentarios existentes
    spawn(function()
        local commentsData = getCommentsFunction:InvokeServer(postId) or {}
        for _, commentData in ipairs(commentsData) do
            if not commentData.deleted then
                createCommentWidget(commentData)
            end
        end
        commentsScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    postCommentButton.MouseButton1Click:Connect(function()
        if commentTextBox.Text ~= "" then
            commentPostEvent:FireServer(postId, commentTextBox.Text)
            commentTextBox.Text = ""
        end
    end)
end

-- showUserProfile
function showUserProfile(userId)
    switchView("settings")
    currentProfileId = userId
    loadSettingsPage(userId)
end

-- switchView
function switchView(view)
    currentView = view
    
    feedScroll.Visible = false
    discoverFrame.Visible = false
    createFrame.Visible = false
    settingsFrame.Visible = false
    commentsSection.Visible = false
    musicSection.Visible = false
    
    -- Controla la visibilidad de la barra de búsqueda y el logo.
    local isDiscoverView = (view == "discover")
    searchFrame.Visible = isDiscoverView
    logoLabel.Visible = not isDiscoverView -- Oculta el logo si estamos en "Descubrir"
    
    for viewName, button in pairs(navButtonInstances) do
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    
    if navButtonInstances[view] then
        navButtonInstances[view].BackgroundColor3 = Color3.fromRGB(59, 89, 152)
    end
    
    if view == "feed" then
        feedScroll.Visible = true
        loadFeed()
    elseif view == "discover" then
        discoverFrame.Visible = true
        loadDiscoverPage()
    elseif view == "create" then
        createFrame.Visible = true
        loadCreatePage()
    elseif view == "settings" then
        settingsFrame.Visible = true
        loadSettingsPage(currentProfileId)
    end
end

-- Cargar feed
function loadFeed()
    for _, child in pairs(feedScroll:GetChildren()) do
        if child.Name:match("^PostFrame_") then
            child:Destroy()
        end
    end
    postWidgets = {}
    
    local feedData = getFeedFunction:InvokeServer()
    if feedData then
        for _, postData in ipairs(feedData) do
            local pf = createPostFrame(postData)
            pf.Parent = feedScroll
        end
    end
    feedScroll.CanvasSize = UDim2.new(0, 0, 0, feedLayout.AbsoluteContentSize.Y)
end

-- Discover: búsqueda + recomendaciones
function loadDiscoverPage()
    -- <<< FIX >>>: limpiar títulos y resultados previos correctamente (evita duplicados)
    for _, child in pairs(discoverFrame:GetChildren()) do
        if child.Name:match("^UserResult") or child.Name == "SectionTitle" or child.Name == "NoRecs" or child.Name == "SearchTitle" then
            child:Destroy()
        end
    end
    
    -- Título de sección (asegurar que solo exista uno)
    if discoverFrame:FindFirstChild("SectionTitle") then
        discoverFrame.SectionTitle:Destroy()
    end
    
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = "SectionTitle"
    sectionTitle.Size = UDim2.new(1, 0, 0, 40)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = "🌟 Usuarios Recomendados"
    sectionTitle.TextColor3 = Color3.new(1, 1, 1)
    sectionTitle.Font = Enum.Font.SourceSansBold
    sectionTitle.TextSize = 20
    sectionTitle.Parent = discoverFrame
    
    spawn(function()
        local recs = getRecommendationsFunction:InvokeServer()
        if recs and #recs > 0 then
            for i, u in ipairs(recs) do
                createUserResultFrame(u, discoverFrame)
            end
        else
            if discoverFrame:FindFirstChild("NoRecs") then discoverFrame.NoRecs:Destroy() end
            local empty = Instance.new("TextLabel")
            empty.Name = "NoRecs"
            empty.Size = UDim2.new(1, 0, 0, 60)
            empty.BackgroundTransparency = 1
            empty.Text = "No hay recomendaciones por ahora. Usa la búsqueda para encontrar usuarios."
            empty.TextColor3 = Color3.new(1,1,1)
            empty.Font = Enum.Font.SourceSans
            empty.TextSize = 16
            empty.Parent = discoverFrame
        end
        discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayout.AbsoluteContentSize.Y)
    end)
end

-- Crear frame de resultado de usuario
function createUserResultFrame(userData, parent)
    local resultFrame = Instance.new("Frame")
    -- <<< FIX >>>: dar nombre único por usuario para evitar colisiones y facilitar limpieza
    resultFrame.Name = "UserResult_" .. tostring(userData.userId)
    resultFrame.Size = UDim2.new(1, 0, 0, 80)
    resultFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    resultFrame.BorderSizePixel = 0
    resultFrame.Parent = parent
    
    local resultCorner = Instance.new("UICorner")
    resultCorner.CornerRadius = UDim.new(0, 10)
    resultCorner.Parent = resultFrame
    
    local userPic = Instance.new("ImageButton")
    userPic.Size = UDim2.new(0, 50, 0, 50)
    userPic.Position = UDim2.new(0, 15, 0, 15)
    userPic.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    userPic.BorderSizePixel = 0
    userPic.Image = userData.profilePicture or "rbxasset://textures/face.png"
    userPic.Parent = resultFrame
    
    local userPicCorner = Instance.new("UICorner")
    userPicCorner.CornerRadius = UDim.new(0.5, 0)
    userPicCorner.Parent = userPic
    
    local userName = Instance.new("TextLabel")
    userName.Size = UDim2.new(0, 200, 0, 25)
    userName.Position = UDim2.new(0, 80, 0, 10)
    userName.BackgroundTransparency = 1
    userName.Text = userData.displayName
    userName.TextColor3 = Color3.new(1, 1, 1)
    userName.TextScaled = false
    userName.Font = Enum.Font.SourceSansBold
    userName.TextSize = 18
    userName.TextXAlignment = Enum.TextXAlignment.Left
    userName.Parent = resultFrame
    
    local userUsername = Instance.new("TextLabel")
    userUsername.Size = UDim2.new(0, 200, 0, 20)
    userUsername.Position = UDim2.new(0, 80, 0, 32)
    userUsername.BackgroundTransparency = 1
    userUsername.Text = "@" .. (userData.username or "usuario")
    userUsername.TextColor3 = Color3.fromRGB(150, 150, 150)
    userUsername.TextScaled = false
    userUsername.Font = Enum.Font.SourceSans
    userUsername.TextSize = 14
    userUsername.TextXAlignment = Enum.TextXAlignment.Left
    userUsername.Parent = resultFrame
    
    -- Verificación
    createVerificationBadge(resultFrame, userData.isVerified, 285, 12)
    
    local userStats = Instance.new("TextLabel")
    userStats.Size = UDim2.new(0, 200, 0, 20)
    userStats.Position = UDim2.new(0, 80, 0, 52)
    userStats.BackgroundTransparency = 1
    userStats.Text = (userData.followersCount or 0) .. " seguidores"
    userStats.TextColor3 = Color3.fromRGB(150, 150, 150)
    userStats.TextScaled = false
    userStats.Font = Enum.Font.SourceSans
    userStats.TextSize = 14
    userStats.TextXAlignment = Enum.TextXAlignment.Left
    userStats.Parent = resultFrame
    
    local followButton = Instance.new("TextButton")
    followButton.Size = UDim2.new(0, 80, 0, 30)
    followButton.Position = UDim2.new(1, -140, 0, 25)
    followButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
    followButton.BorderSizePixel = 0
    followButton.Text = "Seguir"
    followButton.TextColor3 = Color3.new(1, 1, 1)
    followButton.Font = Enum.Font.SourceSans
    followButton.TextSize = 16
    followButton.Parent = resultFrame
    
    local reportButton = Instance.new("TextButton")
    reportButton.Size = UDim2.new(0, 50, 0, 30)
    reportButton.Position = UDim2.new(1, -50, 0, 25)
    reportButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    reportButton.BorderSizePixel = 0
    reportButton.Text = "⚠"
    reportButton.TextColor3 = Color3.new(1, 1, 1)
    reportButton.Font = Enum.Font.SourceSansBold
    reportButton.TextSize = 18
    reportButton.Parent = resultFrame
    
    followButton.MouseButton1Click:Connect(function()
        followButton.Text = "Siguiendo..."
        followButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        followButton.Enabled = false
        
        followUserEvent:FireServer(userData.userId)
        
        wait(0.5)
        loadDiscoverPage()
    end)
    
    reportButton.MouseButton1Click:Connect(function()
        showReportModal(userData.userId, userData.displayName)
    end)
    
    userPic.MouseButton1Click:Connect(function()
        showUserProfile(userData.userId)
    end)
end

-- Mostrar resultados de búsqueda
function showSearchResults(results)
    -- <<< FIX >>>: limpiar resultados previos y títulos antes de mostrar resultados de búsqueda
    for _, child in pairs(discoverFrame:GetChildren()) do
        if child.Name:match("^UserResult") or child.Name == "SectionTitle" or child.Name == "NoRecs" or child.Name == "SearchTitle" then
            child:Destroy()
        end
    end
    
    -- Título para resultados
    local searchTitle = Instance.new("TextLabel")
    searchTitle.Name = "SearchTitle"
    searchTitle.Size = UDim2.new(1, 0, 0, 40)
    searchTitle.BackgroundTransparency = 1
    searchTitle.Text = "🔍 Resultados de Búsqueda"
    searchTitle.TextColor3 = Color3.new(1, 1, 1)
    searchTitle.Font = Enum.Font.SourceSansBold
    searchTitle.TextSize = 20
    searchTitle.Parent = discoverFrame
    
    if results and #results > 0 then
        for _, userData in ipairs(results) do
            createUserResultFrame(userData, discoverFrame)
        end
    else
        local noResults = Instance.new("TextLabel")
        noResults.Name = "NoResults"
        noResults.Size = UDim2.new(1, 0, 0, 60)
        noResults.BackgroundTransparency = 1
        noResults.Text = "No se encontraron usuarios con ese nombre."
        noResults.TextColor3 = Color3.new(1,1,1)
        noResults.Font = Enum.Font.SourceSans
        noResults.TextSize = 16
        noResults.Parent = discoverFrame
    end
    
    discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayout.AbsoluteContentSize.Y)
end

-- Crear página de crear post
function loadCreatePage()
    for _, child in pairs(createFrame:GetChildren()) do
        child:Destroy()
    end
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Crear Nueva Publicación"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = createFrame
    
    local postContentFrame = Instance.new("Frame")
    postContentFrame.Size = UDim2.new(1, 0, 0, 300)
    postContentFrame.Position = UDim2.new(0, 0, 0, 50)
    postContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    postContentFrame.BorderSizePixel = 0
    postContentFrame.Parent = createFrame
    
    local contentFrameCorner = Instance.new("UICorner")
    contentFrameCorner.CornerRadius = UDim.new(0, 10)
    contentFrameCorner.Parent = postContentFrame
    
    local postTextBox = Instance.new("TextBox")
    postTextBox.Size = UDim2.new(1, -20, 0, 180)
    postTextBox.Position = UDim2.new(0, 10, 0, 10)
    postTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    postTextBox.BorderSizePixel = 0
    postTextBox.Text = ""
    postTextBox.PlaceholderText = "¿Qué está pasando?..."
    postTextBox.TextColor3 = Color3.new(1, 1, 1)
    postTextBox.Font = Enum.Font.SourceSans
    postTextBox.TextSize = 18
    postTextBox.TextWrapped = true
    postTextBox.MultiLine = true
    postTextBox.TextXAlignment = Enum.TextXAlignment.Left
    postTextBox.TextYAlignment = Enum.TextYAlignment.Top
    postTextBox.Parent = postContentFrame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 8)
    textBoxCorner.Parent = postTextBox
    
    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(0, 100, 0, 20)
    charCounter.Position = UDim2.new(1, -110, 0, 200)
    charCounter.BackgroundTransparency = 1
    charCounter.Text = "0/2000"
    charCounter.TextColor3 = Color3.fromRGB(150, 150, 150)
    charCounter.TextScaled = true
    charCounter.Font = Enum.Font.SourceSans
    charCounter.Parent = postContentFrame
    
    postTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local length = string.len(postTextBox.Text)
        charCounter.Text = length .. "/2000"
        charCounter.TextColor3 = length > 2000 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 150, 150)
    end)
    
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, -20, 0, 50)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 230)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = postContentFrame
    
    local musicButton = Instance.new("TextButton")
    musicButton.Size = UDim2.new(0, 120, 0, 40)
    musicButton.Position = UDim2.new(0, 0, 0, 5)
    musicButton.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
    musicButton.BorderSizePixel = 0
    musicButton.Text = selectedMusicId ~= "" and "🎵 " .. getMusicTitle(selectedMusicId) or "🎵 Agregar Música"
    musicButton.TextColor3 = Color3.new(1, 1, 1)
    musicButton.TextScaled = true
    musicButton.Font = Enum.Font.SourceSans
    musicButton.Parent = buttonsFrame
    
    local musicCorner = Instance.new("UICorner")
    musicCorner.CornerRadius = UDim.new(0, 8)
    musicCorner.Parent = musicButton
    
    local cancelButton = Instance.new("TextButton")
    cancelButton.Size = UDim2.new(0, 100, 0, 40)
    cancelButton.Position = UDim2.new(1, -220, 0, 5)
    cancelButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    cancelButton.BorderSizePixel = 0
    cancelButton.Text = "Cancelar"
    cancelButton.TextColor3 = Color3.new(1, 1, 1)
    cancelButton.TextScaled = true
    cancelButton.Font = Enum.Font.SourceSans
    cancelButton.Parent = buttonsFrame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 8)
    cancelCorner.Parent = cancelButton
    
    local publishButton = Instance.new("TextButton")
    publishButton.Size = UDim2.new(0, 100, 0, 40)
    publishButton.Position = UDim2.new(1, -110, 0, 5)
    publishButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
    publishButton.BorderSizePixel = 0
    publishButton.Text = "Publicar"
    publishButton.TextColor3 = Color3.new(1, 1, 1)
    publishButton.TextScaled = true
    publishButton.Font = Enum.Font.SourceSansBold
    publishButton.Parent = buttonsFrame
    
    local publishCorner = Instance.new("UICorner")
    publishCorner.CornerRadius = UDim.new(0, 8)
    publishCorner.Parent = publishButton
    
    musicButton.MouseButton1Click:Connect(function()
        showMusicSelection()
    end)
    
    cancelButton.MouseButton1Click:Connect(function()
        postTextBox.Text = ""
        selectedMusicId = ""
        switchView("feed")
    end)
    
    publishButton.MouseButton1Click:Connect(function()
        local text = postTextBox.Text
        if text ~= "" and string.len(text) <= 2000 then
            createPostEvent:FireServer(text, "", selectedMusicId)
            postTextBox.Text = ""
            selectedMusicId = ""
            switchView("feed")
        end
    end)
end

-- Cargar página de ajustes (perfil)
function loadSettingsPage(userId)
    for _, child in pairs(settingsFrame:GetChildren()) do
        if child:IsA("UIListLayout") == false then
            child:Destroy()
        end
    end
    
    local loader = Instance.new("TextLabel")
    loader.Size = UDim2.new(1, 0, 0, 40)
    loader.BackgroundTransparency = 1
    loader.Text = "Cargando perfil..."
    loader.TextColor3 = Color3.new(1,1,1)
    loader.Font = Enum.Font.SourceSansBold
    loader.TextSize = 18
    loader.Parent = settingsFrame
    
    spawn(function()
        local profileData = getProfileFunction:InvokeServer(userId)
        if not profileData then
            loader.Text = "Usuario no encontrado"
            return
        end
        
        for _, child in pairs(settingsFrame:GetChildren()) do
            if child:IsA("UIListLayout") == false then child:Destroy() end
        end
        
        local profileHeader = Instance.new("Frame")
        profileHeader.Name = "ProfileHeader"
        profileHeader.Size = UDim2.new(1, 0, 0, 200)
        profileHeader.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
        profileHeader.BorderSizePixel = 0
        profileHeader.Parent = settingsFrame
        
        local headerCorner = Instance.new("UICorner")
        headerCorner.CornerRadius = UDim.new(0, 15)
        headerCorner.Parent = profileHeader
        
        local headerGradient2 = Instance.new("UIGradient")
        headerGradient2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 89, 152)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 70, 120))
        }
        headerGradient2.Rotation = 45
        headerGradient2.Parent = profileHeader
        
        local bigProfilePic = Instance.new("ImageLabel")
        bigProfilePic.Size = UDim2.new(0, 120, 0, 120)
        bigProfilePic.Position = UDim2.new(0, 30, 0, 40)
        bigProfilePic.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        bigProfilePic.BorderSizePixel = 0
        bigProfilePic.Image = profileData.profilePicture or "rbxasset://textures/face.png"
        bigProfilePic.Parent = profileHeader
        
        local bigPicCorner = Instance.new("UICorner")
        bigPicCorner.CornerRadius = UDim.new(0.5, 0)
        bigPicCorner.Parent = bigProfilePic
        
        -- Verificación en perfil
        createVerificationBadge(bigProfilePic, profileData.isVerified or profileData.isAdmin, 90, 10)
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(0, 300, 0, 40)
        nameLabel.Position = UDim2.new(0, 170, 0, 40)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = profileData.displayName
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextScaled = false
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 22
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = profileHeader
        
        local statsLabel = Instance.new("TextLabel")
        statsLabel.Size = UDim2.new(0, 400, 0, 30)
        statsLabel.Position = UDim2.new(0, 170, 0, 85)
        statsLabel.BackgroundTransparency = 1
        statsLabel.Text = string.format("%d seguidores • %d siguiendo • %d posts",
        profileData.followersCount, profileData.followingCount, profileData.postsCount)
        statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        statsLabel.TextScaled = false
        statsLabel.Font = Enum.Font.SourceSans
        statsLabel.TextSize = 16
        statsLabel.TextXAlignment = Enum.TextXAlignment.Left
        statsLabel.Parent = profileHeader
        
        local bioLabel = Instance.new("TextLabel")
        bioLabel.Size = UDim2.new(0, 400, 0, 25)
        bioLabel.Position = UDim2.new(0, 170, 0, 120)
        bioLabel.BackgroundTransparency = 1
        bioLabel.Text = '"' .. (profileData.bio or "Sin biografía") .. '"'
        bioLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        bioLabel.TextScaled = false
        bioLabel.Font = Enum.Font.SourceSansItalic
        bioLabel.TextSize = 16
        bioLabel.TextWrapped = true
        bioLabel.TextXAlignment = Enum.TextXAlignment.Left
        bioLabel.Parent = profileHeader
        
        local infoFrame = Instance.new("Frame")
        infoFrame.Name = "Info"
        infoFrame.Size = UDim2.new(1, 0, 0, 100)
        infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        infoFrame.BorderSizePixel = 0
        infoFrame.Parent = settingsFrame
        
        local infoCorner = Instance.new("UICorner")
        infoCorner.CornerRadius = UDim.new(0, 10)
        infoCorner.Parent = infoFrame
        
        local joinDateLabel = Instance.new("TextLabel")
        joinDateLabel.Size = UDim2.new(1, -20, 0, 30)
        joinDateLabel.Position = UDim2.new(0, 10, 0, 10)
        joinDateLabel.BackgroundTransparency = 1
        joinDateLabel.Text = "📅 Se unió el " .. os.date("%d/%m/%Y", profileData.joinDate)
        joinDateLabel.TextColor3 = Color3.new(1, 1, 1)
        joinDateLabel.TextScaled = false
        joinDateLabel.Font = Enum.Font.SourceSans
        joinDateLabel.TextSize = 16
        joinDateLabel.TextXAlignment = Enum.TextXAlignment.Left
        joinDateLabel.Parent = infoFrame
        
        local activityLabel = Instance.new("TextLabel")
        activityLabel.Size = UDim2.new(1, -20, 0, 25)
        activityLabel.Position = UDim2.new(0, 10, 0, 45)
        activityLabel.BackgroundTransparency = 1
        activityLabel.Text = "🎯 Usuario " .. (tostring(userId) == tostring(player.UserId) and "actual" or "visitado")
        activityLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        activityLabel.TextScaled = false
        activityLabel.Font = Enum.Font.SourceSans
        activityLabel.TextSize = 16
        activityLabel.TextXAlignment = Enum.TextXAlignment.Left
        activityLabel.Parent = infoFrame
        
        -- Cargar posts del usuario
        local userPosts = getUserPostsFunction:InvokeServer(userId)
        for _, postData in ipairs(userPosts) do
            local pf = createPostFrame(postData)
            pf.Parent = settingsFrame
        end
        
        settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
    end)
end

-- Búsqueda en tiempo real con animación
local searchDebounce = false
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if currentView == "discover" and string.len(searchBox.Text) >= 1 then
        if not searchDebounce then
            searchDebounce = true
            
            -- Mostrar indicador de búsqueda
            searchIndicator.Visible = true
            searchIndicator.Text = "🔍 Buscando..."
            
            -- Animar indicador
            local tween = TweenService:Create(
            searchIndicator,
            TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {TextTransparency = 0.5}
            )
            tween:Play()
            
            wait(0.3) -- Debounce
            
            if string.len(searchBox.Text) >= 3 then
                searchUsersFunction:InvokeServer(searchBox.Text)
            else
                searchIndicator.Text = "Escribe al menos 3 caracteres..."
                wait(1)
                searchIndicator.Visible = false
                tween:Cancel()
                loadDiscoverPage()
            end
            
            searchDebounce = false
        end
    elseif currentView == "discover" and string.len(searchBox.Text) == 0 then
        searchIndicator.Visible = false
        loadDiscoverPage()
    end
end)

-- Escuchar resultados de búsqueda en tiempo real
searchResultsEvent.OnClientEvent:Connect(function(results)
    if currentView == "discover" then
        searchIndicator.Visible = false
        showSearchResults(results)
    end
end)

-- Inicializar interfaz
profileButton.MouseButton1Click:Connect(function()
    showUserProfile(player.UserId)
end)

-- Botón para vincular perfil
linkProfileBtn.MouseButton1Click:Connect(function()
    linkProfileBtn.Text = "..."
    linkProfileBtn.Enabled = false
    
    linkProfileEvent:FireServer()
    
    wait(1)
    linkProfileBtn.Text = "✓"
    linkProfileBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
    
    wait(2)
    linkProfileBtn.Text = "🔗"
    linkProfileBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
    linkProfileBtn.Enabled = true
    
    if currentView == "settings" then
        loadSettingsPage(currentProfileId)
    end
end)

-- Cargar avatar automáticamente al iniciar
spawn(function()
    wait(1)
    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
    profileButton.Image = avatarUrl
    print("Avatar cargado: " .. avatarUrl)
end)

-- Escuchar vinculación de perfil
linkProfileEvent.OnClientEvent:Connect(function(avatarUrl)
    profileButton.Image = avatarUrl
    print("Avatar actualizado: " .. avatarUrl)
    
    -- Actualizar verificación basada en seguidores
    spawn(function()
        local profileData = getProfileFunction:InvokeServer(player.UserId)
        if profileData then
            verifiedBadge.Visible = profileData.isVerified or profileData.isAdmin
        end
    end)
end)

-- Cargar vista inicial
switchView("feed")

-- Ajustar CanvasSize
feedLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    feedScroll.CanvasSize = UDim2.new(0, 0, 0, feedLayout.AbsoluteContentSize.Y)
end)

discoverLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayout.AbsoluteContentSize.Y)
end)

settingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
end)

commentsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    commentsSection.CanvasSize = UDim2.new(0, 0, 0, commentsLayout.AbsoluteContentSize.Y)
end)

-- Broadcast listeners para updates en tiempo real
postCreatedEvent.OnClientEvent:Connect(function(postData)
    if currentView == "feed" then
        local pf = createPostFrame(postData)
        pf.Parent = feedScroll
        feedScroll.CanvasSize = UDim2.new(0, 0, 0, feedLayout.AbsoluteContentSize.Y)
    end
end)

postUpdatedEvent.OnClientEvent:Connect(function(postId, likesCount, commentsCount)
    local idStr = tostring(postId)
    if postWidgets[idStr] then
        postWidgets[idStr].likesCount = likesCount
        postWidgets[idStr].commentsCount = commentsCount
        local liked = postWidgets[idStr].isLikedByUser
        postWidgets[idStr].likeButton.Text = (liked and "❤ " or "♡ ") .. tostring(likesCount)
        postWidgets[idStr].commentButton.Text = "💬 " .. tostring(commentsCount)
    end
end)

-- Comentarios globales en tiempo real
commentAddedEvent.OnClientEvent:Connect(function(postId, commentData)
    -- Solo mostrar si estamos viendo los comentarios de ese post específico
    if commentsSection.Visible and currentPostId == postId then
        -- Verificar que no existe ya para evitar duplicación
        if not commentWidgets[commentData.id] then
            local commentsScroll = commentsSection:FindFirstChild("ScrollingFrame")
            if commentsScroll then
                local cf = Instance.new("Frame")
                cf.Name = "Comment_" .. commentData.id
                cf.Size = UDim2.new(1, -20, 0, 80)
                cf.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                cf.BorderSizePixel = 0
                cf.AutomaticSize = Enum.AutomaticSize.Y
                cf.Parent = commentsScroll
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = cf
                
                local authorLabel = Instance.new("TextLabel")
                authorLabel.Size = UDim2.new(1, -120, 0, 20)
                authorLabel.Position = UDim2.new(0, 10, 0, 5)
                authorLabel.BackgroundTransparency = 1
                authorLabel.Text = commentData.authorName
                authorLabel.Font = Enum.Font.SourceSansBold
                authorLabel.TextColor3 = Color3.new(1,1,1)
                authorLabel.TextSize = 16
                authorLabel.TextXAlignment = Enum.TextXAlignment.Left
                authorLabel.Parent = cf
                
                local usernameLabel = Instance.new("TextLabel")
                usernameLabel.Size = UDim2.new(1, -120, 0, 16)
                usernameLabel.Position = UDim2.new(0, 10, 0, 22)
                usernameLabel.BackgroundTransparency = 1
                usernameLabel.Text = "@" .. (commentData.authorUsername or "usuario")
                usernameLabel.Font = Enum.Font.SourceSans
                usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                usernameLabel.TextSize = 14
                usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
                usernameLabel.Parent = cf
                
                -- Verificación
                createVerificationBadge(cf, commentData.isVerified, authorLabel.TextBounds.X + 15, 5)
                
                local contentLabel = Instance.new("TextLabel")
                contentLabel.Size = UDim2.new(1, -120, 0, 40)
                contentLabel.Position = UDim2.new(0, 10, 0, 40)
                contentLabel.BackgroundTransparency = 1
                contentLabel.Font = Enum.Font.SourceSans
                contentLabel.Text = commentData.content
                contentLabel.TextWrapped = true
                contentLabel.TextSize = 16
                contentLabel.TextColor3 = Color3.fromRGB(220,220,220)
                contentLabel.AutomaticSize = Enum.AutomaticSize.Y
                contentLabel.Parent = cf
                
                commentWidgets[commentData.id] = cf
                
                -- Actualizar canvas size
                local layout = commentsScroll:FindFirstChild("UIListLayout")
                if layout then
                    commentsScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
                end
            end
        end
    end
end)

followUpdatedEvent.OnClientEvent:Connect(function(followerId, targetUserId, isFollowing)
    if tostring(targetUserId) == tostring(currentProfileId) and settingsFrame.Visible then
        loadSettingsPage(currentProfileId)
    end
end)

-- Función para mostrar modal de reportar usuario
function showReportModal(userId, displayName)
    feedScroll.Visible = false
    discoverFrame.Visible = false
    createFrame.Visible = false
    settingsFrame.Visible = false
    commentsSection.Visible = false
    reportSection.Visible = true
    
    navBar.Visible = false
    headerFrame.Visible = false
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 0)
    
    for _, child in pairs(reportSection:GetChildren()) do
        child:Destroy()
    end
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    header.Parent = reportSection
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Reportar a " .. displayName
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 80, 0, 40)
    closeBtn.Position = UDim2.new(1, -90, 0.5, -20)
    closeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    closeBtn.Text = "Cerrar"
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        reportSection.Visible = false
        navBar.Visible = true
        headerFrame.Visible = true
        contentFrame.Size = UDim2.new(1, 0, 1, -140)
        contentFrame.Position = UDim2.new(0, 0, 0, 60)
        switchView("discover")
    end)
    
    local contentScroll = Instance.new("ScrollingFrame")
    contentScroll.Size = UDim2.new(1, -40, 1, -140)
    contentScroll.Position = UDim2.new(0, 20, 0, 80)
    contentScroll.BackgroundTransparency = 1
    contentScroll.Parent = reportSection
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 15)
    layout.Parent = contentScroll
    
    local reportReasons = {
    "Spam o contenido no deseado",
    "Acoso o bullying",
    "Contenido inapropiado",
    "Suplantación de identidad",
    "Información falsa",
    "Otro motivo"
    }
    
    local selectedReason = ""
    local reasonButtons = {}
    
    for _, reason in ipairs(reportReasons) do
        local reasonFrame = Instance.new("Frame")
        reasonFrame.Size = UDim2.new(1, 0, 0, 50)
        reasonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        reasonFrame.BorderSizePixel = 0
        reasonFrame.Parent = contentScroll
        
        local reasonButton = Instance.new("TextButton")
        reasonButton.Size = UDim2.new(1, -20, 1, -10)
        reasonButton.Position = UDim2.new(0, 10, 0, 5)
        reasonButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        reasonButton.BorderSizePixel = 0
        reasonButton.Text = reason
        reasonButton.TextColor3 = Color3.new(1, 1, 1)
        reasonButton.Font = Enum.Font.SourceSans
        reasonButton.TextSize = 16
        reasonButton.Parent = reasonFrame
        
        reasonButtons[reason] = reasonButton
        
        reasonButton.MouseButton1Click:Connect(function()
            selectedReason = reason
            for r, btn in pairs(reasonButtons) do
                if r == reason then
                    btn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
            end
        end)
    end
    
    local submitFrame = Instance.new("Frame")
    submitFrame.Size = UDim2.new(1, 0, 0, 80)
    submitFrame.Position = UDim2.new(0, 0, 1, -80)
    submitFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    submitFrame.Parent = reportSection
    
    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0, 200, 0, 50)
    submitButton.Position = UDim2.new(0.5, -100, 0.5, -25)
    submitButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
    submitButton.BorderSizePixel = 0
    submitButton.Text = "Enviar Reporte"
    submitButton.TextColor3 = Color3.new(1, 1, 1)
    submitButton.Font = Enum.Font.SourceSansBold
    submitButton.TextSize = 18
    submitButton.Parent = submitFrame
    
    submitButton.MouseButton1Click:Connect(function()
        if selectedReason ~= "" then
            reportUserEvent:FireServer(userId, selectedReason)
            
            submitButton.Text = "¡Gracias! Los moderadores revisarán el problema"
            submitButton.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
            submitButton.Enabled = false
            
            wait(3)
            reportSection.Visible = false
            navBar.Visible = true
            headerFrame.Visible = true
            contentFrame.Size = UDim2.new(1, 0, 1, -140)
            contentFrame.Position = UDim2.new(0, 0, 0, 60)
            switchView("discover")
        else
            submitButton.Text = "Selecciona una razón"
            submitButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            wait(1)
            submitButton.Text = "Enviar Reporte"
            submitButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
        end
    end)
end

-- Función para mostrar selección de música
function showMusicSelection()
    feedScroll.Visible = false
    discoverFrame.Visible = false
    createFrame.Visible = false
    settingsFrame.Visible = false
    commentsSection.Visible = false
    musicSection.Visible = true
    
    navBar.Visible = false
    headerFrame.Visible = false
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.Position = UDim2.new(0, 0, 0, 0)
    
    for _, child in pairs(musicSection:GetChildren()) do
        if child ~= musicLayout then
            child:Destroy()
        end
    end
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    header.Parent = musicSection
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Seleccionar Música"
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 20
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Parent = header
    
    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 80, 0, 40)
    backBtn.Position = UDim2.new(1, -90, 0.5, -20)
    backBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    backBtn.Text = "Volver"
    backBtn.Font = Enum.Font.SourceSansBold
    backBtn.TextColor3 = Color3.new(1, 1, 1)
    backBtn.Parent = header
    backBtn.MouseButton1Click:Connect(function()
        musicSection.Visible = false
        navBar.Visible = true
        headerFrame.Visible = true
        contentFrame.Size = UDim2.new(1, 0, 1, -140)
        contentFrame.Position = UDim2.new(0, 0, 0, 60)
        switchView("create")
    end)
    
    for _, music in ipairs(availableMusic) do
        local musicFrame = Instance.new("Frame")
        musicFrame.Size = UDim2.new(1, 0, 0, 80)
        musicFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        musicFrame.BorderSizePixel = 0
        musicFrame.Parent = musicSection
        
        local musicFrameCorner = Instance.new("UICorner")
        musicFrameCorner.CornerRadius = UDim.new(0, 10)
        musicFrameCorner.Parent = musicFrame
        
        local musicIcon = Instance.new("TextLabel")
        musicIcon.Size = UDim2.new(0, 60, 0, 60)
        musicIcon.Position = UDim2.new(0, 10, 0, 10)
        musicIcon.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
        musicIcon.BorderSizePixel = 0
        musicIcon.Text = "🎵"
        musicIcon.TextScaled = true
        musicIcon.Font = Enum.Font.SourceSansBold
        musicIcon.TextColor3 = Color3.new(1, 1, 1)
        musicIcon.Parent = musicFrame
        
        local iconCorner = Instance.new("UICorner")
        iconCorner.CornerRadius = UDim.new(0.5, 0)
        iconCorner.Parent = musicIcon
        
        local musicName = Instance.new("TextLabel")
        musicName.Size = UDim2.new(0, 300, 0, 30)
        musicName.Position = UDim2.new(0, 80, 0, 15)
        musicName.BackgroundTransparency = 1
        musicName.Text = music.title
        musicName.TextColor3 = Color3.new(1, 1, 1)
        musicName.Font = Enum.Font.SourceSansBold
        musicName.TextSize = 18
        musicName.TextXAlignment = Enum.TextXAlignment.Left
        musicName.Parent = musicFrame
        
        local musicId = Instance.new("TextLabel")
        musicId.Size = UDim2.new(0, 300, 0, 20)
        musicId.Position = UDim2.new(0, 80, 0, 45)
        musicId.BackgroundTransparency = 1
        musicId.Text = "ID: " .. music.id
        musicId.TextColor3 = Color3.fromRGB(150, 150, 150)
        musicId.Font = Enum.Font.SourceSans
        musicId.TextSize = 14
        musicId.TextXAlignment = Enum.TextXAlignment.Left
        musicId.Parent = musicFrame
        
        local selectButton = Instance.new("TextButton")
        selectButton.Size = UDim2.new(0, 100, 0, 40)
        selectButton.Position = UDim2.new(1, -110, 0, 20)
        selectButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        selectButton.BorderSizePixel = 0
        selectButton.Text = "Seleccionar"
        selectButton.TextColor3 = Color3.new(1, 1, 1)
        selectButton.Font = Enum.Font.SourceSansBold
        selectButton.TextSize = 16
        selectButton.Parent = musicFrame
        
        local selectCorner = Instance.new("UICorner")
        selectCorner.CornerRadius = UDim.new(0, 8)
        selectCorner.Parent = selectButton
        
        selectButton.MouseButton1Click:Connect(function()
            selectedMusicId = music.id
            selectButton.Text = "✓ Seleccionado"
            selectButton.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
            
            wait(1)
            musicSection.Visible = false
            navBar.Visible = true
            headerFrame.Visible = true
            contentFrame.Size = UDim2.new(1, 0, 1, -140)
            contentFrame.Position = UDim2.new(0, 0, 0, 60)
            switchView("create")
        end)
    end
    
    musicSection.CanvasSize = UDim2.new(0, 0, 0, musicLayout.AbsoluteContentSize.Y)
end

print("FaceBlox Client cargado correctamente - Plataforma completamente reparada")
