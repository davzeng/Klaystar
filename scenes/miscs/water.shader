shader_type canvas_item;

uniform vec4 blue_tint : hint_color;
uniform vec2 sprite_scale;

float rand(vec2 coord)
{
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))*43758.5453123);
}

float noise(vec2 coord)
{
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	//4 corners
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

void fragment()
{
	
	vec2 nc1 = 5.0*UV*sprite_scale;
	vec2 nc2 = 5.0*UV*sprite_scale + 4.0;
	
	vec2 motion1 = vec2(TIME * 0.3, TIME * -0.4);
	vec2 motion2 = vec2(TIME * 0.1, TIME * 0.5);
	
	vec2 dist1 = vec2(noise(nc1 + motion1), noise(nc2 + motion1)) - vec2(0.5);
	vec2 dist2 = vec2(noise(nc1 + motion2), noise(nc2 + motion2)) - vec2(0.5);
	
	vec2 dist = (dist1 + dist2)/300.0;
	
	vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV + dist, 0.0);
	
	color = mix(color, blue_tint, 0.3);
	color.rgb = mix(vec3(0.5), color.rgb, 1.4);
	
	float near_top = (UV.y + dist.y) / (0.05 / sprite_scale.y);
	near_top = clamp(near_top, 0.0, 1.0);
	near_top = 1.0 - near_top;
	
	//color = mix(color, vec4(1.0), near_top);
	if(near_top > 0.6)
	{
		color.a = 0.0;
	}
	
	float near_bottom = (1.0 - UV.y - dist.y) / (0.05 / sprite_scale.y);
	near_bottom = clamp(near_bottom, 0.0, 1.0);
	near_bottom = 1.0 - near_bottom;
	
	//color = mix(color, vec4(1.0), near_left);
	if(near_bottom > 0.6)
	{
		color.a = 0.0;
	}
	
	float near_left = (UV.x + dist.x) / (0.05 / sprite_scale.x);
	near_left = clamp(near_left, 0.0, 1.0);
	near_left = 1.0 - near_left;
	
	//color = mix(color, vec4(1.0), near_left);
	if(near_left > 0.6)
	{
		color.a = 0.0;
	}
	
	float near_right = (1.0 - UV.x - dist.x) / (0.05 / sprite_scale.x);
	near_right= clamp(near_right, 0.0, 1.0);
	near_right = 1.0 - near_right;
	
	//color = mix(color, vec4(1.0), near_left);
	if(near_right > 0.6)
	{
		color.a = 0.0;
	}
	
	COLOR = color;
}
