# 2.5D Demo Project (GDScript)

This demo project is an example of how a 2.5D game could be created in Godot.

Controls: WASD to move, Space to jump, R to reset, and UIOPKL to change view modes.

Note: There is a Mono C# version available [here](https://github.com/godotengine/godot-demo-projects/tree/master/mono/2.5d).

## How does it work?

Custom node types are added in a Godot plugin to allow 2.5D objects. Node25D serves as the base for all 2.5D objects; its first child must be a Spatial, which is used to calculate its position. It also adds YSort25D to sort Node25D nodes, and ShadowMath25D for calculating a shadow (a simple KinematicBody that tries to cast downward).

It uses math inside of Node25D to calculate 2D positions from 3D ones. For getting a 3D position, this project uses KinematicBody and StaticBody (3D), but these only exist for math - the camera is 2D and all sprites are 2D. You are able to use any Spatial node for math.

To display the objects, add a Sprite or any other Node2D-derived children to your Node25D objects. Some nodes are unsuitable, such as 2D physics nodes. Keep in mind that the first child must be Spatial-derived for math purposes.

Several view modes are implemented, including top down, front side, 45 degree, isometric, and two oblique modes. To implement a different view angle, all you need to do is create a new set of basis vectors in Node25D, use it on all instances, and of course create textures to display that object in 2D.

## Screenshots
