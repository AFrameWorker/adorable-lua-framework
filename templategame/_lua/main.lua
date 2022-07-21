local LAST_PROCESS
local LAST_PARAMS

function GET_REGISTRY_VALUE(value)
	return getSettings(LAST_PROCESS).Value[value] or nil
end

function SET_REGISTRY_VALUE(value,arg)
	if not getSettings(LAST_PROCESS) then return end
	getSettings(LAST_PROCESS).Value[value] = arg
end

function CREATE_STATIC_DIRECTORY()
	os.execute([[mkdir ]] .. [["]]..os.getenv([[temp]])..[[\AFv3\Cache"]])
end

function STATIC_DIRECTORY()
	return os.getenv([[temp]])..[[\AFv3\Cache\]]
end

function STATIC_SUB_DIRECTORY(exe)
	return os.getenv([[temp]])..[[\AFv3\Cache\]]..string.gsub(exe,".exe","")
end

function CREATE_SUB_STATIC_DIRECTORY(exe)
	os.execute([[mkdir ]] .. [["]]..STATIC_SUB_DIRECTORY(exe)..[["]])
end

function DOES_STATIC_DIRECTORY_EXIST()
    for _,args in pairs(getDirectoryList(os.getenv([[temp]]))) do if args == os.getenv([[temp]])..[[\AFv3]] then return true end end
    return false
end

function DOES_SUB_STATIC_DIRECTORY_EXIST(exe)
    for _,args in pairs(getDirectoryList(os.getenv([[temp]])..[[\AFv3\Cache\]])) do if args == STATIC_SUB_DIRECTORY(exe) then return true end end
    return false
end

function TEMP_DIRECTORY()
	return string.gsub(getAutorunPath(),[[\autorun\]],[[\]])
end

function ARE_PATCHES_AVAILABLE()
	return getFileList(TEMP_DIRECTORY())[1] or nil
end

function GET_CURRENT_DIRECTORY()
	return TrainerOrigin
end

function LUA_DIR()
	return TrainerOrigin..[[lua\]]
end

function IS_DOFILE_AVAILABLE()
	return getFileList(LUA_DIR(),"_dofile.lua")[1] or nil
end

function GET_ALL_AUTORUN_LUAS()
	return getFileList(AUTORUN_LUA_DIR(),"*.lua")
end

function ARE_AUTORUN_LUAS_AVAILABLE()
	return GET_ALL_AUTORUN_LUAS()[1] or nil
end

function RUN_AUTORON_LUAS()
	for _,args in pairs(GET_ALL_AUTORUN_LUAS()) do dofile(args) end
end

function INJECT_LIBRARIES()
	reinitializeSymbolhandler()
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.acs")) do
		injectLibrary(args,true)
	end
end

function GET_CLASSNAME_FROM_FOREGROUND_WINDOW()
	return getWindowClassName(getForegroundWindow()) or nil
end

function CHANGE_PROCESS_WINDOW_TITLE(findwindow,replacementtext) --findwindow needs to contain either the classname or the current title.
	executeCodeLocalEx('user32.SetWindowTextA',findWindow(nil,findtext), replacementtext)
end

function AUTORUN_LUA_DIR()
	return TrainerOrigin..[[lua\autorun\]]
end

function DESTROY_PROCESS()
	ShellExecute("TASKKILL","/F /IM "..GET_BASEADDR(),"",false)
end

function RESTART_PROCESS()
	DESTROY_ALL_TIMERS()
	UNHOOK_PROCESS()
	ShellExecute("TASKKILL","/F /IM "..GET_BASEADDR(),"",false)
	while IS_GAME_RUNNING(LAST_PROCESS) do sleep(1) end
	CREATE_PROCESS(LAST_PROCESS,LAST_PARAMS)
end

function onOpenProcess(processid)
	INJECT_LIBRARIES()
	LAST_PROCESS = GET_BASEADDR()
	if ALLOW_AUTORUN_LUA then RUN_AUTORON_LUAS() end
	if IS_DOFILE_AVAILABLE() and ALLOW_MANUALLY_DEFINED_LUA then dofile(LUA_DIR()..[[_dofile.lua]]) end
end

function MAIN_Setup(exe)
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.dll")) do if string.gsub(args,TEMP_DIRECTORY(),"") ~= "lua53-64.dll" then os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.asi")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.acd")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.aci")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.ini")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.dat")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.code")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..exe) end
	return true
end

function MAIN_Cleanup(exe)
	for _,args in pairs(getFileList(STATIC_SUB_DIRECTORY(exe))) do os.remove(args) end
	return true
end

function onTerminatedProcess() --selfmade
	DESTROY_ALL_TIMERS()
	MAIN_Cleanup(LAST_PROCESS)
	closeCE()
end

function CLOSE_PROCESS()
	DESTROY_ALL_TIMERS()
	UNHOOK_PROCESS()
	closeCE()
end

function GET_DECIMAL_ADDRESS(addr)
	return getAddress(addr) or nil
end

local HOOKED
local thread
local timeout_count = 0
function CREATE_PROCESS(exe,params)
	LAST_PROCESS = exe
	LAST_PARAMS = params
	if VERSION_NUMBER then SET_REGISTRY_VALUE("VERSION",VERSION_NUMBER) end
	while not DOES_SUB_STATIC_DIRECTORY_EXIST(exe) do CREATE_SUB_STATIC_DIRECTORY(exe) sleep(10) end
	if IS_GAME_RUNNING(exe) then messageDialog("ERROR","The game is already running!",mtError,mbOK) closeCE() return end
	if not HAS_BEEN_SETUP then MAIN_Cleanup(exe) sleep(1) MAIN_Setup(exe) HAS_BEEN_SETUP = true end
	createThread(function() --allows main thread to run so that we can use timers, yay.
		ShellExecute(STATIC_SUB_DIRECTORY(exe)..[[\]]..exe,params,GET_CURRENT_DIRECTORY())
		while not IS_GAME_HOOKED() and not HOOKED do 
			ATTACH_PROCESS(exe) 
			timeout_count = timeout_count + 1 
			if timeout_count >= 500 then messageDialog("ERROR","The game failed to start. Please reinstall.",mtError,mbOK) onTerminatedProcess() break end
			sleep(10) 
		end
		HOOKED = true
		timeout_count = 0
		while IS_GAME_HOOKED() and HOOKED do
			GAME_UPDATE()
			sleep(10)
		end
		while not IS_GAME_HOOKED() and HOOKED do onTerminatedProcess() end
		while IS_GAME_HOOKED() and not HOOKED do break end --breaks while loop, can allow for restarting game executable without ending CE thread
	end)
end

function UNHOOK_PROCESS()
	if not HOOKED then return end
	HOOKED = nil
end

function ATTACH_PROCESS(procname)
	openProcess(procname)
end

function GET_BASEADDR()
	return process or nil
end

function IS_GAME_HOOKED()
	return readInteger(GET_BASEADDR()) or nil
end

function IS_GAME_RUNNING(name)
	return getProcessIDFromProcessName(name) or nil
end

function IS_GAME_FOCUSED()
	return getForegroundProcess() == getOpenedProcessID() or nil
end

local timers = {}
function CREATE_TIMER(int,name)
	int = tonumber(int)
	if not int or not name then return end
	if timers[name] then return end
	timers[name] = createTimer()
	timers[name].Interval = int
	timers[name].OnTimer = _G[name]
end

function DESTROY_TIMER(name)
	if not name then return end
	if not timers[name] then return end
	timers[name].destroy()
	timers[name] = nil
end

function DOES_TIMER_EXIST(name)
	if not name then return false end
	if not timers[name] then return false else return true end
end

function DELAYED_CALL(int,name)
int = tonumber(int)
if not int or not name then return end
if timers[name] then return end
timers[name] = createTimer()
timers[name].Interval = int
timers[name].OnTimer = function()
_G[name]()
timers[name].destroy()
timers[name] = nil
end
end

function DESTROY_ALL_TIMERS()
	for _,timer in pairs(timers) do timer.destroy() timer = nil end
end