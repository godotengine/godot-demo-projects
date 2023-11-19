shader_type spatial;

uniform sampler2DArray texture_albedo : source_color;
uniform vec3 _color : source_color;

varying vec3 world_pos;
varying vec4 terrain;

void vertex() {
	world_pos = CUSTOM0.rgb;
	terrain = CUSTOM1;
}

void fragment() {
	vec4 sample = (texture(texture_albedo, vec3(world_pos.xz, terrain.x)) * COLOR.r)
		+ (texture(texture_albedo, vec3(world_pos.xz, terrain.y)) * COLOR.g)
		+ (texture(texture_albedo, vec3(world_pos.xz, terrain.z)) * COLOR.b);
	ALBEDO = sample.rgb * _color;
}
