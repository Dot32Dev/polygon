--[[
    Algorithm to generate random convex polygons is converted to Lua from Java.
    The original Java implementation is here:
    https://cglab.ca/~sander/misc/ConvexGeneration/ValtrAlgorithm.java
    The algorithm is explained in a blog post here:
    https://cglab.ca/~sander/misc/ConvexGeneration/convex.html
    And lists the following steps:
    1. Generate two lists of random X and Y coordinates
    2. Sort them
    3. Isolate the extreme points
    4. Randomly divide the interior points into two chains
    5. Extract the vector components
    6. Randomly pair up the X- and Y-components
    7. Combine the paired up components into vectors
    8. Sort the vectors by angle
    9. Lay them end-to-end to form a polygon
    10. Move the polygon to the original min and max coordinates
]]

local shuffle = function(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

local generateRandomConvexPolygon = function(n)
    -- Step 1: Generate two lists of random X and Y coordinates
    local xPool = {}
    local yPool = {}

    for i = 1, n do
        table.insert(xPool, love.math.random())
        table.insert(yPool, love.math.random())
    end

    -- Step 2: Sort them
    table.sort(xPool)
    table.sort(yPool)

    -- Step 3: Isolate the extreme points
    local minX = xPool[1]
    local maxX = xPool[#xPool]
    local minY = yPool[1]
    local maxY = yPool[#yPool]

    -- Step 4: Randomly divide the interior points into two chains
    local xVec = {}
    local yVec = {}

    local lastTop = minX
    local lastBot = minX

    for i = 2, n - 1 do
        local x = xPool[i]
        if love.math.random() < 0.5 then
            table.insert(xVec, x - lastTop)
            lastTop = x
        else
            table.insert(xVec, lastBot - x)
            lastBot = x
        end
    end

    -- Add the extreme points to the chains
    table.insert(xVec, maxX - lastTop)
    table.insert(xVec, lastBot - maxX)

    local lastLeft = minY
    local lastRight = minY

    for i = 2, n - 1 do
        local y = yPool[i]
        if love.math.random() < 0.5 then
            table.insert(yVec, y - lastLeft)
            lastLeft = y
        else
            table.insert(yVec, lastRight - y)
            lastRight = y
        end
    end

    -- Add the extreme points to the chains
    table.insert(yVec, maxY - lastLeft)
    table.insert(yVec, lastRight - maxY)

    -- Step 5: Extract the vector components
    -- This is already done while creating xVec and yVec

    -- Step 6: Randomly pair up the X- and Y-components
    shuffle(yVec)

    -- Step 7: Combine the paired up components into vectors
    local vec = {}
    for i = 1, n do
        table.insert(vec, {x = xVec[i], y = yVec[i]})
    end

    -- Step 8: Sort the vectors by angle
    table.sort(vec, function(a, b)
        return math.atan2(a.y, a.x) < math.atan2(b.y, b.x)
    end)

    -- Step 9: Lay them end-to-end to form a polygon
    local x, y = 0, 0
    local minPolygonX, minPolygonY = 0, 0
    local points = {}

    for i = 1, n do
        table.insert(points, {x = x, y = y})

        x = x + vec[i].x
        y = y + vec[i].y

        minPolygonX = math.min(minPolygonX, x)
        minPolygonY = math.min(minPolygonY, y)
    end

    -- Step 10: Move the polygon to the original min and max coordinates
    local xShift = minX - minPolygonX
    local yShift = minY - minPolygonY

    for i = 1, n do
        points[i].x = points[i].x + xShift
        points[i].y = points[i].y + yShift
    end

    return points
end

return generateRandomConvexPolygon