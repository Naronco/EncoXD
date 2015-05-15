module GameScene;

import EncoShared;
import EncoGL3;

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
	private LuaTable playerTable;

	public override void init(Scene scene)
	{
	}

	public void applyCamera(Camera camera)
	{
		camera.addComponent(new PlayerLock(player, camera));
	}

	public void nextLevel()
	{
		if(!level.fromBitmap("res/levels/level" ~ to!string(currentLevel++) ~ ".png", materials, scene.renderer))
			Logger.writeln(new Exception("Invalid Level!"));
	}
	
	private bool isDouble() { return player.isDouble; }
	private int getState() { return player.topState; }
	
	private int getX() { return player.x; }
	private int getY() { return player.y; }
	private void setX(int v) { player.x = v; }
	private void setY(int v) { player.y = v; }
	
	private int getRespawnX() { return player.respawnPosition.x; }
	private int getRespawnY() { return player.respawnPosition.y; }
	private void setRespawnX(int v) { player.respawnPosition = i32vec2(v, player.respawnPosition.y); }
	private void setRespawnY(int v) { player.respawnPosition = i32vec2(player.respawnPosition.x, v); }
	
	private int getFinishX() { return player.finishPosition.x; }
	private int getFinishY() { return player.finishPosition.y; }
	private void setFinishX(int v) { player.finishPosition = i32vec2(v, player.finishPosition.y); }
	private void setFinishY(int v) { player.finishPosition = i32vec2(player.finishPosition.x, v); }

	private int makeUniqueFromXY(int x, int y) { return cast(i32)((x & 0xFFFF) << 16 | (y & 0xFFFF)); }


	public void setLua(LuaState lua)
	{
		player = new Player(scene.renderer.createMesh(MeshUtils.createCube(0.5f, 0.5f, 0.5f)), GLMaterial.load(scene.renderer, "res/materials/player.json"));
		level = new Level(lua, player);
		
		materials ~= GLMaterial.load(scene.renderer, "res/materials/metal.json");
		materials ~= GLMaterial.load(scene.renderer, "res/materials/start.json");
		materials ~= GLMaterial.load(scene.renderer, "res/materials/finish.json");
		materials ~= GLMaterial.load(scene.renderer, "res/materials/checkpoint.json");
		materials ~= GLMaterial.load(scene.renderer, "res/materials/light_plate.json");
		materials ~= GLMaterial.load(scene.renderer, "res/materials/heavy_plate.json");
		materials ~= GLMaterial.load(scene.renderer, "res/materials/bridge.json");

		auto blocks = dirEntries("res/blocks/", SpanMode.shallow, false);

		auto plugins = dirEntries("res/plugins/", SpanMode.shallow, false);
		
		lua["registerBlock"] = &level.registerBlock;

		lua["registerBlockImportant"] = &level.registerBlockImportant;

		lua["makeUniqueFromXY"] = &makeUniqueFromXY; 

		lua["onRespawn"] = &level.onRespawn;

		lua["onStateChange"] = &level.onStateChange;

		lua["hasBlock"] = &level.hasBlock;

		lua["setBlockEnabled"] = &level.setEnabled;

		Random rnd = new Random();

		lua["random"] = &rnd.nextInt;

		playerTable = lua.newTable();

		playerTable["isDouble"] = &isDouble;

		playerTable["getState"] = &getState;

		playerTable["getX"] = &getX;
		playerTable["getY"] = &getY;
		playerTable["setX"] = &setX;
		playerTable["setY"] = &setY;
		
		playerTable["getRespawnX"] = &getRespawnX;
		playerTable["getRespawnY"] = &getRespawnY;
		playerTable["setRespawnX"] = &setRespawnX;
		playerTable["setRespawnY"] = &setRespawnY;
		
		playerTable["getFinishX"] = &getFinishX;
		playerTable["getFinishY"] = &getFinishY;
		playerTable["setFinishX"] = &setFinishX;
		playerTable["setFinishY"] = &setFinishY;

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