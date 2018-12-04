STA_autoconnect, STA_autoconnect_interval = true, 10000
abort = false

function pre_startup()
	local _delay = 10
	print("Start-up will be initiated in " .. _delay .. " seconds.") 
	print("If you want to abort it please copy, paste and run:") 
	print("abort = true")
	tmr.alarm(0, _delay * 1000, 0, startup)
end

function startup()
    if abort == true then
        print('startup aborted')
        return
    end
    print('in startup')
	dofile("cfg_ap.lua")
	dofile("wifi-eventmon.lua")
	abort = nil
	pre_startup = nil
	startup = nil
end

pre_startup()