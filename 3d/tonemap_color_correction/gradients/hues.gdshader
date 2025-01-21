shader_type spatial;
render_mode unshaded;

uniform int steps : hint_range(1, 20);
uniform bool exponential_view = true;

void fragment() {
	float top_bar = 0.01;
	if (UV.y >= top_bar)
	{
		float padding = 0.002;
		float y = (UV.y - top_bar - padding) / (1.0 - top_bar - padding * 2.0);
		y = clamp(y, 0.0, 1.0);
		float segments = 1.0 / 6.0;
		vec3 col = vec3(0);
		if (y < segments)
		{
			col.r = 1.0;
			col.g = y / segments;
			col.b = 0.0;
		}
		else if (y < segments * 2.0)
		{
			col.r = (y - segments * 2.0) / -segments;
			col.g = 1.0;
			col.b = 0.0;
		}
		else if (y < segments * 3.0)
		{
			col.r = 0.0;
			col.g = 1.0;
			col.b = (y - segments * 2.0) / segments;
		}
		else if (y < segments * 4.0)
		{
			col.r = 0.0;
			col.g = (y - segments * 4.0) / -segments;
			col.b = 1.0;
		}
		else if (y < segments * 5.0)
		{
			col.r = (y - segments * 4.0) / segments;
			col.g = 0.0;
			col.b = 1.0;
		}
		else
		{
			col.r = 1.0;
			col.g = 0.0;
			col.b = (y - segments * 6.0) / -segments;
		}

		float scale = UV.x * float(steps);

		if (exponential_view)
		{
			scale = (scale * scale) / float(steps);
		}

		ALBEDO = col * scale;
	}
	else
	{
		ALBEDO = vec3(1.0);
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
