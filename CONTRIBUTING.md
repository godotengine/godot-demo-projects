# Contributing to Godot demo projects

Thanks for your interest in contributing to the Godot demo projects!

## Demo submission criteria

Please follow these guidelines for submitting new demos or improving existing demos:

- The demo must work with the latest Godot version of the branch you're submitting to.

- The demo must follow all of the Godot style guides:
  - [Project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)
  - [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
    - In GDScript, type hints should be used whenever possible to improve runtime performance
    and ease code maintenance. The **Debug > GDScript > Warnings > Untyped Declaration**
    project setting is set to **Warn** on most existing demos to enforce this.
    This setting should also be configured to **Warn** on new demos.
  - [C# style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/c_sharp/c_sharp_style_guide.html)
  - [Shaders style guide](https://docs.godotengine.org/en/stable/tutorials/shaders/shaders_style_guide.html)

- The demo should not be overcomplicated. Simplicity is usually preferred.

- The submitted files must be freely redistributable and modifiable,
  including for commercial use. This applies to art assets as well.
  - In practice, this means the following licenses are accepted for art assets:
    - CC0 1.0 (or similar public domain dedications)
    - CC BY 3.0/4.0
    - CC BY-SA 3.0/4.0
  - Licenses such as "Royalty-free" (without clarification), CC BY-NC or
    CC BY-ND are **not** accepted.

- To allow demos to be cloned quickly, file sizes should be kept reasonable for
  all files submitted. Try to keep the demo project files's download size below
  20 MB, unless there is a good reason to have a larger demo (e.g. if
  high-quality textures are *required* to show off an effect).
  - You can check this by creating a ZIP file containing the project files,
    then removing `.godot/` within the ZIP file.
  - For 3D demos, consider relying on Godot's procedural generation abilities
    (such as [NoiseTexture2D](https://docs.godotengine.org/en/stable/classes/class_noisetexture2d.html))
    to decrease file size.

### Submission criteria for new demos

If you are submitting a new demo:

- Make sure it includes a `README.md` file similar to the other demos.

- Make sure a short description (1-3 lines) is set in the Project Settings.

- Make sure the project has a `icon.webp` in lossless WebP[^1] format that is
  128×128 pixels, with its path defined in the Project Settings. This allows the
  icon to remain crisp on hiDPI displays.

- Make sure the project includes a `screenshots/` folder containing a screenshot in
  lossless WebP[^1] format similar to the other demos. It's recommended to stick to
  only 1 screenshot, but you may add multiple screenshots if required. The
  screenshot should be in 1280×720 resolution, without visible window borders.
  - The `screenshots/` folder must contain an empty `.gdignore` file to prevent
    Godot from importing screenshots as resources.

- Make sure the demo has keyboard and controller input support (plus mouse if
  relevant). Explicit touch input support is a bonus, but not required.
  - For keyboard events, WASD configurations must use *physical* key locations
    in the Input Map to allow them to work out of the box on non-QWERTY keyboard
    layouts.

#### Visual considerations

- Unless the project requires a different stretch mode and aspect, use the
  `canvas_items` stretch mode and `expand` stretch aspect in the Project
  Settings. Configure anchors for Control nodes correctly, so that
  [multiple resolutions](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html)
  and aspect ratios are supported.

- Demos that don't update their visual output often (such as UI demos) must have
  **Low Processor Mode** enabled in the Project Settings. This must be left
  disabled in demos where constant redrawing is expected (such as most "game"
  demos).

- For greater performance and compatibility, use the **Compatibility** rendering
  method in 2D demos that don't require advanced graphics functionality.
  - In 3D demos or 2D demos that require advanced graphics functionality, use
    the **Forward+** rendering method (**Mobile** is automatically used on
    mobile platforms in this case).

- In 3D projects, set **Rendering > Textures > Default Filters > Anisotropic Filtering Level**
   to **16×** in the Project Settings. Make sure all materials use the relevant
   anisotropic sampler mode (**Nearest Mipmaps Anisotropic** or **Linear Mipmaps Anisotropic**).
- In 3D projects, set **Rendering > Anti Aliasing > Quality > MSAA 3D** to **4×**.
  - In projects that use demanding graphics features such as SDFGI, set
  **Rendering > Anti Aliasing > Quality > Screen Space AA** to **FXAA** instead
  as this is faster.
- Use graphics options that perform reasonably well on low-end to mid-range
  hardware. Demanding graphics options should not be enabled by default, unless
  they're the entire point of the demo.

#### If you are submitting a copy of a demo translated to C#

- Please ensure that there is a good reason to have this demo translated. We
  don't want to have multiple copies of every single project, as this makes
  maintenance more difficult.

- Please ensure that the code mirrors the original as closely as possible.

- In the `project.godot` file and in the `README.md`, include "with C#" in
  the title, and also include a link to the original in the `README.md`.

[^1]: You can use [Squoosh](https://squoosh.app/) to convert images to WebP.
Make sure to enable the Lossless option, as it's not the default.
