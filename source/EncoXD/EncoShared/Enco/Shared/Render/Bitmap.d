module Enco.Shared.Render.Bitmap;

import EncoShared;

class Bitmap
{
	private SDL_Surface* m_handle;

	public @property SDL_Surface* surface()
	{
		return m_handle;
	}
	public @property bool valid()
	{
		return m_handle !is null;
	}

	public @property int width()
	{
		return m_handle.w;
	}
	public @property int height()
	{
		return m_handle.h;
	}

	private this(SDL_Surface * surface)
	{
		m_handle = surface;
	}

	public this(int width, int height, int depth)
	{
		m_handle = SDL_CreateRGBSurface(0, width, height, depth, 0, 0, 0, 0);
	}

	public ~this()
	{
		destroy();
	}

	public this(void[] pixels, int width, int height, int depth)
	{
		m_handle = SDL_CreateRGBSurfaceFrom(pixels.ptr, width, height, depth, width * (depth >> 3), 0, 0, 0, 0);
	}

	public static Bitmap fromSurface(SDL_Surface* surface)
	{
		return new Bitmap(surface);
	}

	public static Bitmap load(string file)
	{
		Bitmap bmp = new Bitmap(IMG_Load(file.toStringz()));

		if (!bmp.valid)
		{
			Logger.errln("Can't load texture ", file);
			Logger.errln(IMG_GetError().fromStringz());
		}

		return bmp;
	}

	public void destroy()
	{
		SDL_FreeSurface(m_handle);
		m_handle = null;
	}

	public void save(string file)
	{
		SDL_SaveBMP(m_handle, file.toStringz());
	}

	public Bitmap convert(const SDL_PixelFormat* format)
	{
		return new Bitmap(SDL_ConvertSurface(m_handle, format, 0));
	}

	public uint mapRGB(Color color)
	{
		return SDL_MapRGB(m_handle.format, color.R, color.G, color.B);
	}

	public void fill(Color color)
	{
		SDL_FillRect(m_handle, null, mapRGB(color));
	}

	public void fill(int x, int y, int width, int height, Color color)
	{
		SDL_FillRect(m_handle, new SDL_Rect(x, y, width, height), mapRGB(color));
	}

	public Color getPixel(int x, int y)
	{
		ubyte r, g, b;
		SDL_GetRGB((cast(uint*) m_handle.pixels)[x + y * width], m_handle.format, &r, &g, &b);
		return Color(r, g, b);
	}

	public void setPixel(int x, int y, Color color)
	{
		(cast(uint*) m_handle.pixels)[x + y * width] = mapRGB(color);
	}
}
