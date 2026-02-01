shader_type canvas_item;
uniform sampler2D palette;
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	vec4 bw = texture(TEXTURE, UV);
	vec4 swappedCol = texture(palette, vec2(bw.r, 0));
	
	COLOR = swappedCol;
	COLOR.a = bw.a * modulate.a;
}
