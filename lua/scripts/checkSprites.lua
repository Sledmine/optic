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
    print("[" .. medalsStyle .. "]")
    for _, sprite in pairs(sprites) do
        if sprite.name then
            if not images[sprite.name] and (sprite.alias and not images[sprite.alias]) then
                print("Missing image: " .. sprite.name)
            end
        end
        if sprite.name then
            if not sounds[sprite.name] and (sprite.alias and not oggs[sprite.alias]) then
                print("Missing ogg: " .. sprite.name)
            end
        end
    end
    print("")
end
checkSprites("halo_4")
checkSprites("halo_infinite")
