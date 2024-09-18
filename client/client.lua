local QBCore = exports['qb-core']:GetCoreObject()

local function DebugPrint(message)
    if Config.Debug then
        print("[DEBUG] " .. message)
    end
end

local function ShowJobInformation(jobName, jobLabel, jobDescription, jobPay, jobRank)
    jobRank = jobRank or "Not Defined" 
    local jobDetails = {
        {
            title = "Job Name: " .. jobLabel,
            description = "Description: " .. jobDescription
        },
        {
            title = "Rank: " .. jobRank,
            description = "Current rank for this job."
        },
        {
            title = "Starting Pay: $" .. jobPay,
            description = "Your Starting Pay Until Promotion"
        },
        {
            title = "Apply for this job",
            event = 'inverse-jobcenter:client:applyJob',
            args = jobName
        }
    }

    lib.registerContext({
        id = 'job_information_menu',
        title = 'Job Information',
        options = jobDetails,
        menu = 'job_center_menu'
    })
    lib.showContext('job_information_menu')
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

    local npcPed = CreatePed(4, GetHashKey(npcModel), jobCenterCoords.x, jobCenterCoords.y, jobCenterCoords.z - 1,
        jobCenterCoords.w, false, true)
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    TaskStartScenarioInPlace(npcPed, "WORLD_HUMAN_CLIPBOARD", 0, true)
    DebugPrint("NPC created successfully at coordinates: " ..
    jobCenterCoords.x .. ", " .. jobCenterCoords.y .. ", " .. jobCenterCoords.z)
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
                        DrawText3D(Config.JobCenterLocation.x, Config.JobCenterLocation.y, Config.JobCenterLocation.z,
                            "[E] Browse Jobs")
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

local function GetJobRank(playerJob, jobName)
    if playerJob and jobName and QBCore.Shared.Jobs[jobName] then
        local jobGrades = QBCore.Shared.Jobs[jobName].grades
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
            event = 'inverse-jobcenter:client:toggleDuty'
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
                event = 'inverse-jobcenter:client:showJobInformation',
                args = {
                    name = configJob.name,
                    label = jobLabel,
                    description = jobDescription,
                    startingRank = jobRank 
                }
            })
        end
    end

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

RegisterNetEvent('inverse-jobcenter:client:showJobInformation', function(job)
    DebugPrint("Showing information for job: " .. job.name)
    local qbJob = QBCore.Shared.Jobs[job.name]
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

RegisterNetEvent('inverse-jobcenter:client:applyJob', function(jobName)
    DebugPrint("Applying for job: " .. tostring(jobName))
    if not jobName or type(jobName) ~= "string" or jobName == "" then
        DebugPrint("Invalid job name provided.")
        return QBCore.Functions.Notify("Invalid job name", "error")
    end

    local job = QBCore.Shared.Jobs[jobName]
    if job then
        DebugPrint("Job exists. Triggering server event to apply job: " .. jobName)
        TriggerServerEvent('inverse-jobcenter:server:applyJob', jobName, 0)
    else
        DebugPrint("Job does not exist: " .. jobName)
        QBCore.Functions.Notify("Job does not exist.", "error")
    end
end)

RegisterNetEvent('inverse-jobcenter:client:toggleDuty', function()
    DebugPrint("Toggling duty status.")
    TriggerServerEvent('inverse-jobcenter:server:toggleDuty')
end)

RegisterNetEvent('inverse-jobcenter:client:promote', function(newRank, jobName)
    QBCore.Functions.Notify("Congrats! You've been promoted to rank " .. newRank .. " in " .. jobName .. "!", "success")
end)
