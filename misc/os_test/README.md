# Operating System Testing

This demo showcases various OS-specific features in Godot.
It can be used to test Godot while porting it to a
new platform or to check for regressions.

In a nutshell, this demo shows how you can get information from the
operating system, or interact with the operating system.

Language: GDScript and some [C#](https://docs.godotengine.org/en/latest/tutorials/scripting/c_sharp/index.html)
(Mono is NOT required to run this demo)

Renderer: GLES 2

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/677

## How does it work?

The [`OS`](https://docs.godotengine.org/en/latest/classes/class_os.html)
class provides an abstraction layer over the platform-dependent code.
OS wraps the most common functionality to communicate with the host
operating system, such as the clipboard, video driver, date and time,
timers, environment variables, execution of binaries, command line, etc.

The buttons are connected to a node with the `actions.gd` script, which
perform actions using the OS class.
The text on the left is filled in using the `os_test.gd` script,
which gathers information about the OS using the OS class.

On a Mono-enabled version of Godot, Godot will load `MonoTest.cs` into
the `MonoTest` node. Then, information determined by
[`C# preprocessor defines`](https://docs.godotengine.org/en/latest/tutorials/scripting/c_sharp/c_sharp_features.html#preprocessor-defines)
will be added to the left panel.

## Screenshots

![Top HiDPI](screenshots/top-hidpi.png)

![Mono](screenshots/mono.png)
