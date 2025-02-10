import pygame as pg
from constants import *

class Block(object):
    def __init__(self, x, y, image):
        self.image = image
        self.piece_image = pg.image.load('images/block_debris0.png').convert_alpha()
        self.rect = pg.Rect(x, y, 32, 32)
        self.image_tick = 0
        self.current_image = 0
        self.type = 'BGOject'

        self.triggered = True
        self.shaking = True
        self.shakingUp = True
        self.shakingOffset = 0
        
    def question_animation(self):
        if QUESTION:
            self.image_tick += 1
            if  self.image_tick == 50:
                self.current_image =1
            elif self.image_tick == 60:
                self.current_image = 2
            elif self.image_tick == 70:
                self.current_image = 3
            elif self.image_tick == 80:
                self.current_image = 0
                
    def shake(self):
        offset_change = 0
        if self.shaking:
            offset_change = -2 if self.shakingUp else 2
            self.shakingOffset += offset_change
            self.rect.y += offset_change

        if self.shakingOffset <= -20 or self.shakingOffset >= 20:
            self.shakingUp = False  # Reverse the direction

        if self.shakingOffset == 0 and not self.shakingUp:
            self.shaking = False 
            self.shakingUp = False # Reset values for next time
            
    def brick_piece(self):
        pass
        
            
    def render(self, game):
        # Question block
        if QUESTION:
            if not self.triggered:
                self.question_animation()
            elif not self.shaking:
                self.shake()
            game.screen.blit(self.image[self.current_image], game.get_map().get_camera().apply(self))

        # Brick block
        elif BRICK and self.shaking:
            self.shake()
            game.screen.blit(self.image, game.get_map().get_camera().apply(self))

        else:
            game.screen.blit(self.image, game.get_map().get_camera().apply(self))
                
        