require 'main'

GAME_NAME = "Template"
VERSION_NUMBER = "1.00"
ALLOW_AUTORUN_LUA = true
ALLOW_MANUALLY_DEFINED_LUA = true

SETUP_TABLE = {"ini","dat"} --makes sure files with these extensions will be setup for the application.

local EXE_NAME = "doesnthaveone"

--CREATE_PROCESS(EXE_NAME,"")



function startthething()
	print("This is a test!")
	createThread(function()
		sleep(1000)
		print("I hope you're all doing well.")
		sleep(2000)
		print("This app will close in 5 seconds.")
		sleep(1000)
		print("5")
		sleep(1000)
		print("4")	
		sleep(1000)
		print("3")
		sleep(1000)
		print("2")
		sleep(1000)
		print("1")
		sleep(1000)
		CLOSE_PROCESS()
	end)
end







DELAYED_CALL(1000,"startthething") --test function