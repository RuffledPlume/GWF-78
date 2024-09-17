shader_type spatial;

uniform sampler2D ui_viewport;

void fragment() {
	vec4 viewport_color = texture(ui_viewport, UV);
	ALBEDO = viewport_color.rgb;
	ALPHA = viewport_color.a;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
