module Enco.Shared.Scene;

import EncoShared;

class RenderLayer
{
	void init(Scene scene) {}

	protected void preUpdate(f64 deltaTime) {}
	protected void update(f64 deltaTime) {}
	
	protected void preDraw(RenderContext context, IRenderer renderer) {}
	protected void draw(RenderContext context, IRenderer renderer) {}

	void performUpdate(f64 deltaTime)
	{
		preUpdate(deltaTime);
		foreach(GameObject obj; m_gameObjects)
		{
			obj.performUpdate(deltaTime);
		}
		update(deltaTime);
	}

	void performDraw(RenderContext context, IRenderer renderer)
	{
		preDraw(context, renderer);
		foreach(GameObject obj; m_gameObjects)
		{
			obj.performDraw(context, renderer);
		}
		draw(context, renderer);
	}

	void addGameObject(GameObject object)
	{
		m_gameObjects.length++;
		m_gameObjects[m_gameObjects.length - 1] = object;
	}

	void destroy()
	{
		foreach(GameObject obj; m_gameObjects)
		{
			obj.destroy();
		}
		m_gameObjects = null;
	}

	private GameObject[] m_gameObjects;
}

class Scene
{
	void init() {}

	bool update(f64 deltaTime)
	{
		foreach(RenderLayer layer; m_layers)
		{
			layer.performUpdate(deltaTime);
		}
		return m_next is null;
	}

	void draw(RenderContext context, IRenderer renderer)
	{
		foreach(RenderLayer layer; m_layers)
		{
			layer.performDraw(context, renderer);
		}
	}

	@property void next(Scene scene) { m_next = scene; }
	@property Scene next() { return m_next; }

	void addLayer(RenderLayer layer)
	{
		m_layers.length++;
		m_layers[m_layers.length - 1] = layer;
		layer.init(this);
	}

	void destroy()
	{
		foreach(RenderLayer layer; m_layers)
		{
			layer.destroy();
		}
		m_layers = null;
	}
	
	IRenderer renderer;
	IView view;

	private Scene m_next = null;
	private RenderLayer[] m_layers;
}