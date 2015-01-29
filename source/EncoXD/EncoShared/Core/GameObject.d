module Enco.Shared.Core.GameObject;

import EncoShared;

class GameObject
{
	public this()
	{
		
	}
	
	protected void update(f64 deltaTime) {}

	protected void draw(RenderContext context, IRenderer renderer) {}

	protected void draw2D(GUIRenderer renderer) {}

	public void performUpdate(f64 deltaTime)
	{
		foreach(IComponent com; m_components)
		{
			com.preUpdate(deltaTime);
		}

		update(deltaTime);

		foreach(IComponent com; m_components)
		{
			com.update(deltaTime);
		}
	}

	public void performDraw(RenderContext context, IRenderer renderer)
	{
		foreach(IComponent com; m_components)
		{
			com.preDraw(context, renderer);
		}

		draw(context, renderer);

		foreach(IComponent com; m_components)
		{
			com.draw(context, renderer);
		}

		
		foreach(IComponent com; m_components)
		{
			com.preDraw2D(renderer.gui);
		}

		draw2D(renderer.gui);

		foreach(IComponent com; m_components)
		{
			com.draw2D(renderer.gui);
		}
	}

	public void destroy() {  }

	public Transform transform = Transform();
	public void* data = null;

	public void addComponent(IComponent component)
	{
		m_components.length++;
		m_components[m_components.length - 1] = component;
		component.add(this);
	}

	private IComponent[] m_components;
}