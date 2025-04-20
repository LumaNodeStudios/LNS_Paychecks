# Features

- Gives you a "paycheck" item instead of a direct payment

- Able to cash in paycheck at a bank. Banks are configurable VIA config.lua

- Each "paycheck" item is the amount of the job/grade pay. (Ex. unemployed is $10. Each paycheck item is worth 10 dollars.)

# Requirements

- [ox_inventory](https://github.com/overextended/ox_inventory)

- [ox_lib](https://github.com/overextended/ox_lib)

- [ox_target](https://github.com/overextended/ox_target)

- [qbx_core](https://github.com/Qbox-project/qbx_core)

# qbx_core edits

**qbx_core/config/server.lua**

```
sendPaycheck = function (playerId, payment)
    local player = exports.qbx_core:GetPlayer(playerId)

    if not player then
        print(("[ERROR] Player %s not found in qbx_core."):format(playerId))
        return
    end

    local playerName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname

    local metadata = {
        amount = tonumber(payment),
        owner = playerName,
        job = player.PlayerData.job and player.PlayerData.job.name or "unemployed"
    }

    exports.ox_inventory:AddItem(player.PlayerData.source, 'paycheck', 1, metadata)
    Notify(player.PlayerData.source, locale('info.received_paycheck', payment))
end,
```

**qbx_core/server/loops.lua**

```
local function pay(player)
    local job = player.PlayerData.job
    local jobData = GetJob(job.name)

    if not jobData then return end

    local payment = jobData.grades[job.grade.level].payment or job.payment
    if payment <= 0 then return end
    if not jobData.offDutyPay and not job.onduty then return end

    if config.money.paycheckSociety then
        local account = config.getSocietyAccount(job.name)
        if not account then
            config.sendPaycheck(player.PlayerData.source, payment)
            return
        end
        if account < payment then
            Notify(player.PlayerData.source, locale('error.company_too_poor'), 'error')
            return
        end
        config.removeSocietyMoney(job.name, payment)
    end

    config.sendPaycheck(player.PlayerData.source, payment)
end
```

# Item (ox_inventory)

```
['paycheck'] = {
    label = 'Paycheck',
    weight = 0,
    stack = true,
    close = true,
    description = 'A paycheck for your hard work.',
    metadata = {'job', 'amount', 'owner'}
},
```
