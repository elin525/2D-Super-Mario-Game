import pygame as pg


class BGObject(object):
    def __init__(self, x, y, image):
        self.rect = pg.Rect(x, y, 32, 32)
        self.image = image
        self.type = 'BGObject'

    def render(self, game):
        game.screen.blit(self.image, game.get_map().get_camera().apply(self))