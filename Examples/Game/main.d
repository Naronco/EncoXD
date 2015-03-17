import EncoShared;
import EncoDesktop;
import EncoGL3;

import DragTable;
import Level;
import Player;

import luad.error;
import std.file;

class Game3DLayer : RenderLayer
{
	private Player player;
	private int currentLevel = 0;
	private Material[] materials;
	private Level level;

	public override void init(Scene scene)
	{
	}

	public void applyCamera(Camera camera)
	{
		camera.addComponent(new PlayerLock(player, camera));
	}

	public void nextLevel()
	{
		if(!level.fromBitmap("levels/level" ~ to!string(currentLevel++) ~ ".png", materials, scene.renderer))
			Logger.writeln(new Exception("Invalid Level!"));
	}

	public void setLua(LuaState lua)
	{
		player = new Player(scene.renderer.createMesh(MeshUtils.createCube(0.5f, 0.5f, 0.5f)), GLMaterial.load(scene.renderer, "materials/player.json"));
		level = new Level(lua, player);
		
		materials ~= GLMaterial.load(scene.renderer, "materials/metal.json");
		materials ~= GLMaterial.load(scene.renderer, "materials/start.json");
		materials ~= GLMaterial.load(scene.renderer, "materials/finish.json");
		materials ~= GLMaterial.load(scene.renderer, "materials/checkpoint.json");
		materials ~= GLMaterial.load(scene.renderer, "materials/light_plate.json");
		materials ~= GLMaterial.load(scene.renderer, "materials/heavy_plate.json");
		materials ~= GLMaterial.load(scene.renderer, "materials/bridge.json");

		auto blocks = dirEntries("blocks/", SpanMode.shallow, false);

		auto plugins = dirEntries("plugins/", SpanMode.shallow, false);
		
		lua["registerBlock"] = &level.registerBlock;

		lua["registerBlockImportant"] = &level.registerBlockImportant;

		lua["makeUniqueFromXY"] = (int x, int y) { return cast(i32)((x & 0xFFFF) << 16 | (y & 0xFFFF)); }; 

		lua["onRespawn"] = &level.onRespawn;

		lua["onStateChange"] = &level.onStateChange;

		lua["hasBlock"] = &level.hasBlock;

		lua["setBlockEnabled"] = &level.setEnabled;

		Random rnd = new Random();

		lua["random"] = &rnd.nextInt;

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

		lua["win"] = &nextLevel;

		foreach(string file; plugins)
		{
			if(file.endsWith(".lua"))
			{
				try
				{
					lua.doFile(file);
				}
				catch(LuaErrorException e)
				{
					Logger.errln(e);
				}
				Logger.writeln("Loaded plugin from ", file);
			}
		}

		foreach(string file; blocks)
		{
			if(file.endsWith(".lua"))
			{
				try
				{
					lua.doFile(file);
				}
				catch(LuaErrorException e)
				{
					Logger.errln(e);
				}
				Logger.writeln("Loaded blocks from ", file);
			}
		}

		nextLevel();
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

	debug EncoContext.instance.onKeyDown += (sender, key) {
		if(key == Key.F1)
		{
			Logger.writeln("Rotation: ", camera.transform.rotation.y);
		}
		if(key == Key.F2)
		{
			game.game3DLayer.nextLevel();
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
