module Enco.Shared.Core.Window;

import EncoShared;

class Window
{
	private SDL_Window* m_handle;

	public @property SDL_Window* window() { return m_handle; }
	public @property bool valid() { return m_handle !is null; }

	public this(string title, i32 x, i32 y, i32 w, i32 h, u32 flags)
	{
		m_handle = SDL_CreateWindow(title.ptr, x, y, w, h, flags);
	}

	public ~this()
	{
		destroy();
	}

	public void destroy()
	{
		SDL_DestroyWindow(m_handle);
	}

	public @property void title(string title)
	{
		SDL_SetWindowTitle(m_handle, title.ptr);
	}

	public @property string title()
	{
		const(char)* title = SDL_GetWindowTitle(m_handle);
		i32 i;
		for(i = 0; i < 1024; i++)
			if(title[i] == '\0') break;
		return cast(string)(title[0 .. i]);
	}

	public @property void size(u32vec2 size)
	{
		SDL_SetWindowSize(m_handle, cast(i32)size.x, cast(i32)size.y);
	}

	public @property u32vec2 size()
	{
		i32 x, y;
		SDL_GetWindowSize(m_handle, &x, &y);
		return u32vec2(cast(u32)x, cast(u32)y);
	}

	public @property void maxSize(u32vec2 size)
	{
		SDL_SetWindowMaximumSize(m_handle, cast(i32)size.x, cast(i32)size.y);
	}

	public @property u32vec2 maxSize()
	{
		i32 x, y;
		SDL_GetWindowMaximumSize(m_handle, &x, &y);
		return u32vec2(cast(u32)x, cast(u32)y);
	}

	public @property void minSize(u32vec2 size)
	{
		SDL_SetWindowMinimumSize(m_handle, cast(i32)size.x, cast(i32)size.y);
	}

	public @property u32vec2 minSize()
	{
		i32 x, y;
		SDL_GetWindowMinimumSize(m_handle, &x, &y);
		return u32vec2(cast(u32)x, cast(u32)y);
	}

	public @property void position(u32vec2 pos)
	{
		SDL_SetWindowPosition(m_handle, cast(i32)pos.x, cast(i32)pos.y);
	}

	public @property u32vec2 position()
	{
		i32 x, y;
		SDL_GetWindowPosition(m_handle, &x, &y);
		return u32vec2(cast(u32)x, cast(u32)y);
	}

	public void show()
	{
		SDL_ShowWindow(m_handle);
	}

	public void hide()
	{
		SDL_HideWindow(m_handle);
	}

	public void minimized()
	{
		SDL_MinimizeWindow(m_handle);
	}

	public void maximize()
	{
		SDL_MaximizeWindow(m_handle);
	}

	public void restore()
	{
		SDL_RestoreWindow(m_handle);
	}

	public void focus()
	{
		SDL_RaiseWindow(m_handle);
	}

	public void setIcon(Bitmap icon)
	{
		SDL_SetWindowIcon(m_handle, icon.surface);
	}
}
