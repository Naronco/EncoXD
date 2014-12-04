module Enco.GL3.GLShader;

import EncoGL3;

import std.stdio;

class GLShaderProgram : ShaderProgram
{
	u32 create()
	{
		return program = glCreateProgram();
	}

	void attach(Shader shader)
	{
		glAttachShader(program, shader.id);
	}

	void link()
	{
		glLinkProgram(program);
		bind();
	}

	void bind()
	{
		glUseProgram(program);
	}
	
	int registerUniform(string uniform)
	{
		if((uniform in m_properties) !is null)
			return m_properties[uniform];
		m_properties[uniform] = glGetUniformLocation(program, uniform.ptr);
		return m_properties[uniform];
	}

	void set(string uniform, float value)
	{
		glUniform1f(m_properties[uniform], value);
	}

	void set(string uniform, vec2 value)
	{
		glUniform2fv(m_properties[uniform], 1, value.value_ptr);
	}

	void set(string uniform, vec3 value)
	{
		glUniform3fv(m_properties[uniform], 1, value.value_ptr);
	}

	void set(string uniform, vec4 value)
	{
		glUniform4fv(m_properties[uniform], 1, value.value_ptr);
	}

	void set(string uniform, mat2 value)
	{
		glUniformMatrix2fv(m_properties[uniform], 1, 1, value.value_ptr);
	}

	void set(string uniform, mat3 value)
	{
		glUniformMatrix3fv(m_properties[uniform], 1, 1, value.value_ptr);
	}

	void set(string uniform, mat4 value)
	{
		glUniformMatrix4fv(m_properties[uniform], 1, 1, value.value_ptr);
	}

	int pr() { return program; }

	private u32 program;
	private int[string] m_properties;
}

class GLShader : Shader
{
	bool load(ShaderType type, string content)
	{
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
			writeln("ShaderType is not defined!");
			return false;
		}

		const i32 len = content.length;

		glShaderSource(m_id, 1, [content.ptr].ptr, &len);
		return true;
	}

	bool compile()
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

			writeln(log[0 .. logSize]);
			return false;
		}
		return true;
	}
	
	@property u32 id()
	{
		return m_id;
	}

	private u32 m_id = 0;
}