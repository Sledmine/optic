local fs = require "fs"
local sprites = require "lua.optic.sprites"()

local function checkSprites(medalsStyle)
    local images = {}
    for fileName, entry in fs.dir(("data/%s/images"):format(medalsStyle)) do
        local name = fileName:gsub(".png", "")
        images[name] = true
    end
    local oggs = {}
    for fileName, entry in fs.dir(("data/%s/sounds/ogg"):format(medalsStyle)) do
        local name = fileName:gsub(".ogg", "")
        oggs[name] = true
    end
    local sounds = {}
    for fileName, entry in fs.dir(("data/%s/sounds"):format(medalsStyle)) do
        local name = fileName:gsub(".mp3", "")
        sounds[name] = true
    end
    for _, sprite in pairs(sprites) do
        --if not images[sprite.name] or not oggs[sprite.name] or not sounds[sprite.name] then
        if not images[sprite.name] or not oggs[sprite.name] then
            io.write(medalsStyle .. " -> " .. sprite.name .. " - ")
        end
        if not images[sprite.name] then
            io.write("IMAGE ")
        end
        if not oggs[sprite.name] then
            io.write("OGG ")
        end
        --if not sounds[sprite.name] then
        --    io.write("SOUND ")
        --end
        print("")
    end
    print("")
end
checkSprites("halo_4")
checkSprites("halo_infinite")
