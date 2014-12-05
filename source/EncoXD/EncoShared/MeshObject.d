module Enco.Shared.MeshObject;

import EncoShared;
import std.stdio;

class MeshObject : GameObject
{
	this(Mesh mesh, Material material)
	{
		m_mesh = mesh;
		m_material = material;
	}

	override protected void draw(RenderContext context, IRenderer renderer)
	{
		if(!isInitialized)
		{
			m_renderable = renderer.createMesh(m_mesh);
			m_mesh = null;
			isInitialized = true;

		}
		
		m_material.bind(context);

		m_material.program.set("modelview", context.camera.viewMatrix * modelMatrix);
		m_material.program.set("projection", context.camera.projectionMatrix);
		m_material.program.set("normalmatrix", modelMatrix().transposed().inverse());
		
		renderer.renderMesh(m_renderable);
	}
	
	@property mat4 modelMatrix()
	{
		return mat4.identity.translate(transform.position.x, transform.position.y, transform.position.z);// *
			   //mat4.identity.
	}

	private Mesh m_mesh;
	private bool isInitialized = false;
	private RenderableMesh m_renderable;
	private Material m_material;
}