# RevisedPlanner for Diggles
This mod changes the behavior of the Diggles: Both the assignments during work and the activities during spare time are greatly revised. 
While I was at it, I also fixed some bugs. And added new bugs.
## work-time assignments
Due to technical limitations, the new scheduler for work is a completely new implementation, independent of the original one. Therefore 
I can't give a list of changes - it is just different.
## spare-time activities
- Increased search range for a hospital from 40 units to 160 units.
- Reduced the late-game needs for quality and variety of spare-time activities: At high "civilization states" the gnome's requirements were impossible to satisfy, resulting in significant mood losses.
- Young gnomes should not become unsatisfied with the quality of baths/kitchens/beds/etc just because they had not yet the chance to visit those places.
- Completely changed the way gnomes judge the food variety (because the old method sucks).
- Changed the priorities for searching for spare-time activities (because the old method sucks).
## miscellaneous tweaks
- The barkeeper now starts their first task immediately after arriving, instead of idling around for ten seconds first.
- F9 now drops only *material* items if the gnome has at least one such item in inventory. Otherwise, *everything* is dropped (like before).
- Increased the range at which food items are considered to be *in* the kitchen from 7 to 10 (all three kitchens, but not the fire place).
## bugfixes
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
## known bugs
- Production sites no longer show when a gnome is working (the small green progress indicator is missing). I have no clue how to fix this.
## unknown bugs
- This mod was developed on the original CD version of the game from 2001, no idea if it works on the re-release on GoG/Steam.
- Generally very little tested at all.

# Interactions with other mods or no mods at all
## Using this mod on an unmodded savegame
This should work in theory, though it is little tested. The moment of transition could have some unwanted effects, e.g. gnomes that were busy
collecting stuff for production may not deliver but keep the items in their inventory.
## Removing this mod and continuing a savegame without it
This will not work directly, the game will crash when loading the savegame. I have a fix to rectify this, in form of an "intermediate" mod, 
but it is currently nowhere publicly available. Also, the moment of transition will cause problems, such as two gnomes trying to work at
the same place, idle gnomes not working at all for a while (until manually moved around), and maybe other issues.
## Combination with other mods
Untested, but I expect this to fail for a lot of other mods, since this mod has a lot of changes so that the probability of a conflict is high.
