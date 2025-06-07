# Entire Code is written by Github Copilot, all thanks to it, because im shitty at coding, especially in python
import pyxel
import json
import os
import random

class Card:
    def __init__(self, suit, rank):
        self.suit = suit
        self.rank = rank

    def value(self):
        if self.rank in ['J', 'Q', 'K']:
            return 10
        elif self.rank == 'A':
            return 11  # Ace can be 1 or 11, handled in hand value calculation
        else:
            return int(self.rank)

class Deck:
    def __init__(self):
        self.cards = [Card(suit, rank) for suit in ['Hearts', 'Diamonds', 'Clubs', 'Spades']
                      for rank in ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']]
        random.shuffle(self.cards)

    def draw(self):
        return self.cards.pop() if self.cards else None

class Hand:
    def __init__(self):
        self.cards = []

    def add_card(self, card):
        self.cards.append(card)

    def value(self):
        total = sum(card.value() for card in self.cards)
        aces = sum(1 for card in self.cards if card.rank == 'A')
        while total > 21 and aces:
            total -= 10
            aces -= 1
        return total

class Blackjack:
    def __init__(self):
        self.deck = Deck()
        self.player_hand = Hand()
        self.dealer_hand = Hand()
        self.money = 100
        self.bet = 10
        self.game_state = "MENU"  # MENU, RULES, BETTING, PLAYER, DEALER, RESULT
        self.menu_selected = 0  # 0 = Play, 1 = Rules
        self.selected_action = 0  # 0 = Hit, 1 = Stand
        self.result = ""
        self.load_game()

    def start_game(self):
        self.deck = Deck()
        self.player_hand = Hand()
        self.dealer_hand = Hand()
        self.player_hand.add_card(self.deck.draw())
        self.player_hand.add_card(self.deck.draw())
        self.dealer_hand.add_card(self.deck.draw())
        self.dealer_hand.add_card(self.deck.draw())
        self.game_state = "PLAYER"
        self.selected_action = 0
        self.result = ""

    # Always save after money/bet changes
    def player_bet(self, amount):
        if 0 < amount <= self.money:
            self.bet = amount
            self.save_game()

    def player_hit(self):
        self.player_hand.add_card(self.deck.draw())
        if self.player_hand.value() > 21:
            self.result = "Bust! You lose."
            self.money -= self.bet
            self.game_state = "RESULT"

    def player_stand(self):
        self.game_state = "DEALER"

    def dealer_play(self):
        while self.dealer_hand.value() < 17:
            self.dealer_hand.add_card(self.deck.draw())
        self.resolve_game()

    def resolve_game(self):
        player_val = self.player_hand.value()
        dealer_val = self.dealer_hand.value()
        if player_val > 21:
            self.result = "Bust! You lose."
            self.money -= self.bet
        elif dealer_val > 21:
            self.result = "Dealer busts! You win!"
            self.money += self.bet
        elif player_val == 21 and len(self.player_hand.cards) == 2:
            if dealer_val == 21 and len(self.dealer_hand.cards) == 2:
                self.result = "Both Blackjack! Push."
            else:
                self.result = "Blackjack! You win!"
                self.money += int(1.5 * self.bet)
        elif dealer_val == 21 and len(self.dealer_hand.cards) == 2:
            self.result = "Dealer Blackjack! You lose."
            self.money -= self.bet
        elif player_val > dealer_val:
            self.result = "You win!"
            self.money += self.bet
        elif player_val < dealer_val:
            self.result = "You lose."
            self.money -= self.bet
        else:
            self.result = "Push (draw)."
        self.save_game()
        self.game_state = "RESULT"

    def save_game(self):
        with open('save.json', 'w') as f:
            json.dump({'money': self.money}, f)

    def load_game(self):
        if os.path.exists('save.json'):
            with open('save.json', 'r') as f:
                data = json.load(f)
                self.money = data.get('money', 100)

    def update(self):
        if self.game_state == "MENU":
            if pyxel.btnp(pyxel.KEY_UP) or pyxel.btnp(pyxel.KEY_DOWN):
                self.menu_selected = 1 - self.menu_selected
            if pyxel.btnp(pyxel.KEY_A):
                if self.menu_selected == 0:
                    self.game_state = "BETTING"
                else:
                    self.game_state = "RULES"
        elif self.game_state == "RULES":
            if pyxel.btnp(pyxel.KEY_A) or pyxel.btnp(pyxel.KEY_ESCAPE):
                self.game_state = "MENU"
        elif self.game_state == "BETTING":
            if pyxel.btnp(pyxel.KEY_UP):
                self.player_bet(min(self.money, self.bet + 10))
            elif pyxel.btnp(pyxel.KEY_DOWN):
                self.player_bet(max(10, self.bet - 10))
            elif pyxel.btnp(pyxel.KEY_A):
                if self.bet > 0:
                    self.start_game()
        elif self.game_state == "PLAYER":
            if pyxel.btnp(pyxel.KEY_LEFT) or pyxel.btnp(pyxel.KEY_RIGHT):
                self.selected_action = 1 - self.selected_action
            elif pyxel.btnp(pyxel.KEY_A):
                if self.selected_action == 0:
                    self.player_hit()
                else:
                    self.player_stand()
        elif self.game_state == "DEALER":
            self.dealer_play()
        elif self.game_state == "RESULT":
            if pyxel.btnp(pyxel.KEY_A):
                if self.money <= 0:
                    self.money = 100
                self.game_state = "BETTING"

    def draw_card(self, card, x, y, hidden=False):
        # Smaller card: 20x26
        pyxel.rect(x+1, y+1, 18, 24, 6 if not hidden else 5)
        pyxel.rectb(x, y, 20, 26, 0)
        if hidden:
            pyxel.text(x + 6, y + 10, "??", 8)
        else:
            suit_colors = {'H': 8, 'D': 10, 'C': 3, 'S': 13}
            suit = card.suit[0]
            color = suit_colors.get(suit, 0)
            pyxel.text(x + 2, y + 2, f"{card.rank}", 0)
            pyxel.text(x + 12, y + 2, f"{suit}", color)
            pyxel.text(x + 7, y + 16, f"{suit}", color)

    def draw_hand(self, hand, y, hide_first=False):
        n = len(hand.cards)
        card_width = 20
        spacing = 4
        total_width = n * card_width + (n - 1) * spacing
        start_x = (160 - total_width) // 2
        for i, card in enumerate(hand.cards):
            x = start_x + i * (card_width + spacing)
            if hide_first and i == 0:
                self.draw_card(card, x, y, hidden=True)
            else:
                self.draw_card(card, x, y)

    def draw_pokerchip(self):
        # Center of the screen
        cx, cy = 80, 60
        # Outer ring
        pyxel.circ(cx, cy, 48, 8)
        # White ring
        pyxel.circ(cx, cy, 40, 7)
        # Red ring
        pyxel.circ(cx, cy, 32, 8)
        # Inner white
        pyxel.circ(cx, cy, 24, 7)
        # Center
        pyxel.circ(cx, cy, 16, 0)
        # Pokerchip stripes
        for i in range(12):
            angle = i * 30
            x1 = int(cx + 44 * pyxel.cos(angle))
            y1 = int(cy + 44 * pyxel.sin(angle))
            x2 = int(cx + 36 * pyxel.cos(angle))
            y2 = int(cy + 36 * pyxel.sin(angle))
            pyxel.line(x1, y1, x2, y2, 10)

    def draw(self):
        pyxel.cls(1)

        # Big, centered casino-style title at the upper middle
        title = "PyxelJACK"
        x_title = (160 - len(title) * 4) // 2  # 4 pixels per character
        y_title = 4  # Move up!
        # Shadow
        pyxel.text(x_title + 2, y_title + 2, title, 0)
        # Main
        pyxel.text(x_title, y_title, title, 10)

        if self.game_state == "MENU":
            # Centered menu options, lower on the screen
            opts = ["Play", "Rules"]
            menu_y = 40
            for i, opt in enumerate(opts):
                color = 11 if i == self.menu_selected else 5
                box_w = 60
                box_h = 18
                box_x = (160 - box_w) // 2
                box_y = menu_y + i * (box_h + 8)
                pyxel.rectb(box_x, box_y, box_w, box_h, color)
                pyxel.text(box_x + (box_w - len(opt)*4)//2, box_y + 5, opt, color)
            pyxel.text(16, 100, "Use UP/DOWN and (A) to select", 13)
        elif self.game_state == "RULES":
            pyxel.rect(10, 20, 140, 80, 0)
            pyxel.rectb(10, 20, 140, 80, 10)
            rules = [
                "Blackjack Rules:",
                "- Get closer to 21 than dealer.",
                "- Aces are 1 or 11.",
                "- Face cards are 10.",
                "- Blackjack (A+10) pays 3:2.",
                "- Dealer stands on 17+.",
                "",
                "",
                "Press (A) to return."
            ]
            for i, line in enumerate(rules):
                pyxel.text(18, 28 + i * 10, line, 7)
        elif self.game_state == "BETTING":
            box_w, box_h = 90, 50
            box_x = (160 - box_w) // 2
            box_y = 30
            pyxel.rect(box_x, box_y, box_w, box_h, 0)
            pyxel.rectb(box_x, box_y, box_w, box_h, 10)
            pyxel.text(box_x + 18, box_y + 6, "PLACE YOUR BET", 11)
            bet_str = f"{self.bet}"
            pyxel.text(box_x + (box_w - len(bet_str)*4)//2, box_y + 20, bet_str, 7)
            pyxel.text(box_x + 12, box_y + 32, "UP/DOWN to change", 13)
            if (pyxel.frame_count // 15) % 2 == 0:
                pyxel.text(box_x + 8, box_y + 40, "Press (A) to deal!", 10)
            # Money counter at bottom center (no black line)
            money_str = f"Money: {self.money}"
            pyxel.text((160 - len(money_str) * 4) // 2, 114, money_str, 11)
        else:
            # Dealer
            pyxel.text(10, 20, "Dealer:", 7)
            if self.game_state == "PLAYER":
                self.draw_hand(self.dealer_hand, 30, hide_first=True)
            else:
                self.draw_hand(self.dealer_hand, 30)
            # Player
            pyxel.text(10, 60, "You:", 7)
            self.draw_hand(self.player_hand, 70)
            # Actions
            if self.game_state == "PLAYER":
                actions = ["[Hit]", "[Stand]"]
                for i, act in enumerate(actions):
                    color = 11 if i == self.selected_action else 5
                    pyxel.text(50 + i * 40, 100, act, color)
            if self.game_state == "RESULT":
                pyxel.text(10, 95, self.result, 8)
                pyxel.text(10, 105, "Press (A) for next round", 7)
            # Money counter at bottom center (no black line)
            money_str = f"Money: {self.money}"
            pyxel.text((160 - len(money_str) * 4) // 2, 114, money_str, 11)

def main():
    pyxel.init(160, 120, title="Pyxeljack")
    game = Blackjack()
    pyxel.run(game.update, game.draw)

if __name__ == "__main__":
    main()