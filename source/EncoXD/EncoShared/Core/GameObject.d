module Enco.Shared.Core.GameObject;

import std.algorithm;

import EncoShared;

class GameObject
{
	private GameObject[] m_children;
	private bool m_enabled = true;

	public this()
	{
	}

	public void add(IRenderer renderer)
	{
		m_renderer = renderer;
	}

	public void addChild(GameObject child)
	{
		if(child == this) return;
		m_children ~= child;
	}

	public void removeChild(GameObject child)
	{
		m_children = remove!(c => c == child)(m_children);
	}

	public @property GameObject[] children()
	{
		return m_children;
	}

	protected void update(f64 deltaTime) {}

	protected void draw(RenderContext context, IRenderer renderer) {}

	protected void draw2D(GUIRenderer renderer) {}

	public void performUpdate(f64 deltaTime)
	{
		if(m_enabled)
		{
			foreach(IComponent com; m_components)
			{
				com.preUpdate(deltaTime);
			}

			foreach(ref GameObject child; m_children)
				child.performUpdate(deltaTime);
			update(deltaTime);

			foreach(IComponent com; m_components)
			{
				com.update(deltaTime);
			}
		}
	}

	public void performDraw(RenderContext context, IRenderer renderer)
	{
		if(m_enabled)
		{
			m_renderer = renderer;

			foreach(IComponent com; m_components)
			{
				com.preDraw(context, renderer);
			}

			foreach(ref GameObject child; m_children)
				child.performDraw(context, renderer);
			draw(context, renderer);

			foreach(IComponent com; m_components)
			{
				com.draw(context, renderer);
			}
		}
	}

	public void performDraw2D(GUIRenderer renderer)
	{
		if(m_enabled)
		{
			foreach(IComponent com; m_components)
			{
				com.preDraw2D(renderer);
			}

			foreach(ref GameObject child; m_children)
				child.performDraw2D(renderer);
			draw2D(renderer);

			foreach(IComponent com; m_components)
			{
				com.draw2D(renderer);
			}
		}
	}

	public void destroy() {  }

	public Transform transform = Transform();
	public void[] data = null;

	public void addComponent(IComponent component)
	{
		m_components.length++;
		m_components[m_components.length - 1] = component;
		component.add(this);
	}

	public ref @property bool enabled() { return m_enabled; }

	protected @property IRenderer renderer() { return m_renderer; }
	private IRenderer m_renderer;

	private IComponent[] m_components;
}
