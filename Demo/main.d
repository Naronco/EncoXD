import EncoShared;
import EncoDesktop;
import EncoGL3;

import std.stdio;
static import std.file;
import std.traits;

void main() {
	auto renderer = new GL3Renderer();
	auto context = new EncoContext(
				new DesktopView("UTF-8 Magic *:･ﾟ✧ (∩ ͡° ͜ʖ ͡°)⊃━☆ﾟ. * ･", 1600, 900),
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
	program.registerUniform("texSlot0");
	program.registerUniform("texScale");

	Camera camera = new Camera();
	camera.setWidth(1600);
	camera.setHeight(900);
	camera.setFov(45);
	
	program.set("texSlot0", 0);
	program.set("texScale", 1.0f);

	mat4 modelview = camera.viewMatrix;
	mat4 projection = camera.projectionMatrix;
	
	camera.transform.position = vec3(0, 1, 2);
	camera.transform.rotation = vec3(0, 20, 0);
	
	program.set("modelview", modelview);
	program.set("projection", projection);
	
	program.set("normalmatrix", mat4.identity.transposed().inverse());


	auto scene = Mesh.loadFromObj("yard.obj", 0);
	
	auto grassMesh = scene[3];
	auto fenceMesh = scene[2];
	auto decorationMesh = scene[1];
	auto treeMesh = scene[0];

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	GLTexture tex = new GLTexture();
	tex.load("bricks.png");
	tex.bind(0);

	GLTexture grassTex = new GLTexture();
	grassTex.load("grass.png");
	grassTex.bind(0);

	GLTexture decoTex = new GLTexture();
	decoTex.load("yard.png");
	decoTex.bind(0);

	GLTexture treeTex = new GLTexture();
	treeTex.load("tree.png");
	treeTex.bind(0);

	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	//glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	
	auto fence = renderer.createMesh(fenceMesh);
	auto grass = renderer.createMesh(grassMesh);
	auto decoration = renderer.createMesh(decorationMesh);
	auto trees = renderer.createMesh(treeMesh);
	
	// TODO: Minimize all this code to 15-25 lines + shaders + imports

	float t = 0;

	KeyboardState* state = Keyboard.getState();
	MouseState* mstate = Mouse.getState();

	while(context.update())
	{
		state = Keyboard.getState();
		mstate = Mouse.getState();

		renderer.beginFrame();
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);


		camera.transform.rotation = vec3(0, t, 0);
		modelview = camera.viewMatrix;
		//modelview = mat4.identity;
		
		program.bind();
		program.set("texScale", 1.0f);
		program.set("modelview", modelview);
		program.set("projection", projection);
		program.set("normalmatrix", mat4.identity.transposed().inverse());
		tex.bind(0);
		program.set("texScale", 50.0f);
		
		renderer.renderMesh(fence);
		
		program.set("texScale", 1.0f);

		decoTex.bind(0);

		renderer.renderMesh(decoration);
		
		grassTex.bind(0);
		program.set("texScale", 4.0f);
		renderer.renderMesh(grass);

		treeTex.bind(0);
		program.set("texScale", 1.0f);
		renderer.renderMesh(trees);

		renderer.endFrame();
		
		if (state.isKeyDown(SDLK_w)) camera.transform.position.x += 0.1f;
		if (state.isKeyDown(SDLK_s)) camera.transform.position.x -= 0.1f;
		if (state.isKeyDown(SDLK_a)) camera.transform.position.z += 0.1f;
		if (state.isKeyDown(SDLK_d)) camera.transform.position.z -= 0.1f;
		camera.transform.position.x = mstate.position.x * 0.01f;
		camera.transform.position.z = mstate.position.y * 0.01f;

		t += 0.01f;
	}
	
	renderer.deleteMesh(fence);
	renderer.deleteMesh(grass);
	renderer.deleteMesh(decoration);

	context.stop();
}
