module Enco.GL3.GLTexture;

import EncoGL3;
import EncoShared;

enum TextureFilterMode : int
{
	Linear = GL_LINEAR, Nearest = GL_NEAREST,
	NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
	LinearMipmapNearest = GL_LINEAR_MIPMAP_NEAREST,
	NearestMipmapLinear = GL_NEAREST_MIPMAP_LINEAR,
	LinearMipmapLinear = GL_LINEAR_MIPMAP_LINEAR,
}

enum TextureClampMode : i32
{
	ClampToBorder = GL_CLAMP_TO_BORDER,
	ClampToEdge = GL_CLAMP_TO_EDGE,
	Repeat = GL_REPEAT,
	Mirror = GL_MIRRORED_REPEAT
}

class GLTexture : ITexture
{
	public bool enableMipMaps = false;
	
	public TextureFilterMode minFilter = TextureFilterMode.Linear;
	public TextureFilterMode magFilter = TextureFilterMode.Linear;
	
	public TextureClampMode wrapX = TextureClampMode.Repeat;
	public TextureClampMode wrapY = TextureClampMode.Repeat;

	private i32 inMode, mode;
	private u32 m_id;
	private u32 m_width, m_height;

	public this()
	{
	}

	public ~this()
	{
		destroy();
	}

	public void create(u32 width, u32 height, void[] pixels)
	{
		create(width, height, GL_RGBA, pixels);
	}
	
	public void create(u32 width, u32 height, i32 mode, void[] pixels)
	{
		glGenTextures(1, &m_id);
		glBindTexture(GL_TEXTURE_2D, m_id);

		glTexImage2D(GL_TEXTURE_2D, 0, mode, width, height, 0, mode, GL_UNSIGNED_BYTE, pixels.ptr);

		applyParameters();
		
		this.inMode = mode;
		this.mode = mode;
		m_width = width;
		m_height = height;
	}

	public void create(u32 width, u32 height, i32 inMode, i32 mode, void[] pixels, int type = GL_UNSIGNED_BYTE)
	{
		glGenTextures(1, &m_id);
		glBindTexture(GL_TEXTURE_2D, m_id);

		glTexImage2D(GL_TEXTURE_2D, 0, inMode, width, height, 0, mode, type, pixels.ptr);

		applyParameters();
		
		this.inMode = inMode;
		this.mode = mode;
		m_width = width;
		m_height = height;
	}

	public void applyParameters()
	{
		bind(0);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, magFilter);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, minFilter);

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapX);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapY);

		if(enableMipMaps)
		{
			glGenerateMipmap(GL_TEXTURE_2D);
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16);
		}
	}

	public void bind(u32 unit)
	{
		glActiveTexture(GL_TEXTURE0 + unit);
		glBindTexture(GL_TEXTURE_2D, m_id);
	}

	public void load(string file)
	{
		fromSurface(IMG_Load((file ~ '\0').ptr), file);
	}

	public void fromSurface(SDL_Surface* surface, string name = "Surface")
	{
		if(surface is null || surface.pixels is null)
		{
			Logger.errln("Can't load Texture ", name);
			i32 i = 0;
			const char* err = IMG_GetError();
			for(i32 x = 0; x < 1024; x++)
			{
				i = x;
				if(err[x] == '\0') break;
			}
			Logger.errln(err[0 .. i]);
			return;
		}

		i32 mode = GL_RGB;

		if(surface.format.BytesPerPixel == 4)
		{
			mode = GL_RGBA;
		}

		if(surface.pixels == null)
		{
			Logger.errln("Can't load Texture(", surface.w, "x", surface.h, ")");
			return;
		}
		
		create(surface.w, surface.h, mode, surface.pixels[0 .. surface.w * surface.h * 4]);
		
		SDL_FreeSurface(surface);
	}

	public void resize(u32 width, u32 height, void[] pixels = null)
	{
		bind(0);
		glTexImage2D(GL_TEXTURE_2D, 0, inMode, width, height, 0, mode, GL_UNSIGNED_BYTE, pixels.ptr);
		m_width = width;
		m_height = height;
	}

	public void destroy()
	{
		glDeleteTextures(1, &m_id);
	}
	
	public SDL_Surface* toSurface()
	{
		Logger.writeln("Converting...");
		bind(0);
		u8[] pixels = new u8[width * height];
		glGetTexImage(GL_TEXTURE_2D, 0, GL_BGRA, GL_UNSIGNED_BYTE, pixels.ptr);
		//u8[] px = (cast(u8*)pixels)[0 .. width * height];
		SDL_Surface* surf = SDL_CreateRGBSurfaceFrom(pixels.ptr, cast(i32)width, cast(i32)height, 32, cast(i32)width * 4, 0, 0, 0, 0);
		Logger.writeln("Converted");
		return surf;
	}
	
	public @property u32 id() { return m_id; }

	public @property u32 width() { return m_width; }

	public @property u32 height() { return m_height; }

	public static @property ITexture white() { return m_white; }

	private static ITexture m_white;

	public static void init()
	{
		m_white = new GLTexture();
		m_white.create(1, 1, cast(ubyte[])[255, 255, 255, 255]);
	}
}


class GLTexture3D : ITexture3D
{
	public void create(u32 width, u32 height, u32 depth, void[] pixels)
	{
		create(width, height, depth, GL_RGBA, pixels);
	}

	public void create(u32 width, u32 height, u32 depth, i32 mode, void[] pixels)
	{
		glGenTextures(1, &m_id);
		glBindTexture(GL_TEXTURE_3D, m_id);

		if(pixels == null)
		{
			Logger.errln("Can't load Texture3D(", width, "x", height, "x", depth, ")");
			return;
		}

		glTexImage3D(GL_TEXTURE_3D, 0, mode, width, height, depth, 0, mode, GL_UNSIGNED_BYTE, pixels.ptr);
		this.mode = mode;

		applyParameters();
	}

	public void applyParameters()
	{
		bind(0);

		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, minFilter);
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, magFilter);

		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, wrapX);
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, wrapY);
		glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, wrapZ);

		if(enableMipMaps)
		{
			glGenerateMipmap(GL_TEXTURE_3D);
			glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAX_ANISOTROPY_EXT, 16);
		}
	}

	public void bind(u32 unit)
	{
		glActiveTexture(GL_TEXTURE0 + unit);
		glBindTexture(GL_TEXTURE_3D, m_id);
	}

	public void load(string file)
	{
		auto surface = IMG_Load((file ~ '\0').ptr);

		if(surface is null || surface.pixels is null)
		{
			Logger.errln("Can't load Texture ", file);
			i32 i = 0;
			const char* err = IMG_GetError();
			for(i32 x = 0; x < 1024; x++)
			{
				i = x;
				if(err[x] == '\0') break;
			}
			Logger.errln(err[0 .. i]);
			return;
		}

		i32 mode = GL_RGB;

		if(surface.format.BytesPerPixel == 4)
		{
			mode = GL_RGBA;
		}
		
		create(surface.w, surface.w, surface.h / surface.w, mode, surface.pixels[0 .. surface.w * surface.w * (surface.h / surface.w) * 4]);
		
		SDL_FreeSurface(surface);
	}

	public void resize(u32 width, u32 height, u32 depth, void[] pixels = null)
	{
		bind(0);
		glTexImage3D(GL_TEXTURE_3D, 0, mode, width, height, depth, 0, mode, GL_UNSIGNED_BYTE, pixels.ptr);
	}

	public void destroy()
	{
		glDeleteTextures(1, &m_id);
	}

	public bool enableMipMaps = false;
	
	public TextureFilterMode minFilter = TextureFilterMode.Linear;
	public TextureFilterMode magFilter = TextureFilterMode.Linear;
	
	public TextureClampMode wrapX = TextureClampMode.Repeat;
	public TextureClampMode wrapY = TextureClampMode.Repeat;
	public TextureClampMode wrapZ = TextureClampMode.Repeat;

	public u32 m_id;
	public @property u32 id() { return m_id; }

	private i32 mode;
}

class GLTexturePool
{
	public static GLTexture load(string texture)
	{
		if((texture in m_textures) !is null)
			return m_textures[texture];

		m_textures[texture] = new GLTexture();
		m_textures[texture].load(texture);
		return m_textures[texture];
	}

	private static GLTexture[string] m_textures;
}