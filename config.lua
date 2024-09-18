-- Configurations
Config = {
    Target = 'qb-target', -- Options: qb-target, ox_target, qtarget, drawtext
    Menu = 'inverse-oxlib', -- Options: qb-menu, ox_lib
    JobCenterLocation = vector4(-267.58, -959.16, 31.22, 211), -- Job center coordinates
    Debug = false, -- Enable debug messages
    NPC = {
        model = 'a_m_m_business_01',
        coords = vector4(-267.58, -959.16, 31.22, 211),
    },
    JobCenterBlip = {
        coords = vector3(-267.58, -959.16, 31.22),
        sprite = 402,
        color = 2,
        scale = 1.0,
        name = 'Job Center',
    },
    Jobs = {
        -- { name = 'builder', label = 'Builder', description = 'Builds Stuff', licenseItem = 'builder_license' },
        -- { name = 'garbage', label = 'Garbage Collector', description = 'Collects Garbage', licenseItem = 'garbage_license' },
    }
}