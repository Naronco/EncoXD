import EncoShared;
import EncoDesktop;
import EncoGL3;

import DragTable;
import Level;
import Player;

import std.file;

class Game3DLayer : RenderLayer
{
	private Player player;
	private int currentLevel = 1;
	private Material[] materials;

	public override void init(Scene scene)
	{
	}

	public void applyCamera(Camera camera)
	{
		camera.addComponent(new PlayerLock(player, camera));
	}

	public void setLua(LuaState lua)
	{
		player = new Player(scene.renderer.createMesh(MeshUtils.createCube(0.5f, 0.5f, 0.5f)), GLMaterial.load(scene.renderer, "materials/player.json"));
		Level level = new Level(lua, player);

		materials ~= GLMaterial.load(scene.renderer, "materials/metal.json");

		auto blocks = dirEntries("blocks/", SpanMode.shallow, false);

		auto plugins = dirEntries("plugins/", SpanMode.shallow, false);
		
		lua["registerBlock"] = &level.registerBlock;

		lua["onRespawn"] = &level.onRespawn;

		lua["onStateChange"] = &level.onStateChange;

		lua["hasBlock"] = &level.hasBlock;

		LuaTable playerTable = lua.newTable();

		playerTable["isDouble"] = () { return player.isDouble; };

		playerTable["getState"] = () { return player.topState; };

		playerTable["getX"] = () { return player.x; };
		playerTable["getY"] = () { return player.y; };
		playerTable["setX"] = (int v) { player.x = v; };
		playerTable["setY"] = (int v) { player.y = v; };

		playerTable["setRespawnX"] = (int v) { player.respawnPosition = i32vec2(v, player.respawnPosition.y); };
		playerTable["setRespawnY"] = (int v) { player.respawnPosition = i32vec2(player.respawnPosition.x, v); };
		playerTable["getRespawnX"] = () { return player.respawnPosition.x; };
		playerTable["getRespawnY"] = () { return player.respawnPosition.y; };
		
		playerTable["setFinishX"] = (int v) { player.finishPosition = i32vec2(v, player.finishPosition.y); };
		playerTable["setFinishY"] = (int v) { player.finishPosition = i32vec2(player.finishPosition.x, v); };
		playerTable["getFinishX"] = () { return player.finishPosition.x; };
		playerTable["getFinishY"] = () { return player.finishPosition.y; };
		
		playerTable["respawn"] = &player.respawn;

		lua["player"] = playerTable;

		lua["win"] = () {
			if(!level.fromBitmap("levels/level" ~ to!string(currentLevel++) ~ ".png", materials, scene.renderer))
				throw new Exception("Invalid Level!");
		};

		foreach(string file; plugins)
		{
			if(file.endsWith(".lua"))
			{
				lua.doFile(file);
				Logger.writeln("Loaded plugin from ", file);
			}
		}

		foreach(string file; blocks)
		{
			if(file.endsWith(".lua"))
			{
				lua.doFile(file);
				Logger.writeln("Loaded blocks from ", file);
			}
		}

		if(!level.fromBitmap("levels/level0.png", materials, scene.renderer))
			throw new Exception("Invalid Level!");
		addGameObject(level);
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

	EncoContext.instance.useDynamicLibraries([DynamicLibrary.Lua, DynamicLibrary.SDL2, DynamicLibrary.SDL2Image]);
	EncoContext.instance.importSettings(import("demo.json"));
	EncoContext.instance.start();
	// You can now call renderer functions

	renderer.setClearColor(0.8f, 0.8f, 0.8f);
	auto lua = EncoContext.instance.createLuaState();

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

	camera.transform.position = vec3(0, 0, 0);
	camera.transform.rotation = vec3(-0.9, 0.785398163, 0);

	RenderContext context = RenderContext(camera, vec3(1, 0.5, 0.3));
	
	game.game3DLayer.setLua(lua);
	game.game3DLayer.applyCamera(camera);
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
