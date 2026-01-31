shader_type canvas_item;
uniform sampler2D palette;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 bw = texture(TEXTURE, UV);
	vec4 swappedCol = texture(palette, vec2(bw.r, 0));
	
	COLOR = swappedCol;
	COLOR.a = bw.a;
}
