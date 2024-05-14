#!/usr/bin/env lua

-- runs an OS command and returns the output
function runcommand(command)
  -- run command and store result
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()

  -- return and trim final newline
  return result:sub(1, -2)
end

-- returns a pretty-printed uptime (heavily inspired by neofetch)
function uptime()
  -- get system uptime in seconds
  local uptime_s = runcommand("date +%s") - runcommand("date -d\"$(uptime -s)\" +%s")

  -- find denominations
  local uptime = {}
  uptime.d = math.floor(uptime_s / 86400)
  uptime.h = math.floor((uptime_s - uptime.d * 86400) / 3600)
  uptime.m = math.floor((uptime_s - uptime.d * 86400 - uptime.h * 3600) / 60)
  uptime.s = uptime_s - uptime.d * 86400 - uptime.h * 3600 - uptime.m * 60

  -- pretty print
  local uptime_pp = string.format(
    "%sd %sh %sm %ss",
    uptime.d, uptime.h, uptime.m, uptime.s
  )

  -- remove 0 values
  while uptime_pp:sub(1, 1) == "0" do
    uptime_pp = uptime_pp:sub(4, -1)
  end

  return uptime_pp
end

-- returns the pretty name for the OS
function osname()
  -- get system info
  local os_release = runcommand("cat /etc/os-release")

  -- extract pretty name
  local name_pp = os_release:match("PRETTY_NAME=\"[^\"]+"):sub(14,-1)

  return name_pp
end


-- define table for sysinfo
data = {}
data.line = string.rep("-", 10)

-- gather data
data.user = runcommand("whoami")
data.host = runcommand("hostname")
data.uptime = uptime()
data.os = osname()

-- concatanate data to string
output = string.format(
  "USER: %s" .. "\n"
  .. "HOST: %s" .. "\n"
  .. "UPTIME: %s" .. "\n"
  .. "OS: %s" .. "\n",
  data.user, data.host, data.uptime, data.os
)


-- final display & exit
print(output)
