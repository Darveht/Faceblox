-- Server: FaceBlox (versión corregida que mantiene tu código original y añade broadcasts y recomendaciones)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- DataStores (mismos nombres que tenías)
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")
local PostsDataStore = DataStoreService:GetDataStore("Posts")
local CommentsDataStore = DataStoreService:GetDataStore("Comments")
local UsersDataStore = DataStoreService:GetDataStore("AllUsers")

-- RemoteEvents y RemoteFunctions: si ya existen, reutilizarlos (no duplicar)
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

-- Eventos cliente -> servidor (preservo nombres originales)
local createPostEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "CreatePost")
local likePostEvent     = getOrCreate(remoteEventsFolder, "RemoteEvent", "LikePost")
local commentPostEvent  = getOrCreate(remoteEventsFolder, "RemoteEvent", "CommentPost")
local followUserEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "FollowUser")
local hideCommentEvent  = getOrCreate(remoteEventsFolder, "RemoteEvent", "HideComment")

-- Eventos servidor -> clientes (broadcasts en tiempo real) — nuevos, no quitan los tuyos
local postCreatedEvent  = getOrCreate(remoteEventsFolder, "RemoteEvent", "PostCreated")
local postUpdatedEvent  = getOrCreate(remoteEventsFolder, "RemoteEvent", "PostUpdated")
local commentAddedEvent = getOrCreate(remoteEventsFolder, "RemoteEvent", "CommentAdded")
local followUpdatedEvent= getOrCreate(remoteEventsFolder, "RemoteEvent", "FollowUpdated")

-- RemoteFunctions (reutilizo/creo)
local getFeedFunction       = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetFeed")
local getProfileFunction    = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetProfile")
local searchUsersFunction   = getOrCreate(remoteEventsFolder, "RemoteFunction", "SearchUsers")
local getCommentsFunction   = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetComments")
local getUserPostsFunction  = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetUserPosts")
local getRecommendationsFn  = getOrCreate(remoteEventsFolder, "RemoteFunction", "GetRecommendations") -- nueva función para Discover

-- Variables globales en memoria (mantengo tus nombres y estructura)
local playerData = {}
local allUsers = {}

-- Lista de administradores (mantengo tu lista)
local admins = {"vegetl_t"} -- Cambia esto por el nombre real del admin

local function isAdmin(username)
    for _, admin in pairs(admins) do
        if string.lower(username) == string.lower(admin) then
            return true
        end
    end
    return false
end

-- Funciones auxiliares para DataStores con reintentos (mantengo tus funciones con nombres)
local function saveDataStore(dataStore, key, data)
    local success, err
    local attempts = 0
    repeat
        success, err = pcall(dataStore.SetAsync, dataStore, key, data)
        if not success then
            warn("Error guardando " .. key .. ": " .. tostring(err) .. ". Reintentando...")
            wait(2 ^ math.min(attempts, 6)) -- Espera exponencial acotada
            attempts = attempts + 1
        end
    until success or attempts > 5
    return success
end

local function getDataStore(dataStore, key)
    local success, data
    local attempts = 0
    repeat
        success, data = pcall(dataStore.GetAsync, dataStore, key)
        if not success then
            warn("Error cargando " .. key .. ": " .. tostring(data) .. ". Reintentando...")
            wait(2 ^ math.min(attempts, 6))
            attempts = attempts + 1
        end
    until success or attempts > 5
    return data
end

-- Mantengo tu función de generar GUID
local function generateUniqueId()
    return HttpService:GenerateGUID(false)
end

-- Guardar datos de jugador (igual que antes)
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

local function loadPlayerData(player)
    local data = getDataStore(PlayerDataStore, tostring(player.UserId))
    
    if data then
        playerData[player.UserId] = data
    else
        -- Datos por defecto para nuevos usuarios (mantengo tu estructura y texto)
        playerData[player.UserId] = {
            displayName = player.DisplayName,
            followers = {},
            following = {},
            posts = {},
            profilePicture = "rbxasset://textures/face.png",
            bio = "¡Nuevo en FaceBlox!",
            joinDate = os.time(),
            isAdmin = isAdmin(player.Name)
        }
        savePlayerData(player)
    end
    
    -- Agregar o actualizar usuario en la base de datos global
    local userIdStr = tostring(player.UserId)
    allUsers[userIdStr] = allUsers[userIdStr] or {}
    allUsers[userIdStr].userId = player.UserId
    allUsers[userIdStr].displayName = player.DisplayName
    allUsers[userIdStr].username = player.Name
    allUsers[userIdStr].lastSeen = os.time()
    allUsers[userIdStr].isAdmin = isAdmin(player.Name)
end

-- FUNCIONES PRINCIPALES (mantengo tus nombres y lógica, añadiendo broadcasts y correcciones)

local function createPost(player, content, imageId)
    local postId = generateUniqueId()
    local newPost = {
        id = postId,
        authorId = player.UserId,
        authorName = player.DisplayName,
        content = content,
        imageId = imageId or "",
        timestamp = os.time(),
        likes = {},
        comments = {}
    }
    
    local success = saveDataStore(PostsDataStore, postId, newPost)
    
    if success then
        if playerData[player.UserId] and playerData[player.UserId].posts then
            table.insert(playerData[player.UserId].posts, 1, postId)
            savePlayerData(player)
        end
        -- Broadcast: nuevo post en tiempo real (para que todos los clientes lo añadan)
        pcall(function() postCreatedEvent:FireAllClients(newPost) end)
        return true, postId
    end
    return false, "Error al crear post"
end

local function likePost(player, postId)
    local post = getDataStore(PostsDataStore, postId)
    if not post then
        return false, "Post no encontrado"
    end
    
    local userIdStr = tostring(player.UserId)
    local isLiked = post.likes[userIdStr] ~= nil
    
    if isLiked then
        post.likes[userIdStr] = nil
    else
        post.likes[userIdStr] = {
            userId = player.UserId,
            displayName = player.DisplayName,
            timestamp = os.time()
        }
    end
    
    local success = saveDataStore(PostsDataStore, postId, post)
    if success then
        -- Broadcast: actualizar counts en todos los clientes
        local likesCount = 0
        for _ in pairs(post.likes) do likesCount = likesCount + 1 end
        local commentsCount = #post.comments
        pcall(function() postUpdatedEvent:FireAllClients(postId, likesCount, commentsCount) end)
        return true, not isLiked
    end
    return false, "Error al actualizar like"
end

local function commentOnPost(player, postId, content)
    local post = getDataStore(PostsDataStore, postId)
    if not post then
        return false, "Post no encontrado"
    end
    
    local commentId = generateUniqueId()
    local newComment = {
        id = commentId,
        postId = postId,
        authorId = player.UserId,
        authorName = player.DisplayName,
        content = content,
        timestamp = os.time()
    }
    
    local successComment = saveDataStore(CommentsDataStore, commentId, newComment)
    if successComment then
        table.insert(post.comments, commentId)
        local successPost = saveDataStore(PostsDataStore, postId, post)
        if successPost then
            -- Broadcast nuevo comentario y actualización de counts
            pcall(function() commentAddedEvent:FireAllClients(postId, newComment) end)
            local likesCount = 0
            for _ in pairs(post.likes) do likesCount = likesCount + 1 end
            pcall(function() postUpdatedEvent:FireAllClients(postId, likesCount, #post.comments) end)
            return true, newComment
        end
    end
    return false, "Error al comentar post"
end

local function followUser(player, targetUserId)
    local targetUserData = getDataStore(PlayerDataStore, tostring(targetUserId))
    if not targetUserData then
        return false, "Usuario no encontrado"
    end

    local followerData = playerData[player.UserId]
    if not followerData then return false, "Datos de jugador no cargados" end

    local followerIdStr = tostring(player.UserId)
    local targetUserIdStr = tostring(targetUserId)

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
        -- Broadcast: actualizar UI de seguidores / seguir
        pcall(function() followUpdatedEvent:FireAllClients(player.UserId, targetUserId, not isFollowing) end)
        return true, not isFollowing
    end
    return false, "Error al seguir/dejar de seguir"
end

local function getFeed(player)
    local feedPosts = {}
    local following = (playerData[player.UserId] and playerData[player.UserId].following) or {}
    
    local postsToFetch = {}
    if playerData[player.UserId] and playerData[player.UserId].posts then
        for _, postId in ipairs(playerData[player.UserId].posts) do
            table.insert(postsToFetch, postId)
        end
    end
    
    for _, followingData in pairs(following) do
        local targetUserId = followingData.userId
        if playerData[targetUserId] and playerData[targetUserId].posts then
            for _, postId in ipairs(playerData[targetUserId].posts) do
                table.insert(postsToFetch, postId)
            end
        end
    end
    
    for _, postId in ipairs(postsToFetch) do
        local postData = getDataStore(PostsDataStore, postId)
        if postData then
            table.insert(feedPosts, postData)
        end
    end

    table.sort(feedPosts, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    local formattedPosts = {}
    for _, postData in ipairs(feedPosts) do
        local post = table.clone(postData)
        local likesCount = 0
        for _ in pairs(post.likes) do likesCount = likesCount + 1 end
        post.likesCount = likesCount
        post.commentsCount = table.getn(post.comments)
        post.isLikedByUser = post.likes and post.likes[tostring(player.UserId)] ~= nil
        table.insert(formattedPosts, post)
    end
    
    return formattedPosts
end

local function getUserPosts(userId)
    local userData = getDataStore(PlayerDataStore, tostring(userId))
    if not userData then return {} end
    
    local userPosts = {}
    for _, postId in ipairs(userData.posts) do
        local postData = getDataStore(PostsDataStore, postId)
        if postData then
            local post = table.clone(postData)
            local likesCount = 0
            for _ in pairs(post.likes) do likesCount = likesCount + 1 end
            post.likesCount = likesCount
            post.commentsCount = table.getn(post.comments)
            table.insert(userPosts, post)
        end
    end

    table.sort(userPosts, function(a, b)
        return a.timestamp > b.timestamp
    end)

    return userPosts
end

local function getPostComments(postId)
    local post = getDataStore(PostsDataStore, postId)
    if not post then
        return {}
    end
    
    local postComments = {}
    for _, commentId in ipairs(post.comments) do
        local comment = getDataStore(CommentsDataStore, commentId)
        if comment then
            table.insert(postComments, comment)
        end
    end
    
    table.sort(postComments, function(a, b)
        return a.timestamp < b.timestamp
    end)
    
    return postComments
end

local function getUserProfile(player, targetUserId)
    targetUserId = targetUserId or player.UserId
    
    local targetUserData = getDataStore(PlayerDataStore, tostring(targetUserId))
    if not targetUserData then
        return nil, "Usuario no encontrado"
    end
    
    local profile = {
        userId = targetUserId,
        displayName = targetUserData.displayName,
        bio = targetUserData.bio,
        profilePicture = targetUserData.profilePicture,
        followersCount = 0,
        followingCount = 0,
        postsCount = table.getn(targetUserData.posts),
        joinDate = targetUserData.joinDate,
        isFollowedByUser = playerData[player.UserId] and playerData[player.UserId].following[tostring(targetUserId)] ~= nil or false,
        isAdmin = targetUserData.isAdmin or false
    }
    
    if targetUserData.followers then
        for _ in pairs(targetUserData.followers) do
            profile.followersCount = profile.followersCount + 1
        end
    end
    if targetUserData.following then
        for _ in pairs(targetUserData.following) do
            profile.followingCount = profile.followingCount + 1
        end
    end

    return profile
end

-- Recomendaciones simples: usuarios con más followers que no sigas (limit 20)
local function getRecommendations(player)
    loadAllUsersData()
    local candidates = {}
    for sid, meta in pairs(allUsers) do
        if meta.userId and meta.userId ~= player.UserId then
            local target = getDataStore(PlayerDataStore, tostring(meta.userId))
            local followerCount = 0
            if target and target.followers then for _ in pairs(target.followers) do followerCount = followerCount + 1 end end
            table.insert(candidates, { userId = meta.userId, displayName = meta.displayName or meta.username or "Usuario", followersCount = followerCount })
        end
    end
    table.sort(candidates, function(a,b) return a.followersCount > b.followersCount end)
    local out = {}
    local following = playerData[player.UserId] and playerData[player.UserId].following or {}
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

-- Event Handlers (preservo tus handlers)
createPostEvent.OnServerEvent:Connect(function(player, content, imageId)
    local success, result = createPost(player, content, imageId)
    if success then
        print(player.DisplayName .. " creo un nuevo post: " .. result)
    else
        warn("Error creando post para " .. player.DisplayName .. ": " .. result)
    end
end)

likePostEvent.OnServerEvent:Connect(function(player, postId)
    local success, isLiked = likePost(player, postId)
    if success then
        print("Like actualizado para " .. player.DisplayName .. " en el post " .. postId)
    else
        warn("Error actualizando like para " .. player.DisplayName .. " en el post " .. postId)
    end
end)

commentPostEvent.OnServerEvent:Connect(function(player, postId, content)
    local success, commentData = commentOnPost(player, postId, content)
    if success then
        print(player.DisplayName .. " comentó en el post " .. postId)
        -- además del broadcast ya hecho en commentOnPost, mantenemos tu evento original para compatibilidad
        commentPostEvent:FireAllClients(postId, commentData)
    else
        warn("Error comentando post para " .. player.DisplayName)
    end
end)

followUserEvent.OnServerEvent:Connect(function(player, targetUserId)
    local success, isFollowing = followUser(player, targetUserId)
    if success then
        print(player.DisplayName .. " actualizó el estado de seguir para " .. targetUserId)
    end
end)

hideCommentEvent.OnServerEvent:Connect(function(player, commentId)
    local comment = getDataStore(CommentsDataStore, commentId)
    if comment and tostring(comment.authorId) == tostring(player.UserId) then
        comment.hidden = true
        saveDataStore(CommentsDataStore, commentId, comment)
        hideCommentEvent:FireClient(player, commentId, true)
    end
end)

-- RemoteFunction Handlers (preservo nombres)
getFeedFunction.OnServerInvoke = function(player)
    return getFeed(player)
end

getProfileFunction.OnServerInvoke = function(player, targetUserId)
    return getUserProfile(player, targetUserId)
end

searchUsersFunction.OnServerInvoke = function(player, query)
    return searchUsers(player, query)
end

getCommentsFunction.OnServerInvoke = function(player, postId)
    return getPostComments(postId)
end

getUserPostsFunction.OnServerInvoke = function(player, userId)
    return getUserPosts(userId)
end

getRecommendationsFn.OnServerInvoke = function(player)
    return getRecommendations(player)
end

-- Player Events (mantengo tu flujo)
Players.PlayerAdded:Connect(function(player)
    loadAllUsersData()
    loadPlayerData(player)
    print("FaceBlox: " .. player.DisplayName .. " se conecto a la red social")
    saveAllUsersData()
end)

Players.PlayerRemoving:Connect(function(player)
    savePlayerData(player)
    if allUsers[tostring(player.UserId)] then
        allUsers[tostring(player.UserId)].lastSeen = os.time()
    end
    saveAllUsersData()
    playerData[player.UserId] = nil
    print("FaceBlox: " .. player.DisplayName .. " se desconectó")
end)

print("=================================")
print("✨ FACEBLOX RED SOCIAL MEJORADA ✨")
print("=================================")
print("Server listo con broadcasts y recomendaciones.")
print("=================================")
