Config = {
    Target = 'qb-target',                                      -- Target script to use for job center
    Menu = 'ox_lib',                                           -- Menu to use for job center
    JobCenterLocation = vector4(-267.58, -959.16, 31.22, 211), -- Job Center Location
    PromoteTime = 12 * 60,                                     -- 12 Hours (Change to anything you want) 12 * 60 = 12 hours
    Debug = true,                                              -- Set to false to disable debug messages
    NPC = {
        model = 'a_m_m_business_01',                           -- Model for the NPC
        coords = vector4(-267.58, -959.16, 31.22, 211),        -- Coords for the NPC
    },
    JobCenterBlip = {
        coords = vector3(-267.58, -959.16, 31.22), -- Coords for the Job Center Blip
        sprite = 402,                              -- Blip Sprite
        color = 2,                                 -- Blip Color
        scale = 1.0,                               -- Blip Scale
        name = 'Job Center',                       -- Blip Name
    },
    Jobs = {
        {
            name = 'builder',                                         -- Job Name
            label = 'Builder',                                        -- Job Label
            description = 'Builds, fixes and constructs structures.', -- Job Description
            licenseItem = 'builder_license'                           -- License Item
        },
        -- Add more jobs as needed (EXAMPLE)
        -- {
        --     name = 'jobname',
        --     label = 'Job Label',
        --     description = 'Job Description',
        --     licenseItem = 'license_item'
        -- },
    }
}
