
-- FaceBlox Client - LocalScript
-- Colocar en StarterGui

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local createPostEvent = remoteEvents:WaitForChild("CreatePost")
local likePostEvent = remoteEvents:WaitForChild("LikePost")
local commentPostEvent = remoteEvents:WaitForChild("CommentPost")
local followUserEvent = remoteEvents:WaitForChild("FollowUser")
local getFeedFunction = remoteEvents:WaitForChild("GetFeed")
local getProfileFunction = remoteEvents:WaitForChild("GetProfile")
local searchUsersFunction = remoteEvents:WaitForChild("SearchUsers")

-- Variables
local currentFeed = {}
local currentPage = 1
local currentView = "feed"
local screenGui
local mainFrame
local contentFrame
local feedScroll
local discoverFrame
local createFrame
local settingsFrame

-- Crear ScreenGui principal
screenGui = Instance.new("ScreenGui")
screenGui.Name = "FaceBloxGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Frame principal que ocupa toda la pantalla
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
local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(0, 150, 1, 0)
logoLabel.Position = UDim2.new(0, 10, 0, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "FaceBlox"
logoLabel.TextColor3 = Color3.new(1, 1, 1)
logoLabel.TextScaled = true
logoLabel.Font = Enum.Font.SourceSansBold
logoLabel.Parent = headerFrame

-- Botón de búsqueda
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(0, 250, 0, 35)
searchFrame.Position = UDim2.new(0.5, -125, 0.5, -17)
searchFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
searchFrame.BorderSizePixel = 0
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

-- Foto de perfil del usuario (clickeable)
local profileButton = Instance.new("ImageButton")
profileButton.Size = UDim2.new(0, 45, 0, 45)
profileButton.Position = UDim2.new(1, -55, 0.5, -22)
profileButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
profileButton.BorderSizePixel = 0
profileButton.Image = "rbxasset://textures/face.png"
profileButton.Parent = headerFrame

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0.5, 0)
profileCorner.Parent = profileButton

-- Badge de verificación para administrador
local verifiedBadge = Instance.new("ImageLabel")
verifiedBadge.Size = UDim2.new(0, 15, 0, 15)
verifiedBadge.Position = UDim2.new(1, -5, 0, 0)
verifiedBadge.BackgroundTransparency = 1
verifiedBadge.Image = "rbxassetid://6031068421" -- Ícono de verificación
verifiedBadge.ImageColor3 = Color3.fromRGB(29, 161, 242)
verifiedBadge.Visible = (player.Name == "vegetl_t")
verifiedBadge.Parent = profileButton

-- Contenido principal
contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -140)
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- CREAR TODAS LAS SECCIONES

-- 1. FEED SECTION
feedScroll = Instance.new("ScrollingFrame")
feedScroll.Name = "FeedSection"
feedScroll.Size = UDim2.new(1, -20, 1, 0)
feedScroll.Position = UDim2.new(0, 10, 0, 0)
feedScroll.BackgroundTransparency = 1
feedScroll.BorderSizePixel = 0
feedScroll.ScrollBarThickness = 8
feedScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
feedScroll.Visible = true
feedScroll.Parent = contentFrame

local feedLayout = Instance.new("UIListLayout")
feedLayout.SortOrder = Enum.SortOrder.LayoutOrder
feedLayout.Padding = UDim.new(0, 10)
feedLayout.Parent = feedScroll

-- 2. DISCOVER SECTION
discoverFrame = Instance.new("ScrollingFrame")
discoverFrame.Name = "DiscoverSection"
discoverFrame.Size = UDim2.new(1, -20, 1, 0)
discoverFrame.Position = UDim2.new(0, 10, 0, 0)
discoverFrame.BackgroundTransparency = 1
discoverFrame.BorderSizePixel = 0
discoverFrame.ScrollBarThickness = 8
discoverFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
discoverFrame.Visible = false
discoverFrame.Parent = contentFrame

local discoverLayout = Instance.new("UIListLayout")
discoverLayout.SortOrder = Enum.SortOrder.LayoutOrder
discoverLayout.Padding = UDim.new(0, 10)
discoverLayout.Parent = discoverFrame

-- 3. CREATE POST SECTION
createFrame = Instance.new("Frame")
createFrame.Name = "CreateSection"
createFrame.Size = UDim2.new(1, -20, 1, 0)
createFrame.Position = UDim2.new(0, 10, 0, 0)
createFrame.BackgroundTransparency = 1
createFrame.Visible = false
createFrame.Parent = contentFrame

-- 4. SETTINGS/PROFILE SECTION
settingsFrame = Instance.new("ScrollingFrame")
settingsFrame.Name = "SettingsSection"
settingsFrame.Size = UDim2.new(1, -20, 1, 0)
settingsFrame.Position = UDim2.new(0, 10, 0, 0)
settingsFrame.BackgroundTransparency = 1
settingsFrame.BorderSizePixel = 0
settingsFrame.ScrollBarThickness = 8
settingsFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
settingsFrame.Visible = false
settingsFrame.Parent = contentFrame

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Padding = UDim.new(0, 15)
settingsLayout.Parent = settingsFrame

-- Barra de navegación inferior
local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, 0, 0, 80)
navBar.Position = UDim2.new(0, 0, 1, -80)
navBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
navBar.BorderSizePixel = 0
navBar.Parent = mainFrame

-- Botones de navegación
local navButtons = {
    {name = "Inicio", icon = "🏠", view = "feed"},
    {name = "Descubrir", icon = "🔍", view = "discover"},
    {name = "Crear", icon = "➕", view = "create"},
    {name = "Ajustes", icon = "⚙️", view = "settings"}
}

local navButtonInstances = {}

for i, buttonData in ipairs(navButtons) do
    local navButton = Instance.new("TextButton")
    navButton.Size = UDim2.new(1/#navButtons, 0, 1, 0)
    navButton.Position = UDim2.new((i-1)/#navButtons, 0, 0, 0)
    navButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    navButton.BorderSizePixel = 0
    navButton.Text = buttonData.icon .. "\n" .. buttonData.name
    navButton.TextColor3 = Color3.new(1, 1, 1)
    navButton.TextScaled = true
    navButton.Font = Enum.Font.SourceSans
    navButton.Parent = navBar
    
    navButtonInstances[buttonData.view] = navButton
    
    navButton.MouseButton1Click:Connect(function()
        switchView(buttonData.view)
    end)
end

-- Función para crear post visual
local function createPostFrame(postData)
    local postFrame = Instance.new("Frame")
    postFrame.Size = UDim2.new(1, 0, 0, 200)
    postFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    postFrame.BorderSizePixel = 0
    postFrame.Parent = feedScroll
    
    local postCorner = Instance.new("UICorner")
    postCorner.CornerRadius = UDim.new(0, 10)
    postCorner.Parent = postFrame
    
    -- Header del post
    local postHeader = Instance.new("Frame")
    postHeader.Size = UDim2.new(1, 0, 0, 60)
    postHeader.BackgroundTransparency = 1
    postHeader.Parent = postFrame
    
    -- Foto de perfil del autor
    local authorPic = Instance.new("ImageButton")
    authorPic.Size = UDim2.new(0, 40, 0, 40)
    authorPic.Position = UDim2.new(0, 10, 0, 10)
    authorPic.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    authorPic.BorderSizePixel = 0
    authorPic.Image = "rbxasset://textures/face.png"
    authorPic.Parent = postHeader
    
    local authorPicCorner = Instance.new("UICorner")
    authorPicCorner.CornerRadius = UDim.new(0.5, 0)
    authorPicCorner.Parent = authorPic
    
    -- Badge de verificación para el autor si es admin
    if postData.authorName == "vegetl_t" then
        local authorBadge = Instance.new("ImageLabel")
        authorBadge.Size = UDim2.new(0, 12, 0, 12)
        authorBadge.Position = UDim2.new(1, -2, 0, 0)
        authorBadge.BackgroundTransparency = 1
        authorBadge.Image = "rbxassetid://6031068421"
        authorBadge.ImageColor3 = Color3.fromRGB(29, 161, 242)
        authorBadge.Parent = authorPic
    end
    
    -- Nombre del autor
    local authorName = Instance.new("TextLabel")
    authorName.Size = UDim2.new(0, 150, 0, 20)
    authorName.Position = UDim2.new(0, 60, 0, 10)
    authorName.BackgroundTransparency = 1
    authorName.Text = postData.authorName
    authorName.TextColor3 = Color3.new(1, 1, 1)
    authorName.TextScaled = true
    authorName.Font = Enum.Font.SourceSansBold
    authorName.TextXAlignment = Enum.TextXAlignment.Left
    authorName.Parent = postHeader
    
    -- Botón seguir
    local followButton = Instance.new("TextButton")
    followButton.Size = UDim2.new(0, 60, 0, 25)
    followButton.Position = UDim2.new(1, -70, 0, 10)
    followButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
    followButton.BorderSizePixel = 0
    followButton.Text = "Seguir"
    followButton.TextColor3 = Color3.new(1, 1, 1)
    followButton.TextScaled = true
    followButton.Font = Enum.Font.SourceSans
    followButton.Parent = postHeader
    
    local followCorner = Instance.new("UICorner")
    followCorner.CornerRadius = UDim.new(0, 5)
    followCorner.Parent = followButton
    
    -- Tiempo
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 100, 0, 15)
    timeLabel.Position = UDim2.new(0, 60, 0, 30)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = os.date("%H:%M", postData.timestamp)
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = postHeader
    
    -- Contenido del post
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Size = UDim2.new(1, -20, 0, 80)
    contentLabel.Position = UDim2.new(0, 10, 0, 60)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = postData.content
    contentLabel.TextColor3 = Color3.new(1, 1, 1)
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.TextSize = 16
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.Parent = postFrame
    
    -- Botones de interacción
    local interactionFrame = Instance.new("Frame")
    interactionFrame.Size = UDim2.new(1, 0, 0, 40)
    interactionFrame.Position = UDim2.new(0, 0, 1, -40)
    interactionFrame.BackgroundTransparency = 1
    interactionFrame.Parent = postFrame
    
    -- Botón like
    local likeButton = Instance.new("TextButton")
    likeButton.Size = UDim2.new(0, 80, 0, 30)
    likeButton.Position = UDim2.new(0, 10, 0, 5)
    likeButton.BackgroundColor3 = postData.isLikedByUser and Color3.fromRGB(233, 69, 96) or Color3.fromRGB(60, 60, 60)
    likeButton.BorderSizePixel = 0
    likeButton.Text = "❤️ " .. postData.likesCount
    likeButton.TextColor3 = Color3.new(1, 1, 1)
    likeButton.TextScaled = true
    likeButton.Font = Enum.Font.SourceSans
    likeButton.Parent = interactionFrame
    
    local likeCorner = Instance.new("UICorner")
    likeCorner.CornerRadius = UDim.new(0, 5)
    likeCorner.Parent = likeButton
    
    -- Botón comentar
    local commentButton = Instance.new("TextButton")
    commentButton.Size = UDim2.new(0, 80, 0, 30)
    commentButton.Position = UDim2.new(0, 100, 0, 5)
    commentButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    commentButton.BorderSizePixel = 0
    commentButton.Text = "💬 " .. postData.commentsCount
    commentButton.TextColor3 = Color3.new(1, 1, 1)
    commentButton.TextScaled = true
    commentButton.Font = Enum.Font.SourceSans
    commentButton.Parent = interactionFrame
    
    local commentCorner = Instance.new("UICorner")
    commentCorner.CornerRadius = UDim.new(0, 5)
    commentCorner.Parent = commentButton
    
    -- Eventos
    likeButton.MouseButton1Click:Connect(function()
        likePostEvent:FireServer(postData.id)
        postData.isLikedByUser = not postData.isLikedByUser
        postData.likesCount = postData.likesCount + (postData.isLikedByUser and 1 or -1)
        likeButton.BackgroundColor3 = postData.isLikedByUser and Color3.fromRGB(233, 69, 96) or Color3.fromRGB(60, 60, 60)
        likeButton.Text = "❤️ " .. postData.likesCount
    end)
    
    followButton.MouseButton1Click:Connect(function()
        followUserEvent:FireServer(postData.authorId)
    end)
    
    -- Click en foto de perfil para ver perfil
    authorPic.MouseButton1Click:Connect(function()
        showUserProfile(postData.authorId)
    end)
    
    return postFrame
end

-- Función para mostrar perfil de usuario (pantalla completa, no modal)
function showUserProfile(userId)
    switchView("settings")
    loadSettingsPage(userId)
end

-- Función para cambiar vista
function switchView(view)
    currentView = view
    
    -- Ocultar todas las secciones
    feedScroll.Visible = false
    discoverFrame.Visible = false
    createFrame.Visible = false
    settingsFrame.Visible = false
    
    -- Resetear colores de botones
    for viewName, button in pairs(navButtonInstances) do
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    end
    
    -- Activar botón actual
    if navButtonInstances[view] then
        navButtonInstances[view].BackgroundColor3 = Color3.fromRGB(59, 89, 152)
    end
    
    -- Mostrar la sección correspondiente
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
        loadSettingsPage(player.UserId)
    end
end

-- Función para cargar feed
function loadFeed()
    -- Limpiar feed actual
    for _, child in pairs(feedScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    local feedData = getFeedFunction:InvokeServer(currentPage)
    if feedData then
        for _, postData in ipairs(feedData) do
            createPostFrame(postData)
        end
    end
    
    -- Actualizar tamaño del scroll
    feedScroll.CanvasSize = UDim2.new(0, 0, 0, feedLayout.AbsoluteContentSize.Y)
end

-- Función para cargar página de descubrir
function loadDiscoverPage()
    -- Limpiar contenido anterior
    for _, child in pairs(discoverFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    -- Crear barra de búsqueda
    local searchContainer = Instance.new("Frame")
    searchContainer.Size = UDim2.new(1, 0, 0, 60)
    searchContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    searchContainer.BorderSizePixel = 0
    searchContainer.Parent = discoverFrame
    
    local searchContainerCorner = Instance.new("UICorner")
    searchContainerCorner.CornerRadius = UDim.new(0, 10)
    searchContainerCorner.Parent = searchContainer
    
    local discoverSearchBox = Instance.new("TextBox")
    discoverSearchBox.Size = UDim2.new(1, -120, 0, 40)
    discoverSearchBox.Position = UDim2.new(0, 10, 0, 10)
    discoverSearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    discoverSearchBox.BorderSizePixel = 0
    discoverSearchBox.Text = ""
    discoverSearchBox.PlaceholderText = "Buscar usuarios..."
    discoverSearchBox.TextColor3 = Color3.new(1, 1, 1)
    discoverSearchBox.TextScaled = true
    discoverSearchBox.Font = Enum.Font.SourceSans
    discoverSearchBox.Parent = searchContainer
    
    local searchBoxCorner = Instance.new("UICorner")
    searchBoxCorner.CornerRadius = UDim.new(0, 8)
    searchBoxCorner.Parent = discoverSearchBox
    
    local discoverSearchButton = Instance.new("TextButton")
    discoverSearchButton.Size = UDim2.new(0, 100, 0, 40)
    discoverSearchButton.Position = UDim2.new(1, -110, 0, 10)
    discoverSearchButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
    discoverSearchButton.BorderSizePixel = 0
    discoverSearchButton.Text = "🔍 Buscar"
    discoverSearchButton.TextColor3 = Color3.new(1, 1, 1)
    discoverSearchButton.TextScaled = true
    discoverSearchButton.Font = Enum.Font.SourceSans
    discoverSearchButton.Parent = searchContainer
    
    local searchButtonCorner = Instance.new("UICorner")
    searchButtonCorner.CornerRadius = UDim.new(0, 8)
    searchButtonCorner.Parent = discoverSearchButton
    
    discoverSearchButton.MouseButton1Click:Connect(function()
        if discoverSearchBox.Text ~= "" then
            local results = searchUsersFunction:InvokeServer(discoverSearchBox.Text)
            showSearchResults(results)
        end
    end)
    
    -- Actualizar canvas size
    discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayout.AbsoluteContentSize.Y)
end

-- Función para mostrar resultados de búsqueda
function showSearchResults(results)
    -- Limpiar resultados anteriores
    for _, child in pairs(discoverFrame:GetChildren()) do
        if child.Name:match("UserResult") then
            child:Destroy()
        end
    end
    
    if results then
        for i, userData in ipairs(results) do
            local resultFrame = Instance.new("Frame")
            resultFrame.Name = "UserResult_" .. userData.userId
            resultFrame.Size = UDim2.new(1, 0, 0, 80)
            resultFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            resultFrame.BorderSizePixel = 0
            resultFrame.Parent = discoverFrame
            
            local resultCorner = Instance.new("UICorner")
            resultCorner.CornerRadius = UDim.new(0, 10)
            resultCorner.Parent = resultFrame
            
            -- Foto de perfil
            local userPic = Instance.new("ImageButton")
            userPic.Size = UDim2.new(0, 50, 0, 50)
            userPic.Position = UDim2.new(0, 15, 0, 15)
            userPic.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            userPic.BorderSizePixel = 0
            userPic.Image = "rbxasset://textures/face.png"
            userPic.Parent = resultFrame
            
            local userPicCorner = Instance.new("UICorner")
            userPicCorner.CornerRadius = UDim.new(0.5, 0)
            userPicCorner.Parent = userPic
            
            -- Info del usuario
            local userName = Instance.new("TextLabel")
            userName.Size = UDim2.new(0, 200, 0, 25)
            userName.Position = UDim2.new(0, 80, 0, 15)
            userName.BackgroundTransparency = 1
            userName.Text = userData.displayName
            userName.TextColor3 = Color3.new(1, 1, 1)
            userName.TextScaled = true
            userName.Font = Enum.Font.SourceSansBold
            userName.TextXAlignment = Enum.TextXAlignment.Left
            userName.Parent = resultFrame
            
            local userStats = Instance.new("TextLabel")
            userStats.Size = UDim2.new(0, 200, 0, 20)
            userStats.Position = UDim2.new(0, 80, 0, 40)
            userStats.BackgroundTransparency = 1
            userStats.Text = userData.followersCount .. " seguidores"
            userStats.TextColor3 = Color3.fromRGB(150, 150, 150)
            userStats.TextScaled = true
            userStats.Font = Enum.Font.SourceSans
            userStats.TextXAlignment = Enum.TextXAlignment.Left
            userStats.Parent = resultFrame
            
            -- Botón seguir
            local followButton = Instance.new("TextButton")
            followButton.Size = UDim2.new(0, 100, 0, 30)
            followButton.Position = UDim2.new(1, -110, 0, 25)
            followButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
            followButton.BorderSizePixel = 0
            followButton.Text = "Seguir"
            followButton.TextColor3 = Color3.new(1, 1, 1)
            followButton.TextScaled = true
            followButton.Font = Enum.Font.SourceSans
            followButton.Parent = resultFrame
            
            local followButtonCorner = Instance.new("UICorner")
            followButtonCorner.CornerRadius = UDim.new(0, 8)
            followButtonCorner.Parent = followButton
            
            followButton.MouseButton1Click:Connect(function()
                followUserEvent:FireServer(userData.userId)
                followButton.Text = "Siguiendo"
                followButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            end)
            
            -- Click en foto de perfil
            userPic.MouseButton1Click:Connect(function()
                showUserProfile(userData.userId)
            end)
        end
    end
    
    -- Actualizar canvas size
    discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayout.AbsoluteContentSize.Y)
end

-- Función para cargar página de crear post
function loadCreatePage()
    -- Limpiar contenido anterior
    for _, child in pairs(createFrame:GetChildren()) do
        child:Destroy()
    end
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Crear Nueva Publicación"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = createFrame
    
    -- Frame del contenido
    local postContentFrame = Instance.new("Frame")
    postContentFrame.Size = UDim2.new(1, 0, 0, 300)
    postContentFrame.Position = UDim2.new(0, 0, 0, 50)
    postContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    postContentFrame.BorderSizePixel = 0
    postContentFrame.Parent = createFrame
    
    local contentFrameCorner = Instance.new("UICorner")
    contentFrameCorner.CornerRadius = UDim.new(0, 10)
    contentFrameCorner.Parent = postContentFrame
    
    -- TextBox para el post
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
    
    -- Contador de caracteres
    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(0, 100, 0, 20)
    charCounter.Position = UDim2.new(1, -110, 0, 200)
    charCounter.BackgroundTransparency = 1
    charCounter.Text = "0/500"
    charCounter.TextColor3 = Color3.fromRGB(150, 150, 150)
    charCounter.TextScaled = true
    charCounter.Font = Enum.Font.SourceSans
    charCounter.Parent = postContentFrame
    
    -- Actualizar contador
    postTextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local length = string.len(postTextBox.Text)
        charCounter.Text = length .. "/500"
        charCounter.TextColor3 = length > 500 and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(150, 150, 150)
    end)
    
    -- Botones
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Size = UDim2.new(1, -20, 0, 50)
    buttonsFrame.Position = UDim2.new(0, 10, 0, 230)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = postContentFrame
    
    -- Botón cancelar
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
    
    -- Botón publicar
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
    
    -- Eventos de botones
    cancelButton.MouseButton1Click:Connect(function()
        postTextBox.Text = ""
        switchView("feed")
    end)
    
    publishButton.MouseButton1Click:Connect(function()
        local text = postTextBox.Text
        if text ~= "" and string.len(text) <= 500 then
            createPostEvent:FireServer(text, "")
            postTextBox.Text = ""
            switchView("feed")
            wait(1)
            loadFeed() -- Recargar feed para mostrar el nuevo post
        end
    end)
end

-- Función para cargar página de ajustes (pantalla completa)
function loadSettingsPage(userId)
    userId = userId or player.UserId
    
    -- Limpiar contenido anterior
    for _, child in pairs(settingsFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end
    
    local profileData = getProfileFunction:InvokeServer(userId)
    if not profileData then return end
    
    -- Header del perfil (pantalla completa)
    local profileHeader = Instance.new("Frame")
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
    
    -- Foto de perfil grande
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
    
    -- Badge de verificación en perfil
    if profileData.displayName == "vegetl_t" then
        local profileBadge = Instance.new("ImageLabel")
        profileBadge.Size = UDim2.new(0, 30, 0, 30)
        profileBadge.Position = UDim2.new(1, -10, 0, 0)
        profileBadge.BackgroundTransparency = 1
        profileBadge.Image = "rbxassetid://6031068421"
        profileBadge.ImageColor3 = Color3.fromRGB(29, 161, 242)
        profileBadge.Parent = bigProfilePic
    end
    
    -- Información del perfil
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 300, 0, 40)
    nameLabel.Position = UDim2.new(0, 170, 0, 40)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = profileData.displayName
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = profileHeader
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0, 400, 0, 30)
    statsLabel.Position = UDim2.new(0, 170, 0, 85)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = string.format("%d seguidores • %d siguiendo • %d posts", 
        profileData.followersCount, profileData.followingCount, profileData.postsCount)
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.TextScaled = true
    statsLabel.Font = Enum.Font.SourceSans
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = profileHeader
    
    -- Bio del usuario
    local bioLabel = Instance.new("TextLabel")
    bioLabel.Size = UDim2.new(0, 400, 0, 25)
    bioLabel.Position = UDim2.new(0, 170, 0, 120)
    bioLabel.BackgroundTransparency = 1
    bioLabel.Text = '"' .. (profileData.bio or "Sin biografía") .. '"'
    bioLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    bioLabel.TextScaled = true
    bioLabel.Font = Enum.Font.SourceSansItalic
    bioLabel.TextWrapped = true
    bioLabel.TextXAlignment = Enum.TextXAlignment.Left
    bioLabel.Parent = profileHeader
    
    -- Información adicional
    local infoFrame = Instance.new("Frame")
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
    joinDateLabel.TextScaled = true
    joinDateLabel.Font = Enum.Font.SourceSans
    joinDateLabel.TextXAlignment = Enum.TextXAlignment.Left
    joinDateLabel.Parent = infoFrame
    
    -- Actividad reciente
    local activityLabel = Instance.new("TextLabel")
    activityLabel.Size = UDim2.new(1, -20, 0, 25)
    activityLabel.Position = UDim2.new(0, 10, 0, 45)
    activityLabel.BackgroundTransparency = 1
    activityLabel.Text = "🎯 Usuario " .. (userId == player.UserId and "actual" or "visitado")
    activityLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    activityLabel.TextScaled = true
    activityLabel.Font = Enum.Font.SourceSans
    activityLabel.TextXAlignment = Enum.TextXAlignment.Left
    activityLabel.Parent = infoFrame
    
    -- Actualizar canvas size
    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
end

-- Inicializar con búsqueda en tiempo real
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if string.len(searchBox.Text) >= 3 then
        local results = searchUsersFunction:InvokeServer(searchBox.Text)
        if currentView == "discover" then
            showSearchResults(results)
        end
    end
end)

-- Inicializar interfaz
profileButton.MouseButton1Click:Connect(function()
    showUserProfile(player.UserId)
end)

-- Cargar vista inicial
switchView("feed")

-- Actualizar layouts cuando cambien los contenidos
feedLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    feedScroll.CanvasSize = UDim2.new(0, 0, 0, feedLayout.AbsoluteContentSize.Y)
end)

discoverLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayout.AbsoluteContentSize.Y)
end)

settingsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
end)

print("FaceBlox Client cargado correctamente - Todas las secciones funcionando")
