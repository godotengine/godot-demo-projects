shader_type spatial;
render_mode unshaded;

uniform vec3 my_color : source_color = vec3(1.0, 1.0, 1.0);
uniform int steps : hint_range(1, 20);
uniform bool exponential_view = true;

void fragment() {
	// Draw base color
	ALBEDO = my_color;

	if (UV.y > 0.25)
	{
		// Draw gradient
		float scale = UV.x * float(steps);

		if (exponential_view)
		{
			scale = (scale * scale) / float(steps);
		}

		ALBEDO *= scale;
	}
	else
	{
		// Draw step separation bars
		for (int i = 1; i < steps; i++)
		{
			float threshold = 0.002; // Bar size
			float target = float(i);

			if (exponential_view)
			{
				target = sqrt(float(i) * float(steps));
			}

			target = target / float(steps);

			if (UV.x < target + threshold && UV.x > target - threshold)
			{
				ALBEDO = vec3(0); // Bars are colored black
			}
		}
	}
}
