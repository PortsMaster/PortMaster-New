-- Trigger functions for the different weapons.
local weapons = {
    knife = function(self)
        local level = self:getLevel()
        local entity = jvgslua.Entity("resources/knife/knife.xml", level)

        local velocity = jvgslua.Vector2D_fromPolar(entity:getSpeed(), math.random() * 20 - 10)

        if not self:isFacingRight() then
            velocity:setX(-velocity:getX())
        end

        entity:setPosition(self:getPosition())
        entity:setVelocity(velocity)
        level:addEntity(entity)
        self:setTimer(2000)

        local am = jvgslua.AudioManager_getInstance()
        am:playSound("resources/knife/throw.ogg")
    end,

    clock = function(self)
        local em = jvgslua.EffectManager_getInstance()
        local te = jvgslua.TimeEffect(0.2, 3000)
        em:addEffect(te)
        self:setTimer(3000)
    end,

    hat = function(self)
        local velocity = jvgslua.Vector2D(0.0, -1.0) * self:getSpeed() * 2
        self:setVelocity(velocity)
        self:setTimer(500)
        local pos = jvgslua.Vector2D(self:getPosition():getX(),
                self:getPosition():getY() + self:getRadius():getY())
        effects.stars(pos, 0.5, {"star"})
    end,

    grenade = function(self)
        local level = self:getLevel()
        local entity = jvgslua.Entity("resources/grenade/grenade.xml", level)

        local velocity = jvgslua.Vector2D_fromPolar(entity:getSpeed(), -math.random() * 45)

        if not self:isFacingRight() then
            velocity:setX(-velocity:getX())
        end

        entity:setPosition(self:getPosition())
        entity:setVelocity(velocity)
        level:addEntity(entity)
        self:setTimer(4000)
    end
}

events.trigger{
    spawn = function(self, event)
        self:setBool("ready", true)
    end,

    die = function(self, event)
        common.gameOver()
    end,

    action = function(self, event)
        print(string.format("<point x=\"%.0f\" y=\"%.0f\" \/>",
                self:getPosition():getX(), self:getPosition():getY()))

        if self:isSet("weapon") and self:getBool("ready") then
            local weapon = self:get("weapon")
            if weapons[weapon] then weapons[weapon](self) end
            self:setBool("ready", false)
            local sprite = jvgslua.Sprite("resources/player/regular-sprite.xml")
            self:setSprite(sprite)
        end
    end,

    timer = function(self, event)
        if common.isDead(self) then
            -- Falling sequence limit reached.
            common.gameOver()
        else
            if self:isSet("weapon") then
                local sprite = jvgslua.Sprite("resources/player/" ..
                        self:get("weapon") .. "-sprite.xml")
                self:setSprite(sprite)
            end

            self:setBool("ready", true)
        end
    end,

    property = function(self, event)
        if event:getKey() == "health" and common.isDead(self) then
            effects.commonDie(self)
            local em = jvgslua.EffectManager_getInstance()
            local effect = jvgslua.InvertEffect()
            em:addEffect(effect)
            local lm = jvgslua.LevelManager_getInstance()
            lm:setTimeFactor(0.2)
            -- Limit falling sequence.
            self:setTimer(1000)
        end
    end
}
