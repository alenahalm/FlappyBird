require "vector"
require "mover"
require "column"
require "background"

function love.load()
    love.window.setTitle("Flappy Bird")
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    -- game state
    gaming = false
    menu = true
    gameover = false
    
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
    background.stop = not gaming
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
    if stop and mover.location.y > height then
        gaming = false
        menu = false
        gameover = true
    end

    background:update()
end

function love.draw()

    if gaming then
        background:draw()
        mover:draw()


        for i = 0, column_counter do
            columns[i]:draw()
        end
        mover:draw()
        love.graphics.setFont(love.graphics.newFont("font/font.ttf", 50))
        love.graphics.print("Score: "..score, 100, 50)
        love.graphics.print("Best score: "..best_score, width-330, 50)
    elseif menu then
        bg = love.graphics.newImage("images/menu.png")
        love.graphics.draw(bg, 0, 0)
        font = love.graphics.newFont("font/font.ttf", 120)
        love.graphics.setFont(font)
        txt = "Flappy Bird"
        love.graphics.print(txt, width/2 - font:getWidth(txt)/2, 250)
        font = love.graphics.newFont("font/font.ttf", 60)
        love.graphics.setFont(font)
        txt = "Начать игру"
        love.graphics.print(txt, width/2 - font:getWidth(txt)/2, 550)
        txt = "Выход"
        love.graphics.print(txt, width/2 - font:getWidth(txt)/2, 650)
    elseif gameover then
        background:draw()
        rect = love.graphics.newImage("images/gameover_block.png")
        love.graphics.draw(rect, width/2 - rect:getWidth()/2, height/2 - rect:getHeight()/2)
        font = love.graphics.newFont("font/font.ttf", 80)
        love.graphics.setFont(font)
        txt = "Вы погибли"
        love.graphics.print(txt, width/2 - font:getWidth(txt)/2, 230)
        font = love.graphics.newFont("font/font.ttf", 70)
        love.graphics.setFont(font)
        txt = "Ваш счет"
        love.graphics.print(txt, width/4 - font:getWidth(txt)/2+100, 350)
        txt = "Рекорд"
        love.graphics.print(txt, width*0.75 - font:getWidth(txt)/2-100, 350)
        font = love.graphics.newFont("font/font.ttf", 110)
        love.graphics.setFont(font)
        txt = score
        love.graphics.print(txt, width/4 - font:getWidth(txt)/2+100, 470)
        txt = best_score
        love.graphics.print(txt, width*0.75 - font:getWidth(txt)/2-100, 470)
        rep = love.graphics.newImage("images/replay.png")
        close = love.graphics.newImage("images/close.png")
        love.graphics.draw(rep, width/4 - rep:getWidth()/2+100, 700)
        love.graphics.draw(close, width*0.75 - close:getWidth()/2-100, 700)
    end
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

function love.mousepressed(x, y, button)
    if button == 1 then
        if menu then
            if x > (width/2 - font:getWidth("Начать игру")/2) and 
                x < (width/2 + font:getWidth("Начать игру")/2) and
                y > 530 and y < font:getHeight("Начать игру") + 530 then
                gaming = true
                menu = false
                gameover = false
            end
            if x > (width/2 - font:getWidth("Выход")/2) and 
                x < (width/2 + font:getWidth("Выход")/2) and
                y > 650 and y < font:getHeight("Выход") + 650 then
                love.event.quit()
            end
        elseif gameover then
            if x > (width/4 - rep:getWidth()/2+100) and 
                x < (width/4 + rep:getWidth()/2+100) and
                y > 700 and y < rep:getHeight() + 700 then
                    gaming = true
                    menu = false
                    gameover = false
                    stop = true
                    fall = false
                    mover:restart()
                    score = 0
                    for i = 0, column_counter do
                        columns[i] = Column:create(800 + 550 * i)
                    end
            end
            if x > (width*0.75 - close:getWidth()/2-100) and 
                x < (width*0.75 + close:getWidth()/2-100) and
                y > 700 and y < close:getHeight() + 700 then
                    gaming = false
                    menu = true
                    gameover = false
            end
            mover:restart()
        end
    end
end

function love.keypressed(key)
    if key == 'escape' and menu then
        love.event.quit()
    end
    if key == "escape" and gaming then
        menu = true
        gaming = false
    end
    if fall then
        return
    end
    if not gameover and (key == "w" or key == "space") then
        make_jump()
    end
    
    if stop and (key == "w" or key == "space") then
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