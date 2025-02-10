import pygame as pg


class Tube(pg.sprite.Sprite):
    def __init__(self, x_pos, y_pos):
        super().__init__()

        self.image = pg.image.load('images/tube.png')
        length = (12 - y_pos) * 32
        self.image = self.image.subsurface(0, 0, 64, length)

        self.rect = pg.Rect(x_pos*32, y_pos*32, 65, length)


    def render(self, game):
        game.screen.blit(self.image, game.get_map().get_camera().apply(self))