# 2D Particles

This demo showcases how 2D particle systems work in Godot.

Language: GDScript

Renderer: Mobile

Check out this demo on the Asset Store: https://store.godotengine.org/asset/godot-foundation/particles-2d-demo/

## How does it work?

It uses [`GPUParticles2D`](https://docs.godotengine.org/en/latest/classes/class_gpuparticles2d.html) nodes
with [`ParticleProcessMaterial`](https://docs.godotengine.org/en/latest/classes/class_particleprocessmaterial.html)
materials. Note that `ParticleProcessMaterial` is agnostic between 2D and 3D,
so when used in 2D, the "Disable Z" flag should be enabled.

## Screenshots

![Screenshot of particles](screenshots/particles.webp)
