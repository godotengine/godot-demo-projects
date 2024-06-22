# Global Illumination

This demo showcases Godot's global illumination systems:
LightmapGI, VoxelGI, SDFGI, ReflectionProbe and screen-space effects like SSAO and SSIL.

Use the mouse to look around, <kbd>W</kbd>/<kbd>A</kbd>/<kbd>S</kbd>/<kbd>D</kbd>
or arrow keys to move.

Language: GDScript

Renderer: Forward+

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/2737

## How does it work?

A sphere and box are parented to the camera to showcase dynamic object lighting.
A ReflectionProbe is parented to the sphere to showcase real-time reflections.
When the ReflectionProbe is hidden, it is disabled. In this case,
VoxelGI, SDFGI or environment lighting will be used to provide fallback reflections.

A Decal node is parented to the moving sphere and cube to provide simple shadows for them.
This is especially effective when using the LightmapGI (All) global illumination mode,
which doesn't allow dynamic objects to cast shadows on static surfaces.

## Screenshots

![Screenshot](screenshots/global_illumination.png)

## Licenses

`zdm2.glb` is derived from the [Cube 2: Sauerbraten](http://sauerbraten.org/)
map "zdm2" and is
[licensed under CC BY 4.0 Unported](https://github.com/Calinou/game-maps-obj/blob/master/sauerbraten/zdm2.txt).
The OBJ file which it was converted from is available in the [game-maps-obj](https://github.com/Calinou/game-maps-obj) repository.
