fx_version 'cerulean'
game 'gta5'

author 'pengu'
description 'Job Center Resource with Job Menu and NPC Interaction'
version '1.0.0'

lua54 'yes'  -- Enable Lua 5.4

-- Shared configuration and library initialization
shared_script {
    'config.lua',           -- Shared configuration file
    '@ox_lib/init.lua'     -- Initialize ox_lib if using ox_lib for menus
}

-- Client-side scripts
client_scripts {
    'config.lua',          -- Configuration file for client
    'client/client.lua',   -- Main client script
}

-- Server-side scripts
server_scripts {
    'server/server.lua',   -- Main server script
}

-- Dependencies for the resource
dependencies {
    'qb-core',    -- Essential for QBCore functionalities
    'ox_lib',     -- For menu handling (if using ox_lib)
    'qb-target',  -- For qb-target functionalities (if used)
    'qb-menu',    -- For qb-menu functionalities (if used)
    -- 'ox_target',  -- Uncomment if using ox_target
    -- 'qtarget'     -- Uncomment if using qtarget
}
