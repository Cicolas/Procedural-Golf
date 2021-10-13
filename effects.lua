require("scripts.class")

local r = require("effects.RedConfetti")
local g = require("effects.GreenConfetti")
local b = require("effects.BlueConfetti")
RedConfetti = r()
GreenConfetti = g()
BlueConfetti = b()
RedConfetti:stop()
GreenConfetti:stop()
BlueConfetti:stop()

return {
    update = function (dt)
        if RedConfetti:getBufferSize() <= RedConfetti:getCount() then
            RedConfetti:stop()
        end
        if GreenConfetti:getBufferSize() <= GreenConfetti:getCount() then
            GreenConfetti:stop()
        end
        if BlueConfetti:getBufferSize() <= BlueConfetti:getCount() then
            BlueConfetti:stop()
        end

        RedConfetti:update(dt)
        GreenConfetti:update(dt)
        BlueConfetti:update(dt)
    end,

    draw = function ()
        love.graphics.draw(RedConfetti, 0, 0, 0, 10, 10)
        love.graphics.draw(GreenConfetti, 0, 0, 0, 10, 10)
        love.graphics.draw(BlueConfetti, 0, 0, 0, 10, 10)
    end,

    burst = function (name)
        if name == "RedConfetti" then
            RedConfetti.start(RedConfetti)
        end
        if name == "GreenConfetti" then
            GreenConfetti.start(GreenConfetti)
        end
        if name == "BlueConfetti" then
            BlueConfetti.start(BlueConfetti)
        end
    end
}
