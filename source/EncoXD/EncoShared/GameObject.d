module Enco.Shared.GameObject;

import EncoShared;

class GameObject
{
	this()
	{
		
	}
	
	protected void update(f64 deltaTime) {}

	protected void draw(RenderContext context, IRenderer renderer) {}

	void performUpdate(f64 deltaTime)
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

	void performDraw(RenderContext context, IRenderer renderer)
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
	}

	void destroy() {  }

	Transform transform = Transform();

	void addComponent(IComponent component)
	{
		m_components.length++;
		m_components[m_components.length - 1] = component;
		component.add(this);
	}

	private IComponent[] m_components;
}