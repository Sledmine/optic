clua_version = 2.056

harmony = require "mods.harmony"

local optic = harmony.optic
local events = {localKilledPlayer = "local killed player"}

local currentStyle = "h4"
local imagesPath = "%s/images/%s.png"

local sprites = {
    ["local killed player"] = {"kill", 64, 64},
    ["killing spree"] = {"killing_spree", 64, 64},
    ["local running riot"] = {"running_riot", 64, 64},
    ["suicide"] = {nil, 64, 64},
    ["ting"] = {"hitmarker", 32, 32, "crosshair"}
}

local function image(medalName)
    return imagesPath:format(currentStyle, medalName)
end

function OnMapLoad()
    -- Create sprites
    for event, sprite in pairs(sprites) do
        local imageName = sprite[1]
        local width = sprite[2]
        local height = sprite[3]
        if (imageName) then
            optic.register_sprite(event, image(imageName), width, height)
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

    -- Add medals render group
    optic.create_group("medals", 50, 600, 255, 0, 4000, 0, "fade in", "fade out", "slide")
	console_out("Medals loaded!")
end

function OnMultiplayerSound(sound)
    console_out("sound: " .. sound)
    local sprite = sprites[sound]
    if (sprite) then
        local renderGroup = sprite[4]
        if (renderGroup) then
            -- Crosshair sprite
            local screen_width = read_word(0x637CF2)
            local screen_height = read_word(0x637CF0)
            optic.render_sprite(sound, (screen_width - 35) / 2, (screen_height - 35) / 2,
                                255, 0, 200)
			
        else
            optic.render_sprite("medals", sound)
        end
    end

    return true
end

function OnMultiplayerEvent(event, localId, killerId, victimId)
    console_out("event: " .. event)
    if (sprites[event]) then
        -- Kill sprite
        optic.render_sprite("medals", event)
    end
end

harmony.set_callback("multiplayer sound", "OnMultiplayerSound")
harmony.set_callback("multiplayer event", "OnMultiplayerEvent")
set_callback("map load", "OnMapLoad")
