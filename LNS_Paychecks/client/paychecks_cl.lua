for _, bank in ipairs(Config.Banks) do
    exports.ox_target:addBoxZone({
        coords = bank.coords,
        size = vec3(1.5, 1.5, 1.0),
        rotation = 0,
        debug = false,
        options = {
            {
                name = 'paycheck_cash',
                event = 'LNS_Paychecks:cash',
                icon = 'fa-solid fa-money-bill',
                label = 'Cash Paycheck'
            }
        }
    })
end

RegisterNetEvent('LNS_Paychecks:cash', function()
    lib.callback('LNS_Paychecks:redeem', false, function(success, message)
        if message then
            lib.notify({
                title = 'Paycheck',
                description = message,
                type = success and 'success' or 'error'
            })
        end
    end)
end)

RegisterNetEvent('LNS_Paychecks:notifyPolice', function()
    if Config.Dispatch == 'cd_dispatch' then
        local data = exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = {'police', }, 
            coords = data.coords,
            title = 'Fraud Paycheck Detected',
            message = 'A bank clerk has reported a '..data.sex..' with a fraud paycheck',
            flash = 0,
            unique_id = data.unique_id,
            sound = 1,
            blip = {
                sprite = 431, 
                scale = 1.2, 
                colour = 3,
                flashes = false, 
                text = 'Fraud Paycheck Detected',
                time = 5,
                radius = 0,
            }
        })
    elseif Config.Dispatch == 'ps-dispatch' then
        exports['ps-dispatch']:SuspiciousActivity()
    elseif Config.Dispatch == 'custom' then
        -- Custom dispatch logic here
    end
end)

CreateThread(function()
    while not exports.ox_inventory do Wait(100) end

    exports.ox_inventory:displayMetadata({
        amount = 'Paycheck Value $',
        job = 'Job',
        owner = 'Owner'
    })
end)