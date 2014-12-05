module Enco.Shared.EncoContext;

import EncoShared;

class EncoContext
{
	this(IView mainView, IRenderer renderer, Scene scene)
	{
		m_mainView = mainView;
		m_renderer = renderer;
		m_scene = scene;
		
		assert(m_mainView !is null);
		assert(m_renderer !is null);
		assert(m_scene !is null);

		DerelictSDL2.load();
		DerelictSDL2Image.load();
		DerelictASSIMP3.load();
	}

	~this()
	{
	}

	void start()
	{
		m_mainView.create(m_renderer);

		m_scene.renderer = m_renderer;
		m_scene.view = m_mainView;
		m_scene.init();
	}

	void stop()
	{
		m_mainView.destroy();
	}

	bool update()
	{
		if(!m_scene.update(0))
		{
			m_scene.destroy();
			m_scene = m_scene.next;
			m_scene.init();
		}
		return m_mainView.update(0); // TODO: Add delta time
	}

	void draw(RenderContext context)
	{
		m_scene.draw(context, m_renderer);
	}


	@property Scene scene() { return m_scene; }
	@property IView view() { return m_mainView; }
	@property IRenderer renderer() { return m_renderer; }

	IView getMainView() { return m_mainView; }

	private IView m_mainView;
	private IRenderer m_renderer;
	private Scene m_scene;
}