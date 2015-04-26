module Enco.Shared.Math.Transform;

import EncoShared;

struct Transform
{
private:
	vec3 m_position = vec3(0), m_rotation = vec3(0), m_scale = vec3(1), m_origin = vec3(0);

public:
	public @property mat4 transform()
	{
		return mat4.identity.scale(m_scale.x, m_scale.y, m_scale.z)
			* mat4.translation(m_origin.x, m_origin.y, m_origin.z)
			* (mat4.identity.rotatez(m_rotation.z) * mat4.identity.rotatey(m_rotation.y) * mat4.identity.rotatex(m_rotation.x))
			* mat4.translation(m_position.x, m_position.y, m_position.z);
	}
	
	public @property ref vec3 position() { return m_position; }
	public @property ref vec3 rotation() { return m_rotation; }
	public @property ref vec3 scale() { return m_scale; }
	public @property ref vec3 origin() { return m_origin; }
}
