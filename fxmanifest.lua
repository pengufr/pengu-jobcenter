fx_version 'cerulean'
game 'gta5'

author 'pengu'
description 'Job Center Resource with Job Menu and NPC Interaction'
version '1.0.0'

lua54 'yes'

shared_script {
    'config.lua',
    '@ox_lib/init.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
    '@oxmysql/lib/MySQL.lua',
}

dependencies {
    'qb-core',
    'ox_lib',
    'qb-target',
    -- 'ox_target',  -- Uncomment if using ox_target
    -- 'qtarget'     -- Uncomment if using qtarget
}
