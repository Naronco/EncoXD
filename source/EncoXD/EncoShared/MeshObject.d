module Enco.Shared.MeshObject;

import std.stdio;

import EncoShared;

class MeshObject : GameObject
{
	this(Mesh mesh, Material material)
	{
		m_mesh = mesh;
		m_material = material;
	}

	override protected void draw(RenderContext context, IRenderer renderer)
	{
		if(m_mesh.renderable is null)
		{
			m_mesh = renderer.createMesh(m_mesh);
		}

		m_material.bind(context);

		m_material.program.set("modelview", context.camera.viewMatrix * modelMatrix);
		m_material.program.set("projection", context.camera.projectionMatrix);
		m_material.program.set("normalmatrix", modelMatrix().transposed().inverse());

		renderer.renderMesh(m_mesh);
	}

	@property mat4 modelMatrix()
	{
		return  mat4.identity.translate(transform.position.x, transform.position.y, transform.position.z) *
				mat4.identity.rotate(transform.rotation.x, vec3(1, 0, 0)) *
				mat4.identity.rotate(transform.rotation.y, vec3(0, 1, 0)) *
				mat4.identity.rotate(transform.rotation.z, vec3(0, 0, 1)) *
				mat4.identity.scale(transform.scale.x, transform.scale.y, transform.scale.z);
	}
	
	@property Mesh mesh() { return m_mesh; }
	@property void mesh(Mesh mesh) { m_mesh = mesh; }
	
	@property Material material() { return m_material; }
	@property void material(Material material) { m_material = material; }

	protected Mesh m_mesh;
	protected Material m_material;
}
