module Enco.GL3.GLTexture;

import EncoGL3;
import std.stdio;

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

		// TODO: Add wrap
		// TODO: Add min/mag filter
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	}

	void bind(u32 unit)
	{
		glActiveTexture(GL_TEXTURE0 + unit);
		glBindTexture(GL_TEXTURE_2D, m_id);
	}

	void load(string file)
	{
		auto surface = IMG_Load(file.ptr);
		
		if(surface.pixels == null)
		{
			writeln("Can't load Texture ", file);
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

	@property u32 id() { return m_id; }

	u32 m_id;
}