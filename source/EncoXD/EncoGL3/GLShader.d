module Enco.GL3.GLShader;

import EncoShared;
import EncoGL3;

import std.conv;

class GLShaderProgram : ShaderProgram
{
	public u32 create()
	{
		return program = glCreateProgram();
	}

	public static ShaderProgram fromVertexFragmentFiles(GL3Renderer renderer, string vertex, string fragment)
	{
		GLShader v = new GLShader();
		v.load(ShaderType.Vertex, std.file.readText(vertex));
		v.compile();

		GLShader f = new GLShader();
		f.load(ShaderType.Fragment, std.file.readText(fragment));
		f.compile();

		return renderer.createShader([v, f]);
	}

	public void attach(Shader shader)
	{
		glAttachShader(program, shader.id);
	}

	public void link()
	{
		glLinkProgram(program);
		bind();
	}

	public void bind()
	{
		glUseProgram(program);
	}

	public int registerUniform(string uniform)
	{
		if((uniform in m_properties) !is null)
			return m_properties[uniform];
		m_properties[uniform] = glGetUniformLocation(program, uniform.ptr);
		return m_properties[uniform];
	}

	public void set(string uniform, int value)
	{
		glUniform1i(m_properties[uniform], value);
	}

	public void set(string uniform, float value)
	{
		glUniform1f(m_properties[uniform], value);
	}

	public void set(string uniform, vec2 value)
	{
		glUniform2fv(m_properties[uniform], 1, value.value_ptr);
	}

	public void set(string uniform, vec3 value)
	{
		glUniform3fv(m_properties[uniform], 1, value.value_ptr);
	}

	public void set(string uniform, vec4 value)
	{
		glUniform4fv(m_properties[uniform], 1, value.value_ptr);
	}

	public void set(string uniform, mat2 value)
	{
		glUniformMatrix2fv(m_properties[uniform], 1, 1, value.value_ptr);
	}

	public void set(string uniform, mat3 value)
	{
		glUniformMatrix3fv(m_properties[uniform], 1, 1, value.value_ptr);
	}

	public void set(string uniform, mat4 value)
	{
		glUniformMatrix4fv(m_properties[uniform], 1, 1, value.value_ptr);
	}

	public int pr() { return program; }

	private u32 program;
	private int[string] m_properties;
}

class GLShader : Shader
{
	public bool load(ShaderType type, string content)
	{
		this.content = content;
		switch(type)
		{
		case ShaderType.Vertex:
			m_id = glCreateShader(GL_VERTEX_SHADER);
			break;
		case ShaderType.TessControl:
			m_id = glCreateShader(GL_TESS_CONTROL_SHADER);
			break;
		case ShaderType.TessEvaluation:
			m_id = glCreateShader(GL_TESS_EVALUATION_SHADER);
			break;
		case ShaderType.Geometry:
			m_id = glCreateShader(GL_GEOMETRY_SHADER);
			break;
		case ShaderType.Fragment:
			m_id = glCreateShader(GL_FRAGMENT_SHADER);
			break;
		default:
			Logger.errln("ShaderType ", to!string(type) ," is not defined!");
			return false;
		}

		const i32 len = cast(const(i32))content.length;

		glShaderSource(m_id, 1, [content.ptr].ptr, &len);
		return true;
	}

	public bool compile()
	{
		glCompileShader(m_id);
		i32 success = 0;
		glGetShaderiv(m_id, GL_COMPILE_STATUS, &success);

		if(success == 0)
		{
			i32 logSize = 0;
			glGetShaderiv(m_id, GL_INFO_LOG_LENGTH, &logSize);

			char* log = new char[logSize].ptr;
			glGetShaderInfoLog(m_id, logSize, &logSize, &log[0]);

			Logger.writeln(content);

			Logger.errln("Program Output:\n", log[0 .. logSize]);
			return false;
		}
		return true;
	}

	public @property u32 id()
	{
		return m_id;
	}

	private u32 m_id = 0;
	private string content;
}
