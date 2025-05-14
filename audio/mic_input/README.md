# Audio Mic Input

This example shows how to read microphone audio input data
using the `PackedVector2Array Input.get_microphone_buffer(frames: int)`
function.

The data can be copied to an `AudioStreamGenerator`, saved to a WAV file, or
used as a `FORMAT_RGF` image by a GPU shader.

A sine wave tone generator is included that can be deployed on a second device
and used to probe the positional effects on a stereo microphone.

Language: GDScript

Renderer: Compatibility

## Screenshots

![image](https://github.com/user-attachments/assets/d85360dd-a0aa-4694-aad0-d570fd2a6a15)
