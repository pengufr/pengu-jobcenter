local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:UpdateObject', function()
	QBCore = exports['qb-core']:GetCoreObject()
end)

local function DebugPrint(message)
    if Config.Debug then
        print("[DEBUG] " .. message)
    end
end

local function ShowJobInformation(jobName, jobLabel, jobDescription, jobPay, jobRank)
    jobRank = jobRank or "Not Defined"
    local job = Config.Jobs[jobName] or {}

    local jobDetails = {
        {
            title = "Job Name: " .. jobLabel,
            description = "Description: " .. jobDescription
        },
        {
            title = "Rank: " .. jobRank,
            description = "Starting Rank For This Job"
        },
        {
            title = "Starting Pay: $" .. (jobPay or 0),
            description = "Your Starting Pay Until Promotion"
        },
        {
            title = "Apply for this job",
            event = 'pengu-jobcenter:client:applyJob',
            args = jobName
        }
    }

    if Config.Menu == 'ox_lib' then
        lib.registerContext({
            id = 'job_information_menu',
            title = 'Job Information',
            options = jobDetails,
            menu = 'job_center_menu'
        })
        lib.showContext('job_information_menu')
    elseif Config.Menu == 'qb-menu' then
        local qbJobDetails = {}
        for _, detail in ipairs(jobDetails) do
            table.insert(qbJobDetails, {
                header = detail.title,
                txt = detail.description,
                params = {
                    event = detail.event,
                    args = detail.args
                }
            })
        end
        exports['qb-menu']:closeMenu()
        exports['qb-menu']:openMenu(qbJobDetails)
    end
end

CreateThread(function()
    DebugPrint("Starting Job Center blip creation.")
    for _, location in pairs(Config.JobCenterLocations) do
        -- Ensure we're accessing the correct coordinates for the blip
        local blip = AddBlipForCoord(location.blip.coords)
        SetBlipSprite(blip, location.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, location.blip.scale)
        SetBlipColour(blip, location.blip.color)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(location.blip.name)
        EndTextCommandSetBlipName(blip)
    end

    DebugPrint("Blip(s) for Job Center created successfully.")
end)

local function SetupNPC(npcModel, location)
    DebugPrint("Setting up NPC: " .. npcModel)
    RequestModel(GetHashKey(npcModel))
    while not HasModelLoaded(GetHashKey(npcModel)) do
        DebugPrint("Waiting for NPC model to load.")
        Wait(10)
    end

    -- Access the coordinates from the first location in JobCenterLocations
    local npcPed = CreatePed(4, GetHashKey(npcModel), location.coords.x, location.coords.y, location.coords.z - 1, location.coords.w, false, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    TaskStartScenarioInPlace(npcPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
    DebugPrint("NPC created successfully at coordinates: " .. location.coords.x .. ", " .. location.coords.y .. ", " .. location.coords.z)
    return npcPed
end

local function SetupTargeting(npcPed)
    DebugPrint("Setting up targeting system for NPC.")
    local targetSystem = Config.Target

    if exports[targetSystem] then
        -- Always define targetFunc to avoid nil issues
        local targetFunc = function()
            DebugPrint("No valid targeting function defined.")
        end

        -- Adjust for different targeting systems
        if targetSystem == 'drawtext' then
            targetFunc = function()
                CreateThread(function()
                    while true do
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local npcCoords = Config.JobCenterLocations[1].coords  -- Accessing coords from the first location
                        local distance = #(playerCoords - vector3(npcCoords.x, npcCoords.y, npcCoords.z))

                        if distance < 2.5 then
                            DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z, "[E] Browse Jobs")
                            if IsControlJustReleased(0, 38) then
                                TriggerEvent('pengu-jobcenter:client:openMenu')
                            end
                        end
                        Wait(0)
                    end
                end)
            end
        else
            local options = {
                {
                    type = "client",
                    event = "pengu-jobcenter:client:openMenu",
                    icon = "fas fa-briefcase",
                    label = "Browse Jobs",
                }
            }
            exports[targetSystem]:AddTargetEntity(npcPed, { options = options, distance = 2.5 })
        end

        -- Now it's safe to call targetFunc
        targetFunc()
        DebugPrint("Targeting system set up successfully.")
    else
        DebugPrint("Targeting system not found: " .. targetSystem)
    end
end


CreateThread(function()
    DebugPrint("Initializing NPC and targeting system setup.")
    local npcPed = SetupNPC(Config.NPC.model, Config.JobCenterLocations[1])  -- Accessing the first job center location
    SetupTargeting(npcPed)
end)


local function GetJobRank(playerJob, jobName)
    if playerJob and jobName and Config.Jobs[jobName] then
        local jobGrades = Config.Jobs[jobName].grades
        local playerGrade = playerJob.grade or '0'
        local jobGradeInfo = jobGrades[tostring(playerGrade)]
        return jobGradeInfo and jobGradeInfo.name or "Unknown Rank"
    end
    return "Not Defined"
end

local function RegisterJobOptions(playerData)
    DebugPrint("Registering job options for player.")
    local jobOptions = {}
    local playerJob = playerData.job
    local playerJobName = playerJob.name

    if playerJobName and playerJobName ~= 'unemployed' then
        DebugPrint("Player is employed. Adding 'Toggle Duty' option.")
        table.insert(jobOptions, {
            title = "Toggle Duty",
            description = "Toggle your duty status.",
            icon = 'fas fa-user-clock',
            event = 'pengu-jobcenter:client:toggleDuty',
            args = {}
        })
        QBCore.Functions.Notify("You are currently employed. You can only toggle your duty status.", "info")
    else
        DebugPrint("Player is unemployed. Adding available job options.")
        for _, configJob in pairs(Config.Jobs) do
            local jobLabel = configJob.label
            local jobDescription = configJob.description
            local jobRank = "Not Defined"

            table.insert(jobOptions, {
                title = jobLabel,
                description = jobDescription,
                icon = configJob.icon or 'fas fa-briefcase',
                event = 'pengu-jobcenter:client:showJobInformation',
                args = {
                    name = configJob.name,
                    label = jobLabel,
                    description = jobDescription,
                    startingRank = jobRank
                }
            })
        end
    end

    table.insert(jobOptions, {
        title = 'Buy Misc Items',
        description = 'Purchase miscellaneous items like ID cards, licenses, etc.',
        icon = 'fas fa-shopping-cart',
        event = 'pengu-jobcenter:client:buyMiscItems',
    })

    if Config.Menu == 'ox_lib' then
        lib.registerContext({
            id = 'job_center_menu',
            title = 'Job Center',
            options = jobOptions,
            menu = 'main'
        })
        DebugPrint("Menu registered with job options.")
        lib.showContext('job_center_menu')
    elseif Config.Menu == 'qb-menu' then
        local qbJobOptions = {}
        for _, option in ipairs(jobOptions) do
            table.insert(qbJobOptions, {
                header = option.title,
                txt = option.description,
                params = {
                    event = option.event,
                    args = option.args
                }
            })
        end
        exports['qb-menu']:openMenu(qbJobOptions)
    end
end

RegisterNetEvent('pengu-jobcenter:client:buyMiscItems', function()
    DebugPrint("Opening miscellaneous items menu.")
    local miscItems = {}
    for itemName, itemData in pairs(Config.Misc) do
        table.insert(miscItems, {
            title = itemData.name,
            description = itemData.description,
            icon = 'fas fa-shopping-cart',
            event = 'pengu-jobcenter:client:confirmPurchase',
            args = itemName
        })
    end

    if Config.Menu == 'ox_lib' then
        lib.registerContext({
            id = 'misc_items_menu',
            title = 'Miscellaneous Items',
            options = miscItems,
            menu = 'main'
        })
        lib.showContext('misc_items_menu')
    elseif Config.Menu == 'qb-menu' then
        local qbMiscItems = {}
        for _, item in ipairs(miscItems) do
            table.insert(qbMiscItems, {
                header = item.title,
                txt = item.description,
                params = {
                    event = item.event,
                    args = item.args
                }
            })
        end
        exports['qb-menu']:openMenu(qbMiscItems)
    end
end)

RegisterNetEvent('pengu-jobcenter:client:openMenu', function()
    DebugPrint("Opening job center menu.")
    QBCore.Functions.GetPlayerData(RegisterJobOptions)
end)

RegisterNetEvent('pengu-jobcenter:client:showJobInformation', function(job)
    DebugPrint("Showing information for job: " .. job.name)
    local qbJob = Config.Jobs[job.name]
    if qbJob then
        ShowJobInformation(
            job.name,
            qbJob.label or job.label,
            qbJob.description or job.description,
            qbJob.grades['0'] and qbJob.grades['0'].payment,
            GetJobRank(QBCore.Functions.GetPlayerData(), job.name)
        )
    else
        QBCore.Functions.Notify("Job does not exist.", "error")
    end
end)

RegisterNetEvent('pengu-jobcenter:client:applyJob', function(jobName)
    DebugPrint("Applying for job: " .. tostring(jobName))

    if not jobName or type(jobName) ~= "string" or jobName == "" then
        DebugPrint("Invalid job name provided.")
        return QBCore.Functions.Notify("Invalid job name", "error")
    end

    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed, true)
    RequestAnimDict("missfam4")
    while not HasAnimDictLoaded("missfam4") do
        Wait(10)
    end
    TaskPlayAnim(playerPed, "missfam4", "base", 8.0, -8.0, -1, 49, 0, false, false, false)

    local job = Config.Jobs[jobName]
    if job then
        DebugPrint("Job exists. Triggering server event to apply job: " .. jobName)
        TriggerServerEvent('pengu-jobcenter:server:applyJob', jobName, 0)

        if Config.ProgressBar == 'ox_lib' then
            exports['ox_lib']:progressBar({
                duration = 9650,
                label = 'Applying for ' .. (job.label or 'Unknown Job'),
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true,
                    mouse = false,
                },
                anim = {
                    animDict = 'missfam4',
                    anim = 'base',
                },
                prop = {
                    model = 'prop_clipboard',
                    bone = 60309,
                    coords = vector3(0.0, 0.0, 0.0),
                    rotation = vector3(0.0, 0.0, 0.0),
                },
            })
        elseif Config.ProgressBar == 'progressbar' then
            exports['progressbar']:Progress({
                duration = 9650,
                label = 'Applying for ' .. (job.label or 'Unknown Job'),
                useWhileDead = false,
                canCancel = false,
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            })
        else
            DebugPrint("Invalid progress bar configuration.")
            QBCore.Functions.Notify("Invalid progress bar configuration.", "error")
        end

        Wait(9650) -- Wait for the duration of the progress bar

        -- Clear animation and unfreeze the player after the progress bar is done
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)
    else
        DebugPrint("Job does not exist: " .. jobName)
        QBCore.Functions.Notify("Job does not exist.", "error")

        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)
    end
end)



RegisterNetEvent('pengu-jobcenter:client:confirmPurchase', function(itemName)
    DebugPrint("Confirming purchase for item: " .. tostring(itemName))

    if not itemName or type(itemName) ~= "string" or itemName == "" then
        DebugPrint("Invalid item name provided.")
        return QBCore.Functions.Notify("Invalid item name", "error")
    end

    local itemData = Config.Misc[itemName]

    if itemData then
        DebugPrint("Item exists. Triggering server event to purchase item: " .. itemName)

        local playerPed = PlayerPedId()
        FreezeEntityPosition(playerPed, true)
        RequestAnimDict("missfam4")
        while not HasAnimDictLoaded("missfam4") do
            Wait(10)
        end

        TaskPlayAnim(playerPed, "missfam4", "base", 8.0, -8.0, -1, 49, 0, false, false, false)

        if Config.ProgressBar == 'ox_lib' then
            exports['ox_lib']:progressBar({
                duration = 2000,
                label = 'Purchasing ' .. (itemData.name or 'Unknown Item'),
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true,
                    mouse = false,
                },
                anim = {
                    animDict = 'missfam4',
                    anim = 'base',
                },
                prop = {
                    model = 'prop_clipboard',
                    bone = 60309,
                    coords = vector3(0.0, 0.0, 0.0),
                    rotation = vector3(0.0, 0.0, 0.0),
                },
            })
            Wait(2000) -- Wait for the duration of the progress
        elseif Config.ProgressBar == 'progressbar' then
            exports['progressbar']:Progress({
                duration = 2000,
                label = 'Purchasing ' .. (itemData.name or 'Unknown Item'),
                useWhileDead = false,
                canCancel = false,
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            })
            Wait(2000) -- Wait for the duration of the progress
        else
            DebugPrint("Invalid progress bar configuration.")
            QBCore.Functions.Notify("Invalid progress bar configuration.", "error")
        end

        -- Clear animation and unfreeze the player after the progress is done
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed, false)

        TriggerServerEvent('pengu-jobcenter:server:purchaseItem', itemName)
    else
        DebugPrint("Item does not exist: " .. itemName)
        QBCore.Functions.Notify("Item does not exist.", "error")
    end
end)

RegisterNetEvent('pengu-jobcenter:client:purchaseNotification', function(itemName)
    DebugPrint("Purchase successful for item: " .. itemName)
    QBCore.Functions.Notify("You have purchased a " .. itemName, "success")
end)

RegisterNetEvent('pengu-jobcenter:client:toggleDuty', function()
    DebugPrint("Toggling duty status.")
    TriggerServerEvent('pengu-jobcenter:server:toggleDuty')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    TriggerServerEvent('pengu-jobcenter:server:initPromotionCheck')
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    TriggerServerEvent('pengu-jobcenter:server:initPromotionCheck')
end)