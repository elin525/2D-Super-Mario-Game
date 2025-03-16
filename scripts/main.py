from os import environ
import pygame as pg
import sys
from pygame.locals import *
from constants import *
from world import Map
from tube import Tube
from sound import Sound


class LaunchScreen:
    def __init__(self, game):
        self.game = game
        self.screen = game.screen
        self.text_color1 = GREEN
        self.text_color2 = WHITE
        self.bg_color = BLACK
        self.sound = Sound()
        #self.show = Dashboard(game)


        # Characters data
        self.names = ['Goombas', 'Koopa', 'Mushroom', 'Flower']
        self.points = [100, 150, 500, 1000]
        self.images = [pg.image.load('images/goombas_0.png').convert_alpha(),
                       pg.image.load('images/koopa_0.png').convert_alpha(),
                       pg.image.load('images/mushroom.png').convert_alpha(),
                       pg.image.load('images/flower_0.png').convert_alpha()]
        self.title_image = pg.image.load('images/super_mario_bros.png')

    def show_high_score(self):
        self.show.prep_high_score()
        # Clear the screen or set up the background for the high score display
        self.screen.fill((130, 130, 130))
        # Draw the high score
        self.show.high_score_rect = pg.Rect(self.settings.screen_width / 2 - 60, self.settings.screen_height / 2 - 30, 200, 50)
        self.screen.blit(self.show.high_score_image, self.show.high_score_rect)
        pg.display.flip()  # Update the display


    def check_events(self):
        # Respond to keypresses and mouse events.
        for event in pg.event.get():
            if event.type == pg.QUIT:
                sys.exit()
            elif event.type == pg.MOUSEBUTTONDOWN:
                x, y = pg.mouse.get_pos()
                if self.play_button_rect.collidepoint(x, y):
                    self.sound.play_music("sounds/overworld.wav")
                    return 'Play Game'  # Return a signal to start the main game loop
                elif self.high_score_button_rect.collidepoint(x, y):
                    return 'High Score'

    def draw(self):
        # Draw background color
        self.screen.fill(self.bg_color)

        # Draw Title
        self.title_rect = self.title_image.get_rect(center=(SCREEN_W/2, SCREEN_H - 320))
        self.screen.blit(self.title_image, self.title_rect)

        # Y position for the first character
        y_pos = 200

        # Loop through each character and its points and blit them to the screen
        for i, (name, point, image) in enumerate(zip(self.names, self.points, self.images)):
            # Render the point text
            text = pg.font.Font(None, 35).render(f'= {point} PTS', True, WHITE)
            # Blit the image and text to the screen
            self.screen.blit(image, (SCREEN_W/2 - 250, y_pos + 50))
            self.screen.blit(text, (SCREEN_W/2 - 150, y_pos +50))
            # Increment the y position for the next alien
            y_pos += image.get_height() + 10


            # set button positions
            self.play_button_rect = pg.Rect(SCREEN_W/2 + 100, 280, 200, 50)
            self.high_score_button_rect = pg.Rect(SCREEN_W/2 + 100, 320, 200, 50)
            # draw button
            self.play_button = pg.font.Font(None, 50).render('Play Game', True, self.text_color2)
            self.high_score_button = pg.font.Font(None, 50).render('High Score', True, self.text_color1)
            self.screen.blit(self.play_button, self.play_button_rect)
            self.screen.blit(self.high_score_button, self.high_score_button_rect)


class Game(object):
    def __init__(self):
        environ['SDL_VIDEO_CENTERED'] = '1'
        
        pg.init()
        self.screen = pg.display.set_mode((SCREEN_W, SCREEN_H))
        pg.display.set_caption('Super Mario')
        self.clock = pg.time.Clock()
        
        self.world = Map()
        
        self.run = True
        self.keyL = False
        self.keyR = False
        self.keyU = False
        self.keyD = False
        self.keyS = False
        
    def game_input(self):
        for event in pg.event.get():
            if event.type == pg.QUIT:
                self.run = False
            
            elif event.type == KEYDOWN:
                if event.key == K_RIGHT:
                    self.keyR = True
                elif event.key  == K_LEFT:
                    self.keyL = True
                elif event.key == K_UP:
                    self.keyU = True
                elif event.key == K_DOWN:
                    self.keyD = True
                elif event.key == K_SPACE:
                    self.keyS = True
                    
            elif event.type == KEYUP:
                if event.key == K_RIGHT:
                    self.keyR = False
                elif event.key  == K_LEFT:
                    self.keyL = False
                elif event.key == K_UP:
                    self.keyU = False
                elif event.key == K_DOWN:
                    self.keyD = False
                elif event.key == K_SPACE:
                    self.keyS = False
    
    def get_map(self):
        return self.world
    
    def play(self):
        while self.run:
            self.game_input()
            self.world.update(self)
            self.world.render(self)
            pg.display.flip()
            self.clock.tick(60)

        
if __name__ == '__main__':
    g = Game()
    launch_screen = LaunchScreen(g)
    # Initially draw the launch screen
    launch_screen.draw()
    pg.display.flip()

    action = None
    # Event loop to wait for user action
    while action != 'Play Game':
        action = launch_screen.check_events()
        if action == 'High Score':
            launch_screen.show_high_score()
    g.play()
        
