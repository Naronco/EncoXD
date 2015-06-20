module Enco.GL3.GLTexture;

import EncoGL3;
import EncoShared;

enum TextureFilterMode : int
{
	Linear               = GL_LINEAR, Nearest = GL_NEAREST,
	NearestMipmapNearest = GL_NEAREST_MIPMAP_NEAREST,
	LinearMipmapNearest  = GL_LINEAR_MIPMAP_NEAREST,
	NearestMipmapLinear  = GL_NEAREST_MIPMAP_LINEAR,
	LinearMipmapLinear   = GL_LINEAR_MIPMAP_LINEAR,
}

enum TextureClampMode : i32
{
	ClampToBorder = GL_CLAMP_TO_BORDER,
	ClampToEdge   = GL_CLAMP_TO_EDGE,
	Repeat        = GL_REPEAT,
	Mirror        = GL_MIRRORED_REPEAT
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

	public @property u32 id()
	{
		return m_id;
	}

	public @property u32 width()
	{
		return m_width;
	}

	public @property u32 height()
	{
		return m_height;
	}

	public static @property ITexture white()
	{
		return m_white;
	}

	private static ITexture m_white;

	public static void init()
	{
		m_white = new GLTexture();
		m_white.create(1, 1, cast(ubyte[])[255, 255, 255, 255]);
	}

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

		if (enableMipMaps)
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

	public void fromBitmap(Bitmap bitmap, string name = "Bitmap")
	{
		if (!bitmap.valid)
		{
			Logger.errln(name, " is invalid!");
			return;
		}

		i32 mode = GL_RGB;

		if (bitmap.surface.format.BytesPerPixel == 4)
		{
			mode = GL_RGBA;
		}

		create(bitmap.width, bitmap.height, mode, bitmap.surface.pixels[0 .. bitmap.width * bitmap.height * bitmap.surface.format.BytesPerPixel]);
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

	public Bitmap toBitmap()
	{
		bind(0);
		u8[] pixels = new u8[width * height];
		glGetTexImage(GL_TEXTURE_2D, 0, GL_BGRA, GL_UNSIGNED_BYTE, pixels.ptr);
		scope (exit)
		{
			delete pixels; // Otherwise program crashes after second time and destroy, pixels = null, pixels[] = 0 doesnt work
		}
		return new Bitmap(pixels, cast(i32) width, cast(i32) height, 32);
	}
}


class GLTexture3D : ITexture3D
{
	@property u32 width()
	{
		return m_width;
	}

	@property u32 height()
	{
		return m_height;
	}

	@property u32 depth()
	{
		return m_depth;
	}

	private u32 m_width, m_height, m_depth;

	public bool enableMipMaps = false;

	public TextureFilterMode minFilter = TextureFilterMode.Linear;
	public TextureFilterMode magFilter = TextureFilterMode.Linear;

	public TextureClampMode wrapX = TextureClampMode.Repeat;
	public TextureClampMode wrapY = TextureClampMode.Repeat;
	public TextureClampMode wrapZ = TextureClampMode.Repeat;

	private u32 m_id;
	public @property u32 id()
	{
		return m_id;
	}

	private i32 m_mode;

	public void create(u32 width, u32 height, u32 depth, void[] pixels)
	{
		create(width, height, depth, GL_RGBA, pixels);
	}

	public void create(u32 width, u32 height, u32 depth, i32 mode, void[] pixels)
	{
		glGenTextures(1, &m_id);
		glBindTexture(GL_TEXTURE_3D, m_id);

		m_width = width;
		m_height = height;
		m_depth = depth;

		glTexImage3D(GL_TEXTURE_3D, 0, mode, width, height, depth, 0, mode, GL_UNSIGNED_BYTE, pixels.ptr);
		m_mode = mode;

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

		if (enableMipMaps)
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

	public void fromBitmap(Bitmap bitmap, string name = "Bitmap")
	{
		if (!bitmap.valid)
		{
			Logger.errln(name, " is invalid!");
			return;
		}

		i32 mode = GL_RGB;

		if (bitmap.surface.format.BytesPerPixel == 4)
		{
			mode = GL_RGBA;
		}

		create(bitmap.width, bitmap.width, bitmap.height / bitmap.width, mode, bitmap.surface.pixels[0 .. bitmap.width * bitmap.width * (bitmap.height / bitmap.width) * bitmap.surface.format.BytesPerPixel]);
	}

	public void resize(u32 width, u32 height, u32 depth, void[] pixels = null)
	{
		bind(0);
		m_width = width;
		m_height = height;
		m_depth = depth;
		glTexImage3D(GL_TEXTURE_3D, 0, m_mode, width, height, depth, 0, m_mode, GL_UNSIGNED_BYTE, pixels.ptr);
	}

	public void destroy()
	{
		glDeleteTextures(1, &m_id);
	}
}

class GLTexturePool
{
	public static GLTexture load(string texture)
	{
		if ((texture in m_textures) !is null)
			return m_textures[texture];

		m_textures[texture] = new GLTexture();
		m_textures[texture].fromBitmap(Bitmap.load(texture));
		return m_textures[texture];
	}

	private static GLTexture[string] m_textures;
}
