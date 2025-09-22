-- FaceBlox_Client_04_RemotesAndInit
-- Parte 4: conectar RemoteEvents y RemoteFunctions desde ReplicatedStorage,
-- listeners en tiempo real (postCreated, postUpdated, commentAdded, followUpdated),
-- linkProfile, búsqueda en tiempo real, y primer switchView("feed").
 
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
 
-- Esperar que las otras partes hayan exportado funciones/uis/state
local maxWait = 10
local waited = 0
while (not _G.FaceBlox or not _G.FaceBlox.ui or not _G.FaceBlox.functions) and waited < maxWait do
    waited = waited + 0.1
    wait(0.1)
end
if not _G.FaceBlox or not _G.FaceBlox.ui or not _G.FaceBlox.functions then
    warn("FaceBlox Parte4: No se encontró FaceBlox completo. Asegúrate de que Partes 1-3 estén cargadas.")
    return
end
 
local ui = _G.FaceBlox.ui
local state = _G.FaceBlox.state
 
-- Asegurar RemoteEvents/Functions folder
local remoteEventsFolder = ReplicatedStorage:WaitForChild("RemoteEvents")
 
local function getOrNil(name) return remoteEventsFolder:FindFirstChild(name) end
 
-- Cliente -> servidor
local createPostEvent    = getOrNil("CreatePost")
local likePostEvent      = getOrNil("LikePost")
local commentPostEvent   = getOrNil("CommentPost")
local followUserEvent    = getOrNil("FollowUser")
local hideCommentEvent   = getOrNil("HideComment")
local reportUserEvent    = getOrNil("ReportUser")
local deleteCommentEvent = getOrNil("DeleteComment")
-- Server -> client
local postCreatedEvent  = getOrNil("PostCreated")
local postUpdatedEvent  = getOrNil("PostUpdated")
local commentAddedEvent = getOrNil("CommentAdded")
local followUpdatedEvent= getOrNil("FollowUpdated")
local linkProfileEvent  = getOrNil("LinkProfile")
local searchResultsEvent = getOrNil("SearchResults")
-- RemoteFunctions
local getFeedFunction = getOrNil("GetFeed")
local getProfileFunction = getOrNil("GetProfile")
local searchUsersFunction = getOrNil("SearchUsers")
local getCommentsFunction = getOrNil("GetComments")
local getUserPostsFunction = getOrNil("GetUserPosts")
local getRecommendationsFunction = getOrNil("GetRecommendations")
local getAdminReportsFunction = getOrNil("GetAdminReports")
local getPlayerAvatarFunction = getOrNil("GetPlayerAvatar")
 
-- Guardar referencias en _G para que las Partes 2/3 puedan FireServer/Invoke
_G.FaceBlox.remoteEvents = {
CreatePost = createPostEvent,
LikePost = likePostEvent,
CommentPost = commentPostEvent,
FollowUser = followUserEvent,
HideComment = hideCommentEvent,
ReportUser = reportUserEvent,
DeleteComment = deleteCommentEvent
}
_G.FaceBlox.remoteFunctions = {
GetFeed = getFeedFunction,
GetProfile = getProfileFunction,
SearchUsers = searchUsersFunction,
GetComments = getCommentsFunction,
GetUserPosts = getUserPostsFunction,
GetRecommendations = getRecommendationsFunction,
GetAdminReports = getAdminReportsFunction,
GetPlayerAvatar = getPlayerAvatarFunction
}
 
-- Conectar search results (server -> client)
if searchResultsEvent then
    searchResultsEvent.OnClientEvent:Connect(function(results)
        if _G and _G.FaceBlox and type(_G.FaceBlox.functions.showSearchResults) == "function" then
            _G.FaceBlox.functions.showSearchResults(results)
            end
            end)
            end
                
                -- linkProfileEvent: actualiza avatar y verificación en header
                if linkProfileEvent then
                    linkProfileEvent.OnClientEvent:Connect(function(avatarUrl)
                        local finalAvatarUrl = avatarUrl or ("https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png")
                        pcall(function() ui.profileButton.Image = finalAvatarUrl end)
                            -- Actualizar verificación basada en followers (obteniendo perfil del server)
                            if getProfileFunction then
                                local ok, profileData = pcall(function() return getProfileFunction:InvokeServer(player.UserId) end)
                                    if ok and profileData then
                                        if ui.verifiedBadge then ui.verifiedBadge.Visible = profileData.isVerified or profileData.isAdmin end
                                    end
                                end
                            end)
                        end
                        
                        -- Inicializar avatar del jugador
                        spawn(function()
                            wait(1)
                            local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
                            pcall(function() ui.profileButton.Image = avatarUrl end)
                            end)
                                
                                -- profileButton to profile
                                ui.profileButton.MouseButton1Click:Connect(function()
                                    if _G and _G.FaceBlox and type(_G.FaceBlox.functions.showUserProfile) == "function" then
                                        _G.FaceBlox.functions.showUserProfile(player.UserId)
                                        end
                                        end)
                                            
                                            -- linkProfileBtn: pedir avatar al server
                                            ui.linkProfileBtn.MouseButton1Click:Connect(function()
                                                ui.linkProfileBtn.Text = "..."
                                                ui.linkProfileBtn.Enabled = false
                                                
                                                if linkProfileEvent then pcall(function() linkProfileEvent:FireServer() end) end
                                                
                                                wait(1)
                                                ui.linkProfileBtn.Text = "✓"
                                                ui.linkProfileBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
                                                
                                                wait(2)
                                                ui.linkProfileBtn.Text = "🔗"
                                                ui.linkProfileBtn.BackgroundColor3 = Color3.fromRGB(46, 125, 50)
                                                ui.linkProfileBtn.Enabled = true
                                                
                                                if _G and _G.FaceBlox and type(_G.FaceBlox.functions.loadSettingsPage) == "function" then
                                                    _G.FaceBlox.functions.loadSettingsPage(_G.FaceBlox.state.currentProfileId or player.UserId)
                                                    end
                                                    end)
                                                        
                                                        -- Broadcast listeners para updates en tiempo real
                                                        if postCreatedEvent then
                                                            postCreatedEvent.OnClientEvent:Connect(function(postData)
                                                                if ui.feedScroll.Visible then
                                                                    local pf = _G.FaceBlox.functions.createPostFrame(postData)
                                                                        pf.Parent = ui.feedScroll
                                                                        ui.feedScroll.CanvasSize = UDim2.new(0,0,0, ui.feedLayout.AbsoluteContentSize.Y)
                                                                    end
                                                                end)
                                                            end
                                                            
                                                            if postUpdatedEvent then
                                                                postUpdatedEvent.OnClientEvent:Connect(function(postId, likesCount, commentsCount)
                                                                    -- recargar feed para mantener sincronía (te asegura que el administrador y seguidores estén sincronizados)
                                                                    if _G and _G.FaceBlox and type(_G.FaceBlox.functions.loadFeed) == "function" then
                                                                        _G.FaceBlox.functions.loadFeed()
                                                                        end
                                                                        end)
                                                                        end
                                                                            
                                                                            if commentAddedEvent then
                                                                                commentAddedEvent.OnClientEvent:Connect(function(postId, commentData)
                                                                                    -- Si estamos viendo los comentarios de ese post en particular, recargar sección
                                                                                    if ui.commentsSection.Visible and tostring(_G.FaceBlox.state.currentPostId) == tostring(postId) then
                                                                                        if _G and _G.FaceBlox and type(_G.FaceBlox.functions.showCommentsSection) == "function" then
                                                                                            _G.FaceBlox.functions.showCommentsSection(postId)
                                                                                            end
                                                                                            end
                                                                                            end)
                                                                                            end
                                                                                                
                                                                                                if followUpdatedEvent then
                                                                                                    followUpdatedEvent.OnClientEvent:Connect(function(followerId, targetUserId, isFollowing)
                                                                                                        if tostring(targetUserId) == tostring(_G.FaceBlox.state.currentProfileId) and ui.settingsFrame.Visible then
                                                                                                            if _G and _G.FaceBlox and type(_G.FaceBlox.functions.loadSettingsPage) == "function" then
                                                                                                                _G.FaceBlox.functions.loadSettingsPage(_G.FaceBlox.state.currentProfileId)
                                                                                                                end
                                                                                                                end
                                                                                                                    -- sincronizar allUsers/recomendaciones: recargar discover
                                                                                                                    if ui.discoverFrame.Visible and type(_G.FaceBlox.functions.loadDiscoverPage) == "function" then
                                                                                                                        _G.FaceBlox.functions.loadDiscoverPage()
                                                                                                                        end
                                                                                                                        end)
                                                                                                                        end
                                                                                                                            
                                                                                                                            -- Escuchar SearchResults (ya conectado arriba). Además exponer GetPlayerAvatar si es necesario
                                                                                                                            -- Asegurar CanvasSize listeners
                                                                                                                            local feedLayoutObj = ui.feedLayout
                                                                                                                            if feedLayoutObj then
                                                                                                                                feedLayoutObj:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                                                                                                                                    ui.feedScroll.CanvasSize = UDim2.new(0, 0, 0, feedLayoutObj.AbsoluteContentSize.Y)
                                                                                                                                end)
                                                                                                                            end
                                                                                                                            local discoverLayoutObj = ui.discoverLayout
                                                                                                                            if discoverLayoutObj then
                                                                                                                                discoverLayoutObj:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                                                                                                                                    ui.discoverFrame.CanvasSize = UDim2.new(0, 0, 0, discoverLayoutObj.AbsoluteContentSize.Y)
                                                                                                                                end)
                                                                                                                            end
                                                                                                                            local settingsLayoutObj = ui.settingsLayout
                                                                                                                            if settingsLayoutObj then
                                                                                                                                settingsLayoutObj:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                                                                                                                                    ui.settingsFrame.CanvasSize = UDim2.new(0, 0, 0, settingsLayoutObj.AbsoluteContentSize.Y)
                                                                                                                                end)
                                                                                                                            end
                                                                                                                            local commentsLayoutObj = ui.commentsLayout
                                                                                                                            if commentsLayoutObj then
                                                                                                                                commentsLayoutObj:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                                                                                                                                    ui.commentsSection.CanvasSize = UDim2.new(0, 0, 0, commentsLayoutObj.AbsoluteContentSize.Y)
                                                                                                                                end)
                                                                                                                            end
                                                                                                                            
                                                                                                                            -- Finalmente, iniciar vista inicial (feed)
                                                                                                                            if _G and _G.FaceBlox and type(_G.FaceBlox.functions.switchView) == "function" then
                                                                                                                                _G.FaceBlox.functions.switchView("feed")
                                                                                                                                end
                                                                                                                                    
                                                                                                                                    print("FaceBlox Cliente - Parte 04 (Remotes & Init) cargada. Plataforma lista.")
