module Enco.Shared.IComponent;

import EncoShared;

interface IComponent
{
	void add(GameObject object);

	void preUpdate(f64 deltaTime);
	void update(f64 deltaTime);

	void preDraw(RenderContext context, IRenderer renderer);
	void draw(RenderContext context, IRenderer renderer);
}