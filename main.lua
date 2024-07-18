generateRandomConvexPolygon = require("polygon_generator")
varToString = require("print_table")

local objects = {}

function love.mousepressed(b)
    local polygon = generateRandomConvexPolygon(10)
    polygon.x = 400
    polygon.y = 300

    local size = 100
    for _, point in ipairs(polygon) do
        point.x = point.x*size-size/2
        point.y = point.y*size-size/2
    end
    table.insert(objects, 1, polygon)
end

function love.draw() 
    love.graphics.setColor(0, 1, 0)

    for _, polygon in ipairs(objects) do
        local vertices = {}
        for _, point in ipairs(polygon) do
            table.insert(vertices, point.x + polygon.x)
            table.insert(vertices, point.y + polygon.y)
        end
        love.graphics.polygon("line", vertices)
    end

    if love.keyboard.isDown("space") then 
        love.graphics.print(varToString(objects))
    end
end

function love.update() 
    if objects[1] then
        -- objects[1].x = love.mouse.getX()
        -- objects[1].y = love.mouse.getY()
        if love.keyboard.isDown("left") then
            objects[1].x = objects[1].x - 5
        end
        if love.keyboard.isDown("right") then
            objects[1].x = objects[1].x + 5
        end
        if love.keyboard.isDown("up") then
            objects[1].y = objects[1].y - 5
        end
        if love.keyboard.isDown("down") then
            objects[1].y = objects[1].y + 5
        end
    end

    for i=2, #objects do
        -- Run SAT collision detection on objects[1] and objects[i]
        local bool, dist, dir = seperating_axis_theorem(objects[1], objects[i])
        if bool then
            love.graphics.print("Intersecting!")
            -- love.graphics.setColor(1, 0, 0)
            objects[1].x = objects[1].x + dist * dir.x
            objects[1].y = objects[1].y + dist * dir.y
        end
    end
end

function seperating_axis_theorem(object1, object2) 
    -- Get all the axes to test
    local axes = {}
    getAxes(axes, object1, true)
    getAxes(axes, object2)

    local min_overlap = nil
    local smallest_axis = nil
    for i, axis in ipairs(axes) do
        -- Project each polygon onto the axix
        local proj1 = project(object1, axis)
        local proj2 = project(object2, axis)

        -- love.graphics.line(proj1.min + 200, i*10 + 100, proj1.max + 200, i*10 + 100)
        -- love.graphics.line(proj2.min + 200, i*10 + 100, proj2.max + 200, i*10 + 100)

        local overlap = overlaps(proj1, proj2)
        if min_overlap == nil or overlap < min_overlap then
            min_overlap = overlap
            smallest_axis = i
        end
        if overlap == 0 then
            return false
        end
    end

    print(min_overlap)
    return true, min_overlap, axes[smallest_axis]
end

function getAxes(axes, object, flip)
    for i, vertex in ipairs(object) do
        local next_vertex = object[i + 1] or object[1]
        
        local edge = {}
        edge.x = vertex.x - next_vertex.x
        edge.y = vertex.y - next_vertex.y

        local normal = {}
        normal.x = - edge.y
        normal.y = edge.x

        if flip then
            normal.x = edge.y
            normal.y = - edge.x
        end

        normal = normalise(normal)

        -- love.graphics.setColor(1, 0, 0)
        -- love.graphics.line(object.x + vertex.x, object.y + vertex.y, object.x + vertex.x + normal.x*20, object.y + vertex.y + normal.y*20)
        -- love.graphics.setColor(0, 1, 0)


        table.insert(axes, normal)
    end
end

function normalise(vector)
    local length = math.sqrt(vector.x^2 + vector.y^2)
    
    -- Return zero vector if the length is zero to avoid division by zero
    if length == 0 then
        return {x = 0, y = 0}
    end

    return {x = vector.x / length, y = vector.y / length}
end

function project(object, axis)
    local min = (object[1].x + object.x) * axis.x + (object[1].y + object.y) * axis.y
    local max = min

    for i, vertex in ipairs(object) do
        local proj = (vertex.x + object.x) * axis.x + (vertex.y + object.y) * axis.y
        min = math.min(min, proj)
        max = math.max(max, proj)
    end

    return {min = min, max = max}
end

function overlaps(proj1, proj2)
    -- return proj1.max > proj2.min and proj1.min < proj2.max

    if proj1.max > proj2.min and proj1.min < proj2.max then
        local overlap_start = math.max(proj1.min, proj2.min)
        local overlap_end = math.min(proj1.max, proj2.max)
        return overlap_end - overlap_start
    else
        return 0
    end
end