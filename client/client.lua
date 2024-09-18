local QBCore = exports['qb-core']:GetCoreObject()

local function DebugPrint(message)
    if Config.Debug then
        print("[DEBUG] " .. message)
    end
end

Citizen.CreateThread(function()
    DebugPrint("Starting Job Center blip creation.")
    local blip = AddBlipForCoord(Config.JobCenterBlip.coords)
    SetBlipSprite(blip, Config.JobCenterBlip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.JobCenterBlip.scale)
    SetBlipColour(blip, Config.JobCenterBlip.color)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.JobCenterBlip.name)
    EndTextCommandSetBlipName(blip)
    DebugPrint("Blip for Job Center created successfully.")
end)

local function SetupNPC(npcModel, jobCenterCoords)
    DebugPrint("Setting up NPC: " .. npcModel)
    RequestModel(GetHashKey(npcModel))
    while not HasModelLoaded(GetHashKey(npcModel)) do
        DebugPrint("Waiting for NPC model to load.")
        Wait(10)
    end

    local npcPed = CreatePed(4, GetHashKey(npcModel), jobCenterCoords.x, jobCenterCoords.y, jobCenterCoords.z + 1, jobCenterCoords.w, false, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    TaskStartScenarioInPlace(npcPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
    DebugPrint("NPC created successfully at coordinates: " .. jobCenterCoords.x .. ", " .. jobCenterCoords.y .. ", " .. jobCenterCoords.z)
    return npcPed
end

local function SetupTargeting(npcPed)
    DebugPrint("Setting up targeting system for NPC.")
    local targetSystem = Config.Target
    if exports[targetSystem] then
        local targetFunc = targetSystem == 'drawtext' and function()
            CreateThread(function()
                while true do
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local distance = #(playerCoords - Config.JobCenterLocation)

                    if distance < 2.5 then
                        DrawText3D(Config.JobCenterLocation.x, Config.JobCenterLocation.y, Config.JobCenterLocation.z, "[E] Browse Jobs")
                        if IsControlJustReleased(0, 38) then
                            TriggerEvent('inverse-jobcenter:client:openMenu')
                        end
                    end
                    Wait(0)
                end
            end)
        end or function()
            local options = {
                {
                    type = "client",
                    event = "inverse-jobcenter:client:openMenu",
                    icon = "fas fa-briefcase",
                    label = "Browse Jobs",
                }
            }
            exports[targetSystem]:AddTargetEntity(npcPed, { options = options, distance = 2.5 })
        end

        targetFunc()
        DebugPrint("Targeting system set up successfully.")
    else
        DebugPrint("Targeting system not found: " .. targetSystem)
    end
end

CreateThread(function()
    DebugPrint("Initializing NPC and targeting system setup.")
    local npcPed = SetupNPC(Config.NPC.model, Config.JobCenterLocation)
    SetupTargeting(npcPed)
end)

local function RegisterJobOptions(playerData)
    DebugPrint("Registering job options for player.")
    local jobOptions = {}
    local playerJob = playerData.job.name

    if playerJob and playerJob ~= 'unemployed' then
        DebugPrint("Player is employed. Adding 'Toggle Duty' option.")
        table.insert(jobOptions, {
            title = "Toggle Duty",
            description = "Toggle your duty status.",
            icon = 'fas fa-user-clock',
            event = 'inverse-jobcenter:client:toggleDuty'
        })
        QBCore.Functions.Notify("You are currently employed. You can only toggle your duty status.", "info")
    else
        DebugPrint("Player is unemployed. Adding available job options.")
        for _, job in pairs(Config.Jobs) do
            table.insert(jobOptions, {
                title = job.label,
                description = job.description,
                icon = job.icon or 'fas fa-briefcase',
                event = 'inverse-jobcenter:client:applyJob',
                args = job.name
            })
        end
    end

    table.insert(jobOptions, {
        title = "Toggle Duty",
        description = "Toggle your duty status.",
        icon = 'fas fa-user-clock',
        event = 'inverse-jobcenter:client:toggleDuty'
    })

    lib.registerContext({
        id = 'job_center_menu',
        title = 'Job Center',
        options = jobOptions,
        menu = 'main'
    })
    DebugPrint("Menu registered with job options.")
    lib.showContext('job_center_menu')
end

RegisterNetEvent('inverse-jobcenter:client:openMenu', function()
    DebugPrint("Opening job center menu.")
    QBCore.Functions.GetPlayerData(RegisterJobOptions)
end)

RegisterNetEvent('inverse-jobcenter:client:applyJob', function(jobName)
    DebugPrint("Applying for job: " .. tostring(jobName))
    if not jobName or type(jobName) ~= "string" or jobName == "" then
        DebugPrint("Invalid job name provided.")
        return QBCore.Functions.Notify("Invalid job name", "error")
    end

    local job = QBCore.Shared.Jobs[jobName]
    if job then
        DebugPrint("Job exists. Triggering server event to apply job: " .. jobName)
        TriggerServerEvent('inverse-jobcenter:server:applyJob', jobName, job.defaultGrade or 0)
    else
        DebugPrint("Job does not exist: " .. jobName)
        QBCore.Functions.Notify("Job does not exist.", "error")
    end
end)

RegisterNetEvent('inverse-jobcenter:client:toggleDuty', function()
    DebugPrint("Toggling duty status.")
    TriggerServerEvent('inverse-jobcenter:server:toggleDuty')
end)