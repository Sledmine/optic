clua_version = 2.056

-- Modules
harmony = require "mods.harmony"
local optic = harmony.optic
local blam = require "blam"

local eventQueue = {}

-- Optic data definition
local events = {
    localKilledPlayer = "local killed player",
    localDoubleKill = "local double kill",
    localTripleKill = "local triple kill",
    localKilltacular = "local killtacular",
    localKillingSpree = "local killing spree",
    localRunningRiot = "local running riot",
    vehicleKill = "vehicle kill",
    playerKill = "player kill",
    ctfEnemyScore = "ctf enemy score",
    ctfAllyScore = "ctf ally score",
    ctfEnemyStoleFlag = "ctf enemy stole flag",
    hitmarker = "ting"
}
local currentStyle = "h4"
local imagesPath = "%s/images/%s.png"
local playerData = {deaths = 0, kills = 0, noKillSinceDead = false}

---@class sprite
---@field name string Name of the image file name of the sprite
---@field width number Width of the sprite image
---@field height number Height of sprite image
---@field renderGroup string Alternative render group for the sprite, medal group by default
---@field callback string

local sprites = {
    kill = {name = "kill", width = 64, height = 64},

    doubleKill = {name = "double_kill", width = 64, height = 64},
    tripleKill = {name = "triple_kill", width = 64, height = 64},
    killtacular = {name = "killtacular", width = 64, height = 64},
    killingSpree = {name = "killing_spree", width = 64, height = 64},
    runningRiot = {name = "running_riot", width = 64, height = 64},
    snapshot = {name = "snapshot", width = 64, height = 64},
    closeCall = {name = "close_call", width = 64, height = 64},
    hitmarkerHit = {
        name = "hitmarker",
        width = 32,
        height = 32,
        renderGroup = "crosshair"
    },
    hitmarkerKill = {
        name = "hitmarker_kill",
        width = 32,
        height = 32,
        renderGroup = "crosshair"
    }
}

--- Create and format paths for sprite images
-- This is helpful to avoid hardcoding sprite absolute paths
local function image(spriteName)
    return imagesPath:format(currentStyle, spriteName)
end

function OnMapLoad()
    -- Create sprites
    for event, sprite in pairs(sprites) do
        if (sprite.name) then
            console_out("Loading sprite: " .. sprite.name)
            optic.register_sprite(sprite.name, image(sprite.name), sprite.width,
                                  sprite.height)
        end
    end

    -- Fade in animation
    optic.register_animation("fade in", 200)
    optic.add_animation_target("fade in", "ease in", "position x", 60)
    optic.add_animation_target("fade in", "ease in", "opacity", 255)

    -- Fade out animation
    optic.register_animation("fade out", 200)
    optic.add_animation_target("fade out", "ease out", "opacity", -255)

    -- Slide animation
    optic.register_animation("slide", 300)
    optic.add_animation_target("slide", 0.4, 0.0, 0.6, 1.0, "position x", 60)

    -- Create medals render group
    optic.create_group("medals", 50, 600, 255, 0, 4000, 0, "fade in", "fade out", "slide")
    console_out("Medals loaded!")
end

---@param sprite sprite
local function medal(sprite)
    local renderGroup = sprite.renderGroup
    if (renderGroup) then
        -- TODO Add real alternate render group implementation
        -- Crosshair sprite
        local screen_width = read_word(0x637CF2)
        local screen_height = read_word(0x637CF0)
        optic.render_sprite(soundEventName, (screen_width - 35) / 2,
                            (screen_height - 35) / 2, 255, 0, 200)

    else
        optic.render_sprite("medals", sprite.name)
    end
end

function OnMultiplayerSound(soundEventName)
    console_out("sound: " .. soundEventName)
    if (soundEventName == events.hitmarker) then
        medal(sprites.hitmarkerHit)
    end
    -- return true
end

local function isKillStreak(eventName)
    if (eventName ~= events.localDoubleKill and eventName ~= events.localTripleKill and
    eventName ~= events.localKillingSpree and eventName ~= events.localKilltacular) then
        return false
    end
    return true
end

function OnMultiplayerEvent(eventName, localId, killerId, victimId)
    console_out("event: " .. eventName)
    console_out("localId: " .. tostring(localId))
    console_out("killerId: " .. tostring(killerId))
    console_out("victimId: " .. tostring(victimId))
    if (eventName == events.localKilledPlayer) then
        local lastEvent = eventQueue[#eventQueue]
        if (not isKillStreak(lastEvent)) then
            local player = blam.biped(get_dynamic_player())
            local victim = blam.biped(victimId)
            if (victim) then
                console_out("Victim is alive!")
            end
            -- TODO Check if the current player weapon is a sniper
            if (player) then
                if (blam.isNull(player.zoomLevel) and playerHasSniper) then
                    medal(sprites.snapshot)
                end
                if (player.health <= 0.25) then
                    medal(sprites.closeCall)
                end
            end
        else
            medal(sprites.kill)
        end
    elseif (eventName == events.localDoubleKill) then
        medal(sprites.doubleKill)
    elseif (eventName == events.localTripleKill) then
        medal(sprites.tripleKill)
    elseif (eventName == events.localKilltacular) then
        medal(sprites.killtacular)
    elseif (eventName == events.localKillingSpree) then
        medal(sprites.killingSpree)
    elseif (eventName == events.localRunningRiot) then
        medal(sprites.runningRiot)
    end
    eventQueue[#eventQueue + 1] = eventName
end

harmony.set_callback("multiplayer sound", "OnMultiplayeºrSound")
harmony.set_callback("multiplayer event", "OnMultiplayerEvent")
set_callback("map load", "OnMapLoad")

-- OnMapLoad()
