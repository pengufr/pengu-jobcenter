Job Center Script for QBCore - BY: Pengu
This script is a Multi-Functional and Highly configurable script for your QBCore server!

Features
Job Application: Players can apply for various jobs.
Job License Management: Automatically grants job licenses upon job acceptance.
Duty Toggle: Players can toggle their duty status.
Job Information: When you select a you can see the job name, job starting rank, and the starting pay sallary
Job Rank Up System: When you are on the job for 12+ hours you will get promoted wich will increase your pay + rank

And much more!

Installation Guide

In your qb-core/shared/items.lua add the following code:

['license_name']                   = { ['name'] = 'pdbadge', ['label'] = 'License Name', ['weight'] = 50, ['type'] = 'item', ['image'] = 'license_name.png', ['unique'] = true, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Official license_name License' },

In your qb-inventory/config.lua add the following code:

-- pengu-jobcenter Licenses
        ["license_name"] = {
            ["name"] = "license_name",
            ["label"] = "License Name",
            ["weight"] = 50,
            ["type"] = "item",
            ["image"] = "license_name.png",
            ["unique"] = true,
            ["useable"] = false,
            ["shouldClose"] = true,
            ["combinable"] = nil,
            ["description"] = "Official license_name License"
        },

Replace all 'license_name' with your custom licenses set in the config

1. Check Dependencies located in the fxmanifest.lua

2. Configure the script 
    - Edit the config.lua file in the pengu-jobcenter folder to customize the job center settings, including job definitions, NPC configurations, 
    and license names
    - Make sure your license items in the config.lua are added and located in the qb-core/shared/items.lua and in your qb-inventory/config.lua
    - Make sure the jobs you add in the config.lua are added in the qb-core/shared/jobs.lua 

3. Add 'ensure pengu-jobcenter' to your server.cfg

4. Start your server, ENJOY!

ANY QUESTIONS OR ISSUES? DM ME ON DISCORD - (pengufr)
