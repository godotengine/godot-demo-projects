# Audio Mic Feed

**This demo example is waiting for [PR#108773 Add MicrophoneFeed with direct access to the microphone input buffer](https://github.com/godotengine/godot/pull/108773)
to be merged into the v4.6 branch.  This PR creates a MicrophoneServer which can 
make a MicrophoneFeed that can draw audio data directly from the microphone buffer 
without being tied to the clock timing of the audio system.**

This example shows how to read microphone audio input data
using the `PackedVector2Array Input.get_microphone_buffer(frames: int)`
function.

The data can be copied to an `AudioStreamGenerator`, saved to a WAV file, or
used as a `FORMAT_RGF` image by a GPU shader.

A sine wave tone generator is included that can be deployed on a second device
and be used to probe the positional effects on a stereo microphone.

Language: GDScript

Renderer: Compatibility

## Screenshots

![image](https://github.com/user-attachments/assets/d85360dd-a0aa-4694-aad0-d570fd2a6a15)
