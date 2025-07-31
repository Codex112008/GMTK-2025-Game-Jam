shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float radius = 3.0;

void fragment() {
	vec2 uv = SCREEN_UV;
	uv.y = 1.0 - uv.y; // seems like the origin changed in Godot 4.
	vec2 surface = vec2(0.5, 0.8);
	vec2 center = surface + vec2(0, radius);
	float base = length(uv - center);
	float height = base - radius;
	float xdiff = (uv.x - surface.x) / base * height;
	uv = clamp(vec2 (uv.x - xdiff, surface.y - height), vec2(0.0, 0.0), vec2(1.0, 1.0));
	uv.y = 1.0 - uv.y; // flip back after all calculations
	COLOR.rgb = textureLod(screen_texture, uv, 0.0).rgb;
}