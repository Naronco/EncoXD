import EncoShared;
import EncoDesktop;
import EncoGL3;

import GameScene;
import Player;

import std.stdio;
import std.traits;

void main()
{
	GL3Renderer renderer = new GL3Renderer();
	GameScene game = new GameScene();
	EncoContext.create(
				new DesktopView(),
				renderer,
				game);

	EncoContext.instance.useDynamicLibraries([DynamicLibrary.Assimp, DynamicLibrary.SDL2, DynamicLibrary.SDL2Image]);
	EncoContext.instance.importSettings(import("demo.json"));
	EncoContext.instance.start();

	Camera camera = new Camera();
	camera.farClip = 100;
	camera.fov = 45;
	
	camera.transform.position = vec3(0, 1, 2);
	camera.addComponent(new FPSRotation());
	camera.addComponent(new Player());

	game.game3DLayer.addGameObject(camera);

	RenderContext render = RenderContext(camera);

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
	
	Keyboard.update();
	Mouse.update();

	KeyboardState* state = Keyboard.getState();
	MouseState* mstate = Mouse.getState();

	Mouse.capture(cast(DesktopView)EncoContext.instance.view);

	while(EncoContext.instance.update())
	{
		Keyboard.update();
		Mouse.update();

		state = Keyboard.getState();
		mstate = Mouse.getState();

		renderer.beginFrame();

		target.bind();

		EncoContext.instance.draw(render);
		
		target.unbind();

		program.bind();

		target.color.bind(0);
		tex.bind(1);
		target.depth.bind(2);

		renderer.renderMesh(m);

		renderer.endFrame();
		
		if (state.isKeyDown(SDLK_ESCAPE)) break;
	}

	EncoContext.instance.stop();
}
