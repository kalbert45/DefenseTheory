shader_type canvas_item;

uniform vec4 color : source_color;
uniform float mixture;

void fragment() 
{
    COLOR = texture(TEXTURE, UV);
    COLOR.rgb = mix(COLOR.rgb, color.rgb, mixture);
}
