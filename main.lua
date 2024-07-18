generateRandomConvexPolygon = require("polygon_generator")
varToString = require("print_table")

local objects = {}

love.graphics.setColor(0, 1, 0)

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

    love.graphics.print(varToString(objects))
end

function love.update() 
    if objects[1] then
        objects[1].x = love.mouse.getX()
        objects[1].y = love.mouse.getY()
    end
end