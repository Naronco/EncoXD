module EncoShared.Render.Shader;

import EncoShared;

enum ShaderType : ubyte
{
	Vertex, TessControl, TessEvaluation, Geometry, Fragment
}

interface ShaderProgram
{
	uint create();

	void attach(Shader shader);

	void link();

	void bind();

	int registerUniform(string uniform);

	final void registerUniforms(const string[] uniforms)
	{
		foreach (string uniform; uniforms)
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

	uint id();
}

interface Shader
{
	bool load(ShaderType type, string content);

	bool compile();

	uint id();
}
