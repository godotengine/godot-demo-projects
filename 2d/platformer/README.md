# 2D Platformer

This demo is a pixel art 2D platformer with single-player
and two player splitscreen multiplayer.

It demonstrates how to code characters and physics-based objects
in a real game context. This is a relatively complete demo
where the player can jump, walk on slopes, fire bullets,
interact with enemies, and collect items. It contains one
level. The player is invincible, unlike the enemies.

Language: GDScript

Renderer: Forward Plus

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/120

## Features

- Side-scrolling player controller using [`CharacterBody2D`](https://docs.godotengine.org/en/latest/classes/class_characterbody2d.html).
	- Can walk smoothly up and down slopes.
	- Can shoot, including while jumping.
	- Has a double jump that provides a horizontal momentum boost.
- Enemies that crawl on the floor and change direction when they encounter an obstacle.
- Camera that stays within the level’s bounds.
- Keyboard and gamepad control support.
- Platforms that can move in any direction.
- Gun that shoots bullets with rigid body (natural) physics.
- Collectible coins.
- Pausing and a pause menu.
- Pixel art visuals.
- Sound effects and music.

## Screenshots

![Player shooting in the direction of an enemy](screenshots/shoot.webp)

![The entire level layout viewed in the editor](screenshots/layout.webp)

## Music

"Pompy" by Hubert Lamontagne (madbr) https://soundcloud.com/madbr/pompy
