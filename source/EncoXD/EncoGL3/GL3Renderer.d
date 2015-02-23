module Enco.GL3.GL3Renderer;

import std.stdio;
import std.json;

import EncoGL3;

class GL3Renderer : IRenderer
{
	public this()
	{

	}

	public ~this()
	{

	}

	public void importSettings(JSONValue json)
	{
	}

	public u32 blendFuncFromString(string str)
	{
		switch(str)
		{
			case "Zero": return GL_ZERO;
			case "One": return GL_ONE;
			case "SrcColor": return GL_SRC_COLOR;
			case "OneMinusSrcColor": return GL_ONE_MINUS_SRC_COLOR;
			case "DstColor": return GL_DST_COLOR;
			case "OneMinusDstColor": return GL_ONE_MINUS_DST_COLOR;
			case "SrcAlpha": return GL_SRC_ALPHA;
			case "OneMinusSrcAlpha": return GL_ONE_MINUS_SRC_ALPHA;
			case "DstAlpha": return GL_DST_ALPHA;
			case "OneMinusDstAlpha": return GL_ONE_MINUS_DST_ALPHA;
			case "SrcAlphaSaturate": return GL_SRC_ALPHA_SATURATE;
			case "Src1Color": return GL_SRC1_COLOR;
			case "OneMinusSrc1Color": return GL_ONE_MINUS_SRC1_COLOR;
			case "OneMinusSrc1Alpha": return GL_ONE_MINUS_SRC1_ALPHA;
			default: return GL_ZERO;
		}
	}

	public void postImportSettings(JSONValue json)
	{
		if(("Context" in json) !is null && json["Context"].type == JSON_TYPE.OBJECT)
		{
			enableDepthTest = ("DepthTest" in json["Context"]) !is null && json["Context"]["DepthTest"].type == JSON_TYPE.TRUE;

			if(("CullFace" in json["Context"]) !is null && json["Context"]["CullFace"].type == JSON_TYPE.TRUE)
				glEnable(GL_CULL_FACE);

			if(("InvertCull" in json["Context"]) !is null && json["Context"]["InvertCull"].type == JSON_TYPE.TRUE)
				glCullFace(GL_FRONT);

			if(("ClearColor" in json["Context"]) !is null && json["Context"]["ClearColor"].type == JSON_TYPE.ARRAY && json["Context"]["ClearColor"].array.length == 3)
				setClearColor(json["Context"]["ClearColor"].array[0].floating, json["Context"]["ClearColor"].array[1].floating, json["Context"]["ClearColor"].array[2].floating);

			if(("Blend" in json["Context"]) !is null)
			{
				if(json["Context"]["Blend"].type == JSON_TYPE.OBJECT)
				{
					if(("Enabled" in json["Context"]["Blend"]) !is null && json["Context"]["Blend"]["Enabled"].type == JSON_TYPE.TRUE)
					{
						if(("Src" in json["Context"]["Blend"]) !is null && ("Dest" in json["Context"]["Blend"]) !is null &&
							json["Context"]["Blend"]["Src"].type == JSON_TYPE.STRING && json["Context"]["Blend"]["Dest"].type == JSON_TYPE.STRING)
						{
							string src = json["Context"]["Blend"]["Src"].str;
							string dest = json["Context"]["Blend"]["Dest"].str;

							glBlendFunc(blendFuncFromString(src), blendFuncFromString(dest));
						}
					}
				}
				else if(json["Context"]["Blend"].type == JSON_TYPE.TRUE)
				{
					glEnable(GL_BLEND);
					glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
				}
			}
		}
	}

	public void createContext(i32 x, i32 y, u32 width, u32 height, u32 colorBits, u32 depthBits, u32 stencilBits, bool fullscreen, SDL_Window* sdlWindow = null)
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
			m_gui = new GUIRenderer(this, GLMaterial.load(this, "materials/gui.json"));
			m_gui.resize(width, height);

			m_width = width;
			m_height = height;

			GLTexture.init();
		}
	}

	public void deleteContext()
	{
		if(valid)
		{
			SDL_GL_DeleteContext(m_context);
			m_context = null;
		}
	}

	public int getSDLOptions()
	{
		return SDL_WINDOW_OPENGL | SDL_RENDERER_PRESENTVSYNC;
	}

	public void beginFrame()
	{
	}

	public void endFrame()
	{
		if(valid)
		{
			SDL_GL_SwapWindow(m_window);
		}
	}

	/// OpenGL only
	public void makeCurrent()
	{
		if(valid)
		{
			SDL_GL_MakeCurrent(m_window, m_context);
		}
	}


	public void setClearColor(f32 r, f32 g, f32 b)
	{
		glClearColor(r, g, b, 1);
	}

	public void setClearDepth(f64 clearDepth)
	{
		glClearDepth(clearDepth);
	}

	public void clearBuffer(RenderingBuffer buffers)
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

	public Mesh createMesh(Mesh mesh)
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

		mesh.renderable = new RenderableMesh(vao, vbo, cast(u32)mesh.indices.length);

		return mesh;
	}

	public void deleteMesh(Mesh mesh)
	{
		glDeleteBuffers(bufferCount, mesh.renderable.vbos);
		glDeleteVertexArrays(1, &mesh.renderable.bufferID);
	}

	public void renderMesh(Mesh mesh)
	{
		glBindVertexArray(mesh.renderable.bufferID);
		glDrawElements(GL_TRIANGLES, mesh.renderable.indexLength, GL_UNSIGNED_INT, null);
	}

	public ShaderProgram createShader(Shader[] shaders)
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

	public Bitmap getComputed()
	{
		u8[] pixels = new u8[3 * m_width * m_height];
		glReadPixels(0, 0, m_width, m_height, GL_BGR, GL_UNSIGNED_BYTE, pixels.ptr);
		return new Bitmap(pixels, m_width, m_height, 24);
	}

	public @property void enableDepthTest(bool value)
	{
		if(m_depthTest == value) return;
		m_depthTest = value;
		if(value)
			glEnable(GL_DEPTH_TEST);
		else
			glDisable(GL_DEPTH_TEST);
	}

	public @property bool enableDepthTest() { return m_depthTest; }

	public @property void enableBlend(bool value)
	{
		if(m_blend == value) return;
		m_blend = value;
		if(value)
			glEnable(GL_BLEND);
		else
			glDisable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	public @property bool enableBlend() { return m_blend; }

	public @property bool valid() { return m_valid; }

	public @property GUIRenderer gui() { return m_gui; }
	
	public void resize(u32 width, u32 height)
	{
		m_width = width;
		m_height = height;
		m_gui.resize(width, height);
		glViewport(0, 0, width, height);
	}

	public @property ITexture white() { return GLTexture.white; }

	private bool m_valid = false;
	private bool m_depthTest = false;
	private bool m_blend = false;
	private u32 m_width, m_height;
	private GUIRenderer m_gui;

	public SDL_Window* m_window;
	public SDL_GLContext m_context;
}
