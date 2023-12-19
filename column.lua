Column = {}
Column.__index = Column

function Column:create(x)
    local column = {}
    setmetatable(column, Column)
    begin = x
    column.top = love.graphics.newImage('images/top.png')
    column.bottom = love.graphics.newImage('images/bottom.png')
    love.graphics.scale(0.1, 0.1)
    column.gap = Vector:create(0, 0)
    column.gap.x = x
    column.width = column.top:getWidth()-30
    column.height = 250
    column.gap.y = love.math.random(10, height-column.height-10)
    column.is_drawing = false
    return column
end

function Column:update(last)
    if self.is_drawing then
        self.gap.x = self.gap.x - 3
    end
    if self.gap.x + self.width < 0 then
        self.gap.x = last.gap.x + 550
        self.gap.y = love.math.random(10, height*0.81-self.height-10)
    end
end

function Column:draw()
    love.graphics.draw(self.top, (self.gap.x-15), (-self.top:getHeight()+self.gap.y))
    love.graphics.draw(self.bottom, (self.gap.x-15), (self.gap.y + self.height))
end


function Column:check_collision(object)

    -- object
    r = object.size / 2
    cx = object.location.x + r
    cy = object.location.y + r
    -- love.graphics.circle('line', cx, cy, r)
    -- line 1
    x1 = self.gap.x
    y1 = 0
    x2 = self.gap.x
    y2 = self.gap.y
    -- love.graphics.line(x1, y1, x2, y2)
    if line_circle(x1, y1, x2, y2, cx, cy, r) then
        return true
    end

    -- line 2
    x1 = self.gap.x
    y1 = self.gap.y
    x2 = self.gap.x + self.width
    y2 = self.gap.y
    -- love.graphics.line(x1, y1, x2, y2)
    if line_circle(x1, y1, x2, y2, cx, cy, r) then
        return true
    end

    -- line 3
    x1 = self.gap.x
    y1 = self.gap.y + self.height
    x2 = self.gap.x + self.width
    y2 = self.gap.y + self.height
    -- love.graphics.line(x1, y1, x2, y2)
    if line_circle(x1, y1, x2, y2, cx, cy, r) then
        return true
    end

    -- line 4
    x1 = self.gap.x
    y1 = self.gap.y + self.height
    x2 = self.gap.x
    y2 = height
    -- love.graphics.line(x1, y1, x2, y2)
    if line_circle(x1, y1, x2, y2, cx, cy, r) then
        return true
    end
end

function dist(px, py, x, y)
    return math.sqrt((px - x)*(px - x) + (py - y)*(py - y))
end

function line_circle(x1, y1, x2, y2, cx, cy, r)
    inside1 = point_circle(x1, y1, cx, cy, r)
    inside2 = point_circle(x2, y2, cx, cy, r)
    if inside1 or inside2 then
        return true
    end

    distX = x1 - x2
    distY = y1 - y2
    length = math.sqrt((distX * distX) + (distY * distY))

    dot = (((cx - x1) * (x2 - x1)) + ((cy - y1) * (y2 - y1))) / (length * length)

    closestX = x1 + (dot * (x2 - x1))
    closestY = y1 + (dot * (y2 - y1))

    onSegment = line_point(x1, y1, x2, y2, closestX, closestY)
    if not onSegment then
        return false
    end

    distX = closestX - cx
    distY = closestY - cy

    distance = math.sqrt((distX * distX) + (distY * distY))
    if distance <= r then
        return true
    end
    return false
end

function line_point(x1, y1, x2, y2, px, py)
    d1 = dist(px, py, x1, y1)
    d2 = dist(px, py, x2, y2)

    lineLen = dist (x1, y1, x2, y2)

    buffer = 0.1

    if d1 + d2 >= lineLen - buffer and d1 + d2 <= lineLen + buffer then
        return true
    end
    return false
end

function point_circle(px, py, cx, cy, r)
    distX = px - cx
    distY = py - cy
    distance = math.sqrt((distX * distX) + (distY * distY))

    if distance <= r then
        return true
    end
    return false
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x1 - x2) * (x1-x2) + (y1-y2) * (y1-y2))
end

function Column:stop()
    self.is_drawing = false
end