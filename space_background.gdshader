shader_type sky;

group_uniforms Nebulae;
uniform vec3 nebula_color1 : source_color = vec3(0.02, 0.05, 0.2);
uniform vec3 nebula_color2 : source_color = vec3(0.1, 0.02, 0.15);
uniform float nebula_opacity : hint_range(0.0, 1.0) = 0.8;
uniform float nebula_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float nebula_scale : hint_range(0.1, 5.0) = 1.5;
uniform float nebula_speed : hint_range(0.0, 0.1) = 0.002;

group_uniforms Stars;
uniform float star_density : hint_range(0.0, 20.0) = 1.0;
uniform float star_brightness : hint_range(0.0, 10.0) = 1.5;
uniform float star_size : hint_range(0.01, 2.0) = 0.1;
uniform vec3 star_color_hot : source_color = vec3(0.7, 0.9, 1.0);
uniform vec3 star_color_cool : source_color = vec3(1.0, 0.8, 0.6);
uniform float twinkle_speed : hint_range(0.0, 50.0) = 12.0;
uniform float twinkle_intensity : hint_range(0.0, 1.0) = 0.5;

group_uniforms Depth_and_Parallax;
uniform vec3 camera_position = vec3(0.0);
uniform float parallax_factor : hint_range(0.0, 0.1) = 0.001;
uniform vec3 base_color : source_color = vec3(0.001, 0.001, 0.005);
uniform float galactic_edge_intensity : hint_range(0.0, 2.0) = 0.5;

// High quality hash
vec3 hash33(vec3 p) {
    p = fract(p * vec3(443.897, 441.423, 437.195));
    p += dot(p, p.yxz + 19.19);
    return fract((p.xxy + p.yzz) * p.zyx);
}

// noise function
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(mix(dot(hash33(i), vec3(1.0)), dot(hash33(i + vec3(1,0,0)), vec3(1.0)), f.x),
                   mix(dot(hash33(i + vec3(0,1,0)), vec3(1.0)), dot(hash33(i + vec3(1,1,0)), vec3(1.0)), f.x), f.y),
               mix(mix(dot(hash33(i + vec3(0,0,1)), vec3(1.0)), dot(hash33(i + vec3(1,0,1)), vec3(1.0)), f.x),
                   mix(dot(hash33(i + vec3(0,1,1)), vec3(1.0)), dot(hash33(i + vec3(1,1,1)), vec3(1.0)), f.x), f.y), f.z);
}

float fbm(vec3 p) {
    float v = 0.0;
    float a = 0.5;
    vec3 shift = vec3(100);
    for (int i = 0; i < 6; ++i) {
        v += a * noise(p);
        p = p * 2.1 + shift;
        a *= 0.5;
    }
    return v;
}

float warped_noise(vec3 p) {
    vec3 q = vec3(fbm(p), fbm(p + vec3(5.2, 1.3, 0.1)), fbm(p + vec3(1.2, 4.2, 2.8)));
    vec3 r = vec3(fbm(p + 4.0 * q + vec3(1.7, 9.2, 4.4)), fbm(p + 4.0 * q + vec3(8.3, 2.8, 1.1)), fbm(p + 4.0 * q + vec3(3.3, 1.8, 6.7)));
    return fbm(p + 4.0 * r);
}

void sky() {
    vec3 dir = EYEDIR;
    
    // 1. Base Universe Depth
    vec3 color = base_color;

    // Apply translation-based parallax
    vec3 mid_dir = normalize(dir + camera_position * parallax_factor * 0.005);
    vec3 bg_dir = normalize(dir + camera_position * parallax_factor * 0.001);
    
    // Layer 1: Distant background galaxies/dust
    // Increased base probability significantly
    vec3 g1 = floor(bg_dir * 1200.0);
    float h1 = dot(hash33(g1), vec3(0.333));
    float galactic = pow(warped_noise(dir * 0.8), 2.0);
    if (h1 > 1.0 - (0.002 * star_density)) {
        color += vec3(0.15) * galactic * star_brightness;
    }
    
    // 2. High Resolution Nebulae
    vec3 neb_p_dir = dir + camera_position * parallax_factor * 0.002;
    float n1_val = warped_noise(neb_p_dir * nebula_scale + TIME * nebula_speed);
    float n2_val = warped_noise(neb_p_dir * (nebula_scale * 1.33) - TIME * (nebula_speed * 0.5));
    vec3 neb_color = (nebula_color1 * pow(n1_val, 3.0) + nebula_color2 * pow(n2_val, 4.0)) * nebula_intensity;
    float nebula_mask = clamp(pow(n1_val, 2.0) + pow(n2_val, 3.0), 0.0, 1.0) * nebula_opacity;
    color = mix(color, neb_color, nebula_mask);
    color += neb_color * nebula_mask * 0.5;

    // 3. Galactic Edge Glow
    color += vec3(0.01, 0.02, 0.04) * galactic * galactic_edge_intensity;
    
    // 4. Stable Layered Stars
    
    // Layer 2: Mid-range stars
    vec3 g2 = floor(mid_dir * 600.0);
    float h2 = dot(hash33(g2), vec3(0.333));
    if (h2 > 1.0 - (0.0015 * star_density)) {
        color += vec3(0.8) * h2 * star_brightness;
    }
    
    // Layer 3: Vibrant foreground stars
    vec3 fg_p_dir = normalize(dir + camera_position * parallax_factor * 0.01);
    vec3 g3 = floor(fg_p_dir * 300.0);
    vec3 h3 = hash33(g3);
    if (h3.x > 1.0 - (0.0008 * star_density)) {
        float twinkle = sin(TIME * (h3.y * twinkle_speed) + h3.z * 100.0) * 0.5 + 0.5;
        twinkle = pow(twinkle, 4.0) * twinkle_intensity;
        
        vec3 star_color = mix(star_color_cool, star_color_hot, h3.y);
        float size = mix(0.5, 2.0, h3.z) * star_size;
        color += star_color * (1.0 + twinkle * 3.0) * size * star_brightness;
        
        // Dynamic Halo
        float dist = length(fract(fg_p_dir * 300.0) - 0.5);
        color += star_color * exp(-dist * (24.0 / (star_size + 0.01))) * 0.4 * star_brightness;
    }

    COLOR = color;
}
