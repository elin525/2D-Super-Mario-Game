import pygame as pg 
from constants import *
from sound import Sound

class Mario:
    def __init__(self, x_pos, y_pos):
        self.score = 0
        self.coins = 0
        
        
        self.visible = True
        self.image_tick = 0
        self.power_level = 0

        self.unkillable = False
        self.unkillableTime = 0

        self.x_speed = 0
        self.y_speed = 0
        self.on_ground = True
        self.already_jumped = False
        self.next_jump_time = 0
        self.facing_right = True
        self.fast_moving = False
        
        self.pos_x = x_pos

        self.image = pg.image.load('images/Mario/mario.png').convert_alpha()
        self.mario_right = {}
        self.mario_left = {}
        
        self.sound = Sound()
        self.load_sprites()

        self.rect = pg.Rect(x_pos, y_pos, 32, 32)
        
    def load_sprites(self):
        # load images based on status
        self.mario_right = {
            'small': {
                'stand': pg.image.load('images/Mario/mario.png'),
                'move': [
                    pg.image.load('images/Mario/mario_move0.png'),
                    pg.image.load('images/Mario/mario_move1.png'),
                    pg.image.load('images/Mario/mario_move2.png')
                ],
                'jump': pg.image.load('images/Mario/mario_jump.png'),
                'end': [
                    pg.image.load('images/Mario/mario_end.png'),
                    pg.image.load('images/Mario/mario_end1.png')
                ],
                'stop': pg.image.load('images/Mario/mario_st.png')
            },
            'big': {
                'stand': pg.image.load('images/Mario/mario1.png'),
                'move': [
                    pg.image.load('images/Mario/mario1_move0.png'),
                    pg.image.load('images/Mario/mario1_move1.png'),
                    pg.image.load('images/Mario/mario1_move2.png')
                ],
                'jump': pg.image.load('images/Mario/mario1_jump.png'),
                'stop': pg.image.load('images/Mario/mario1_st.png')
            },
            'level_up': {
                'stand': pg.image.load('images/Mario/mario2.png'),
                'move': [
                    pg.image.load('images/Mario/mario2_move0.png'),
                    pg.image.load('images/Mario/mario2_move1.png'),
                    pg.image.load('images/Mario/mario2_move2.png')
                ],
                'jump': pg.image.load('images/Mario/mario2_jump.png'),
                'stop': pg.image.load('images/Mario/mario2_st.png'),
            },
            'level_changing': pg.image.load('images/Mario/mario_lvlup.png').convert_alpha(),
            'death': pg.image.load('images/Mario/mario_death.png').convert_alpha()
    }

        # Left side frame
        for key, value in self.mario_right.items():
            if isinstance(value, dict):
                self.mario_left[key] = {}
                for action, image in value.items():
                    if isinstance(image, list):
                        self.mario_left[key][action] = [pg.transform.flip(img, True, False) for img in image]
                    else:
                        self.mario_left[key][action] = pg.transform.flip(image, True, False)

        
    def movement(self, game):
        # Moving left or right
        if game.keyL:
            self.x_speed = min(self.x_speed - SPEED_INCREASE_RATE, -MAX_FASTMOVE_SPEED if self.fast_moving else -MAX_MOVE_SPEED)
            self.facing_right = False
        elif game.keyR:
            self.x_speed = max(self.x_speed + SPEED_INCREASE_RATE, +MAX_FASTMOVE_SPEED if self.fast_moving else +MAX_MOVE_SPEED)
            self.facing_right = True
        else:
            # Apply friction
            if abs(self.x_speed) > SPEED_DECREASE_RATE:
                self.x_speed -= SPEED_DECREASE_RATE if self.x_speed > 0 else -SPEED_DECREASE_RATE
            else:
                self.x_speed = 0
                
        # Jump
        if game.keyU and self.on_ground and not self.already_jumped:
            current_time = pg.time.get_ticks()
            self.sound.play_sound("sounds/jump.wav")
            if current_time > self.next_jump_time:
                self.y_speed = -JUMP_POWER
                self.already_jumped = True
                self.on_ground = False
                self.next_jump_time = current_time + 750  # Delay next jump for 750 ms
        
        # Moving up and Falling
        if not self.on_ground:
            # If player keep pressing jump button while Mario is in the air, Mario will start to ascend
            if game.keyU and self.y_speed < 0:
                self.y_speed += GRAVITY
            # If player stop pressing jump button, Mario will fall faster
            elif not game.keyU and self.y_speed < 0:
                self.y_speed += GRAVITY * LOW_JUMP_MULTIPLIER
            #  If Mario jump off a platform
            else:
                self.y_speed = max(self.y_speed + GRAVITY *  FALL_MULTIPLIER, MAX_FALL_SPEED)
            
        # Land 
        if self.y_speed > 0 and self.on_ground:
            self.on_ground = True
            self.already_jumped = False
            self.y_speed = 0
            
        #  Collision with platforms/walls
        blocks = game.get_map().get_blocks_for_collision(self.rect.x // 32, self.rect.y // 32)
        
        self.pos_x += self.x_speed
        self.rect.x = self.pos_x
        
        self.update_x_pos(blocks)

        self.rect.y += self.y_speed
        self.update_y_pos(blocks, game)

        # on_ground parameter won't be stable without this piece of code
        coord_y = self.rect.y // 32
        if self.power_level > 0:
            coord_y += 1
        for block in game.get_map().get_blocks_below(self.rect.x // 32, coord_y):
            if block != 0 and block.type != 'BGObject':
                if pg.Rect(self.rect.x, self.rect.y + 1, self.rect.w, self.rect.h).colliderect(block.rect):
                    self.on_ground = True
            
    def update_x_pos(self, blocks):
        for block in blocks:
            if block != 0 and block.type != 'BGObject':
                if pg.Rect.colliderect(self.rect, block.rect):
                    if self.x_speed > 0:
                        self.rect.right = block.rect.left
                        self.pos_x = self.rect.left
                        self.x_speed = 0
                    elif self.x_speed < 0:
                        self.rect.left = block.rect.right
                        self.pos_x = self.rect.left
                        self.x_speed = 0

    def update_y_pos(self, blocks, game):
        self.on_ground = False
        for block in blocks:
            if block != 0 and block.type != 'BGObject':
                if pg.Rect.colliderect(self.rect, block.rect):

                    if self.y_speed > 0:
                        self.rect.bottom = block.rect.top
                        self.y_speed = 0
                        self.on_ground = True
                        self.already_jumped = False

                    elif self.y_speed < 0:
                        self.rect.top = block.rect.bottom
                        self.y_speed = -self.y_speed / 3
                        #self.activate_block_action(core, block)
        
        
    def set_image(self, action):
        # if mario change direction, flip the images
        sprites = self.mario_right if self.facing_right else self.mario_left

        # base on power level get sprites
        level_key = {0: 'small', 1: 'big', 2: 'level_up'}.get(self.power_level, 'small')
        images = sprites[level_key].get(action)

        # make sure what images are use
        if isinstance(images, list):
            # if images is a list
            self.image = images[self.image_tick % len(images)]
        else:
            # if only have one image
            self.image = images 
    
    def update_image(self, game):
        # update animation tick
        self.image_tick += 1
        if game.keyS:
            self.image_tick += 1

        # make sure mario's movement
        if not self.on_ground:
            action = 'jump'
        elif self.x_speed == 0 and (game.keyR or game.keyL):
            action = 'stop'  # 如果有停止动作时立即反映
        elif self.x_speed == 0:
            action = 'stand'
        elif self.x_speed > 0 or self.x_speed < 0:
            action = 'move'

        # control the frame rate of each action
        if self.image_tick % 5 == 0 or action in ['stand', 'stop']:
            self.set_image(action)
            if action in ['stand', 'stop']:  
                self.image_tick = 0

            

            # if necessary, reset the image tick
            if action != 'move' or self.image_tick > 30:
                self.image_tick = 0
            
    
    def update(self, game):
        self.movement(game)
        self.update_image(game)
        
    def render(self, game):
        if self.visible:
            game.screen.blit(self.image, game.get_map().get_camera().apply(self))
