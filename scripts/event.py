import pygame as pg

from constants import *


class Event(object):
    def __init__(self):

        # 0 = Kill/Game Over
        # 1 = Win (using flag)
        self.type = 0

        self.delay = 0
        self.time = 0
        self.x_vel = 0
        self.y_vel = 0
        self.game_over = False

        self.player_in_castle = False
        self.tick = 0
        self.score_tick = 0

    def reset(self):
        self.type = 0

        self.delay = 0
        self.time = 0
        self.x_vel = 0
        self.y_vel = 0
        self.game_over = False

        self.player_in_castle = False
        self.tick = 0
        self.score_tick = 0

    def start_kill(self, core, game_over):
        """

        Player gets killed.

        """
        self.type = 0
        self.delay = 4000
        self.y_vel = -4
        self.time = pg.time.get_ticks()
        self.game_over = game_over


        # Sets "dead" sprite
        core.get_map().get_mario().set_image(len(core.get_map().get_mario().sprites))

    def start_win(self, game):
        """

        player touches the flag.

        """
        self.type = 1
        self.delay = 2000
        self.time = 0

        game.get_map().get_player().set_image(5)
        game.get_map().get_player().x_vel = 1
        game.get_map().get_player().rect.x += 10

        
    def update(self, game):

        # Death
        if self.type == 0:
            self.y_vel += GRAVITY * FALL_MULTIPLIER if self.y_vel < 6 else 0
            game.get_map().get_player().rect.y += self.y_vel


        # Flag win
        elif self.type == 1:

            if not self.player_in_castle:

                if not game.get_map().flag.flag_omitted:
                    game.get_map().get_player().set_image(5)
                    game.get_map().flag.move_flag_down()
                    game.get_map().get_player().flag_animation_move(game, False)

                else:
                    self.tick += 1
                    if self.tick == 1:
                        game.get_map().get_player().direction = False
                        game.get_map().get_player().set_image(6)
                        game.get_map().get_player().rect.x += 20
                    elif self.tick >= 30:
                        game.get_map().get_player().flag_animation_move(game, True)
                        game.get_map().get_player().update_image(game)

            