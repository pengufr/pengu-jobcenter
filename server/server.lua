local QBCore = exports['qb-core']:GetCoreObject()

local function NotifyPlayer(src, message, type)
    TriggerClientEvent('QBCore:Notify', src, message, type)
end

local function GetJobByName(jobName)
    return QBCore.Shared.Jobs[jobName] or nil
end

RegisterNetEvent('inverse-jobcenter:server:applyJob', function(jobName, defaultGrade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        if Player.PlayerData.job.name == 'unemployed' then
            local job = GetJobByName(jobName)

            if job then
                NotifyPlayer(src, "Applying for job... Please wait.", "info")

                Wait(10000) 

                Player.Functions.SetJob(jobName, defaultGrade)

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

RegisterNetEvent('inverse-jobcenter:server:removeJob', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local jobName = Player.PlayerData.job.name

        if jobName and jobName ~= 'unemployed' then
            local job = GetJobByName(jobName)

            if job then
                Player.Functions.SetJob('unemployed', 0)

                if job.licenseItem then
                    local itemInfo = Player.Functions.GetItemByName(job.licenseItem)

                    if itemInfo then
                        Player.Functions.RemoveItem(job.licenseItem, 1)
                        NotifyPlayer(src, "Your job license for " .. job.label .. " has been removed.", "info")
                    end
                end

                NotifyPlayer(src, "You have left the job: " .. job.label, "success")
            else
                NotifyPlayer(src, "The job does not exist.", "error")
            end
        else
            NotifyPlayer(src, "You are not currently employed.", "error")
        end
    end
end)


function GetJobByName(jobName)
    for _, job in pairs(Config.Jobs) do
        if job.name == jobName then
            return job
        end
    end
    return nil
end

function NotifyPlayer(playerId, message, type)
    TriggerClientEvent('QBCore:Notify', playerId, message, type)
end


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

local function GetJobByName(jobName)
    return Config.Jobs[jobName]
end

local function NotifyPlayer(playerId, message, messageType)
    TriggerClientEvent('QBCore:Notify', playerId, message, messageType)
end

RegisterNetEvent('inverse-jobcenter:server:promotePlayer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local jobName = Player.PlayerData.job.name
        if jobName and jobName ~= 'unemployed' then
            local currentRank = Player.PlayerData.job.grade
            local jobDetails = GetJobByName(jobName)

            if jobDetails then
                local nextRank = currentRank + 1
                local rankCount = #jobDetails.grades 

                if nextRank <= rankCount then
                    Player.Functions.SetJob(jobName, nextRank)
                    NotifyPlayer(src, "Congratulations! You've been promoted to rank " .. nextRank .. " in " .. jobName,
                        "success")
                    TriggerClientEvent('inverse-jobcenter:client:promote', src, nextRank, jobName)
                else
                    NotifyPlayer(src, "You have reached the highest rank in your job.", "info")
                end
            else
                NotifyPlayer(src, "Error: Job details not found.", "error")
            end
        end
    end
end)
