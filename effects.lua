require("scripts.class")

local confetti = require("effects.RedConfetti")
RedConfetti = confetti()

return {
    update = function (dt)
        if RedConfetti:getBufferSize() <= RedConfetti:getCount() then
            RedConfetti:stop()
        end

        RedConfetti:update(dt)
    end,

    draw = function ()
        love.graphics.draw(RedConfetti, 0, 0, 0, 10, 10)
    end,

    burst = function (name)
        if name == "RedConfetti" then
            RedConfetti.start(RedConfetti)
        end
    end
}
