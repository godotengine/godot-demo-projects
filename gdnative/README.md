# GDNative

## Init
To build you need to init the godot-cpp submodule

```bash
cd godot-cpp
git submodule update --init --recursive
scons -j8 platform=<platform> bits=64 generate_bindings=yes
```

## Run
For any project just run

```bash
scons -j8 platform=<platform>
```

then open the project with godot and run

```bash
godot -e
```

## Debug

You can use gdb (on Linux) with VSCode or any other editor that supports debug, run the engine with the project as working dir.

VSCode lauch.json
```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(gdb) Launch",
            "type": "cppdbg",
            "request": "launch",
            "program": "/usr/bin/godot",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}/gdnative/dodge_the_creeps",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "preLaunchTask": "Build dodge_the_creeps",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```
