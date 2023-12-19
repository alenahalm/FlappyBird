Background = {}
Background.__index = Background

function Background:create(filename)
    local background = {}
    background.image1 = love.graphics.newImage(filename)
    background.image2 = love.graphics.newImage(filename)
    background.width = background.image1:getWidth()
    background.x1 = 0
    background.x2 = background.width

    background.scale_y = height / background.image1:getHeight()
    background.scale_x = width / background.image1:getWidth()

    background.stop = true

    setmetatable(background, Background)
    return background
end

function Background:update()
    if not self.stop then
        self.x1 = self.x1 - 3
        self.x2 = self.x2 - 3
        if self.x2 + self.width <= width / self.scale_x then
            self.x1 = 0
            self.x2 = self.width
        end
    end
end

function Background:draw()
    love.graphics.scale(self.scale_x, self.scale_y)
    love.graphics.push()
    love.graphics.draw(self.image1, self.x1, 0)
    love.graphics.draw(self.image2, self.x2, 0)
    love.graphics.pop()
end