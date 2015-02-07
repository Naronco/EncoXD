module Enco.Shared.Render.Font;

import EncoShared;

class Font
{
	private TTF_Font* handle;

	public this(string font, i32 sizeInPt)
	{
		if(!EncoContext.instance.loaded.contains(DynamicLibrary.SDL2TTF))
		{
			Logger.errln("SDL2TTF not initialized (EncoContext.useDynamicLibraries)");
			return;
		}
		handle = TTF_OpenFont((font ~ "\0").ptr, sizeInPt);
		if(handle is null)
		{
			Logger.errln("Error initializing ", font, ": ", TTF_GetError());
		}
	}

	public ~this()
	{
		if(handle !is null)
		{
			TTF_CloseFont(handle);
			handle = null;
		}
	}

	public ITexture render(T : ITexture)(string text, Color color, u32 lineWidth = 1000)
	{
		ITexture tex = new T();
		tex.fromSurface(TTF_RenderUTF8_Blended_Wrapped(handle, (text ~ "\0").ptr, color.sdl_color, lineWidth), "Blended Text: " ~ text);
		return tex;
	}

	public ITexture renderFast(T : ITexture)(string text, Color color, u32 lineWidth = 1000)
	{
		ITexture tex = new T();
		tex.fromSurface(SDL_ConvertSurfaceFormat(TTF_RenderUTF8_Solid_Wrapped(handle, (text ~ "\0").ptr, color.sdl_color, lineWidth), SDL_PIXELFORMAT_RGBA8888, 0), "Solid Text: " ~ text);
		return tex;
	}
}