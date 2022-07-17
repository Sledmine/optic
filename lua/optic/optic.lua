local glue = require "glue"
local deepcopy = glue.deepcopy
clua_version = 2.056

-- Modules
local harmony = require "mods.harmony"
local optic = harmony.optic
local blam = require "blam"
local json = require "json"
local glue = require "glue"
local createSprites = require "optic.sprites"
-- Switches
local DebugMode = false
local opticVersion = "3.0.0"

-- Controlled by optic.json config file, do not edit on the script!
local configuration = {ActiveSound = true, hitmarker = true, hudMessages = true, style = "halo_4", volume = 50}

local function dprint(message)
    if (DebugMode) then
        console_out(message)
    end
end

local events = {
    fallingDead = "falling dead",
    guardianKill = "guardian kill",
    vehicleKill = "vehicle kill",
    playerKill = "player kill",
    betrayed = "betrayed",
    suicide = "suicide",
    localKilledPlayer = "local killed player",
    localDoubleKill = "local double kill",
    localTripleKill = "local triple kill",
    localKilltacular = "local killtacular",
    localKillingSpree = "local killing spree",
    localRunningRiot = "local running riot",
    localCtfScore = "local ctf score",
    ctfEnemyScore = "ctf enemy score",
    ctfAllyScore = "ctf ally score",
    ctfEnemyStoleFlag = "ctf enemy stole flag",
    ctfEnemyReturnedFLag = "ctf enemy returned flag",
    ctfAllyStoleFlag = "ctf ally stole flag",
    ctfAllyReturnedFlag = "ctf ally returned flag",
    ctfFriendlyFlagIdleReturned = "ctf friendly flag idle returned",
    ctfEnemyFlagIdleReturned = "ctf enemy flag idle returned"
}

local soundsEvents = {hitmarker = "ting"}

local imagesPath = "%s/images/%s.png"
local soundsPath = "%s/sounds/%s.mp3"
local opticStylePath = "%s/sprites.style"
local playerData = {
    deaths = 0,
    kills = 0,
    noKillSinceDead = false,
    killingSpreeCount = 0,
    dyingSpreeCount = 0,
    multiKillCount = 0,
    multiKillTimestamp = nil,
    flagCaptures = 0
}
local defaultPlayerData = deepcopy(playerData)

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
---@field hasAudio boolean

--- Create and format paths for sprite images
--- This is helpful to avoid hardcoding sprite absolute paths
local function image(spriteName)
    return imagesPath:format(configuration.style, spriteName)
end

--- Create and format paths for sprite images
-- This is helpful to avoid hardcoding sprite absolute paths
local function audio(spriteName)
    return soundsPath:format(configuration.style, spriteName)
end

local sprites
local sounds
local medalsQueue = {}
local harmonySprites = {}
local harmonySounds = {}

local function loadOpticStyle()
    local styleFile = read_file(opticStylePath:format(configuration.style))
    if (styleFile) then
        local style = json.decode(styleFile)
        if (style) then
            defaultMedalSize = (screenHeight / style.medalSizeFactor) - 1
            return true
        end
    end
    console_out("Error, Optic style does not have a style.json file!")
    return false
end

local function loadOpticConfiguration()
    dprint("Loading optic configuration...")
    local opticConfiguration = read_file("optic.json")
    if (opticConfiguration) then
        configuration = json.decode(opticConfiguration)
        dprint("Success, configuration loaded correctly.")
        loadOpticStyle()
        return true
    end
    dprint("Warning, unable to load optic configuration.")
    return false
end

local function saveOpticConfiguration()
    dprint("Saving optic configuration...")
    local configurationSavedSuccesfully = write_file("optic.json", json.encode(configuration))
    if (configurationSavedSuccesfully) then
        dprint("Success, configuration saved successfully.")
        return true
    end
    dprint("Warning, unable to save optic configuration.")
    return false
end

function OnScriptLoad()
    loadOpticConfiguration()

    sprites = createSprites(defaultMedalSize)

    sounds = {suicide = {name = "suicide"}, betrayal = {name = "betrayal"}}

    -- Create sprites
    for event, sprite in pairs(sprites) do
        if (sprite.name) then
            local medalImagePath = image(sprite.name)
            local medalSoundPath = audio(sprite.name)
            if not file_exists(medalImagePath) then
                medalImagePath = image(sprite.alias)
                medalSoundPath = audio(sprite.alias)
            end
            dprint("Loading sprite: " .. sprite.name)
            dprint("Image: " .. medalImagePath)
            if (file_exists(medalImagePath)) then
                if (file_exists(medalSoundPath)) then
                    dprint("Sound: " .. medalSoundPath)
                    harmonySprites[sprite.name] = optic.create_sprite(medalImagePath, sprite.width,
                                                                      sprite.height)
                    harmonySounds[sprite.name] = optic.create_sound(medalSoundPath)
                    sprites[event].hasAudio = true
                else
                    -- dprint("Warning, there is no sound for this sprite!")
                    harmonySprites[sprite.name] = optic.create_sprite(medalImagePath, sprite.width,
                                                                      sprite.height)
                end
            end
        end
    end

    for event, sound in pairs(sounds) do
        if (sound.name) then
            local soundPath = audio(sound.name)
            dprint("Loading sound: " .. sound.name)
            dprint("Sound: " .. soundPath)
            if (file_exists(soundPath)) then
                harmonySounds[sound.name] = optic.create_sound(soundPath)
            end
        end
    end

    -- Fade in animation
    local fadeInAnimation = optic.create_animation(300)
    optic.set_animation_property(fadeInAnimation, "ease in", "position x", defaultMedalSize)
    optic.set_animation_property(fadeInAnimation, "ease in", "opacity", 255)

    -- Fade out animation
    local fadeOutAnimation = optic.create_animation(400)
    optic.set_animation_property(fadeOutAnimation, "ease out", "opacity", -255)

    -- Slide animation
    local slideAnimation = optic.create_animation(250)
    optic.set_animation_property(slideAnimation, 0.4, 0.0, 0.6, 1.0, "position x", defaultMedalSize)

    hitmarkerEnterAnimation = optic.create_animation(0)

    -- Hitmarker kill fade animation
    hitmarkerFadeAnimation = optic.create_animation(80)
    optic.set_animation_property(hitmarkerFadeAnimation, "linear", "opacity", -255)
    


    -- Create sprites render queue
    renderQueue = optic.create_render_queue(50, (screenHeight / 2) - (defaultMedalSize / 2), 255, 0,
                                            4000, 0, fadeInAnimation, fadeOutAnimation,
                                            slideAnimation)

    -- Create audio engine instance
    if ActiveSound == true then
        AudioEngine = optic.create_audio_engine()
        harmony.optic.set_audio_engine_gain(AudioEngine, configuration.volume or 50)
    end
    
    medalsLoaded = true

    -- Load medals callback
    harmony.set_callback("multiplayer sound", "OnMultiplayerSound")
    harmony.set_callback("multiplayer event", "OnMultiplayerEvent")

    dprint("Medals loaded!")
end

--- Normalize any map name or snake case name to a name with sentence case
---@param name string
local function toSentenceCase(name)
    return string.gsub(" " .. name:gsub("_", " "), "%W%l", string.upper):sub(2)
end

---@param sprite sprite
local function medal(sprite)
    if (medalsLoaded) then
        medalsQueue[#medalsQueue + 1] = sprite.name
        local renderGroup = sprite.renderGroup
        local harmonySprite = harmonySprites[sprite.name]
        if harmonySprite then
            -- TODO Add render group discrimination
            if (renderGroup) then
                -- Crosshair sprite
                if sprite.name == "hitmarker" then
                    optic.render_sprite(harmonySprite, (screenWidth - sprites.hitmarkerHit.width) / 2,
                                    (screenHeight - sprites.hitmarkerHit.height) / 2, 255, 0, 200)
                else
                    optic.render_sprite(harmonySprite, (screenWidth - sprites.hitmarkerKill.width) / 2,
                                    (screenHeight - sprites.hitmarkerKill.height) / 2, 255, 0, 200, hitmarkerEnterAnimation, hitmarkerFadeAnimation)
                end
            else
                optic.render_sprite(harmonySprite, renderQueue)
                if (sprite.hasAudio) and ActiveSound == true then
                    local harmonyAudio = harmonySounds[sprite.name]
                    optic.play_sound(harmonyAudio, AudioEngine)
                end
            end
            if (configuration.hudMessages) then
                if (not sprite.name:find("hitmarker")) then
                    hud_message(toSentenceCase(sprite.name))
                end
            end
        end
    else
        console_out("Error, medals were not loaded properly!")
    end
end

local function sound(sound)
    if harmonySounds[sound.name] and ActiveSound == true then
        optic.play_sound(harmonySounds[sound.name], AudioEngine)
    else
        dprint("Warning, sound " .. sound.name .. " was not loaded!")
    end
end

function OnMultiplayerSound(soundEventName)
    dprint("sound: " .. soundEventName)
    if (soundEventName == soundsEvents.hitmarker) then
        if (configuration.hitmarker) then
            medal(sprites.hitmarkerHit)
        end
    end
    -- Cancel default sounds that are using medals sounds
    if (soundEventName:find("kill") or soundEventName:find("running")) then
        dprint("Cancelling sound...")
        return false
    end
    return true
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
            local allServerKills = 0
            for playerIndex = 0, 15 do
                local playerData = blam.player(get_player(playerIndex))
                if (playerData and playerData.index ~= localPlayer.index) then
                    allServerKills = allServerKills + playerData.kills
                end
            end
            dprint("All server kills: " .. allServerKills)
            if (allServerKills == 0 and localPlayer.kills == 1) then
                medal(sprites.firstStrike)
            end
            if (player.health <= 0.25) then
                medal(sprites.closeCall)
            end
            if (not isPreviousMedalKillVariation()) then
                medal(sprites.kill)
            end
            if (configuration.hitmarker) then
                medal(sprites.hitmarkerKill)
            end

            -- Bump up killing spree count
            if (localId == killerId) then
                playerData.killingSpreeCount = playerData.killingSpreeCount + 1

                -- Killing spree medals
                if (playerData.killingSpreeCount == 5) then
                    medal(sprites.killingSpree)
                elseif (playerData.killingSpreeCount == 10) then
                    medal(sprites.killingFrenzy)
                elseif (playerData.killingSpreeCount == 15) then
                    medal(sprites.runningRiot)
                elseif (playerData.killingSpreeCount == 20) then
                    medal(sprites.rampage)
                elseif (playerData.killingSpreeCount == 25) then
                    medal(sprites.untouchable)
                elseif (playerData.killingSpreeCount == 30) then
                    medal(sprites.invincible)
                elseif (playerData.killingSpreeCount == 35) then
                    medal(sprites.inconceivable)
                elseif (playerData.killingSpreeCount == 40) then
                    medal(sprites.unfriggenbelievable)
                end

                -- Comeback kill medal
                if (playerData.dyingSpreeCount <= -3) then
                    playerData.dyingSpreeCount = 0
                    medal(sprites.comebackKill)
                end

                -- Multikill medals
                if (playerData.multiKillTimestamp == nil) then
                    playerData.multiKillTimestamp = os.time()
                    playerData.multiKillCount = 1
                else
                    playerData.multiKillCount = playerData.multiKillCount + 1

                    -- Check if the 4.5 seconds have already elapsed
                    local time = os.time() - playerData.multiKillTimestamp
                    if (time < 4.5) then
                        if (playerData.multiKillCount == 2) then
                            medal(sprites.doubleKill)
                        elseif (playerData.multiKillCount == 3) then
                            medal(sprites.tripleKill)
                        elseif (playerData.multiKillCount == 4) then
                            medal(sprites.overkill)
                        elseif (playerData.multiKillCount == 5) then
                            medal(sprites.killtacular)
                        elseif (playerData.multiKillCount == 6) then
                            medal(sprites.killtrocity)
                        elseif (playerData.multiKillCount == 7) then
                            medal(sprites.killimanjaro)
                        elseif (playerData.multiKillCount == 8) then
                            medal(sprites.killtastrophe)
                        elseif (playerData.multiKillCount == 9) then
                            medal(sprites.killpocalypse)
                        elseif (playerData.multiKillCount == 10) then
                            medal(sprites.killionaire)
                        end
                    else
                        playerData.multiKillCount = 0
                        playerData.multiKillTimestamp = nil
                    end
                end
            end

            -- Count player dead
            if (localId == victimId) then
                playerData.killingSpreeCount = 0
                playerData.dyingSpreeCount = playerData.dyingSpreeCount - 1
                playerData.multiKillCount = 0
                playerData.multiKillTimestamp = nil
            end
        else
            dprint("Player is dead!")
            medal(sprites.fromTheGrave)
        end
    end

    -- CTF medals
    if (eventName == events.localCtfScore) then
        playerData.flagCaptures = playerData.flagCaptures + 1
        medal(sprites.flagCaptured)
        if (playerData.flagCaptures == 2) then
            medal(sprites.flagRunner)
        elseif (playerData.flagCaptures == 3) then
            medal(sprites.flagChampion)
        end
    end

    -- Suicide sound
    if (eventName == events.suicide and localId == victimId) then
        playerData.killingSpreeCount = 0
        playerData.dyingSpreeCount = playerData.dyingSpreeCount - 1
        sound(sounds.suicide)
    end

    -- Betrayal sound
    if (eventName == events.betrayed and localId == victimId) then
        sound(sounds.betrayal)
    end
end

function OnCommand(command)
    if (command == "optic_test" or command == "otest") then
        medal(sprites.firstStrike)
        medal(sprites.doubleKill)
        medal(sprites.tripleKill)
        medal(sprites.overkill)
        if (configuration.hitmarker) then
            medal(sprites.hitmarkerHit)
            medal(sprites.hitmarkerKill)
        end
        return false
    elseif (command == "optic_debug" or command == "odebug") then
        DebugMode = not DebugMode
        console_out("Debug Mode: " .. tostring(DebugMode))
        return false
    elseif (command == "optic_version" or command == "oversion") then
        console_out(opticVersion)
        return false
    elseif (command == "optic_reload" or command == "oreload") then
        loadOpticConfiguration()
        return false
    elseif (command:find "optic_style") then
        local params = glue.string.split(command, " ")
        local style = params[2]
        if (style and directory_exists(style)) then
            configuration.style = style
            console_out("Success, optic style loaded")
            saveOpticConfiguration()
            loadOpticConfiguration()
            return false
        end
        console_out("Error at loading optic style")
        return false
    elseif command:find "optic_volume" or command:find "ovolume" then
        local params = glue.string.split(command, " ")
        local volume = tonumber(params[2]) or 1
        configuration.volume = volume
        harmony.optic.set_audio_engine_gain(AudioEngine, configuration.volume)
        console_out("Optic volume set to " .. volume)
        saveOpticConfiguration()
        return false
    end
end

function OnMapLoad()
    loadOpticConfiguration()
    if (not medalsLoaded) then
        console_out("Error, medals were not loaded properly!")
    end

    -- Reset player state
    playerData = deepcopy(defaultPlayerData)
end

set_callback("command", "OnCommand")
set_callback("map load", "OnMapLoad")

OnScriptLoad()
