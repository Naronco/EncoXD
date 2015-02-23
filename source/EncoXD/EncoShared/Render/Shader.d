module Enco.Shared.Render.Shader;

import EncoShared;

enum ShaderType : u8
{
	Vertex, TessControl, TessEvaluation, Geometry, Fragment
}

interface ShaderProgram
{
	u32 create();

	void attach(Shader shader);

	void link();

	void bind();

	int registerUniform(string uniform);

	final void registerUniforms(const string[] uniforms)
	{
		foreach(string uniform; uniforms)
			registerUniform(uniform);
	}
	
	void set(string uniform, int value);

	void set(string uniform, float value);

	void set(string uniform, vec2 value);

	void set(string uniform, vec3 value);

	void set(string uniform, vec4 value);

	void set(string uniform, mat2 value);

	void set(string uniform, mat3 value);

	void set(string uniform, mat4 value);

	u32 id();
}

interface Shader
{
	bool load(ShaderType type, string content);

	bool compile();

	u32 id();
}