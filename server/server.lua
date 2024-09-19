local QBCore = exports['qb-core']:GetCoreObject()

local function NotifyPlayer(src, message, type)
    TriggerClientEvent('QBCore:Notify', src, message, type)
end

local function GetJobByName(jobName)
    return QBCore.Shared.Jobs[jobName] or nil
end

RegisterNetEvent('pengu-jobcenter:server:applyJob', function(jobName, defaultGrade)
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

RegisterNetEvent('pengu-jobcenter:server:removeJob', function()
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

local playerJobsPromTimerStart = {}
local playerPromTimer = {}
local promoteTime = 12 * 60
local function startPromotionTimer(src, player, timeStartFrom)
    playerJobsPromTimerStart[src] = true
    playerPromTimer[src] = timeStartFrom
    CreateThread(function()
        while playerJobsPromTimerStart[src] do
            playerPromTimer[src] = playerPromTimer[src] + 1
            if playerPromTimer[src] >= promoteTime then
                local currentJobName = player.PlayerData.job.name
                local jobGradeint = player.PlayerData.job.grade.level or 0
                local nexJobGradeint = jobGradeint + 1

                local jobDetails = QBCore.Shared.Jobs[currentJobName]
                local jobGrade = tostring(jobGradeint)
                local nextJobGrade = tostring(nexJobGradeint)

                if jobDetails and jobDetails.grades[jobGrade] and jobDetails.grades[nextJobGrade] then
                    local jobGradeName = jobDetails.grades[jobGrade].name
                    local nextJobGradeName = jobDetails.grades[nextJobGrade].name

                    player.Functions.SetJob(currentJobName, nexJobGradeint)
                    NotifyPlayer(src, "You've been promoted from " .. jobGradeName .. " to " .. nextJobGradeName, "success")
                else
                    NotifyPlayer(src, "You have reached the highest rank or there was an issue with job grades.", "error")
                end
            end
            Wait(1000 * 60)
        end
    end)
end

AddEventHandler('playerDropped', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if player then
        local citizenid = player.PlayerData.citizenid
        if playerJobsPromTimerStart[src] and playerPromTimer[src] then
            MySQL.Async.execute('UPDATE player_duty_time SET duty_time = ? WHERE citizenid = ?', { playerPromTimer[src], citizenid })
            playerJobsPromTimerStart[src] = nil
            playerPromTimer[src] = nil
        end
    end
end)

RegisterNetEvent('pengu-jobcenter:server:initPromotionCheck', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local result = MySQL.Sync.fetchSingle('SELECT * FROM player_duty_time WHERE citizenid = ?', {player.PlayerData.citizenid})
	if result and result.duty_time then
        local timeStartFrom = result.duty_time
        startPromotionTimer(src, player, timeStartFrom)
    end
end)


RegisterNetEvent('pengu-jobcenter:server:toggleDuty', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if player then
        local playerJob = player.PlayerData.job.name
        if playerJob and playerJob ~= '' then
            local isOnDuty = player.PlayerData.job.onduty
            player.Functions.SetJobDuty(not isOnDuty)

            local status = isOnDuty and "off duty" or "on duty"
            if not isOnDuty then
                startPromotionTimer(src, player, 0)
                MySQL.Async.insert('INSERT INTO player_duty_time (citizenid, duty_time) VALUES (:cid, :dt) ON DUPLICATE KEY UPDATE duty_time = ?', {
                    ['cid'] = player.PlayerData.citizenid,
                    ['dt'] = 0,
                })
            else
                playerJobsPromTimerStart[src] = nil
                playerPromTimer[src] = nil
                MySQL.Async.execute('DELETE FROM player_duty_time WHERE citizenid = ?', { player.PlayerData.citizenid })
            end
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


RegisterNetEvent('pengu-jobcenter:server:promotePlayer', function()
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
                    TriggerClientEvent('pengu-jobcenter:client:promote', src, nextRank, jobName)
                else
                    NotifyPlayer(src, "You have reached the highest rank in your job.", "info")
                end
            else
                NotifyPlayer(src, "Error: Job details not found.", "error")
            end
        end
    end
end)