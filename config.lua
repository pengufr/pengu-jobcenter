Config = {}

Config = {
    Target = 'qb-target',    -- Can be 'qb-target' or 'ox_target' or 'qtarget'
    Menu = 'ox_lib',         -- Can be 'ox_lib' or 'qb-menu'
    ProgressBar = 'ox_lib',  -- Can be 'ox_lib' or 'progressbar'
    PromotionTime = 12 * 60 * 60, -- 12 hours
    Debug = true,
    NPC = {
        model = 'a_m_m_business_01',
        coords = vector4(-267.58, -959.16, 31.22, 211),
    },
}
Config.Misc = {
    ["id_card"] = {
        name = "ID Card",
        description = "A valid identification card.",
        price = 100,
    },
    ["driver_license"] = {
        name = "Driver's License",
        description = "Official document allowing you to drive.",
        price = 100,
    },
    -- You can add more items here in the same format
}
Config.JobCenterLocations = {
    {
        coords = vector4(-267.58, -959.16, 31.22, 211),
        blip = {
            coords = vector3(-267.58, -959.16, 31.22),
            sprite = 402,
            color = 2,
            scale = 1.0,
            name = 'Job Center',
        },
    },
    -- You can add more job center locations here in the same format
}

Config.Jobs = {
    builder = {
        name = 'builder',
        label = 'Builder',
        description = 'A skilled worker who constructs buildings and other structures.',
        defaultDuty = false,
        offDutyPay = false,
        licenseItem = 'builder_license',
        grades = {
            ['0'] = { name = 'Recruit', payment = 200 },
            ['1'] = { name = 'Novice', payment = 250 },
            ['2'] = { name = 'Experienced', payment = 350 },
        },
    },
    -- You can add more jobs here in the same format
}
