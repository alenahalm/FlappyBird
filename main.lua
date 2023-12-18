require "vector"
require "mover"
require "column"
require "background"

function love.load()
    love.window.setTitle("Flappy Bird")
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    best_score = tonumber((love.filesystem.read("score.txt"))) or 0
    
    background = Background:create('images/background.png')

    mover = Mover:create(Vector:create(width/4, height*0.6), Vector:create(0, 0), 5)
    gravity = Vector:create(0, 0.1)
    jump = Vector:create(0, -5)
    
    to_jump = false
    count_jumps = 0

    columns = {}
    column_counter = 5
    for i = 0, column_counter do
        columns[i] = Column:create(800 + 550 * i)
    end

    stop = true

    fall = false

    score = 0
    cur_column = 0
end

function love.update(dt)
    if to_jump then
        mover:apply_force(jump)
        jump = jump + gravity
        if jump.y <= 0 then
            to_jump = false
        end
    else
        if not stop or fall then
            mover:apply_force(gravity)
        end
        if fall then
            background.stop = true
        end
    end
    if mover:check_boundaries(background.scale_y) then
        background.stop = true
        for i = 0, column_counter do
            columns[i]:stop()
            stop = true
        end
    end
    mover:update()
    for i = 0, column_counter do
        columns[i]:update(columns[farthest_column()])
    end
    index = nearest_column()
    if index ~= cur_column and not stop then
        score = score + 1
        cur_column = nearest_column()
    end

    background:update()
end

function love.draw()

    background:draw()
    mover:draw()

    if columns[nearest_column()]:check_collision(mover) then
        fall = true
        if score > best_score then
            suc, mes = love.filesystem.write("score.txt", tostring(score))
        end
        if not stop then
            make_jump()
        end
        for i = 0, column_counter do
            columns[i]:stop()
        end
        stop = true
    end
    for i = 0, column_counter do
        columns[i]:draw()
    end
    mover:draw()
    love.graphics.setFont(love.graphics.newFont("font/font.ttf", 50))
    love.graphics.print("Score: "..score, 100, 50)
    love.graphics.print("Best score: "..best_score, width-200, 50)
    -- love.graphics.print("FPS = "..tostring(love.timer.getFPS()), 400, 50)
    -- love.graphics.print(tostring(background.stop), 700, 50)
end

function nearest_column()
    value = width
    ind = 5
    for i = 0, column_counter do
        if columns[i].gap.x < value and mover.location.x < columns[i].gap.x + columns[i].width then
            value = columns[i].gap.x
            ind = i
        end
    end
    return ind
end

function farthest_column()
    value = 0
    ind = column_counter-1
    for i = 0, column_counter do
        if columns[i].gap.x > value then
            value = columns[i].gap.x
            ind = i
        end
    end
    return ind
end

function love.keypressed(key)
    if key == "r" then
        best_score = tonumber((love.filesystem.read("score.txt"))) or 0
        stop = true
        fall = false
        mover:restart()
        score = 0
        for i = 0, column_counter do
            columns[i] = Column:create(800 + 550 * i)
        end
    end
    if key == 'escape' then
        love.event.quit()
    end
    if fall then
        return
    end
    if not stop and key == "w" then
        make_jump()
    end
    
    if key == "b" then
        background.stop = not background.stop
    end
    if key == "p" then
        count_jumps = 0
        stop = not stop
        if stop then
            mover:stop()
        end
        for i = 0, column_counter do
            columns[i].is_drawing = not columns[i].is_drawing
        end
    end

end

function make_jump()
    to_jump = true
    jump.x = 0
    jump.y = -2
    mover.velocity.y = 0
    mover.is_jumping = true
end