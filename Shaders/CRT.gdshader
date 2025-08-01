shader_type canvas_item;

// CRT shader uniforms
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform bool overlay = false;
uniform vec2 resolution = vec2(640.0, 480.0);
uniform float brightness = 1.4;
uniform float scanlines_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float scanlines_width : hint_range(0.0, 0.5) = 0.25;
uniform float grille_opacity : hint_range(0.0, 1.0) = 0.3;
uniform bool roll = true;
uniform float roll_speed = 8.0;
uniform float roll_size : hint_range(0.0, 100.0) = 15.0;
uniform float roll_variation : hint_range(0.1, 5.0) = 1.8;
uniform float distort_intensity : hint_range(0.0, 0.2) = 0.05;
uniform float aberration : hint_range(-1.0, 1.0) = 0.03;
uniform float noise_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float noise_speed = 5.0;
uniform float static_noise_intensity : hint_range(0.0, 1.0) = 0.06;
uniform bool pixelate = true;
uniform bool discolor = true;
uniform float warp_amount : hint_range(0.0, 5.0) = 1.0;
uniform bool clip_warp = false;
uniform float vignette_intensity = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;

// Planet distortion uniforms
uniform float planet_radius = 0.2;
uniform float distortion_strength = 0.5;
uniform vec2 planet_center = vec2(0.5, 0.8); // Customizable planet position

// The rest of the functions from the CRT shader
vec2 random(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1, 311.7)), dot(uv, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(
        mix(
            dot(random(uv_index + vec2(0.0, 0.0)), uv_fract - vec2(0.0, 0.0)),
            dot(random(uv_index + vec2(1.0, 0.0)), uv_fract - vec2(1.0, 0.0)),
            blur.x
        ),
        mix(
            dot(random(uv_index + vec2(0.0, 1.0)), uv_fract - vec2(0.0, 1.0)),
            dot(random(uv_index + vec2(1.0, 1.0)), uv_fract - vec2(1.0, 1.0)),
            blur.x
        ),
        blur.y
    ) * 0.5 + 0.5;
}

vec2 warp(vec2 uv) {
    vec2 delta = uv - 0.5;
    float delta2 = dot(delta.xy, delta.xy);
    float delta4 = delta2 * delta2;
    return uv + delta * (delta4 * warp_amount);
}

float border(vec2 uv) {
    float radius = min(warp_amount, 0.08);
    radius = max(min(min(abs(radius * 2.0), abs(1.0)), abs(1.0)), 1e-5);
    vec2 abs_uv = abs(uv * 2.0 - 1.0) - vec2(1.0, 1.0) + radius;
    float dist = length(max(vec2(0.0), abs_uv)) / radius;
    return clamp(1.0 - smoothstep(0.96, 1.0, dist), 0.0, 1.0);
}

float vignette(vec2 uv) {
    uv *= 1.0 - uv.xy;
    float vig = uv.x * uv.y * 15.0;
    return pow(vig, vignette_intensity * vignette_opacity);
}

void fragment() {
    // First apply planet distortion
    vec2 uv = SCREEN_UV;
    uv.y = 1.0 - uv.y; // Flip for Godot coordinate system
    
    // Calculate planet distortion
    float base = distance(uv, planet_center);
    float height = base - planet_radius;
    vec2 distorted_uv = uv;
    if (base > 0.001) {
        float xdiff = (uv.x - planet_center.x) / base * height;
        distorted_uv = clamp(vec2(uv.x - xdiff, planet_center.y - height), vec2(0.0), vec2(1.0));
    }
    
    // Blend between original and distorted UVs using radial mask
    float screen_dist = distance(uv, vec2(0.5, 0.5));
    float mask = pow(screen_dist, 2.0);
    vec2 final_uv = mix(uv, distorted_uv, mask * distortion_strength);
    final_uv.y = 1.0 - final_uv.y; // Flip back
    
    // Now apply CRT effects to the distorted image
    vec2 crt_uv = overlay ? warp(final_uv) : warp(UV);
    vec2 text_uv = crt_uv;
    
    if (pixelate) {
        text_uv = ceil(crt_uv * resolution) / resolution;
    }
    
    // Calculate roll effect
    float roll_line = 0.0;
    vec2 roll_uv = vec2(0.0);

    if (roll || noise_opacity > 0.0) {
        float time = roll ? TIME : 0.0;
        roll_line = smoothstep(0.3, 0.9, sin(crt_uv.y * roll_size - (time * roll_speed)));
        roll_line *= roll_line * smoothstep(0.3, 0.9, sin(crt_uv.y * roll_size * roll_variation - (time * roll_speed * roll_variation)));
        roll_uv = vec2(roll_line * distort_intensity * (1.0 - UV.x), 0.0);
    }

    // Sample texture with chromatic aberration
    vec4 text;
    if (roll) {
        text.r = texture(SCREEN_TEXTURE, text_uv + roll_uv * 0.8 + vec2(aberration, 0.0) * 0.1).r;
        text.g = texture(SCREEN_TEXTURE, text_uv + roll_uv * 1.2 - vec2(aberration, 0.0) * 0.1).g;
        text.b = texture(SCREEN_TEXTURE, text_uv + roll_uv).b;
    } else {
        text.r = texture(SCREEN_TEXTURE, text_uv + vec2(aberration, 0.0) * 0.1).r;
        text.g = texture(SCREEN_TEXTURE, text_uv - vec2(aberration, 0.0) * 0.1).g;
        text.b = texture(SCREEN_TEXTURE, text_uv).b;
    }
    text.a = 1.0;

    // Apply CRT grille
    if (grille_opacity > 0.0) {
        float gr = smoothstep(0.85, 0.95, abs(sin(crt_uv.x * (resolution.x * 3.14159265))));
        float gg = smoothstep(0.85, 0.95, abs(sin(1.05 + crt_uv.x * (resolution.x * 3.14159265))));
        float gb = smoothstep(0.85, 0.95, abs(sin(2.1 + crt_uv.x * (resolution.x * 3.14159265))));

        text.r = mix(text.r, text.r * gr, grille_opacity);
        text.g = mix(text.g, text.g * gg, grille_opacity);
        text.b = mix(text.b, text.b * gb, grille_opacity);
    }

    // Apply brightness
    text.rgb = clamp(text.rgb * brightness, 0.0, 1.0);

    // Apply scanlines
    if (scanlines_opacity > 0.0) {
        float scan = smoothstep(scanlines_width, scanlines_width + 0.5, abs(sin(crt_uv.y * (resolution.y * 3.14159265))));
        text.rgb = mix(text.rgb, text.rgb * vec3(scan), scanlines_opacity);
    }

    // Apply noise
    if (noise_opacity > 0.0) {
        float n = smoothstep(0.4, 0.5, noise(crt_uv * vec2(2.0, 200.0) + vec2(10.0, TIME * noise_speed)));
        float nl = n * roll_line * clamp(random((ceil(crt_uv * resolution) / resolution) + vec2(TIME * 0.8, 0.0)).x + 0.8, 0.0, 1.0);
        text.rgb = clamp(mix(text.rgb, text.rgb + nl, noise_opacity), vec3(0.0), vec3(1.0));
    }

    // Apply static
    if (static_noise_intensity > 0.0) {
        text.rgb += clamp(random((ceil(crt_uv * resolution) / resolution) + fract(TIME)).x, 0.0, 1.0) * static_noise_intensity;
    }

    // Apply border and vignette
    text.rgb *= border(crt_uv);
    text.rgb *= vignette(crt_uv);

    // Handle clip warp
    if (clip_warp) {
        text.a = border(crt_uv);
    }

    // Apply VHS discoloration
    if (discolor) {
        vec3 greyscale = vec3(dot(text.rgb, vec3(0.333)));
        text.rgb = mix(text.rgb, greyscale, 0.5);
        float midpoint = pow(0.5, 2.2);
        text.rgb = (text.rgb - vec3(midpoint)) * 1.2 + midpoint;
    }

    COLOR = text;
}