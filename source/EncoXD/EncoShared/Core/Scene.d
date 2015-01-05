module Enco.Shared.Core.Scene;

import std.algorithm;

import EncoShared;

class RenderLayer
{
	public void init(Scene scene) {}

	protected void preUpdate(f64 deltaTime) {}
	protected void update(f64 deltaTime) {}
	
	protected void preDraw(RenderContext context, IRenderer renderer) {}
	protected void draw(RenderContext context, IRenderer renderer) {}

	public void performUpdate(f64 deltaTime)
	{
		preUpdate(deltaTime);
		foreach(GameObject obj; m_gameObjects)
		{
			obj.performUpdate(deltaTime);
		}
		update(deltaTime);
	}

	public void performDraw(RenderContext context, IRenderer renderer)
	{
		preDraw(context, renderer);
		foreach(GameObject obj; m_gameObjects)
		{
			obj.performDraw(context, renderer);
		}
		draw(context, renderer);
	}

	public GameObject addGameObject(GameObject object)
	{
		m_gameObjects.length++;
		m_gameObjects[m_gameObjects.length - 1] = object;
		return object;
	}

	public void removeGameObject(GameObject object)
	{
		m_gameObjects = remove!(o => o == object)(m_gameObjects);
	}

	public @property GameObject[] gameObjects() { return m_gameObjects; }

	public void destroy()
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
	public void init() {}

	public bool update(f64 deltaTime)
	{
		foreach(RenderLayer layer; m_layers)
		{
			layer.performUpdate(deltaTime);
		}
		return m_next is null;
	}

	public void draw(RenderContext context, IRenderer renderer)
	{
		foreach(RenderLayer layer; m_layers)
		{
			layer.performDraw(context, renderer);
		}
	}

	public @property void next(Scene scene) { m_next = scene; }
	public @property Scene next() { return m_next; }

	public void addLayer(RenderLayer layer)
	{
		m_layers.length++;
		m_layers[m_layers.length - 1] = layer;
		layer.init(this);
	}

	public void destroy()
	{
		foreach(RenderLayer layer; m_layers)
		{
			layer.destroy();
		}
		m_layers = null;
	}
	
	public IRenderer renderer;
	public IView view;

	private Scene m_next = null;
	private RenderLayer[] m_layers;
}