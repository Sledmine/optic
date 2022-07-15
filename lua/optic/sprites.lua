local function sprites(size)
    return {
        -- Kill medals
        kill = {name = "normal_kill", width = size, height = size},
        rocketKill = {name = "rocket_kill", width = size, height = size},
        supercombine = {name = "needler_kill", width = size, height = size},

        -- Multikills
        doubleKill = {name = "double_kill", width = size, height = size},
        tripleKill = {name = "triple_kill", width = size, height = size},
        overkill = {name = "overkill", width = size, height = size},
        killtacular = {name = "killtacular", width = size, height = size},
        killtrocity = {name = "killtrocity", width = size, height = size},
        killamanjaro = {name = "killamanjaro", width = size, height = size},
        killtastrophe = {name = "killtastrophe", width = size, height = size},
        killpocalypse = {name = "killpocalypse", width = size, height = size},
        killionaire = {name = "killionaire", width = size, height = size},

        -- Killing sprees
        killingSpree = {name = "killing_spree", width = size, height = size},
        killingFrenzy = {name = "killing_frenzy", width = size, height = size},
        runningRiot = {name = "running_riot", width = size, height = size},
        rampage = {name = "rampage", width = size, height = size},
        untouchable = {name = "untouchable", width = size, height = size, alias = "nightmare"},
        invincible = {name = "invincible", width = size, height = size, alias = "boogeyman"},
        inconceivable = {name = "inconceivable", width = size, height = size, alias = "grim_reaper"},
        unfriggenbelievable = {
            name = "unfriggenbelievable",
            width = size,
            height = size,
            alias = "demon"
        },
        comebackKill = {name = "comeback_kill", width = size, height = size},

        -- Bonus
        firstStrike = {name = "first_strike", width = size, height = size},
        fromTheGrave = {name = "from_the_grave", width = size, height = size},
        closeCall = {name = "close_call", width = size, height = size},
        snapshot = {name = "snapshot", width = size, height = size},

        -- CTF
        flagCaptured = {name = "flag_captured", width = size, height = size},
        flagRunner = {name = "flag_runner", width = size, height = size},
        flagChampion = {name = "flag_champion", width = size, height = size},

        hitmarkerHit = {
            name = "hitmarker",
            width = size,
            height = size,
            renderGroup = "crosshair",
            noHudMessage = true
        },
        hitmarkerKill = {
            name = "hitmarker_kill",
            width = size,
            height = size,
            renderGroup = "crosshair",
            noHudMessage = true
        }
    }
end

return sprites
