module Enco.GL3.GLDevice;

import EncoGL3;

class GLDevice : IDevice
{
private:
	GL3Renderer m_renderer;

public:
	this(GL3Renderer renderer)
	{
		assert(renderer !is null, "Passed null as renderer");
		m_renderer = renderer;
	}

	ITexture3D createTexture3D()
	{
		return new GLTexture3D();
	}

	ITexture createTexture()
	{
		return new GLTexture();
	}

	IMaterialManager createMaterialManager()
	{
		return new GLMaterialManager(m_renderer);
	}

	GLShader createShader()
	{
		return new GLShader();
	}

	ShaderProgram createShaderProgram()
	{
		return new GLShaderProgram();
	}

	IRenderTarget createRenderTarget()
	{
		return new GLRenderTarget();
	}

	IRenderer getRenderer()
	{
		return m_renderer;
	}
}