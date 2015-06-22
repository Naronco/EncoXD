module Level;

import std.file;

import EncoShared;

import Player;

class Block : GameObject
{
	protected int m_x, m_y;

	public @property int x()
	{
		return m_x;
	}
	public @property int y()
	{
		return m_y;
	}

	public @property bool willFall()
	{
		return false;
	}

	public this(int x, int y, Mesh regularPlane, Material material)
	{
		m_x = x;
		m_y = y;


		MeshObject mesh = new MeshObject(regularPlane, material);
		mesh.transform.position = vec3(m_x, 0, m_y);
		addChild(mesh);
	}

	public void onPlayerStateChange(Player player)
	{
	}
	public void onPlayerRespawn(Player player)
	{
	}
}

class LuaBlock : Block
{
	private LuaFunction m_playerStateChange;
	private LuaFunction m_playerRespawn;

	public this(int x, int y, Mesh regularPlane, Material material, LuaFunction playerStateChange, LuaFunction playerRespawn)
	{
		super(x, y, regularPlane, material);
		m_playerStateChange = playerStateChange;
		m_playerRespawn		= playerRespawn;
	}

	override public void onPlayerStateChange(Player player)
	{
		m_playerStateChange(x - 1, y - 1);
	}

	override public void onPlayerRespawn(Player player)
	{
		m_playerRespawn(x - 1, y - 1);
	}
}

struct BlockRegister
{
	int			rgb;
	u8			mid;
	LuaFunction added;
	LuaFunction playerStateChange;
	LuaFunction playerRespawn;
}

class Level : GameObject
{
	private i32vec2			m_finish, m_start;
	private LuaState		m_lua;
	private BlockRegister[] m_registered;
	private BlockRegister[] m_registeredI;
	private Block[]			m_blocks;
	private LuaFunction[]	m_respawnEvents;
	private LuaFunction[]	m_stateEvents;
	private Player			player;

	public this(LuaState lua, Player player)
	{
		m_lua		= lua;
		this.player = player;
		addChild(player);

		player.onRespawn += (s) {
			foreach (ref Block block; m_blocks)
				block.onPlayerRespawn(player);
			foreach (ref LuaFunction evt; m_respawnEvents)
				evt();
		};

		player.onStateChange += (s) {
			foreach (ref Block block; m_blocks)
				block.onPlayerStateChange(player);
			foreach (ref LuaFunction evt; m_stateEvents)
				evt();
		};
	}

	private void registerBlock(u8 r, u8 g, u8 b, u8 mid, LuaFunction added, LuaFunction playerStateChange, LuaFunction playerRespawn)
	{
		m_registered ~= BlockRegister(r << 16 | g << 8 | b, mid, added, playerStateChange, playerRespawn);
	}

	private void registerBlockImportant(u8 r, u8 g, u8 b, u8 mid, LuaFunction added, LuaFunction playerStateChange, LuaFunction playerRespawn)
	{
		m_registeredI ~= BlockRegister(r << 16 | g << 8 | b, mid, added, playerStateChange, playerRespawn);
	}

	private void onRespawn(LuaFunction f)
	{
		m_respawnEvents ~= f;
	}

	private void onStateChange(LuaFunction f)
	{
		m_stateEvents ~= f;
	}

	public bool hasBlock(int x, int y)
	{
		foreach (ref Block block; m_blocks)
			if (block.x - 1 == x && block.y - 1 == y)
				return block.enabled;
		return false;
	}

	public void setEnabled(int x, int y, bool val)
	{
		foreach (ref Block block; m_blocks)
			if (block.x - 1 == x && block.y - 1 == y)
				block.enabled = val;
	}

	public bool fromBitmap(string path, Material[] materials, IRenderer renderer)
	{
		if (!exists(path))
		{
			Logger.errln(path, " doesn't exist");
			return false;
		}
		foreach (ref Block block; m_blocks)
		{
			removeChild(block);
		}
		m_blocks.length = 0;
		Bitmap bmp = Bitmap.load(path);
		scope (exit) bmp.destroy();
		Mesh   boxes = MeshUtils.createCube(0.5f, 0.1f, 0.5f, -0.5f, -0.1f, -0.5f);
		boxes = renderer.createMesh(boxes);
		for (int x = 0; x < bmp.width; x++)
		{
 PxLoopI: for (int y = 0; y < bmp.height; y++)
			{
				Color pixel = bmp.getPixel(x, y);
				if (pixel.RGB == 0xFFFFFF)
					continue PxLoopI;
				foreach (ref BlockRegister block; m_registeredI)
				{
					if (pixel.RGB == block.rgb)
					{
						block.added(x - 1, y - 1);
						Block b = new LuaBlock(x, y, boxes, materials[block.mid], block.playerStateChange, block.playerRespawn);
						m_blocks ~= b;
						addChild(b);
						continue PxLoopI;
					}
				}
			}
		}
		for (int x = 0; x < bmp.width; x++)
		{
 PxLoop: for (int y = 0; y < bmp.height; y++)
			{
				Color pixel = bmp.getPixel(x, y);
				if (pixel.RGB == 0xFFFFFF)
					continue PxLoop;
				foreach (ref BlockRegister block; m_registered)
				{
					if (pixel.RGB == block.rgb)
					{
						block.added(x - 1, y - 1);
						Block b = new LuaBlock(x, y, boxes, materials[block.mid], block.playerStateChange, block.playerRespawn);
						m_blocks ~= b;
						addChild(b);
						continue PxLoop;
					}
				}
			}
		}

		player.respawn();
		return true;
	}
}
