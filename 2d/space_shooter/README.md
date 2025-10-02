# Space Shooter

## Introduction
In this on-rails shoot-em-up demo, the player gets to control a Space ship flying through a 2D version of Space, while firing their lasers by hitting the Space bar.
Various enemies will enter the screen from the right and try their hardest to destroy the player's ship.
Shooting these enemies will award points and the highest score achieved is kept in a one-entry leaderboard.
Avoiding the blocky obstacles and the enemies is key to survival and high scores, so good luck and have fun!

## Controls
* WSAD or Arrow Keys to move the ship
* Space to fire lasers
* Escape / ESC to stop playing and return to the main menu

---
## Godot Concepts presented in the demo
### Editor Workflow
* Importing assets (images, sounds)
* Using Scenes to group Nodes into small, mostly self-contained units of functionality
* Using a TileMap and TileSet to place obstacles in the level
* Use of AnimationPlayer nodes to both animate properties (position, rotation) as well as trigger functions
* Using a Parallax Background to give an impression of speed and distance traveled

### Scripting
* Using signals to communicate between Nodes that are created in different Scenes
* Using groups to tag and identify Nodes
* Interactions between KinematicBody2D and Area2D nodes for hit detection / collision
* Use of VisibilityNotifier2D to remove Nodes that move off screen
* Dynamically instancing loaded Scenes as Nodes

### GUI
* GUI Containers for organization and positioning
* GUI Controls to start and stop gameplay
* Use of a CanvasLayer to keep GUI always on top of the gameplay screen

### Miscellaneous
* Persisting a "savegame" in the user directory for the highscore

### Interactivity
* Player input for movement and firing
