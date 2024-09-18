local QBCore = exports['qb-core']:GetCoreObject()

local function DebugPrint(message)
    if Config.Debug then
        print("[DEBUG] " .. message)
    end
end

local function CreateBlip()
    local blip = AddBlipForCoord(Config.JobCenterLocation.x, Config.JobCenterLocation.y, Config.JobCenterLocation.z)
    SetBlipSprite(blip, Config.JobCenterBlip.sprite)
    SetBlipColour(blip, Config.JobCenterBlip.color)
    SetBlipScale(blip, Config.JobCenterBlip.scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.JobCenterBlip.name)
    EndTextCommandSetBlipName(blip)
end

local function SetupNPC(npcModel, jobCenterCoords)
    RequestModel(GetHashKey(npcModel))
    while not HasModelLoaded(GetHashKey(npcModel)) do
        Wait(10)
    end

    local npcPed = CreatePed(4, GetHashKey(npcModel), jobCenterCoords.x, jobCenterCoords.y, jobCenterCoords.z + 1, jobCenterCoords.w, false, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    TaskStartScenarioInPlace(npcPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
    return npcPed
end

local function SetupTargeting(npcPed)
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
    end
end

CreateThread(function()
    CreateBlip()
    local npcPed = SetupNPC(Config.NPC.model, Config.JobCenterLocation)
    SetupTargeting(npcPed)
end)

local function RegisterJobOptions(playerData)
    local jobOptions = {}
    local playerJob = playerData.job.name

    if playerJob and playerJob ~= 'unemployed' then
        table.insert(jobOptions, {
            title = "Toggle Duty",
            description = "Toggle your duty status.",
            icon = 'fas fa-user-clock',
            event = 'inverse-jobcenter:client:toggleDuty'
        })
        QBCore.Functions.Notify("You are currently employed. You can only toggle your duty status.", "info")
    else
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
    DebugPrint("Menu registered with options.")
    lib.showContext('job_center_menu')
end

RegisterNetEvent('inverse-jobcenter:client:openMenu', function()
    QBCore.Functions.GetPlayerData(RegisterJobOptions)
end)

RegisterNetEvent('inverse-jobcenter:client:applyJob', function(jobName)
    if not jobName or type(jobName) ~= "string" or jobName == "" then
        return QBCore.Functions.Notify("Invalid job name", "error")
    end

    local job = QBCore.Shared.Jobs[jobName]
    if job then
        TriggerServerEvent('inverse-jobcenter:server:applyJob', jobName, job.defaultGrade or 0)  
    else
        QBCore.Functions.Notify("Job does not exist.", "error")
    end
end)

RegisterNetEvent('inverse-jobcenter:client:toggleDuty', function()
    TriggerServerEvent('inverse-jobcenter:server:toggleDuty')
end)
