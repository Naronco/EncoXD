import EncoShared;
import EncoDesktop;
import EncoGL3;

import DragTable;
import Level;
import Player;

class Game3DLayer : RenderLayer
{
	private Player player;

	public override void init(Scene scene)
	{
		Level level = new Level();
		if(!level.fromBitmap("levels/level0.png", GLMaterial.load(scene.renderer, "materials/metal.json"), scene.renderer))
			throw new Exception("Invalid Level!");
		level.setPlayer(player = new Player(scene.renderer.createMesh(MeshUtils.createCube(0.5f, 0.5f, 0.5f)), GLMaterial.load(scene.renderer, "materials/player.json")));
		addGameObject(level);

		Logger.writeln("Loaded Game3DLayer");
	}

	public void applyCamera(Camera camera)
	{
		camera.addComponent(new PlayerLock(player, camera));
	}
}

class GameScene : Scene
{
	public Game3DLayer game3DLayer;

	public override void init()
	{
		addLayer(game3DLayer = new Game3DLayer());
	}
}

void main(string[] args)
{
	GL3Renderer renderer = new GL3Renderer();
	GameScene game = new GameScene();
	EncoContext.create(new DesktopView(), renderer, game);

	EncoContext.instance.useDynamicLibraries([DynamicLibrary.Assimp, DynamicLibrary.SDL2, DynamicLibrary.SDL2Image, DynamicLibrary.SDL2TTF]);
	EncoContext.instance.importSettings(import("demo.json"));
	EncoContext.instance.start();
	// You can now call renderer functions
				
	renderer.setClearColor(0.8f, 0.8f, 0.8f);

	Camera camera = new Camera();
	camera.farClip = 1000;
	camera.nearClip = -1000;
	camera.width = EncoContext.instance.view.width;
	camera.height = EncoContext.instance.view.height;
	camera.zoom = 10;
	camera.projectionMode = ProjectionMode.Orthographic3D;

	EncoContext.instance.onKeyDown += (sender, key) {
		if(key == Key.F1)
		{
			Logger.writeln("Rotation: ", camera.transform.rotation.y);
		}
	};
	
	camera.addComponent(new DragTableX());
	camera.addComponent(new DragTableHalfY());
	game.game3DLayer.applyCamera(camera);

	camera.transform.position = vec3(0, 0, 0);
	camera.transform.rotation = vec3(-0.9, 0.785398163, 0);
	
	RenderContext context = RenderContext(camera, vec3(1, 0.5, 0));

	game.game3DLayer.addGameObject(camera);

	KeyboardState* state = Keyboard.getState();
	MouseState* mstate = Mouse.getState();

	Random random = new Random();

	while(EncoContext.instance.update())
	{
		state = Keyboard.getState();
		mstate = Mouse.getState();

		renderer.beginFrame();
		
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);

		EncoContext.instance.draw3D(context);
		
		renderer.gui.begin();

		EncoContext.instance.draw2D();

		renderer.gui.end();

		renderer.endFrame();

		if (state.isKeyDown(Key.Escape)) break;

		EncoContext.instance.endUpdate();
	}

	Mouse.release();

	EncoContext.instance.stop();
}
