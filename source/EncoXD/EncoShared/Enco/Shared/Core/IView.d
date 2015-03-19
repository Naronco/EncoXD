module Enco.Shared.Core.IView;

import std.json;

import EncoShared;

abstract class IView
{
	public abstract void create();
	public abstract void destroy();

	public void importSettings(JSONValue json);

	public abstract void handleEvent(ref SDL_Event event);

	public @property void size(u32vec2 size) { m_size = size; onResize(); }
	public @property void name(string name) { m_name = name; onRename(); }

	public @property u32vec2 size() { return m_size; }
	public @property string name() { return m_name; }

	protected abstract void onResize();
	protected abstract void onRename();

	public @property u32 width() { return m_size.x; }
	public @property u32 height() { return m_size.y; }
	
	public ref @property Scene scene() { return m_scene; }
	public ref @property IRenderer renderer() { return m_renderer; }

	public void performDraw()
	{
		renderer.makeCurrent();
		renderer.beginFrame();
		onDraw();
		renderer.endFrame();
	}

	public void performUpdate(f64 delta)
	{
		onUpdate(delta);
	}

	protected void draw3D(RenderContext context)
	{
		if(scene !is null)
			scene.draw3D(context, renderer);
	}

	protected void draw2D()
	{
		if(scene !is null)
			scene.draw2D(renderer.gui);
	}

	public void update(f64 delta)
	{
		if(m_scene !is null)
			m_scene.update(delta);
	}
	
	protected abstract void onDraw() {}
	protected abstract void onUpdate(f64 delta) {}

	protected u32vec2 m_size;
	protected string m_name;
	protected Scene m_scene;
	protected IRenderer m_renderer;
}
