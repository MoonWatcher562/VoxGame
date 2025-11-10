shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// === Controls ===
uniform float glow_strength : hint_range(0.0, 5.0) = 1.0;
uniform int group_count : hint_range(1, 8) = 4;
uniform float color_quantize = 0.33;

// === Optional overrides (can be left blank) ===
uniform vec3 albedo_tint[8];
uniform float metallic_override[8];
uniform float roughness_override[8];
uniform float glow_override[8];

// --- Color grouping function ---
int hash_color_group(vec3 c) {
	vec3 q = floor(c / color_quantize);
	float combined = q.r * 31.0 + q.g * 6.0 + q.b;
	int group = int(mod(combined, float(group_count)));
	return clamp(group, 0, group_count - 1);
}

void fragment() {
	vec3 color = COLOR.rgb; // original vertex color
	int group = hash_color_group(color);

	// --- Apply override or fallback to vertex color ---
	vec3 tint = albedo_tint[group];
	if (tint == vec3(0.0)) {
		tint = color; // fallback: keep original vertex color
	}

	float metallic_val = metallic_override[group];
	float rough_val = roughness_override[group];
	float glow_val = glow_override[group];

	// Fallback defaults for undefined metallic/roughness
	if (metallic_val == 0.0 && rough_val == 0.0 && glow_val == 0.0) {
		metallic_val = 0.2;
		rough_val = 0.5;
	}

	ALBEDO = tint;
	METALLIC = metallic_val;
	ROUGHNESS = rough_val;
	EMISSION = tint * glow_val * glow_strength;
}
