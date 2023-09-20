shader_type spatial;
render_mode cull_disabled, specular_schlick_ggx;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;

uniform float speed: hint_range(-1, 1) = 0.0;

uniform sampler2D noise1;
uniform sampler2D noise2;
uniform sampler2D normalmap: hint_normal;

uniform float specularity : hint_range(0.0, 1.0, 0.01);
uniform float roughness : hint_range(0.0, 1.0, 0.01);

uniform vec4 color : source_color;
uniform vec4 deep_water: source_color;

//depth-fade var
uniform float beer_law_factor = 2.0;
uniform float _distance = 0.0;

//foam var
uniform vec4 edge_color: source_color;
uniform float edge_scale = 0.25;
uniform float near = 0.1;
uniform float far = 100.0;

// wave var
uniform vec2 wave_strength = vec2(0.5, 0.25);
uniform vec2 wave_frequ = vec2(12.0, 12.0);
uniform vec2 time_factor = vec2(1.0, 2.0);

float waves(vec2 pos, float time) {
	return (wave_strength.y * sin(pos.y * wave_frequ.y + time * time_factor.y)) + (wave_strength.x * sin(pos.x * wave_frequ.x + time * time_factor.x));
}

void vertex() {
	VERTEX.y += waves(VERTEX.xy, TIME);
}

float rim(float depth) {
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

float calc_depth_fade(float depth, mat4 projection_matrix, 
						vec4 fragcoord, float beer_factor, float __distance, vec3 vertex) {
	
	float scene_depth = depth;

	scene_depth = scene_depth * 2.0 - 1.0;
	scene_depth = projection_matrix[3][2] / (scene_depth + projection_matrix[2][2]);
	scene_depth = scene_depth + vertex.z; // z is negative
	
	// application of beers law
	scene_depth = exp(-scene_depth * beer_factor);
	
	float screen_depth = fragcoord.z;
	
	float depth_fade = (scene_depth - screen_depth) / __distance;
	
	depth_fade = clamp(depth_fade, 0.0, 1.0);
	
	return depth_fade;
}

void fragment() {
	float time = TIME * speed;
	
	vec3 n1 = texture(noise1, UV + time).rgb;
	vec3 n2 = texture(noise2, UV - time * 0.2).rgb;
	
	vec2 uv_movement = UV * 4.0;
	uv_movement += TIME * speed * 4.0;
	
	float sum = (n1.r + n2.r) - 1.0;
	
	float z_depth = rim(texture(depth_texture, SCREEN_UV).x);
	float z_pos = rim(FRAGCOORD.z);
	float diff = z_depth - z_pos;
	
	// depth-fade
	float z_depth_fade = calc_depth_fade(texture(depth_texture, SCREEN_UV).x, PROJECTION_MATRIX, FRAGCOORD, beer_law_factor, _distance, VERTEX);
	float z_fade = rim(FRAGCOORD.z);
	float fade_diff = z_depth_fade - z_fade;
	
	vec4 gradientcolor = mix(color, deep_water, z_depth_fade);
	
	vec2 displacement = vec2(sum * 0.1);
	diff += displacement.x * 70.0;
	
	vec4 col = mix(edge_color, gradientcolor, step(edge_scale, diff));
	
	vec4 alpha = texture(screen_texture, SCREEN_UV + displacement);
	
	
	float fin = 0.0;
	if (sum > 0.0 && sum < 0.4) fin = 0.1;
	if (sum > 0.4 && sum < 0.8) fin = 0.0;
	if (sum > 0.8) fin = 1.0;
	
	// konvertier fin in vec3 um
	ALBEDO = vec3(fin) + mix(alpha.rgb, col.rgb, gradientcolor.a);
	
	NORMAL_MAP = texture(normalmap, uv_movement).rgb;
	
	SPECULAR = specularity;
	ROUGHNESS = roughness;
}