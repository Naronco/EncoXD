import EncoShared;
import EncoDesktop;
import EncoGL3;

import GameScene;
import Player;

import std.stdio;
import std.traits;

class GameWindow : DesktopView
{
	RenderContext context;
	GameScene game;
	GLRenderTarget target;
	Mesh plane;
	GLShaderProgram program;
	GLTexture3D palette;

	public this()
	{
		scene = game = new GameScene();
	}

	public void init()
	{
		Camera camera = new Camera();
		camera.farClip = 600;
		camera.fov = 45;
		camera.width = width;
		camera.height = height;

		camera.transform.position = vec3(0, 1, 2);
		camera.addComponent(new FPSRotation());
		camera.addComponent(new Player());

		game.game3DLayer.addGameObject(camera);

		context = RenderContext(camera);

		plane = renderer.createMesh(MeshUtils.createPlane());

		palette = new GLTexture3D();
		palette.wrapX = TextureClampMode.ClampToEdge;
		palette.wrapY = TextureClampMode.ClampToEdge;
		palette.wrapZ = TextureClampMode.ClampToEdge;
		palette.fromBitmap(Bitmap.load("res/tex/pallete16_mod.png"));

		target = new GLRenderTarget();
		target.init(width, height, true, this);

		program = cast(GLShaderProgram)GLShaderProgram.fromVertexFragmentFiles(cast(GL3Renderer)renderer, "res/shaders/post.vert", "res/shaders/post.frag");
		program.registerUniforms(["slot0", "slot1", "slot2"]);
		program.set("slot0", 0);
		program.set("slot1", 1);
		program.set("slot2", 2);

		MouseState* mstate = Mouse.getState();
		Mouse.capture();

		EncoContext.instance.onControllerAdded += (sender, id) {
			Logger.writeln("Added controller #", id);
		};

		EncoContext.instance.onControllerRemoved += (sender, id) {
			Logger.writeln("Removed controller #", id);
		};

		EncoContext.instance.onControllerButtonDown += (sender, e) {
			Logger.writeln("#", e.id, " down ", e.button);
		};

		EncoContext.instance.onControllerButtonUp += (sender, e) {
			Logger.writeln("#", e.id, " up ", e.button);
		};

		EncoContext.instance.onControllerAxis += (sender, e) {
			Logger.writeln("#", e.id, " axis ", e.axis, " -> ", (e.value * 0.00003051757));
		};
	}

	override protected void onDraw()
	{
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);

		target.bind();
		
		draw3D(context);

		target.unbind();

		program.bind();

		target.color.bind(0);
		palette.bind(1);
		target.depth.bind(2);

		renderer.renderMesh(plane);
		
		renderer.gui.begin();
		
		draw2D();

		renderer.gui.end();
	}
	
	override protected void onUpdate(f64 delta)
	{
		update(delta);
	}
}

void main()
{
	EncoContext.create([DynamicLibrary.Assimp, DynamicLibrary.SDL2, DynamicLibrary.SDL2Image, DynamicLibrary.SDL2TTF]);

	GameWindow window = new GameWindow();

	EncoContext.instance.addView!GL3Renderer(window);
	EncoContext.instance.importSettings(import("demo.json"));
	EncoContext.instance.start();

	window.init();

	KeyboardState* state = Keyboard.getState();

	while(EncoContext.instance.update())
	{
		state = Keyboard.getState();

		EncoContext.instance.draw();

		if (state.isKeyDown(SDLK_ESCAPE)) break;

		EncoContext.instance.endUpdate();
	}

	Mouse.release();

	EncoContext.instance.stop();
}
