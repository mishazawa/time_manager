
-- set frequency to 1 minute
local freq = 64 * 60
local time_manager_event = script.generate_event_name()

local play_time_table = {}

function set_limit (cmd) 
    local player = game.get_player(cmd.player_index)
    local limit_minutes = tonumber(cmd.parameter)

    play_time_table[player.index] = {
        enabled = limit_minutes ~= 0,
        paused = false,
        time_remain = limit_minutes,
    }

    game.print({"gt_messages.time-set", limit_minutes, player.name})
end

function get_limit (cmd) 
    local player = game.get_player(cmd.player_index)
    if play_time_table[player.index] ~= nil then 
        player.print({"gt_messages.time-left", play_time_table[player.index].time_remain})
    else 
        player.print({"gt_messages.time-left-no-limit"})
    end
end

function check_players_play_time (event)
    for p, v in pairs(play_time_table) do
        local player = game.get_player(p)
        if v.enabled and v.paused ~= true then
            v.time_remain = v.time_remain - 1
            if v.time_remain == 0 then
                player.print({"gt_messages.time-exeeded"}, {r = 0.5, g = 0, b = 0, a = 0.5})
                v.enabled = false
            elseif v.time_remain < 5 then
                player.print({"gt_messages.time-left", v.time_remain})
            end
        end
    end    
end


function on_player_joined(t)
    local tick = t.tick
    local player = game.get_player(t.player_index)
    if play_time_table[player.index] ~= nil then
        play_time_table[player.index].paused = false
    end
end

function on_player_left(t)
    local tick = t.tick
    local player = game.get_player(t.player_index)
    if play_time_table[player.index] ~= nil then
        play_time_table[player.index].paused = true
    end
end

function on_tick(event)
    local tick = event.tick % freq
    if tick == 0 then
        script.raise_event(time_manager_event, event)
    end
end

commands.add_command("gt_set", {"gt_messages.gt-set-instruction"}, set_limit)
commands.add_command("gt_status", {"gt_messages.gt-status-instruction"}, get_limit)

script.on_event(defines.events.on_player_joined_game,   on_player_joined)
script.on_event(defines.events.on_player_left_game,     on_player_left)
script.on_event(defines.events.on_tick,                 on_tick)
script.on_event(time_manager_event,                     check_players_play_time)