module Enco.Shared.Math.Transform;

import EncoShared;

struct Transform
{
	public mat4 transform = mat4.identity;
	
	public @property vec3 position() { return vec3(transform.matrix[3][0], transform.matrix[3][1], transform.matrix[3][2]); }
	public @property void position(vec3 v) { transform.matrix[3][0] = v.x; transform.matrix[3][1] = v.y; transform.matrix[3][2] = v.z; }
	
	public @property quat rotation() { assert(transform.isFinite); return quat.from_matrix(mat3(transform)); }
	public @property void rotation(quat v) { transform.set_rotation(v.to_matrix!(3, 3)()); }
	
	public @property vec3 scale()
	{
		return vec3(
			vec3(transform.matrix[0][0], transform.matrix[0][1], transform.matrix[0][2]).magnitude,
			vec3(transform.matrix[1][0], transform.matrix[1][1], transform.matrix[1][2]).magnitude,
			vec3(transform.matrix[2][0], transform.matrix[2][1], transform.matrix[2][2]).magnitude
		);
	}

	public @property void scale(vec3 v) { transform.scale(v.x, v.y, v.z); }

	private f32 m_rotX = 0, m_rotY = 0, m_rotZ = 0;
}
