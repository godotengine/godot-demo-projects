# Voxel Game

This demo is a minimal first-person voxel game,
inspired by others such as Minecraft.

Language: GDScript

Renderer: Forward+

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/2755

## How does it work?

Each chunk is a
[`StaticBody3D`](https://docs.godotengine.org/en/latest/classes/class_staticbody3d.html)
with each block having its own
[`CollisionShape`](https://docs.godotengine.org/en/latest/classes/class_collisionshape.html)
for collisions. The meshes are created using
[`SurfaceTool`](https://docs.godotengine.org/en/latest/classes/class_surfacetool.html)
which allows specifying vertices, triangles, and UV coordinates
for constructing a mesh.

The chunks and chunk data are stored in
[`Dictionary`](https://docs.godotengine.org/en/latest/classes/class_dictionary.html)
objects. New chunks have their meshes drawn in separate
[`Thread`](https://docs.godotengine.org/en/latest/classes/class_thread.html)s,
but generating the collisions is done in the main thread, since Godot does
not support changing physics objects in a separate thread. There
are two terrain types, random blocks and flat grass. A more
complex terrain generator is out-of-scope for this demo project.

The player can place and break blocks using the
[`RayCast`](https://docs.godotengine.org/en/latest/classes/class_raycast.html)
node attached to the camera. It uses the collision information to
figure out the block position and change the block data. You can
switch the active block using the brackets or with the middle mouse button.

There is a settings menu for render distance and toggling the fog.
Settings are stored inside of an
[AutoLoad singleton](https://docs.godotengine.org/en/latest/getting_started/step_by_step/singletons_autoload.html)
called "Settings". This class will automatically save
settings, and load them when the game opens, by using the
[`File`](https://docs.godotengine.org/en/latest/classes/class_file.html) class.

Sticking to GDScript and the built-in Godot tools, as this demo does, is
quite limiting. If you are making your own voxel game, you should probably
use Zylann's voxel module instead: https://github.com/Zylann/godot_voxel

## Screenshots

![Screenshot](screenshots/blocks.png)

![Screenshot](screenshots/title.png)

## Licenses

Textures are from [Minetest Game](https://github.com/minetest/minetest_game).

Some textures Copyright &copy; 2010-2018 Minetest contributors,
 CC BY-SA 3.0 Unported (Attribution-ShareAlike)
http://creativecommons.org/licenses/by-sa/3.0/

Some textures Copyright &copy; 2010-2018 Minetest contributors,
 CC0 1.0 "No rights reserved"
https://creativecommons.org/publicdomain/zero/1.0/

Font is "TinyUnicode" by DuffsDevice. Copyright &copy; DuffsDevice, CC-BY (Attribution) http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=468

### Copyright information for textures reused from Minetest Game

While most textures are under CC BY-SA 3.0, some are under CC0 1.0

Cisoun's texture pack (CC BY-SA 3.0):

  * default\_stone.png
  * default\_leaves.png
  * default\_leaves\_simple.png
  * default\_tree.png
  * default\_tree\_top.png

celeron55, Perttu Ahola <celeron55@gmail.com> (CC BY-SA 3.0)

  * default\_mineral\_iron.png
  * default\_mineral\_coal.png
  * default\_bookshelf.png

VanessaE (CC BY-SA 3.0):

  * default\_sand.png

Calinou (CC BY-SA 3.0):

  * default\_brick.png

PilzAdam (CC BY-SA 3.0):

  * default\_mineral\_gold.png

jojoa1997 (CC BY-SA 3.0):

  * default\_obsidian.png

InfinityProject (CC BY-SA 3.0):

  * default\_mineral\_diamond.png

Zeg9 (CC BY-SA 3.0):

  * default\_coal\_block.png

paramat (CC BY-SA 3.0):

  * default\_bush\_stem.png
  * default\_grass\_side.png -- Derived from a texture by TumeniNodes (CC-BY-SA 3.0)
  * default\_mese\_block.png

TumeniNodes (CC BY-SA 3.0):

  * default\_grass.png

Blockmen (CC BY-SA 3.0):

  * default\_wood.png

sofar (CC0 1.0):

  * default\_gravel.png -- Derived from Gambit's PixelBOX texture pack light gravel

Neuromancer (CC BY-SA 3.0):

  * default\_furnace\_bottom.png
  * default\_furnace\_side.png
  * default\_cobble.png, based on texture by Brane praefect
  * default\_mossycobble.png, based on texture by Brane praefect

Gambit (CC BY-SA 3.0):

  * default\_diamond\_block.png

kilbith (CC BY-SA 3.0):

  * default\_steel\_block.png
  * default\_gold\_block.png
  * default\_mineral\_tin.png

Mossmanikin (CC BY-SA 3.0):

  * default\_fern\_3.png

random-geek (CC BY-SA 3.0):

  * default\_dirt.png -- Derived from a texture by Neuromancer (CC BY-SA 3.0)

Krock (CC0 1.0):

  * default\_glass.png
