local antiSpamList = {}

local function checkAntiSpam(source)
    return antiSpamList[source] == nil
end

local function antiSpam(source)
    antiSpamList[source] = true
    PZShared.newWaitingThread(PZConfig.security.commands_antispam_cooldown, function()
        antiSpamList[source] = nil
    end)
end

PZServer.registerConsoleCommand = function(name, onExecute)
    RegisterCommand(name, function(source, args, cmd)
        if source ~= 0 then
            return
        end
        onExecute(source, args, cmd)
    end, false)
end

PZServer.registerCommand = function(name, onExecute)
    RegisterCommand(name, function(source, args, cmd)
        if source == 0 then
            return
        end
        if not checkAntiSpam(source) then return end
        antiSpam(source)
        onExecute(source, args, cmd)
    end, false)
end

PZServer.registerRestrictedCommand = function(name, permissions, onExecute, onNoPermissionExecute)
    RegisterCommand(name, function(source, args, cmd)
        if source == 0 then
            return
        end
        ---@type PZPlayer
        local player = PZPlayersManager.getPlayer(source)
        local rank = player:getRank()
        if not rank:hasPermissions(permissions) then
            if onNoPermissionExecute then
                onNoPermissionExecute(source, args)
            else
                player:notify(PZShared.translate("no_permission_command"):format(cmd))
            end
            return
        end
        if not checkAntiSpam(source) then return end
        antiSpam(source)
        onExecute(source, args, cmd)
    end)
end