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
                    player.print("Perhaps time for a small pause?")
                end
            end
        end
    )
end

script.on_init(wellbeing_message_handler)
script.on_event(defines.events.on_runtime_mod_setting_changed, wellbeing_message_handler)
