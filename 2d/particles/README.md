# 2D Particles

This demo showcases how 2D particle systems work in Godot.

Language: GDScript

Renderer: Mobile

Check out this demo on the asset library: https://godotengine.org/asset-library/asset/2724

## How does it work?

It uses [`GPUParticles2D`](https://docs.godotengine.org/en/latest/classes/class_gpuparticles2d.html) nodes
with [`ParticleProcessMaterial`](https://docs.godotengine.org/en/latest/classes/class_particleprocessmaterial.html)
materials. Note that `ParticleProcessMaterial` is agnostic between 2D and 3D,
so when used in 2D, the "Disable Z" flag should be enabled.

## Screenshots

![Screenshot of particles](screenshots/particles.webp)
