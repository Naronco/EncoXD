module Enco.GL3.GLMaterial;

import EncoGL3;

import std.json;
import std.stdio;
import std.conv;

class GLMaterial
{
	/// Loads JSON Material File in format {Name:str, Textures:int->texture, Vertex:str/shader, Fragment:str/shader}
	static Material load(IRenderer renderer, string file)
	{
		JSONValue value = parseJSON!string(std.file.readText(file));
		
		assert(value.type == JSON_TYPE.OBJECT);
		assert(value["Name"].type == JSON_TYPE.STRING);
		assert(value["Textures"].type == JSON_TYPE.OBJECT);
		assert(value["Vertex"].type == JSON_TYPE.STRING || value["Vertex"].type == JSON_TYPE.OBJECT);
		assert(value["Fragment"].type == JSON_TYPE.STRING || value["Fragment"].type == JSON_TYPE.OBJECT);

		Material mat = Material();
		mat.name = value["Name"].str;

		JSONValue[string] textures = value["Textures"].object;

		string textureSlots = "";
		string[] textureSlotUniforms;

		foreach(string id, JSONValue texture; textures)
		{
			textureSlots ~= "uniform sampler2D slot" ~ id ~ ";\n";
			textureSlotUniforms ~= "slot" ~ id;

			int i = parse!int(id);

			GLTexture tex = GLTexturePool.load(texture["File"].str);
			if(texture["MipMap"].type == JSON_TYPE.TRUE)
			{
				tex.enableMipMaps = true;
				tex.minFilter = TextureFilterMode.LinearMipmapLinear;
			}
			tex.applyTexParams();

			mat.textures[i] = tex;
		}

		string vertex;
		if(value["Vertex"].type == JSON_TYPE.STRING)
		{
			vertex = std.file.readText("shaders/" ~ value["Vertex"].str ~ ".vert");
		}
		else
		{
			string[string] vars;
			foreach(string name, JSONValue val; value["Vertex"].object)
			{
				vars[name] = val.str;
			}
			vars["TextureSlots"] = textureSlots;

			vertex = TemplateParser.parse(std.file.readText("shaders/" ~ value["Vertex"]["Base"].str ~ ".vert"), vars);
		}
		
		string fragment;
		if(value["Fragment"].type == JSON_TYPE.STRING)
		{
			fragment = std.file.readText("shaders/" ~ value["Fragment"].str ~ ".frag");
		}
		else
		{
			string[string] vars;
			foreach(string name, JSONValue val; value["Fragment"].object)
			{
				vars[name] = val.str;
			}
			vars["TextureSlots"] = textureSlots;

			fragment = TemplateParser.parse(std.file.readText("shaders/" ~ value["Fragment"]["Base"].str ~ ".frag"), vars);
		}

		GLShader vs = new GLShader();
		vs.load(ShaderType.Vertex, vertex);
		vs.compile();

		GLShader fs = new GLShader();
		fs.load(ShaderType.Fragment, fragment);
		fs.compile();

		auto program = renderer.createShader([vs, fs]);
		program.registerUniforms(["modelview", "projection", "normalmatrix", "l_direction", "l_viewDir"] ~ textureSlotUniforms);

		mat.program = program;

		return mat;
	}
}