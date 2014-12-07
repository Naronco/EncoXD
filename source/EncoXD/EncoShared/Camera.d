module Enco.Shared.Camera;

import EncoShared;

enum ProjectionMode
{
	Perspective, Orthographic
}

class Camera : GameObject
{
	@property mat4 projectionMatrix()
	{
		if(m_needUpdate)
		{
			if(m_mode == ProjectionMode.Perspective)
				m_projectionMatrix = mat4.perspective(m_width, m_height, m_fov, m_near, m_far);
			else if(m_mode == ProjectionMode.Orthographic)
				m_projectionMatrix = mat4.orthographic(0, m_width, m_height, 0, m_near, m_far);
			m_needUpdate = false;
		}
		return m_projectionMatrix;
	}
	
	@property mat4 viewMatrix()
	{
		m_viewMatrix = mat4.identity.rotate(transform.rotation.x, vec3(1, 0, 0)) *
					   mat4.identity.rotate(transform.rotation.y, vec3(0, 1, 0)) *
					   mat4.identity.rotate(transform.rotation.z, vec3(0, 0, 1)) *
					   mat4.identity.translate(-transform.position.x, -transform.position.y, -transform.position.z);
		return m_viewMatrix;
	}
	
	@property f32 nearClip() { return m_near; }
	@property f32 farClip() { return m_far; }
	@property f32 width() { return m_width; }
	@property f32 height() { return m_height; }
	@property f32 fov() { return m_fov; }
	@property ProjectionMode projectionMode() { return m_mode; }
	
	@property void nearClip(float value) { m_needUpdate = m_needUpdate || m_near != value; m_near = value; }
	@property void farClip(float value) { m_needUpdate = m_needUpdate || m_far != value; m_far = value; }
	@property void width(float value) { m_needUpdate = m_needUpdate || m_width != value; m_width = value; }
	@property void height(float value) { m_needUpdate = m_needUpdate || m_height != value; m_height = value; }
	@property void fov(float value) { m_needUpdate = m_needUpdate || m_fov != value; m_fov = value; }
	@property void projectionMode(ProjectionMode value) { m_needUpdate = m_needUpdate || m_mode != value; m_mode = value; }
	
	private f32 m_near = 0.1f;
	private f32 m_far = 100;
	private f32 m_width = 1;
	private f32 m_height = 1;
	private f32 m_fov = 45;
	private ProjectionMode m_mode = ProjectionMode.Perspective;

	private mat4 m_projectionMatrix = mat4.perspective(1, 1, 45, 0.1f, 100);
	private mat4 m_viewMatrix = mat4.identity;
	private bool m_needUpdate = false;
}