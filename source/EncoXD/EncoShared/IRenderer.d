module Enco.Shared.IRenderer;

import EncoShared;

enum RenderingBuffer : int
{
	colorBuffer = 1 << 0,
	depthBuffer = 1 << 1,
	stencilBuffer = 1 << 2,
}

interface IRenderer
{
	void createContext(i32 x, i32 y, u32 width, u32 height, u32 colorBits, u32 depthBits, u32 stencilBits, bool fullscreen, SDL_Window* sdlWindow = null); // TODO: Replace SDL_Window / Make IView renderable
	void deleteContext();

	int getSDLOptions();

	void beginFrame();
	void endFrame();

	void makeCurrent(); /// OpenGL only

	final void setClearColor(vec3 color) { setClearColor(color.r, color.g, color.b); }
	void setClearColor(f32 r, f32 g, f32 b);

	void setClearDepth(f64 clearDepth);

	void clearBuffer(RenderingBuffer buffers);

	Mesh createMesh(Mesh mesh);
	void deleteMesh(Mesh mesh);
	void renderMesh(Mesh mesh);

	ShaderProgram createShader(Shader[] shaders);
}