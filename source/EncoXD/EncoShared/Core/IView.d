module Enco.Shared.Core.IView;

import std.json;

import EncoShared;

abstract class IView
{
	public abstract void create(IRenderer renderer);
	public abstract void destroy();

	public void importSettings(JSONValue json);

	public abstract bool update(f64 deltaTime);

	public @property void size(u32vec2 size) { m_size = size; onResize(); }
	public @property void name(string name) { m_name = name; onRename(); }

	public @property u32vec2 size() { return m_size; }
	public @property string name() { return m_name; }

	protected abstract void onResize();
	protected abstract void onRename();

	public @property u32 width() { return m_size.x; }
	public @property u32 height() { return m_size.y; }

	protected u32vec2 m_size;
	protected string m_name;
}
