Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_SPT", function(loc)
    loc:add_localized_strings({
        ["SPT_title"] = "查询游戏时间"
    })
end)

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
