<html>
	<%lsp 
	if ( t_vars ~= nil ) then
		print(t_vars["ssid"])
	/lsp%>
	<head>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<link rel="shortcut icon" href="about:blank">
	</head>
	<%lsp 
--		station_cfg={}
		print(t_vars["ssid"])
--		station_cfg={}
--		station_cfg={}
--		station_cfg.ssid = "NODE"
--		station_cfg.pwd="123"
--		station_cfg.save=false
--		wifi.sta.config(station_cfg)
	end
	/lsp%>
	<body>
		<div style="color:black;text-align:center;width:100%;display:inline-block;font-weight:bold">RECEIVED</div>
		<div style="color:black;text-align:left;width:100%;display:inline-block"><%lsp = t_vars["ssid"] /lsp%></div>
	</body>
</html>