# Audio Generator

This is a demo showing how one can generate and
play audio samples from GDScript.
It plays a simple 440 Hz sine wave at 22050 Hz.

Language: GDScript

Renderer: GLES 2

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/526

## How does it work?

It uses the `push_frame()` method on an [`AudioStreamGeneratorPlayback`](https://docs.godotengine.org/en/latest/classes/class_audiostreamgeneratorplayback.html)
object, which is inside of an
[`AudioStreamPlayer`](https://docs.godotengine.org/en/latest/classes/class_audiostreamplayer.html)
node, to generate audio frame-by-frame based on `pulse_hz`.
