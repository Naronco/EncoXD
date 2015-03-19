module Enco.GL3.GLRenderTarget;

import EncoShared;
import EncoGL3;

class GLRenderTarget : IRenderTarget
{
	public void init(u32 width, u32 height, bool depth, Window view)
	{
		m_view = view;

		glGenFramebuffers(1, &fbo);
		glBindFramebuffer(GL_FRAMEBUFFER, fbo);

		m_color = new GLTexture();
		m_color.minFilter = TextureFilterMode.Nearest;
		m_color.magFilter = TextureFilterMode.Nearest;
		m_color.create(width, height, GL_RGB, null);


		if(depth)
		{
			m_depth = new GLTexture();
			m_depth.minFilter = TextureFilterMode.Nearest;
			m_depth.magFilter = TextureFilterMode.Nearest;
			m_depth.create(width, height, GL_DEPTH_COMPONENT24, GL_DEPTH_COMPONENT, null, GL_FLOAT);
		}

		glGenRenderbuffers(1, &drb);
		glBindRenderbuffer(GL_RENDERBUFFER, drb);
		glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, width, height);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, drb);

		glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, m_color.id, 0);
		if(depth)
			glFramebufferTexture(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, m_depth.id, 0);


		if(depth)
			glDrawBuffers(2, [GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT].ptr);
		else
			glDrawBuffers(1, [GL_COLOR_ATTACHMENT0].ptr);

		if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) assert(0);

		this.width = width;
		this.height = height;
	}

	public void resize(u32 width, u32 height)
	{
		this.width = width;
		this.height = height;
		m_color.resize(width, height);
		if(m_depth !is null) m_depth.resize(width, height);
	}

	public void bind()
	{
		glBindFramebuffer(GL_FRAMEBUFFER, fbo);
		glViewport(0, 0, width, height);
		EncoContext.instance.renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);
	}

	public void unbind()
	{
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glViewport(0, 0, view.size.x, view.size.y);
		EncoContext.instance.renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);
	}

	public @property ITexture color()
	{
		return cast(ITexture)m_color;
	}

	public @property ITexture depth()
	{
		return cast(ITexture)m_depth;
	}

	public @property Window view()
	{
		return m_view;
	}

	private u32 width, height;
	public u32 fbo, drb;
	private GLTexture m_color, m_depth;
	private Window m_view;
}
