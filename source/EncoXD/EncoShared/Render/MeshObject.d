module EncoShared.Render.MeshObject;

import std.stdio;

import EncoShared;

class MeshObject : GameObject
{
	public this(Mesh mesh, Material material)
	{
		m_mesh = mesh;
		m_material = material;
	}

	protected override void draw(RenderContext context, IRenderer renderer)
	{
		if (m_mesh.renderable is null)
		{
			m_mesh = renderer.createMesh(m_mesh);
		}

		m_material.bind(renderer, context);

		if (m_relative)
			m_material.program.set("modelview", context.camera.rotationMatrix * transform.transform);
		else
			m_material.program.set("modelview", context.camera.viewMatrix * transform.transform);
		m_material.program.set("projection", context.camera.projectionMatrix);
		m_material.program.set("normalmatrix", transform.transform.transposed.inverse);

		renderer.renderMesh(m_mesh);
	}

	public @property ref Mesh mesh()
	{
		return m_mesh;
	}
	public @property ref bool renderRelative()
	{
		return m_relative;
	}
	public @property ref Material material()
	{
		return m_material;
	}

	protected Mesh m_mesh;
	protected Material m_material;
	protected bool m_relative = false;
}
