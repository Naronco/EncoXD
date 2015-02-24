module Enco.Shared.Render.Mesh;

import EncoShared;

class RenderableMesh
{
	public u32 bufferID;
	public u32* vbos;
	public u32 indexLength;

	public this(u32 bufferID, u32* vbos, u32 indexLength)
	{
		this.bufferID = bufferID;
		this.vbos = vbos;
		this.indexLength = indexLength;
	}
}

class MeshUtils
{
	public static Mesh createPlane(f32 left = -1, f32 right = 1, f32 bottom = 1, f32 top = -1, f32 uvX1 = 0, f32 uvY1 = 0, f32 uvX2 = 1, f32 uvY2 = 1)
	{
		Mesh m = new Mesh();
		m.addVertices([vec3(left, top, 0), vec3(right, top, 0), vec3(right, bottom, 0), vec3(left, bottom, 0)]);
		m.addTexCoords([vec2(uvX1, uvY1), vec2(uvX2, uvY1), vec2(uvX2, uvY2), vec2(uvX1, uvY2)]);
		m.addNormals([vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1)]);
		m.addIndices([0, 1, 2, 0, 2, 3]);
		return m;
	}
}

class Mesh
{
	public @property vec3[] vertices() { return m_vertices; }
	public @property vec3[] normals() { return m_normals; }
	public @property u32[] indices() { return m_indices; }
	public @property vec2[] texCoords() { return m_texCoords; }

	public void addVertex(vec3 vertex) { m_vertices.length++; m_vertices[m_vertices.length - 1] = vertex; }
	public void addVertices(const vec3[] vertices) { m_vertices ~= vertices; }

	public void addNormal(vec3 normal) { m_normals.length++; m_normals[m_normals.length - 1] = normal; }
	public void addNormals(const vec3[] normals) { m_normals ~= normals; }

	public void addIndex(u32 index) { m_indices.length++; m_indices[m_indices.length - 1] = index; }
	public void addIndices(const u32[] indices) { m_indices ~= indices; }

	public void addTexCoord(vec2 texCoord) { m_texCoords.length++; m_texCoords[m_texCoords.length - 1] = texCoord; }
	public void addTexCoords(const vec2[] texCoords) { m_texCoords ~= texCoords; }
	
	public static Mesh[] loadFromObj(string file, u32 flags)
	{
		const aiScene* scene = aiImportFile(file.toStringz(), aiProcess_GenNormals |
				aiProcess_JoinIdenticalVertices | aiProcess_Triangulate | aiProcess_GenUVCoords | aiProcess_FlipUVs | flags);
		Mesh[] meshes;
		meshes.length = scene.mNumMeshes;

		for(int j = 0; j < scene.mNumMeshes; j++)
		{
			auto sceneMesh = scene.mMeshes[j];

			Mesh mesh = new Mesh();

			for(int i = 0; i < sceneMesh.mNumVertices; i++)
			{
				mesh.addVertex(vec3(sceneMesh.mVertices[i].x, sceneMesh.mVertices[i].y, sceneMesh.mVertices[i].z));
				mesh.addTexCoord(vec2(sceneMesh.mTextureCoords[0][i].x, sceneMesh.mTextureCoords[0][i].y));
				mesh.addNormal(vec3(sceneMesh.mNormals[i].x, sceneMesh.mNormals[i].y, sceneMesh.mNormals[i].z));
			}

			for(int i = 0; i < sceneMesh.mNumFaces; i++)
			{
				mesh.addIndices(sceneMesh.mFaces[i].mIndices[0 .. sceneMesh.mFaces[i].mNumIndices]);
			}

			meshes[j] = mesh;
		}
		
		return meshes.reverse;
	}

	public RenderableMesh renderable = null;

	private vec3[] m_vertices;
	private vec3[] m_normals;
	private vec2[] m_texCoords;
	private u32[] m_indices;
}