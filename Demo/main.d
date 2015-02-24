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


	EncoContext.instance.useDynamicLibraries([DynamicLibrary.Assimp, DynamicLibrary.SDL2, DynamicLibrary.SDL2Image, DynamicLibrary.SDL2TTF]);
	EncoContext.instance.importSettings(import("demo.json"));
	EncoContext.instance.start();

	Camera camera = new Camera();
	camera.farClip = 600;
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
	tex.fromBitmap(Bitmap.load("tex/pallete16_mod.png"));

	GLRenderTarget target = new GLRenderTarget();
	target.init(EncoContext.instance.view.width, EncoContext.instance.view.height, true);

	GLShaderProgram program = cast(GLShaderProgram)GLShaderProgram.fromVertexFragmentFiles(renderer, "shaders/post.vert", "shaders/post.frag");
	program.registerUniforms(["slot0", "slot1", "slot2"]);
	program.set("slot0", 0);
	program.set("slot1", 1);
	program.set("slot2", 2);

	KeyboardState* state = Keyboard.getState();
	MouseState* mstate = Mouse.getState();
	Mouse.capture();

	Random random = new Random();

	GLTexture[] guitex = [GLTexturePool.load("tex/test.png"), GLTexturePool.load("tex/test2.png")];
	vec4[] colors = new vec4[16 * 9];
	for(int x = 0; x < 16; x++)
		for(int y = 0; y < 9; y++)
			colors[x + y * 16] = vec4(random.nextFloat(), random.nextFloat(), random.nextFloat(), random.nextFloat());
			
	EncoContext.instance.onKeyUp += (sender, key) {
		if(key == SDLK_p)
		{
			Bitmap surf = renderer.getComputed();
			surf.save("screen.bmp");
			surf.destroy();
		}
	};

	EncoContext.instance.onControllerAdded += (sender, id) {
		Logger.writeln("Added controller #", id);
	};

	EncoContext.instance.onControllerRemoved += (sender, id) {
		Logger.writeln("Removed controller #", id);
	};

	EncoContext.instance.onControllerButtonDown += (sender, evt) {
		Logger.writeln("#", cast(i32)evt[0], " down ", cast(i32)evt[1]);
	};

	EncoContext.instance.onControllerButtonUp += (sender, evt) {
		Logger.writeln("#", cast(i32)evt[0], " up ", cast(i32)evt[1]);
	};

	EncoContext.instance.onControllerAxis += (sender, button) {
		Logger.writeln("#", cast(i32)button[0], " axis ", cast(i32)button[1], " -> ", (button[2] * 0.00003051757));
	};

	while(EncoContext.instance.update())
	{
		state = Keyboard.getState();
		mstate = Mouse.getState();

		renderer.beginFrame();

		target.bind();

		EncoContext.instance.draw3D(render);

		target.unbind();

		program.bind();

		target.color.bind(0);
		tex.bind(1);
		target.depth.bind(2);

		renderer.renderMesh(m);
		
		renderer.gui.begin();

		EncoContext.instance.draw2D();

		renderer.gui.end();

		renderer.endFrame();

		if (state.isKeyDown(SDLK_ESCAPE)) break;

		EncoContext.instance.endUpdate();
	}

	Mouse.release();

	EncoContext.instance.stop();
}
