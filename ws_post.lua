return function ()
	
	local ws_post = {}
	
	function ws_post:request(method, url, vars, tdata, x)
		local message = {}
	
		--_, _, method, url, vars = string.find(headers, "([A-Z]+) /([^?]*)%??(.*) HTTP")
		--print("Method, URL, vars: ", method, url, vars)
	
		--print ("METHOD = "..method)
		if method ~= "POST" then
			print("bad method")
			return message
		end
		
		if tdata == nil or #tdata < 1 then
			print("bad length")
			return message
		end
		
		file.open(url, "w")
		file.close()
		while #tdata > 0 do
			file.open(url, "a+")
			file.write(table.remove(tdata, 1))
			file.close()
		end
		
		return message
	end
	
	return ws_post
end