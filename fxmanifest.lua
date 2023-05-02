fx_version 'cerulean'

game 'gta5'

author 'ardo'

description 'NPC MDler'

version '1.0.0'

shared_script '@es_extended/imports.lua'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

dependencies {
	'b-notify',
	'robberies_creator',
	'es_extended'
}