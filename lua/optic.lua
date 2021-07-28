clua_version = 2.056

-- Modules
harmony = require "mods.harmony"
local optic = harmony.optic
local blam = require "blam"

local debugMode = false
local medalsQueue = {}

local function dprint(message)
    if (debugMode) then
        console_out(message)
    end
end

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
-- local defaultMedalSize = 70
local playerData = {deaths = 0, kills = 0, noKillSinceDead = false}
local screenWidth = read_word(0x637CF2)
local screenHeight = read_word(0x637CF0)
-- FIXME There should be a better way to scale this, I just did simple math to obtain this value
-- local defaultMedalSize = (screenHeight * 0.065) - 1
local defaultMedalSize = (screenHeight / 15) - 1
local medalsLoaded = false

---@class sprite
---@field name string Name of the image file name of the sprite
---@field width number Width of the sprite image
---@field height number Height of sprite image
---@field renderGroup string Alternative render group for the sprite, medal group by default
---@field callback string

local sprites = {
    kill = {name = "normal_kill", width = defaultMedalSize, height = defaultMedalSize},
    doubleKill = {name = "double_kill", width = defaultMedalSize, height = defaultMedalSize},
    tripleKill = {name = "triple_kill", width = defaultMedalSize, height = defaultMedalSize},
    killtacular = {name = "killtacular", width = defaultMedalSize, height = defaultMedalSize},
    killingSpree = {name = "killing_spree", width = defaultMedalSize, height = defaultMedalSize},
    runningRiot = {name = "running_riot", width = defaultMedalSize, height = defaultMedalSize},
    snapshot = {name = "snapshot_kill", width = defaultMedalSize, height = defaultMedalSize},
    closeCall = {name = "close_call", width = defaultMedalSize, height = defaultMedalSize},
    fromTheGrave = {name = "from_the_grave", width = defaultMedalSize, height = defaultMedalSize},
    firstStrike = {name = "first_strike", width = defaultMedalSize , height = defaultMedalSize},
    rocketKill = {name = "rocket_kill", width = defaultMedalSize, height = defaultMedalSize},
    supercombine = {name = "needler_kill", width = defaultMedalSize, height = defaultMedalSize},
    hitmarkerHit = {
        name = "hitmarker",
        width = defaultMedalSize,
        height = defaultMedalSize,
        renderGroup = "crosshair"
    },
    hitmarkerKill = {
        name = "hitmarker_kill",
        width = defaultMedalSize,
        height = defaultMedalSize,
        renderGroup = "crosshair"
    }
}

--- Create and format paths for sprite images
-- This is helpful to avoid hardcoding sprite absolute paths
local function image(spriteName)
    return imagesPath:format(currentStyle, spriteName)
end

function OnScriptLoad()
    -- Create sprites
    for event, sprite in pairs(sprites) do
        if (sprite.name) then
            dprint("Loading sprite: " .. sprite.name)
            optic.register_sprite(sprite.name, image(sprite.name), sprite.width, sprite.height)
        end
    end

    -- Fade in animation
    optic.register_animation("fade in", 200)
    optic.add_animation_target("fade in", "ease in", "position x", defaultMedalSize)
    optic.add_animation_target("fade in", "ease in", "opacity", 255)

    -- Fade out animation
    optic.register_animation("fade out", 200)
    optic.add_animation_target("fade out", "ease out", "opacity", -255)

    -- Slide animation
    optic.register_animation("slide", 300)
    optic.add_animation_target("slide", 0.4, 0.0, 0.6, 1.0, "position x", defaultMedalSize)

    -- Create medals render group
    optic.create_group("medals", 50, (screenHeight / 2), 255, 0, 4000, 0, "fade in", "fade out",
                       "slide")
    medalsLoaded = true

    -- Load medals callback
    harmony.set_callback("multiplayer sound", "OnMultiplayerSound")
    harmony.set_callback("multiplayer event", "OnMultiplayerEvent")

    dprint("Medals loaded!")
end

---@param sprite sprite
local function medal(sprite)
    if (medalsLoaded) then
        medalsQueue[#medalsQueue + 1] = sprite.name
        local renderGroup = sprite.renderGroup
        if (renderGroup) then
            -- TODO Add real alternate render group implementation
            -- Crosshair sprite
            optic.render_sprite(sprite.name, (screenWidth - sprites.hitmarkerHit.width) / 2,
                                (screenHeight - sprites.hitmarkerHit.height) / 2, 255, 0, 200)

        else
            optic.render_sprite("medals", sprite.name)
        end
    else
        console_out("Error, medals were not loaded properly!")
    end
end

function OnMultiplayerSound(soundEventName)
    dprint("sound: " .. soundEventName)
    if (soundEventName == events.hitmarker) then
        medal(sprites.hitmarkerHit)
    end
    -- return true
end

local function isPreviousMedalKillVariation()
    local lastMedal = medalsQueue[#medalsQueue]
    if (lastMedal and lastMedal:find("kill") and lastMedal ~= "normal_kill") then
        medalsQueue[#medalsQueue] = nil
        return true
    end
    return false
end

function OnMultiplayerEvent(eventName, localId, killerId, victimId)
    dprint("event: " .. eventName)
    dprint("localId: " .. tostring(localId))
    dprint("killerId: " .. tostring(killerId))
    dprint("victimId: " .. tostring(victimId))
    if (eventName == events.localKilledPlayer) then
        local player = blam.biped(get_dynamic_player())
        local victim = blam.biped(victimId)
        if (victim) then
            dprint("Victim is alive!")
        end
        if (player) then
            local firstPerson = blam.firstPerson()
            if (firstPerson) then
                local weapon = blam.weapon(get_object(firstPerson.weaponObjectId))
                if (weapon) then
                    local tag = blam.getTag(weapon.tagId)
                    if (tag and blam.isNull(player.vehicleObjectId)) then
                        if (tag.path:find("sniper")) then
                            -- FIXME Check if there is a way to tell how our victim died
                            if (blam.isNull(player.zoomLevel) and player.weaponPTH) then
                                medal(sprites.snapshot)
                            end
                        elseif (tag.path:find("rocket")) then
                            medal(sprites.rocketKill)
                        elseif (tag.path:find("needler")) then
                            medal(sprites.supercombine)
                        end
                    end
                end
            end
            local localPlayer = blam.player(get_player())
            dprint(localPlayer)
            local allServerKills = 0
            for playerIndex = 0,15 do
                local playerData = blam.player(get_player(playerIndex))
                if (playerData and playerData.kills > 0 and playerData.index ~= localPlayer.index) then
                    allServerKills = allServerKills + playerData.kills
                end
            end
            if (allServerKills == 0 and localPlayer.kills == 1) then
                medal(sprites.firstStrike)
            end
            if (player.health <= 0.25) then
                medal(sprites.closeCall)
            end
            if (not isPreviousMedalKillVariation()) then
                medal(sprites.kill)
            end
            medal(sprites.hitmarkerKill)
        else
            dprint("Player is dead!")
            medal(sprites.fromTheGrave)
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
end

function OnCommand(command)
    if (command == "otest") then
        medal(sprites.kill)
        medal(sprites.runningRiot)
        medal(sprites.closeCall)
        medal(sprites.killtacular)
        medal(sprites.hitmarkerHit)
        return false
    elseif (command == "odebug") then
        debugMode = not debugMode
        return false
    end
end

function OnMapLoad()
    if (not medalsLoaded) then
        console_out("Error, medals were not loaded properly!")
    end
end

set_callback("command", "OnCommand")
set_callback("map load", "OnMapLoad")

OnScriptLoad()
