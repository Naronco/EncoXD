module Enco.Shared.Core.ContentManager;

import EncoShared;

class ContentManager
{
private:
	IDevice m_device;

	ITexture[string] m_textures;
	ITexture3D[string] m_3DTextures;
	Material[string] m_materials;

public:
	this(IDevice device)
	{
		m_device = device;
	}

	~this()
	{
		destroy();
	}

	void destroy()
	{
		foreach(string name, ITexture tex; m_textures)
		{
			tex.destroy();
		}

		foreach(string name, ITexture3D tex; m_3DTextures)
		{
			tex.destroy();
		}
	}

	T loadTexture(T : ITexture = ITexture)(string path)
	{
		if((path in m_textures) !is null)
			return m_textures[path];
		m_textures[path] = m_device.createTexture();
		m_textures[path].fromBitmap(Bitmap.load(path), "CM: " ~ path);
		return cast(T)m_textures[path];
	}

	T loadTexture3D(T : ITexture3D = ITexture3D)(string path)
	{
		if((path in m_3DTextures) !is null)
			return m_3DTextures[path];
		m_3DTextures[path] = m_device.createTexture3D();
		m_3DTextures[path].fromBitmap(Bitmap.load(path), "CM: " ~ path);
		return cast(T)m_3DTextures[path];
	}

	Material loadMaterial(string path)
	{
		if((path in m_materials) !is null)
			return m_materials[path];
		IMaterialManager mat = m_device.createMaterialManager();
		m_materials[path] = mat.load(path);
		return m_materials[path];
	}
}