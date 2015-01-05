module Enco.Shared.Math.Frustum;

import EncoShared;

pure int intersectsPoint(Frustum f, vec3 v)
{
	foreach(plane; f.planes)
	{
		float d = dot(v, plane.normal);

		if(d < -plane.d)
		{
			return OUTSIDE;
		}

		if(d == -plane.d)
		{
			return INTERSECT;
		}
	}

	return INSIDE;
}