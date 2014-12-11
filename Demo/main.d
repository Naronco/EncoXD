import EncoShared;
import EncoDesktop;
import EncoGL3;

import GameScene;

import std.stdio;
import std.traits;

void main() {
	auto renderer = new GL3Renderer();
	EncoContext.create(
				new DesktopView("UTF-8 Magic *:･ﾟ✧ (∩ ͡° ͜ʖ ͡°)⊃━☆ﾟ. * ･", 1600, 900),
				renderer,
				new GameScene());
	EncoContext.instance.start();
	renderer.setClearColor(0.5f, 0.8f, 1.0f);

	Camera camera = new Camera();
	camera.width = 1600;
	camera.height = 900;
	camera.farClip = 100;
	camera.fov = 45;
	
	camera.transform.position = vec3(0, 1, 2);
	camera.addComponent(new FPSRotation());

	RenderContext render = RenderContext();
	render.camera = camera;

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_CULL_FACE);
	//glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
	
	// TODO: Minimize all this code to 15-25 lines + shaders + imports

	Mesh m = new Mesh();
	m.addVertices([vec3(-1, -1, 0), vec3(1, -1, 0), vec3(1, 1, 0), vec3(-1, 1, 0)]);
	m.addTexCoords([vec2(0, 0), vec2(1, 0), vec2(1, 1), vec2(0, 1)]);
	m.addNormals([vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1), vec3(0, 0, 1)]);
	m.addIndices([0, 1, 2, 0, 2, 3]);
	m = renderer.createMesh(m);

	GLTexture3D tex = new GLTexture3D();
	tex.wrapX = TextureClampMode.ClampToEdge;
	tex.wrapY = TextureClampMode.ClampToEdge;
	tex.wrapZ = TextureClampMode.ClampToEdge;
	tex.load("tex/pallete16_mod.png");

	GLRenderTarget target = new GLRenderTarget();
	target.init(1600, 900, true);

	GLShaderProgram program = cast(GLShaderProgram)GLShaderProgram.fromVertexFragmentFiles(renderer, "shaders/post.vert", "shaders/post.frag");
	program.registerUniforms(["slot0", "slot1", "slot2"]);
	program.set("slot0", 0);
	program.set("slot1", 1);
	program.set("slot2", 2);

	KeyboardState* state = Keyboard.getState();
	MouseState* mstate = Mouse.getState();

	Mouse.capture(cast(DesktopView)EncoContext.instance.view);

	while(EncoContext.instance.update())
	{
		state = Keyboard.getState();
		mstate = Mouse.getState();

		renderer.beginFrame();

		target.bind();
		
		camera.performUpdate(0);

		EncoContext.instance.draw(render);
		
		target.unbind();

		program.bind();

		target.color.bind(0);
		tex.bind(1);
		target.depth.bind(2);

		renderer.renderMesh(m);

		renderer.endFrame();
		
		if (state.isKeyDown(SDLK_w)) camera.transform.position += vec3(cos(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x), -sin(-camera.transform.rotation.x), sin(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x)) * 0.1f;
		if (state.isKeyDown(SDLK_s)) camera.transform.position -= vec3(cos(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x), -sin(-camera.transform.rotation.x), sin(-camera.transform.rotation.y - 1.57079633f) * cos(-camera.transform.rotation.x)) * 0.1f;
		if (state.isKeyDown(SDLK_a)) camera.transform.position -= vec3(cos(-camera.transform.rotation.y), 0, sin(-camera.transform.rotation.y)) * 0.1f;
		if (state.isKeyDown(SDLK_d)) camera.transform.position += vec3(cos(-camera.transform.rotation.y), 0, sin(-camera.transform.rotation.y)) * 0.1f;
		if (state.isKeyDown(SDLK_SPACE)) camera.transform.position += vec3(0, 1, 0) * 0.1f;
		if (state.isKeyDown(SDLK_LSHIFT)) camera.transform.position -= vec3(0, 1, 0) * 0.1f;
		if (state.isKeyDown(SDLK_ESCAPE)) break;
		//if (state.isKeyDown(SDLK_a)) camera.transform.position.z += 0.1f;
		//if (state.isKeyDown(SDLK_d)) camera.transform.position.z -= 0.1f;
		//camera.transform.rotation -= vec3(mstate.offset.y, mstate.offset.x, 0) * 0.005f;
	}

	EncoContext.instance.stop();
}
