import EncoShared;
import EncoDesktop;
import EncoGL3;

import DragTableX;

class Game3DLayer : RenderLayer
{
	AnimatedProperty!float carY;
	GameObject carObj, carGlassObj;
	bool up = false;
	
	public override void init(Scene scene)
	{
		auto meshes = Mesh.loadFromObj("meshes/floor.obj", 0);
		
		addGameObject(new MeshObject(meshes[0], GLMaterial.load(scene.renderer, "materials/orthoFloor.json")));
		
		carY = new AnimatedProperty!float(0.0f);
		carY.easingType = "sinusoidal";
		carY.value = 5.0f;
		carY.length = 3000;

		carY.onDone += {
			up = !up;
			carY.value = up ? 0 : 5;
		};

		auto car = Mesh.loadFromObj("meshes/car.obj", 0);
		carGlassObj = addGameObject(new MeshObject(car[0], GLMaterial.load(scene.renderer, "materials/glass.json")));
		carObj = addGameObject(new MeshObject(car[1], GLMaterial.load(scene.renderer, "materials/car.json")));
	}

	override protected void update(f64 deltaTime)
	{
		carY.update(deltaTime);
	}
	
	override protected void preDraw(RenderContext context, IRenderer renderer)
	{
		carObj.transform.position.y = cast(float)carY;
		carGlassObj.transform.position.y = cast(float)carY;
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
	EncoContext.create(
				new DesktopView(),
				renderer,
				game);


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
	camera.projectionMode = ProjectionMode.Orthographic3D;

	camera.addComponent(new DragTableX());

	camera.transform.position = vec3(0, 0, 0);
	camera.transform.rotation = vec3(-0.785398163, 0.785398163, 0);
	
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

		if (state.isKeyDown(SDLK_ESCAPE)) break;

		EncoContext.instance.endUpdate();
	}

	Mouse.release();

	EncoContext.instance.stop();
}
