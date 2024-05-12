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
  uptime_s = runcommand("date +%s") - runcommand("date -d\"$(uptime -s)\" +%s")

  -- find denominations
  uptime = {}
  uptime.d = math.floor(uptime_s / 86400)
  uptime.h = math.floor((uptime_s - uptime.d*86400) / 3600)
  uptime.m = math.floor((uptime_s - uptime.d*86400 - uptime.h*3600) / 60)
  uptime.s = uptime_s - uptime.d*86400 - uptime.h*3600 - uptime.m*60

  -- pretty print
  uptime_pp = string.format(
    "%sd %sh %sm %ss",
    uptime.d, uptime.h, uptime.m, uptime.s
  )

  -- remove 0 values
  while uptime_pp:sub(1, 1) == "0" do
    uptime_pp = uptime_pp:sub(4, -1)
  end

  return uptime_pp
end


-- define table for sysinfo
data = {}
data["line"] = string.rep("-", 10)

-- gather data
data["user"] = runcommand("whoami")
data["host"] = runcommand("hostname")
data["uptime"] = uptime()

-- concatanate data to string
output = string.format(
  "USER: %s" .. "\n"
  .. "HOST: %s" .. "\n"
  .. "UPTIME: %s" .. "\n",
  data["user"], data["host"], data["uptime"]
)


-- final display & exit
print(output)
