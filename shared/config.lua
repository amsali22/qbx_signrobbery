return{
    --- Sign robbery config
    --- 
    signProps = {
        "prop_sign_road_01a", -- stop sign
        "prop_sign_road_03e", -- do not block sign 
        "prop_sign_road_02a", -- yeld sign
        "prop_sign_road_04a", -- no parking sign
        --- add more sign models here check https://forge.plebmasters.de/objects
    },

    requireItemForRobbery = true, -- if true, you need to have the item in your inventory to rob the signs 

    robberyItem = "water", -- item needed to rob the sign. only if requireItemForRobbery is true

    alertCops = true, -- if true, it will alert the cops when a sign is robbed (change the alert to your dispatch system in the client.lua)

    --- trader config
    --- 
    traderPed = { --- Trader ped that will be used to trade stolen signs
        pedmodel = "cs_floyd", -- Ped model
        coords = vec4(-355.57, -1541.41, 26.72, 277.76), -- x, y, z, heading
    },

    itemRequiredForTrade = "stolen_sign", -- Item that the player will give to the trader ped its also the item that the player will receive when robbing the sign

    ---  itemtoreceive is the item that the player will receive
    ---  amounttotake is the amount of item that the player will give to the trader ped
    ---  amounttoreceive is the amount of item that the player will receive from the trader ped
    tradableItems = {
        {itemtoreceive = "aluminium", amounttotake = 1, amounttoreceive = 10},
        {itemtoreceive = "plastic", amounttotake = 1, amounttoreceive = 10},
        {itemtoreceive = "iron", amounttotake = 1, amounttoreceive = 5},
        --- {itemtoreceive = "copper", amounttotake = 1, amounttoreceive = 5}, You can add more items to trade here
    }
}