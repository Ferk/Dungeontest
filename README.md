
Dungeontest
===========

This is a game built using the [Minetest engine](https://github.com/minetest/minetest/).

This game will generate an infinite underground dungeon maze based on a simple binary tree algorithm.

This means the whole underground is a dungeon, and exploring it is the only way to gather resources. Even though you will start up in the surface of the world (along the vegetation and stuff) You do not start up with any tools that would allow you to obtain a renewable source of food (other than what you find scattered in the wilderness), so you may have to enter the dungeon from the start.

The dungeon starts generating at y = -35 and the room next to 0,0 will show a ladder to the surface.

The ladders going up from the first level (the one closer to the surface) will spawn in the surface entrances that you can use to access the Dungeon. This is the only way to actually enter the Dungeon, since the walls are indestructible.

![Dungeon Entrance Screenshot](menu/background.png)


#### Guidelines

* What this game is not:

  * __It's not about mining__. Rarely will a block be "oddly breakable by hand" (only if it actually makes sense for a player to pick it up and use it). The main dungeon structure is compossed by reinforced blocks that no tool will break. Only when being under creative mode will this guideline be void.
  * __It's not about crafting__. The players only have a 2x2 grid for very basic crafting (repairs, combining items and so) and it's intended to stay like this (no workbenches). The idea is that exploration of the dungeon should be rewarded more. If there's an item you want, instead of crafting you would have to get it as loot from some enemy, find it randomly in chests on certain levels or discover the particular room that offers a way to obtain it. This means you won't be able to craft a pickaxe in the first place, so in a way this also reinforces the previous statement.

* What this game is:

  * __It's an experiment done for fun__. Currently it's a work in progress and it might be for a long time. I might not be afraid of breaking stuff from one version to another.
  * __It's meant to be extensible__. The idea is that it should be easy to add stuff for dungeon rooms: traps, chests, scrolls, mobs and decorations. Also anything that can have variations of it should be allowed to.
  * __It's meant to be easy to edit__. Entering in creative mode should give you access to more stuff than what normal creative mode allows you to. And some nodes may behave different when interacted with (for example: the spawners don't change state, the "bones" mod was extended so that a creative player can add their custom corpse with whatever stuff he wants inside of it, whereas a normal player can only take stuff out).
  * __It's meant to be Roguelike-like__. I will always try to draw elements from modern roguelike games, such as [Stone Soup Dungeon Crawl](https://crawl.develz.org/).


#### Dungeon-Making

The only thing needed to start adding content to the Dungeon is to turn on the "creative mode" checkbox when starting the game.

In creative mode everything is destructible and you will have all the nodes available in the inventory along with a special item given to creative-mode players: The Tome of DungeonMaking.

This book offers an interface when opened that allows you to load room presets and save them after you have edited the room. If you save the room with a different name, a new room preset will be created.

When you save a room preset everything that is in-between the outermost dungeon walls of the room will be saved (excluding those walls themselves). This gives you a volume of 15x14x15 blocks, which should be enough for most purposes. There's no support for bigger rooms at the moment (you could change the hardcoded default, but this will break previously saved rooms).

You can however make the rooms smaller simply by adding more layers of wall, which will get saved along the room schematic.

Saved rooms are stored in the  "[game/dungeontest/mods/dungeon_rooms/roomdata/](mods/dungeon_rooms/roomdata)", inside of a subdirectory corresponding to each of the possible room layouts that a room can have.

There will be a ".conf" file that stores some information for the room selection ([check here](mods/dungeon_rooms/roomdata/4/standard.conf) for an example) and at least an ".mts" file, but if there's additional per-node metadata required (like inventory of chests, etc) a ".meta" file might also be created.

I'm looking forward to you guys making cool rooms that you can share so that they can be included in the game by default! Just let me know and send me your files.

##### Room layouts

With the current algorithm, there are 4 possible layout types:

* Layout type 0 - Only one door, located in the positive X side

        ---#---
        |     |
        |     |
        |     |
        -------

* Layout type 1 - One door in the X and another in the -X coordinates

        ---#---
        |     |
        |     |
        |     |
        ---#---

* Layout type 2 - One door in the X and another in the -Z coordinates

        ---#---
        |     |
        #     |
        |     |
        -------

* Layout type 3 - One door in the X, another in -X and a third one in the -Z coordinates

        ---#---
        |     |
        #     |
        |     |
        ---#---

Every room in the dungeon is a rotation or permutation of any of these 4 layouts. There are no rooms with more than 3 doors.

However, in the random pool of roomdata there's a 4th set of schematics that are layout-agnostic. Every room generated has a possibility of being replaced by one of these generic schematics. This means they have to offer openings for all of the 4 doors, even if when they are used one or more of the openings won't have a door. These schematics are placed always with a random rotation.

##### Chat commands

In addition to the Tome of DungeonMaking, you can save and load the room by entering the following commands in the Minetest console (F10) or directly in the chat input box (T key):

    /save <NAME_OF_THE_ROOM_FILE>

    /load <NAME_OF_THE_ROOM_FILE>


There are some additional commands that you can use as well:

* ``/reset`` will re-generate the current room using the same parameters as the ones used during the generation of the room.

        /reset


* ``/rotate`` will rotate the room around the Y axis. This might be useful if you are creating a room that is designed only for a particular set of entrances.

 Note that rotating a room can result in the player getting stuck inside a wall, so I'd recomend having noclip enabled during such manipulation

        /rotate <number multiple of 90>

#### Compatibility

In theory this game would be compatible with most mods based on minetest_game,
however due to its particular nature many of them might be unsuitable for it
or, if they add features to the underground, they may bring havoc to the dungeon.

In general, all mods that add monsters and other creatures from the "mobs_redo"
mod should be compatible with Dungeontest, though you might have to adapt them to
register


#### License of source code

Copyright (C) 2015 Fernando Carmona Varo <ferkiwi@gmail.com>
See README file in each mod directory for information about other authors.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

#### License of media (textures and sounds)

Copyright (C) 2010-2015 Fernando Carmona Varo <ferkiwi@gmail.com>, celeron55, Perttu Ahola <celeron55@gmail.com>
See README.txt in each mod directory for information about other authors.

Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
http://creativecommons.org/licenses/by-sa/3.0/
