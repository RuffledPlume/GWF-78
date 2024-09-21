shader_type spatial;

uniform vec3 baseColor : source_color;
uniform vec3 windowColor : source_color;
uniform vec4 windowEmission : source_color;
uniform float windowEmissionStrength = 5.0;
uniform sampler2D windowNoise : repeat_enable;

varying vec3 worldPosition;

void vertex() 
{
	worldPosition = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
}

void fragment() 
{
	int uv_x_rand = int(floor(UV.x));
	int uv_y_rand = int(floor(UV.y));
	
	if(uv_x_rand != 0 || uv_y_rand != 0)
	{	
		float noiseThreshold = 1.0;
		if(uv_x_rand == -1) noiseThreshold = 0.3;
		else if(uv_x_rand == 1) noiseThreshold = 0.5;
		else if(uv_y_rand == -1) noiseThreshold = 0.7;
		else if(uv_y_rand == 1) noiseThreshold = 0.9;
		
		float noise = texture(windowNoise, vec2(worldPosition.x - worldPosition.y, worldPosition.z + worldPosition.y)).r;
		noise -= TIME * 0.001;
		SPECULAR = 0.85;
		ROUGHNESS = 0.25;
		if(noise > noiseThreshold)
		{
			ALBEDO   = windowEmission.rgb;
			EMISSION = windowEmission.rgb * windowEmissionStrength;
		}
		else
		{
			ALBEDO = windowColor;
		}
	}
	else
	{
		ALBEDO = baseColor;
	}
}