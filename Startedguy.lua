-- Client: FaceBlox (LocalScript) - versión corregida manteniendo tu código original
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Esperar RemoteEvents/Functions (reutilizan los que creó el server)
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

-- RemoteFunctions
local getFeedFunction = remoteEvents:WaitForChild("GetFeed")
local getProfileFunction = remoteEvents:WaitForChild("GetProfile")
local searchUsersFunction = remoteEvents:WaitForChild("SearchUsers")
local getCommentsFunction = remoteEvents:WaitForChild("GetComments")
local getUserPostsFunction = remoteEvents:WaitForChild("GetUserPosts")
local getRecommendationsFunction = remoteEvents:WaitForChild("GetRecommendations")

-- Variables (preservo nombres y estructura)
local currentView = "feed"
local currentProfileId = player.UserId
local screenGui
local mainFrame
local contentFrame
local feedScroll
local discoverFrame
local createFrame
local settingsFrame
local commentsSection -- nueva sección fullscreen para comentarios
local navButtonInstances = {}

-- map de widgets de posts para updates en tiempo real
local postWidgets = {} -- [postId] = {frame, likeButton, commentButton, likesCount, commentsCount, isLikedByUser, contentLabel}

-- Crear ScreenGui principal (mantengo tu planteamiento original)
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

-- Header con gradiente (preservo)
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

-- Logo FaceBlox (igual)
local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(0, 150, 1, 0)
logoLabel.Position = UDim2.new(0, 10, 0, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "FaceBlox"
logoLabel.TextColor3 = Color3.new(1, 1, 1)
logoLabel.TextScaled = true
logoLabel.Font = Enum.Font.SourceSansBold
logoLabel.Parent = headerFrame

-- Search box (igual)
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

-- Badge de verificación (igual)
local verifiedBadge = Instance.new("ImageLabel")
verifiedBadge.Size = UDim2.new(0, 15, 0, 15)
verifiedBadge.Position = UDim2.new(1, -5, 0, 0)
verifiedBadge.BackgroundTransparency = 1
verifiedBadge.Image = "rbxassetid://6031068421"
verifiedBadge.ImageColor3 = Color3.fromRGB(29, 161, 242)
verifiedBadge.Visible = (player.Name == "vegetl_t")
verifiedBadge.Parent = profileButton

-- Contenido principal (igual estructura)
contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -140)
contentFrame.Position = UDim2.new(0, 0, 0, 60)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- CREAR TODAS LAS SECCIONES (preservo nombres)
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

-- COMMENTS SECTION (Nueva: fullscreen dentro de contentFrame, no modal centrado)
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

-- Barra de navegación inferior (igual)
local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, 0, 0, 80)
navBar.Position = UDim2.new(0, 0, 1, -80)
navBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
navBar.BorderSizePixel = 0
navBar.Parent = mainFrame

-- Botones de navegación (restauro tus iconos y nombres)
local navButtons = {
    {name = "Inicio", icon = "🏠", view = "feed"},
    {name = "Descubrir", icon = "🔍", view = "discover"},
    {name = "Crear", icon = "➕", view = "create"},
    {name = "Perfil", icon = "👤", view = "settings"}
}

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

-- Función para crear un frame de post visual (mejorada pero manteniendo tu estructura)
local function createPostFrame(postData)
    local idStr = tostring(postData.id)
    local postFrame = Instance.new("Frame")
    postFrame.Name = "PostFrame_" .. idStr
    postFrame.Size = UDim2.new(1, 0, 0, 10) -- AutomaticSize controlará altura
    postFrame.AutomaticSize = Enum.AutomaticSize.Y
    postFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    postFrame.BorderSizePixel = 0
    postFrame.Parent = feedScroll
    
    local postCorner = Instance.new("UICorner")
    postCorner.CornerRadius = UDim.new(0, 10)
    postCorner.Parent = postFrame

    -- Usamos UIListLayout para que los elementos se apilen y no se solapen
    local postLayout = Instance.new("UIListLayout")
    postLayout.Padding = UDim.new(0, 6)
    postLayout.SortOrder = Enum.SortOrder.LayoutOrder
    postLayout.Parent = postFrame

    -- Header del post (autor)
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

    -- Nombre del autor (a la derecha de la imagen)
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

    -- Contenido del post (texto grande y AutomaticSize para mostrar completo)
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "Content"
    contentLabel.Size = UDim2.new(1, -20, 0, 10)
    contentLabel.Position = UDim2.new(0, 10, 0, 60)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = postData.content or ""
    contentLabel.TextColor3 = Color3.new(1, 1, 1)
    contentLabel.TextWrapped = true
    contentLabel.Font = Enum.Font.SourceSans
    contentLabel.TextSize = 20 -- letra más grande
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    contentLabel.Parent = postFrame

    -- Botones de interaccion (ubicados abajo para evitar solapamiento con el contenido largo)
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

    -- Inicializar estados y contadores
    local likesCount = postData.likesCount or 0
    local commentsCount = postData.commentsCount or 0
    local isLiked = postData.isLikedByUser or false

    likeButton.Text = (isLiked and "❤ " or "♡ ") .. tostring(likesCount)
    likeButton.BackgroundColor3 = isLiked and Color3.fromRGB(233, 69, 96) or Color3.fromRGB(60, 60, 60)
    commentButton.Text = "💬 " .. tostring(commentsCount)
    commentButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

    -- Guardar referencias para actualizaciones en tiempo real
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
        -- Mostrar perfil del autor en pantalla completa de perfil
        showUserProfile(postData.authorId)
    end)

    likeButton.MouseButton1Click:Connect(function()
        -- Optimistic UI (se actualizará con broadcast del server)
        local wasLiked = postWidgets[idStr].isLikedByUser
        postWidgets[idStr].isLikedByUser = not wasLiked
        postWidgets[idStr].likesCount = postWidgets[idStr].likesCount + (wasLiked and -1 or 1)
        postWidgets[idStr].likeButton.BackgroundColor3 = postWidgets[idStr].isLikedByUser and Color3.fromRGB(233, 69, 96) or Color3.fromRGB(60, 60, 60)
        postWidgets[idStr].likeButton.Text = (postWidgets[idStr].isLikedByUser and "❤ " or "♡ ") .. tostring(postWidgets[idStr].likesCount)
        likePostEvent:FireServer(idStr)
    end)

    commentButton.MouseButton1Click:Connect(function()
        -- Abrir la sección de comentarios (pantalla completa dentro de contentFrame)
        showCommentsSection(idStr)
    end)

    return postFrame
end

-- Función que muestra la sección de comentarios (pantalla completa dentro de contentFrame)
function showCommentsSection(postId)
    -- Ocultar otras secciones y mostrar commentsSection a pantalla completa
    feedScroll.Visible = false
    discoverFrame.Visible = false
    createFrame.Visible = false
    settingsFrame.Visible = false
    commentsSection.Visible = true

    -- Limpiar commentsSection (solo elementos previos)
    for _, child in pairs(commentsSection:GetChildren()) do
        if child ~= commentsLayout then
            child:Destroy()
        end
    end

    -- Header para commentsSection
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
    inputFrame.Parent = commentsSection

    local commentTextBox = Instance.new("TextBox")
    commentTextBox.Size = UDim2.new(1, -120, 0, 52)
    commentTextBox.Position = UDim2.new(0, 10, 0, 14)
    commentTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    commentTextBox.PlaceholderText = "Escribe un comentario..."
    commentTextBox.TextColor3 = Color3.new(1, 1, 1)
    commentTextBox.Font = Enum.Font.SourceSans
    commentTextBox.TextSize = 18
    commentTextBox.Parent = inputFrame

    local postCommentButton = Instance.new("TextButton")
    postCommentButton.Size = UDim2.new(0, 100, 0, 52)
    postCommentButton.Position = UDim2.new(1, -110, 0, 14)
    postCommentButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
    postCommentButton.Text = "Enviar"
    postCommentButton.TextColor3 = Color3.new(1, 1, 1)
    postCommentButton.Font = Enum.Font.SourceSansBold
    postCommentButton.TextSize = 18
    postCommentButton.Parent = inputFrame

    -- Cargar comentarios del servidor (no bloqueante)
    spawn(function()
        local commentsData = getCommentsFunction:InvokeServer(postId) or {}
        for _, commentData in ipairs(commentsData) do
            local commentFrame = Instance.new("Frame")
            commentFrame.Size = UDim2.new(1, -20, 0, 70)
            commentFrame.BackgroundTransparency = 1
            commentFrame.Parent = commentsScroll

            local authorLabel = Instance.new("TextLabel")
            authorLabel.Size = UDim2.new(1, 0, 0, 20)
            authorLabel.BackgroundTransparency = 1
            authorLabel.Font = Enum.Font.SourceSansBold
            authorLabel.Text = commentData.authorName
            authorLabel.TextColor3 = Color3.new(1,1,1)
            authorLabel.TextSize = 16
            authorLabel.Parent = commentFrame

            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, 0, 0, 46)
            contentLabel.Position = UDim2.new(0, 0, 0, 20)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Font = Enum.Font.SourceSans
            contentLabel.Text = commentData.content
            contentLabel.TextWrapped = true
            contentLabel.TextSize = 18
            contentLabel.TextColor3 = Color3.fromRGB(220,220,220)
            contentLabel.AutomaticSize = Enum.AutomaticSize.Y
            contentLabel.Parent = commentFrame
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

-- showUserProfile ahora carga perfil y posts en settingsFrame sin mezclar con feed/comments
function showUserProfile(userId)
    switchView("settings")
    currentProfileId = userId
    loadSettingsPage(userId)
end

-- switchView (mantengo tu lógica pero añado control de commentsSection)
function switchView(view)
    currentView = view
    
    feedScroll.Visible = false
    discoverFrame.Visible = false
    createFrame.Visible = false
    settingsFrame.Visible = false
    commentsSection.Visible = false
    
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

-- Cargar feed (limpia correctamente, crea tarjetas con AutomaticSize)
function loadFeed()
    -- eliminar solo los PostFrame_* del feed
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

-- Discover: búsqueda + recomendaciones (no vacío)
function loadDiscoverPage()
    -- limpiar
    for _, child in pairs(discoverFrame:GetChildren()) do
        if child.Name:match("UserResult") then
            child:Destroy()
        end
    end
    
    -- mostrar recomendaciones (no bloqueante)
    spawn(function()
        local recs = getRecommendationsFunction:InvokeServer()
        if recs and #recs > 0 then
            for i, u in ipairs(recs) do
                local resultFrame = Instance.new("Frame")
                resultFrame.Name = "UserResult"
                resultFrame.Size = UDim2.new(1, 0, 0, 80)
                resultFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                resultFrame.BorderSizePixel = 0
                resultFrame.Parent = discoverFrame
                
                local resultCorner = Instance.new("UICorner")
                resultCorner.CornerRadius = UDim.new(0, 10)
                resultCorner.Parent = resultFrame
                
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
                
                local userName = Instance.new("TextLabel")
                userName.Size = UDim2.new(0, 200, 0, 25)
                userName.Position = UDim2.new(0, 80, 0, 15)
                userName.BackgroundTransparency = 1
                userName.Text = u.displayName
                userName.TextColor3 = Color3.new(1, 1, 1)
                userName.TextScaled = false
                userName.Font = Enum.Font.SourceSansBold
                userName.TextSize = 18
                userName.TextXAlignment = Enum.TextXAlignment.Left
                userName.Parent = resultFrame
                
                local userStats = Instance.new("TextLabel")
                userStats.Size = UDim2.new(0, 200, 0, 20)
                userStats.Position = UDim2.new(0, 80, 0, 40)
                userStats.BackgroundTransparency = 1
                userStats.Text = (u.followersCount or 0) .. " seguidores"
                userStats.TextColor3 = Color3.fromRGB(150, 150, 150)
                userStats.TextScaled = false
                userStats.Font = Enum.Font.SourceSans
                userStats.TextSize = 14
                userStats.TextXAlignment = Enum.TextXAlignment.Left
                userStats.Parent = resultFrame
                
                local followButton = Instance.new("TextButton")
                followButton.Size = UDim2.new(0, 100, 0, 30)
                followButton.Position = UDim2.new(1, -110, 0, 25)
                followButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
                followButton.BorderSizePixel = 0
                followButton.Text = "Seguir"
                followButton.TextColor3 = Color3.new(1, 1, 1)
                followButton.Font = Enum.Font.SourceSans
                followButton.TextSize = 16
                followButton.Parent = resultFrame
                
                followButton.MouseButton1Click:Connect(function()
                    followUserEvent:FireServer(u.userId)
                    -- refrescar recomendaciones para remover el usuario seguido
                    loadDiscoverPage()
                end)
                
                userPic.MouseButton1Click:Connect(function()
                    showUserProfile(u.userId)
                end)
            end
        else
            -- Si no hay recomendaciones, mostrar texto
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

-- Mostrar resultados de búsqueda (en Discover)
function showSearchResults(results)
    for _, child in pairs(discoverFrame:GetChildren()) do
        if child.Name:match("UserResult") then
            child:Destroy()
        end
    end
    
    if results then
        for _, userData in ipairs(results) do
            local resultFrame = Instance.new("Frame")
            resultFrame.Name = "UserResult"
            resultFrame.Size = UDim2.new(1, 0, 0, 80)
            resultFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            resultFrame.BorderSizePixel = 0
            resultFrame.Parent = discoverFrame
            
            local resultCorner = Instance.new("UICorner")
            resultCorner.CornerRadius = UDim.new(0, 10)
            resultCorner.Parent = resultFrame
            
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
            
            local userName = Instance.new("TextLabel")
            userName.Size = UDim2.new(0, 200, 0, 25)
            userName.Position = UDim2.new(0, 80, 0, 15)
            userName.BackgroundTransparency = 1
            userName.Text = userData.displayName
            userName.TextColor3 = Color3.new(1, 1, 1)
            userName.Font = Enum.Font.SourceSansBold
            userName.TextSize = 18
            userName.TextXAlignment = Enum.TextXAlignment.Left
            userName.Parent = resultFrame
            
            local userStats = Instance.new("TextLabel")
            userStats.Size = UDim2.new(0, 200, 0, 20)
            userStats.Position = UDim2.new(0, 80, 0, 40)
            userStats.BackgroundTransparency = 1
            userStats.Text = "0 seguidores"
            userStats.TextColor3 = Color3.fromRGB(150, 150, 150)
            userStats.Font = Enum.Font.SourceSans
            userStats.TextSize = 14
            userStats.TextXAlignment = Enum.TextXAlignment.Left
            userStats.Parent = resultFrame
            
            local followButton = Instance.new("TextButton")
            followButton.Size = UDim2.new(0, 100, 0, 30)
            followButton.Position = UDim2.new(1, -110, 0, 25)
            followButton.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
            followButton.BorderSizePixel = 0
            followButton.Text = "Seguir"
            followButton.TextColor3 = Color3.new(1, 1, 1)
            followButton.Font = Enum.Font.SourceSans
            followButton.TextSize = 16
            followButton.Parent = resultFrame
            
            followButton.MouseButton1Click:Connect(function()
                followUserEvent:FireServer(userData.userId)
            end)
            
            userPic.MouseButton1Click:Connect(function()
                showUserProfile(userData.userId)
            end)
        end
    end
    
    discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayout.AbsoluteContentSize.Y)
end

-- Crear página de crear post (mantengo tu UI y funcionalidad)
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
    
    cancelButton.MouseButton1Click:Connect(function()
        postTextBox.Text = ""
        switchView("feed")
    end)
    
    publishButton.MouseButton1Click:Connect(function()
        local text = postTextBox.Text
        if text ~= "" and string.len(text) <= 2000 then
            createPostEvent:FireServer(text, "")
            postTextBox.Text = ""
            switchView("feed")
        end
    end)
end

-- Cargar página de ajustes (perfil) — ahora no mezcla comentarios ni feed
function loadSettingsPage(userId)
    -- limpiar solo elementos del settingsFrame (sin tocar los layouts)
    for _, child in pairs(settingsFrame:GetChildren()) do
        if child:IsA("UIListLayout") == false then
            child:Destroy()
        end
    end
    
    -- loader visible mientras carga
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
        
        -- limpiar loader y crear header con los datos del perfil (solo de ese usuario)
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
        
        if profileData.isAdmin then
            local profileBadge = Instance.new("ImageLabel")
            profileBadge.Size = UDim2.new(0, 30, 0, 30)
            profileBadge.Position = UDim2.new(1, -10, 0, 0)
            profileBadge.BackgroundTransparency = 1
            profileBadge.Image = "rbxassetid://6031068421"
            profileBadge.ImageColor3 = Color3.fromRGB(29, 161, 242)
            profileBadge.Parent = bigProfilePic
        end
        
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
        
        -- Cargar y mostrar los posts del perfil (solo de ese usuario; evita mezclar comentarios)
        local userPosts = getUserPostsFunction:InvokeServer(userId)
        for _, postData in ipairs(userPosts) do
            local pf = createPostFrame(postData)
            pf.Parent = settingsFrame
        end
        
        settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsLayout.AbsoluteContentSize.Y)
    end)
end

-- Inicializar búsqueda en tiempo real (en discover)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if string.len(searchBox.Text) >= 3 and currentView == "discover" then
        local results = searchUsersFunction:InvokeServer(searchBox.Text)
        showSearchResults(results)
    end
end)

-- Inicializar interfaz (perfil propio)
profileButton.MouseButton1Click:Connect(function()
    showUserProfile(player.UserId)
end)

-- Cargar vista inicial
switchView("feed")

-- Ajustar CanvasSize cuando cambian layouts
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

-- Broadcast listeners para actualizar UI en tiempo real (preservo compatibilidad)
postCreatedEvent.OnClientEvent:Connect(function(postData)
    -- añadir al feed como tarjeta (manteniendo orden)
    local pf = createPostFrame(postData)
    pf.Parent = feedScroll
    feedScroll.CanvasSize = UDim2.new(0, 0, 0, feedLayout.AbsoluteContentSize.Y)
end)

postUpdatedEvent.OnClientEvent:Connect(function(postId, likesCount, commentsCount)
    local idStr = tostring(postId)
    if postWidgets[idStr] then
        postWidgets[idStr].likesCount = likesCount
        postWidgets[idStr].commentsCount = commentsCount
        -- actualizar textos y colores respetando estado local de isLikedByUser
        local liked = postWidgets[idStr].isLikedByUser
        postWidgets[idStr].likeButton.Text = (liked and "❤ " or "♡ ") .. tostring(likesCount)
        postWidgets[idStr].commentButton.Text = "💬 " .. tostring(commentsCount)
    end
end)

commentAddedEvent.OnClientEvent:Connect(function(postId, commentData)
    local idStr = tostring(postId)
    if postWidgets[idStr] then
        postWidgets[idStr].commentsCount = (postWidgets[idStr].commentsCount or 0) + 1
        postWidgets[idStr].commentButton.Text = "💬 " .. tostring(postWidgets[idStr].commentsCount)
    end
    -- si la sección de comentarios está abierta para ese post, añadir comentario abajo
    if commentsSection.Visible then
        -- verificar si la sección actual corresponde al post (comprobación simple via título)
        -- para simplicidad, siempre recargamos la sección si está abierta
        -- append comentario a la lista:
        local commentsScroll = commentsSection:FindFirstChildWhichIsA("ScrollingFrame")
        if commentsScroll then
            local cf = Instance.new("Frame")
            cf.Size = UDim2.new(1, -20, 0, 70)
            cf.BackgroundTransparency = 1
            cf.Parent = commentsScroll

            local authorLabel = Instance.new("TextLabel")
            authorLabel.Size = UDim2.new(1, 0, 0, 20)
            authorLabel.BackgroundTransparency = 1
            authorLabel.Font = Enum.Font.SourceSansBold
            authorLabel.Text = commentData.authorName
            authorLabel.TextColor3 = Color3.new(1,1,1)
            authorLabel.TextSize = 16
            authorLabel.Parent = cf

            local contentLabel = Instance.new("TextLabel")
            contentLabel.Size = UDim2.new(1, 0, 0, 46)
            contentLabel.Position = UDim2.new(0, 0, 0, 20)
            contentLabel.BackgroundTransparency = 1
            contentLabel.Font = Enum.Font.SourceSans
            contentLabel.Text = commentData.content
            contentLabel.TextWrapped = true
            contentLabel.TextSize = 18
            contentLabel.TextColor3 = Color3.fromRGB(220,220,220)
            contentLabel.AutomaticSize = Enum.AutomaticSize.Y
            contentLabel.Parent = cf
        end
    end
end)

followUpdatedEvent.OnClientEvent:Connect(function(followerId, targetUserId, isFollowing)
    -- si estás viendo el perfil de target, recargar el header para actualizar botón y contadores
    if tostring(targetUserId) == tostring(currentProfileId) and settingsFrame.Visible then
        loadSettingsPage(currentProfileId)
    end
end)

print("FaceBlox Client cargado correctamente - Todas las secciones funcionando")
