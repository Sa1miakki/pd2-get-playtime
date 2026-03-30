Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_SPT", function(loc)
    loc:add_localized_strings({
        ["SPT_title"] = "查询游戏时间"
    })
end)

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


Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_SPT", function(menu_manager, nodes)
    MenuCallbackHandler["SPT_confirm"] = function()
	    if managers.network._session then
	        local menu_options = {}
	        menu_options[#menu_options+1] = {text = managers.network.account:username(), data = _G.LuaNetworking:LocalPeerID(), callback = Get_Playtime_Peer}
	        for _, peer in pairs(managers.network:session():peers()) do
			    menu_options[#menu_options+1] ={text = peer:name(), data = peer:id(), callback = Get_Playtime_Peer}
	        end
	        menu_options[#menu_options+1] = {text = "关闭", is_cancel_button = true}
            QuickMenu:new("获取游戏时间", "选择一名玩家，获取他的游戏时间", menu_options, true)
        end
        
    end
	
    local menu = nodes.pause or nodes.lobby

    if nodes.lobby then
        local item = nodes.lobby:item("SPT_menu_id")
		local data_node = {type = "CoreMenuItem.Item"}
		local param = {
			name = "SPT_title", 
            text_id = "SPT_title",
            callback = "SPT_confirm"
		}
        if not item then
            item = nodes.lobby:create_item(data_node, param)
			nodes.lobby:insert_item(item, 18)
        end
        
		item:set_enabled(true)
  
    elseif nodes.pause then
	    local item = nodes.pause:item("SPT_menu_id")
		local data_node = {type = "CoreMenuItem.Item"}
		local param = {
			name = "SPT_title", 
            text_id = "SPT_title",
            callback = "SPT_confirm"
		}
        if not item then
            item = nodes.pause:create_item(data_node, param)
			nodes.pause:insert_item(item, 12)
        end
        
		item:set_enabled(true)
	
	
	end
end)
