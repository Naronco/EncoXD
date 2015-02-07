module Enco.Shared.Core.Camera;

import EncoShared;

enum ProjectionMode
{
	Perspective, Orthographic2D, Orthographic3D
}

class Camera : GameObject
{
	public this()
	{
		if(EncoContext.instance !is null && EncoContext.instance.view !is null)
		{
			width = EncoContext.instance.view.width;
			height = EncoContext.instance.view.height;
		}
	}

	public @property mat4 projectionMatrix()
	{
		if(m_needUpdate)
		{
			if(m_mode == ProjectionMode.Perspective)
				m_projectionMatrix = mat4.perspective(m_width, m_height, m_fov, m_near, m_far);
			else if(m_mode == ProjectionMode.Orthographic2D)
				m_projectionMatrix = mat4.orthographic(0, m_width, m_height, 0, m_near, m_far);
			else if(m_mode == ProjectionMode.Orthographic3D)
				m_projectionMatrix = mat4.orthographic(-1, 1, -1, 1, m_near, m_far) * mat4.identity.scale(m_iZoom, m_iZoom, m_iZoom);
			m_needUpdate = false;
		}
		return m_projectionMatrix;
	}
	
	public @property mat4 viewMatrix()
	{
		return m_viewMatrix = rotationMatrix * translationMatrix;
	}
	
	public @property mat4 rotationMatrix()
	{
		return mat4.identity.rotate(transform.rotation.x, vec3(1, 0, 0)) *
				mat4.identity.rotate(transform.rotation.y, vec3(0, 1, 0)) *
				mat4.identity.rotate(transform.rotation.z, vec3(0, 0, 1));
	}
	
	public @property mat4 translationMatrix()
	{
		return mat4.identity.translate(-transform.position.x, -transform.position.y, -transform.position.z);
	}
	
	public @property f32 nearClip() { return m_near; }
	public @property f32 farClip() { return m_far; }
	public @property f32 width() { return m_width; }
	public @property f32 height() { return m_height; }
	public @property f32 fov() { return m_fov; }
	public @property f32 zoom() { return 1 / m_iZoom; }
	public @property ProjectionMode projectionMode() { return m_mode; }
	
	public @property void nearClip(f32 value) { m_needUpdate = m_needUpdate || m_near != value; m_near = value; }
	public @property void farClip(f32 value) { m_needUpdate = m_needUpdate || m_far != value; m_far = value; }
	public @property void width(f32 value) { m_needUpdate = m_needUpdate || m_width != value; m_width = value; }
	public @property void height(f32 value) { m_needUpdate = m_needUpdate || m_height != value; m_height = value; }
	public @property void fov(f32 value) { m_needUpdate = m_needUpdate || m_fov != value; m_fov = value; }
	public @property void zoom(f32 value) { m_iZoom = 1 / value; }
	public @property void projectionMode(ProjectionMode value) { m_needUpdate = m_needUpdate || m_mode != value; m_mode = value; }
	
	private f32 m_near = 0.1f;
	private f32 m_far = 100;
	private f32 m_width = 1;
	private f32 m_height = 1;
	private f32 m_fov = 45;
	private f32 m_iZoom = 1 / 7.0f;
	private ProjectionMode m_mode = ProjectionMode.Perspective;

	private mat4 m_projectionMatrix = mat4.perspective(1, 1, 45, 0.1f, 100);
	private mat4 m_viewMatrix = mat4.identity;
	private bool m_needUpdate = false;
}