Config = {}

Config = {
    Target = 'qb-target', -- Can be 'qb-target' or 'ox_target'
    Menu = 'ox_lib', -- Can be 'ox_lib' or 'qb-menu'
    ProgressBar = 'ox_lib', -- Can be 'ox_lib' or 'qb-progress'
    JobCenterLocation = vector4(-267.58, -959.16, 31.22, 211),
    PaymentTime = 10000, -- Time in milliseconds for job payment
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
}
Config.Jobs = {
    builder = {
        name = 'builder',
        label = 'Builder',
        description = 'Builds, fixes, and constructs structures.',
        licenseItem = 'builder_license',
        grades = {
            ['0'] = { name = 'Recruit', payment = 200 },
            ['1'] = { name = 'Novice', payment = 250 },
            ['2'] = { name = 'Experienced', payment = 350 },
        },
    },
    -- Add more jobs here in the same format
}

