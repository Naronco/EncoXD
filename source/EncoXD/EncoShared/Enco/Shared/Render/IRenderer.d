module Enco.Shared.Render.IRenderer;

import std.json;

import EncoShared;

enum RenderingBuffer : int
{
	colorBuffer   = 1 << 0,
	depthBuffer   = 1 << 1,
	stencilBuffer = 1 << 2,
}

interface IRenderer
{
	void createContext(int x, int y, uint width, uint height, uint colorBits, uint depthBits, uint stencilBits, bool fullscreen, Window window, bool useGui = true, string guiMaterial = "res/materials/gui.json");
	void deleteContext();

	void importSettings(JSONValue json);
	void postImportSettings(JSONValue json);

	int getSDLOptions();

	void beginFrame();
	void endFrame();

	@property void enableDepthTest(bool value);
	@property bool enableDepthTest();

	@property void enableBlend(bool value);
	@property bool enableBlend();

	@property GUIRenderer gui();
	@property ITexture white();

	void makeCurrent(); /// OpenGL only

	final void setClearColor(vec3 color)
	{
		setClearColor(color.r, color.g, color.b);
	}
	void setClearColor(float r, float g, float b);

	void setClearDepth(double clearDepth);

	void clearBuffer(RenderingBuffer buffers);

	Mesh createMesh(Mesh mesh);
	void deleteMesh(Mesh mesh);
	void renderMesh(Mesh mesh);

	void resize(uint width, uint height);

	Bitmap getComputed();

	ShaderProgram createShader(Shader[] shaders);
}
