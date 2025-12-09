This example demonstrates how to read microphone audio input data using the 
`AudioServer.get_input_frames(frames: int) -> PackedVector2Array` function from https://github.com/godotengine/godot/pull/113288

The Microphone is turned on by default. If you need to change the input device
you need to turn it off first. Play music to test the speakers are working, or a 
fixed wavelength tone (on another device) to see how the sound waves interact if you have 
a stereo microphone.

Since the primary use case of this feature is Voice over IP (VoIP) there is a demo 
of a time delay playback buffer with a changable length. The actual playback buffer 
aims for the target delay by either pausing or speeding up the playback stream.  
An `AudioEffectPitchShift` is used to lower the pitch of the playback to compensate 
for the speedup. Toggle `Use Recording` to substitute up to a 10 second loop you 
of audio you have recorded so you don't need to keep speaking into the microphone
to test it.

Language: GDScript

Renderer: Compatibility

Version: 4.6

## Screenshots
<img width="639" height="500" alt="image" src="https://github.com/user-attachments/assets/e42ba103-8d0b-4955-8616-7205b59c5bdc" />
