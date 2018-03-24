--[[

	VARIABLES

]]--

local isMenuOpen = false

--[[

	DERMA

]]--


--[[

	FUNCTIONS

]]--

local function openLogMenu( logTable )
	if isMenuOpen then return end
	isMenuOpen = true

	
end

--[[

	NET MESSAGES

]]--

net.Receive( "ryl_airdrop_logs_request", function()
	openLogMenu( net.ReadTable() )
end )