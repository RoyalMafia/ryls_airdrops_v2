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
	spawnChance (REQUIRED) - The chance of the quality being selected

	printName (REQUIRED)   - The name displayed in the airdrop menu

	itemColour (REQUIRED)  - This is the colour for the quality used in the airdrop menu

	reqRank (OPTIONAL)     - If you want to have a quality that requires a certain rank. This only affects player called in drops
	You can either state a single rank or include multiple ranks in a table. e.g. "rank1" or { "rank1", "rank2" } 
]]--

ryl_airdrop_config.qualities = {
	["example_normal"] = {
		spawnChance = 44,
		printName   = "example normal",
		itemColour  = Color( 150, 150, 150 )
	},
	["example_vip"] = {
		spawnChance = 70,
		printName   = "example vip",
		itemColour  = Color( 240, 20, 20 ),
		reqRank     = { "vip1", "vip2" }
	}
}

--[[

	ITEM TABLE

	printName (REQUIRED)   - The name that is displayed on the UI

	itemEnt (OPTIONAL)     - The entity that will be spawned in 

	itemQuality (REQUIRED) - What quality category it falls under

	itemFunc (OPTIONAL)    - Called when spawning. Passes the entity and the player. Can be used for many things

]]--

ryl_airdrop_config.items = {
	["example_normal_ball"] = {
		printName   = "example 1",
		itemEnt     = "sent_ball",
		itemQuality = "example_normal",
	},
	["example_big_ball"] = {
		printName   = "example 2",
		itemEnt     = "sent_ball",
		itemQuality = "example_normal",
		itemFunc   = function( ply, ent ) ent:SetBallSize( 69 ) end
	},
	["example_player_health"] = {
		printName   = "example 3",
		itemQuality = "example_normal",
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
