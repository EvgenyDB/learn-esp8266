return function (port) 
	
	local x = 0
	
	local function f_connection (client)
		local f_parse = dofile("ws_request_parse.lua")()
		local restart = false
		client:on("receive", function (client, payload)
			--print (payload)
			local method, url, vars = ""
			local wait_more = false
			local tdata = {}
			tdata, method, url, vars, wait_more = f_parse:parse(payload)
			if wait_more then return end
			f_parse = nil
			
			local buf = {}
			
			if method == "POST" then
				local xyz = dofile("ws_post.lua")()
				buf = xyz:request(method, url, vars, tdata, x)
				xyz = nil
			elseif method == "GET" then
				local xyz = dofile("ws_get.lua")()
				buf, restart = xyz:request(method, url, vars, x)
				xyz = nil
			end
			
			local function send (localSocket)
				if buf ~= nil and #buf > 0 then
					local str = table.remove(buf, 1)
					--print (#buf, str)
					localSocket:send(str)
				else
					localSocket:close()
					buf = nil
					--print ( "restart = ", restart )
					if ( restart == true ) then node.restart() end
					collectgarbage()
				end
			end
			
			client:on("sent", send)
			send (client)
			collectgarbage()
		end)
	end

    local srv = net.createServer(net.TCP, 180) -- 180 seconds client timeout
    srv:listen(port, function (client)
		client:on("connection", f_connection)
        collectgarbage()
	end)
	
	local tcpserver = {}
    function tcpserver:close()
		--xyz:cleanup()
		--xyz = nil
        srv:close()
		buf = nil
        srv = nil
        collectgarbage()
	end
	
	return tcpserver
end