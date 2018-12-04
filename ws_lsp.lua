-- Handling Lua Server Page
return function ()
	
	local ws_lua = {}
	
	function ws_lua:process(method, fname, t_vars)
		--print ( method, fname, t_vars )
		--print ( t_vars["ssid"] )
		local t_HTML = {}
		-- single row will be
		-- {["category"]="html" or "lua",
		--	["text"]="some.-.-.text",
		--	["price"]=10,  ["quantity"]=5 }
		local message = {}
		local restart = false
		
		if ( fname == "" or fname == nil or file.exists(fname) == false ) then
			--print ("HTTP/1.1 404 file not found")
			return {"HTTP/1.1 404 file not found"}
		end
		
		-- PARSE the received GET variables
		
		
		local fileOffset = 0
		local line = ""
		local chunkSize = 512
		local in_lua_code = false
		local lua_code = ""
		if file.open(fname, "r") then
			repeat 
				file.seek("set", fileOffset)
				line = file.read(chunkSize)
				if ( line ~= nil ) then 
					local open_tag_start_pos, open_tag_end_pos = 0, 0
					local close_tag_start_pos, close_tag_end_pos = 0, 0
					
					if ( in_lua_code == false ) then
						-- parsing HTML code
						local html_code = ""
						open_tag_start_pos, open_tag_end_pos = line:find("<%%lsp")
						if ( open_tag_start_pos ~= nil ) then
							html_code = line:sub(1, open_tag_start_pos - 1)
							in_lua_code = true
						else
							html_code = line
						end
						t_HTML[#t_HTML+1] = {["text"] = html_code, ["category"] = "html"}
						-- message[#message + 1] = html_code
						fileOffset = fileOffset + (open_tag_end_pos or html_code:len()) + 1
					else 
						-- parsing LUA code
						close_tag_start_pos, close_tag_end_pos = line:find("/lsp%%>")
						local code = ""
						if ( close_tag_start_pos ~= nil ) then
							local code = line:sub(1, close_tag_start_pos - 1)
							local stripped = string.gsub(code, '^%s*(.-)%s*$', '%1')
							if ( stripped:sub(1,1) == "=" ) then
								--print ("printing stripped ...")
								--print (stripped)
								--  code  ???
								t_HTML[#t_HTML+1] = {["text"] = stripped:sub(2), ["category"] = "lua"}
								--message[#message + 1] = code
							else
								lua_code = lua_code .. " " .. code
							end
							in_lua_code = false
						else
							lua_code = lua_code .. " " .. line
						end
						fileOffset = fileOffset + (close_tag_end_pos or line:len())   --close_tag_end_pos -- + 1
					end
				end
			until (line == nil) --or string.len(line) ~= chunkSize)
			
			file.close()
		end
		
		-- Execute Lua code
		local status, chunk = pcall(loadstring("return function(t_vars) " .. lua_code .. " end"))
		--print(chunk, status)
		if ( status == true ) then
			chunk(t_vars)
			for k,v in pairs(t_HTML) do 
				--print ( v["category"] )
				--print ( v["text"] )
				if ( v["category"] == "html" ) then
					message[#message + 1] = v["text"]
				else
					print ( v["text"] )
				end
			end
		else 
			message = { "ERROR: " .. chunk}
		end
		t_HTML, fileOffset, line, chunkSize, in_lua_code, lua_code, status, chunk  = nil, nil, nil, nil, nil, nil, nil, nil
		return message, restart
	end
	
	return ws_lua
end