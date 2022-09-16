#[compute]
#version 460

// Instruct the GPU to use 8x8x1 = 64 local invocations per workgroup.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

// Prepare memory for the image, which will be both read and written to
// `restrict` is used to tell the compiler that the memory will only be accessed
// by the `heightmap` variable.
layout(r8, binding = 0) restrict uniform image2D heightmap;
// `readonly` is used to tell the compiler that we will not write to this memory.
// This allows the compiler to make some optimizations it couldn't otherwise.
layout(rgba8, binding = 1) restrict readonly uniform image2D gradient;

// This function is the GPU counterpart of `compute_island_cpu()` in `main.gd`.
void main() {
	// Grab the current pixel's position from the ID of this specific invocation ("thread").
	ivec2 coords = ivec2(gl_GlobalInvocationID.xy);
	ivec2 dimensions = imageSize(heightmap);
	// Calculate the center of the image.
	// Because we are working with integers ('round numbers') here,
	// the result will be floored to an integer.
	ivec2 center = dimensions / 2;
	// Calculate the smallest distance from center to edge.
	int smallest_radius = min(center.x, center.y);

	// Calculate the distance from the center of the image to the current pixel.
	float dist = distance(coords, center);
	// Retrieve the range of the gradient image.
	int gradient_max_x = imageSize(gradient).x - 1;
	// Calculate the gradient index based on the distance from the center.
	// `mix()` functions similarly to `lerp()` in GDScript.
	int gradient_x = int(mix(0.0, float(gradient_max_x), dist / float(smallest_radius)));

	// Retrieve the gradient value at the calculated position.
	ivec2 gradient_pos = ivec2(gradient_x, 0);
	vec4 gradient_color = imageLoad(gradient, gradient_pos);

	// Even though the image format only has the red channel,
	// this will still return a vec4: `vec4(red, 0.0, 0.0, 1.0)`
	vec4 pixel = imageLoad(heightmap, coords);

	// Multiply the pixel's red channel by the gradient's red channel
	// (or any RGB channel, they're all the same except for alpha).
	pixel.r *= gradient_color.r;
	// If the pixel is below a certain threshold, this sets it to 0.0.
	// The `step()` function is like `clamp()`, but it returns 0.0 if the value is
	// below the threshold, or 1.0 if it is above.
	//
	// This is why we multiply it by the pixel's value again: to get the original
	// value back if it is above the threshold. This shorthand replaces an `if`
	// statement, which would cause branching and thus potentially slow down the
	// shader.
	pixel.r = step(0.2, pixel.r) * pixel.r;

	// Store the pixel back into the image.
	// WARNING: make sure you are writing to the same coordinate that you read from.
	// If you don't, you may end up writing to a pixel, before that pixel is read
	// by a different invocation and cause errors.
	imageStore(heightmap, coords, pixel);
}
