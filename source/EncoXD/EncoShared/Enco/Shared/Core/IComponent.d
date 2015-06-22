module Enco.Shared.Core.IComponent;

import EncoShared;

abstract class IComponent
{
	void add(GameObject object)
	{
	}

	void preUpdate(double deltaTime)
	{
	}
	void update(double deltaTime)
	{
	}

	void preDraw(RenderContext context, IRenderer renderer)
	{
	}
	void draw(RenderContext context, IRenderer renderer)
	{
	}

	void preDraw2D(GUIRenderer renderer)
	{
	}
	void draw2D(GUIRenderer renderer)
	{
	}
}
