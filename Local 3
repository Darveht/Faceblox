-- FaceBlox_Client_03_PagesAndUIActions
-- Parte 3: loaders (loadFeed, loadDiscoverPage, loadCreatePage, loadSettingsPage),
-- createUserResultFrame, search UI behaviors, music selection UI, report modal, switchView.
-- Usa las funciones de Parte2 y UI de Parte1.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local gui = playerGui:WaitForChild("FaceBloxGui")
local ui = _G.FaceBlox.ui
local state = _G.FaceBlox.state

-- Helpers
local function createUserResultFrame(userData, parent)
    local resultFrame = Instance.new("Frame")
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
    userPic.Image = userData.profilePicture or ("https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(userData.userId) .. "&width=150&height=150&format=png")
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
    
    -- Verificación
    if _G.FaceBlox and _G.FaceBlox.functions and _G.FaceBlox.functions.getMusicTitle then
        -- usar createVerificationBadgeNextTo definida en Parte2 (accesible si fue exportada)
    end
    -- Intentar llamar verificación (si existe)
    if _G.FaceBlox and _G.FaceBlox.functions and type(_G.FaceBlox.functions.createVerificationBadgeNextTo) == "function" then
        pcall(function() _G.FaceBlox.functions.createVerificationBadgeNextTo(userName, userData.isVerified) end)
        end
            
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
                if _G and _G.FaceBlox and _G.FaceBlox.remoteEvents and _G.FaceBlox.remoteEvents.FollowUser then
                    pcall(function() _G.FaceBlox.remoteEvents.FollowUser:FireServer(userData.userId) end)
                    end
                        wait(0.5)
                        if _G and _G.FaceBlox and type(_G.FaceBlox.functions.loadDiscoverPage) == "function" then
                            _G.FaceBlox.functions.loadDiscoverPage()
                            end
                            end)
                                
                                reportButton.MouseButton1Click:Connect(function()
                                    if _G and _G.FaceBlox and type(_G.FaceBlox.functions.showReportModal) == "function" then
                                        _G.FaceBlox.functions.showReportModal(userData.userId, userData.displayName)
                                        end
                                        end)
                                            
                                            userPic.MouseButton1Click:Connect(function()
                                                if _G and _G.FaceBlox and type(_G.FaceBlox.functions.showUserProfile) == "function" then
                                                    _G.FaceBlox.functions.showUserProfile(tonumber(userData.userId))
                                                    end
                                                    end)
                                                    end
                                                        
                                                        -- showSearchResults: limpia y muestra resultados
                                                        local function showSearchResults(results)
                                                            for _, child in pairs(ui.discoverFrame:GetChildren()) do
                                                                if child.Name:match("^UserResult") or child.Name == "SectionTitle" or child.Name == "NoRecs" or child.Name == "SearchTitle" then
                                                                    child:Destroy()
                                                                end
                                                            end
                                                            
                                                            local searchTitle = Instance.new("TextLabel")
                                                            searchTitle.Name = "SearchTitle"
                                                            searchTitle.Size = UDim2.new(1, 0, 0, 40)
                                                            searchTitle.BackgroundTransparency = 1
                                                            searchTitle.Text = "🔍 Resultados de Búsqueda"
                                                            searchTitle.TextColor3 = Color3.new(1, 1, 1)
                                                            searchTitle.Font = Enum.Font.SourceSansBold
                                                            searchTitle.TextSize = 20
                                                            searchTitle.Parent = ui.discoverFrame
                                                            
                                                            if results and #results > 0 then
                                                                for _, userData in ipairs(results) do
                                                                    createUserResultFrame(userData, ui.discoverFrame)
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
                                                                noResults.Parent = ui.discoverFrame
                                                            end
                                                            
                                                            ui.discoverFrame.CanvasSize = UDim2.new(0, 0, 0, ui.discoverLayout.AbsoluteContentSize.Y)
                                                        end
                                                        
                                                        -- loadFeed: obtiene feed desde RemoteFunction GetFeed (Parte4 expone remoteFunctions)
                                                        local function loadFeed()
                                                            -- Limpiar
                                                            for _, child in pairs(ui.feedScroll:GetChildren()) do
                                                                if child.Name:match("^PostFrame_") then
                                                                    child:Destroy()
                                                                end
                                                            end
                                                            state.postWidgets = {}
                                                            
                                                            if _G and _G.FaceBlox and _G.FaceBlox.remoteFunctions and _G.FaceBlox.remoteFunctions.GetFeed then
                                                                local ok, feedData = pcall(function() return _G.FaceBlox.remoteFunctions.GetFeed:InvokeServer() end)
                                                                    feedData = ok and feedData or {}
                                                                    if feedData then
                                                                        for _, postData in ipairs(feedData) do
                                                                            local pf = _G.FaceBlox.functions.createPostFrame(postData)
                                                                                pf.Parent = ui.feedScroll
                                                                            end
                                                                        end
                                                                    end
                                                                    
                                                                    ui.feedScroll.CanvasSize = UDim2.new(0, 0, 0, ui.feedLayout.AbsoluteContentSize.Y)
                                                                end
                                                                
                                                                -- loadDiscoverPage: obtener recomendaciones y mostrar
                                                                local function loadDiscoverPage()
                                                                    -- limpiar previos
                                                                    for _, child in pairs(ui.discoverFrame:GetChildren()) do
                                                                        if child.Name:match("^UserResult") or child.Name == "SectionTitle" or child.Name == "NoRecs" or child.Name == "SearchTitle" then
                                                                            child:Destroy()
                                                                        end
                                                                    end
                                                                    
                                                                    if _G and _G.FaceBlox and _G.FaceBlox.remoteFunctions and _G.FaceBlox.remoteFunctions.GetRecommendations then
                                                                        spawn(function()
                                                                            local ok, recs = pcall(function() return _G.FaceBlox.remoteFunctions.GetRecommendations:InvokeServer() end)
                                                                                recs = ok and recs or {}
                                                                                if recs and #recs > 0 then
                                                                                    for i, u in ipairs(recs) do
                                                                                        createUserResultFrame(u, ui.discoverFrame)
                                                                                    end
                                                                                else
                                                                                    local empty = Instance.new("TextLabel")
                                                                                    empty.Name = "NoRecs"
                                                                                    empty.Size = UDim2.new(1, 0, 0, 60)
                                                                                    empty.BackgroundTransparency = 1
                                                                                    empty.Text = "No hay recomendaciones por ahora. Usa la búsqueda para encontrar usuarios."
                                                                                    empty.TextColor3 = Color3.new(1,1,1)
                                                                                    empty.Font = Enum.Font.SourceSans
                                                                                    empty.TextSize = 16
                                                                                    empty.Parent = ui.discoverFrame
                                                                                end
                                                                                ui.discoverFrame.CanvasSize = UDim2.new(0, 0, 0, ui.discoverLayout.AbsoluteContentSize.Y)
                                                                            end)
                                                                        end
                                                                    end
                                                                    
                                                                    -- loadCreatePage: UI de creación -> similar al tuyo
                                                                    local function loadCreatePage()
                                                                        for _, child in pairs(ui.createFrame:GetChildren()) do
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
                                                                        titleLabel.Parent = ui.createFrame
                                                                        
                                                                        local postContentFrame = Instance.new("Frame")
                                                                        postContentFrame.Size = UDim2.new(1, 0, 0, 300)
                                                                        postContentFrame.Position = UDim2.new(0, 0, 0, 50)
                                                                        postContentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                                                                        postContentFrame.BorderSizePixel = 0
                                                                        postContentFrame.Parent = ui.createFrame
                                                                        
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
                                                                        musicButton.Size = UDim2.new(0, 180, 0, 40)
                                                                        musicButton.Position = UDim2.new(0, 0, 0, 5)
                                                                        musicButton.BackgroundColor3 = Color3.fromRGB(156, 39, 176)
                                                                        musicButton.BorderSizePixel = 0
                                                                        musicButton.Text = state.selectedMusicId ~= "" and "🎵 " .. (_G.FaceBlox.functions.getMusicTitle and _G.FaceBlox.functions.getMusicTitle(state.selectedMusicId) or "") or "🎵 Agregar Música"
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
                                                                                if _G and _G.FaceBlox and type(_G.FaceBlox.functions.showMusicSelection) == "function" then
                                                                                    _G.FaceBlox.functions.showMusicSelection()
                                                                                    end
                                                                                    end)
                                                                                        
                                                                                        cancelButton.MouseButton1Click:Connect(function()
                                                                                            postTextBox.Text = ""
                                                                                            state.selectedMusicId = ""
                                                                                            if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                _G.FaceBlox.functions.switchView("feed")
                                                                                                end
                                                                                                end)
                                                                                                    
                                                                                                    publishButton.MouseButton1Click:Connect(function()
                                                                                                        local text = postTextBox.Text
                                                                                                        if text ~= "" and string.len(text) <= 2000 then
                                                                                                            if _G and _G.FaceBlox and _G.FaceBlox.remoteEvents and _G.FaceBlox.remoteEvents.CreatePost then
                                                                                                                pcall(function() _G.FaceBlox.remoteEvents.CreatePost:FireServer(text, "", state.selectedMusicId) end)
                                                                                                                end
                                                                                                                    postTextBox.Text = ""
                                                                                                                    state.selectedMusicId = ""
                                                                                                                    if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                                        _G.FaceBlox.functions.switchView("feed")
                                                                                                                        end
                                                                                                                        end
                                                                                                                        end)
                                                                                                                        end
                                                                                                                            
                                                                                                                            -- loadSettingsPage (usa remoteFunctions.GetProfile e GetUserPosts)
                                                                                                                            local function loadSettingsPage(userId)
                                                                                                                                for _, child in pairs(ui.settingsFrame:GetChildren()) do
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
                                                                                                                                loader.Parent = ui.settingsFrame
                                                                                                                                
                                                                                                                                spawn(function()
                                                                                                                                    if _G and _G.FaceBlox and _G.FaceBlox.remoteFunctions and _G.FaceBlox.remoteFunctions.GetProfile then
                                                                                                                                        local ok, profileData = pcall(function() return _G.FaceBlox.remoteFunctions.GetProfile:InvokeServer(userId) end)
                                                                                                                                            profileData = ok and profileData or nil
                                                                                                                                            if not profileData then
                                                                                                                                                loader.Text = "Usuario no encontrado"
                                                                                                                                                return
                                                                                                                                            end
                                                                                                                                            
                                                                                                                                            for _, child in pairs(ui.settingsFrame:GetChildren()) do
                                                                                                                                                if child:IsA("UIListLayout") == false then child:Destroy() end
                                                                                                                                            end
                                                                                                                                            
                                                                                                                                            local profileHeader = Instance.new("Frame")
                                                                                                                                            profileHeader.Name = "ProfileHeader"
                                                                                                                                            profileHeader.Size = UDim2.new(1, 0, 0, 200)
                                                                                                                                            profileHeader.BackgroundColor3 = Color3.fromRGB(59, 89, 152)
                                                                                                                                            profileHeader.BorderSizePixel = 0
                                                                                                                                            profileHeader.Parent = ui.settingsFrame
                                                                                                                                            
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
                                                                                                                                            bigProfilePic.Image = profileData.profilePicture or ("https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(userId) .. "&width=150&height=150&format=png")
                                                                                                                                            bigProfilePic.Parent = profileHeader
                                                                                                                                            
                                                                                                                                            local bigPicCorner = Instance.new("UICorner")
                                                                                                                                            bigPicCorner.CornerRadius = UDim.new(0.5, 0)
                                                                                                                                            bigPicCorner.Parent = bigProfilePic
                                                                                                                                            
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
                                                                                                                                            
                                                                                                                                            -- Verificación en perfil
                                                                                                                                            if _G.FaceBlox and _G.FaceBlox.functions and type(_G.FaceBlox.functions.createVerificationBadgeNextTo) == "function" then
                                                                                                                                                pcall(function() _G.FaceBlox.functions.createVerificationBadgeNextTo(nameLabel, profileData.isVerified or profileData.isAdmin) end)
                                                                                                                                                end
                                                                                                                                                    
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
                                                                                                                                                    infoFrame.Parent = ui.settingsFrame
                                                                                                                                                    
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
                                                                                                                                                    if _G and _G.FaceBlox and _G.FaceBlox.remoteFunctions and _G.FaceBlox.remoteFunctions.GetUserPosts then
                                                                                                                                                        local ok, userPosts = pcall(function() return _G.FaceBlox.remoteFunctions.GetUserPosts:InvokeServer(userId) end)
                                                                                                                                                            userPosts = ok and userPosts or {}
                                                                                                                                                            for _, postData in ipairs(userPosts) do
                                                                                                                                                                local pf = _G.FaceBlox.functions.createPostFrame(postData)
                                                                                                                                                                    pf.Parent = ui.settingsFrame
                                                                                                                                                                end
                                                                                                                                                            end
                                                                                                                                                            
                                                                                                                                                            ui.settingsFrame.CanvasSize = UDim2.new(0, 0, 0, ui.settingsLayout.AbsoluteContentSize.Y)
                                                                                                                                                        end
                                                                                                                                                    end)
                                                                                                                                                end
                                                                                                                                                
                                                                                                                                                -- showReportModal (copiado de tu original)
                                                                                                                                                local function showReportModal(userId, displayName)
                                                                                                                                                    ui.feedScroll.Visible = false
                                                                                                                                                    ui.discoverFrame.Visible = false
                                                                                                                                                    ui.createFrame.Visible = false
                                                                                                                                                    ui.settingsFrame.Visible = false
                                                                                                                                                    ui.commentsSection.Visible = false
                                                                                                                                                    ui.reportSection.Visible = true
                                                                                                                                                    
                                                                                                                                                    ui.navBar.Visible = false
                                                                                                                                                    ui.headerFrame.Visible = false
                                                                                                                                                    ui.contentFrame.Size = UDim2.new(1, 0, 1, 0)
                                                                                                                                                    ui.contentFrame.Position = UDim2.new(0, 0, 0, 0)
                                                                                                                                                    
                                                                                                                                                    for _, child in pairs(ui.reportSection:GetChildren()) do
                                                                                                                                                        child:Destroy()
                                                                                                                                                    end
                                                                                                                                                    
                                                                                                                                                    local header = Instance.new("Frame")
                                                                                                                                                    header.Size = UDim2.new(1, 0, 0, 60)
                                                                                                                                                    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                                                                                                                                    header.Parent = ui.reportSection
                                                                                                                                                    
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
                                                                                                                                                        ui.reportSection.Visible = false
                                                                                                                                                        ui.navBar.Visible = true
                                                                                                                                                        ui.headerFrame.Visible = true
                                                                                                                                                        ui.contentFrame.Size = UDim2.new(1, 0, 1, -140)
                                                                                                                                                        ui.contentFrame.Position = UDim2.new(0, 0, 0, 60)
                                                                                                                                                        if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                                                                            _G.FaceBlox.functions.switchView("discover")
                                                                                                                                                            end
                                                                                                                                                            end)
                                                                                                                                                                
                                                                                                                                                                local contentScroll = Instance.new("ScrollingFrame")
                                                                                                                                                                contentScroll.Size = UDim2.new(1, -40, 1, -140)
                                                                                                                                                                contentScroll.Position = UDim2.new(0, 20, 0, 80)
                                                                                                                                                                contentScroll.BackgroundTransparency = 1
                                                                                                                                                                contentScroll.Parent = ui.reportSection
                                                                                                                                                                
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
                                                                                                                                                                submitFrame.Parent = ui.reportSection
                                                                                                                                                                
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
                                                                                                                                                                        if _G and _G.FaceBlox and _G.FaceBlox.remoteEvents and _G.FaceBlox.remoteEvents.ReportUser then
                                                                                                                                                                            pcall(function() _G.FaceBlox.remoteEvents.ReportUser:FireServer(userId, selectedReason) end)
                                                                                                                                                                            end
                                                                                                                                                                                
                                                                                                                                                                                submitButton.Text = "¡Gracias! Los moderadores revisarán el problema"
                                                                                                                                                                                submitButton.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
                                                                                                                                                                                submitButton.Enabled = false
                                                                                                                                                                                
                                                                                                                                                                                wait(3)
                                                                                                                                                                                ui.reportSection.Visible = false
                                                                                                                                                                                ui.navBar.Visible = true
                                                                                                                                                                                ui.headerFrame.Visible = true
                                                                                                                                                                                ui.contentFrame.Size = UDim2.new(1, 0, 1, -140)
                                                                                                                                                                                ui.contentFrame.Position = UDim2.new(0, 0, 0, 60)
                                                                                                                                                                                if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                                                                                                    _G.FaceBlox.functions.switchView("discover")
                                                                                                                                                                                    end
                                                                                                                                                                                    else
                                                                                                                                                                                        submitButton.Text = "Selecciona una razón"
                                                                                                                                                                                        submitButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                                                                                                                                                                                        wait(1)
                                                                                                                                                                                        submitButton.Text = "Enviar Reporte"
                                                                                                                                                                                        submitButton.BackgroundColor3 = Color3.fromRGB(220, 20, 60)
                                                                                                                                                                                    end
                                                                                                                                                                                end)
                                                                                                                                                                            end
                                                                                                                                                                            
                                                                                                                                                                            -- showMusicSelection: muestra pistas (state.availableMusic)
                                                                                                                                                                            local function showMusicSelection()
                                                                                                                                                                                ui.feedScroll.Visible = false
                                                                                                                                                                                ui.discoverFrame.Visible = false
                                                                                                                                                                                ui.createFrame.Visible = false
                                                                                                                                                                                ui.settingsFrame.Visible = false
                                                                                                                                                                                ui.commentsSection.Visible = false
                                                                                                                                                                                ui.musicSection.Visible = true
                                                                                                                                                                                
                                                                                                                                                                                ui.navBar.Visible = false
                                                                                                                                                                                ui.headerFrame.Visible = false
                                                                                                                                                                                ui.contentFrame.Size = UDim2.new(1, 0, 1, 0)
                                                                                                                                                                                ui.contentFrame.Position = UDim2.new(0, 0, 0, 0)
                                                                                                                                                                                
                                                                                                                                                                                for _, child in pairs(ui.musicSection:GetChildren()) do
                                                                                                                                                                                    if child ~= ui.musicLayout then
                                                                                                                                                                                        child:Destroy()
                                                                                                                                                                                    end
                                                                                                                                                                                end
                                                                                                                                                                                
                                                                                                                                                                                local header = Instance.new("Frame")
                                                                                                                                                                                header.Size = UDim2.new(1, 0, 0, 60)
                                                                                                                                                                                header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                                                                                                                                                                header.Parent = ui.musicSection
                                                                                                                                                                                
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
                                                                                                                                                                                    ui.musicSection.Visible = false
                                                                                                                                                                                    ui.navBar.Visible = true
                                                                                                                                                                                    ui.headerFrame.Visible = true
                                                                                                                                                                                    ui.contentFrame.Size = UDim2.new(1, 0, 1, -140)
                                                                                                                                                                                    ui.contentFrame.Position = UDim2.new(0, 0, 0, 60)
                                                                                                                                                                                    if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                                                                                                        _G.FaceBlox.functions.switchView("create")
                                                                                                                                                                                        end
                                                                                                                                                                                        end)
                                                                                                                                                                                            
                                                                                                                                                                                            if #state.availableMusic == 0 then
                                                                                                                                                                                                local empty = Instance.new("TextLabel")
                                                                                                                                                                                                empty.Size = UDim2.new(1, 0, 0, 60)
                                                                                                                                                                                                empty.Position = UDim2.new(0, 0, 0, 80)
                                                                                                                                                                                                empty.BackgroundTransparency = 1
                                                                                                                                                                                                empty.Text = "No hay música cargada. Agrega pistas desde el servidor/administrador."
                                                                                                                                                                                                empty.TextColor3 = Color3.new(1,1,1)
                                                                                                                                                                                                empty.Font = Enum.Font.SourceSans
                                                                                                                                                                                                empty.TextSize = 18
                                                                                                                                                                                                empty.TextWrapped = true
                                                                                                                                                                                                empty.Parent = ui.musicSection
                                                                                                                                                                                            else
                                                                                                                                                                                                for _, music in ipairs(state.availableMusic) do
                                                                                                                                                                                                    local musicFrame = Instance.new("Frame")
                                                                                                                                                                                                    musicFrame.Size = UDim2.new(1, 0, 0, 80)
                                                                                                                                                                                                    musicFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                                                                                                                                                                                                    musicFrame.BorderSizePixel = 0
                                                                                                                                                                                                    musicFrame.Parent = ui.musicSection
                                                                                                                                                                                                    
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
                                                                                                                                                                                                    
                                                                                                                                                                                                    selectButton.MouseButton1Click:Connect(function()
                                                                                                                                                                                                        state.selectedMusicId = music.id
                                                                                                                                                                                                        selectButton.Text = "✓ Seleccionado"
                                                                                                                                                                                                        selectButton.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
                                                                                                                                                                                                        wait(1)
                                                                                                                                                                                                        ui.musicSection.Visible = false
                                                                                                                                                                                                        ui.navBar.Visible = true
                                                                                                                                                                                                        ui.headerFrame.Visible = true
                                                                                                                                                                                                        ui.contentFrame.Size = UDim2.new(1, 0, 1, -140)
                                                                                                                                                                                                        ui.contentFrame.Position = UDim2.new(0, 0, 0, 60)
                                                                                                                                                                                                        if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                                                                                                                            _G.FaceBlox.functions.switchView("create")
                                                                                                                                                                                                            end
                                                                                                                                                                                                            end)
                                                                                                                                                                                                            end
                                                                                                                                                                                                            end
                                                                                                                                                                                                                
                                                                                                                                                                                                                ui.musicSection.CanvasSize = UDim2.new(0, 0, 0, ui.musicLayout.AbsoluteContentSize.Y)
                                                                                                                                                                                                            end
                                                                                                                                                                                                            
                                                                                                                                                                                                            -- switchView: controla visibilidad y usa loaders definidos arriba
                                                                                                                                                                                                            local function switchView(view)
                                                                                                                                                                                                                state.currentView = view
                                                                                                                                                                                                                
                                                                                                                                                                                                                ui.feedScroll.Visible = false
                                                                                                                                                                                                                ui.discoverFrame.Visible = false
                                                                                                                                                                                                                ui.createFrame.Visible = false
                                                                                                                                                                                                                ui.settingsFrame.Visible = false
                                                                                                                                                                                                                ui.commentsSection.Visible = false
                                                                                                                                                                                                                ui.musicSection.Visible = false
                                                                                                                                                                                                                
                                                                                                                                                                                                                local isDiscoverView = (view == "discover")
                                                                                                                                                                                                                ui.searchFrame.Visible = isDiscoverView
                                                                                                                                                                                                                ui.logoLabel.Visible = not isDiscoverView
                                                                                                                                                                                                                
                                                                                                                                                                                                                for viewName, button in pairs(ui.navButtonInstances) do
                                                                                                                                                                                                                    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                                                                                                                                                                                                                end
                                                                                                                                                                                                                
                                                                                                                                                                                                                if ui.navButtonInstances[view] then
                                                                                                                                                                                                                    ui.navButtonInstances[view].BackgroundColor3 = Color3.fromRGB(59, 89, 152)
                                                                                                                                                                                                                end
                                                                                                                                                                                                                
                                                                                                                                                                                                                if view == "feed" then
                                                                                                                                                                                                                    ui.feedScroll.Visible = true
                                                                                                                                                                                                                    loadFeed()
                                                                                                                                                                                                                elseif view == "discover" then
                                                                                                                                                                                                                    ui.discoverFrame.Visible = true
                                                                                                                                                                                                                    loadDiscoverPage()
                                                                                                                                                                                                                elseif view == "create" then
                                                                                                                                                                                                                    ui.createFrame.Visible = true
                                                                                                                                                                                                                    loadCreatePage()
                                                                                                                                                                                                                elseif view == "settings" then
                                                                                                                                                                                                                    ui.settingsFrame.Visible = true
                                                                                                                                                                                                                    loadSettingsPage(state.currentProfileId or player.UserId)
                                                                                                                                                                                                                end
                                                                                                                                                                                                            end
                                                                                                                                                                                                            
                                                                                                                                                                                                            -- Exportar a _G.FaceBlox.functions
                                                                                                                                                                                                            _G.FaceBlox.functions = _G.FaceBlox.functions or {}
                                                                                                                                                                                                                _G.FaceBlox.functions.createUserResultFrame = createUserResultFrame
                                                                                                                                                                                                                    _G.FaceBlox.functions.showSearchResults = showSearchResults
                                                                                                                                                                                                                        _G.FaceBlox.functions.loadFeed = loadFeed
                                                                                                                                                                                                                            _G.FaceBlox.functions.loadDiscoverPage = loadDiscoverPage
                                                                                                                                                                                                                                _G.FaceBlox.functions.loadCreatePage = loadCreatePage
                                                                                                                                                                                                                                    _G.FaceBlox.functions.loadSettingsPage = loadSettingsPage
                                                                                                                                                                                                                                        _G.FaceBlox.functions.showReportModal = showReportModal
                                                                                                                                                                                                                                            _G.FaceBlox.functions.showMusicSelection = showMusicSelection
                                                                                                                                                                                                                                                _G.FaceBlox.functions.switchView = switchView
                                                                                                                                                                                                                                                    _G.FaceBlox.functions.showUserProfile = function(uid)
                                                                                                                                                                                                                                                        state.currentProfileId = uid
                                                                                                                                                                                                                                                        switchView("settings")
                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                    -- Conectar nav buttons clicks (fuerza compatibilidad con Parte1)
                                                                                                                                                                                                                                                    for viewName, btn in pairs(ui.navButtonInstances) do
                                                                                                                                                                                                                                                        btn.MouseButton1Click:Connect(function()
                                                                                                                                                                                                                                                            if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                                                                                                                                                                                _G.FaceBlox.functions.switchView(viewName)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                end
                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                    -- Búsqueda: conectar SearchBox aquí para que envíe al server (Parte4)
                                                                                                                                                                                                                                                                    if ui.searchBox then
                                                                                                                                                                                                                                                                        local searchDebounce = false
                                                                                                                                                                                                                                                                        ui.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                                                                                                                                                                                                                                                                            if state.currentView == "discover" and string.len(ui.searchBox.Text) >= 1 then
                                                                                                                                                                                                                                                                                if not searchDebounce then
                                                                                                                                                                                                                                                                                    searchDebounce = true
                                                                                                                                                                                                                                                                                    ui.searchIndicator.Visible = true
                                                                                                                                                                                                                                                                                    ui.searchIndicator.Text = "🔍 Buscando..."
                                                                                                                                                                                                                                                                                    local tween = TweenService:Create(
                                                                                                                                                                                                                                                                                    ui.searchIndicator,
                                                                                                                                                                                                                                                                                    TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                                                                                                                                                                                                                                                                                    {TextTransparency = 0.5}
                                                                                                                                                                                                                                                                                    )
                                                                                                                                                                                                                                                                                    tween:Play()
                                                                                                                                                                                                                                                                                    wait(0.3)
                                                                                                                                                                                                                                                                                    if string.len(ui.searchBox.Text) >= 3 then
                                                                                                                                                                                                                                                                                        if _G and _G.FaceBlox and _G.FaceBlox.remoteFunctions and _G.FaceBlox.remoteFunctions.SearchUsers then
                                                                                                                                                                                                                                                                                            pcall(function() _G.FaceBlox.remoteFunctions.SearchUsers:InvokeServer(ui.searchBox.Text) end)
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            else
                                                                                                                                                                                                                                                                                                ui.searchIndicator.Text = "Escribe al menos 3 caracteres..."
                                                                                                                                                                                                                                                                                                wait(1)
                                                                                                                                                                                                                                                                                                ui.searchIndicator.Visible = false
                                                                                                                                                                                                                                                                                                tween:Cancel()
                                                                                                                                                                                                                                                                                                loadDiscoverPage()
                                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                                            searchDebounce = false
                                                                                                                                                                                                                                                                                        end
                                                                                                                                                                                                                                                                                    elseif state.currentView == "discover" and string.len(ui.searchBox.Text) == 0 then
                                                                                                                                                                                                                                                                                        ui.searchIndicator.Visible = false
                                                                                                                                                                                                                                                                                        loadDiscoverPage()
                                                                                                                                                                                                                                                                                    end
                                                                                                                                                                                                                                                                                end)
                                                                                                                                                                                                                                                                            end
                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                            print("FaceBlox Cliente - Parte 03 (Pages & UI Actions) cargada.")
