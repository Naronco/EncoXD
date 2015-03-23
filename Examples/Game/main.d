import EncoShared;
import EncoDesktop;
import EncoGL3;

import DragTable;

import GameScene;

class GameWindow : DesktopView
{
	RenderContext context;
	GameScene game;
	
	public this()
	{
		scene = game = new GameScene();
	}

	public void init()
	{
		Camera camera = new Camera();
		renderer.setClearColor(0.8f, 0.8f, 0.8f);
		auto lua = EncoContext.instance.createLuaState();
		camera.farClip = 1000;
		camera.nearClip = -1000;
		camera.width = width;
		camera.height = height;
		camera.zoom = 10;
		camera.projectionMode = ProjectionMode.Orthographic3D;

		debug EncoContext.instance.onKeyDown += (sender, key) {
			if(key == Key.F1)
			{
				Logger.writeln("Rotation: ", camera.transform.rotation.pitch);
			}
			if(key == Key.F2)
			{
				game.game3DLayer.nextLevel();
			}
		};

		camera.addComponent(new DragTableX());
		camera.addComponent(new DragTableHalfY());

		camera.transform.position = vec3(0, 0, 0);
		camera.transform.rotation = camera.transform.rotation.euler_rotation(-0.9, -0.2, 0);

		context = RenderContext(camera, vec3(1, 0.5, 0.3));
	
		game.game3DLayer.setLua(lua);
		game.game3DLayer.applyCamera(camera);
		game.game3DLayer.addGameObject(camera);
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
	EncoContext.create([DynamicLibrary.Lua, DynamicLibrary.SDL2, DynamicLibrary.SDL2Image]);
	
	GameWindow window = new GameWindow();
	EncoContext.instance.addView!GL3Renderer(window);
	EncoContext.instance.importSettings(import("game.json"));
	EncoContext.instance.start();
	scope(exit) EncoContext.instance.stop();
	
	window.init();

	KeyboardState* state = Keyboard.getState();

	while(EncoContext.instance.update())
	{
		state = Keyboard.getState();

		EncoContext.instance.draw();

		if (state.isKeyDown(Key.Escape)) break;

		EncoContext.instance.endUpdate();
	}
}
