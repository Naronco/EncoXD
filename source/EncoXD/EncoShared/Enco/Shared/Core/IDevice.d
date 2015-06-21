module Enco.Shared.Core.IDevice;

import EncoShared;

interface IDevice
{
	ITexture3D createTexture3D();
	ITexture createTexture();
	IMaterialManager createMaterialManager();
	Shader createShader();
	ShaderProgram createShaderProgram();
	IRenderTarget createRenderTarget();
	IRenderer getRenderer();
}