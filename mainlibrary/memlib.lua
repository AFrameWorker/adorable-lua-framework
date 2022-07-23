
-- this library sucks
local ENUMERATE_RETRY_COUNT = 0
local ENUMERATE_MAX_RETRIES = 25
function ERROR_HANDLER(call,...)
	DESTROY_ALL_TIMERS()
	UNHOOK_PROCESS()
	DESTROY_PROCESS()
	local arg = print(...)
	messageDialog("LUA ERROR","Error on CALL: "..call.." | Data: ".. arg,mtError,mbOK)
	CLOSE_PROCESS()
	return nil
end

function ENUMERATE_SYMBOLS(call,address)
	if DISABLE_ENUMERATION_LOOP then 
		reinitializeSymbolhandler() 
		waitForSections()
	return end
	createThread(function()
		while not readInteger(address) do 
			if ENUMERATE_RETRY_COUNT >= ENUMERATE_MAX_RETRIES then ERROR_HANDLER(call,address) break end
			--print("enumerating... "..call.." | "..address)
			reinitializeSymbolhandler() 
			waitForSections()
			ENUMERATE_RETRY_COUNT = ENUMERATE_RETRY_COUNT + 1 
		end
		ENUMERATE_RETRY_COUNT = 0
		--print("enumerated: "..call.." | "..address)
	end)
end

function READ_BYTE(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_BYTE",address) end
	return readByte(address) or nil
end

function READ_BYTES(address,bytecount, ReturnAsTable)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_BYTES",address) end
	if not readInteger(address) then return nil end
	return readBytes(address,bytecount, ReturnAsTable)
end

function READ_SHORT_INTEGER(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_SHORT_INTEGER",address) end
	return readShortInteger(address) or nil
end

function READ_SMALL_INTEGER(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_SMALL_INTEGER",address) end
	return readSmallInteger(address) or nil
end

function READ_INTEGER(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_INTEGER",address) end
	return readInteger(address) or nil
end

function READ_QWORD(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_QWORD",address) end
	return readQword(address) or nil
end

function READ_POINTER(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_POINTER",address) end
	return readPointer(address) or nil
end

function READ_FLOAT(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_FLOAT",address) end
	return readFloat(address) or nil
end

function READ_DOUBLE(address)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_DOUBLE",address) end
	return readDouble(address) or nil
end

function READ_STRING(address, maxlength, widechar)
	if not readInteger(address) then ENUMERATE_SYMBOLS("READ_STRING",address) end
	if not maxlength then maxlength = 64 end
	return readString(address, maxlength, widechar) or nil
end

function WRITE_BYTE(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeByte(address,value) or ERROR_HANDLER("WRITE_BYTE",address.." "..value)
end

function WRITE_BYTES(address,...)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	if not readInteger(address) then ERROR_HANDLER("WRITE_BYTES",address, ...) return nil end
	return writeBytes(address,...)
end

function WRITE_SHORT_INTEGER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeShortInteger(address,value) or ERROR_HANDLER("WRITE_SHORT_INTEGER",address.." ".. value)
end

function WRITE_SMALL_INTEGER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeSmallInteger(address,value) or ERROR_HANDLER("WRITE_SMALL_INTEGER",address.." ".. value)
end

function WRITE_INTEGER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeInteger(address,value) or ERROR_HANDLER("WRITE_INTEGER",address.." ".. value)
end

function WRITE_QWORD(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeQword(address,value) or ERROR_HANDLER("WRITE_QWORD",address.." ".. value)
end

function WRITE_POINTER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writePointer(address,value) or ERROR_HANDLER("WRITE_POINTER",address.." ".. value)
end

function WRITE_FLOAT(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeFloat(address,value) or ERROR_HANDLER("WRITE_FLOAT",address.." "..value)
end

function WRITE_DOUBLE(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeDouble(address,value) or ERROR_HANDLER("WRITE_DOUBLE",address.." "..value)
end

function WRITE_STRING(address,text, widechar)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	return writeString(address,text, widechar) or ERROR_HANDLER("WRITE_STRING",address.." "..text.." "..tostring(widechar))
end

function FULL_ACCESS(address,size)
	if not readInteger(address) then reinitializeSymbolhandler() waitForSections() end
	if not readInteger(address) then ERROR_HANDLER("FULL_ACCESS",address.." "..size) return nil end
	return fullAccess(address,size)
end
