shader_type spatial;

uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float metallic : hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float roughness : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float specular : hint_range(0.0, 1.0, 0.1) = 0.5;

void fragment() {
	ALBEDO = albedo_color.rgb;
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
