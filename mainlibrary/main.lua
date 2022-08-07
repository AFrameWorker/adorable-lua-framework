local LAST_PROCESS
local LAST_PARAMS
local curseed = math.randomseed(os.time())
if not DOFILE_FILE_NAME then DOFILE_FILE_NAME = "_dofile.lua" end

function GET_CURRENT_SEED()
	return curseed or nil	
end

function STRING_EXPLODE(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function GET_REGISTRY_VALUE(value)
	if getSettings(LAST_PROCESS).Value[value] == "" then return nil end
	return getSettings(LAST_PROCESS).Value[value]
end

function SET_REGISTRY_VALUE(value,arg)
	if not getSettings(LAST_PROCESS) then return end
	getSettings(LAST_PROCESS).Value[value] = arg
end

function GET_REGISTRY_VALUE_CUSTOMKEY(key,value)
	if getSettings(key).Value[value] == "" then return nil end
	return getSettings(key).Value[value] or nil
end

function SET_REGISTRY_VALUE_CUSTOMKEY(key,value,arg)
	if not getSettings(key) then return end
	getSettings(key).Value[value] = arg
end

function DOES_FILE_EXIST(path,file)
	return getFileList(path,file)[1] or nil
end

function DOES_FOLDER_EXIST(dir,dirtofind)
	for _,v in pairs(getDirectoryList(dir)) do
		if string.gsub(v,dir,"") == dirtofind then return dirtofind end
	end
	return nil
end

function CREATE_DIR_IN_CACHE(dir)
	os.execute([[mkdir ]] .. [["]]..STATIC_DIRECTORY()..dir..[["]])
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
	return getFileList(LUA_DIR(),DOFILE_FILE_NAME)[1] or nil
end

function GET_ALL_AUTORUN_LUAS()
	return getFileList(AUTORUN_LUA_DIR(),"*.lua")
end

function ARE_AUTORUN_LUAS_AVAILABLE()
	return GET_ALL_AUTORUN_LUAS()[1] or nil
end

function RUN_AUTORON_LUAS() --meant to be named autorun, was a funny misspelling that I'll keep now.
	for _,args in pairs(GET_ALL_AUTORUN_LUAS()) do dofile(args) end
end

function LOAD_LUA_SCRIPTS()
	if ALLOW_AUTORUN_LUA then RUN_AUTORON_LUAS() end --Accidentally wrote it here too, therefore I never noticed it until someone told me about it.
	if IS_DOFILE_AVAILABLE() and ALLOW_MANUALLY_DEFINED_LUA then dofile(LUA_DIR()..DOFILE_FILE_NAME) end
end

function RELOAD_LUA_SCRIPTS()
	DESTROY_ALL_TIMERS()
	if ALLOW_AUTORUN_LUA then RUN_AUTORON_LUAS() end --Accidentally wrote it here too, therefore I never noticed it until someone told me about it.
	if IS_DOFILE_AVAILABLE() and ALLOW_MANUALLY_DEFINED_LUA then dofile(LUA_DIR()..DOFILE_FILE_NAME) end
end

function ENUMERATE_SYMBOLS()
	reinitializeSymbolhandler() --reinit the symbol handler
	waitForSections()
	return true
end

function MAKE_FORM_TRANSPARENT(form,transparency)
	if not form then return end
	form.setLayeredAttributes(0x000000, transparency, 2 )
	form.Color = 0x000000
end

function MAKE_FORM_TRANSPARENT_CLICKTHROUGH(form,transparency)
	if not form then return end
	form.setLayeredAttributes(0x000000, transparency, 1 )
	form.Color = 0x000000
end

function ARE_BASE_MODULES_LOADED(exe)
	if not readByte(exe) then return false end
	if not readByte(getAddress(exe)+getModuleSize(exe)-1) then return false end
	if not readByte("KERNEL32.dll") then return false end
	return true
end

local inject_count = 0
local max_inject_count = 4
local inject_status = false
function CREATE_INJECTION_TIMEOUT()
	inject_status = false
	inject_count = 0
	injectionthread = createThread(function()
		while inject_count < max_inject_count do sleep(100) if inject_status then return end inject_count = inject_count + 1 end
		RESTART_PROCESS()
	end)
end

function INJECT_LIBRARIES(exe)
	CREATE_INJECTION_TIMEOUT()
	pause()
	for _,args in pairs(getFileList(STATIC_SUB_DIRECTORY(exe),"*.acs")) do
		injectLibrary(args,true) --injects all acs's as fast as possible without enumeration
		inject_count = 0
	end
	inject_status = true
	unpause()
end

function GET_CLASSNAME_FROM_FOREGROUND_WINDOW()
	return getWindowClassName(getForegroundWindow()) or nil
end

function FOCUS_PROCESS_WINDOW(classname,windowtitle)
	executeCodeLocalEx('user32.SetForegroundWindow', findWindow(classname,windowtitle))
end

function CHANGE_PROCESS_WINDOW_TITLE(classname,windowtitle,text) --findwindow needs to contain either the classname or the current title.
	if not text then return end
	executeCodeLocalEx('user32.SetWindowTextA',findWindow(classname,windowtitle), text)
end

function AUTORUN_LUA_DIR()
	return TrainerOrigin..[[lua\autorun\]]
end

local UNHOOK
local HOOKED
function UNHOOK_PROCESS()
	HOOKED = nil
	UNHOOK = true
	DESTROY_ALL_TIMERS()
end

function DESTROY_PROCESS()
	ShellExecute("TASKKILL","/F /IM "..GET_BASEADDR(),"",false)
end

function RESTART_MAIN_PROCESS()
	ShellExecute(GET_CURRENT_DIRECTORY()..[[\]]..LAST_PROCESS_NO_CE,LAST_PARAMS,GET_CURRENT_DIRECTORY())
	closeCE()
end

RESTART_DELAY_GLOBAL = 250
function RESTART_PROCESS()
	UNHOOK_PROCESS()
	ShellExecute("TASKKILL","/F /IM "..LAST_PROCESS,"",false)
	while IS_GAME_RUNNING(LAST_PROCESS) do sleep(10) end
	sleep(RESTART_DELAY_GLOBAL)
	RESTART_MAIN_PROCESS()
end

function MAIN_Setup(exe)
	while not DOES_SUB_STATIC_DIRECTORY_EXIST(exe) do sleep(10) CREATE_SUB_STATIC_DIRECTORY(exe) end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.dll")) do if string.gsub(args,TEMP_DIRECTORY(),"") ~= "lua53-64.dll" then os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end end
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.acs")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end
	if SETUP_TABLE then
		for _,setupvalue in pairs(SETUP_TABLE) do for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*."..setupvalue)) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..string.gsub(args,TEMP_DIRECTORY(),"")) end end 
	end
	
	for _,args in pairs(getFileList(TEMP_DIRECTORY(),"*.code")) do os.rename(args,STATIC_SUB_DIRECTORY(exe)..[[\]]..exe) end --always last to ensure it doesnt run before the other setups have finished.
	return true
end

function MAIN_Cleanup(exe)
	while getFileList(STATIC_SUB_DIRECTORY(exe))[1] do sleep(1) for _,args in pairs(getFileList(STATIC_SUB_DIRECTORY(exe))) do os.remove(args) end end
	return true
end

function onTerminatedProcess() --selfmade (same as CLOSE_PROCESS() wtf)
	DESTROY_ALL_TIMERS()
	if LAST_PROCESS then MAIN_Cleanup(LAST_PROCESS) end
	closeCE()
end

function CLOSE_PROCESS()
	DESTROY_ALL_TIMERS()
	MAIN_Cleanup(LAST_PROCESS)
	closeCE()
end

function CLOSE_PROCESS_NO_CLEANUP()
	DESTROY_ALL_TIMERS()
	closeCE()
end

function GET_DECIMAL_ADDRESS(addr)
	return getAddress(addr) or nil
end

function FIX_EXE_VARIABLE(exe)
	exe = string.gsub(exe,".exe","")
	exe = exe..[[ce.exe]]
	return exe
end

function IS_AVAILABLE(exe)
	return getFileList(STATIC_SUB_DIRECTORY(exe),exe)[1] or nil
end

local timeout_count = 0
local hasLuaLoaded = false
local debug_hook_test = 0
local MAX_TIMEOUT = 500
function onOpenProcess(processid)
	if HOOKED then return end
	HOOKED = true --preventing the rest of the code to be called more than once if onOpenProcess decides to be funny
	reinitializeSymbolhandler()
	waitForSections()
	if LAST_PROCESS then INJECT_LIBRARIES(LAST_PROCESS) end
	LOAD_LUA_SCRIPTS()
end

function HOOK_PROCESS(exe,updaterate)
	if not exe then return end
	main = createThread(function()
		while not readInteger(exe) do 
			openProcess(exe)
			timeout_count = timeout_count + 1
			if timeout_count >= MAX_TIMEOUT then messageDialog("ERROR","The game failed to start. Please reinstall.",mtError,mbOK) onTerminatedProcess() return end
			sleep(10)
		end
		while readInteger(exe) do
			sleep(updaterate)
			if UNHOOK then UNHOOK = nil return end
			GAME_UPDATE()
		end
		while not readInteger(exe) do sleep(1) onTerminatedProcess() end
	end)
end

function CREATE_PROCESS(exe,params,updaterate)
	if not exe then return end
	LAST_PROCESS_NO_CE = exe
	exe = FIX_EXE_VARIABLE(exe)
	LAST_PROCESS = exe
	LAST_PARAMS = params
	if not updaterate then updaterate = 10 end
	if VERSION_NUMBER then SET_REGISTRY_VALUE("VERSION",VERSION_NUMBER) end
	if IS_GAME_RUNNING(exe) then messageDialog("ERROR","The game is already running!",mtError,mbOK) closeCE() return end
	if not HAS_BEEN_SETUP then MAIN_Cleanup(exe) sleep(10) MAIN_Setup(exe) HAS_BEEN_SETUP = true end
	while not IS_AVAILABLE(exe) do sleep(10) end
	ShellExecute(STATIC_SUB_DIRECTORY(exe)..[[\]]..exe,params,GET_CURRENT_DIRECTORY())
	HOOK_PROCESS(exe,updaterate)
end

function CREATE_PROCESS_NO_HOOK(path,exe,params)
	ShellExecute(path..[[\]]..exe,params,path)
end

function CREATE_PROCESS_NO_HOOK_CUSTOM_PATH(path,exe,params,path2)
	ShellExecute(path..[[\]]..exe,params,path2)
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
	if timers[name] then timers[name].destroy() timers[name] = nil end
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
	--timers = {}
end	
