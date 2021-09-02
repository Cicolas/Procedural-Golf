--map creator 0=nothing 1=floor 2=wall 8=start 9=goal
local push = require("scripts.push")
local effects = require("effects")
require("UI")
require("phys")

local love = love

MAPWIDTH, MAPHEIGHT = 8, 8
GameWidth, GameHeight = 800, 600 --fixed game resolution
WindowWidth, WindowHeight = 1280, 720

Won = false

local UICanvas = love.graphics.newCanvas();
--mapTxt = love.filesystem.read("mapa.txt")
local mapTxt = ""
local char = ''

local mundo = love.physics.newWorld(0, 0, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
local walls = {}
local ball = CircObject(mundo, 400, 300, 5, "dynamic", 1)

local vx, vy = 0, 0
local mx, my = 0, 0
local ballGoX, ballGoY = 0, 0

local line = {}
local points = -1

local state = 3; --0 notihng; 1 menu; 2 playing; 3 waiting

function love.load(arg)
  push:setupScreen(GameWidth, GameHeight, WindowWidth, WindowHeight, {fullscreen = false, pixelperfect = false, resizable = true, stretched = false, mssa = 0})
  love.graphics.setFont(love.graphics.newFont("fonts/Lato-bold.ttf", 56))
 
  mundo:setCallbacks(CollisionOnEnter, CollisionOnEnd, CollisionOnStay, postSolve)
  ball.fixture:setUserData("ball")

  NextLevel()
  -- ShowWinUI(points)
  UILoad()

  --mapTxt = MapReader(mapTxt)

  UICanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end

function love.draw()
  --love.graphics.setColor({255/255, 228/255, 94/255})
  --love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.het)
  love.graphics.clear({255/255, 228/255, 94/255}, 0)

  if state == 3 or state == 2 then
    local x = 0
    local y = 0

    --UICANVAS ON PLAYING
    love.graphics.setCanvas(UICanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.print(points, 13, 3)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(points, 10, 0)
    love.graphics.setCanvas()
  
    love.graphics.push()
    push:start()
      love.graphics.clear({255/255, 228/255, 94/255}, 0)
  
      for key, value in pairs(walls) do
        love.graphics.setColor(value.color)
        value:draw()
      end
  
      love.graphics.setColor(1, 1, 1, 1)
  
      love.graphics.circle("fill", math.floor(ball.body:getX()), math.floor(ball.body:getY()), ball.shape:getRadius())
  
      --love.graphics.line(line)
  
      if love.mouse.isDown(1) and vx == 0 and vy == 0 then
        love.graphics.line(ball.body:getX(), ball.body:getY(), ballGoX, ballGoY)
      end
  
      -- effects.draw()
    push:finish() 
    love.graphics.pop()
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(UICanvas, 0, 0)

    if state == 3 then
      love.graphics.setCanvas(UICanvas)
      love.graphics.clear(0, 0, 0, 0)
      UIDraw(points+1)
      love.graphics.setCanvas()

      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(UICanvas, 0, 0)
    end
  end 
end

--gameplay

function love.update(dt)
  if state == 2 then
    local updatedMX, updatedMY = love.mouse.getPosition()

    table.insert(line,ball.body:getX())
    table.insert(line,ball.body:getY())

    mundo:update(dt)
    ballGoX = ball.body:getX()+(mx-updatedMX)
    ballGoY = ball.body:getY()+(my-updatedMY)

    vx, vy = ball.body:getLinearVelocity()

    if vx < 5 and vx > -5 and vy < 5 and vy > -5 then
      vx = 0
      vy = 0
      ball.body:setLinearVelocity(0, vy)
      ball.body:setLinearVelocity(vx, 0)
    end

    if not (vx == 0 and vy == 0) then
      ball.body:setLinearVelocity(vx*.975, vy*.975)
    end

    if Won and vx == 0 and vy == 0 then
      ShowWinUI()
    end
  end
 

  -- effects.update(dt)

  --print("vx: "..vx.." vy: "..vy)
end


function love.mousepressed(x, y, button, isTouch)
  if button == 1 then
    mx, my = love.mouse.getPosition()
    if state == 3 then
      NextLevel()
    end
    -- effects.burst("RedConfetti")
  end
end

function love.mousereleased(x, y, button, isTouch)
  if state == 2 then
    if button == 1 and vx == 0 and vy == 0 then
      local fx, fy = (mx-x)/(love.graphics.getWidth()/push:getWidth()), (my-y)/(love.graphics.getHeight()/push:getHeight())
      Release(math.atan2(my-y, mx-x), Normalize(fx, fy))
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "f1" then
    Won = true
  end
end

function love.resize(w, h)
  WindowWidth = w
  WindowHeight = h
  UIResize()
  return push:resize(w, h)
end

function Release (angle, force)
  print(force)
  if force > 200 then
    force = 200
  end
  ball.body:applyLinearImpulse(math.cos(angle)*force/3, math.sin(angle)*force/3)
end

function Sign (number)
  if number == math.abs(number) then
    return 1
 else
    return -1
 end
end

-- function Xor(a, b)
--   if a == true and b == true then
--     return false
--   elseif a == false and b == false then
--     return false
--   else
--     return true
--   end
-- end

function WriteInMap(x, y, w, a)
  local offset = ((y-1)*w)+(y-1)
  local before = mapTxt:sub(0, x+offset-1)
  local after = mapTxt:sub(x+offset+1)
  mapTxt = before..a..after
end

function GetInMap(x, y, w)
  local offset = ((y-1)*w)+(y-1)
  local char = mapTxt:sub(offset+x, offset+x)
  return char
end

function FillMap(width, heigth)
  for i = 2, heigth do
    for j = 2, width do
      local a, b, c, d = 0, 0, 0, 0

      if GetInMap(j+1, i, width) == "2" then
        a = 1
      end

      if GetInMap(j-1, i, width) == "2" then
        b = 1
      end

      if GetInMap(j, i+1, width) == "2" then
        c = 1
      end

      if GetInMap(j, i-1, width) == "2" then
        d = 1
      end 

      if a+b+c+d >= 3 then
        WriteInMap(j, i, width, "2")
      elseif a+b+c+d < 1 then
        WriteInMap(j, i, width, "1")
      end

      --print(a+b+c+d)
    end
  end
end

function Normalize (x, y)
  return (x^2+y^2)^.5
end

function MapReader (str)
  str = string.gsub(str, " ", "")
  print(str)

  for i=1, string.len(str) do
    char = string.sub(str, i, i)
    if char == '0' then
      io.write(" ")
    elseif char == '1' then
      io.write(".")
    elseif char == '2' then
      io.write("x")
    elseif char == '8' then
      io.write("s")
    elseif char == '9' then
      io.write("o")
    elseif char == ' ' or char == '\n' then
      io.write("\n")
    end
  end

  return str
end

function CreateRandMap(width, heigth)
  mapTxt = ""

  local m2 = 0
  m2 = (width+heigth)/2

  if m2 < 6 then
    return false
  end

  --size the map
  for i=1,heigth do
    for j=1,width do
      mapTxt = mapTxt.."1"
    end
    mapTxt = mapTxt.."\n"
  end

  --insert spawn and hole point (spawn)
  local startX = 0
  local startY = 0

  repeat
    startX = love.math.random(1, width)
    startY = love.math.random(1, heigth)
  until startX == 1 or startY == 1

  WriteInMap(startX, startY, width, "8")

  --insert spawn and hole point (hole)

  local finalX = 0
  local finalY = 0

  repeat
    finalX = love.math.random(1, width)
    finalY = love.math.random(1, heigth)
    --print(finalX.."\t"..finalY)
  until (startX-finalX)+(startY-finalY) < 1 and not (finalX == startX) and not (finalY == startY) and (finalX == width or finalY == heigth)

  WriteInMap(finalX, finalY, width, "9")

  for i = 1, heigth do
    for j = 1, width do
      if love.math.random() < 2.5/m2 and not (i == startY) and not (j == startX) and not (i == finalY) and not (j == finalX) then
          WriteInMap(j, i, width, "2")
      end
    end
  end

  local toAdd = ""

  for i = 1, width+1 do
    toAdd = toAdd.."2"
  end

  toAdd = toAdd.."\n"

  mapTxt = toAdd..mapTxt
  mapTxt = string.gsub(mapTxt, "\n", "2\n2")
  mapTxt = mapTxt..toAdd

  FillMap(width+2, heigth+2)

  local s2 = 0
  local f2 = 0

  s2 = math.abs(startX-finalX)
  f2 = math.abs(startY-finalY)

  if Normalize(s2, f2) < m2+1 then
    CreateRandMap(width, heigth)
  end

  return true

  --print(mapTxt)
end

function SetInWorld(width, heigth)
  local initialX = GameWidth/2-(width*32/2)-16
  local initialY = GameHeight/2-(heigth*32/2)-16

  local o = o

  local x = initialX
  local y = initialY

  for i=1, string.len(mapTxt) do
    o = RectObject(mundo, x, y, 32, 32, "static", 1)

    char = string.sub(mapTxt, i, i)
    if char == '0' then
      o.color = {0, 0, 0, 1}
      x = x + 32
    elseif char == '1' then
      o.body:setActive(false)
      o.color = {58/255, 242/255, 89/255, 1}
      x = x + 32
    elseif char == '2' then
      o.color = {63/255, 70/255, 110/255, 1}
      o.fixture:setUserData("wall")
      x = x + 32
    elseif char == '8' then
      o.fixture:setSensor(true)
      o.color = {39/255, 186/255, 64/255, 1}
      o.fixture:setUserData("start")
      x = x + 32
    elseif char == '9' then
      o.fixture:setSensor(true)
      o.color = {179/255, 63/255, 50/255, 1}
      o.fixture:setUserData("final")
      x = x + 32
    elseif char == ' ' or char == '\n' then
      y = y + 32
      x = initialX
    end

    table.insert(walls, o)
  end
end

function CerterBall()
  for key, value in pairs(walls) do
    if value.fixture:getUserData() == "start" then
      ball.body:setPosition(value.body:getX(), value.body:getY())
    end
  end
end

function NextLevel()
  state = 2

  for i = 1, #walls do
    walls[i].body:destroy()
  end

  walls = {}

  CreateRandMap(MAPWIDTH, MAPHEIGHT)
  SetInWorld(MAPWIDTH, MAPHEIGHT)
  CerterBall()

  Won = false

  points = points+1
end

function ShowWinUI()
  state = 3
end