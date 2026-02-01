shader_type canvas_item;

// Position of the SDF shape in UV space (0-1 range relative to sprite)
uniform vec2 sdf_position = vec2(0.5, 0.5);

// Size/radius of the SDF shape
uniform float sdf_size = 0.3;

// Color of the SDF shape
uniform vec4 sdf_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Smoothness of the SDF edge (anti-aliasing)
uniform float edge_smoothness = 0.01;

// SDF Type selector
uniform int sdf_type : hint_range(0, 6) = 0; // 0=circle, 1=box, 2=rounded_box, 3=hexagon, 4=star, 5=heart, 6=capsule

// Additional parameter for certain shapes
uniform float shape_param = 0.2;

// Capsule parameters (endpoints relative to center)
uniform vec2 capsule_point_a = vec2(-0.2, 0.0);
uniform vec2 capsule_point_b = vec2(0.2, 0.0);

// Camera/Screen texture
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Effect type for modifying the camera texture inside the SDF
uniform int effect_type : hint_range(0, 6) = 0; // 0=none, 1=invert, 2=grayscale, 3=blur, 4=pixelate, 5=color_tint, 6=distort

// Effect intensity
uniform float effect_intensity = 1.0;

// Blur/pixelate amount
uniform float effect_amount = 0.01;

// === SDF Functions ===

// Circle SDF
float sdf_circle(vec2 p, float r) {
    return length(p) - r;
}

// Box SDF
float sdf_box(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

// Rounded Box SDF
float sdf_rounded_box(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + r;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

// Capsule SDF
float sdf_capsule(vec2 p, vec2 a, vec2 b, float r) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

// === Effect Functions ===

vec4 apply_effect(vec2 screen_uv, int effect, float intensity, float amount) {
    vec4 color = texture(screen_texture, screen_uv);
    
    if (effect == 0) {
        // No effect
        return color;
    }
    else if (effect == 1) {
        // Invert
        vec4 inverted = vec4(1.0 - color.rgb, color.a);
        return mix(color, inverted, intensity);
    }
    else if (effect == 2) {
        // Grayscale
        float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
        vec4 grayscale = vec4(vec3(gray), color.a);
        return mix(color, grayscale, intensity);
    }
    else if (effect == 3) {
        // Simple blur (box blur)
        vec4 blurred = vec4(0.0);
        float samples = 0.0;
        for (float x = -2.0; x <= 2.0; x += 1.0) {
            for (float y = -2.0; y <= 2.0; y += 1.0) {
                blurred += texture(screen_texture, screen_uv + vec2(x, y) * amount);
                samples += 1.0;
            }
        }
        blurred /= samples;
        return mix(color, blurred, intensity);
    }
    else if (effect == 4) {
        // Pixelate
        vec2 pixelated_uv = floor(screen_uv / amount) * amount;
        vec4 pixelated = texture(screen_texture, pixelated_uv);
        return mix(color, pixelated, intensity);
    }
    else if (effect == 5) {
        // Color tint (using sdf_color)
        vec4 tinted = vec4(color.rgb * sdf_color.rgb, color.a);
        return mix(color, tinted, intensity);
    }
    else if (effect == 6) {
        // Distortion (radial)
        vec2 center = screen_uv - sdf_position;
        float dist = length(center);
        vec2 distorted_uv = screen_uv + center * dist * amount * intensity;
        return texture(screen_texture, distorted_uv);
    }
    
    return color;
}

void fragment() {
    // Get UV coordinates centered at the SDF position (using sprite UV, not screen UV)
    vec2 uv = UV - sdf_position;
    
    // Calculate the SDF distance based on selected type
    float dist;
    
    if (sdf_type == 0) {
        // Circle
        dist = sdf_circle(uv, sdf_size);
    }
    else if (sdf_type == 1) {
        // Box
        dist = sdf_box(uv, vec2(sdf_size, sdf_size));
    }
    else if (sdf_type == 2) {
        // Rounded Box
        dist = sdf_rounded_box(uv, vec2(sdf_size, sdf_size), shape_param);
	}
	else {
        // Capsule
        dist = sdf_capsule(uv, capsule_point_a, capsule_point_b, sdf_size);
    }
    
    // Create smooth edge with anti-aliasing
    float alpha = 1.0 - smoothstep(-edge_smoothness, edge_smoothness, dist);
    
    // Get the camera/screen texture at this pixel's screen position
    vec4 camera_color = apply_effect(SCREEN_UV, effect_type, effect_intensity, effect_amount);
    
    // Mix camera texture with SDF color based on alpha
    vec4 sdf_result = mix(camera_color, sdf_color, sdf_color.a);
    
    // Set final color: show modified camera inside SDF, transparent outside
    COLOR = vec4(sdf_result.rgb, alpha);
}