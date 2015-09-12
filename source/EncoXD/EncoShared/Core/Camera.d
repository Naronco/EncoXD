module EncoShared.Core.Camera;

import EncoShared;

enum ProjectionMode
{
	Perspective, Orthographic2D, Orthographic3D
}

class Camera : GameObject
{
	public @property mat4 projectionMatrix()
	{
		if (m_needUpdate)
		{
			if (m_mode == ProjectionMode.Perspective)
				m_projectionMatrix = mat4.perspective(m_width, m_height, m_fov, m_near, m_far);
			else if (m_mode == ProjectionMode.Orthographic2D)
				m_projectionMatrix = mat4.orthographic(0, m_width, m_height, 0, m_near, m_far);
			else if (m_mode == ProjectionMode.Orthographic3D)
				m_projectionMatrix = mat4.orthographic(-m_aspect, m_aspect, -1, 1, m_near, m_far) * mat4.identity.scale(m_iZoom, m_iZoom, m_iZoom);
			m_needUpdate = false;
		}
		return m_projectionMatrix;
	}

	public @property mat4 viewMatrix()
	{
		return rotationMatrix * translationMatrix;
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

	public @property float nearClip()
	{
		return m_near;
	}
	public @property float farClip()
	{
		return m_far;
	}
	public @property float width()
	{
		return m_width;
	}
	public @property float height()
	{
		return m_height;
	}
	public @property float fov()
	{
		return m_fov;
	}

	/// Zoom for Orthographic3D (Defaults to 7)
	public @property float zoom()
	{
		return 1 / m_iZoom;
	}
	public @property ProjectionMode projectionMode()
	{
		return m_mode;
	}

	public @property void nearClip(float value)
	{
		m_needUpdate = m_needUpdate || m_near != value; m_near = value;
	}
	public @property void farClip(float value)
	{
		m_needUpdate = m_needUpdate || m_far != value; m_far = value;
	}
	public @property void width(float value)
	{
		m_needUpdate = m_needUpdate || m_width != value; m_width = value; m_aspect = m_width / m_height;
	}
	public @property void height(float value)
	{
		m_needUpdate = m_needUpdate || m_height != value; m_height = value; m_aspect = m_width / m_height;
	}
	public @property void fov(float value)
	{
		m_needUpdate = m_needUpdate || m_fov != value; m_fov = value;
	}

	/// Zoom for Orthographic3D (Defaults to 7)
	public @property void zoom(float value)
	{
		m_needUpdate = true; m_iZoom = 1 / value;
	}
	public @property void projectionMode(ProjectionMode value)
	{
		m_needUpdate = m_needUpdate || m_mode != value; m_mode = value;
	}

	private float m_near = 0.1f;
	private float m_far = 100;
	private float m_width = 1;
	private float m_height = 1;
	private float m_aspect = 1;
	private float m_fov = 45;
	private float m_iZoom = 1 / 7.0f;
	private ProjectionMode m_mode = ProjectionMode.Perspective;

	private mat4 m_projectionMatrix = mat4.perspective(1, 1, 45, 0.1f, 100);
	private bool m_needUpdate = false;
}
