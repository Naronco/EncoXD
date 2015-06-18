module Enco.Shared.Math.Transform;

import EncoShared;

import std.format;

struct Transform
{
private:
	vec3	 m_position = vec3(0), m_rotation = vec3(0), m_scale = vec3(1);
	Transform* m_parent;

public:
	@property mat4 transform()
	{
		return (m_parent ? m_parent.transform : mat4.identity) * (mat4.translation(m_position.x, m_position.y, m_position.z))
			   * (mat4.identity.rotatez(-m_rotation.z) * mat4.identity.rotatey(-m_rotation.y) * mat4.identity.rotatex(-m_rotation.x))
			   * mat4.identity.scale(m_scale.x, m_scale.y, m_scale.z);
	}

	string toString(int depth)
	{
		if (depth > 12)
			depth = 12;
		string i = "             ";
		i.length = depth;
		if (m_parent)
			return format(i ~ "[\n" ~ i ~ " P: %s\n" ~ i ~ " R: %s\n" ~ i ~ " S: %s\n" ~ i ~ " Parent:\n" ~ i ~ "]", position, rotation, scale, m_parent.toString(depth++));
		else
			return format(i ~ "[\n" ~ i ~ " P: %s\n" ~ i ~ " R: %s\n" ~ i ~ " S: %s\n" ~ i ~ "]", position, rotation, scale);
	}

	string toString()
	{
		if (m_parent)
			return format("[\n P: %s\n R: %s\n S: %s\n Parent:\n%s\n]", position, rotation, scale, m_parent.toString(1));
		else
			return format("[\n P: %s\n R: %s\n S: %s\n]", position, rotation, scale);
	}

	@property vec3 appliedPosition()
	{
		return (transform * vec4(0, 0, 0, 1)).xyz;
	}

	void setIdentity()
	{
		m_position = vec3(0);
		m_rotation = vec3(0);
		m_scale	   = vec3(1);
	}

	@property ref vec3	   position()
	{
		return m_position;
	}
	@property ref vec3	   rotation()
	{
		return m_rotation;
	}
	@property ref vec3	   scale()
	{
		return m_scale;
	}
	@property ref Transform* parent()
	{
		return m_parent;
	}
}

unittest
{
	bool aboutEqual(T)(T a, T b)
	{
		static if (is (T == float))
			return std.math.abs(a - b) < 0.001f;
		else
			return (a - b).length_squared < 0.1f;
	}

	Transform transform;
	assert(transform.appliedPosition == vec3(0), "Invalid matrix");

	transform.position = vec3(3, 2, 0);
	assert((transform.transform * vec4(1, 0, 1, 1)).xyz == vec3(4, 2, 1), "Invalid matrix");

	Transform parent;
	transform.parent = &parent;

	parent.position = vec3(1, 0, 0);

	assert((transform.transform * vec4(1, 0, 1, 1)).xyz == vec3(5, 2, 1), "Invalid parent offset");

	parent.rotation = vec3(0, 0, 1.57079633);

	assert(aboutEqual(transform.appliedPosition, vec3(3, -3, 0)), "Invalid parent rotation");
}
