import EncoShared;
import EncoDesktop;
import EncoGL3;

import derelict.assimp3.assimp;

import std.stdio;
static import std.file;
import std.traits;

void main() {
	auto renderer = new GL3Renderer();
	auto context = new EncoContext(
				new DesktopView("UTF-8 Magic *:･ﾟ✧ (∩ ͡° ͜ʖ ͡°)⊃━☆ﾟ. * ･", 800, 600),
				renderer);
	context.start();
	renderer.setClearColor(0.5f, 0.8f, 1.0f);

	Shader vertex = new GLShader();
	vertex.load(ShaderType.Vertex, std.file.readText("shader.vert"));
	vertex.compile();

	Shader fragment = new GLShader();
	fragment.load(ShaderType.Fragment, std.file.readText("shader.frag"));
	fragment.compile();

	auto program = renderer.createShader([vertex, fragment]);
	program.registerUniform("modelview");
	program.registerUniform("projection");
	program.registerUniform("normalmatrix");

	mat4 modelview = mat4.look_at(vec3(0, 0, 4), vec3(0, 0, 0), vec3(0, 1, 0));
	mat4 projection = mat4.perspective(800, 600, 45, 0.1f, 100.0f);
	
	program.set("modelview", modelview);
	program.set("projection", projection);
	
	writeln(modelview);
	writeln(projection);
	program.set("normalmatrix", modelview.transposed().inverse());

	//DerelictASSIMP3.load();

	auto random = new Random();

	auto triangle = new Mesh();
	int i = 0;
	for(int x = 0; x < 10; x++)
	{
		for(int y = 0; y < 10; y++)
		{
			triangle.addVertices([vec3((x - 5) * 0.2f, (y - 4) * 0.2f, 0), vec3((x - 4) * 0.2f, (y - 4) * 0.2f, 0), vec3((x - 4) * 0.2f, (y - 5) * 0.2f, 0), vec3((x - 5) * 0.2f, (y - 5) * 0.2f, 0)]);
			triangle.addTexCoords([vec2(x * 0.1f, y * 0.1f), vec2(x * 0.1f + 0.1f, y * 0.1f), vec2(x * 0.1f + 0.1f, y * 0.1f + 0.1f), vec2(x * 0.1f, y * 0.1f + 0.1f)]);
			triangle.addNormals([vec3(random.nextFloat(), random.nextFloat(), random.nextFloat()), vec3(random.nextFloat(), random.nextFloat(), random.nextFloat()), vec3(random.nextFloat(), random.nextFloat(), random.nextFloat()), vec3(random.nextFloat(), random.nextFloat(), random.nextFloat())]);
			triangle.addIndices([i + 1, i , i + 3, i + 3, i + 2, i + 1]);
			i += 4;
		}
	}

	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);

	auto mesh = renderer.createMesh(triangle);
	
	// TODO: Minimize all this code to 15-25 lines + shaders + imports

	float t = 0;

	while(context.update())
	{
		renderer.beginFrame();
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);

		program.bind();

		modelview = mat4.look_at(vec3(0, 0, 4), vec3(0, 0, 0), vec3(0, 1, 0)) * mat4.identity.rotate(t, vec3(1, 0, 0));

		program.set("modelview", modelview);
		program.set("projection", projection);
		program.set("normalmatrix", modelview.transposed().inverse());
		renderer.renderMesh(mesh);

		renderer.endFrame();

		t += 0.01f;
	}

	renderer.deleteMesh(mesh);

	context.stop();
}
