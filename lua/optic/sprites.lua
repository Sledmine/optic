local function sprites(defaultMedalSize)
    return {
        -- Kill medals
        kill = {name = "normal_kill", width = defaultMedalSize, height = defaultMedalSize},
        rocketKill = {name = "rocket_kill", width = defaultMedalSize, height = defaultMedalSize},
        supercombine = {name = "needler_kill", width = defaultMedalSize, height = defaultMedalSize},
    
        -- Multikills
        doubleKill = {name = "double_kill", width = defaultMedalSize, height = defaultMedalSize},
        tripleKill = {name = "triple_kill", width = defaultMedalSize, height = defaultMedalSize},
        overkill = {name = "overkill", width = defaultMedalSize, height = defaultMedalSize},
        killtacular = {name = "killtacular", width = defaultMedalSize, height = defaultMedalSize},
        killtrocity = {name = "killtrocity", width = defaultMedalSize, height = defaultMedalSize},
        killaminjaro = {name = "killaminjaro", width = defaultMedalSize, height = defaultMedalSize},
        killtastrophe = {name = "killtastrophe", width = defaultMedalSize, height = defaultMedalSize},
        killpocalypse = {name = "killpocalypse", width = defaultMedalSize, height = defaultMedalSize},
        killionaire = {name = "killionaire", width = defaultMedalSize, height = defaultMedalSize},
        
        -- Killing sprees
        killingSpree = {name = "killing_spree", width = defaultMedalSize, height = defaultMedalSize},
        killingFrenzy = {name = "killing_frenzy", width = defaultMedalSize, height = defaultMedalSize},
        runningRiot = {name = "running_riot", width = defaultMedalSize, height = defaultMedalSize},
        rampage = {name = "rampage", width = defaultMedalSize, height = defaultMedalSize},
        untouchable = {name = "untouchable", width = defaultMedalSize, height = defaultMedalSize},
        invincible = {name = "invincible", width = defaultMedalSize, height = defaultMedalSize},
        inconceivable = {name = "inconceivable", width = defaultMedalSize, height = defaultMedalSize},
        unfriggenbelievable = {name = "unfriggenbelievable", width = defaultMedalSize, height = defaultMedalSize},
        comebackKill = {name = "comeback_kill", width = defaultMedalSize, height = defaultMedalSize},
    
        --Bonus
        firstStrike = {name = "first_strike", width = defaultMedalSize, height = defaultMedalSize},
        fromTheGrave = {name = "from_the_grave", width = defaultMedalSize, height = defaultMedalSize},
        closeCall = {name = "close_call", width = defaultMedalSize, height = defaultMedalSize},
        snapshot = {name = "snapshot_kill", width = defaultMedalSize, height = defaultMedalSize},
    
        -- CTF
        flagCapture = {name = "flag_capture", width = defaultMedalSize, height = defaultMedalSize},
        flagRunner = {name = "flag_runner", width = defaultMedalSize, height = defaultMedalSize},
        flagChampion = {name = "flag_champion", width = defaultMedalSize, height = defaultMedalSize},
    
        hitmarkerHit = {
            name = "hitmarker",
            width = defaultMedalSize,
            height = defaultMedalSize,
            renderGroup = "crosshair",
            noHudMessage = true
        },
        hitmarkerKill = {
            name = "hitmarker_kill",
            width = defaultMedalSize,
            height = defaultMedalSize,
            renderGroup = "crosshair",
            noHudMessage = true
        }
    }
end

return sprites