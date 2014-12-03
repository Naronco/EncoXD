module Enco.Shared.Enco3D.Mesh;

import EncoShared;

struct RenderableMesh
{
	u32 bufferID;
	u32* vbos;
	u32 indexLength;
}

class Mesh
{
	@property vec3[] vertices() { return m_vertices; }
	@property vec3[] normals() { return m_normals; }
	@property u32[] indices() { return m_indices; }
	@property vec2[] texCoords() { return m_texCoords; }

	void addVertex(vec3 vertex) { m_vertices.length++; m_vertices[m_vertices.length - 1] = vertex; }
	void addVertices(vec3[] vertices) { m_vertices ~= vertices; }

	void addNormal(vec3 normal) { m_normals.length++; m_normals[m_normals.length - 1] = normal; }
	void addNormals(vec3[] normals) { m_normals ~= normals; }

	void addIndex(u32 index) { m_indices.length++; m_indices[m_indices.length - 1] = index; }
	void addIndices(u32[] indices) { m_indices ~= indices; }

	void addTexCoord(vec2 texCoord) { m_texCoords.length++; m_texCoords[m_texCoords.length - 1] = texCoord; }
	void addTexCoords(vec2[] texCoords) { m_texCoords ~= texCoords; }
	
	private vec3[] m_vertices;
	private vec3[] m_normals;
	private vec2[] m_texCoords;
	private u32[] m_indices;
}