return function ()
	
	local ws_request_parse = {}
	local _first_chunk = true
	local method, url, vars = ""
	local postdata = {}
	local content_len
	local _len_data = 0
	
	function ws_request_parse:parse(payload)
		local _data = ""
		if _first_chunk then
			local i, j = string.find(payload, '\r\n\r\n')
			if i then
				_first_chunk = false
				local _headers = string.sub(payload, 1, j)
				local _, _, ID = string.find(_headers, "ookie: parnik=(%x%x%x%x%x%x%x%x)")
				if (ID ~= "0FCE98AC") then
					--message[#message + 1] = {"HTTP/1.0 200 OK\r\n"}
					--return
				end
				_, _, method, url, vars = string.find(_headers, "([A-Z]+) /([^?]*)%??(.*) HTTP")
				_data = string.sub(payload, j+1, -1)
				_, _, content_len = string.find(_headers, "Content%-Length: (%d+)")
				content_len = tonumber(content_len)
			end
		else
			_data = payload
		end
		--print (payload)
		--print (string.len(payload))
		_len_data = _len_data + string.len(_data)
		postdata[#postdata+1] = _data
		
		--print (content_len)
		--print (_len_data)
		if ( content_len ~= nil and _len_data ~= content_len ) then 
			return nil, nil, nil, nil, true
		end  -- still more data to come
		--if ( string.len(payload) == 1460 ) then return end
		
		--print ("return from parse")
		return postdata, method, url, vars, false
	end
	
	return ws_request_parse
end