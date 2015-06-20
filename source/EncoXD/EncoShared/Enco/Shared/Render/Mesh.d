module Enco.Shared.Render.Mesh;

import std.algorithm;

import EncoShared;

class RenderableMesh
{
	public u32 bufferID;
	public u32 * vbos;
	public u32 indexLength;

	public this(u32 bufferID, u32 * vbos, u32 indexLength)
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

	public static Mesh createPlaneX(f32 offset = 0, f32 left = -1, f32 right = 1, f32 bottom = 1, f32 top = -1, f32 uvX1 = 0, f32 uvY1 = 0, f32 uvX2 = 1, f32 uvY2 = 1)
	{
		Mesh m = new Mesh();
		m.addVertices([vec3(offset, left, top), vec3(offset, right, top), vec3(offset, right, bottom), vec3(offset, left, bottom)]);
		m.addTexCoords([vec2(uvX1, uvY1), vec2(uvX2, uvY1), vec2(uvX2, uvY2), vec2(uvX1, uvY2)]);
		m.addNormals([vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0)]);
		m.addIndices([0, 1, 2, 0, 2, 3]);
		return m;
	}

	public static Mesh createPlaneY(f32 offset = 0, f32 left = -1, f32 right = 1, f32 bottom = 1, f32 top = -1, f32 uvX1 = 0, f32 uvY1 = 0, f32 uvX2 = 1, f32 uvY2 = 1)
	{
		Mesh m = new Mesh();
		m.addVertices([vec3(left, offset, top), vec3(right, offset, top), vec3(right, offset, bottom), vec3(left, offset, bottom)]);
		m.addTexCoords([vec2(uvX1, uvY1), vec2(uvX2, uvY1), vec2(uvX2, uvY2), vec2(uvX1, uvY2)]);
		m.addNormals([vec3(0, 1, 0), vec3(0, 1, 0), vec3(0, 1, 0), vec3(0, 1, 0)]);
		m.addIndices([0, 1, 2, 0, 2, 3]);
		return m;
	}

	public static Mesh createPlaneZ(f32 offset = 0, f32 left = -1, f32 right = 1, f32 bottom = 1, f32 top = -1, f32 uvX1 = 0, f32 uvY1 = 0, f32 uvX2 = 1, f32 uvY2 = 1)
	{
		Mesh m = new Mesh();
		m.addVertices([vec3(left, top, offset), vec3(right, top, offset), vec3(right, bottom, offset), vec3(left, bottom, offset)]);
		m.addTexCoords([vec2(uvX1, uvY1), vec2(uvX2, uvY1), vec2(uvX2, uvY2), vec2(uvX1, uvY2)]);
		m.addNormals([vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1)]);
		m.addIndices([0, 1, 2, 0, 2, 3]);
		return m;
	}

	public static Mesh createPlaneXInv(f32 offset = 0, f32 left = -1, f32 right = 1, f32 bottom = 1, f32 top = -1, f32 uvX1 = 0, f32 uvY1 = 0, f32 uvX2 = 1, f32 uvY2 = 1)
	{
		Mesh m = new Mesh();
		m.addVertices([vec3(offset, left, top), vec3(offset, right, top), vec3(offset, right, bottom), vec3(offset, left, bottom)]);
		m.addTexCoords([vec2(uvX1, uvY1), vec2(uvX2, uvY1), vec2(uvX2, uvY2), vec2(uvX1, uvY2)]);
		m.addNormals([vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0)]);
		m.addIndices([2, 1, 0, 3, 2, 0]);
		return m;
	}

	public static Mesh createPlaneYInv(f32 offset = 0, f32 left = -1, f32 right = 1, f32 bottom = 1, f32 top = -1, f32 uvX1 = 0, f32 uvY1 = 0, f32 uvX2 = 1, f32 uvY2 = 1)
	{
		Mesh m = new Mesh();
		m.addVertices([vec3(left, offset, top), vec3(right, offset, top), vec3(right, offset, bottom), vec3(left, offset, bottom)]);
		m.addTexCoords([vec2(uvX1, uvY1), vec2(uvX2, uvY1), vec2(uvX2, uvY2), vec2(uvX1, uvY2)]);
		m.addNormals([vec3(0, 1, 0), vec3(0, 1, 0), vec3(0, 1, 0), vec3(0, 1, 0)]);
		m.addIndices([2, 1, 0, 3, 2, 0]);
		return m;
	}

	public static Mesh createPlaneZInv(f32 offset = 0, f32 left = -1, f32 right = 1, f32 bottom = 1, f32 top = -1, f32 uvX1 = 0, f32 uvY1 = 0, f32 uvX2 = 1, f32 uvY2 = 1)
	{
		Mesh m = new Mesh();
		m.addVertices([vec3(left, top, offset), vec3(right, top, offset), vec3(right, bottom, offset), vec3(left, bottom, offset)]);
		m.addTexCoords([vec2(uvX1, uvY1), vec2(uvX2, uvY1), vec2(uvX2, uvY2), vec2(uvX1, uvY2)]);
		m.addNormals([vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1)]);
		m.addIndices([2, 1, 0, 3, 2, 0]);
		return m;
	}


	public static Mesh createCube(f32 diaX = 1, f32 diaY = 1, f32 diaZ = 1, f32 offX = 0, f32 offY = 0, f32 offZ = 0)
	{
		Mesh m = new Mesh();
		vec3 off = vec3(offX, offY, offZ);
		m.addVertices([
					      vec3(-diaX, -diaY, -diaZ) + off, vec3(diaX, -diaY, -diaZ) + off, vec3(diaX, diaY, -diaZ) + off, vec3(-diaX, diaY, -diaZ) + off,

					      vec3(-diaX, -diaY, diaZ) + off, vec3(diaX, -diaY, diaZ) + off, vec3(diaX, diaY, diaZ) + off, vec3(-diaX, diaY, diaZ) + off,

					      vec3(-diaX, -diaY, -diaZ) + off, vec3(-diaX, diaY, -diaZ) + off, vec3(-diaX, diaY, diaZ) + off, vec3(-diaX, -diaY, diaZ) + off,

					      vec3(diaX, -diaY, -diaZ) + off, vec3(diaX, diaY, -diaZ) + off, vec3(diaX, diaY, diaZ) + off, vec3(diaX, -diaY, diaZ) + off,

					      vec3(-diaX, -diaY, -diaZ) + off, vec3(diaX, -diaY, -diaZ) + off, vec3(diaX, -diaY, diaZ) + off, vec3(-diaX, -diaY, diaZ) + off,

					      vec3(-diaX, diaY, -diaZ) + off, vec3(diaX, diaY, -diaZ) + off, vec3(diaX, diaY, diaZ) + off, vec3(-diaX, diaY, diaZ) + off
		              ]);
		m.addTexCoords([
						   vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1),
						   vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1),
						   vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1),
						   vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1),
						   vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1),
						   vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)
		               ]);
		m.addNormals([
					     vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1), vec3(0, 0, -1),
					     vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1),

					     vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0), vec3(-1, 0, 0),
					     vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0), vec3(1, 0, 0),

					     vec3(0, -1, 0), vec3(0, -1, 0), vec3(0, -1, 0), vec3(0, -1, 0),
					     vec3(0, 1, 0), vec3(0, 1, 0), vec3(0, 1, 0), vec3(0, 1, 0)
		             ]);
		m.addIndices([
					     2, 1, 0, 3, 2, 0,
					     4, 5, 6, 4, 6, 7,
					     10, 9, 8, 11, 10, 8,
					     12, 13, 14, 12, 14, 15,
					     16, 17, 18, 16, 18, 19,
					     22, 21, 20, 23, 22, 20
		             ]);
		return m;
	}

	public static Mesh merge(Mesh[] meshes)
	{
		Mesh m = new Mesh();
		u32 maxIndex = 0;
		foreach (ref Mesh mesh; meshes)
		{
			m.addVertices(mesh.vertices);
			m.addTexCoords(mesh.texCoords);
			m.addNormals(mesh.normals);
			u32 off = maxIndex;
			foreach (ref u32 index; mesh.indices)
			{
				m.addIndex(index + off);
				maxIndex = max(maxIndex, index);
			}
		}
		return m;
	}
}

class Mesh
{
	public @property vec3[] vertices()
	{
		return m_vertices;
	}
	public @property vec3[] normals()
	{
		return m_normals;
	}
	public @property u32[] indices()
	{
		return m_indices;
	}
	public @property vec2[] texCoords()
	{
		return m_texCoords;
	}

	public void addVertex(vec3 vertex)
	{
		m_vertices.length++; m_vertices[m_vertices.length - 1] = vertex;
	}
	public void addVertices(const vec3[] vertices)
	{
		m_vertices ~= vertices;
	}

	public void addNormal(vec3 normal)
	{
		m_normals.length++; m_normals[m_normals.length - 1] = normal;
	}
	public void addNormals(const vec3[] normals)
	{
		m_normals ~= normals;
	}

	public void addIndex(u32 index)
	{
		m_indices.length++; m_indices[m_indices.length - 1] = index;
	}
	public void addIndices(const u32[] indices)
	{
		m_indices ~= indices;
	}

	public void addTexCoord(vec2 texCoord)
	{
		m_texCoords.length++; m_texCoords[m_texCoords.length - 1] = texCoord;
	}
	public void addTexCoords(const vec2[] texCoords)
	{
		m_texCoords ~= texCoords;
	}

	public static Mesh[] loadFromObj(string file, u32 flags)
	{
		const aiScene* scene = aiImportFile(file.toStringz(), aiProcess_GenNormals |
		                                    aiProcess_JoinIdenticalVertices | aiProcess_Triangulate | aiProcess_GenUVCoords | aiProcess_FlipUVs | flags);
		Mesh[]       meshes;
		meshes.length = scene.mNumMeshes;

		for (int j = 0; j < scene.mNumMeshes; j++)
		{
			auto sceneMesh = scene.mMeshes[j];

			Mesh mesh = new Mesh();

			for (int i = 0; i < sceneMesh.mNumVertices; i++)
			{
				mesh.addVertex(vec3(sceneMesh.mVertices[i].x, sceneMesh.mVertices[i].y, sceneMesh.mVertices[i].z));
				mesh.addTexCoord(vec2(sceneMesh.mTextureCoords[0][i].x, sceneMesh.mTextureCoords[0][i].y));
				mesh.addNormal(vec3(sceneMesh.mNormals[i].x, sceneMesh.mNormals[i].y, sceneMesh.mNormals[i].z));
			}

			for (int i = 0; i < sceneMesh.mNumFaces; i++)
			{
				mesh.addIndices(sceneMesh.mFaces[i].mIndices[0 .. sceneMesh.mFaces[i].mNumIndices]);
			}

			meshes[j] = mesh;
		}

		reverse(meshes);

		return meshes;
	}

	public RenderableMesh renderable = null;

	private vec3[]        m_vertices;
	private vec3[]        m_normals;
	private vec2[]        m_texCoords;
	private u32[]         m_indices;
}
