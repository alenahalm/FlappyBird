Mover = {}
Mover.__index = Mover

function Mover:create(location, velocity, weight)
    local mover = {}
    setmetatable(mover, Mover)
    mover.image = love.graphics.newImage("images/WIND_BIRD.png")
    mover.location = location
    mover.velocity = velocity
    mover.acceleration = Vector:create(0, 0)
    mover.weight = weight or 1
    mover.size = mover.image:getHeight() * 0.08
    mover.max_speed = 3
    mover.is_jumping = false
    return mover
end

function Mover:stop()
    self.velocity.x = 0
    self.velocity.y = 0
end

function Mover:apply_force(force)
    if math.abs(self.acceleration:mag()) < self.max_speed then
        self.acceleration:add(force * self.weight)
    end
end

function Mover:draw()
    local scale = 0.08
    love.graphics.push()
    love.graphics.scale(scale, scale)
    love.graphics.draw(self.image, (self.location.x-self.size/2+10)/scale, self.location.y/scale)
    love.graphics.pop()
end

function Mover:update()
    self.velocity:add(self.acceleration)
    self.location:add(self.velocity)
    self.acceleration:mul(0)
end

function Mover:check_boundaries(scale)
    if self.location.y > (height / scale) * 0.81 - self.size / 2 then
        -- self.location.y = (height / scale) * 0.81 - self.size / 2
        return true
    elseif self.location.y < 0 then
        -- self.location.y = 0
        return true
    end
    return false
end

function Mover:restart()
    self.location.x = width/4
    self.location.y = height*0.6
    self.velocity.x = 0
    self.velocity.y = 0
    self.acceleration.x = 0
    self.acceleration.y = 0
end