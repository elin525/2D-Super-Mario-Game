import pygame as pg 

class Flag:
    def __init__(self, x_pos, y_pos):
        self.flag_down = False
        self.offset = 0
        
        # load pole image
        self.pole_image = pg.image.load('images/flag_pillar.png').convert_alpha()
        self.flag_image = pg.image.load('images/flag.png').convert_alpha()
        
        # set initial position of flag and pole
        self.pole_rect = pg.Rect(x_pos, y_pos, 16, 400)
        self.flag_rect = pg.Rect(x_pos, y_pos, 32, 32)
        
    def handle_events(self, event):
        if event.type == pg.MOUSEBUTTONDOWN:
            # check if user clicked on the flag
            if self.flag_rect.collidepoint(event.pos):
                self.flag_down = True
    
    def  update(self):
        # move flag down with pole when flag is held down
        self.offset += 5
        self.flag.rect.y += 5
            
        # raise flag back up after it has been lowered
        if self.offset > 300:
            self.flag_down = True
            self.offset = 0
                
    def render(self, game):
        game.screen.blit(self.pole_image, game.get_map().get_camera().apply(self))
        game.screen.blit(self.flag_image, game.get_map().get_camera().apply(self))