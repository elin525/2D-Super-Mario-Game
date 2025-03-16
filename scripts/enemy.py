import pygame as pg
from constants import *

class Enemy():
    def __init__(self, x_pos, y_pos):  
        self.rect = pg.Rect(x_pos, y_pos, 32, 32)  
        self.x_speed = 1
        self.y_speed = 0
        self.facing_right = True
        self.on_ground = False
        self.collision = True
        
        self.image_tick = 0
        self.state = 'walking'
        self.crushed = False
        
        if self.facing_right:
            self.x_speed = 1
        else:
            self.y_speed = -1

    def move(self, blocks):
        # Horizontal movement
        self.rect.x += self.x_speed

        # Check and handle horizontal collisions
        for block in blocks:
            if block and block.type != 'BGObject' and self.rect.colliderect(block.rect):
                if self.x_speed > 0:
                    self.rect.right = block.rect.left
                else:
                    self.rect.left = block.rect.right
                # Reverse direction upon collision
                self.x_speed = -self.x_speed
                self.facing_right = not self.facing_right

        # Vertical movement with gravity effect
        self.rect.y += self.y_speed * FALL_MULTIPLIER
        self.on_ground = False

        # Check and handle vertical collisions
        for block in blocks:
            if block != 0 and block.type != 'BGObject' and pg.Rect.colliderect(self.rect, block.rect):
                if self.y_speed > 0:  # Falling down
                    self.on_ground = True
                    self.rect.bottom = block.rect.top
                    self.y_speed = 0

            

    def check_boarder(self, game):
        # Check if the enemy has fallen below the ground level
        if self.rect.y > Ground_Level:
            self.state = 'die'
            self.die(game)
            
    def update(self, game):
        # Only move if in 'walking' state
        if self.state == 'walking':
            blocks = game.get_map().get_blocks_for_collision(self.rect.x // 32, self.rect.y // 32)
            self.move(blocks)


class Goombas(Enemy):
    def __init__(self, x_pos, y_pos):
        super().__init__(x_pos, y_pos)
        
        self.load_images()
        self.image = self.images_right

    def load_images(self):
        self.images_right = [
            pg.image.load('images/goombas_0.png').convert_alpha(),
            pg.image.load('images/goombas_1.png').convert_alpha(),
            pg.image.load('images/goombas_dead.png').convert_alpha(),
        ]

        # Flipped images facing left
        self.images_left = [pg.transform.flip(img, True, False) for img in self.images_right]
        # Initially facing right
        self.images = self.images_right
        self.current_image = 0
        
    def check_collision(self, game):
        # collision with Mario
        player = game.get_map().get_player()
        if self.collision:
            if pg.Rect.colliderect(self.rect, player.rect):
                if player.rect.bottom <= self.rect.top + COLLISION_MARGIN:
                    # Goomba is crushed
                    self.state = 'die'
                    self.die(game, crushed = True)
                    player.y_speed += BOUNCE_SPEED
            

    def die(self, game, crushed):
        if crushed:
            self.crushed = True
            self.image_tick = 0
            self.current_image = 2
            self.collision = False
        else:
            self.y_speed = -5
            self.current_image = 3
            self.collision = False

    def update_image(self):
        self.image_tick += 1
        if self.image_tick >= 12:
            self.current_image = (self.current_image + 1) % len(self.images)
            self.image_tick = 0
    
    def update(self, game):
        super().update(game)
        self.update_image()
        if self.state == 'walking':
            self.images = self.images_right if self.facing_right else self.images_left
        elif self.state == 'die':
                if self.crushed:
                    self.image_tick += 1
                    if self.image_tick == 40:
                        game.get_map().get_enemy().remove(self)
                    else:
                        self.y_speed += GRAVITY
                        self.rect.y += self.y_speed
                        self.check_boarder(game)
                        
                        
    def render(self, game):
        game.screen.blit(self.image[self.current_image], game.get_map().get_camera().apply(self))
                        
class Koopa(Enemy):
    def __init__(self, x_pos, y_pos):
        super().__init__(x_pos, y_pos)
        
        self.load_images()

    def load_images(self):
        self.images_right = [
            pg.image.load('images/koopa_0.png').convert_alpha(),
            pg.image.load('images/koopa_1.png').convert_alpha(),
            pg.image.load('images/koopa_dead.png').convert_alpha(),
        ]

        # Flipped images facing left
        self.images_left = [pg.transform.flip(img, True, False) for img in self.images_right]
        # Initially facing right
        self.images = self.images_right
        
    def check_collisions_with_mario(self, game):
        # collision with mob
        for enemy in game.get_map().get_enemy():
            if enemy is not self:
                if self.rect.colliderect(enemy.rect):
                    enemy.die(game, crushed = False) 
    
    def update_image(self):
        if self.facing_right:
            self.images = self.images_right
        else:
            self.images = self.images_left
        self.image_tick += 1
        
        if self.image_tick == 12:
            self.current_image = 1
        elif self.image_tick == 24:
            self.current_image = 0
            self.image_tick = 0        
            
    def render(self, game):
        game.screen.blit(self.images[self.current_image], game.get_map().get_camera().apply(self))