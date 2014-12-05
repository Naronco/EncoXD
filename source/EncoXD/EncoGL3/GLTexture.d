module Enco.GL3.GLTexture;

import EncoGL3;
import std.stdio;

enum TextureFilterMode : int
{
	Linear = GL_LINEAR, Nearest = GL_NEAREST,
	NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
	LinearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,
	NearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR,
	LinearMipmapLinear = GL_LINEAR_MIPMAP_LINEAR,
}

enum TextureClampMode : int
{
	ClampToBorder = GL_CLAMP_TO_BORDER,
	ClampToEdge = GL_CLAMP_TO_EDGE,
	Repeat = GL_REPEAT,
	Mirror = GL_MIRRORED_REPEAT
}

class GLTexture : ITexture
{
	void create(u32 width, u32 height, void* pixels)
	{
		create(width, height, GL_RGBA, pixels);
	}

	void create(u32 width, u32 height, int mode, void* pixels)
	{
		glGenTextures(1, &m_id);
		glBindTexture(GL_TEXTURE_2D, m_id);

		if(pixels == null)
		{
			writeln("Can't load Texture(", width, "x", height, ")");
			return;
		}

		glTexImage2D(GL_TEXTURE_2D, 0, mode, width, height, 0, mode, GL_UNSIGNED_BYTE, pixels);

		applyTexParams();
	}

	void applyTexParams()
	{
		bind(0);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapX);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapY);

		if(enableMipMaps)
		{
			glGenerateMipmap(GL_TEXTURE_2D);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16);
		}
	}

	void bind(u32 unit)
	{
		glActiveTexture(GL_TEXTURE0 + unit);
		glBindTexture(GL_TEXTURE_2D, m_id);
	}

	void load(string file)
	{
		auto surface = IMG_Load((file ~ '\0').ptr);

		if(surface is null || surface.pixels is null)
		{
			writeln("Can't load Texture ", file);
			int i = 0;
			const char* err = IMG_GetError();
			for(int x = 0; x < 1024; x++)
			{
				i = x;
				if(err[x] == '\0') break;
			}
			writeln(err[0 .. i]);
			return;
		}

		int mode = GL_RGB;

		if(surface.format.BytesPerPixel == 4)
		{
			mode = GL_RGBA;
		}
		
		create(surface.w, surface.h, mode, surface.pixels);
		
		SDL_FreeSurface(surface);
	}

	void destroy()
	{
		glDeleteTextures(1, &m_id);
	}

	bool enableMipMaps = false;
	
	TextureFilterMode minFilter = TextureFilterMode.Linear;
	TextureFilterMode magFilter = TextureFilterMode.Linear;
	
	TextureClampMode wrapX = TextureClampMode.Repeat;
	TextureClampMode wrapY = TextureClampMode.Repeat;


	@property u32 id() { return m_id; }

	u32 m_id;
}

class GLTexturePool
{
	static GLTexture load(string texture)
	{
		if((texture in m_textures) !is null)
			return m_textures[texture];

		m_textures[texture] = new GLTexture();
		m_textures[texture].load(texture);
		return m_textures[texture];
	}

	private static GLTexture[string] m_textures;
}