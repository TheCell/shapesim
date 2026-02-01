shader_type canvas_item;

// ======================================================
// SDF PARAMETERS
// ======================================================

uniform vec2 sdf_position = vec2(0.5, 0.5);
uniform float sdf_size = 0.3;
uniform vec4 sdf_color : source_color = vec4(1.0);
uniform float edge_smoothness = 0.01;

uniform int sdf_type : hint_range(0, 6) = 0;
uniform float shape_param = 0.2;

uniform vec2 capsule_point_a = vec2(-0.2, 0.0);
uniform vec2 capsule_point_b = vec2(0.2, 0.0);

// ======================================================
// BORDER (PIXEL PERFECT)
// ======================================================

uniform bool border_enabled = true;
uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float border_size = 2;

// ======================================================
// SCREEN / EFFECTS
// ======================================================

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

uniform int effect_type : hint_range(0, 6) = 0;
uniform float effect_amount = 0.01;
uniform float pull_strength = 0.01;
uniform vec2 pull_center = vec2(0.5, 0.5);

// ======================================================
// EFFECT INTENSITIES (PER EFFECT)
// ======================================================

uniform float intensity_chromatic = 1.0;           
uniform float intensity_luminance = 1.0;          
uniform float intensity_green_pulse = 1.0;        
uniform float intensity_red_pulse = 1.0;          
uniform float intensity_center_pull = 1.0;        
uniform float intensity_center_pull_inverse = 1.0;
uniform float intensity_chromatic_anim = 1.0;     

// ======================================================
// SDF FUNCTIONS
// ======================================================

float sdf_circle(vec2 p, float r) {
    return length(p) - r;
}

float sdf_box(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdf_rounded_box(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + r;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - r;
}

float sdf_capsule(vec2 p, vec2 a, vec2 b, float r) {
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

// ======================================================
// EFFECT INTENSITY HELPER
// ======================================================

float get_effect_intensity(int effect) {
    if (effect == 0) return intensity_chromatic;
    if (effect == 1) return intensity_luminance;
    if (effect == 2) return intensity_green_pulse;
    if (effect == 3) return intensity_red_pulse;
    if (effect == 4) return intensity_center_pull;
    if (effect == 5) return intensity_center_pull_inverse;
    if (effect == 6) return intensity_chromatic_anim;
    return 0.0;
}

// ======================================================
// EFFECT SYSTEM (INTENSITY BLENDED)
// ======================================================

vec4 apply_effect(vec2 screen_uv, int effect, float amount, vec2 uv) {
    vec4 base = texture(screen_texture, screen_uv);
    vec4 effected = base;
    float intensity = clamp(get_effect_intensity(effect), 0.0, 1.0);

    if (effect == 0) {
        // Chromatic aberration
        vec2 dir = screen_uv - vec2(0.5);
        vec2 offset = normalize(dir) * (amount/100.0) * intensity;

        effected.r = texture(screen_texture, screen_uv + offset).r;
        effected.g = texture(screen_texture, screen_uv).g;
        effected.b = texture(screen_texture, screen_uv - offset).b;
    }
    else if (effect == 1) {
        // Inverted luminance
        vec2 dir = screen_uv - vec2(0.5);
        vec2 offset = normalize(dir) * (amount/100.0);
        float r = texture(screen_texture, screen_uv + offset).r;
        float g = texture(screen_texture, screen_uv).g;
        float b = texture(screen_texture, screen_uv - offset).b;
        float lum = dot(vec3(r, g, b), vec3(0.2126, 0.7152, 0.0722));
        effected.rgb = mix(base.rgb, vec3(lum), intensity);
    }
    else if (effect == 2) {
        // Green pulse
        float pulse = sin(TIME * 4.0) * 0.5 + 0.8;
        vec3 pulse_color = base.rgb * pulse + vec3(0.0, 0.5, 0.0);
        effected.rgb = mix(base.rgb, pulse_color, intensity);
    }
    else if (effect == 3) {
        // Red pulse
        float pulse = sin(TIME * 6.0) * 0.5 + 0.8;
        vec3 pulse_color = base.rgb * pulse + vec3(0.5, 0.0, 0.0);
        effected.rgb = mix(base.rgb, pulse_color, intensity);
    }
    else if (effect == 4 || effect == 5) {
        // Center pull distortion
        vec2 dir = uv - pull_center;
        float dist = length(dir);
        if (dist > 0.0) dir /= dist;

        float time_mod = (effect == 4)
            ? (sin(TIME * 6.0) + 0.8)
            : 1.0 /sin(TIME * 4.0);

        float pull = dist * dist * pull_strength * time_mod * intensity;
        vec2 distorted_uv = screen_uv - dir * pull;
        effected = texture(screen_texture, distorted_uv);
    }
    else if (effect == 6) {
        // Animated chromatic aberration
        vec2 dir = screen_uv - vec2(0.5);
        vec2 offset = normalize(dir) * (amount/100.0) * vec2(sin(TIME * 5.0), cos(TIME * 3.5)) * intensity;

        effected.r = texture(screen_texture, screen_uv + offset).r;
        effected.g = texture(screen_texture, screen_uv).g;
        effected.b = texture(screen_texture, screen_uv - offset).b;
    }

    return effected;
}

// ======================================================
// FRAGMENT
// ======================================================

void fragment() {
    vec2 local_uv = UV - sdf_position;

    float dist;
    if (sdf_type == 0) {
        dist = sdf_circle(local_uv, sdf_size);
    } else if (sdf_type == 1) {
        dist = sdf_box(local_uv, vec2(sdf_size));
    } else if (sdf_type == 2) {
        dist = sdf_rounded_box(local_uv, vec2(sdf_size), shape_param);
    } else {
        dist = sdf_capsule(local_uv, capsule_point_a, capsule_point_b, sdf_size);
    }

    // Fill alpha
    float fill_alpha = 1.0 - smoothstep(-edge_smoothness, edge_smoothness, dist);

    // Exact 1-pixel border
    float border_mask = 1.0 - smoothstep(-border_size, border_size, abs(dist));
    border_mask *= float(border_enabled);

    vec4 camera_color = apply_effect(
        SCREEN_UV,
        effect_type,
        effect_amount,
        UV
    );

    vec4 fill_color = mix(camera_color, sdf_color, sdf_color.a);

    vec3 final_rgb = mix(fill_color.rgb, border_color.rgb, border_mask * border_color.a);
    float final_alpha = max(fill_alpha, border_mask);

    COLOR = vec4(final_rgb, final_alpha);
}
