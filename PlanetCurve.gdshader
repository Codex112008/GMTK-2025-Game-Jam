shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float radius = 0.2; // Adjust as needed (smaller values = smaller planet)
uniform float distortion_strength = 0.5; // Controls overall intensity

void fragment() {
    vec2 uv = SCREEN_UV;
    uv.y = 1.0 - uv.y; // Flip for Godot 4 coordinate system
    
    vec2 screen_center = vec2(0.5, 0.5);
    vec2 planet_center = vec2(0.5, 0.8 + radius); // Planet sphere center
    
    // Calculate distance from screen center (for masking)
    float screen_dist = distance(uv, screen_center);
    float mask = pow(screen_dist, 2.0); // Quadratic falloff for smoother effect
    
    // Calculate planet distortion as before
    float base = distance(uv, planet_center);
    float height = base - radius;
    vec2 distorted_uv = uv;
    if (base > 0.001) { // Avoid division by zero
        float xdiff = (uv.x - 0.5) / base * height;
        distorted_uv = clamp(vec2(uv.x - xdiff, 0.8 - height), vec2(0.0), vec2(1.0));
    }
    
    // Blend between original and distorted UVs using radial mask
    vec2 final_uv = mix(uv, distorted_uv, mask * distortion_strength);
    final_uv.y = 1.0 - final_uv.y; // Flip back before sampling
    
    COLOR.rgb = textureLod(screen_texture, final_uv, 0.0).rgb;
}