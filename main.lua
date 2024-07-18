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

    love.graphics.setColor(0, 1, 0)
    
    for i=2, #objects do
            -- Run SAT collision detection on objects[1] and objects[i]
        if seperating_axis_theorem(objects[1], objects[i]) then
            love.graphics.print("Intersecting!")
            love.graphics.setColor(1, 0, 0)
        end
    end
end

function love.update() 
    if objects[1] then
        objects[1].x = love.mouse.getX()
        objects[1].y = love.mouse.getY()
    end
end

function seperating_axis_theorem(object1, object2) 
    -- Get all the axes to test
    local axes = {}
    getAxes(axes, object1)
    getAxes(axes, object2)

    for i, axis in ipairs(axes) do
        -- Project each polygon onto the axix
        local proj1 = project(object1, axis)
        local proj2 = project(object2, axis)

        -- love.graphics.line(proj1.min + 200, i*10 + 100, proj1.max + 200, i*10 + 100)
        -- love.graphics.line(proj2.min + 200, i*10 + 100, proj2.max + 200, i*10 + 100)

        if not overlaps(proj1, proj2) then
            return false
        end
    end

    return true
end

function getAxes(axes, object)
    for i, vertex in ipairs(object) do
        local next_vertex = object[i + 1] or object[1]
        local normal = {}
        normal.x = - (vertex.y - next_vertex.y)
        normal.y = vertex.x - next_vertex.x

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
    return proj1.max > proj2.min and proj1.min < proj2.max
end