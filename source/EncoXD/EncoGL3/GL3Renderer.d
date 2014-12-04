module Enco.GL3.GL3Renderer;

import EncoGL3;

import std.stdio;

class GL3Renderer : IRenderer
{
	this()
	{

	}

	~this()
	{

	}

	void createContext(i32 x, i32 y, u32 width, u32 height, u32 colorBits, u32 depthBits, u32 stencilBits, bool fullscreen, SDL_Window* sdlWindow = null)
	{
		if(sdlWindow != null)
		{
			DerelictGL3.load();

			m_window = sdlWindow;
			
			SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, cast(i32)depthBits);
			SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, cast(i32)stencilBits);

			SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
			SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);

			m_context = SDL_GL_CreateContext(m_window);

			DerelictGL3.reload();

			m_valid = true;
		}
	}

	void deleteContext()
	{
		if(valid)
		{
			SDL_GL_DeleteContext(m_context);
			m_context = null;
		}
	}

	int getSDLOptions()
	{
		return SDL_WINDOW_OPENGL;
	}

	void beginFrame()
	{
	}

	void endFrame()
	{
		if(valid)
		{
			SDL_GL_SwapWindow(m_window);
		}
	}

	/// OpenGL only
	void makeCurrent()
	{
		if(valid)
		{
			SDL_GL_MakeCurrent(m_window, m_context);
		}
	}


	void setClearColor(f32 r, f32 g, f32 b)
	{
		glClearColor(r, g, b, 1);
	}

	void setClearDepth(f64 clearDepth)
	{
		glClearDepth(clearDepth);
	}

	void clearBuffer(RenderingBuffer buffers)
	{
		if ((buffers & RenderingBuffer.colorBuffer) == RenderingBuffer.colorBuffer) {
			glClear(GL_COLOR_BUFFER_BIT);
		}
		if ((buffers & RenderingBuffer.depthBuffer) == RenderingBuffer.depthBuffer) {
			glClear(GL_DEPTH_BUFFER_BIT);
		}
		if ((buffers & RenderingBuffer.stencilBuffer) == RenderingBuffer.stencilBuffer) {
			glClear(GL_STENCIL_BUFFER_BIT);
		}
	}
	
	private static const int bufferCount = 4;

	RenderableMesh createMesh(Mesh mesh)
	{
		u32 vao;
		glGenVertexArrays(1, &vao);
		glBindVertexArray(vao);


		u32* vbo = new u32[bufferCount].ptr;

		glGenBuffers(bufferCount, vbo);

		glBindBuffer(GL_ARRAY_BUFFER, vbo[0]);
		glBufferData(GL_ARRAY_BUFFER, vec3.sizeof * mesh.vertices.length, mesh.vertices.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(0u, 3, GL_FLOAT, cast(u8)0, 0, null);
		glEnableVertexAttribArray(0);

		glBindBuffer(GL_ARRAY_BUFFER, vbo[1]);
		glBufferData(GL_ARRAY_BUFFER, vec2.sizeof * mesh.texCoords.length, mesh.texCoords.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(1u, 2, GL_FLOAT, cast(u8)0, 0, null);
		glEnableVertexAttribArray(1);

		glBindBuffer(GL_ARRAY_BUFFER, vbo[2]);
		glBufferData(GL_ARRAY_BUFFER, vec3.sizeof * mesh.normals.length, mesh.normals.ptr, GL_STATIC_DRAW);
		glVertexAttribPointer(2u, 3, GL_FLOAT, cast(u8)0, 0, null);
		glEnableVertexAttribArray(2);

		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo[bufferCount - 1]);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, uint.sizeof * mesh.indices.length, mesh.indices.ptr, GL_STATIC_DRAW);

		glBindVertexArray(0);

		return RenderableMesh(vao, vbo, mesh.indices.length);
	}

	void deleteMesh(RenderableMesh mesh)
	{
		glDeleteBuffers(bufferCount, mesh.vbos);
		glDeleteVertexArrays(1, &mesh.bufferID);
	}

	void renderMesh(RenderableMesh mesh)
	{
		glBindVertexArray(mesh.bufferID);
		glDrawElements(GL_TRIANGLES, mesh.indexLength, GL_UNSIGNED_INT, null);
	}

	ShaderProgram createShader(Shader[] shaders)
	{
		GLShaderProgram program = new GLShaderProgram();
		program.create();

		foreach(Shader shader; shaders)
		{
			program.attach(shader);
		}

		program.link();

		return program;
	}

	@property bool valid() { return m_valid; }

	private bool m_valid = false;
	SDL_Window* m_window;
	SDL_GLContext m_context;
}