local config = { -- default values, 
	enableATK = false,
	ebableELE = false,
	enableCRT = false,
	enableDEF = false,
	
	attack_value = 0,
	element_value = 0,
	defence_value = 0,
	critical_value = 0,

}

-- don't edit anything below unless you know what you're doing

local config_path = "Status Mod/config.json"
local playerBase, playerData

if true then -- init config
	local config_file = json.load_file(config_path)
	
	if config_file ~= nil then
		config = config_file
	else
		json.dump_file(config_path, config)
	end
end

local function getPlayerBase()
    if not playerBase or playerData then
        local playerManager = sdk.get_managed_singleton("snow.player.PlayerManager")
        playerBase = playerManager:call("findMasterPlayer")
    end
    return playerBase
end
local function getPlayerData()
    if not playerData then
        local playerBase = getPlayerBase()
        if not playerBase then
            return
        end
        playerData = playerBase:call("get_PlayerData")
    end
    return playerData
end

function set_attack_value()
	local original_attack_value = 0
	if config.enableATK then
		local playerData = getPlayerData()
		local now_attack_value = playerData:get_field("_Attack")
		original_attack_value = now_attack_value
		local total_attack_value = 0
		total_attack_value = config.attack_value
		playerData:set_field("_AtkUpAlive",total_attack_value)
	else
		local playerData = getPlayerData()
		playerData:set_field("_AtkUpAlive",original_attack_value)
		config.attack_value = 1
	end
end

function set_defence_value()
	local original_defence_value = 0
	if config.enableDEF then
		local playerData = getPlayerData()
		local now_defence_value = playerData:get_field("_Defence")
		original_defence_value = now_defence_value
		local total_defence_value = 0
		total_defence_value = config.defence_value
		playerData:set_field("_DefUpAlive",total_defence_value)
	else
		local playerData = getPlayerData()
		playerData:set_field("_DefUpAlive",original_defence_value)
		config.defence_value = 1
	end
end

function set_critical_value()
	local original_critical_value = 0
	if config.enableCRT then
		local playerData = getPlayerData()
		local now_critical_value = playerData:get_field("_CriticalRate")
		-- print(now_critical_value)
		original_critical_value = now_defence_value
		local total_critical_value = 0
		total_critical_value = config.critical_value
		playerData:set_field("_CritChanceUpBow",total_critical_value)
		playerData:set_field("_CritChanceUpBowTimer",100)
		playerData:set_field("_CritUpEcSecondTimer",50)
	else
		local playerData = getPlayerData()
		playerData:set_field("_CritChanceUpBow",original_critical_value)
		playerData:set_field("_CritChanceUpBowTimer",0)
		playerData:set_field("_CritUpEcSecondTimer",0)
		config.critical_value = 0
	end
end

function set_element_value()
	local original_element_value = 0
	if config.enableELE then
		local playerData = getPlayerData()
		local now_element_value = playerData:get_field("_ElementAttack")
		-- print(now_element_value)
		original_element_value = now_element_value
		local total_element_value = 0
		total_element_value = config.element_value + now_element_value
		playerData:set_field("_ElementAttack",total_element_value)
	else
		local playerData = getPlayerData()
		playerData:set_field("_ElementAttack",original_element_value)
		config.element_value = 0
	end
end

local function on_do_update(args)
	set_attack_value()
	set_element_value()
	set_critical_value()
	set_element_value()
end

sdk.hook(
    sdk.find_type_definition("snow.player.PlayerManager"):get_method("update"), 
    on_do_update, 
    function(retval) end)

re.on_draw_ui(function()
	local changed = false
	
	if imgui.tree_node("Status Modifier") then
		if imgui.tree_node("Attack") then
			changed, config.enableATK = imgui.checkbox("Enable", config.enableATK)
			if config.enableATK then
				changed, config.attack_value = imgui.drag_int("ATTACK Value", config.attack_value, 1, 0, 2600)
			end
			if changed then
				set_attack_value()
			end
			imgui.tree_pop()
		end
		
		changed = false

		if imgui.tree_node("ElementValue") then
			changed, config.enableELE = imgui.checkbox("Enable", config.enableELE)
			if config.enableELE then
				changed, config.element_value = imgui.drag_int("Element Value", config.element_value, 1, 0, 65535)
			end
			if changed then
				set_element_value()
			end
			imgui.tree_pop()
		end
		
		changed = false
		
		if imgui.tree_node("Critical") then
			changed, config.enableCRT = imgui.checkbox("Enable", config.enableCRT)
			if config.enableCRT then
				changed, config.critical_value = imgui.drag_int("Critical Value", config.critical_value, 1, 0, 100)
			end
			if changed then
				set_critical_value()
			end
			imgui.tree_pop()
		end

		changed = false

		if imgui.tree_node("Defence") then
			changed, config.enableDEF = imgui.checkbox("Enable", config.enableDEF)
			if config.enableDEF then
				changed, config.defence_value = imgui.drag_int("DEFENCE Value", config.defence_value, 1, 0, 3100)
			end
			if changed then
				set_defence_value()
			end
			imgui.tree_pop()
		end		


		-- Save Config
		-- if imgui.button("Save Settings") then
		-- 	if json.load_file(config_path) ~= config then
		-- 		json.dump_file(config_path, config)
		-- 	end
		-- end
		
		imgui.tree_pop()
	end
end)
