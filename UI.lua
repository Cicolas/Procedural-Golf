local top = 0
local left = 0
local width = 0
local height = 0

UILoad = function ()
    UIResize()
end

UIDraw = function(Level, plays, time)
    love.graphics.setColor(0, 0, 0, .75)
    love.graphics.rectangle("fill", left, top, width, height)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Level "..Level.." Complete!!!", 
    left, top+50,
    width*2,
    "center",
    0,
    .5, .5
    )
    
    --stats
    love.graphics.printf("Time:", 
    left+30, top+(height/2)-30,
    width*2.5,
    "left",
    0,
    .4, .4
    )
    love.graphics.printf("Plays:", 
    left+30, top+(height/2),
    width*2.5,
    "left",
    0,
    .4, .4
    )

    --values
    love.graphics.printf(string.format( "%.2f", time).." s", 
    left-30, top+(height/2)-30,
    width*2.5,
    "right",
    0,
    .4, .4
    )
    love.graphics.printf(plays, 
    left-30, top+(height/2),
    width*2.5,
    "right",
    0,
    .4, .4
    )

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Press to continue", 
    left, top+height-80,
    width*3.33333,
    "center",
    0,
    .3, .3
    )
end

UIResize = function()
    width = WindowWidth/4
    height = WindowHeight/1.5
    top = WindowHeight/2-height/2
    left = WindowWidth/2-width/2
end