This example demonstrates how to read microphone audio input data using the 
`AudioServer.get_input_frames(frames: int) -> PackedVector2Array` function from https://github.com/godotengine/godot/pull/113288

The Microphone is turned on by default. To change the input device
you must to turn it off first. Play the music to test the speakers are working.
Play the sinusoidal tone (on another device) to see how the sound waves interact if you have 
a stereo microphone.

Sinnce an important use case of this feature is Voice over IP (VoIP) this demo 
includes a time delay playback buffer with a changable lag length. The actual playback buffer 
aims for the target delay by either pausing or speeding up the playback stream.  
An `AudioEffectPitchShift` is used to lower the pitch of the playback to compensate 
for the speedup. If you have recorded a short section of audio you can 
toggle the `Recording loop` button to look the data so you don't have to keep 
voicing sounds into the microphone.

Language: GDScript

Renderer: Compatibility

Version: 4.6

## Screenshots
<img width="630" height="512" alt="image" src="https://github.com/user-attachments/assets/6d0b4b2d-f28f-4ece-b3e5-1a42dc22d3b6" />
