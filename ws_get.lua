return function ()
	
	local ws_get = {}
	
	local function parse_get_variables ( vars )
		local t_vars = {}
		for token in string.gmatch(vars, "[^&]+") do
			local name, value = string.match(token, "(.*)%=(.*)")
			t_vars[name] = value
		end
		return t_vars
	end
	
	function ws_get:request(method, url, vars, x)
		local AceEnabled = true
		local message = {}
		local restart = false
		
		if method ~= "GET" then
			--print("bad method")
			return message
		end
		
		if (url == "" and vars == "") then
			--print ("Redirecting to index.html")
			url = "index.html"
		end
		local fname, fext = url:match( "([^/]+)$" ), url:match("^.+(%..+)$")
		--print ( method, url, vars, fname, fext )
		
		if ( fname:len() > 30 or fname == "" or fname == nil or file.exists(fname) == false ) then
			--print ("HTTP/1.1 404 file not found")
			return {"HTTP/1.1 404 file not found"}
		end
		
		if (fname == "favicon.ico") then
			return {"HTTP/1.1 404 file not found"}
		end
		
		local t_vars = {}
		if ( vars ~= nil and vars ~= "") then 
			t_vars = parse_get_variables ( vars )
		end
		
		if ( fext == ".lsp" ) then
			local f_lsp = dofile("ws_lsp.lua")()
			message, restart = f_lsp:process(method, fname, t_vars)
			f_lsp = nil
		else 
			repeat
				local _exit = true
				if (url == "" and vars == "") then
					local flist = file.list();
					message = {"HTTP/1.0 200 OK"}
					message[#message + 1] = "Server: NodeMCU on ESP8266"
					message[#message + 1] = "Content-Type: text/html"
					message[#message + 1] = "Connection: close\r\n\r\n"
					message[#message + 1] = "<html><body><h1><a href='/'>NodeMCU IDE</a></h1>"
					message[#message + 1] = "<table border=1 cellpadding=3><tr><th>Name</th><th>Size</th><th>Edit</th><th>Compile</th><th>Delete</th></tr>"
					for k,v in pairs(flist) do
						local line = "<tr><td><a href='" ..k.. "'>" ..k.. "</a></td><td>" ..v.. "</td><td>"
						local editable = k:sub(-4, -1) == ".lua" or k:sub(-4, -1) == ".css" or k:sub(-5, -1) == ".html" or k:sub(-5, -1) == ".json"
						if editable then
							line = line .. "<a href='" ..k.. "?edit'>edit</a>"
						end
						line = line .. "</td><td>"
						if k:sub(-4, -1) == ".lua" then
							line = line .. "<a href='" ..k.. "?compile'>compile</a>"
						end
						line = line .. "</td><td><a href='" ..k.. "?delete'>delete</a></td></tr>"
						message[#message + 1] = line
					end
					message[#message + 1] = "</table><a href='#' onclick='v=prompt(\"Filename\");if (v!=null) { this.href=\"/\"+v+\"?edit\"; return true;} else return false;'>Create new</a> &nbsp; &nbsp; <a href='#' onclick='var x=new XMLHttpRequest();x.open(\"GET\",\"/?restart\");x.send();setTimeout(function(){location.href=\"/\"},5000);document.write(\"Please wait\");return false'>Restart</a>"
					message[#message + 1] = "</body></html>"
				elseif (url == "" and vars == "restart") then
					print ("Restrat")
					--node.restart()
					restart = true
					url = ""
				else
					-- it wants a file in particular
					if vars == "edit" then
						local sen = "<html><body><h1><a href='/'>NodeMCU IDE</a></h1>"
						if AceEnabled then
							local mode = 'ace/mode/'
							if url:match(".css") then mode = mode .. 'css'
							elseif url:match(".html") then mode = mode .. 'html'
							elseif url:match(".json") then mode = mode .. 'json'
							elseif url:match(".js") then mode = mode .. 'javascript'
							else mode = mode .. 'lua'
							end
							sen = sen .. "<style type='text/css'>#editor{width: 100%; height: 80%}</style><div id='editor'></div><script src='//rawgit.com/ajaxorg/ace-builds/master/src-min-noconflict/ace.js'></script>"
								.. "<script>var e=ace.edit('editor');e.setTheme('ace/theme/cobalt');e.getSession().setMode('"..mode.."');function getSource(){return e.getValue();};function setSource(s){e.setValue(s);}</script>"
						else
							sen = sen .. "<textarea name=t cols=79 rows=17></textarea></br>"
								.. "<script>function getSource() {return document.getElementsByName('t')[0].value;};function setSource(s) {document.getElementsByName('t')[0].value = s;};</script>"
						end
						sen = sen .. "<script>function tag(c){document.getElementsByTagName('w')[0].innerHTML=c};var x=new XMLHttpRequest();x.onreadystatechange=function(){if(x.readyState==4) setSource(x.responseText);};x.open('GET',location.pathname);x.send()</script>"
							.. "<button onclick=\"tag('Saving');x.open('POST',location.pathname);x.onreadystatechange=function(){if(x.readyState==4) tag(x.responseText);};x.send(new Blob([getSource()],{type:'text/plain'}));\">Save</button> <a href='?run'>run</a> <w></w>"
						sen = sen .. "</body></html>"
						message[#message + 1] = sen
					elseif vars == "compile" then
						collectgarbage()
						node.compile(url)
						url = ""
						vars = ""
						_exit = false
					elseif vars == "delete" then
						print ("delete")
						file.remove(url)
						url = ""
						vars = ""
						_exit = false
					else
						local DataToGet = 0
						local line = ""
						local chunkSize = 512
						if file.open(url, "r") then
							repeat 
								file.seek("set", DataToGet)
								line = file.read(chunkSize)
								if ( line ~= nil ) then 
									message[#message + 1] = line
									DataToGet = DataToGet + chunkSize
								else
									message = {"HTTP/1.0 200 OK"}
								end
							until (line == nil or string.len(line) ~= chunkSize)
							file.close()
						end
					end        
					
				end
				print ("exit = " , _exit)
			until (_exit == true)
		end
		
		return message, restart
	end
	
	return ws_get
end