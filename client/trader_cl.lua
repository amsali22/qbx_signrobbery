--- this was taken from a old script of mine so i dont have to rewrite the trading logic again 
---
local config = require 'shared.config'
local created = false

CreateThread(function()
    if not created then
        created = true
        createTraderPed()
    end
end)

function createTraderPed()
    local pedModel = config.traderPed.pedmodel
    local coords = config.traderPed.coords
    
    local success = lib.requestModel(pedModel)
    if not success then
        print('Failed to load trader ped model. Retrying in 5 seconds...')
        Wait(5000)
        return createTraderPed()
    end
    
    local ped = CreatePed(4, GetHashKey(pedModel), coords.x, coords.y, coords.z, coords.w, false, true)
    if not DoesEntityExist(ped) then
        print('Failed to create trader ped. Retrying...')
        SetModelAsNoLongerNeeded(pedModel)
        Wait(2000)
        return createTraderPed()
    end
    
    SetEntityHeading(ped, coords.w)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetModelAsNoLongerNeeded(pedModel)
    
    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'trade_materials',
            icon = 'fas fa-recycle',
            label = 'Trade Stolen Signs',
            onSelect = function()
                openTradeMenu()
            end,
            canInteract = function()
                return true
            end,
        }
    })
end

function openTradeMenu()
    local options = {}
    
    for _, item in ipairs(config.tradableItems) do
        table.insert(options, {
            title = item.itemtoreceive:gsub("^%l", string.upper),
            description = ('Trade 1 ' .. "Sign" .. '  for %s %s'):format(item.amounttoreceive, item.itemtoreceive),
            onSelect = function()
                local count = exports.ox_inventory:Search('count', config.itemRequiredForTrade)
                if count > 0 then
                    openInputDialog(item, count)
                else
                    lib.notify({
                        id = 'trade_error',
                        title = 'Trade Failed',
                        description = 'You don\'t have any signs to trade.',
                        type = 'error'
                    })
                end
            end,
        })
    end
    
    lib.registerContext({
        id = 'trade_menu',
        title = 'Trade Stolen Signs',
        options = options
    })
    
    lib.showContext('trade_menu')
end

function openInputDialog(item, maxCount)
    local input = lib.inputDialog('Select Amount', {
        {
            type = 'slider',
            label = 'Amount',
            description = ('Trade signs for %s (Max: %s)'):format(item.itemtoreceive, maxCount),
            default = 1,
            min = 1,
            max = maxCount
        }
    })
    
    if input then
        local amount = input[1]
        executeTradeTransaction(item, amount)
    end
end

function executeTradeTransaction(item, amount)
    lib.callback('trader_ped:tradeItems', false, function(success, reason)
        if success then
            lib.notify({
                id = 'trade_success',
                title = 'Trade Successful',
                description = ('You received %s %s'):format(amount * item.amounttoreceive, item.itemtoreceive),
                type = 'success'
            })
        else
            if reason == "weight" then
                lib.notify({
                    id = 'trade_error',
                    title = 'Trade Failed',
                    description = 'You cannot carry that much weight',
                    type = 'error'
                })
            else
                lib.notify({
                    id = 'trade_error',
                    title = 'Trade Failed',
                    description = 'You don\'t have enough tradable items',
                    type = 'error'
                })
            end
        end
    end, item, amount)
end