-- Server: FaceBlox (pegar en ServerScriptService)
-- CAMBIOS IMPORTANTES:
-- 1) Aseguro que el admin siempre tenga followersCount sincronizado (getAdminData aplicado globalmente).
-- 2) Cuando se cargan allUsers, admin usa follower count especial.
-- 3) Cuando se actualizan follows, si objetivo es admin el displayed followers usa el valor admin especial.
-- 4) Proporciono endpoints RemoteFunction/RemoteEvent tal como tu cliente espera.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local PlayerDataStore   = DataStoreService:GetDataStore("PlayerData")
local PostsDataStore    = DataStoreService:GetDataStore("Posts")
local PostsIndexStore   = DataStoreService:GetDataStore("PostsIndex")
local CommentsDataStore = DataStoreService:GetDataStore("Comments")
local UsersDataStore    = DataStoreService:GetDataStore("AllUsers")
local ReportsDataStore  = DataStoreService:GetDataStore("Reports")

local function getOrCreate(parent, className, name)
    local existing = parent:FindFirstChild(name)
    if existing then return existing end
    local inst = Instance.new(className)
    inst.Name = name
    inst.Parent = parent
    return inst
end

local remoteEventsFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not remoteEventsFolder then
    remoteEventsFolder = Instance.new("Folder", ReplicatedStorage)
    remoteEventsFolder.Name = "RemoteEvents"
end

-- Cliente -> servidor
local createPostEvent    = getOrCreate(remoteEventsFolder, "RemoteEvent", "CreatePost")
local likePostEvent      = getOrCreate(remoteEventsFolder, "RemoteEvent", "LikePost")
local commentPostEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "CommentPost")
local followUserEvent    = getOrCreate(remoteEventsFolder, "RemoteEvent", "FollowUser")
local hideCommentEvent   = getOrCreate(remoteEventsFolder, "RemoteEvent", "HideComment")
local reportUserEvent    = getOrCreate(remoteEventsFolder, "RemoteEvent", "ReportUser")
local deleteCommentEvent = getOrCreate(remoteEventsFolder, "RemoteEvent", "DeleteComment")

-- Servidor -> cliente
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

-- Memoria
local playerData = {}
local allUsers = {}
local postsIndex = {}
local pendingReports = {}

-- Admins (siempre 'vegetl_t' en tu ejemplo)
local admins = {
{username = "vegetl_t", displayName = "darheel"}
}

local function isAdmin(username, displayName)
    for _, admin in pairs(admins) do
        if string.lower(username or "") == string.lower(admin.username)
            or (displayName and string.lower(displayName) == string.lower(admin.displayName)) then
            return true
        end
    end
    return false
end

local function getAdminData()
    return {
    followersCount = 222000,
    isVerified = true,
    isAdmin = true,
    displayName = "vegetl_t",
    username = "vegetl_t"
    }
end

local function isVerified(username, displayName, followersCount)
    local lowerUsername = string.lower(username or "")
    local lowerDisplayName = string.lower(displayName or "")
    if lowerUsername == "vegetl_t" or lowerDisplayName == "vegetl_t" then
        return true
    end
    return (followersCount or 0) >= 1000
end

-- DataStore helpers con retries
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
            if success then return result else return nil end
        end
        
        local function generateUniqueId()
            return HttpService:GenerateGUID(false)
        end
        
        -- Save/load helpers
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
            
            -- asegurar que la entrada admin (si existe por username) tenga followersCount especial
            for k, v in pairs(allUsers) do
                if v.username and string.lower(v.username) == "vegetl_t" then
                    local adminData = getAdminData()
                    allUsers[k].followersCount = adminData.followersCount
                    allUsers[k].isVerified = true
                    allUsers[k].isAdmin = true
                end
            end
        end
        
        local function loadPostsIndex()
            local idx = getDataStore(PostsIndexStore, "AllPosts")
            if idx and type(idx) == "table" then postsIndex = idx else postsIndex = {} end
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
            
            -- actualizar allUsers y sincronizar admin si corresponde
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
            
            -- si este usuario es el admin por username, forzamos followersCount (sincronización global)
            if string.lower(player.Name or "") == "vegetl_t" then
                local adminData = getAdminData()
                followersCount = adminData.followersCount
                allUsers[key].isVerified = true
                allUsers[key].isAdmin = true
            else
                allUsers[key].isVerified = isVerified(player.Name, player.DisplayName, followersCount)
            end
            
            allUsers[key].followersCount = followersCount
        end
        
        -- ---------- FUNCIONES PRINCIPALES ----------
        local function createPost(player, content, imageId, musicId)
            local postId = generateUniqueId()
            local followersCount = 0
            if playerData[player.UserId] and playerData[player.UserId].followers then
                for _ in pairs(playerData[player.UserId].followers) do followersCount = followersCount + 1 end
            end
            
            local avatar = (playerData[player.UserId] and playerData[player.UserId].profilePicture) or ("https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=150&height=150&format=png")
            
            local newPost = {
            id = postId,
            authorId = player.UserId,
            authorName = player.DisplayName,
            authorUsername = player.Name,
            profilePicture = avatar,
            content = content or "",
            imageId = imageId or "",
            musicId = musicId or "",
            timestamp = os.time(),
            likes = {},
            comments = {},
            isVerified = isVerified(player.Name, player.DisplayName, followersCount)
            }
            
            local success = saveDataStore(PostsDataStore, postId, newPost)
            if not success then return false, "Error guardando post" end
            
            playerData[player.UserId].posts = playerData[player.UserId].posts or {}
            table.insert(playerData[player.UserId].posts, 1, postId)
            savePlayerData(player)
            
            postsIndex = postsIndex or {}
            table.insert(postsIndex, 1, postId)
            local MAX_INDEX = 500
            while #postsIndex > MAX_INDEX do table.remove(postsIndex, #postsIndex) end
            saveDataStore(PostsIndexStore, "AllPosts", postsIndex)
            
            pcall(function() postCreatedEvent:FireAllClients(newPost) end)
                return true, postId
            end
            
            local function likePost(player, postId)
                local post = getDataStore(PostsDataStore, postId)
                if not post then return false, "Post no encontrado" end
                
                local userIdStr = tostring(player.UserId)
                post.likes = post.likes or {}
                local isLiked = post.likes[userIdStr] ~= nil
                
                if isLiked then post.likes[userIdStr] = nil
                else post.likes[userIdStr] = { userId = player.UserId, displayName = player.DisplayName, timestamp = os.time() } end
                    
                    local success = saveDataStore(PostsDataStore, postId, post)
                    if not success then return false, "Error actualizando like" end
                    
                    local likesCount = 0
                    for _ in pairs(post.likes or {}) do likesCount = likesCount + 1 end
                    local commentsCount = #(post.comments or {})
                    pcall(function() postUpdatedEvent:FireAllClients(postId, likesCount, commentsCount) end)
                        return true, not isLiked
                    end
                    
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
                        
                        pcall(function() commentAddedEvent:FireAllClients(postId, newComment) end)
                            local likesCount = 0
                            for _ in pairs(post.likes or {}) do likesCount = likesCount + 1 end
                            pcall(function() postUpdatedEvent:FireAllClients(postId, likesCount, #post.comments) end)
                                
                                return true, newComment
                            end
                            
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
                                    -- actualizar allUsers (y sincronizar admin)
                                    loadAllUsersData()
                                    if allUsers[targetUserIdStr] then
                                        -- si el target es admin por username, forzamos el admin follower count especial
                                        if string.lower(allUsers[targetUserIdStr].username or "") == "vegetl_t" then
                                            local adminData = getAdminData()
                                            allUsers[targetUserIdStr].followersCount = adminData.followersCount
                                            allUsers[targetUserIdStr].isVerified = true
                                            allUsers[targetUserIdStr].isAdmin = true
                                        else
                                            local newFollowersCount = 0
                                            for _ in pairs(targetUserData.followers or {}) do newFollowersCount = newFollowersCount + 1 end
                                            allUsers[targetUserIdStr].followersCount = newFollowersCount
                                            allUsers[targetUserIdStr].isVerified = isVerified(allUsers[targetUserIdStr].username, allUsers[targetUserIdStr].displayName, newFollowersCount)
                                        end
                                        saveAllUsersData()
                                    end
                                    
                                    pcall(function() followUpdatedEvent:FireAllClients(player.UserId, targetUserId, not isFollowing) end)
                                        return true, not isFollowing
                                    end
                                    return false, "Error al seguir/dejar de seguir"
                                end
                                
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
                                                    local followersCount = fullUserData.followers and (function()
                                                        local c=0; for _ in pairs(fullUserData.followers) do c=c+1 end; return c
                                                    end)() or 0
                                                    
                                                    -- Si el usuario es admin por username, forzamos valor admin
                                                    if string.lower(userData.username or "") == "vegetl_t" then
                                                        local adminData = getAdminData()
                                                        followersCount = adminData.followersCount
                                                    end
                                                    
                                                    table.insert(results, {
                                                    userId = userData.userId,
                                                    displayName = userData.displayName,
                                                    username = userData.username,
                                                    followersCount = followersCount,
                                                    isVerified = (string.lower(userData.username or "") == "vegetl_t") or isVerified(userData.username, userData.displayName, followersCount),
                                                    profilePicture = fullUserData.profilePicture or "rbxasset://textures/face.png"
                                                    })
                                                end
                                            end
                                        end
                                    end
                                    
                                    pcall(function() searchResultsEvent:FireClient(player, results) end)
                                        return results
                                    end
                                    
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
                                                post.profilePicture = post.profilePicture or post.authorProfilePicture or ("https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(post.authorId).."&width=150&height=150&format=png")
                                                post.likesCount = 0
                                                for _ in pairs(post.likes or {}) do post.likesCount = post.likesCount + 1 end
                                                post.commentsCount = #(post.comments or {})
                                                post.isLikedByUser = (post.likes and post.likes[tostring(player.UserId)] ~= nil) or false
                                                
                                                -- si el author es admin por username, forzar isVerified + followersCount fuente admin (cliente no recibe followersCount en post, pero isVerified es importante)
                                                if string.lower(post.authorUsername or "") == "vegetl_t" then
                                                    post.isVerified = true
                                                end
                                                
                                                table.insert(feedPosts, post)
                                                count = count + 1
                                            end
                                        end
                                        
                                        table.sort(feedPosts, function(a,b) return (a.timestamp or 0) > (b.timestamp or 0) end)
                                            return feedPosts
                                        end
                                        
                                        local function getUserPosts(userId)
                                            local userData = getDataStore(PlayerDataStore, tostring(userId))
                                            if not userData then return {} end
                                            
                                            local userPosts = {}
                                            for _, postId in ipairs(userData.posts or {}) do
                                                local postData = getDataStore(PostsDataStore, postId)
                                                if postData then
                                                    local post = table.clone(postData)
                                                    post.profilePicture = post.profilePicture or post.authorProfilePicture
                                                    post.likesCount = 0
                                                    for _ in pairs(post.likes or {}) do post.likesCount = post.likesCount + 1 end
                                                    post.commentsCount = #(post.comments or {})
                                                    if string.lower(post.authorUsername or "") == "vegetl_t" then post.isVerified = true end
                                                    table.insert(userPosts, post)
                                                end
                                            end
                                            
                                            table.sort(userPosts, function(a, b) return a.timestamp > b.timestamp end)
                                                return userPosts
                                            end
                                            
                                            local function getPostComments(postId)
                                                local post = getDataStore(PostsDataStore, postId)
                                                if not post then return {} end
                                                
                                                local postComments = {}
                                                for _, commentId in ipairs(post.comments or {}) do
                                                    local comment = getDataStore(CommentsDataStore, commentId)
                                                    if comment and not comment.deleted then
                                                        -- si el autor es admin forzamos isVerified
                                                        if string.lower(comment.authorUsername or "") == "vegetl_t" then
                                                            comment.isVerified = true
                                                        end
                                                        table.insert(postComments, comment)
                                                    end
                                                end
                                                
                                                table.sort(postComments, function(a,b) return a.timestamp < b.timestamp end)
                                                    return postComments
                                                end
                                                
                                                local function getProfile(player, targetUserId)
                                                    targetUserId = targetUserId or player.UserId
                                                    local targetUserData = getDataStore(PlayerDataStore, tostring(targetUserId))
                                                    if not targetUserData then return nil, "Usuario no encontrado" end
                                                    
                                                    local successName, playerName = pcall(function() return Players:GetNameFromUserIdAsync(tonumber(targetUserId)) end)
                                                        if not successName then playerName = targetUserData.username or ("User"..tostring(targetUserId)) end
                                                        
                                                        local isAdminFlag = false
                                                        if playerName then
                                                            isAdminFlag = (string.lower(playerName) == "vegetl_t") or (targetUserData.username and string.lower(targetUserData.username) == "vegetl_t")
                                                        end
                                                        
                                                        -- compute followersCount (respetando admin override)
                                                        local followersCount = 0
                                                        if isAdminFlag then
                                                            local adminData = getAdminData()
                                                            followersCount = adminData.followersCount
                                                        else
                                                            if targetUserData.followers then
                                                                for _ in pairs(targetUserData.followers) do followersCount = followersCount + 1 end
                                                            end
                                                        end
                                                        
                                                        local followingCount = 0
                                                        if targetUserData.following then
                                                            for _ in pairs(targetUserData.following) do followingCount = followingCount + 1 end
                                                        end
                                                        
                                                        -- refrescar allUsers entry si existe
                                                        loadAllUsersData()
                                                        if allUsers[tostring(targetUserId)] then
                                                            allUsers[tostring(targetUserId)].followersCount = followersCount
                                                            allUsers[tostring(targetUserId)].isVerified = isAdminFlag or isVerified(targetUserData.username or "", targetUserData.displayName, followersCount)
                                                            saveAllUsersData()
                                                        end
                                                        
                                                        local profile = {
                                                        userId = targetUserId,
                                                        displayName = targetUserData.displayName or playerName,
                                                        username = targetUserData.username or playerName,
                                                        bio = targetUserData.bio,
                                                        profilePicture = targetUserData.profilePicture,
                                                        followersCount = followersCount,
                                                        followingCount = followingCount,
                                                        postsCount = #(targetUserData.posts or {}),
                                                        joinDate = targetUserData.joinDate,
                                                        isFollowedByUser = (playerData[player.UserId] and playerData[player.UserId].following[tostring(targetUserId)]) ~= nil,
                                                        isAdmin = isAdminFlag,
                                                        isVerified = isAdminFlag or isVerified(targetUserData.username or "", targetUserData.displayName, followersCount)
                                                        }
                                                        
                                                        return profile
                                                    end
                                                    
                                                    local function getRecommendations(player)
                                                        loadAllUsersData()
                                                        local candidates = {}
                                                        for sid, meta in pairs(allUsers) do
                                                            if meta.userId and meta.userId ~= player.UserId then
                                                                local target = getDataStore(PlayerDataStore, tostring(meta.userId))
                                                                local followerCount = meta.followersCount or 0
                                                                local isAdminUser = string.lower(meta.username or "") == "vegetl_t"
                                                                if isAdminUser then
                                                                    local adminData = getAdminData()
                                                                    followerCount = adminData.followersCount
                                                                end
                                                                table.insert(candidates, {
                                                                userId = meta.userId,
                                                                displayName = meta.displayName or meta.username or "Usuario",
                                                                username = meta.username or "",
                                                                followersCount = followerCount,
                                                                isVerified = isAdminUser or meta.isVerified or isVerified(meta.username or "", meta.displayName or "", followerCount),
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
                                                        
                                                        -- ---------- HANDLERS ----------
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
                                                                    getProfileFunction.OnServerInvoke = function(player, targetUserId) return getProfile(player, targetUserId) end
                                                                    searchUsersFunction.OnServerInvoke = function(player, query) return searchUsers(player, query) end
                                                                    getCommentsFunction.OnServerInvoke = function(player, postId) return getPostComments(postId) end
                                                                    getUserPostsFunction.OnServerInvoke = function(player, userId) return getUserPosts(userId) end
                                                                    getRecommendationsFn.OnServerInvoke = function(player) return getRecommendations(player) end
                                                                    getAdminReportsFunction.OnServerInvoke = function(player)
                                                                        if isAdmin(player.Name, player.DisplayName) then return pendingReports else return {} end
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
                                                                        if allUsers[tostring(player.UserId)] then allUsers[tostring(player.UserId)].lastSeen = os.time() end
                                                                        saveAllUsersData()
                                                                        playerData[player.UserId] = nil
                                                                        print("FaceBlox: " .. player.DisplayName .. " desconectado")
                                                                    end)
                                                                    
                                                                    print("=================================")
                                                                    print("✨ FACEBLOX SERVER ACTUALIZADO (admin sync + reproductor con tiempo) ✨")
                                                                    print("=================================")



