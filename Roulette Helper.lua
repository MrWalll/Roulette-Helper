--[[
    This script was created by MrWalll
]]

util.require_natives(1672190175)
util.keep_running()

local myroot = menu.my_root()
local PlayerName = players.get_name
local active_step = 0
local send_to = 1
local tp = {}
local rigOutcome = menu.ref_by_path("Online>Quick Progress>Casino>Roulette Outcome")
local commands = menu.ref_by_path("Online>Chat>Commands>Enabled For Me")

local steps = {
    [0] = "Casino rigging is one of the most efficient ways to generate money for other players. It's less risky than money drops, and scales to more people than heists. This method can make up to 14mi per hour per player, for up to 20 players at a time.",
    [1] = "Enable roulette rigging with Online > Quick Progress > Casino > Roulette Outcome > 1. \nThis works on all tables at once.",
    [2] = "You must remain inside the Casino to rig the table games, if you leave they will no longer be rigged.",
    [3] = "Each player that wants to play must take a seat at a roulette table. The purple High Limit tables pay out 10x more than green tables. For VIP access players must either own a penthouse, or join an org of someone who owns a penthouse.",
    [4] = "Press TAB key to maximize bet amounts per click.",
    [5] = "Click on the red 1 space to bet 5k (be careful to click in the center of the square and not the surrounding lines)",
    [6] = 'Click on the "1st 12" space five times to bet an additional 50k.',
    [7] = "When the spin comes up red 1, each player will win 330k on a 55k bet.",
    [8] = "If a player wins 13 bets in a row, then the casino will cut them off for one hour. To avoid this, place a small losing bet every 10 spins or every $3mil."
    }

myroot:divider(SCRIPT_NAME)

Steps_Slider = myroot:slider("Steps", {"sliderSteps"}, ""..steps[0], 0, 8, 0, 1, function(value)
    active_step = value
    menu.set_help_text(Steps_Slider, steps[active_step])
end)

myroot:list_select("Send to", {"sliderSendto"}, "Click to apply", {"All", "Team/Org Chat"}, 1, function(index)
    send_to = index
end)

send_step = myroot:action("Send", {"sendStep"}, "Sends the current step to the chosen chat.", function(click_type)
    menu.show_warning(myroot, click_type, "You should not send step 1 and 2 to others. It will not make any sense for them!", function()
        switch send_to do
            case 1:
                chat.send_message(steps[active_step], false, true, true)
                break
            case 2:
                chat.send_message(steps[active_step], true, true, true)
                break
        end
        send_step:focus()
    end, function()
        util.toast("Aborted")
        send_step:focus()
    end, false)
end)

myroot:divider("")
RigRoulette = myroot:action("Rig Roulette Outcome", {}, "This is just a helper so you dont have to do it on your own\nRigs Roulette Outcome to 1", function()
    if menu.get_menu_name(RigRoulette) == "Rig Roulette Outcome" then
        menu.set_value(rigOutcome, "1")
        menu.set_menu_name(RigRoulette, "Rig Roulette Outcome [Active]")
    else
        menu.set_value(rigOutcome, "-1")
        menu.set_menu_name(RigRoulette, "Rig Roulette Outcome")
    end
end)

autoLose = myroot:toggle_loop("Auto Rig", {}, "Rigs the Roulette to lose ever 10min for one min. \nWhy every 10min? Because one roulette round is about 1min long (from setting bet to receving win) times 10 makes it 10 wins so you need to lose once, to not get cut off by the casino.", function(toggle)
    local startTime = os.time()

    while autoLose.value do
        local currentTime = os.time()
        local timePast = currentTime - startTime

        if timePast >= 600 then --600 == 10min
            if rigOutcome.value == 1 then
                rigOutcome.value = "35" --set outcome to 35 to lose 100% of your bet
                util.yield(65*1000) -- wait one round
                rigOutcome.value = "1" --reset outcome to 1
            else
                rigOutcome.value = "1"
            end
            startTime = os.time() --reset startTime for timePast
        end
        util.yield(10)
    end
end,function()
    if RigRoulette.menu_name == "Rig Roulette Outcome [Active]" then
        rigOutcome.value = "1"
    end
    if RigRoulette.menu_name == "Rig Roulette Outcome" then
        rigOutcome.value = "-1"
    end
end)

tp_list = myroot:list("Teleport Players to Casino")

myroot:divider("")
credits = myroot:list("Credits")

credits:hyperlink("hexarobi", "https://discord.com/channels/956618713157763072/1045070097401794611", "Inspired and steps from his post")

tp_list:action("Redirect to Chat Commands", {},"You need to activate chat commands for others bevor they can use this.", function()
    commands:focus()
end)
tp_list:action("Inform others about this command", {}, "Sends a message to all chat explaining about this chat command and how to use it.", function()
    local prefix = menu.ref_by_path("Online>Chat>Commands>Prefix"):getState()
    chat.send_message('A chat command for you all to teleport into the casino has been activated.\nJust type "'..prefix..'tptocasino" in the team or all chat', false, true, true)
end)
tp_list:divider("")

players.add_command_hook(function(playerID, set)                                                                                                                                                                                                                                                                             --[[        _  _           ]]
    if not menu.ref_by_rel_path(tp_list, PlayerName(playerID)):isValid() then                                                                                                                                                                                                                                                --[[       (.)(.)          ]]
        tp[playerID] = tp_list:action(PlayerName(playerID), {"tptocasino"}, 'Command: "tptocasino"', function()                                                                                                                                                                                                              --[[      (.____.)         ]]
            menu.trigger_commands("casinotp"..PlayerName(playerID))                                                                                                                                                                                                                                                          --[[        '--'           ]]
        end, nil, nil, COMMANDPERM_RUDE)
    end
end)

players.on_leave(function(playerID, name)
    tp[playerID]:delete()
end)