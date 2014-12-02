import EncoShared;
import EncoDesktop;
import EncoGL3;

import std.stdio;
import std.traits;

void main() {
	DerelictSDL2.load();
	SDL_Init(SDL_INIT_VIDEO);

	auto renderer = new GL3Renderer();

	auto context = new EncoContext(
				new DesktopView("UTF-8 Magic *:･ﾟ✧ (∩ ͡° ͜ʖ ͡°)⊃━☆ﾟ. * ･", 800, 600),
				renderer);

	context.start();
	renderer.setClearColor(0.5f, 0.8f, 1.0f);

	uint program, vs, fs;

	vs = glCreateShader(GL_VERTEX_SHADER);
	fs = glCreateShader(GL_FRAGMENT_SHADER);

	string vertex = "#version 330

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec2 in_tex;

out vec2 texCoord;

void main(void)
{
	gl_Position = vec4(in_position, 1);

	texCoord = in_tex;
}";

	const int vl = vertex.length;

	glShaderSource(vs, 1, [vertex.ptr].ptr, &vl);
	glCompileShader(vs);

	char* log = new char[1024].ptr;
	int len = 0;
	glGetShaderInfoLog(vs, 1024, &len, log);

	if(len != 0)
	{
		write(log[0 .. len]);
		return;
	}

	string fragment = "#version 330
out vec4 out_frag_color;

in vec2 texCoord;

void main(void)
{
	out_frag_color = vec4(texCoord.x, 0, texCoord.y, 1);
}";

	const int fl = fragment.length;

	glShaderSource(fs, 1, [fragment.ptr].ptr, &fl);
	glCompileShader(fs);

	char* flog = new char[1024].ptr;
	int flen = 0;
	glGetShaderInfoLog(fs, 1024, &flen, flog);

	if(flen != 0)
	{
		write(flog[0 .. flen]);
		return;
	}

	program = glCreateProgram();
	glAttachShader(program, vs);
	glAttachShader(program, fs);

	glLinkProgram(program);
	glUseProgram(program);

	auto triangle = new Mesh();
	triangle.addVertices([vec3(-1, 1, 0), vec3(1, 1, 0), vec3(1, -1, 0), vec3(-1, -1, 0)]);
	triangle.addTexCoords([vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]);
	triangle.addIndices([3, 0, 1, 1, 2, 3]);
	// TODO: Minimize all this code to 10-20 lines + shaders

	auto mesh = renderer.createMesh(triangle);

	while(context.update())
	{
		renderer.beginFrame();
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);

		glUseProgram(program);
		renderer.renderMesh(mesh);

		renderer.endFrame();
	}

	renderer.deleteMesh(mesh);

	context.stop();
}
