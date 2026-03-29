# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/).

## [v0.2] - 2024-07-09
### Changes
- Improved autoprod:
- Multiple brothels should be assigned to different genders.
- Improved unpacking (if path was blocked).
- mproved handling of harvesting when the path was blocked.
- Lower priority of hospital if no one is injured.
- Implemented border stone function: Carry nearby material home.
- Fixed and improved detection of multiple different dig-sites.
- Improved priority of mushroom harvesting.
- Fixed handling of failure to pick up material.
- Fixed locking of assigned material.
- Improved searching for brothel: Check gender.
- Show additional icons to indicate current plan for spare-time.
- Gnomes now prefer living rooms ("homes") with higher quality.
- Gnomes won't go to the hospital if they are dying of old age.
- Added a newsticker for when a gnome can't find a path multiple times.

### Removed
- removed multiple bugfixes, because they were ported to BugFix mod:
- Fixed a bug where the barkeeper would get stuck when four orders are pending at the same time.
- Fixed a bug where the first position of bowlers would become unusable in certain situations.
- Fixed that other bowling guests can cheer or boo at the current bowler.
- Fixed a bug where gnomes could no longer use the disco and would leave immediately after arriving.
- Workaround for when the bowling alley is stuck because the gnome registered as current bowler has left somehow.
- Fixed a bug in the lava world where Fenris isn't found in his lair.

## [v0.1] - 2022-04-22
### Added
- Due to technical limitations, the new scheduler for work is a completely new implementation, independent of the original one. Therefore I can't give a list of changes - it is just different.
- Increased search range for a hospital from 40 units to 160 units.
- Reduced the late-game needs for quality and variety of spare-time activities: At high "civilization states" the gnome's requirements were impossible to satisfy, resulting in significant mood losses.
- Young gnomes should not become unsatisfied with the quality of baths/kitchens/beds/etc just because they had not yet the chance to visit those places.
- Completely changed the way gnomes judge the food variety (because the old method sucks).
- Changed the priorities for searching for spare-time activities (because the old method sucks).
- The barkeeper now starts their first task immediately after arriving, instead of idling around for ten seconds first.
- F9 now drops only material items if the gnome has at least one such item in inventory. Otherwise, everything is dropped (like before).
- Increased the range at which food items are considered to be in the kitchen from 7 to 10 (all three kitchens, but not the fire place).
- Fixed a bug where the barkeeper would get stuck when four orders are pending at the same time.
- Fixed a bug where the first position of bowlers would become unusable in certain situations.
- Fixed that other bowling guests can cheer or boo at the current bowler.
- Fixed that if many items are already on the ground, a gnome might fail to put down another item.
- Fixed what looks like a typo and should affect how gnomes decide they are done with their current spare-time activity.
- Reduced the mood loss from bad sleep quality (insufficient beds) by half. The same code was in here twice, so it seems this was not intentional (and thus I consider it a bug).
- Fixed a bug where gnomes could no longer use the disco and would leave immediately after arriving.
- Fixed a bug where the hospital would no longer work after a patient died.
- Workaround for when the bowling alley is stuck because the gnome registered as current bowler has left somehow.
- Partially fixed the animation at the hospital where the patient should lay in bed: Now they are laying, but hovering a bit above the bed ...
- Fixed a bug in the lava world where Fenris isn't found in his lair.


