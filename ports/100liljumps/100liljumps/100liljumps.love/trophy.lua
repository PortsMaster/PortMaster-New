local Object = require("./classic")

Trophy = Object.extend(Object)

Trophy.animation = Animation({
    {filename = "trophy-sheet.png", duration = 12*18},
})

Trophy.key_to_completed_flag = {
    cave_challenge = "caves_challenge_completed",
    temple_challenge = "temple_challenge_completed",
    jungle_challenge = "jungle_challenge_completed",
    puzzle_challenge = "puzzle_challenge_completed",
}

function Trophy.new(self, pos, key)
    self.pos = V2(pos.x, pos.y)
    self.key = key
end

function Trophy:update(dt)
    self.animation:advance_step()
end

function Trophy:draw()
    local challenge_completed_flag_key = Trophy.key_to_completed_flag[self.key]
    local trophy_unlocked = game_state[challenge_completed_flag_key]

    if trophy_unlocked then
        self.animation:draw(self.pos.x, self.pos.y)
    end
end