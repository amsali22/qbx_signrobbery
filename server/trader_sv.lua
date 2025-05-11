local config = require 'shared.config'
lib.callback.register('trader_ped:tradeItems', function(source, item, amount)
    local player = source
    local hasItem = exports.ox_inventory:GetItemCount(player, config.itemRequiredForTrade)
    -- we check if the player has the item required for trade
    if hasItem >= amount then
        -- Check if player can carry the items
        if exports.ox_inventory:CanCarryItem(player, item.itemtoreceive, amount * item.amounttoreceive) then
            -- Remove the recyclable materials
            if exports.ox_inventory:RemoveItem(player, config.itemRequiredForTrade, amount) then
                -- Add the traded items
                exports.ox_inventory:AddItem(player, item.itemtoreceive, amount * item.amounttoreceive)
                return true, nil
            end
        else
            return false, "weight"
        end
    end
    return false, "count"
end)