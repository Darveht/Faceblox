- FaceBlox - Red Social para Roblox (Mejorado)
-- main.lua - ServerScript Principal

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

-- DataStores
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData")
local PostsDataStore = DataStoreService:GetDataStore("Posts")
local CommentsDataStore = DataStoreService:GetDataStore("Comments")
local UsersDataStore = DataStoreService:GetDataStore("AllUsers") -- Nueva base de datos de usuarios

-- RemoteEvents y RemoteFunctions
local remoteEventsFolder = Instance.new("Folder")
remoteEventsFolder.Name = "RemoteEvents"
remoteEventsFolder.Parent = ReplicatedStorage

-- Crear RemoteEvents
local createPostEvent = Instance.new("RemoteEvent")
createPostEvent.Name = "CreatePost"
createPostEvent.Parent = remoteEventsFolder

local likePostEvent = Instance.new("RemoteEvent")
likePostEvent.Name = "LikePost"
likePostEvent.Parent = remoteEventsFolder

local commentPostEvent = Instance.new("RemoteEvent")
commentPostEvent.Name = "CommentPost"
commentPostEvent.Parent = remoteEventsFolder

local followUserEvent = Instance.new("RemoteEvent")
followUserEvent.Name = "FollowUser"
followUserEvent.Parent = remoteEventsFolder

local hideCommentEvent = Instance.new("RemoteEvent")
hideCommentEvent.Name = "HideComment"
hideCommentEvent.Parent = remoteEventsFolder

-- RemoteFunctions
local getFeedFunction = Instance.new("RemoteFunction")
getFeedFunction.Name = "GetFeed"
getFeedFunction.Parent = remoteEventsFolder

local getProfileFunction = Instance.new("RemoteFunction")
getProfileFunction.Name = "GetProfile"
getProfileFunction.Parent = remoteEventsFolder

local searchUsersFunction = Instance.new("RemoteFunction")
searchUsersFunction.Name = "SearchUsers"
searchUsersFunction.Parent = remoteEventsFolder

local getCommentsFunction = Instance.new("RemoteFunction")
getCommentsFunction.Name = "GetComments"
getCommentsFunction.Parent = remoteEventsFolder

local getUserPostsFunction = Instance.new("RemoteFunction")
getUserPostsFunction.Name = "GetUserPosts"
getUserPostsFunction.Parent = remoteEventsFolder

-- Variables globales
local playerData = {}
local posts = {}
local comments = {}
local allUsers = {} -- Base de datos de todos los usuarios

-- Lista de administradores
local admins = {"vegetl_t"} -- Cambia esto por el nombre real del admin

local function isAdmin(username)
    for _, admin in pairs(admins) do
        if string.lower(username) == string.lower(admin) then
            return true
        end
    end
    return false
end

-- Funciones auxiliares
local function generateUniqueId()
    return HttpService:GenerateGUID(false)
end

local function savePlayerData(player)
    local success, err = pcall(function()
        PlayerDataStore:SetAsync(tostring(player.UserId), playerData[player.UserId])
    end)
    if not success then
        warn("Error guardando datos del jugador: " .. err)
    end
end

local function saveAllUsersData()
    local success, err = pcall(function()
        UsersDataStore:SetAsync("AllUsersData", allUsers)
    end)
    if not success then
        warn("Error guardando base de datos de usuarios: " .. err)
    end
end

local function loadAllUsersData()
    local success, data = pcall(function()
        return UsersDataStore:GetAsync("AllUsersData")
    end)
    
    if success and data then
        allUsers = data
    else
        allUsers = {}
    end
end

local function addUserToDatabase(player)
    allUsers[tostring(player.UserId)] = {
        userId = player.UserId,
        displayName = player.DisplayName,
        username = player.Name,
        joinDate = os.time(),
        lastSeen = os.time(),
        isAdmin = isAdmin(player.Name)
    }
    saveAllUsersData()
end

local function loadPlayerData(player)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(tostring(player.UserId))
    end)
    
    if success and data then
        playerData[player.UserId] = data
    else
        -- Datos por defecto para nuevos usuarios
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
    
    -- Agregar usuario a la base de datos global
    addUserToDatabase(player)
end

-- Funciones principales
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
        comments = {},
        hidden = false
    }
    
    posts[postId] = newPost
    table.insert(playerData[player.UserId].posts, postId)
    
    -- Guardar en DataStore
    local success, err = pcall(function()
        PostsDataStore:SetAsync(postId, newPost)
    end)
    
    if success then
        savePlayerData(player)
        return true, postId
    else
        posts[postId] = nil
        return false, "Error al crear post"
    end
end

local function likePost(player, postId)
    if not posts[postId] then
        return false, "Post no encontrado"
    end
    
    local post = posts[postId]
    local userId = tostring(player.UserId)
    
    -- Toggle like
    if post.likes[userId] then
        post.likes[userId] = nil
    else
        post.likes[userId] = {
            userId = player.UserId,
            displayName = player.DisplayName,
            timestamp = os.time()
        }
    end
    
    -- Guardar cambios
    PostsDataStore:SetAsync(postId, post)
    return true, post.likes[userId] ~= nil
end

local function commentOnPost(player, postId, content)
    if not posts[postId] then
        return false, "Post no encontrado"
    end
    
    local commentId = generateUniqueId()
    local newComment = {
        id = commentId,
        postId = postId,
        authorId = player.UserId,
        authorName = player.DisplayName,
        content = content,
        timestamp = os.time(),
        likes = {},
        replies = {},
        hidden = false
    }
    
    comments[commentId] = newComment
    table.insert(posts[postId].comments, commentId)
    
    -- Guardar en DataStore
    CommentsDataStore:SetAsync(commentId, newComment)
    PostsDataStore:SetAsync(postId, posts[postId])
    
    return true, commentId
end

local function getPostComments(postId)
    if not posts[postId] then
        return {}
    end
    
    local postComments = {}
    for _, commentId in ipairs(posts[postId].comments) do
        if comments[commentId] and not comments[commentId].hidden then
            table.insert(postComments, comments[commentId])
        end
    end
    
    -- Ordenar por timestamp
    table.sort(postComments, function(a, b)
        return a.timestamp < b.timestamp
    end)
    
    return postComments
end

local function getUserPosts(userId)
    local userPosts = {}
    
    for postId, post in pairs(posts) do
        if post.authorId == userId and not post.hidden then
            -- Agregar información adicional
            post.likesCount = 0
            for _ in pairs(post.likes) do
                post.likesCount = post.likesCount + 1
            end
            post.commentsCount = #post.comments
            post.isLikedByUser = false -- Se puede mejorar para el usuario actual
            
            table.insert(userPosts, post)
        end
    end
    
    -- Ordenar por timestamp (más recientes primero)
    table.sort(userPosts, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    return userPosts
end

local function followUser(player, targetUserId)
    if not playerData[targetUserId] then
        return false, "Usuario no encontrado"
    end
    
    local followerId = player.UserId
    local isFollowing = false
    
    -- Toggle follow
    if playerData[followerId].following[tostring(targetUserId)] then
        -- Unfollow
        playerData[followerId].following[tostring(targetUserId)] = nil
        playerData[targetUserId].followers[tostring(followerId)] = nil
        isFollowing = false
    else
        -- Follow
        playerData[followerId].following[tostring(targetUserId)] = {
            userId = targetUserId,
            timestamp = os.time()
        }
        playerData[targetUserId].followers[tostring(followerId)] = {
            userId = followerId,
            displayName = player.DisplayName,
            timestamp = os.time()
        }
        isFollowing = true
    end
    
    savePlayerData(player)
    -- También guardar datos del usuario objetivo si está online
    for _, onlinePlayer in pairs(Players:GetPlayers()) do
        if onlinePlayer.UserId == targetUserId then
            savePlayerData(onlinePlayer)
            break
        end
    end
    
    return true, isFollowing
end

local function getFeed(player, page)
    page = page or 1
    local postsPerPage = 10
    local startIndex = (page - 1) * postsPerPage + 1
    
    -- Obtener posts de usuarios seguidos + posts propios
    local feedPosts = {}
    local following = playerData[player.UserId].following
    
    for postId, post in pairs(posts) do
        if post.authorId == player.UserId or following[tostring(post.authorId)] then
            if not post.hidden then
                table.insert(feedPosts, post)
            end
        end
    end
    
    -- Ordenar por timestamp (más recientes primero)
    table.sort(feedPosts, function(a, b)
        return a.timestamp > b.timestamp
    end)
    
    -- Paginar resultados
    local paginatedPosts = {}
    for i = startIndex, math.min(startIndex + postsPerPage - 1, #feedPosts) do
        if feedPosts[i] then
            -- Agregar información adicional a cada post
            local postData = feedPosts[i]
            postData.likesCount = 0
            for _ in pairs(postData.likes) do
                postData.likesCount = postData.likesCount + 1
            end
            postData.commentsCount = #postData.comments
            postData.isLikedByUser = postData.likes[tostring(player.UserId)] ~= nil
            
            table.insert(paginatedPosts, postData)
        end
    end
    
    return paginatedPosts, #feedPosts > startIndex + postsPerPage - 1
end

local function getUserProfile(player, targetUserId)
    targetUserId = targetUserId or player.UserId
    
    if not playerData[targetUserId] then
        return nil, "Usuario no encontrado"
    end
    
    local profile = {
        userId = targetUserId,
        displayName = playerData[targetUserId].displayName,
        bio = playerData[targetUserId].bio,
        profilePicture = playerData[targetUserId].profilePicture,
        followersCount = 0,
        followingCount = 0,
        postsCount = #playerData[targetUserId].posts,
        joinDate = playerData[targetUserId].joinDate,
        isFollowedByUser = playerData[player.UserId].following[tostring(targetUserId)] ~= nil,
        isAdmin = playerData[targetUserId].isAdmin or false
    }
    
    -- Contar seguidores y seguidos
    for _ in pairs(playerData[targetUserId].followers) do
        profile.followersCount = profile.followersCount + 1
    end
    
    for _ in pairs(playerData[targetUserId].following) do
        profile.followingCount = profile.followingCount + 1
    end
    
    return profile
end

local function searchUsers(player, query)
    local results = {}
    query = string.lower(query)
    
    -- Buscar en la base de datos de todos los usuarios
    for userId, userData in pairs(allUsers) do
        if string.find(string.lower(userData.displayName), query) or 
           string.find(string.lower(userData.username), query) then
            
            local followerCount = 0
            if playerData[tonumber(userId)] then
                for _ in pairs(playerData[tonumber(userId)].followers) do
                    followerCount = followerCount + 1
                end
            end
            
            table.insert(results, {
                userId = tonumber(userId),
                displayName = userData.displayName,
                username = userData.username,
                profilePicture = "rbxasset://textures/face.png",
                followersCount = followerCount,
                isAdmin = userData.isAdmin or false
            })
        end
    end
    
    -- Limitar resultados
    if #results > 20 then
        local limitedResults = {}
        for i = 1, 20 do
            table.insert(limitedResults, results[i])
        end
        return limitedResults
    end
    
    return results
end

-- Event Handlers
createPostEvent.OnServerEvent:Connect(function(player, content, imageId)
    local success, result = createPost(player, content, imageId)
    if success then
        print(player.DisplayName .. " creó un nuevo post: " .. result)
    else
        warn("Error creando post para " .. player.DisplayName .. ": " .. result)
    end
end)

likePostEvent.OnServerEvent:Connect(function(player, postId)
    local success, isLiked = likePost(player, postId)
    if success then
        likePostEvent:FireClient(player, postId, isLiked)
    end
end)

commentPostEvent.OnServerEvent:Connect(function(player, postId, content)
    local success, commentId = commentOnPost(player, postId, content)
    if success then
        commentPostEvent:FireClient(player, postId, commentId, true)
    else
        commentPostEvent:FireClient(player, postId, nil, false)
    end
end)

followUserEvent.OnServerEvent:Connect(function(player, targetUserId)
    local success, isFollowing = followUser(player, targetUserId)
    if success then
        followUserEvent:FireClient(player, targetUserId, isFollowing)
    end
end)

hideCommentEvent.OnServerEvent:Connect(function(player, commentId)
    if comments[commentId] and comments[commentId].authorId == player.UserId then
        comments[commentId].hidden = true
        CommentsDataStore:SetAsync(commentId, comments[commentId])
        hideCommentEvent:FireClient(player, commentId, true)
    end
end)

-- RemoteFunction Handlers
getFeedFunction.OnServerInvoke = function(player, page)
    return getFeed(player, page)
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

-- Player Events
Players.PlayerAdded:Connect(function(player)
    -- Cargar base de datos de usuarios
    loadAllUsersData()
    
    loadPlayerData(player)
    print("FaceBlox: " .. player.DisplayName .. " se conectó a la red social")
    
    -- Actualizar última vez visto
    if allUsers[tostring(player.UserId)] then
        allUsers[tostring(player.UserId)].lastSeen = os.time()
        saveAllUsersData()
    end
    
    -- Cargar posts existentes
    local success, existingPosts = pcall(function()
        return PostsDataStore:ListKeysAsync("", 100)
    end)
    
    if success then
        for _, key in pairs(existingPosts:GetCurrentPage()) do
            if not posts[key.KeyName] then
                local postData = PostsDataStore:GetAsync(key.KeyName)
                if postData then
                    posts[key.KeyName] = postData
                end
            end
        end
    end
    
    -- Cargar comentarios existentes
    local commentsSuccess, existingComments = pcall(function()
        return CommentsDataStore:ListKeysAsync("", 200)
    end)
    
    if commentsSuccess then
        for _, key in pairs(existingComments:GetCurrentPage()) do
            if not comments[key.KeyName] then
                local commentData = CommentsDataStore:GetAsync(key.KeyName)
                if commentData then
                    comments[key.KeyName] = commentData
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    -- Actualizar última vez visto antes de salir
    if allUsers[tostring(player.UserId)] then
        allUsers[tostring(player.UserId)].lastSeen = os.time()
        saveAllUsersData()
    end
    
    savePlayerData(player)
    playerData[player.UserId] = nil
    print("FaceBlox: " .. player.DisplayName .. " se desconectó")
end)

print("=================================")
print("🚀 FACEBLOX RED SOCIAL MEJORADA 🚀")
print("=================================")
print("Nuevas características:")
print("✅ Interfaz de pantalla completa")
print("✅ Sistema de comentarios completo")
print("✅ Perfiles expandidos clickeables")
print("✅ Insignias de verificación para admins")
print("✅ Base de datos completa de usuarios")
print("✅ Búsqueda mejorada en todos los usuarios")
print("✅ Botones de seguir en perfiles")
print("✅ Vista de posts de usuarios individuales")
print("=================================")
print("Admin configurado: " .. table.concat(admins, ", "))
print("=================================")
