module Enco.Shared.Enco3D.Mesh;

import EncoShared;

class RenderableMesh
{
	u32 bufferID;
	u32* vbos;
	u32 indexLength;

	this(u32 bufferID, u32* vbos, u32 indexLength)
	{
		this.bufferID = bufferID;
		this.vbos = vbos;
		this.indexLength = indexLength;
	}
}

class Mesh
{
	@property vec3[] vertices() { return m_vertices; }
	@property vec3[] normals() { return m_normals; }
	@property u32[] indices() { return m_indices; }
	@property vec2[] texCoords() { return m_texCoords; }

	void addVertex(vec3 vertex) { m_vertices.length++; m_vertices[m_vertices.length - 1] = vertex; }
	void addVertices(const vec3[] vertices) { m_vertices ~= vertices; }

	void addNormal(vec3 normal) { m_normals.length++; m_normals[m_normals.length - 1] = normal; }
	void addNormals(const vec3[] normals) { m_normals ~= normals; }

	void addIndex(u32 index) { m_indices.length++; m_indices[m_indices.length - 1] = index; }
	void addIndices(const u32[] indices) { m_indices ~= indices; }

	void addTexCoord(vec2 texCoord) { m_texCoords.length++; m_texCoords[m_texCoords.length - 1] = texCoord; }
	void addTexCoords(const vec2[] texCoords) { m_texCoords ~= texCoords; }
	
	static Mesh[] loadFromObj(string file, u32 flags)
	{
		const aiScene* scene = aiImportFile(file.ptr, aiProcess_GenNormals |
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

	RenderableMesh renderable = null;

	private vec3[] m_vertices;
	private vec3[] m_normals;
	private vec2[] m_texCoords;
	private u32[] m_indices;
}