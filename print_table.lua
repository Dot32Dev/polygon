-- Thanks to HugoBDesigner! (https://love2d.org/forums/viewtopic.php?t=82877)
local function varToString(var)
  if type(var) == "string" then
    return "\"" .. var .. "\""
  elseif type(var) ~= "table" then
    return tostring(var)
  else
    local ret = "{ "
    local ts = {}
    local ti = {}
    for i, v in pairs(var) do
      if type(i) == "string" then
        table.insert(ts, i)
      else
        table.insert(ti, i)
      end
    end
    table.sort(ti)
    table.sort(ts)
    
    local comma = ""
    if #ti >= 1 then
      for i, v in ipairs(ti) do
        ret = ret .. comma .. varToString(var[v])
        comma = ", \n"
      end
    end
    
    if #ts >= 1 then
      for i, v in ipairs(ts) do
        ret = ret .. comma .. "" .. v .. " = " .. varToString(var[v])
        comma = ", \n"
      end
    end
    
    return ret .. "}"
  end
end

return varToString