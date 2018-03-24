# ryls airdrops v2
Airdrop addon created by ryl ( https://steamcommunity.com/id/royalxvi/ ) 

## What's new

There's a lot more content in this version than my last one and the code now is 20x better:
- Instead of using file writing it now uses SQL Databases for saving/loading positions
- Players now have the ability to call in an airdrop if they have the "airdrop grenade"
- Changed how the loot system works, now you can customise the item drop chances as well as adding new drop chances
- Called in drops can have "VIP" loot, in the config you can define if the item quality has a required rank ( This item quality is not included in normal drops )
- There is now a tool gun which easily allows you to add/remove airdrop positions as well as view the current ones at the same time
- Airdrops are now spawned in via a plane which flies over the map instead of just spawning in above the position
- Only one airdrop will spawn in at a time
- Airdrop crates themselves have a parachute which opens at a certain distance and then disappears
- Redone the old UI to make it look nicer and cleaner
- In the config you can set up "item functions" which is called when the user goes to spawn an item in through the airdrops menu. This allows you to either edit the entity that spawns in or not have an entity that spawns and just gives the player something ( Will explain later )
- Airdrops have a smoke particle system once they land on the floor to show where they are etc

## Info

This is an addon which creates 'airdrops' which contain items that are defined in the config and 
each item has a rarity defining how likely it is to be in the drop.

## Airdrop preview

![Inventory Example](https://i.gyazo.com/c6b71d7805b9b4cb8367765ff9e7e8a3.png)
![Airdrop ingame](https://i.gyazo.com/23eb5fe38e792aa8d23764472a61eeab.jpg)

<a href="http://www.youtube.com/watch?feature=player_embedded&v=ViOHIFm4WE8
" target="_blank">Youtube Airdrop Preview</a>

## Setting it up

All of the setup is done via the config which is located in `lua/autorun`.
In the config you can edit: Qualities, Items, Drop Rate, Drop Life, Ranks, Drop Radius

I have included some examples in the config

**Qualities**

"spawnChance" (REQUIRED)
> How the spawn chance system works has changed a fair amount. When selecting a quality it takes into account all of the spawn chances for every quality and adds them up this it to create the "max probability", so the chance of that quality being selected is "spawnChance" / "max probability" for example 44 / 235.

"printName" (REQUIRED)
> The name that will be shown in the airdrops UI for items of this quality

"itemCol" (REQUIRED)
> The colour of the item in the airdrops UI for items of this quality

"reqRank" (OPTIONAL)
> This setting only effects drops which are called in via players, when the airdrop is spawned in and it generates the loot for the drop
it will check the rank of the player that called it in and if they have the right rank then the quality with the required rank will have a chance of being selected. For normal drops all qualities with required ranks are removed from the selection table. NOTE: Other players can still loot these items.

**Items**

"printName" (REQUIRED)
> Name that is displayed for this item in the airdrops UI

"itemEnt" (OPTIONAL)
> If this is included it will be the entity that is to be spawned in

"itemQuality" (REQUIRED)
> The quality category that this item falls under

"itemFunc" (OPTIONAL)
> The function that is called when the item is spawned in, passes the player and entity. Allows you to modify either the entity or player. This is ran serverside

**Drop Rate**

This is how frequently the drops spawn in and is done in minutes (  Default 10mins )

**Drop Life**

This is how long the drop will stay spawned in for and is done in seconds ( Default 5mins )

**Drop Radius**

When the plane is spawned in it will be given a random "drop distance" between 50 units and whatever you set it to be in the config ( Default 300 )

**Ranks**

These are the ranks which are able to modify the drop positions as well as call in the airdrops via the chat command

## Chat Commands

Now there is only one chat command which is `!forcedrop` and only the users with the correct rank can use which is setup in the config.

## Tool Gun

How the current tool gun draws the positions is via 3D2D now this works fine on perfectly flat surfaces, however on uneven surfaces the circles can be clipped etc. I may change how the circles are drawn to prevent this from happening.

Only users with the correct rank can add/remove positions.
Fairly simple: left click add a position, right click removes position which the user is aiming at, & upon equipping will display all current drop positions.

## Known Bugs

- Very rare chance the plane won't spawn in the airdrop initially ( If this happens once the plane is about to despawn the airdrop will spawn at required position )
- Sometimes when equipping the tool gun the positions don't load ( Just have to requip )
- This was an old bug but not sure if still exists: Rare chance that the drop would spawn with only 4 items instead of 5

If you find any other bugs please comment on my profile with the bug / error info etc or create an issue on here.

## Note

This addon includes models, materials, & sounds from other workshop addons, If you are the creator of this content please contact me on Steam if you don't want them to be used in this addon.
- Plane Models, Materials, & Sound: Dr. Matt ( http://steamcommunity.com/id/mattjeanes ) http://steamcommunity.com/sharedfiles/filedetails/?id=128559085
- Parachute Model & Materials: Reverend V92 ( http://steamcommunity.com/id/JesseVanover ) http://steamcommunity.com/sharedfiles/filedetails/?id=895159273

