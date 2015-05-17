module Enco.Shared.Math.Transform;

import EncoShared;

struct Transform
{
private:
	vec3 m_position = vec3(0), m_rotation = vec3(0), m_scale = vec3(1);
	Transform* m_parent;

public:
	public @property mat4 transform()
	{
		return (m_parent ? m_parent.transform : mat4.identity) * (mat4.translation(m_position.x, m_position.y, m_position.z))
			* (mat4.identity.rotatez(-m_rotation.z) * mat4.identity.rotatey(-m_rotation.y) * mat4.identity.rotatex(-m_rotation.x))
			* mat4.identity.scale(m_scale.x, m_scale.y, m_scale.z);
	}
	
	public @property ref vec3 position() { return m_position; }
	public @property ref vec3 rotation() { return m_rotation; }
	public @property ref vec3 scale() { return m_scale; }
	public @property ref Transform* parent() { return m_parent; }
}

unittest
{
	bool aboutEqual(T)(T a, T b)
	{
		static if (is(T == float))
			return std.math.abs(a - b) < 0.001f;
		else
			return (a - b).length_squared < 0.1f;
	}

	Transform transform;
	assert((transform.transform * vec4(0, 0, 0, 1)).xyz == vec3(0), "Invalid matrix");

	transform.position = vec3(3, 2, 0);
	assert((transform.transform * vec4(0, 0, 0, 1)).xyz == vec3(3, 2, 0), "Invalid matrix");

	Transform parent;
	transform.parent = &parent;

	parent.position = vec3(1, 0, 0);

	assert((transform.transform * vec4(0, 0, 0, 1)).xyz == vec3(4, 2, 0), "Invalid parent offset");

	parent.rotation = vec3(0, 0, 1.57079633);

	assert(aboutEqual((transform.transform * vec4(0, 0, 0, 1)).xyz, vec3(3, -3, 0)), "Invalid parent rotation");
}