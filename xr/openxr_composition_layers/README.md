# OpenXR compositor layer demo

This is a demo for an OpenXR project where we showcase the new compositor layer functionality.
This is a companion to the [OpenXR composition layers manual page](https://docs.godotengine.org/en/latest/tutorials/xr/openxr_composition_layers.html).

Language: GDScript
Renderer: Compatibility
Minimum Godot Version: 4.3

## How does it work?

Compositor layers allow us to present additional content on a headset outside of our normal 3D rendered results.
With XR we render our 3D image at a higher resolution after which its lens distorted before it's displayed on the headset.
This to counter the natural barrel distortion caused by the lenses in most XR headsets.

When we look at things like rendered text or other mostly 2D elements that are presented on a virtual screen,
this causes a double whammy when it comes to sampling that data.
The subsequent quality loss often renders text unreadable or at the least ugly looking.

It turns out however that when 2D interfaces are presented on a virtual screen in front of the user,
often as a rectangle or slightly curved screen,
that rendering this content ontop of the lens distorted 3D rendering,
and simply curving this 2D plane,
results in a high quality render.

OpenXR supports three such shapes that when used appropriately leads to crisp 2D visuals.
This demo shows one such shape, the equirect, a curved display.

The only downside of this approach is that compositing happens in the XR runtime,
so any spectator view shown on screen will omit these layers.

> Note, if composition layers aren't supported by the XR runtime,
> Godot falls back to rendering the content within the normal 3D rendered result.

## Action map

This project does not use the default action map but instead configures an action map that just contains the actions required for this example to work.
This so we remove any clutter and just focus on the functionality being demonstrated.

There are only three actions needed for this example:
- aim_pose is used to position the XR controllers,
- select is used as a way to interact with the UI, it reacts to the trigger,
- haptic is used to emit a pulse on the controller when the player presses the trigger.

Aiming at the 2D UI will mimic mouse movement based on where you point.
Only one controller will interact with the UI at any given time seeing we can only mimic one mouse cursor.
You can switch between the left and right controller by pressing the trigger on the controller you wish to use.

Seeing the simplicity of this example we only supply bindings for the simple controller.
XR runtimes should provide proper re-mapping and as support for the simple controller is mandatory when controllers are used,
this should work on any XR runtime.
On some system the simple controller is also supported with hand tracking and on those you can use a pinch gesture
(touch your thumb and index finger together) to interact with the UI.

## Running on PCVR

This project can be run as normal for PCVR. Ensure that an OpenXR runtime has been installed.
This project has been tested with the Oculus client and SteamVR OpenXR runtimes.
Note that Godot currently can't run using the WMR OpenXR runtime. Install SteamVR with WMR support.

## Running on standalone VR

You must install the Android build templates and OpenXR vendors plugin and configure an export template for your device.
Please follow [the instructions for deploying on Android in the manual](https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html).

## Screenshots

![Screenshot](xr_composition_layer_demo.png)
