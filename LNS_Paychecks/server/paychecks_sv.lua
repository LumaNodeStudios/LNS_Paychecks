lib.callback.register('LNS_Paychecks:redeem', function(source)
    local paycheckItem = Config.PaycheckItem
    local player = exports.qbx_core:GetPlayer(source)

    if not player then
        return false, 'Error retrieving player data!'
    end

    local playerName = ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)

    local slots = exports.ox_inventory:GetSlotsWithItem(source, paycheckItem)

    if not slots or #slots == 0 then
        return false, 'No paychecks found in your inventory.'
    end

    local totalPay = 0
    local paycheckCount = 0

    for _, slot in pairs(slots) do
        local meta = slot.metadata

        if meta and type(meta.amount) == "number" and type(meta.owner) == "string" then
            if meta.owner ~= playerName then
                TriggerClientEvent('LNS_Paychecks:notifyPolice', source)
                return false, 'Attempted fraud detected. Police notified.'
            end

            if meta.amount < 0 or meta.amount > 20000 then
                return false, 'Suspicious paycheck detected. Contact staff.'
            end

            local count = slot.count or 1
            local removed = exports.ox_inventory:RemoveItem(source, paycheckItem, count, meta, slot.slot)
            if removed then
                totalPay = totalPay + (meta.amount * count)
                paycheckCount = paycheckCount + count
            end
        end
    end    

    if paycheckCount > 0 then
        player.Functions.AddMoney('bank', totalPay)
        return true, ('You cashed in %d paycheck(s) for $%s'):format(paycheckCount, totalPay)
    end

    return false, 'No valid paychecks found to cash in!'
end)

RegisterNetEvent('LNS_Paychecks:givePaycheck', function()
    local src = source
    local player = exports.qbx_core:GetPlayer(src)

    if not player or not player.PlayerData.job then 
        return 
    end

    local jobData = player.PlayerData.job
    local amountPerCheck = jobData.payment or 0

    if amountPerCheck <= 0 or amountPerCheck > 10000 then
        return
    end

    local metadata = {
        job = jobData.name,
        amount = amountPerCheck,
        owner = ("%s %s"):format(player.PlayerData.charinfo.firstname, player.PlayerData.charinfo.lastname)
    }

    exports.ox_inventory:AddItem(src, Config.PaycheckItem, 1, metadata)
end)

local function discordprint()
    SetTimeout(2000, function()
        print('^5[INFO]^0 Discord: https://discord.gg/uKPFaNNHD4')
    end)
end
CreateThread(discordprint)

lib.versionCheck('Error420Unknown/Error420_Paychecks')