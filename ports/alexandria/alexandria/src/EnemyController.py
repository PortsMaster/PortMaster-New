class EnemyController(object):
    def __init__(self, game):
        self.game = game

    def run_enemies(self):
        for e in self.game.combatants+self.game.bullets:
            e.ai.run(e, self.game)

        for e in self.game.bullets:
            if isinstance(e.ttl, int):
                if e.ttl <= 0:
                    e.expire(self.game)
                else:
                    e.ttl -= 1
                

    def thread(self):
        while True:
            yield None
            if not self.game.paused:
                self.run_enemies()
