# 2D Polygons and Lines

A demo of solid and textured 2D polygons and lines using
[`Polygon2D`](https://docs.godotengine.org/en/3.6/classes/class_polygon2d.html) and
[`Line2D`](https://docs.godotengine.org/en/3.6/classes/class_line2d.html).

In this project, solid Line2Ds are antialiased by using a specially crafted texture.
By using a texture that is solid white on all its pixels except the top and bottom edges
(which are fully transparent white), the border appears smooth thanks to bilinear filtering.
A more extensive variation of this concept (which works better with variable-width lines) can be found
in the unofficial
[Antialiased Line2D add-on](https://github.com/godot-extended-libraries/godot-antialiased-line2d).

Language: GDScript

Renderer: GLES 2

## Screenshots

![Screenshot](screenshots/polygons_line.webp)
