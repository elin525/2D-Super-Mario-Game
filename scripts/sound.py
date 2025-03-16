import pygame as pg 
from pygame import mixer
import time

class Sound:
    def _init_(self, game):
        self.game = game
        mixer.init()
        
    def set_volume(self, volume = 0.3):
        mixer.music.set_volume(volume)
        
    def play_music(self, filename):
        self.stop_music()
        mixer.music.load(filename)
        mixer.music.play(loops = -1)
        
    def pause_music(self):
        mixer.music.pause()
        
    def unpause_music(self):
        mixer.music.stop()
        
    def stop_music(self):
        mixer.music.stop()
        
    def play_sound(self, soundname):
        #self.stop_music()
        sound_effect = mixer.Sound(soundname)
        sound_effect.play()
        
    def game_over(self):
        self.stop_music()
        self.play_music('sounds/gameover.wav')
        time.sleep(3)
        self.stop_music()