shader_type canvas_item;

uniform vec4[5] colorChoices : source_color;
uniform int faction = 0;

void vertex() {
	
}

void fragment() {
	COLOR = texture(TEXTURE, UV) * colorChoices[faction];
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
