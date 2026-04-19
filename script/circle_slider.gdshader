shader_type spatial;
render_mode blend_mix, unshaded;

uniform sampler2D target_texture : filter_nearest;
uniform float value : hint_range(0.0, 1.0) = 0.75;
uniform float radius : hint_range(0.1, 1.0) = 0.4;
uniform float thickness : hint_range(0.01, 0.5) = 0.1;
uniform vec4 fill_color : source_color = vec4(0.2, 0.8, 0.5, 1.0);
uniform vec4 bg_color : source_color = vec4(0.2, 0.2, 0.2, 1.0);
uniform float smoothness : hint_range(0.0, 0.1) = 0.005;
uniform float rotation : hint_range(0.0, 1.0) = 0.0;
uniform bool show_handle = true;

void fragment() {
	vec2 uv = UV - 0.5;
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);
	float t = (angle + PI) / (2.0 * PI);
	t = mod(t + 0.75 + rotation, 1.0); 
	float ring_width = thickness;
	float outer_radius = radius + ring_width;
	if (dist > outer_radius + smoothness || dist < radius - smoothness) {
		ALPHA = 0.0;
	}
    
	float ring = smoothstep(radius - smoothness, radius + smoothness, dist) - smoothstep(outer_radius - smoothness, outer_radius + smoothness, dist);
    
	float filled = 0.0;
	if (t <= value) {
		filled = 1.0;
	} else if (value > 0.99 && t <= 1.0) {
		filled = 1.0; 
	}
    
	vec4 color = mix(bg_color, fill_color, filled);
	ALBEDO = color.rgb * texture(target_texture, UV).rgb;
	ALPHA = color.a * ring;
}