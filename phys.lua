require("scripts.class")

local love = love

persisting = 0

RectObject = class(function(a, world, x, y, w, h, type, bounciness, friction, sensor)
  a.body = love.physics.newBody(world, x, y, type)
  a.shape = love.physics.newRectangleShape(w, h)
  a.fixture = love.physics.newFixture(a.body, a.shape)
  a.fixture:setRestitution(bounciness or 0)
  a.fixture:setFriction(friction or 0)
  a.fixture:isSensor(sensor or false)
  a.color = {0, 0, 0, 0}
end)

function RectObject:draw ()
  love.graphics.polygon("fill", self.body:getWorldPoints(
                                self.shape:getPoints()))
end

CircObject = class(function(a, world, x, y, radius, type, bounciness, friction, sensor)
  a.body = love.physics.newBody(world, x, y, type)
  a.shape = love.physics.newCircleShape(radius)
  a.fixture = love.physics.newFixture(a.body, a.shape)
  a.fixture:setRestitution(bounciness or 0)
  a.fixture:setFriction(friction or 0)
  a.fixture:isSensor(sensor or false)
  a.color = {0, 0, 0, 0}
end)

function CircObject:draw ()
  love.graphics.circle("fill", self.body:getX(),
                       self.body:getY(), self.shape:getRadius())
end

function Detect(t, name1, name2)
  for i,v in ipairs(t) do
    local fs1, fs2 = v:getFixtures()
    if fs1:getUserData() == name1 and fs2:getUserData() == name2 or fs1:getUserData() == name2 and fs2:getUserData() == name1 then
      return true
    end
  end
end

--callbacks

function CollisionOnEnter(a, b, coll)
  local x,y = coll:getNormal()
  --print("\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of: "..x..", "..y)

  if a:getUserData() == "final" then
    Won = true
  end
end

function CollisionOnEnd(a, b, coll)
  persisting = 0
  --print("\n"..a:getUserData().." uncolliding with "..b:getUserData())

  if a:getUserData() == "final" then
    Won = false
  end
end

function CollisionOnStay(a, b, coll)
  persisting = persisting + 1    -- keep track of how many updates they've been touching for
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end