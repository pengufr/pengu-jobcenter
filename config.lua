Config = {
    Target = 'qb-target',
    Menu = 'ox_lib',
    JobCenterLocation = vector4(-267.58, -959.16, 31.22, 211),
    Debug = true,
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
        {
            name = 'builder',
            label = 'Builder',
            description = 'Builds various structures and fixes buildings',
            licenseItem = 'builder_license'
        },
        -- Add more jobs as needed
    }
}
