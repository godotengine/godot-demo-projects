shader_type spatial;

uniform bool WorldSpace = true; // toggle between world and local space
uniform bool RemapRange = false; // remap from -1..1 to 0..1

void fragment() {
	// World space normal
	vec4 Wn = INV_VIEW_MATRIX * vec4(NORMAL, 0.0);
	if ( WorldSpace == false) // Local space normal
	{
		Wn = inverse( MODEL_MATRIX ) * Wn;
	}
	if ( RemapRange == true )
	{
		ALBEDO = ( Wn.rgb + 1.0 ) / 2.0;
	}
	else
	{
		ALBEDO = Wn.rgb;
	}
}
