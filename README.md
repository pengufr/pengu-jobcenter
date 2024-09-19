## Pengu Job Center Script For Your QBCore Server!

## Dependency
* [qb-core](https://github.com/qbcore-framework/qb-core)
* [ox_lib](https://github.com/overextended/ox_lib)
* [qb-target](https://github.com/qbcore-framework/qb-target)
* [qb-menu](https://github.com/qbcore-framework/qb-menu)

## Optional Dependency (fxmanifest.lua)
* [ox_target](https://github.com/overextended/ox_target)
* [qtarget](https://github.com/overextended/qtarget/releases)

## Preview
* [Preview](Soon)

## Job Center Features
* Job Application: Players can apply for various jobs.
* Job License Management: Automatically grants job licenses upon job acceptance.
* Duty Toggle: Players can toggle their duty status on/off.
* Job Information: When you select a you can see the job name, job starting rank, and the starting pay sallary.
* Job Rank Up System: When you are on the job for a certain amount of hours (Configurable) you will get promoted wich will increase your pay + rank.

## Installation Guide | Version 1.0.0

## 1: Instert the SQL located in sql/jobcenter.sql

## 2: In your qb-core/shared/items.lua add the following code:

```lua 
    ['license_name']                   = { ['name'] = 'license_name', ['label'] = 'License Name', ['weight'] = 50, ['type'] = 'item', ['image'] = 'license_name.png', ['unique'] = true, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Official license_name License' },
```

## 3: In your qb-inventory/config.lua add the following code:

```lua -- pengu-jobcenter Licenses
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
```

## ANY QUESTIONS OR ISSUES? DM ME ON DISCORD - (pengufr)
