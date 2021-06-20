
<html>
    <p align="center">
        <img width="450px" src="img/optic-logo.png"/>
    </p>
    <h1 align="center">Optic <b>1.0.0</b></h1>
    <p align="center">
        Optic medals for Halo Custom Edition using Harmony
    </p>
    
</html>

# Description
This project is an effort to bring medals to Halo Custom Edition that are compatible with Chimera
1.0, but at the same time looking for a better and more flexible way to customize your own medals,
this repository aims to be the standard for medals released under the Mercury repository, but feel
free to contribute by pull requests or discussing on the
[Shadowmods Discord Server](https://discord.shadowmods.net).

This project is possible thanks to [Harmony](https://github.com/JerryBrick/harmony),
[Chimera](https://github.com/SnowyMouse/chimera),
[Mercury](https://github.com/Sledmine/Mercury) and [lua-blam](https://github.com/Sledmine/lua-blam).

# Downloading and Installation

Get it on [Mercury](https://github.com/Sledmine/Mercury) by using the following command:
```
mercury install optic
```

# Supported Medals
Right now the project is aiming to provide an acceptable quantity of medals from Halo 4 as an
standard for medals available to recreate on Halo Custom Edition.

- Kill
- Double Kill
- Triple Kill
- Killtacular
- Killing Spree
- Running Riot
- Snapshot (Beta)
- Rocket Kill
- Needler Kill
- Close Call

Also this project provides simple hitmaker support.

New medals will be added across time, be sure to follow us on our Discord server for every upcoming
release with new features, fixes and medals.

# FAQ
## Why there are not many medals as HAC2 had once a time?
This is an entire new project that uses Harmony as the core tool to render medals animations on the 
game, meaning that the engine or system to handle game actions to eventually convert them into 
medals, needed to be built from zero in order to create a better and flexible system than the
presented by HAC2, more and better medals will come later after different releases.

## Why some medals are not working on protected maps?
This optic project uses lua-blam as a tool to determine different events happening on the game,
if the map you are playing is "protected" lua-blam will have some problems at getting the required
information from the game memory resulting in some medalls not being able to be triggered.