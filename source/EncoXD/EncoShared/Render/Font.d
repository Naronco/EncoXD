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
		handle = TTF_OpenFont(font.toStringz(), sizeInPt);
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

	public ITexture render(T : ITexture)(string text, Color color)
	{
		ITexture tex = new T();
		string[] lines = text.split('\n');
		i32 maxWidth;
		foreach(string line; lines)
		{
			i32 w, h;
			TTF_SizeText(handle, line.toStringz(), &w, &h);
			maxWidth = max(w, maxWidth);
		}
		tex.fromBitmap(Bitmap.fromSurface(TTF_RenderUTF8_Blended_Wrapped(handle, text.toStringz(), color.sdl_color, maxWidth)), "Blended Text: " ~ text);
		return tex;
	}
}