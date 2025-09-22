-- Server: FaceBlox (reorganizado y corregido)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- DataStores
local PlayerDataStore   = DataStoreService:GetDataStore("PlayerData")
local PostsDataStore    = DataStoreService:GetDataStore("Posts")
local PostsIndexStore   = DataStoreService:GetDataStore("PostsIndex") -- NUEVO: índice global de posts
local CommentsDataStore = DataStoreService:GetDataStore("Comments")
local UsersDataStore    = DataStoreService:GetDataStore("AllUsers")
local ReportsDataStore  = DataStoreService:GetDataStore("Reports")

-- RemoteEvents y RemoteFunctions (asegurar existencia)
local function getOrCreate(parent, className, name)
    local existing = parent:FindFirstChild(name)
    if existing then return existing end
    local inst = Instance.new(className)
    inst.Name = name
    inst.Parent = parent
    return inst
end

local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents") or Instance.new("Folder", ReplicatedStorage)
remoteEventsFolder.Name = "RemoteEvents"

-- Cliente -> servidor
local createPostEvent    = getOrCreate(remoteEventsFolder, "RemoteEvent", "CreatePost")
local likePostEvent      = getOrCreate(remoteEventsFolder, "RemoteEvent", "LikePost")
local commentPostEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "CommentPost")
local followUserEvent    = getOrCreate(remoteEventsFolder, "RemoteEvent", "FollowUser")
local hideCommentEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "HideComment")
local reportUserEvent    = getOrCreate(remoteEventsFolder, "RemoteEvent", "ReportUser")
local deleteCommentEvent = getOrCreate(remoteEventsFolder, "RemoteEvent", "DeleteComment")

-- Servidor -> cliente (broadcasts)
local postCreatedEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "PostCreated")
local postUpdatedEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "PostUpdated")
local commentAddedEvent  = getOrCreate(remoteEventsFolder, "RemoteEvent", "CommentAdded")
local commentDeletedEvent= getOrCreate(remoteEventsFolder, "RemoteEvent", "CommentDeleted")
local followUpdatedEvent = getOrCreate(remoteEventsFolder, "RemoteEvent", "FollowUpdated")
local linkProfileEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "LinkProfile")
local searchResultsEvent = getOrCreate(remoteEventsFolder, "RemoteEvent", "SearchResults")

-- RemoteFunctions
local getFeedFunction         = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetFeed")
local getProfileFunction      = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetProfile")
local searchUsersFunction     = getOrCreate(remoteEventsFolder, "RemoteFunction", "SearchUsers")
local getCommentsFunction     = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetComments")
local getUserPostsFunction    = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetUserPosts")
local getRecommendationsFn    = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetRecommendations")
local getAdminReportsFunction = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetAdminReports")
local getPlayerAvatarFunction = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetPlayerAvatar")

-- Memoria en servidor
local playerData = {}   -- datos por usuario cargados en memoria
local allUsers = {}     -- índice de usuarios (persistido)
local postsIndex = {}   -- índice global de postIds (cargado desde PostsIndexStore)
local pendingReports = {}

-- Administradores
local admins = {
{username = "vegetl_t", displayName = "darheel"}
}

local function isAdmin(username, displayName)
    for _, admin in pairs(admins) do
        if string.lower(username) == string.lower(admin.username)
            or (displayName and string.lower(displayName) == string.lower(admin.displayName)) then
            return true
        end
    end
    return false
end

local function isVerified(username, displayName, followersCount)
    if isAdmin(username, displayName) then return true end
    return (followersCount and followersCount >= 2)
end

-- Helpers para DataStore con reintentos
local function saveDataStore(dataStore, key, value)
    local success, result
    local attempts = 0
    repeat
    success, result = pcall(function() return dataStore:SetAsync(key, value) end)
        if not success then
            warn("DataStore SetAsync fallo para key="..tostring(key)..": "..tostring(result)..". Reintentando...")
            wait(2 ^ math.min(attempts, 6))
            attempts = attempts + 1
        end
        until success or attempts > 5
        return success
    end
    
    local function getDataStore(dataStore, key)
        local success, result
        local attempts = 0
        repeat
        success, result = pcall(function() return dataStore:GetAsync(key) end)
            if not success then
                warn("DataStore GetAsync fallo para key="..tostring(key)..": "..tostring(result)..". Reintentando...")
                wait(2 ^ math.min(attempts, 6))
                attempts = attempts + 1
            end
            until success or attempts > 5
            if success then
                return result
            else
                return nil
            end
        end
        
        local function generateUniqueId()
            return HttpService:GenerateGUID(false)
        end
        
        -- Guardar/leer datos de jugador
        local function savePlayerData(player)
            if playerData[player.UserId] then
                saveDataStore(PlayerDataStore, tostring(player.UserId), playerData[player.UserId])
            end
        end
        
        local function saveAllUsersData()
            saveDataStore(UsersDataStore, "AllUsersData", allUsers)
        end
        
        local function loadAllUsersData()
            local data = getDataStore(UsersDataStore, "AllUsersData")
            if data then
                allUsers = data
            else
                allUsers = {}
            end
        end
        
        local function loadPostsIndex()
            local idx = getDataStore(PostsIndexStore, "AllPosts")
            if idx and type(idx) == "table" then
                postsIndex = idx
            else
                postsIndex = {}
            end
        end
        
        local function loadPlayerData(player)
            local key = tostring(player.UserId)
            local data = getDataStore(PlayerDataStore, key)
            if data then
                playerData[player.UserId] = data
            else
                playerData[player.UserId] = {
                displayName = player.DisplayName,
                followers = {},
                following = {},
                posts = {},
                profilePicture = "rbxasset://textures/face.png",
                bio = "¡Nuevo en FaceBlox!",
                joinDate = os.time(),
                isAdmin = isAdmin(player.Name, player.DisplayName)
                }
                savePlayerData(player)
            end
            
            -- actualizar allUsers
            allUsers[key] = allUsers[key] or {}
            allUsers[key].userId = player.UserId
            allUsers[key].displayName = player.DisplayName
            allUsers[key].username = player.Name
            allUsers[key].lastSeen = os.time()
            allUsers[key].isAdmin = isAdmin(player.Name, player.DisplayName)
            
            local followersCount = 0
            if playerData[player.UserId].followers then
                for _ in pairs(playerData[player.UserId].followers) do followersCount = followersCount + 1 end
            end
            allUsers[key].followersCount = followersCount
            allUsers[key].isVerified = isVerified(player.Name, player.DisplayName, followersCount)
        end
        
        -- ---------- FUNCIONES PRINCIPALES ----------
        
        -- Crear post: guarda post, actualiza postsIndex y lista del usuario
        local function createPost(player, content, imageId, musicId)
            local postId = generateUniqueId()
            
            -- Calcular verificación
            local followersCount = 0
            if playerData[player.UserId] and playerData[player.UserId].followers then
                for _ in pairs(playerData[player.UserId].followers) do followersCount = followersCount + 1 end
            end
            
            local authorProfilePicture = (playerData[player.UserId] and playerData[player.UserId].profilePicture) or ("https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png")
            
            local newPost = {
            id = postId,
            authorId = player.UserId,
            authorName = player.DisplayName,
            authorUsername = player.Name,
            authorProfilePicture = authorProfilePicture, -- NUEVO: incluir avatar
            content = content or "",
            imageId = imageId or "",
            musicId = musicId or "",
            timestamp = os.time(),
            likes = {},
            comments = {},
            isVerified = isVerified(player.Name, player.DisplayName, followersCount)
            }
            
            local success = saveDataStore(PostsDataStore, postId, newPost)
            if not success then
                return false, "Error guardando post"
            end
            
            -- actualizar lista de posts del autor en memoria y DataStore
            playerData[player.UserId].posts = playerData[player.UserId].posts or {}
            table.insert(playerData[player.UserId].posts, 1, postId)
            savePlayerData(player)
            
            -- actualizar índice global de posts (más reciente primero)
            postsIndex = postsIndex or {}
            table.insert(postsIndex, 1, postId)
            -- limitar tamaño del índice para no exceder DataStore (ej. 500)
            local MAX_INDEX = 500
            while #postsIndex > MAX_INDEX do
                table.remove(postsIndex, #postsIndex)
            end
            saveDataStore(PostsIndexStore, "AllPosts", postsIndex)
            
            -- broadcast nuevo post
            pcall(function() postCreatedEvent:FireAllClients(newPost) end)
                
                return true, postId
            end
            
            -- Like/unlike post
            local function likePost(player, postId)
                local post = getDataStore(PostsDataStore, postId)
                if not post then return false, "Post no encontrado" end
                
                local userIdStr = tostring(player.UserId)
                local isLiked = post.likes and (post.likes[userIdStr] ~= nil)
                
                post.likes = post.likes or {}
                if isLiked then
                    post.likes[userIdStr] = nil
                else
                    post.likes[userIdStr] = { userId = player.UserId, displayName = player.DisplayName, timestamp = os.time() }
                end
                
                local success = saveDataStore(PostsDataStore, postId, post)
                if not success then return false, "Error actualizando like" end
                
                local likesCount = 0
                for _ in pairs(post.likes) do likesCount = likesCount + 1 end
                local commentsCount = #(post.comments or {})
                pcall(function() postUpdatedEvent:FireAllClients(postId, likesCount, commentsCount) end)
                    return true, not isLiked
                end
                
                -- Comentar post
                local function commentOnPost(player, postId, content)
                    local post = getDataStore(PostsDataStore, postId)
                    if not post then return false, "Post no encontrado" end
                    
                    local commentId = generateUniqueId()
                    
                    local followersCount = 0
                    if playerData[player.UserId] and playerData[player.UserId].followers then
                        for _ in pairs(playerData[player.UserId].followers) do followersCount = followersCount + 1 end
                    end
                    
                    local newComment = {
                    id = commentId,
                    postId = postId,
                    authorId = player.UserId,
                    authorName = player.DisplayName,
                    authorUsername = player.Name,
                    content = content,
                    timestamp = os.time(),
                    isVerified = isVerified(player.Name, player.DisplayName, followersCount)
                    }
                    
                    local successComment = saveDataStore(CommentsDataStore, commentId, newComment)
                    if not successComment then return false, "Error guardando comentario" end
                    
                    post.comments = post.comments or {}
                    table.insert(post.comments, commentId)
                    local successPost = saveDataStore(PostsDataStore, postId, post)
                    if not successPost then return false, "Error actualizando post con comentario" end
                    
                    -- Broadcast comentario y actualizar contadores
                    pcall(function() commentAddedEvent:FireAllClients(postId, newComment) end)
                        local likesCount = 0
                        for _ in pairs(post.likes or {}) do likesCount = likesCount + 1 end
                        pcall(function() postUpdatedEvent:FireAllClients(postId, likesCount, #post.comments) end)
                            
                            return true, newComment
                        end
                        
                        -- Seguir/dejar de seguir
                        local function followUser(player, targetUserId)
                            local targetUserData = getDataStore(PlayerDataStore, tostring(targetUserId))
                            if not targetUserData then return false, "Usuario no encontrado" end
                            
                            local followerData = playerData[player.UserId]
                            if not followerData then return false, "Datos de jugador no cargados" end
                            
                            local followerIdStr = tostring(player.UserId)
                            local targetUserIdStr = tostring(targetUserId)
                            
                            followerData.following = followerData.following or {}
                            targetUserData.followers = targetUserData.followers or {}
                            
                            local isFollowing = followerData.following[targetUserIdStr] ~= nil
                            
                            if isFollowing then
                                followerData.following[targetUserIdStr] = nil
                                targetUserData.followers[followerIdStr] = nil
                            else
                                followerData.following[targetUserIdStr] = { userId = targetUserId, timestamp = os.time() }
                                targetUserData.followers[followerIdStr] = { userId = player.UserId, displayName = player.DisplayName, timestamp = os.time() }
                            end
                            
                            local success1 = saveDataStore(PlayerDataStore, followerIdStr, followerData)
                            local success2 = saveDataStore(PlayerDataStore, targetUserIdStr, targetUserData)
                            
                            if success1 and success2 then
                                -- actualizar allUsers
                                if allUsers[targetUserIdStr] then
                                    local newFollowersCount = 0
                                    for _ in pairs(targetUserData.followers or {}) do newFollowersCount = newFollowersCount + 1 end
                                    allUsers[targetUserIdStr].followersCount = newFollowersCount
                                    allUsers[targetUserIdStr].isVerified = isVerified(allUsers[targetUserIdStr].username, allUsers[targetUserIdStr].displayName, newFollowersCount)
                                    saveAllUsersData()
                                end
                                
                                pcall(function() followUpdatedEvent:FireAllClients(player.UserId, targetUserId, not isFollowing) end)
                                    return true, not isFollowing
                                end
                                
                                return false, "Error al seguir/dejar de seguir"
                            end
                            
                            -- Buscar usuarios (usa allUsers / PlayerDataStore)
                            local function searchUsers(player, query)
                                loadAllUsersData()
                                local results = {}
                                local queryLower = string.lower(query or "")
                                
                                for userId, userData in pairs(allUsers) do
                                    if userData.displayName and userData.username then
                                        local dn = string.lower(userData.displayName)
                                        local un = string.lower(userData.username)
                                        if string.find(dn, queryLower) or string.find(un, queryLower) then
                                            local fullUserData = getDataStore(PlayerDataStore, userId)
                                            if fullUserData then
                                                local followersCount = 0
                                                if fullUserData.followers then
                                                    for _ in pairs(fullUserData.followers) do followersCount = followersCount + 1 end
                                                end
                                                table.insert(results, {
                                                userId = userData.userId,
                                                displayName = userData.displayName,
                                                username = userData.username,
                                                followersCount = followersCount,
                                                isVerified = isVerified(userData.username, userData.displayName, followersCount),
                                                profilePicture = fullUserData.profilePicture or "rbxasset://textures/face.png"
                                                })
                                            end
                                        end
                                    end
                                end
                                
                                -- Enviar resultados en tiempo real al cliente que buscó
                                pcall(function() searchResultsEvent:FireClient(player, results) end)
                                    return results
                                end
                                
                                -- Obtener feed GLOBAL (usa postsIndex y PostsDataStore)
                                local function getFeed(player)
                                    loadAllUsersData()
                                    loadPostsIndex()
                                    
                                    local feedPosts = {}
                                    local MAX_RETURN = 100
                                    local count = 0
                                    
                                    for i, postId in ipairs(postsIndex or {}) do
                                        if count >= MAX_RETURN then break end
                                        local postData = getDataStore(PostsDataStore, postId)
                                        if postData then
                                            local post = table.clone(postData)
                                            post.likesCount = 0
                                            for _ in pairs(post.likes or {}) do post.likesCount = post.likesCount + 1 end
                                            post.commentsCount = #(post.comments or {})
                                            post.isLikedByUser = (post.likes and post.likes[tostring(player.UserId)] ~= nil) or false
                                            table.insert(feedPosts, post)
                                            count = count + 1
                                        end
                                    end
                                    
                                    table.sort(feedPosts, function(a,b) return (a.timestamp or 0) > (b.timestamp or 0) end)
                                        return feedPosts
                                    end
                                    
                                    -- Obtener posts de un usuario (usa PlayerDataStore -> posts list)
                                    local function getUserPosts(userId)
                                        local userData = getDataStore(PlayerDataStore, tostring(userId))
                                        if not userData then return {} end
                                        
                                        local userPosts = {}
                                        for _, postId in ipairs(userData.posts or {}) do
                                            local postData = getDataStore(PostsDataStore, postId)
                                            if postData then
                                                local post = table.clone(postData)
                                                post.likesCount = 0
                                                for _ in pairs(post.likes or {}) do post.likesCount = post.likesCount + 1 end
                                                post.commentsCount = #(post.comments or {})
                                                table.insert(userPosts, post)
                                            end
                                        end
                                        
                                        table.sort(userPosts, function(a, b) return a.timestamp > b.timestamp end)
                                            return userPosts
                                        end
                                        
                                        -- Obtener comentarios de un post
                                        local function getPostComments(postId)
                                            local post = getDataStore(PostsDataStore, postId)
                                            if not post then return {} end
                                            
                                            local postComments = {}
                                            for _, commentId in ipairs(post.comments or {}) do
                                                local comment = getDataStore(CommentsDataStore, commentId)
                                                if comment and not comment.deleted then
                                                    table.insert(postComments, comment)
                                                end
                                            end
                                            
                                            table.sort(postComments, function(a,b) return a.timestamp < b.timestamp end)
                                                return postComments
                                            end
                                            
                                            -- Obtener perfil de usuario
                                            local function getUserProfile(player, targetUserId)
                                                targetUserId = targetUserId or player.UserId
                                                local targetUserData = getDataStore(PlayerDataStore, tostring(targetUserId))
                                                if not targetUserData then return nil, "Usuario no encontrado" end
                                                
                                                local followersCount, followingCount = 0, 0
                                                for _ in pairs(targetUserData.followers or {}) do followersCount = followersCount + 1 end
                                                for _ in pairs(targetUserData.following or {}) do followingCount = followingCount + 1 end
                                                
                                                local profile = {
                                                userId = targetUserId,
                                                displayName = targetUserData.displayName,
                                                bio = targetUserData.bio,
                                                profilePicture = targetUserData.profilePicture,
                                                followersCount = followersCount,
                                                followingCount = followingCount,
                                                postsCount = #(targetUserData.posts or {}),
                                                joinDate = targetUserData.joinDate,
                                                isFollowedByUser = (playerData[player.UserId] and playerData[player.UserId].following[tostring(targetUserId)]) ~= nil,
                                                isAdmin = targetUserData.isAdmin or false,
                                                isVerified = isVerified(allUsers[tostring(targetUserId)] and allUsers[tostring(targetUserId)].username or "", targetUserData.displayName, followersCount)
                                                }
                                                
                                                return profile
                                            end
                                            
                                            -- Recomendaciones sencillas (usa allUsers)
                                            local function getRecommendations(player)
                                                loadAllUsersData()
                                                local candidates = {}
                                                for sid, meta in pairs(allUsers) do
                                                    if meta.userId and meta.userId ~= player.UserId then
                                                        local target = getDataStore(PlayerDataStore, tostring(meta.userId))
                                                        local followerCount = meta.followersCount or 0
                                                        table.insert(candidates, {
                                                        userId = meta.userId,
                                                        displayName = meta.displayName or meta.username or "Usuario",
                                                        username = meta.username or "",
                                                        followersCount = followerCount,
                                                        isVerified = meta.isVerified or false,
                                                        profilePicture = target and target.profilePicture or "rbxasset://textures/face.png"
                                                        })
                                                    end
                                                end
                                                table.sort(candidates, function(a,b) return a.followersCount > b.followersCount end)
                                                    local out = {}
                                                    local following = (playerData[player.UserId] and playerData[player.UserId].following) or {}
                                                    local followedSet = {}
                                                    for k,_ in pairs(following) do followedSet[k] = true end
                                                    for _, c in ipairs(candidates) do
                                                        if not followedSet[tostring(c.userId)] then
                                                            table.insert(out, c)
                                                            if #out >= 20 then break end
                                                        end
                                                    end
                                                    return out
                                                end
                                                
                                                -- ---------- EVENT HANDLERS y REMOTE FUNCTIONS ----------
                                                
                                                createPostEvent.OnServerEvent:Connect(function(player, content, imageId, musicId)
                                                    local success, result = createPost(player, content, imageId, musicId)
                                                    if success then
                                                        print(player.DisplayName .. " creó post: " .. tostring(result))
                                                    else
                                                        warn("Error creando post para " .. player.DisplayName .. ": " .. tostring(result))
                                                    end
                                                end)
                                                
                                                likePostEvent.OnServerEvent:Connect(function(player, postId)
                                                    local success, isLiked = likePost(player, postId)
                                                    if not success then warn("Error like: "..tostring(isLiked)) end
                                                end)
                                                
                                                commentPostEvent.OnServerEvent:Connect(function(player, postId, content)
                                                    local success, commentData = commentOnPost(player, postId, content)
                                                    if not success then warn("Error comentando: "..tostring(commentData)) end
                                                end)
                                                
                                                followUserEvent.OnServerEvent:Connect(function(player, targetUserId)
                                                    local success,_ = followUser(player, targetUserId)
                                                    if not success then warn("Error follow action") end
                                                end)
                                                
                                                hideCommentEvent.OnServerEvent:Connect(function(player, commentId)
                                                    local comment = getDataStore(CommentsDataStore, commentId)
                                                    if comment and tostring(comment.authorId) == tostring(player.UserId) then
                                                        comment.hidden = true
                                                        saveDataStore(CommentsDataStore, commentId, comment)
                                                        hideCommentEvent:FireClient(player, commentId, true)
                                                    end
                                                end)
                                                
                                                reportUserEvent.OnServerEvent:Connect(function(player, targetUserId, reason)
                                                    local reportId = generateUniqueId()
                                                    local reportData = {
                                                    id = reportId,
                                                    reporterId = player.UserId,
                                                    reporterName = player.DisplayName,
                                                    targetUserId = targetUserId,
                                                    reason = reason,
                                                    timestamp = os.time(),
                                                    status = "pending"
                                                    }
                                                    local success = saveDataStore(ReportsDataStore, reportId, reportData)
                                                    if success then
                                                        table.insert(pendingReports, reportData)
                                                        print("Reporte recibido: "..reportId)
                                                    end
                                                end)
                                                
                                                deleteCommentEvent.OnServerEvent:Connect(function(player, commentId)
                                                    local comment = getDataStore(CommentsDataStore, commentId)
                                                    if comment and (tostring(comment.authorId) == tostring(player.UserId) or isAdmin(player.Name, player.DisplayName)) then
                                                        comment.deleted = true
                                                        comment.deletedBy = player.DisplayName
                                                        saveDataStore(CommentsDataStore, commentId, comment)
                                                        pcall(function() commentDeletedEvent:FireAllClients(commentId) end)
                                                        end
                                                        end)
                                                            
                                                            linkProfileEvent.OnServerEvent:Connect(function(player)
                                                                if playerData[player.UserId] then
                                                                    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
                                                                    playerData[player.UserId].profilePicture = avatarUrl
                                                                    savePlayerData(player)
                                                                    linkProfileEvent:FireClient(player, avatarUrl)
                                                                end
                                                            end)
                                                            
                                                            -- RemoteFunction handlers
                                                            getFeedFunction.OnServerInvoke = function(player) return getFeed(player) end
                                                            getProfileFunction.OnServerInvoke = function(player, targetUserId) return getUserProfile(player, targetUserId) end
                                                            searchUsersFunction.OnServerInvoke = function(player, query) return searchUsers(player, query) end
                                                            getCommentsFunction.OnServerInvoke = function(player, postId) return getPostComments(postId) end
                                                            getUserPostsFunction.OnServerInvoke = function(player, userId) return getUserPosts(userId) end
                                                            getRecommendationsFn.OnServerInvoke = function(player) return getRecommendations(player) end
                                                            getAdminReportsFunction.OnServerInvoke = function(player)
                                                                if isAdmin(player.Name, player.DisplayName) then
                                                                    return pendingReports
                                                                else
                                                                    return {}
                                                                end
                                                            end
                                                            getPlayerAvatarFunction.OnServerInvoke = function(player)
                                                                return "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
                                                            end
                                                            
                                                            -- Player lifecycle
                                                            Players.PlayerAdded:Connect(function(player)
                                                                loadAllUsersData()
                                                                loadPostsIndex()
                                                                loadPlayerData(player)
                                                                print("FaceBlox: " .. player.DisplayName .. " conectado")
                                                                saveAllUsersData()
                                                            end)
                                                            
                                                            Players.PlayerRemoving:Connect(function(player)
                                                                savePlayerData(player)
                                                                if allUsers[tostring(player.UserId)] then
                                                                    allUsers[tostring(player.UserId)].lastSeen = os.time()
                                                                end
                                                                saveAllUsersData()
                                                                playerData[player.UserId] = nil
                                                                print("FaceBlox: " .. player.DisplayName .. " desconectado")
                                                            end)
                                                            
                                                            print("=================================")
                                                            print("✨ FACEBLOX SERVER CORREGIDO ✨")
                                                            print("Index de posts global implementado; feed ahora devuelve posts de la plataforma.")
                                                            print("=================================")
