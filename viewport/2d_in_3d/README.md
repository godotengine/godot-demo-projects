# 2D in 3D

A demo showing how a 2D scene can be shown within a 3D one using viewports.

Language: GDScript

Renderer: GLES 2

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/129

## How does it work?

The Pong game is rendered to a custom
[`Viewport`](https://docs.godotengine.org/en/latest/classes/class_viewport.html)
node rather than the main Viewport. In the code,
`get_texture()` is called on the Viewport to get a
[`ViewportTexture`](https://docs.godotengine.org/en/latest/classes/class_viewporttexture.html),
which is then assigned to the quad's material's albedo texture.

## Screenshots

![Screenshot](screenshots/pong.png)
