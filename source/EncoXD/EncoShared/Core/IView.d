module EncoShared.Core.IView;

import std.json;

import EncoShared;

abstract class IView
{
	public void doCreate()
	{
		create();

		if (!m_created && m_scene !is null)
		{
			m_scene.view = this;
			if (renderer !is null)
				m_scene.setRenderer(renderer);
			m_scene.init();
		}
		m_created = true;
	}

	protected abstract void create();
	public abstract void destroy();

	public void importSettings(JSONValue json);

	public abstract void handleEvent(ref SDL_Event event);

	public @property void size(u32vec2 size)
	{
		m_size = size; onResize();
	}

	public @property void name(string name)
	{
		m_name = name; onRename();
	}

	public @property u32vec2 size()
	{
		return m_size;
	}

	public @property string name()
	{
		return m_name;
	}

	protected abstract void onResize();
	protected abstract void onRename();

	public @property uint width()
	{
		return m_size.x;
	}

	public @property uint height()
	{
		return m_size.y;
	}

	public @property void scene(Scene scene)
	{
		if (scene !is null)
		{
			if (m_created)
			{
				scene.view = this;
				if (renderer !is null)
					scene.setRenderer(renderer);
				scene.init();
			}
			m_scene = scene;
		}
	}

	public @property Scene scene()
	{
		return m_scene;
	}

	public ref @property IRenderer renderer()
	{
		return m_renderer;
	}

	public void performDraw()
	{
		renderer.makeCurrent();
		renderer.beginFrame();
		onDraw();
		renderer.endFrame();
	}

	public void performUpdate(double delta)
	{
		onUpdate(delta);
	}

	protected void draw3D(RenderContext context)
	{
		if (scene !is null)
			scene.performDraw(context, renderer);
	}

	protected void draw2D()
	{
		if (scene !is null)
			scene.performDraw2D(renderer.gui);
	}

	public void update(double delta)
	{
		if (m_scene !is null)
			m_scene.performUpdate(delta);
	}

	protected abstract void onDraw()
	{
	}

	protected abstract void onUpdate(double delta)
	{
	}

	protected bool m_created = false;
	protected u32vec2 m_size;
	protected string m_name;
	protected Scene m_scene;
	protected IRenderer m_renderer;
}
