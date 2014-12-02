module Enco.Shared.Enco3D.Shader;

import EncoShared;

alias u32 ShaderProgram;

enum ShaderType
{
	Vertex, TessControl, TessEvaluation, Geometry, Fragment
}

interface Shader
{
	void load(ShaderType type, string content);

	void compile();
}