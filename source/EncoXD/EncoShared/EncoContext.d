module Enco.Shared.EncoContext;

import EncoShared;

class EncoContext
{
	this(IView mainView, IRenderer renderer)
	{
		m_mainView = mainView;
		m_renderer = renderer;
	}

	~this()
	{
	}

	void start()
	{
		DerelictSDL2.load();
		DerelictSDL2Image.load();
		DerelictASSIMP3.load();

		m_mainView.create(m_renderer);
	}

	void stop()
	{
		m_mainView.destroy();
	}

	bool update()
	{
		return m_mainView.update(0); // TODO: Add delta time
	}

	IView getMainView() { return m_mainView; }

	private IView m_mainView;
	private IRenderer m_renderer;
}