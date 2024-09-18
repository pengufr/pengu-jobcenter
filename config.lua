Config = {
    Target = 'qb-target',                                      -- Options: qb-target, ox_target, qtarget, drawtext
    Menu = 'ox_lib',                                    -- Options: qb-menu, ox_lib
    JobCenterLocation = vector4(-267.58, -959.16, 31.22, 211), -- Job center coordinates
    Debug = true,                                              -- Enable debug messages
    NPC = {
        model = 'a_m_m_business_01',                         -- NPC model
        coords = vector4(-267.58, -959.16, 31.22, 211),    -- NPC coordinates
    },
    JobCenterBlip = {
        coords = vector3(-267.58, -959.16, 31.22),         -- Blip coordinates
        sprite = 402,                                      -- Blip sprite
        color = 2,                                       -- Blip color
        scale = 1.0,                                    -- Blip scale
        name = 'Job Center',                            -- Blip name
    },
    Jobs = { -- Add custom jobs here, make sure the licenseItem is in your qb-core/shared/items.lua and in your qb-inventory/config.lua
        {
            name = 'builder',
            label = 'Builder',
            description = 'Builds various structures and fixes buildings',
            licenseItem = 'builder_license'
        },
        -- {
        --     name = 'garbage',
        --     label = 'Garbage Collector',
        --     description = 'Responsible for city sanitation and garbage collection',
        --     licenseItem = 'garbage_license'
        -- },
        -- {
        --     name = 'police',
        --     label = 'Police Officer',
        --     description = 'Enforces the law and maintains public order',
        --     licenseItem = 'police_license'
        -- },
    }
}
