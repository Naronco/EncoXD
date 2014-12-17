import EncoShared;
import EncoDesktop;
import EncoGL3;

import GameScene;

import std.stdio;
import std.traits;

void main() {
	auto renderer = new GL3Renderer();
	EncoContext.create(
				new DesktopView(),
				renderer,
				new GameScene());
	EncoContext.instance.importSettings(import("demo.json"));
	EncoContext.instance.start();

	Camera camera = new Camera();
	camera.width = EncoContext.instance.view.width;
	camera.height = EncoContext.instance.view.height;
	camera.farClip = 100;
	camera.fov = 45;
	
	camera.transform.position = vec3(0, 1, 2);
	camera.addComponent(new FPSRotation());

	RenderContext render = RenderContext();
	render.camera = camera;
	
	// TODO: Minimize all this code to 15-25 lines + shaders + imports

	Mesh m = renderer.createMesh(MeshUtils.createPlane());

	GLTexture3D tex = new GLTexture3D();
	tex.wrapX = TextureClampMode.ClampToEdge;
	tex.wrapY = TextureClampMode.ClampToEdge;
	tex.wrapZ = TextureClampMode.ClampToEdge;
	tex.load("tex/pallete16_mod.png");

	GLRenderTarget target = new GLRenderTarget();
	target.init(EncoContext.instance.view.width, EncoContext.instance.view.height, true);

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
