# 3D scaling

This demo shows how to scale the 3D viewport rendering without affecting
2D elements such as the HUD. It also demonstrates how to toggle filtering
on a viewport by using TextureRect to display the ViewportTexture
delivered by the Viewport node. This technique can be useful in 2D games
as well. For instance, it can be used to have a "pixel art" viewport for
the main game area and a non-pixel-art viewport for HUD elements.

ViewportContainer can also be used to display a viewport in a GUI, but it
doesn't offer the ability to enable filtering.
