local QBCore = exports['qb-core']:GetCoreObject()

local function NotifyPlayer(src, message, type)
    TriggerClientEvent('QBCore:Notify', src, message, type)
end

local function GetJobByName(jobName)
    for _, job in ipairs(Config.Jobs) do
        if job.name == jobName then
            return job
        end
    end
    return nil
end

RegisterNetEvent('inverse-jobcenter:server:applyJob', function(jobName, defaultGrade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        if Player.PlayerData.job.name == 'unemployed' then
            local job = GetJobByName(jobName)

            if job then
                NotifyPlayer(src, "Applying for job... Please wait.", "info")

                -- Delay for 10 seconds
                Wait(10000)

                -- Set the job and default grade
                Player.Functions.SetJob(jobName, defaultGrade)

                -- Grant the job license if it exists
                if job.licenseItem then
                    local itemInfo = Player.Functions.GetItemByName(job.licenseItem)

                    if not itemInfo then
                        Player.Functions.AddItem(job.licenseItem, 1)
                        NotifyPlayer(src, "You have received a job license for your new position.", "success")
                    else
                        NotifyPlayer(src, "You already have a job license for this position.", "info")
                    end
                end

                NotifyPlayer(src, "You got the job: " .. job.label, "success") 
            else
                NotifyPlayer(src, "The job does not exist.", "error")
            end
        else
            NotifyPlayer(src, "You already have a job.", "error")
        end
    end
end)

RegisterNetEvent('inverse-jobcenter:server:toggleDuty', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if player then
        local playerJob = player.PlayerData.job.name
        if playerJob and playerJob ~= '' then
            local isOnDuty = player.PlayerData.job.onduty
            player.Functions.SetJobDuty(not isOnDuty)

            local status = isOnDuty and "off duty" or "on duty"
            NotifyPlayer(src, "You are now " .. status .. " as a " .. playerJob .. ".", "success")
        else
            NotifyPlayer(src, "You do not have a job to toggle duty for.", "error")
        end
    end
end)
