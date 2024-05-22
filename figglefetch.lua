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

-- generates ascii randomart from the OS name, hostname and username
function generateart(os, host, user, algorithm)
  -- set image sizes
  local dimensions = {8, 5}
  local len = dimensions[1] * dimensions[2]

  -- trim/repeat os string to 20 characters
  if #os > len then
    os = os:sub(1, len)
  elseif #os < len then
    os = string.rep(os, len // #os)
    os = os .. os:sub(1, len - #os)
  end
  
  -- trim/repeat hostname string to len characters
  if #host > len then
    host = host:sub(1, len)
  elseif #host < len then
    host = string.rep(host, len // #host)
    host = host .. host:sub(1, len - #host)
  end
  
  -- trim/repeat username string to len characters
  if #user > len then
    user = user:sub(1, len)
  elseif #user < len then
    user = string.rep(user, len // #user)
    user = user .. user:sub(1, len - #user)
  end

  -- joins the strings together in a 2:1:1 ratio, then finds the decimal of each character  
  local codes = {}
  local ratio = {
    (len // 2) + (len - (len // 2 + len // 4 + len // 4)),
    len // 4,
    len // 4
  }
  local string = os:sub(1, ratio[1]) .. host:sub(1, ratio[2]) .. user:sub(1, ratio[3])
  for char in string:gmatch(".") do
    table.insert(codes, char:byte())
  end

  -- converts codes to characters
  local art_chars = {}
  for i,v in pairs(codes) do
    if v == 32 or v == 45 then
      art_chars[i] = tostring(46):char()
    elseif v >= 65 and v <= 90 then
      art_chars[i] = tostring(v-33):char()
    elseif v >= 97 and v <= 102 then
      art_chars[i] = tostring(v-39):char()
    elseif v >= 103 and v <= 108 then
      art_chars[i] = tostring(v-12):char()
    elseif v >= 109 and v <= 112 then
      art_chars[i] = tostring(v+14):char()
    elseif v >= 113 and v <= 118 then
      art_chars[i] = tostring(v-22):char()
    elseif v >= 119 and v <= 122 then
      art_chars[i] = tostring(v+4):char()
    end
  end

  -- joins the table of ascii codes into a rectangle
  local art = {}
  for i=1,dimensions[2] do
    art[i] = table.concat(art_chars, "", dimensions[1]*(i-1)+1, dimensions[1]*i)
  end

  return art
end

-- combines the randomart and the data and prints it
function printoutput(data_fmt, art)
  -- find which table is longer
  local longest_output = math.max(#data_fmt, #art)

  local output = ""
  for i=1,longest_output do
    if art[i] == nil and data_fmt[i] ~= nil then
      art[i] = string.rep(" ", #art[1])
    elseif data_fmt[i] == nil and art[i] ~= nil then
      data_fmt[i] = ""
    end

    output = output .. art[i] .. "\t" .. data_fmt[i] .. "\n"
  end

  print(output)

  return
end


-- define table for sysinfo
data = {}
data.line = string.rep("-", 20)

-- gather data
data.user = runcommand("whoami")
data.host = runcommand("hostname")
data.uptime = uptime()
data.os = osname()

-- format data into another table
data_fmt = {
  "USER: " .. data.user,
  "HOST: " .. data.host,
  "UPTIME: " .. data.uptime,
  "OS: " .. data.os
}
art = generateart(data.os, data.host, data.user)

-- final display & exit
printoutput(data_fmt, art)
