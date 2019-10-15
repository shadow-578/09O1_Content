local function AddPlayerModel( name, model )

	list.Set( "PlayerOptionsModel", name, model )
	player_manager.AddValidModel( name, model )
	
end

list.Set( "PlayerOptionsModel", "SpongeBob", "models/sbplayer/sb.mdl" )
player_manager.AddValidModel( "SpongeBob", "models/sbplayer/sb.mdl" )

list.Set( "PlayerOptionsModel", "Patrick", "models/sbplayer/pat.mdl" )
player_manager.AddValidModel( "Patrick", "models/sbplayer/pat.mdl" )

list.Set( "PlayerOptionsModel", "Squidward", "models/sbplayer/squid.mdl" )
player_manager.AddValidModel( "Squidward", "models/sbplayer/squid.mdl" )

list.Set( "PlayerOptionsModel", "Sandy", "models/sbplayer/sandy.mdl" )
player_manager.AddValidModel( "Sandy", "models/sbplayer/sandy.mdl" )

list.Set( "PlayerOptionsModel", "Mr. Krabs", "models/sbplayer/mrkrabs.mdl" )
player_manager.AddValidModel( "Mr. Krabs", "models/sbplayer/mrkrabs.mdl" )

list.Set( "PlayerOptionsModel", "Plankton", "models/sbplayer/plankton.mdl" )
player_manager.AddValidModel( "Plankton", "models/sbplayer/plankton.mdl" )