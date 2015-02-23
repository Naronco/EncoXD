module Enco.Shared.Render.Bitmap;

import EncoShared;

class Bitmap
{
	private SDL_Surface* m_handle;

	public @property SDL_Surface* surface() { return m_handle; }
	public @property bool valid() { return m_handle !is null; }
	
	public @property i32 width() { return m_handle.w; }
	public @property i32 height() { return m_handle.h; }

	private this(SDL_Surface* surface)
	{
		m_handle = surface;
	}

	public this(i32 width, i32 height, i32 depth)
	{
		m_handle = SDL_CreateRGBSurface(0, width, height, depth, 0, 0, 0, 0);
	}

	public ~this()
	{
		destroy();
	}

	public this(void[] pixels, i32 width, i32 height, i32 depth)
	{
		m_handle = SDL_CreateRGBSurfaceFrom(pixels.ptr, width, height, depth, width * (depth >> 3), 0, 0, 0, 0);
	}

	public static Bitmap fromSurface(SDL_Surface* surface)
	{
		return new Bitmap(surface);
	}

	public static Bitmap load(string file)
	{
		Bitmap bmp = new Bitmap(IMG_Load((file ~ '\0').ptr));

		if(!bmp.valid)
		{
			Logger.errln("Can't load texture ", file);
			i32 i = 0;
			const char* err = IMG_GetError();
			for(i32 x = 0; x < 1024; x++)
			{
				i = x;
				if(err[x] == '\0') break;
			}
			Logger.errln(err[0 .. i]);
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
		SDL_SaveBMP(m_handle, (file ~ "\0").ptr);
	}
}