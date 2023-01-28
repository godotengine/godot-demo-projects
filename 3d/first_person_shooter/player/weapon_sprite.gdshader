shader_type spatial;
render_mode specular_disabled, depth_test_disabled;

// Texture spritesheet.
uniform sampler2D views : filter_nearest, source_color;

// Number of frames in the animation (vertical axis on the image).
uniform int frame_count : hint_range(1, 1000) = 7;
// Current frame in the animation.
uniform int frame : hint_range(0, 999) = 0;

const float MIN_BRIGHTNESS = 0.4;
const float ALBEDO_ENERGY = 4.0;

void vertex() {
	// Billboard.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	float y = float(frame) / float(frame_count); // UV vertical start for the view in the atlas.
	float view_height = 1.0 / float(frame_count); // UV height of the animation in the atlas.
	vec4 tex = texture(views, vec2(UV.x, y + view_height * UV.y));

	// Ensure the weapon sprite in the darkness is always visible to an extent,
	// but allow it to be lit by light sources.
	EMISSION.rgb = tex.rgb * MIN_BRIGHTNESS;
	ALBEDO = tex.rgb * ALBEDO_ENERGY;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
