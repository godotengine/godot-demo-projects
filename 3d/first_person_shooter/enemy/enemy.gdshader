shader_type spatial;
render_mode specular_disabled, cull_disabled;

// Texture spritesheet.
uniform sampler2D views : filter_nearest, source_color;

// Number of sides in the spritesheet (horizontal axis on the image).
uniform int view_count : hint_range(1, 32) = 8;

// Number of frames in the animation (vertical axis on the image).
uniform int frame_count : hint_range(1, 1000) = 7;
// Current frame in the animation.
uniform int frame : hint_range(0, 999) = 0;

const float MIN_BRIGHTNESS = 0.1;
const float ALBEDO_ENERGY = 4.0;

void vertex() {
	// Y-billboard.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
}

void fragment() {
	float d = dot(NORMAL.zx, vec2(-1.0, 0.0));
	float angle = -acos(NORMAL.z) + PI;
	float current_view = NORMAL.x > 0.0 ? angle / TAU : 1.0 - angle / TAU;
	float x = round(current_view * float(view_count)) / float(view_count); // UV horizontal start for the view in the atlas.
	float y = float(frame) / float(frame_count); // UV vertical start for the view in the atlas.

	float view_width = 1.0 / float(view_count); // UV width of the view in the atlas.
	float view_height = 1.0 / float(frame_count); // UV height of the animation in the atlas.
	vec4 tex = texture(views, vec2(x + view_width * UV.x, y + view_height * UV.y));

	// Ensure enemies in the darkness are always visible to an extent,
	// but allow them to be lit by light sources.
	EMISSION.rgb = tex.rgb * MIN_BRIGHTNESS;
	ALBEDO = tex.rgb * ALBEDO_ENERGY;
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
