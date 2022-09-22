local fs = require "fs"
local sprites = require "lua.optic.sprites"(1)
local inspect = require "inspect"

local function checkSprites(medalsStyle)
    local images = {}
    for fileName, entry in fs.dir(("data/%s/images"):format(medalsStyle)) do
        local name = fileName:gsub(".png", "")
        images[name] = true
    end
    local sourceSound = {}
    for fileName, entry in fs.dir(("data/%s/sounds/source"):format(medalsStyle)) do
        local name = fileName:gsub(".ogg", "")
        name = name:gsub(".wav", "")
        sourceSound[name] = true
    end
    -- local sounds = {}
    -- for fileName, entry in fs.dir(("data/%s/sounds"):format(medalsStyle)) do
    --    local name = fileName:gsub(".mp3", "")
    --    sounds[name] = true
    -- end
    print("[" .. medalsStyle .. "]")
    for _, sprite in pairs(sprites) do
        if not images[sprite.name] and not images[sprite.alias or sprite.name] then
            print("Image: " .. sprite.name)
        end
        if not sourceSound[sprite.name] and not sourceSound[sprite.alias or sprite.name] then
            print("Sound: " .. sprite.name)
        end
    end
    print("")
end
checkSprites("halo_4")
checkSprites("halo_infinite")
