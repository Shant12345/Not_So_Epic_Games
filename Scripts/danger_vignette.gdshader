shader_type canvas_item;

uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float softness : hint_range(0.0, 1.0) = 0.3;
uniform float radius : hint_range(0.0, 2.0) = 0.65;
uniform vec4 danger_color : source_color = vec4(0.8, 0.0, 0.0, 1.0);

void fragment() {
	float dist = distance(UV, vec2(0.5));
	float vignette = smoothstep(radius - softness, radius, dist);
	COLOR = vec4(danger_color.rgb, vignette * intensity * danger_color.a);
}
