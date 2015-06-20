module Enco.GL3.GLMaterial;

import EncoGL3;

import std.json;
import std.stdio;
import std.conv;

class GLMaterialManager : IMaterialManager
{
private:
	GL3Renderer m_renderer;

public:

	this(GL3Renderer renderer)
	{
		assert(renderer !is null, "Passed null as renderer");
		m_renderer = renderer;
	}

	/// Loads JSON Material File in format {Name:str, Textures:str->{File:str,MipMap:bool?,Smooth:bool?}, Blend:bool?, DepthTest:bool?, Vertex:str/shader, Fragment:str/shader}
	public Material load(string file)
	{
		JSONValue value = parseJSON!string(std.file.readText(file));

		assert(value.type == JSON_TYPE.OBJECT);
		assert(value["Name"].type == JSON_TYPE.STRING);
		assert(value["Textures"].type == JSON_TYPE.OBJECT);
		assert(value["Vertex"].type == JSON_TYPE.STRING || value["Vertex"].type == JSON_TYPE.OBJECT);
		assert(value["Fragment"].type == JSON_TYPE.STRING || value["Fragment"].type == JSON_TYPE.OBJECT);

		Material mat = Material();
		mat.name = value["Name"].str;

		mat.blend = "Blend" in value && value["Blend"].type == JSON_TYPE.TRUE;

		if ("DepthTest" in value)
			mat.depth = value["DepthTest"].type == JSON_TYPE.TRUE;
		else
			mat.depth = true;

		JSONValue[string] textures = value["Textures"].object;

		string	 textureSlots = "";
		string[] textureSlotUniforms;

		foreach (string id, JSONValue texture; textures)
		{
			textureSlots ~= "uniform sampler2D slot" ~ id ~ ";";
			textureSlotUniforms ~= "slot" ~ id;

			if (texture["File"].str != "null")
			{
				int		  i = parse!int (id);

				GLTexture tex = GLTexturePool.load(texture["File"].str);
				if (("MipMap" in texture) !is null && texture["MipMap"].type == JSON_TYPE.TRUE)
				{
					tex.enableMipMaps = true;
					tex.minFilter	  = TextureFilterMode.LinearMipmapLinear;
				}
				if (("Smooth" in texture) !is null && texture["Smooth"].type == JSON_TYPE.FALSE)
				{
					tex.minFilter = TextureFilterMode.Nearest;
					tex.magFilter = TextureFilterMode.Nearest;
				}
				tex.applyParameters();

				mat.textures[i] = tex;
			}
		}

		string vertex;
		if (value["Vertex"].type == JSON_TYPE.STRING)
		{
			vertex = std.file.readText("res/shaders/" ~ value["Vertex"].str ~ ".vert");
		}
		else
		{
			string[string] vars;
			foreach (string name, JSONValue val; value["Vertex"].object)
			{
				vars[name] = val.str;
			}
			vars["TextureSlots"] = textureSlots;

			vertex = TemplateParser.parse(std.file.readText("res/shaders/" ~ value["Vertex"]["Base"].str ~ ".vert"), vars);
		}

		string fragment;
		if (value["Fragment"].type == JSON_TYPE.STRING)
		{
			fragment = std.file.readText("res/shaders/" ~ value["Fragment"].str ~ ".frag");
		}
		else
		{
			string[string] vars;
			foreach (string name, JSONValue val; value["Fragment"].object)
			{
				vars[name] = val.str;
			}
			vars["TextureSlots"] = textureSlots;

			fragment = TemplateParser.parse(std.file.readText("res/shaders/" ~ value["Fragment"]["Base"].str ~ ".frag"), vars);
		}

		GLShader vs = new GLShader();
		vs.load(ShaderType.Vertex, vertex);
		vs.compile();

		GLShader fs = new GLShader();
		fs.load(ShaderType.Fragment, fragment);
		fs.compile();

		auto program = m_renderer.createShader([vs, fs]);
		program.registerUniforms(["modelview", "projection", "normalmatrix", "l_direction", "cam_translation"] ~ textureSlotUniforms);

		mat.program = program;

		return mat;
	}

	public deprecated static Material load(IRenderer renderer, string file)
	{
		auto m = new GLMaterialManager(cast(GL3Renderer)renderer);
		return m.load(file);
	}
}

deprecated alias GLMaterial = GLMaterialManager;

class GLMaterialPool
{
	public static Material load(GL3Renderer renderer, string texture)
	{
		if ((texture in m_materials) !is null)
			return m_materials[texture];

		GLMaterialManager mat = new GLMaterialManager(renderer);
		m_materials[texture] = mat.load(texture);
		return m_materials[texture];
	}

	private static Material[string] m_materials;
}
