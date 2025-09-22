-- FaceBlox_Client_02_PostsAndComments
-- Parte 2: createPostFrame, showCommentsSection, createCommentWidget, verificación, helpers.
-- Este script usa la UI creada por Parte 1 (la busca en PlayerGui).
 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
 
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
 
-- Esperar UI de Parte1
local gui = playerGui:WaitForChild("FaceBloxGui")
local ui = (_G.FaceBlox and _G.FaceBlox.ui) or {
feedScroll = gui:WaitForChild("ContentFrame"):WaitForChild("FeedSection")
}
-- referencias locales
local feedScroll = ui.feedScroll
local feedLayout = ui.feedLayout
local commentsSection = ui.commentsSection
local commentsLayout = ui.commentsLayout
local musicSection = ui.musicSection
local musicLayout = ui.musicLayout
 
-- usar state y availableMusic desde _G
local state = _G.FaceBlox.state
 
-- Helpers de verificación (dos variantes; mantenemos ambas como en tu código original)
local function createVerificationBadge(parent, isVerified, xOffset, yOffset)
    if isVerified then
        local badge = Instance.new("ImageLabel")
        badge.Size = UDim2.new(0, 16, 0, 16)
        badge.Position = UDim2.new(0, xOffset or 0, 0, yOffset or 0)
        badge.BackgroundTransparency = 1
        badge.Image = "rbxassetid://125268479387354"
        badge.ImageColor3 = Color3.fromRGB(29, 161, 242)
        badge.Parent = parent
        return badge
    end
    return nil
end
 
local function createVerificationBadgeNextTo(textLabel, isVerified)
    if not isVerified then return nil end
    local parent = textLabel.Parent
    local badge = Instance.new("ImageLabel")
    badge.Name = "Badge_Verified"
    badge.Size = UDim2.new(0, 16, 0, 16)
    badge.BackgroundTransparency = 1
    badge.Image = "rbxassetid://125268479387354"
    badge.ImageColor3 = Color3.fromRGB(29, 161, 242)
    badge.AnchorPoint = Vector2.new(0, 0)
    badge.Parent = parent
    spawn(function()
        wait(0.05)
        local textExtentX = 0
        pcall(function() textExtentX = textLabel.TextBounds.X end)
            local x = (textLabel.Position and textLabel.Position.X.Offset or 0) + textExtentX + 8
            local y = (textLabel.Position and textLabel.Position.Y.Offset or 0) + (textLabel.Size and textLabel.Size.Y.Offset/2 - 8 or 0)
            badge.Position = UDim2.new(0, x, 0, y)
        end)
        return badge
    end
    
    -- getMusicTitle (usa state.availableMusic)
    local function getMusicTitle(musicId)
        for _, music in ipairs(state.availableMusic or {}) do
            if music.id == musicId then
                return music.title
            end
        end
        return "Música desconocida"
    end
    
    -- createPostFrame (copia fiel de tu bloque original con player interaction y reproductor)
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
        authorPic.Image = postData.profilePicture or ("https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(postData.authorId) .. "&width=150&height=150&format=png")
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
        
        -- Verificación al lado del nombre
        createVerificationBadgeNextTo(authorName, postData.isVerified)
        
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
        
        -- Reproductor de música (si existe) con animación y tiempo (debajo del icono de música)
        if postData.musicId and postData.musicId ~= "" then
            local musicFrame = Instance.new("Frame")
            musicFrame.Name = "MusicPlayer"
            musicFrame.Size = UDim2.new(1, -20, 0, 90)
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
            musicTitle.Size = UDim2.new(0, 260, 0, 20)
            musicTitle.Position = UDim2.new(0, 60, 0, 10)
            musicTitle.BackgroundTransparency = 1
            musicTitle.Text = getMusicTitle(postData.musicId)
            musicTitle.TextColor3 = Color3.new(1, 1, 1)
            musicTitle.Font = Enum.Font.SourceSansBold
            musicTitle.TextSize = 16
            musicTitle.TextXAlignment = Enum.TextXAlignment.Left
            musicTitle.Parent = musicFrame
            
            local timeInfo = Instance.new("TextLabel")
            timeInfo.Size = UDim2.new(0, 200, 0, 18)
            timeInfo.Position = UDim2.new(0, 60, 0, 34)
            timeInfo.BackgroundTransparency = 1
            timeInfo.Text = "Duración: --:--  •  Restante: --:--"
            timeInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
            timeInfo.Font = Enum.Font.SourceSans
            timeInfo.TextSize = 14
            timeInfo.TextXAlignment = Enum.TextXAlignment.Left
            timeInfo.Parent = musicFrame
            
            local progressBg = Instance.new("Frame")
            progressBg.Size = UDim2.new(0, 260, 0, 6)
            progressBg.Position = UDim2.new(0, 60, 0, 56)
            progressBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            progressBg.BorderSizePixel = 0
            progressBg.Parent = musicFrame
            
            local progressFill = Instance.new("Frame")
            progressFill.Size = UDim2.new(0, 0, 1, 0)
            progressFill.Position = UDim2.new(0, 0, 0, 0)
            progressFill.BackgroundColor3 = Color3.fromRGB(29, 161, 242)
            progressFill.BorderSizePixel = 0
            progressFill.Parent = progressBg
            
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
            
            local musicPlayer = Instance.new("Sound")
            musicPlayer.SoundId = "rbxassetid://" .. postData.musicId
            musicPlayer.Volume = 0.6
            musicPlayer.Parent = workspace
            
            local isPlaying = false
            local updateConn
            
            local function formatTime(sec)
                sec = math.max(0, tonumber(sec) or 0)
                local m = math.floor(sec / 60)
                local s = math.floor(sec % 60)
                return string.format("%02d:%02d", m, s)
            end
            
            local function stopUpdate()
                if updateConn then
                    updateConn:Disconnect()
                    updateConn = nil
                end
            end
            
            local function startUpdate()
                stopUpdate()
                updateConn = RunService.Heartbeat:Connect(function()
                    if not musicPlayer.IsLoaded then return end
                    local len = musicPlayer.TimeLength or 0
                    local pos = musicPlayer.TimePosition or 0
                    local remaining = math.max(0, len - pos)
                    timeInfo.Text = string.format("Duración: %s  •  Restante: %s", formatTime(len), formatTime(remaining))
                    local pct = (len > 0) and math.clamp(pos / len, 0, 1) or 0
                    progressFill.Size = UDim2.new(pct, 0, 1, 0)
                end)
            end
            
            musicPlayer.Loaded:Connect(function()
                local len = musicPlayer.TimeLength or 0
                timeInfo.Text = string.format("Duración: %s  •  Restante: %s", formatTime(len), formatTime(len))
            end)
            
            musicPlayer.Ended:Connect(function()
                isPlaying = false
                playButton.Text = "▶ Play"
                playButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                stopUpdate()
                progressFill.Size = UDim2.new(0, 0, 1, 0)
                timeInfo.Text = "Duración: " .. formatTime(musicPlayer.TimeLength or 0) .. "  •  Restante: 00:00"
            end)
            
            playButton.MouseButton1Click:Connect(function()
                if not isPlaying then
                    if not musicPlayer.IsLoaded then
                        pcall(function() musicPlayer:LoadAsync() end)
                        end
                            pcall(function() musicPlayer:Play() end)
                                isPlaying = true
                                playButton.Text = "⏸ Pause"
                                playButton.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
                                startUpdate()
                            else
                                pcall(function() musicPlayer:Pause() end)
                                    isPlaying = false
                                    playButton.Text = "▶ Play"
                                    playButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
                                    stopUpdate()
                                end
                            end)
                            
                            postFrame.Destroying:Connect(function()
                                stopUpdate()
                                pcall(function() musicPlayer:Destroy() end)
                                end)
                                end
                                    
                                    -- Botones de interacción (like / comment)
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
                                    
                                    -- Guardar referencias en state.postWidgets
                                    state.postWidgets[idStr] = {
                                    frame = postFrame,
                                    likeButton = likeButton,
                                    commentButton = commentButton,
                                    likesCount = likesCount,
                                    commentsCount = commentsCount,
                                    isLikedByUser = isLiked,
                                    contentLabel = contentLabel,
                                    postId = idStr
                                    }
                                    
                                    -- Eventos locales: authorPic, likeButton, commentButton
                                    authorPic.MouseButton1Click:Connect(function()
                                        if _G and _G.FaceBlox and type(_G.FaceBlox.functions) == "table" and type(_G.FaceBlox.functions.showUserProfile) == "function" then
                                            _G.FaceBlox.functions.showUserProfile(tonumber(postData.authorId))
                                            end
                                            end)
                                                
                                                likeButton.MouseButton1Click:Connect(function()
                                                    local wasLiked = state.postWidgets[idStr].isLikedByUser
                                                    state.postWidgets[idStr].isLikedByUser = not wasLiked
                                                    state.postWidgets[idStr].likesCount = state.postWidgets[idStr].likesCount + (wasLiked and -1 or 1)
                                                    state.postWidgets[idStr].likeButton.BackgroundColor3 = state.postWidgets[idStr].isLikedByUser and Color3.fromRGB(233, 69, 96) or Color3.fromRGB(60, 60, 60)
                                                    state.postWidgets[idStr].likeButton.Text = (state.postWidgets[idStr].isLikedByUser and "❤ " or "♡ ") .. tostring(state.postWidgets[idStr].likesCount)
                                                    -- FireServer se hace desde Parte 4 (remotes). Aquí simplemente intentamos usar referencias si existen.
                                                    if _G and _G.FaceBlox and _G.FaceBlox.remoteEvents and _G.FaceBlox.remoteEvents.LikePost then
                                                        pcall(function() _G.FaceBlox.remoteEvents.LikePost:FireServer(idStr) end)
                                                        end
                                                        end)
                                                            
                                                            commentButton.MouseButton1Click:Connect(function()
                                                                if _G and _G.FaceBlox and type(_G.FaceBlox.functions.showCommentsSection) == "function" then
                                                                    _G.FaceBlox.functions.showCommentsSection(idStr)
                                                                    end
                                                                    end)
                                                                        
                                                                        return postFrame
                                                                    end
                                                                    
                                                                    -- showCommentsSection (gran bloque copiado tal como en tu original)
                                                                    local function showCommentsSection(postId)
                                                                        _G.FaceBlox.state.currentPostId = postId
                                                                        
                                                                        -- Ocultar otras secciones
                                                                        ui.feedScroll.Visible = false
                                                                        ui.discoverFrame.Visible = false
                                                                        ui.createFrame.Visible = false
                                                                        ui.settingsFrame.Visible = false
                                                                        ui.commentsSection.Visible = true
                                                                        
                                                                        ui.navBar.Visible = false
                                                                        ui.headerFrame.Visible = false
                                                                        ui.contentFrame.Size = UDim2.new(1, 0, 1, 0)
                                                                        ui.contentFrame.Position = UDim2.new(0, 0, 0, 0)
                                                                        
                                                                        -- Limpiar commentsSection
                                                                        for _, child in pairs(ui.commentsSection:GetChildren()) do
                                                                            if child ~= ui.commentsLayout then
                                                                                child:Destroy()
                                                                            end
                                                                        end
                                                                        state.commentWidgets = {}
                                                                        
                                                                        -- Header
                                                                        local header = Instance.new("Frame")
                                                                        header.Size = UDim2.new(1, 0, 0, 60)
                                                                        header.Position = UDim2.new(0, 0, 0, 0)
                                                                        header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                                                        header.Parent = ui.commentsSection
                                                                        
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
                                                                            ui.commentsSection.Visible = false
                                                                            ui.navBar.Visible = true
                                                                            ui.headerFrame.Visible = true
                                                                            ui.contentFrame.Size = UDim2.new(1, 0, 1, -140)
                                                                            ui.contentFrame.Position = UDim2.new(0, 0, 0, 60)
                                                                            if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                _G.FaceBlox.functions.switchView("feed")
                                                                                end
                                                                                end)
                                                                                    
                                                                                    -- Scroll con comentarios
                                                                                    local commentsScroll = Instance.new("ScrollingFrame")
                                                                                    commentsScroll.Size = UDim2.new(1, 0, 1, -140)
                                                                                    commentsScroll.Position = UDim2.new(0, 0, 0, 60)
                                                                                    commentsScroll.BackgroundTransparency = 1
                                                                                    commentsScroll.Parent = ui.commentsSection
                                                                                    
                                                                                    local layout = Instance.new("UIListLayout")
                                                                                    layout.Parent = commentsScroll
                                                                                    layout.Padding = UDim.new(0, 10)
                                                                                    
                                                                                    -- Caja para escribir comentario (fija abajo)
                                                                                    local inputFrame = Instance.new("Frame")
                                                                                    inputFrame.Size = UDim2.new(1, 0, 0, 80)
                                                                                    inputFrame.Position = UDim2.new(0, 0, 1, -80)
                                                                                    inputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                                                                    inputFrame.ZIndex = 10
                                                                                    inputFrame.Parent = ui.commentsSection
                                                                                    
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
                                                                                    
                                                                                    -- Crear widget de comentario local (igual que en tu original)
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
                                                                                        
                                                                                        createVerificationBadgeNextTo(authorLabel, commentData.isVerified)
                                                                                        
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
                                                                                        
                                                                                        local buttonFrame = Instance.new("Frame")
                                                                                        buttonFrame.Size = UDim2.new(0, 100, 0, 70)
                                                                                        buttonFrame.Position = UDim2.new(1, -110, 0, 5)
                                                                                        buttonFrame.BackgroundTransparency = 1
                                                                                        buttonFrame.Parent = commentFrame
                                                                                        
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
                                                                                                if _G and _G.FaceBlox and _G.FaceBlox.remoteEvents and _G.FaceBlox.remoteEvents.DeleteComment then
                                                                                                    pcall(function() _G.FaceBlox.remoteEvents.DeleteComment:FireServer(commentData.id) end)
                                                                                                    end
                                                                                                    end)
                                                                                                    end
                                                                                                        
                                                                                                        reportCommentBtn.MouseButton1Click:Connect(function()
                                                                                                            reportCommentBtn.Text = "✓"
                                                                                                            reportCommentBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
                                                                                                            wait(1)
                                                                                                            reportCommentBtn.Text = "⚠"
                                                                                                            reportCommentBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
                                                                                                        end)
                                                                                                        
                                                                                                        state.commentWidgets[commentData.id] = commentFrame
                                                                                                        return commentFrame
                                                                                                    end
                                                                                                    
                                                                                                    -- Cargar comentarios existentes (invocar GetComments desde remoteFunctions si existe)
                                                                                                    spawn(function()
                                                                                                        if _G and _G.FaceBlox and _G.FaceBlox.remoteFunctions and _G.FaceBlox.remoteFunctions.GetComments then
                                                                                                            local ok, commentsData = pcall(function()
                                                                                                                return _G.FaceBlox.remoteFunctions.GetComments:InvokeServer(postId)
                                                                                                            end)
                                                                                                            commentsData = ok and commentsData or {}
                                                                                                            for _, commentData in ipairs(commentsData) do
                                                                                                                if not commentData.deleted then
                                                                                                                    createCommentWidget(commentData)
                                                                                                                end
                                                                                                            end
                                                                                                            commentsScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
                                                                                                        end
                                                                                                    end)
                                                                                                    
                                                                                                    postCommentButton.MouseButton1Click:Connect(function()
                                                                                                        if commentTextBox.Text ~= "" then
                                                                                                            if _G and _G.FaceBlox and _G.FaceBlox.remoteEvents and _G.FaceBlox.remoteEvents.CommentPost then
                                                                                                                pcall(function() _G.FaceBlox.remoteEvents.CommentPost:FireServer(postId, commentTextBox.Text) end)
                                                                                                                end
                                                                                                                    commentTextBox.Text = ""
                                                                                                                end
                                                                                                            end)
                                                                                                        end
                                                                                                        
                                                                                                        -- Exportar funciones a _G para que otras partes las llamen
                                                                                                        _G.FaceBlox.functions = _G.FaceBlox.functions or {}
                                                                                                            _G.FaceBlox.functions.createPostFrame = createPostFrame
                                                                                                                _G.FaceBlox.functions.showCommentsSection = showCommentsSection
                                                                                                                    _G.FaceBlox.functions.getMusicTitle = getMusicTitle
                                                                                                                        _G.FaceBlox.state = state
                                                                                                                        
                                                                                                                        print("FaceBlox Cliente - Parte 02 (Posts & Comments) cargada.")
