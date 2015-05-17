import EncoShared;
import EncoDesktop;
import EncoGL3;

class SolarsystemLayer : RenderLayer
{
	MeshObject sun, earth, moon;

	public override void init(Scene scene)
	{
		auto planets = Mesh.loadFromObj("res/meshes/planets.obj", 0);

		sun = cast(MeshObject)addGameObject(new MeshObject(planets[0], GLMaterial.load(scene.renderer, "res/materials/sun.json")));
		earth = cast(MeshObject)addGameObject(new MeshObject(planets[1], GLMaterial.load(scene.renderer, "res/materials/earth.json")));
		earth.transform.position = vec3(10, 0, 0);
		moon = cast(MeshObject)addGameObject(new MeshObject(planets[2], GLMaterial.load(scene.renderer, "res/materials/moon.json")));
		moon.transform.position = vec3(1, 0, 0);

		sun.addChild(earth);
		earth.addChild(moon);

		// TODO: Add more planets
	}

	override protected void update(f64 deltaTime)
	{
		sun.transform.rotation = earth.transform.rotation + vec3(0, deltaTime * 0.1f, 0);
		earth.transform.rotation = earth.transform.rotation + vec3(0, deltaTime * 2.1f, 0);
		moon.transform.rotation = moon.transform.rotation + vec3(0, 0, deltaTime * 5.3f);
	}
}

class Solarsystem : Scene
{
	public SolarsystemLayer layer;

	public override void init()
	{
		addLayer(layer = new SolarsystemLayer());
	}
}

class GameWindow : DesktopView
{
	RenderContext context;
	Solarsystem game;

	public this()
	{
		scene = game = new Solarsystem();
	}

	public void init()
	{
		Camera camera = new Camera();
		renderer.setClearColor(0, 0, 0);
		camera.nearClip = 0.1f;
		camera.farClip = 100.0f;
		camera.width = width;
		camera.height = height;

		camera.addComponent(new FPSRotation());
		camera.addComponent(new FreeMove());

		context = RenderContext(camera, vec3(1, 0.5, 0.3));

		game.layer.addGameObject(camera);
	}

	override protected void onDraw()
	{
		renderer.clearBuffer(RenderingBuffer.colorBuffer | RenderingBuffer.depthBuffer);

		draw3D(context);
		draw2D();
	}

	override protected void onUpdate(f64 delta)
	{
		update(delta);
	}
}

void main(string[] args)
{
	EncoContext.create([DynamicLibrary.SDL2, DynamicLibrary.SDL2Image, DynamicLibrary.Assimp]);

	GameWindow window = new GameWindow();
	EncoContext.instance.addView!GL3Renderer(window);
	EncoContext.instance.importSettings(import("game.json"));
	EncoContext.instance.start();
	scope(exit) EncoContext.instance.stop();

	Mouse.capture();

	window.init();

	while(EncoContext.instance.update())
	{
		EncoContext.instance.draw();

		if (Keyboard.getState().isKeyDown(Key.Escape)) break;

		EncoContext.instance.endUpdate();
	}
}
