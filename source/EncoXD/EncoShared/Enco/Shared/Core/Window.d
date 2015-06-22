module Enco.Shared.Core.Window;

import EncoShared;

class Window
{
	private SDL_Window* m_handle;
	private int m_id;

	public @property SDL_Window* window()
	{
		return m_handle;
	}
	public @property bool valid()
	{
		return m_handle !is null;
	}
	public @property int id()
	{
		return m_id;
	}

	public this(string title, int x, int y, int w, int h, uint flags)
	{
		m_handle = SDL_CreateWindow(title.toStringz(), x, y, w, h, flags);
		m_id = SDL_GetWindowID(m_handle);
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
		SDL_SetWindowTitle(m_handle, title.toStringz());
	}

	public @property string title()
	{
		string title = SDL_GetWindowTitle(m_handle).fromStringz().dup;
		return title;
	}

	public @property void size(u32vec2 size)
	{
		SDL_SetWindowSize(m_handle, cast(int) size.x, cast(int) size.y);
	}

	public @property u32vec2 size()
	{
		int x, y;
		SDL_GetWindowSize(m_handle, &x, &y);
		return u32vec2(cast(uint) x, cast(uint) y);
	}

	public @property void maxSize(u32vec2 size)
	{
		SDL_SetWindowMaximumSize(m_handle, cast(int) size.x, cast(int) size.y);
	}

	public @property u32vec2 maxSize()
	{
		int x, y;
		SDL_GetWindowMaximumSize(m_handle, &x, &y);
		return u32vec2(cast(uint) x, cast(uint) y);
	}

	public @property void minSize(u32vec2 size)
	{
		SDL_SetWindowMinimumSize(m_handle, cast(int) size.x, cast(int) size.y);
	}

	public @property u32vec2 minSize()
	{
		int x, y;
		SDL_GetWindowMinimumSize(m_handle, &x, &y);
		return u32vec2(cast(uint) x, cast(uint) y);
	}

	public @property void position(u32vec2 pos)
	{
		SDL_SetWindowPosition(m_handle, cast(int) pos.x, cast(int) pos.y);
	}

	public @property u32vec2 position()
	{
		int x, y;
		SDL_GetWindowPosition(m_handle, &x, &y);
		return u32vec2(cast(uint) x, cast(uint) y);
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
