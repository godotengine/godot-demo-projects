# Aircraft

This demo simulates 2 aircraft using
[`VehicleWing3D`](https://docs.godotengine.org/en/latest/classes/class_vehiclewing3d.html)
nodes.

Wings are displayed as multiple debug sections in different colors:
- Green - normal state
- Orange - stall warning
- Red - stall
- Blue - control surface

Controls:
- Ailerons: <kbd>A/D</kbd>, <kbd>Gamepad Horizontal Axis Of Left Stick</kbd>
- Elevator: <kbd>W/S</kbd>, <kbd>Gamepad Vertical Axis Of Left Stick</kbd>
- Rudder: <kbd>Q/E</kbd>, <kbd>Gamepad Left/Right Trigger</kbd>
- Flaps: <kbd>Down/Up</kbd>, <kbd>Gamepad D-Pad Down/Up</kbd>
- Throttle: <kbd>+/-</kbd>, <kbd>Gamepad A/B</kbd>
- Brake: <kbd>Space</kbd>, <kbd>Gamepad X</kbd>
- Spawn next aircraft: <kbd>F1</kbd>, <kbd>Gamepad Right Bumper</kbd>

The player_aircraft_controller.gd script implements aircraft controls.

Basic parameters of aircraft:
- Cessna-172:
  - Mass: 750 kg
  - Wing distance to mass of center: 0.05 m
  - Wing span: 11.0 m
  - Wing chord: 1.5 m
  - Wing dihedral: 1.7 degree
  - Wing twist: -3.0 degree
  - Wing zero lift angle: -2.5 degree
- Yak-52:
  - Mass: 1000 kg
  - Wing distance to mass of center: 0.1 m
  - Wing span: 9.3 m
  - Wing chord: 2.1 m
  - Wing taper: 0.5
  - Wing sweep: -1.0 degree
  - Wing dihedral: 2.0 degree
  - Wing twist: -2.5 degree
  - Wing zero lift angle: -2.0 degree

Language: GDScript

Renderer: Forward+

## How does it work?

The base aircraft uses a
[`VehicleBody3D`](https://docs.godotengine.org/en/latest/classes/class_vehiclebody3d.html)
node. Wing aerodynamics are implemented in a
[`VehicleWing3D`](https://docs.godotengine.org/en/latest/classes/class_vehiclewing3d.html)
node.
