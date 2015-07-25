module EncoShared.Core.GameObject;

import std.algorithm;

import EncoShared;

class GameObject
{
	private GameObject[] m_children;
	private GameObject m_parent;
	private bool m_enabled = true;

	public this()
	{
	}

	public void setRenderer(IRenderer renderer)
	{
		m_renderer = renderer;
	}

	alias addGameObject = addChild;

	public GameObject addChild(GameObject child)
	{
		if (child == this)
			return child;
		child.m_parent = this;
		child.transform.parent = &transform;
		m_children ~= child;
		return child;
	}

	public void removeChild(GameObject child)
	{
		m_children = remove!(c => c == child)(m_children);
	}

	public @property GameObject[] children()
	{
		return m_children;
	}

	protected void update(double deltaTime)
	{
	}

	protected void draw(RenderContext context, IRenderer renderer)
	{
	}

	protected void draw2D(GUIRenderer renderer)
	{
	}

	protected @property GameObject parent()
	{
		return m_parent;
	}

	public void performUpdate(double deltaTime)
	{
		if (m_enabled)
		{
			foreach (IComponent com; m_components)
			{
				com.preUpdate(deltaTime);
			}

			update(deltaTime);
			foreach (ref GameObject child; m_children)
				child.performUpdate(deltaTime);

			foreach (IComponent com; m_components)
			{
				com.update(deltaTime);
			}
		}
	}

	public void performDraw(RenderContext context, IRenderer renderer)
	{
		if (m_enabled)
		{
			m_renderer = renderer;

			foreach (IComponent com; m_components)
			{
				com.preDraw(context, renderer);
			}

			draw(context, renderer);
			foreach (ref GameObject child; m_children)
				child.performDraw(context, renderer);

			foreach (IComponent com; m_components)
			{
				com.draw(context, renderer);
			}
		}
	}

	public void performDraw2D(GUIRenderer renderer)
	{
		if (m_enabled)
		{
			foreach (IComponent com; m_components)
			{
				com.preDraw2D(renderer);
			}

			draw2D(renderer);
			foreach (ref GameObject child; m_children)
				child.performDraw2D(renderer);

			foreach (IComponent com; m_components)
			{
				com.draw2D(renderer);
			}
		}
	}

	public void destroy()
	{
	}

	public Transform transform = Transform();
	public void[]    data = null;

	public void addComponent(IComponent component)
	{
		m_components.length++;
		m_components[m_components.length - 1] = component;
		component.add(this);
	}

	public ref @property bool enabled()
	{
		return m_enabled;
	}

	public @property IRenderer renderer()
	{
		return m_renderer;
	}
	private IRenderer m_renderer;

	private IComponent[] m_components;
}

alias Layer = RenderLayer;

class RenderLayer : GameObject
{
	protected void init(Scene scene)
	{
	}
	public void doInit(Scene scene)
	{
		m_scene = scene; init(scene);
	}

	public override GameObject addChild(GameObject child)
	{
		if (child == this)
			return child;
		child.setRenderer(m_renderer);
		child.m_parent = this;
		m_children ~= child;
		return child;
	}

	protected @property Scene scene()
	{
		return m_scene;
	}
	private Scene m_scene;
}

class Scene : GameObject
{
	public @property void next(Scene scene)
	{
		m_next = scene;
	}
	public @property Scene next()
	{
		return m_next;
	}

	public void init()
	{
	}

	alias addLayer = addChild;

	public override GameObject addChild(GameObject child)
	{
		if (child == this)
			return child;
		if (cast(RenderLayer) child)
			(cast(RenderLayer) child).doInit(this);
		child.setRenderer(m_renderer);
		child.m_parent = this;
		m_children ~= child;
		return child;
	}

	public IView view;

	private Scene m_next = null;
}
