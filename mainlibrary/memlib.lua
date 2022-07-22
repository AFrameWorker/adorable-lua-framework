function ERROR_HANDLER(call,...)
	DESTROY_ALL_TIMERS()
	UNHOOK_PROCESS()
	DESTROY_PROCESS()
	local arg = print(...)
	messageDialog("LUA ERROR","Error on CALL: "..call.." | Data: ".. arg,mtError,mbOK)
	CLOSE_PROCESS()
	return nil
end

function READ_BYTE(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readByte(address) or ERROR_HANDLER("READ_BYTE",address)
end

function READ_BYTES(address,bytecount, ReturnAsTable)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	if not readInteger(address) then ERROR_HANDLER("READ_BYTES",address.." "..bytecount.." ".. tostring(ReturnAsTable)) return nil end
	return readBytes(address,bytecount, ReturnAsTable)
end

function READ_SHORT_INTEGER(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readShortInteger(address) or ERROR_HANDLER("READ_SHORT_INTEGER",address)
end

function READ_SMALL_INTEGER(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readSmallInteger(address) or ERROR_HANDLER("READ_SMALL_INTEGER",address)
end

function READ_INTEGER(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readInteger(address) or ERROR_HANDLER("READ_INTEGER",address)
end

function READ_QWORD(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readQword(address) or ERROR_HANDLER("READ_QWORD",address)
end

function READ_POINTER(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readPointer(address) or ERROR_HANDLER("READ_POINTER",address)
end

function READ_FLOAT(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readFloat(address) or ERROR_HANDLER("READ_FLOAT",address)
end

function READ_DOUBLE(address)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return readDouble(address) or ERROR_HANDLER("READ_DOUBLE",address)
end

function READ_STRING(address, maxlength, widechar)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	if not maxlength then maxlength = 64 end
	return readString(address, maxlength, widechar) or ERROR_HANDLER("READ_STRING",address.." "..maxlength.." "..tostring(widechar))
end

function WRITE_BYTE(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeByte(address,value) or ERROR_HANDLER("WRITE_BYTE",address.." "..value)
end

function WRITE_BYTES(address,...)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	if not readInteger(address) then ERROR_HANDLER("WRITE_BYTES",address, ...) return nil end
	return writeBytes(address,...)
end

function WRITE_SHORT_INTEGER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeShortInteger(address,value) or ERROR_HANDLER("WRITE_SHORT_INTEGER",address.." ".. value)
end

function WRITE_SMALL_INTEGER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeSmallInteger(address,value) or ERROR_HANDLER("WRITE_SMALL_INTEGER",address.." ".. value)
end

function WRITE_INTEGER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeInteger(address,value) or ERROR_HANDLER("WRITE_INTEGER",address.." ".. value)
end

function WRITE_QWORD(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeQword(address,value) or ERROR_HANDLER("WRITE_QWORD",address.." ".. value)
end

function WRITE_POINTER(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writePointer(address,value) or ERROR_HANDLER("WRITE_POINTER",address.." ".. value)
end

function WRITE_FLOAT(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeFloat(address,value) or ERROR_HANDLER("WRITE_FLOAT",address.." "..value)
end

function WRITE_DOUBLE(address,value)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeDouble(address,value) or ERROR_HANDLER("WRITE_DOUBLE",address.." "..value)
end

function WRITE_STRING(address,text, widechar)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	return writeString(address,text, widechar) or ERROR_HANDLER("WRITE_STRING",address.." "..text.." "..tostring(widechar))
end

function FULL_ACCESS(address,size)
	if not readInteger(address) then reinitializeSymbolhandler() waitForPDB() end
	if not readInteger(address) then ERROR_HANDLER("FULL_ACCESS",address.." "..size) return nil end
	return fullAccess(address,size)
end