--[[---------------------------------------------------
		
  /$$$$$$                       /$$$$$$  /$$          
 /$$__  $$                     /$$__  $$|__/          
| $$  \__/  /$$$$$$  /$$$$$$$ | $$  \__/ /$$  /$$$$$$ 
| $$       /$$__  $$| $$__  $$| $$$$    | $$ /$$__  $$
| $$      | $$  \ $$| $$  \ $$| $$_/    | $$| $$  \ $$
| $$    $$| $$  | $$| $$  | $$| $$      | $$| $$  | $$
|  $$$$$$/|  $$$$$$/| $$  | $$| $$      | $$|  $$$$$$$
 \______/  \______/ |__/  |__/|__/      |__/ \____  $$
                                             /$$  \ $$
                                            |  $$$$$$/
                                             \______/ 
--]]---------------------------------------------------

--[[

	MAIN TABLE

]]--

ryl_airdrop_config = {}

--[[

	QUALITY TABLE
	Edits the qualities and the spawn chance for them.

	itemColour - This is the colour for the quality used in the UI

	reqRank    - If you want to have a quality that requires a certain rank. This only affects player called in drops
	You can either state a single rank or include multiple ranks in a table. e.g. "rank1" or { "rank1", "rank2" } 
]]--

ryl_airdrop_config.qualities = {
	["common"] = {
		spawnChance = 44,
		printName   = "Common",
		itemColour  = Color( 150, 150, 150 )
	},
	["uncommon"] = {
		spawnChance = 30,
		printName   = "Uncommon",
		itemColour  = Color( 100, 255, 100 )
	},
	["unusual"] = {
		spawnChance = 15,
		printName   = "Unusual",
		itemColour  = Color( 100, 100, 255 )
	},
	["rare"] = {
		spawnChance = 7,
		printName   = "Rare",
		itemColour  = Color( 128, 0, 128 )
	},
	["ultrarare"] = {
		spawnChance = 3,
		printName   = "Ultra Rare",
		itemColour  = Color( 255, 100, 100 )
    },
    ["premium"] = {
    	spawnChance = 0.2,
    	printName   = "PREMIUM",
    	itemColour  = Color( 255, 153, 0 )
	}
}

--[[

	ITEM TABLE

	printName (REQUIRED)   - The name that is displayed on the UI

	itemEnt (OPTIONAL)     - The entity that will be spawned in 

	itemQuality (REQUIRED) - What quality category it falls under

	itemFunc (OPTIONAL)   - Called when spawning. Passes the entity and the player. Can be used for many things

]]--

ryl_airdrop_config.items = {
	["airdrop_grenade"] = {
		printName   = "Aidrop grenade",
		itemEnt     = "weapons_airdrop_smokegrenade",
		itemQuality = "premium"
	},
	["test1"] = {
		printName   = "test1",
		itemEnt     = "sent_ball",
		itemQuality = "premium",
	},
	["test2"] = {
		printName   = "test2",
		itemEnt     = "sent_ball",
		itemQuality = "premium" 
	},
	["test3"] = {
		printName   = "test3",
		itemEnt     = "sent_ball",
		itemQuality = "ultrarare"
	},
	["test4"] = {
		printName   = "test4",
		itemEnt     = "sent_ball",
		itemQuality = "ultrarare"
	},
	["test5"] = {
		printName   = "test5",
		itemEnt     = "sent_ball",
		itemQuality = "rare"
	},
	["test6"] = {
		printName   = "test6",
		itemEnt     = "sent_ball",
		itemQuality = "rare"
	},
	["test7"] = {
		printName   = "test7",
		itemEnt     = "sent_ball",
		itemQuality = "unusual"
	},
	["test8"] = {
		printName   = "test8",
		itemEnt     = "sent_ball",
		itemQuality = "unusual"
	},
	["test9"] = {
		printName   = "test9",
		itemEnt     = "sent_ball",
		itemQuality = "uncommon"
	},
	["test10"] = {
		printName   = "test10",
		itemEnt     = "sent_ball",
		itemQuality = "uncommon"
	},
	["test11"] = {
		printName   = "test11",
		itemEnt     = "sent_ball",
		itemQuality = "common",
		itemFunc   = function( ply, ent ) ent:SetBallSize( 69 ) end
	},
	["test12"] = {
		printName   = "test12",
		itemEnt     = "sent_ball",
		itemQuality = "common"
	},
	["plyhealth"] = {
		printName   = "1000HP",
		itemQuality = "common",
		itemFunc    = function( ply, ent ) ply:SetHealth( ply:Health() + 1000 ) end
	}
}

--[[

	VARIABLES

]]--

-- This is how frequent the drops are done in minutes
ryl_airdrop_config.dropRate = 10

-- Airdrop life time 
ryl_airdrop_config.dropLife = 300

-- The ranks which can add / remove drop positions
ryl_airdrop_config.ranks = { "superadmin", "owner" }

-- The radius of the drops
ryl_airdrop_config.dropRadius = 300