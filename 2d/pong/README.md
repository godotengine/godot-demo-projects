# Pong with GDScript

A simple Pong game. This demo shows best practices
for game development in Godot, including
[signals](https://docs.godotengine.org/en/latest/getting_started/step_by_step/signals.html).

Language: GDScript

Renderer: GLES 2

Note: There is a C# version available [here](https://github.com/godotengine/godot-demo-projects/tree/master/mono/pong).

Note: There is a VisualScript version available [here](https://github.com/godotengine/godot-demo-projects/tree/master/visual_script/pong).

Note: There is a GDNative C++ version available [here](https://github.com/godotengine/gdnative-demos/tree/master/cpp/pong).

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/121

## How does it work?

The walls, paddle, and ball are all
[`Area2D`](https://docs.godotengine.org/en/latest/classes/class_area2d.html)
nodes. When the ball touches the walls or the paddles,
they emit signals and modify the ball.

## Screenshots

![Screenshot](screenshots/pong.png)
