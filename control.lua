function formattime(ticks)
    local minutes = math.floor(ticks / 60 / 60)
    local hours = math.floor(minutes / 60)
    return string.format("%02dh%02dm", hours, minutes % 60)
end

function wellbeing_message_handler()
    local ticks_per_minute = 60 * 60

    local interval_list_in_ticks = {}
    for i, player in pairs(game.players) do
        local setting = player.mod_settings["wellbeing-alert-interval"].value
        if setting > 0 then
            interval_list_in_ticks[i] = setting * ticks_per_minute
        end
    end

    script.on_nth_tick(nil)
    script.on_nth_tick(interval_list_in_ticks,
        function(event)
            for i, player in pairs(game.players) do
                if player.mod_settings["wellbeing-alert-interval"].value * ticks_per_minute == event.nth_tick then
                    local session_duration = game.tick - (global.session_start[player.index] or 0)
                    player.print("You've been playing for " .. formattime(session_duration) .. "\n" ..
                                 "Perhaps time for a pause? Will warn again in: " .. formattime(event.nth_tick))
                end
            end
        end
    )
end

script.on_init(
    function()
        global.session_start = {}
        wellbeing_message_handler()
    end
)

script.on_event(defines.events.on_player_joined_game,
    function(event)
        global.session_start[event.player_index] = game.tick
    end
)

commands.add_command("wellbeing", "<reset-timer> resets the session timer to zero",
    function(command)
        if command.parameter == "reset-timer" then
            global.session_start[command.player_index] = game.tick
        end
    end
)
script.on_event(defines.events.on_runtime_mod_setting_changed, wellbeing_message_handler)
