# 2D Platformer

This demo is a pixel art 2D platformer with graphics and sound.

It shows you how to code characters and physics-based objects
in a real game context. This is a relatively complete demo
where the player can jump, walk on slopes, fire bullets,
interact with enemies, and more. It contains one closed
level, and the player is invincible, unlike the enemies.

You will find most of the demo’s content in the `Level.tscn` scene.
You can open it from the default `Game.tscn` scene, or double
click on `Level.tscn` in the `src/Level/` directory.

We invite you to open the demo's GDScript files in the editor as
they contain a lot of comments that explain how each class works.

Language: GDScript

Renderer: GLES 2

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/120

## Features

- Side-scrolling player controller using [`KinematicBody2D`](https://docs.godotengine.org/en/latest/classes/class_kinematicbody2d.html).
    - Can walk on and snap to slopes.
    - Can shoot, including while jumping.
- Enemies that crawl on the floor and change direction when they encounter an obstacle.
- Camera that stays within the level’s bounds.
- Supports keyboard and gamepad controls.
- Platforms that can move in any direction.
- Gun that shoots bullets with rigid body (natural) physics.
- Collectible coins.
- Pause and pause menu.
- Pixel art visuals.
- Sound effects and music.

## Screenshots

![Player shooting in the direction of an enemy](screenshots/shoot.png)

![The entire level layout viewed in the editor](screenshots/layout.png)

## Music

"Pompy" by Hubert Lamontagne (madbr) https://soundcloud.com/madbr/pompy
