# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.2] - 2022-08-28
### Fixed
- Unlimited kill streaks bug
- Configuration properties being missed on newer releases

## [3.0.1] - 2022-07-15
### Added
- Flag to enable or disable optic sounds (helps preventing crashing on some systems in the meantime)

## [3.0.0] - 2022-07-15
### Added
- Commands `optic_style <style>` and `optic_volume <volume>`
- New medals for Halo 4 and Halo Infinite styles

### Changed
- Latest Harmony API (allows Optic to work again with other mods installed)
- Normalized audio volume across styles

### Fixed
- Some issues with kill streak stacking

## [2.0.0] - 2021-12-18
### Added
- Sounds for medals
- Configuration file to toggle optic features, select favorite optic style, etc
- Halo Infinite medals and sounds (WIP)
- Sound to suicide event

## [1.1.3]
### Fixed
- Bug where some multiplayer stock sounds were not playing

## [1.1.2]
### Changed
- Harmony dependency to 2.0.0 to prevent crashes and new API compatibility

## [1.1.1]
### Added
- Files to prepare an upcoming medals audio feature

### Changed
- Medals are now printing medal names to the HUD when rendered

### Fixed
- Potential crash at reloading scripts on old harmony versions < harmony-0.1.0

## [1.1.0]
### Added
- New first strike medal

### Fixed
- Medals scale and positioning issues on different resolutions

## [1.0.0]
### Added
- Initial release