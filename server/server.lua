local QBCore = exports['qb-core']:GetCoreObject()

local function NotifyPlayer(src, message, type)
    TriggerClientEvent('QBCore:Notify', src, message, type)
end

local function GetJobByName(jobName)
    return Config.Jobs[jobName] or nil
end

RegisterNetEvent('pengu-jobcenter:server:applyJob', function(jobName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name == 'unemployed' then
        local job = GetJobByName(jobName)

        if not job then return NotifyPlayer(src, "The job does not exist.", "error") end
        NotifyPlayer(src, "Applying for job... Please wait.", "info")

        Wait(10000)
        Player.Functions.SetJob(jobName, '0')
        print("Player " .. src .. " has been assigned to job: " .. jobName)
        print("current job: " .. Player.PlayerData.job.name)

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
        NotifyPlayer(src, "You already have a job.", "error")
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
local promoteTime = Config.PromotionTime
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

                local jobDetails = Config.Jobs[currentJobName]
                local jobGrade = tostring(jobGradeint)
                local nextJobGrade = tostring(nexJobGradeint)

                if jobDetails and jobDetails.grades[jobGrade] and jobDetails.grades[nextJobGrade] then
                    local jobGradeName = jobDetails.grades[jobGrade].name
                    local nextJobGradeName = jobDetails.grades[nextJobGrade].name

                    player.Functions.SetJob(currentJobName, nexJobGradeint)
                    NotifyPlayer(src, "You've been promoted from " .. jobGradeName .. " to " .. nextJobGradeName,
                        "success")
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
            MySQL.Async.execute('UPDATE player_duty_time SET duty_time = ? WHERE citizenid = ?',
                { playerPromTimer[src], citizenid })
            playerJobsPromTimerStart[src] = nil
            playerPromTimer[src] = nil
        end
    end
end)

RegisterNetEvent('pengu-jobcenter:server:initPromotionCheck', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    if not player then return end

    local result = MySQL.Sync.fetchSingle('SELECT * FROM player_duty_time WHERE citizenid = ?',
        { player.PlayerData.citizenid })
    if result and result.duty_time then
        local timeStartFrom = result.duty_time
        startPromotionTimer(src, player, timeStartFrom)
    end
end)


RegisterNetEvent('pengu-jobcenter:server:toggleDuty', function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)

    if not player then return end

    local playerJob = player.PlayerData.job.name
    if playerJob and playerJob ~= '' then
        local isOnDuty = player.PlayerData.job.onduty
        player.Functions.SetJobDuty(not isOnDuty)

        local status = isOnDuty and "off duty" or "on duty"
        if not isOnDuty then
            startPromotionTimer(src, player, 0)
            MySQL.Async.insert(
                'INSERT INTO player_duty_time (citizenid, duty_time) VALUES (:cid, :dt) ON DUPLICATE KEY UPDATE duty_time = ?',
                {
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
end)

RegisterNetEvent('QBCore:Server:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)


local function TableInserts()
    QBCore.Functions.AddJobs(Config.Jobs)
end

TableInserts()


local function GetJobByName(jobName)
    return Config.Jobs[jobName]
end

local function NotifyPlayer(playerId, message, messageType)
    TriggerClientEvent('QBCore:Notify', playerId, message, messageType)
end

RegisterNetEvent('pengu-jobcenter:server:promotePlayer', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local jobName = Player.PlayerData.job.name
    if jobName and jobName ~= 'unemployed' then
        local currentRank = Player.PlayerData.job.grade
        local jobDetails = GetJobByName(jobName)

        if not jobDetails then return NotifyPlayer(src, "Error: Job details not found.", "error") end

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
    end
end)


RegisterNetEvent('pengu-jobcenter:server:purchaseItem', function(itemName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return NotifyPlayer(src, "The item does not exist.", "error") end
    local itemData = Config.Misc[itemName]

    if not itemData then return end
    -- Assuming the item costs $100
    local itemCost = itemData.price or 100 -- Use the item's price if available

    -- Check if player can afford the item
    if Player.Functions.RemoveMoney('cash', itemCost, "Purchased " .. itemData.name) then
        -- Prepare item info based on type
        local info = {}
        if itemName == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
            info.description = "This ID is issued to " .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        elseif itemName == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
            info.description = "This License is issued to " .. Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        end

        -- Give the player the item with the info
        Player.Functions.AddItem(itemName, 1, nil, info)

        -- Create a detailed message about the item
        local itemInfo = "Name: " .. itemData.name .. "\n" .. "Description: " .. (itemData.description or "No description available.") .. "\n" .. "Price: $" .. itemCost

        NotifyPlayer(src, "You purchased a " .. itemData.name .. "!\n" .. itemInfo, "success")
    else
        NotifyPlayer(src, "You don't have enough money to purchase a " .. itemData.name, "error")
    end
end)
