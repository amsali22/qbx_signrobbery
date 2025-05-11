local config = require 'shared.config'
local targetsCreated = false
local cooldowns = {}

-- Helper function to check if player has the required item
local function hasRequiredItem()
    if not config.requireItemForRobbery then
        return true
    end
    
    local count = exports.ox_inventory:Search('count', config.robberyItem)
    return count > 0
end

-- Helper function to check cooldown
local function isOnCooldown(entityKey)
    if cooldowns[entityKey] and (GetGameTimer() - cooldowns[entityKey]) < 300000 then -- 5 minute cooldown
        return true
    end
    return false
end

-- Function to alert cops
local function alertCops(coords)
    if not config.alertCops then return end

    --- @param coords, is the coords of the sign you can use it to set the alert location in the map.
    -- You can replace this with your specific dispatch system
    -- Example for ps-dispatch:
    -- exports['ps-dispatch']:SignRobbery(coords)
    
    -- For me i will use the lib.notify to show the alert (replace this with your dispatch system)
    lib.notify({
        title = 'Sign Robbery Alert',
        description = 'A sign has been stolen at coordinates: ' .. tostring(coords),
        type = 'error'
    })
end

-- Function to create a robbery animation and give rewards
local function robberyAnimation(entity)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local entityCoords = GetEntityCoords(entity)
    local entityModel = GetEntityModel(entity)
    
    -- Check cooldown
    local entityKey = tostring(entityModel) .. "_" .. math.floor(entityCoords.x) .. "_" .. math.floor(entityCoords.y) .. "_" .. math.floor(entityCoords.z)
    if isOnCooldown(entityKey) then
        lib.notify({
            id = 'sign_robbery_cooldown',
            title = 'Sign Robbery',
            description = 'This sign has been stolen recently',
            type = 'error'
        })
        return
    end
    
    -- Request animation dictionary
    if not HasAnimDictLoaded('amb@prop_human_bum_bin@base') then
        lib.requestAnimDict('amb@prop_human_bum_bin@base')
        while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
            Wait(10)
        end
    end
    
    -- Create progress bar
    if lib.progressCircle({
        duration = 5000,
        label = 'Preparing to steal the sign...',
        useWhileDead = false,
        canCancel = true,
        position = 'bottom',
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@base',
            clip = 'base'
        },
    }) then
        local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}}, {'w', 'a', 's', 'd'})
        if not success then
            lib.notify({
                id = 'sign_robbery_failed',
                title = 'Sign Robbery',
                description = 'You failed to steal the sign',
                type = 'error'
            })
            return
        else
        --- alert cops
        alertCops(coords)

        lib.progressCircle({
        duration = 5000,
        label = 'taking the sign',
        useWhileDead = false,
        canCancel = true,
        position = 'bottom',
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'amb@prop_human_bum_bin@base',
            clip = 'base'
        }, })

        -- Success, give reward
        TriggerServerEvent('sign_robbery:stealSign')
        cooldowns[entityKey] = GetGameTimer()  
        -- Delete sign temporarily (will Respawn after server cleanup)
        SetEntityAsMissionEntity(entity, true, true)
        DeleteEntity(entity)
    end
    end
    
    RemoveAnimDict('amb@prop_human_bum_bin@base')
end

-- Create targets for all sign props
local function createTargets()
    if targetsCreated then return end

    for _, sign in ipairs(config.signProps) do
        exports.ox_target:addModel(sign, {
            {
                name = 'steal_sign',
                icon = 'fas fa-hand-paper',
                label = 'Steal Sign',
                onSelect = function(data)
                    -- Check if player has required item
                    if not hasRequiredItem() then
                        lib.notify({
                            id = 'sign_robbery_item',
                            title = 'Sign Robbery',
                            description = 'You need ' .. config.robberyItem .. ' to steal this sign',
                            type = 'error'
                        })
                        return
                    end
                    
                    -- Check if player is close enough to the sign
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local entityCoords = GetEntityCoords(data.entity)
                    local distance = #(playerCoords - entityCoords)
                    
                    if distance > 2.5 then
                        lib.notify({
                            id = 'sign_robbery_distance',
                            title = 'Sign Robbery',
                            description = 'You need to be closer to the sign',
                            type = 'error'
                        })
                        return
                    end
                    
                    -- Start robbery animation
                    robberyAnimation(data.entity)
                end,
                canInteract = function(entity)
                    -- Create unique key for this entity based on its model and position
                    local entityCoords = GetEntityCoords(entity)
                    local entityModel = GetEntityModel(entity)
                    local entityKey = tostring(entityModel) .. "_" .. math.floor(entityCoords.x) .. "_" .. math.floor(entityCoords.y) .. "_" .. math.floor(entityCoords.z)
                    
                    -- Don't allow interaction during cooldown
                    return not isOnCooldown(entityKey)
                end,
                distance = 2.5
            }
        })
    end
    
    targetsCreated = true
end

-- Initialize the script
CreateThread(function()
    createTargets()
end)

-- Reset cooldowns on resource restart or player joining
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        cooldowns = {}
    end
end)

-- Clear animation dictionary when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if HasAnimDictLoaded('amb@prop_human_bum_bin@base') then
            RemoveAnimDict('amb@prop_human_bum_bin@base')
        end
    end
end)