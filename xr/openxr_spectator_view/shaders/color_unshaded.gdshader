shader_type spatial;
render_mode unshaded;

uniform vec4 albedo_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	ALBEDO = albedo_color.rgb;
	ALPHA = albedo_color.a;
}
