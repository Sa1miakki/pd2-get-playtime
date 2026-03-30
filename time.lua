local get_time = false

--local teee = '<div class="game_info_cap "><a href="https://steamcommunity.com/app/218620"><img class="game_capsule" src="https://shared.cdn.queniuqe.com/store_item_assets/steam/apps/218620/capsule_184x69.jpg?t=1771610568"></a></div> \n <div class="game_info_details"> \n 2,046 hrs on record<br>'
--local prica = '<body class="flat_page profile_page private_profile responsive_page ">'
--local hidden = '<body class="flat_page profile_page has_profile_background GameProfileTheme responsive_page ">'

function Get_Playtime_Peer(pid)
    local peer = managers.network:session():peer(pid)
	local user_id = peer:account_type_str() == "STEAM" and peer:account_id() or "epic"
	
	if not get_time then
	    managers.chat:feed_system_message(ChatManager.GAME, string.format("正在获取 %s 的游戏时间", peer:name()))
	end
	
	if user_id == "epic" then
	    managers.chat:feed_system_message(ChatManager.GAME, string.format("%s 是非STEAM玩家!", peer:name()))
	else
	    dohttpreq("https://steamcommunity.com/profiles/" .. user_id .. "/?l=english",
			function(page, id)
			    --page = hidden --替换
			    local get_time = true
		        --managers.chat:feed_system_message(ChatManager.GAME, tostring(page))
			    local _, hstart = string.find(page, "game_info_details")
			    local _, hend = string.find(page, "hrs on record")
			    
				if page == "" then
				    managers.chat:feed_system_message(ChatManager.GAME, "获取失败")
					page = false
				end
			   
 			    if hstart and hend then
			        local hour_str = string.sub(page, hstart + 17, hend)
			        local hour_str = string.gsub(hour_str, " hrs on record", "")
					local hour_str = string.gsub(hour_str, "<br>", "")
					local hour_str = string.gsub(hour_str, "\n", "")
				    managers.chat:feed_system_message(ChatManager.GAME, string.format("%s 有 %s 小时的游戏时间", peer:name(), hour_str))
			    elseif string.find(page, "flat_page profile_page private_profile responsive_page") then
				    managers.chat:feed_system_message(ChatManager.GAME, string.format("%s 的个人资料是私密的", peer:name()))
			    elseif page then
				    managers.chat:feed_system_message(ChatManager.GAME, string.format("%s 隐藏了游戏详情", peer:name()))
				end
			end)
	end
end


if managers.network._session then
	local menu_options = {}
	menu_options[#menu_options+1] = {text = managers.network.account:username(), data = _G.LuaNetworking:LocalPeerID(), callback = Get_Playtime_Peer}
	for _, peer in pairs(managers.network:session():peers()) do
		if peer:rank() and peer:level() then
			menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Get_Playtime_Peer}
		else
			menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Get_Playtime_Peer}
		end
	end
	menu_options[#menu_options+1] = {text = "关闭", is_cancel_button = true}
	local menu = QuickMenu:new("获取游戏时间", "选择一名玩家，获取他的游戏时间", menu_options)
	menu:Show()
end