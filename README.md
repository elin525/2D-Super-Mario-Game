# 🎮 Super Mario Clone – Godot Project

A 2D platformer game inspired by **Super Mario Bros**, built from scratch using the **Godot Engine**.  
This project recreates classic Mario gameplay mechanics including power-ups, enemies, coins, music, and a flagpole finish!

---

## 📸 Demo Preview

[![Watch the demo on YouTube](https://youtu.be/VXTAsLg7kE4)  
*Click to watch Mario collecting coins, defeating enemies, and reaching the flagpole!*

---

## 🚀 Features

- 👨‍🔧 Classic Mario mechanics (jumping, growing, fireballs, etc.)
- 🌟 Power-ups: Mushrooms, Fire Flowers, Stars, 1-UPs
- 👾 Enemies: Goombas, Koopas, and more
- 💥 Invincibility mode with music & flashing colors
- 🏁 Flagpole end-of-level scene
- 🔊 Sound effects & background music
- 🖼️ Title screen with animated Mario and start menu
- 📊 Scoring system with floating point labels
- 💾 Checkpoint system and lives tracking

---

## 🛠️ Getting Started

### Requirements

- [Godot Engine 4.4.1](https://godotengine.org/download)
- Git (optional)

### How to Run

1. Clone this repository or download the ZIP.
   ```bash
   git clone https://github.com/your-username/super-mario-godot.git
2. Double click project.godot file. After entering the game engine, click the "run project" button.


File:
Fonts (file):
  - Holds the specialized pixel formated text used in the original game
Images (file):
  - All reference images that are overlayed in the game including: enemies, flag, sky, blocks, player...etc.
Pickups (file):
  - Setup the power ups to distinguish them from eachother and how they interact
Scripts (file)
begin_game.gd (Class):
  - Start up game, setting up general information for flag, world & player
brick_area.gd (Class):
  - General code for the bricks and their interactions
camera.gd (Class):
  - Especially impotant for following the player's movement and keeping them on screen, and setting
    boundries.
elevator.gd (Class):
  - The moving platforms in level 2 that either go up or down when standing on top of them
enemy.gd (Class):
  - General class that will hold the different type of enemies being: koopa(shell & normal form)
    & goomba, interaction with player
fireworks.gd (Class):
  - Astetics that play at the end of the level after touching the flag
flag.gd (Class):
  - End level and move on
flag_area.gd (Sub-Class):
  - Interaction with the flag and it's collision area
game_over.gd (Class):
  - Game over screen after loosing all lives
goomba.gd (Sub-Class):
  - Normal enemy that walks around
koopa.gd (Sub-Class):
  - Normal enemy that walks around, can turn to shell and hit other enemies and or the player
lives_scene.gd (Class):
  - Transition scene after dying displaying lives
pickup.gd (Class):
  - All the power ups in the game being the 1-up,super mushroom, star & fire flower
piranha_plant.gd (Class):
  - Enemies that pop out of pipes in world 2
player.gd (Class):
  - The general class that is utilized and will determine the player, their inputs, and interaction
    with everything in the worlds.
points_label.gd (Class):
  - Display the variables kept in the score
question_area.gd (Class):
  - General code for the bricks and their interactions
score.gd (Class):
  - Saves the points, coins collected and the time
title_screen.gd (Class):
  - Start up menu that displays the start button and general points
tube.gd (Class):
  - Pipe class that'll teleport players when entering special pipes.
Sounds (file):
  - Reference sound effects and music playing in the game
Tubes (file):
  - Different types of tubes that show up in game
UI (file):
  - Score and points label utilize this to display status on the screen
Worlds (file):
  - Files and layout that changes for the level the player is currently on

