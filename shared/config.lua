return{
    --- Sign robbery config
    --- prop is the sign model that will be used to define each sign
    --- item is the item that will be given to the player when he rob the sign
    signProps = {
        {prop = "prop_sign_road_01a", item = "stop_sign"}, -- stop sign
        {prop = "prop_sign_road_03e", item = "donotblock_sign"}, -- do not block sign 
        {prop = "prop_sign_road_02a", item = "yield_sign"}, -- yield sign
        {prop = "prop_sign_road_04a", item = "noparking_sign"}, -- no parking sign
        --- add more sign models here check https://forge.plebmasters.de/objects
    },

    requireItemForRobbery = true, -- if true, you need to have the item in your inventory to rob the signs 

    robberyItem = "boltcutter", -- item needed to rob the sign. only if requireItemForRobbery is true

    alertCops = true, -- if true, it will alert the cops when a sign is robbed (change the alert to your dispatch system in the client.lua)

    --- trader config
    ---  
    traderPed = { --- Trader ped that will be used to trade stolen signs
        pedmodel = "cs_floyd", -- Ped model
        coords = vec4(-355.57, -1541.41, 26.72, 277.76), -- x, y, z, heading
    },

    itemRequiredForTrade = {
        "stop_sign",
        "donotblock_sign",
        "yield_sign",
        "noparking_sign",
        -- Add more tradable items here
    },

    ---  itemtoreceive is the item that the player will receive
    ---  amounttoreceive is the amount of item that the player will receive from the trader ped
    tradableItems = {
        {itemtoreceive = "aluminium", amounttoreceive = 10},
        {itemtoreceive = "plastic", amounttoreceive = 10},
        {itemtoreceive = "iron", amounttoreceive = 5},
        --- {itemtoreceive = "copper", amounttoreceive = 5}, You can add more items to trade here
    }
}