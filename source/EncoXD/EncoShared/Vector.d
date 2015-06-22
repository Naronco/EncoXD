module Enco.Shared.Ext.Vector;

import EncoShared;

bool inRect(vec2 input, vec2 a, vec2 b)
{
	return input.x >= a.x && input.x < b.x && input.y >= a.y && input.y < b.y;
}

bool inRect(vec2 input, vec4 rect)
{
	return input.x >= rect.x && input.x < rect.z && input.y >= rect.y && input.y < rect.w;
}

unittest
{
	vec2 input = vec2(4, 5);
	assert(input.inRect(vec4(2, 3, 5, 7)));
	assert(!input.inRect(vec4(2, 3, 3, 7)));
}