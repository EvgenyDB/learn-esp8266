wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
	print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
	T.BSSID.."\n\tChannel: "..T.channel)
end)

wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
	print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\treason: "..T.reason)
	-- Keep autoconnect switched OFF, because it tries every second and messes up the AP
	wifi.sta.autoconnect(0)
	-- MUST run disconnect, otherwise it tries every second to reconnect until the dooms day !!!
	wifi.sta.disconnect()
	-- GV STA_autoconnect is used in order to switch ON and OFF this enhanced auto_connect functionality
	if ( STA_autoconnect == true ) then
		if ( STA_autoconnect_interval == nil ) then
			STA_autoconnect_interval = 10000
		end
		tmr.alarm(0,STA_autoconnect_interval,0,function() wifi.sta.connect() end)
	end
end)

-- wifi.eventmon.register(wifi.eventmon.STA_AUTHMODE_CHANGE, function(T)
	-- print("\n\tSTA - AUTHMODE CHANGE".."\n\told_auth_mode: "..
	-- T.old_auth_mode.."\n\tnew_auth_mode: "..T.new_auth_mode)
-- end)

-- wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
	-- print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
	-- T.netmask.."\n\tGateway IP: "..T.gateway)
-- end)

--wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT, function()
--	print("\n\tSTA - DHCP TIMEOUT")
--end)

--wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
--	print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
--end)

--wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T)
--	print("\n\tAP - STATION DISCONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
--end)

--wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, function(T)
--	print("\n\tAP - PROBE REQUEST RECEIVED".."\n\tMAC: ".. T.MAC.."\n\tRSSI: "..T.RSSI)
--end)

--wifi.eventmon.register(wifi.eventmon.WIFI_MODE_CHANGED, function(T)
--	print("\n\tSTA - WIFI MODE CHANGED".."\n\told_mode: "..
--	T.old_mode.."\n\tnew_mode: "..T.new_mode)
--end)