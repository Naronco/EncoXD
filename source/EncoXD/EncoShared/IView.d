module Enco.Shared.IView;

import EncoShared;

abstract class IView
{
	abstract void create(IRenderer renderer);
	abstract void destroy();

	abstract bool update(f64 deltaTime);
	
	void setSize(u32vec2 size) { m_size = size; onResize(); }
	void setName(string name) { m_name = name; onRename(); }
	
	protected abstract void onResize();
	protected abstract void onRename();
	
	final @property u32 width() { return m_size.x; }
	final @property u32 height() { return m_size.y; }

	protected u32vec2 m_size;
	protected string m_name;
}