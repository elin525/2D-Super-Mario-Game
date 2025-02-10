import pygame as pg 
from pytmx.util_pygame import load_pygame

from constants import *
from camera import Camera
from bg_obj import BGObject
from block import Block
from mario import Mario
from tube import Tube
from enemy import Goombas, Koopa
from sound import Sound

class Map(object):
    def __init__(self):
        self.mapSize = (0, 0)
        self.sky = 0 #sky surface
        self.game_activate = False
        
        self.brick = [] # contains brick objects
        self.obj_bg = [] #contain clouds landscape and so on
        self.tubes = []
        self.bullets = []
        self.dashboards = []
        self.enemies = []
        
        self.loadMap()
        self.camera = Camera(self.mapSize[0] * 500, 14)
        self.mario = Mario(x_pos=128, y_pos=351)
            
    def loadMap(self):
        """Load the tiled map"""
        tmx_data = load_pygame("worlds/1-1/W11.tmx")
        self.mapSize = (tmx_data.width, tmx_data.height)
        self.sky = pg.Surface((SCREEN_W, SCREEN_H))
        self.sky.fill((pg.Color(SKY))) # sky color
        
        #2D List
        self.map = [[0] * tmx_data.height for i in range (tmx_data.width)]
        layer_num = 0
        
        for layer in tmx_data.visible_layers:
            for y in range(tmx_data.height):
                for x in range(tmx_data.width):
                    #get pygame surface
                    image = tmx_data.get_tile_image(x, y, layer_num)
                    if image is not None:
                        tile_id = tmx_data.get_tile_gid(x, y, layer_num)
                        if layer.name == "Foreground":
                            if QUESTION:
                                image = (
                                    image,                                      # 1
                                    tmx_data.get_tile_image(0, 15, layer_num),   # 2
                                    tmx_data.get_tile_image(1, 15, layer_num),   # 3
                                    tmx_data.get_tile_image(2, 15, layer_num)    # activated
                                )

                            self.map[x][y] = Block(x * tmx_data.tileheight, y * tmx_data.tilewidth, image)
                            self.brick.append(self.map[x][y]) # positions for all blocks
                            
                        elif layer.name == "Background":
                            self.map[x][y] = BGObject(x * tmx_data.tileheight, y * tmx_data.tilewidth, image)
                            self.obj_bg.append(self.map[x][y])
                            
            layer_num += 1
            
            # setup tubes
            tubes_pos = [(28, 10), (37, 9), (46, 8), (55, 8), (163, 10), (179, 10)]
            for x_pos, y_pos in tubes_pos:
                self.add_tubes(x_pos, y_pos)
            
            # setup goombas
            gbs_pos = [(3150, 352), (3300, 352), (3650, 352), (2400, 352)]
            for x_pos, y_pos in gbs_pos:
                self.add_goombas(x_pos, y_pos) 
                
            # setup goombas
            #kpa_pos = [(2500, 95), (3700, 352), (4020, 352)]
            #for x_pos, y_pos in kpa_pos:
                #self.add_koopa(x_pos, y_pos)
            
            
    def get_camera(self):
        return self.camera
    
    def get_mario(self):
        return self.mario
    
    def get_dashboard(self):
        return self.dashboards
    
    def get_enemy(self):
        return self.enemies
    
    def add_tubes(self, x_pos, y_pos):
        self.tubes.append(Tube(x_pos, y_pos))

        for y in range(y_pos, 12): #12 is because it ground level
            for x in range(x_pos, x_pos + 2):
                self.map[x][y] = Block(x * 32, y * 32, image = None)
                
    def add_goombas(self, x_pos, y_pos):
        self.enemies.append(Goombas(x_pos, y_pos))
        
    def add_koopa(self, x_pos, y_pos):
        self.enemies.append(Koopa(x_pos, y_pos))
                
    # Returns tiles around the entity
    def get_blocks_for_collision(self, x, y):
        
        return (
            self.map[x][y - 1],
            self.map[x][y + 1],
            self.map[x][y],
            self.map[x - 1][y],
            self.map[x + 1][y],
            self.map[x + 2][y],
            self.map[x + 1][y - 1],
            self.map[x + 1][y + 1],
            self.map[x][y + 2],
            self.map[x + 1][y + 2],
            self.map[x - 1][y + 1],
            self.map[x + 2][y + 1],
            self.map[x][y + 3],
            self.map[x + 1][y + 3]
        )

    #   code to get position where player is currently standing on the gound
    def get_blocks_below(self, x, y):
        #return two blocks where player is standing
        return (
            self.map[x][y + 1],
            self.map[x+ 1][y + 1]
        )
        
    def remove_dashboard(self, dashboard):
        if dashboard in self.dashboards:
            self.dashboards.remove(dashboard)
    
    def remove_brick(self, brick):
        self.brick.remove(brick)
        # Remove from collision map as well  
        self.map[brick.rect.x // 32][brick.rect.y // 32] = 0
    
    def remove_bullet(self, bullet):
        """Remove a bullet from the game world."""
        if bullet in self.bullets:
            self.bullets.remove(bullet)
    
    def update_mario(self, game):
        self.get_mario().update(game)
        
    def update(self, game):
        if not game.get_map().game_activate:
            self.update_mario(game)

        else:
            self.get_event().update(game)

        #this is code to make move for the camera
        if not self.game_activate:
            self.get_camera().update(game.get_map().get_mario().rect)
    
    def render_map(self, game):
        game.screen.blit(self.sky, (0, 0))
        
    def render(self, game):
        game.screen.blit(self.sky, (0, 0))
        
        #self.obj_bg contains items or tiles like clouds and landscape
        for obj in  self.obj_bg:
            obj.render(game)
            
        for block in self.brick:
            block.render(game)
            
        for tube in self.tubes:
            tube.render(game)
            
        for enemy in self.enemies:
            enemy.render(game)
            
        self.mario.render(game)